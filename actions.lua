--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

local play_hand = G.FUNCS.play_cards_from_highlighted
local discard_hand = G.FUNCS.discard_cards_from_highlighted
local sort_by_value = G.FUNCS.sort_hand_value
local sort_by_suit = G.FUNCS.sort_hand_suit
local select_blind = G.FUNCS.select_blind
local skip_blind = G.FUNCS.skip_blind

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
    play_hand()
  end,

  DISCARD_HAND = function(data)
    discard_hand()
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

  SORT_HAND = function(data)
    if data.type == "suit" then
      sort_by_suit()
    elseif data.type == "value" then
      sort_by_value()
    end
  end,

  SELECT_BLIND = function(data)
    local e = G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck)
    select_blind(e)
  end,

  SKIP_BLIND = function(data)
    local e = G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck)
    skip_blind(e)
  end,

}

G.FUNCS.play_cards_from_highlighted = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "PLAY_HAND" })
  else
    play_hand(...)
  end
end

G.FUNCS.discard_cards_from_highlighted = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "DISCARD_HAND" })
  else
    discard_hand(...)
  end
end

G.FUNCS.sort_hand_suit = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SORT_HAND", type = "suit" })
  else
    sort_by_suit(...)
  end
end

G.FUNCS.sort_hand_value = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SORT_HAND", type = "value" })
  else
    sort_by_value(...)
  end
end

G.FUNCS.select_blind = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SELECT_BLIND" })
  else
    select_blind(...)
  end
end

G.FUNCS.skip_blind = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "SKIP_BLIND" })
  else
    skip_blind(...)
  end
end

----------------------------------------------
------------MOD CODE END----------------------