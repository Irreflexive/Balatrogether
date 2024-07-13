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
local sell_card = G.FUNCS.sell_card
local use_card = G.FUNCS.use_card

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
    G.GAME.selected_back = G.P_CENTER_POOLS.Back[key]
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
    local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "select_blind")
    if e then select_blind(e) end
  end,

  SKIP_BLIND = function(data)
    local e = findDescendantOfElementByConfig(G.blind_select:get_UIE_by_ID(G.GAME.blind_on_deck), "button", "skip_blind")
    if e then skip_blind(e) end
  end,

  SELL = function(data)
    local card = G[data.type].cards[data.index]
    card:sell_card()
    for i = 1, #G.jokers.cards do
      if G.jokers.cards[i] ~= card then 
        G.jokers.cards[i]:calculate_joker({selling_card = true, card = card})
      end
    end
  end,

  USE = function(data)
    local card = G.consumeables.cards[data.index]
    use_card({config = {ref_table = card}})
  end,

  BUY = function(data)
    local card = G.jokers.cards[data.index]
    card:buy_card()
  end,

  BUY_AND_USE = function(data)
    local card = G.jokers.cards[data.index]
    card:buy_and_use_card()
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

G.FUNCS.sell_card = function(e, ...)
  if G.MULTIPLAYER.enabled then
    local index = 1
    local card = e.config.ref_table
    for k,v in ipairs(card.area) do
      if v == card then index = k end
    end
    G.FUNCS.tcp_send({ cmd = "SELL", index = index, type = card.area == G.jokers and 'jokers' or 'consumeables' })
  else
    sell_card(e, ...)
  end
end

G.FUNCS.use_card = function(e, ...)
  if G.MULTIPLAYER.enabled then
    local index = 1
    local card = e.config.ref_table
    for k,v in ipairs(card.area) do
      if v == card then index = k end
    end
    G.FUNCS.tcp_send({ cmd = "USE", index = index })
  else
    use_card(e, ...)
  end
end

----------------------------------------------
------------MOD CODE END----------------------