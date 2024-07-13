--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

G.MULTIPLAYER.actions = {

  JOIN = function(data)
    G.MULTIPLAYER.enabled = true
    G.MULTIPLAYER.versus = false
    G.MULTIPLAYER.players = data.players
    -- Load UI
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
    G.OVERLAY_MENU.config.no_esc = true
  end,

  LEAVE = function(data)
    G.MULTIPLAYER.players = data.players
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = G.UIDEF.server_config(),
    }
    G.OVERLAY_MENU.config.no_esc = true
  end,

  START = function(data)
    local key = 1
    for k, v in ipairs(G.P_CENTER_POOLS.Back) do
      if v.name == data.deck then
        key = k
        break
      end
    end
    G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[key])
    G.FUNCS.start_run(nil, { seed = data.seed, stake = data.stake })
  end,

  PLAY_HAND = function(data)
    G.FUNCS.play_cards_from_highlighted()
  end,

  DISCARD_HAND = function(data)
    G.FUNCS.discard_cards_from_highlighted()
  end,

  HIGHLIGHT = function(data)
    G[data.type]:add_to_highlighted(G[data.type].cards[data.index])
  end,

  UNHIGHLIGHT = function(data)
    G[data.type]:remove_from_highlighted(G[data.type].cards[data.index])
  end,

  UNHIGHLIGHT_ALL = function(data)
    G.hand:unhighlight_all()
  end,

}

----------------------------------------------
------------MOD CODE END----------------------