G.FUNCS.endless_multiplayer = function(e)
  G.FUNCS.tcp_send({ cmd = "ENDLESS" })
end

G.FUNCS.tcp_listen("JOIN", function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.players = data.players
  if (G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list')) or data.players[#data.players] == tostring(G.STEAM.user.getSteamID()) then
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
  end
  G.OVERLAY_MENU.config.no_esc = true
end)

G.FUNCS.tcp_listen("LEAVE", function(data)
  G.MULTIPLAYER.players = data.players
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list') then
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
  end
end)

G.FUNCS.tcp_listen("START", function(data)
  G.MULTIPLAYER.versus = data.versus
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
      banned_other = G.FUNCS.is_versus_game() and disabled_blinds or {}
    }
  }
  G.FUNCS.start_run(nil, { 
    seed = data.seed, 
    stake = data.stake, 
    challenge = G.MULTIPLAYER.debug and 
      debug_challenge or 
      nil,
  })
end)

G.FUNCS.tcp_listen("ENDLESS", function(data)
  G.FUNCS.exit_overlay_menu()
end)