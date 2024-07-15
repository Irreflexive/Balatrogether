G.FUNCS.endless_multiplayer = function(e)
  G.FUNCS.tcp_send({ cmd = "ENDLESS" })
end

G.MULTIPLAYER.actions.JOIN = function(data)
  G.MULTIPLAYER.enabled = true
  G.MULTIPLAYER.versus = false
  G.MULTIPLAYER.players = data.players
  if (G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list')) or data.players[#data.players] == tostring(G.STEAM.user.getSteamID()) then
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
  end
  G.OVERLAY_MENU.config.no_esc = true
end

G.MULTIPLAYER.actions.LEAVE = function(data)
  G.MULTIPLAYER.players = data.players
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('balatrogether_player_list') then
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
  end
end

G.MULTIPLAYER.actions.START = function(data)
  G.GAME.selected_back = Back(get_deck_from_name(data.deck))
  local debug_challenge = {
    name = 'Multiplayer Test',
    id = 'c_multiplayer_test',
    rules = {
      custom = {},
      modifiers = {
        {id = 'dollars', value = 1000},
        {id = 'consumable_slots', value = 5},
      }
    },
    jokers = {
      {id = 'j_joker'},
      {id = 'j_joker'},
      {id = 'j_joker'},
      {id = 'j_joker'},
      {id = 'j_joker'},
    },
    consumeables = {
      {id = 'c_heirophant'},
      {id = 'c_high_priestess'},
      {id = 'c_pluto'},
    },
    vouchers = {},
    deck = {
      type = G.GAME.selected_back.name,
    },
    restrictions = {
      banned_cards = {},
      banned_tags = {},
      banned_other = {}
    }
  }
  G.FUNCS.start_run(nil, { seed = data.seed, stake = data.stake, challenge = G.MULTIPLAYER.debug and debug_challenge or nil })
end

G.MULTIPLAYER.actions.ENDLESS = function(data)
  G.FUNCS.exit_overlay_menu()
end