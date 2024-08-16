G.FUNCS.endless_multiplayer = function(e)
  G.FUNCS.tcp_send({ cmd = "ENDLESS" })
end

G.FUNCS.change_gamespeed = function(args)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "GAME_SPEED", speed = args.to_val })
  end
  G.SINGLEPLAYER_FUNCS.change_gamespeed(args)
end

local start_setup_run_ref = G.FUNCS.start_setup_run
G.FUNCS.start_setup_run = function(e)
  if G.SETTINGS.current_setup == 'Multiplayer Run' or Balatrogether.server.enabled then
    G.FUNCS.exit_overlay_menu()
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    local _deck = G.PROFILES[G.SETTINGS.profile].MEMORY.deck or "Red Deck"
    G.FUNCS.tcp_send({
      cmd = "START", 
      stake = _stake, 
      seed = generate_starting_seed(), 
      challenge = nil, 
      deck = _deck, 
      versus = Balatrogether.new_run_config.versus,
      speed = G.SETTINGS.GAMESPEED
    })
  else
    start_setup_run_ref(e)
  end
end

G.FUNCS.join_lobby = function(e)
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN_LOBBY", number = e.config.id })
end

G.FUNCS.tcp_listen("JOIN", function(data)
  Balatrogether.server.enabled = true
  Balatrogether.server.versus = false
  Balatrogether.server.players = data.players
  Balatrogether.server.max_players = data.maxPlayers
  if (G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list')) or data.players[#data.players].id == tostring(G.STEAM.user.getSteamID()) then
    G.FUNCS.setup_run_multiplayer()
  end
  G.OVERLAY_MENU.config.no_esc = true
end)

G.FUNCS.tcp_listen("LOBBIES", function(data)
  Balatrogether.server.lobbies = data
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_lobby_list') then
    G.FUNCS['change_' .. Balatrogether.prefix .. '_server_lobbies_list_page']()
  else
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.lobby_list(),
    }
  end
end)

G.FUNCS.tcp_listen("LEAVE", function(data)
  Balatrogether.server.players = data.players
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list') then
    G.FUNCS.setup_run_multiplayer()
  end
end)

G.FUNCS.tcp_listen("START", function(data)
  Balatrogether.server.versus = data.versus
  Balatrogether.new_run_config.versus = data.versus
  Balatrogether.server.card_id = 0
  Balatrogether.server.leaderboard_blind = false
  Balatrogether.server.leaderboard = nil
  if not data.versus then
    G.SINGLEPLAYER_FUNCS.change_gamespeed({to_val = data.speed})
  end

  G.GAME.selected_back = Back(get_deck_from_name(data.deck))

  local cards = {}
  local enhancements = {"m_bonus", "m_mult", "m_wild", "m_glass", "m_steel", "m_stone", "m_gold", "m_lucky"}
  local editions = {"foil", "holo", "polychrome", createCollectionId(nil, 'secure')}
  for i = 1, 52 do
    local en = enhancements[i % (#enhancements + 1) + 1]
    local ed = editions[i % (#editions + 1) + 1]
    if i <= 10 then
      table.insert(cards, {s='S',r='K',g='Red',e=en,d=ed})
    elseif i <= 20 then
      table.insert(cards, {s='S',r='K',g='Blue',e=en,d=ed})
    elseif i <= 30 then
      table.insert(cards, {s='S',r='K',g=createCollectionId('s', 'green'),e=en,d=ed})
    elseif i <= 40 then
      table.insert(cards, {s='S',r='K',g='Purple',e=en,d=ed})
    elseif i <= 50 then
      table.insert(cards, {s='S',r='K',g='Gold',e=en,d=ed})
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
      {id = 'j_joker', edition = data.versus and createCollectionId(nil, 'secure') or nil},
      {id = 'j_joker'},
      {id = 'j_joker'},
      {id = data.versus and createCollectionId('j', 'annie_and_hallie') or 'j_joker'},
      {id = data.versus and createCollectionId('j', 'annie_and_hallie') or 'j_joker'},
    },
    consumeables = {
      {id = 'c_wheel_of_fortune'},
      {id = 'c_aura'},
      {id = 'c_pluto'},
      {id = data.versus and createCollectionId('c', 'cup') or 'c_heirophant'},
      data.versus and {id = createCollectionId('c', 'siphon')} or nil
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

G.FUNCS.tcp_listen("WIN", function(data)
  win_game()
end)

G.FUNCS.tcp_listen("GAME_SPEED", function(data)
  G.SINGLEPLAYER_FUNCS.change_gamespeed({to_val = data.speed})
end)