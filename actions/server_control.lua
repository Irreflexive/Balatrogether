G.FUNCS.endless_multiplayer = function(e)
  G.FUNCS.tcp_send({ cmd = "ENDLESS" })
end

G.FUNCS.start_setup_run = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  if G.SETTINGS.current_setup == 'New Run' then 
    if not G.GAME or (not G.GAME.won and not G.GAME.seeded) then
      if G.SAVED_GAME ~= nil then
        if not G.SAVED_GAME.GAME.won then 
          G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
        end
        G:save_settings()
      end
    end
    local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
    local _challenge = G.challenge_tab or nil
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.start_run(e, {stake = _stake, seed = _seed, challenge = _challenge})
  
  elseif G.SETTINGS.current_setup == 'Multiplayer Run' then
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    local _deck = G.PROFILES[G.SETTINGS.profile].MEMORY.deck or "Red Deck"
    G.FUNCS.tcp_send({
      cmd = "START", 
      stake = _stake, 
      seed = generate_starting_seed(), 
      challenge = nil, 
      deck = _deck, 
      versus = G.new_multiplayer_run_config.versus
    })

  elseif G.SETTINGS.current_setup == 'Continue' then
    if G.SAVED_GAME ~= nil then
      G.FUNCS.start_run(nil, {savetext = G.SAVED_GAME})
    end
  end
end

function Controller:key_hold_update(key, dt)
  if ((self.locked) and not G.SETTINGS.paused) or (self.locks.frame) or (self.frame_buttonpress) then return end
  --self.frame_buttonpress = true
  if self.held_key_times[key] then
      if key == "r" and not G.SETTINGS.paused then
          if self.held_key_times[key] > 0.7 then
              if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
                  G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
              end
              G:save_settings()
              self.held_key_times[key] = nil
              if G.MULTIPLAYER.enabled then
                G.SETTINGS.current_setup = 'Multiplayer Run'
              else
                G.SETTINGS.current_setup = 'New Run'
              end
              G.GAME.viewed_back = nil
              G.run_setup_seed = G.GAME.seeded
              G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
              G.forced_seed, G.setup_seed = nil, nil
              if G.GAME.seeded then G.forced_seed = G.GAME.pseudorandom.seed end
              G.forced_stake = G.GAME.stake
              if G.STAGE == G.STAGES.RUN then G.FUNCS.start_setup_run() end
              G.forced_stake = nil
              G.challenge_tab = nil
              G.forced_seed = nil
          else
              self.held_key_times[key] = self.held_key_times[key] + dt
          end
      end
  end
end

G.FUNCS.tcp_listen("JOIN", function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.players = data.players
  G.MULTIPLAYER.max_players = data.maxPlayers
  if (G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list')) or data.players[#data.players] == tostring(G.STEAM.user.getSteamID()) then
    G.FUNCS.setup_run_multiplayer()
  end
  G.OVERLAY_MENU.config.no_esc = true
end)

G.FUNCS.tcp_listen("LEAVE", function(data)
  G.MULTIPLAYER.players = data.players
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list') then
    G.FUNCS.setup_run_multiplayer()
  end
end)

G.FUNCS.tcp_listen("START", function(data)
  G.MULTIPLAYER.versus = data.versus
  G.new_multiplayer_run_config.versus = data.versus
  G.MULTIPLAYER.leaderboard_blind = false
  G.MULTIPLAYER.leaderboard = nil
  G.GAME.selected_back = Back(get_deck_from_name(data.deck))
  local cards = {}
  for i = 1, 52 do
    if i <= 10 then
      table.insert(cards, {s='S',r='K',g='Red'})
    elseif i <= 20 then
      table.insert(cards, {s='S',r='K',g='Blue'})
    elseif i <= 30 then
      table.insert(cards, {s='S',r='K',g='s_' .. SMODS.current_mod.prefix .. '_green'})
    elseif i <= 40 then
      table.insert(cards, {s='S',r='K',g='Purple'})
    elseif i <= 50 then
      table.insert(cards, {s='S',r='K',g='Gold'})
    else
      table.insert(cards, {s='S',r='K'})
    end
  end
  local debug_challenge = {
    name = 'Multiplayer (DEBUG)',
    id = 'c_multiplayer_debug',
    rules = {
      custom = {},
      modifiers = {
        {id = 'dollars', value = 1000},
        {id = 'consumable_slots', value = 5},
      }
    },
    jokers = {
      {id = 'j_joker', edition = data.versus and SMODS.current_mod.prefix .. '_secure' or nil},
      {id = 'j_joker'},
      {id = 'j_joker'},
      {id = data.versus and 'j_' .. SMODS.current_mod.prefix .. '_annie_and_hallie' or 'j_joker'},
      {id = data.versus and 'j_' .. SMODS.current_mod.prefix .. '_annie_and_hallie' or 'j_joker'},
    },
    consumeables = {
      {id = 'c_wheel_of_fortune'},
      {id = 'c_aura'},
      {id = 'c_pluto'},
      {id = data.versus and 'c_' .. SMODS.current_mod.prefix .. '_cup' or 'c_heirophant'},
    },
    vouchers = {},
    deck = {
      cards = data.versus and cards or nil,
      type = G.GAME.selected_back.name,
    },
    restrictions = {
      banned_cards = {},
      banned_tags = {},
      banned_other = {}
    }
  }
  G.FUNCS.start_run(nil, { 
    seed = data.seed, 
    stake = data.stake, 
    challenge = data.debug and 
      debug_challenge or 
      nil,
  })
end)

G.FUNCS.tcp_listen("ENDLESS", function(data)
  G.FUNCS.exit_overlay_menu()
end)