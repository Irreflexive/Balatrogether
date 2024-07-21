G.FUNCS.sell_card = function(e, ...)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() and card.area then
    local index = 1
    for k,v in ipairs(card.area.cards) do
      if v.ID == card.ID then index = k end
    end
    G.FUNCS.tcp_send({ cmd = "SELL", index = index, type = card.area == G.jokers and 'jokers' or 'consumeables' })
  else
    G.SINGLEPLAYER_FUNCS.sell_card(e, ...)
  end
end

G.FUNCS.use_card = function(e, ...)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() then
    local index = 1
    for k,v in ipairs(card.area.cards) do
      if v.ID == card.ID then index = k end
    end
    local areaType = card.area == G.shop_jokers and "shop_jokers"
      or card.area == G.shop_booster and "shop_booster"
      or card.area == G.shop_vouchers and "shop_vouchers"
      or card.area == G.pack_cards and "pack_cards"
      or nil
    G.FUNCS.tcp_send({ cmd = card.area == G.consumeables and "USE" or "BUY", index = index, type = areaType })
  else
    G.SINGLEPLAYER_FUNCS.use_card(e, ...)
  end
end

G.FUNCS.buy_from_shop = function(e)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() then
    local index = 1
    for k,v in ipairs(G.shop_jokers.cards) do
      if v.ID == card.ID then index = k end
    end
    G.FUNCS.tcp_send({ cmd = e.config.id == 'buy_and_use' and "BUY_AND_USE" or "BUY", index = index, type = "shop_jokers" })
  else
    G.SINGLEPLAYER_FUNCS.buy_card(e)
  end
end

G.FUNCS.tcp_listen("SELL", function(data)
  local card = G[data.type].cards[data.index]
  G.SINGLEPLAYER_FUNCS.sell_card({config = {ref_table = card}})
end)

G.FUNCS.tcp_listen("USE", function(data)
  local card = G.consumeables.cards[data.index]
  G.SINGLEPLAYER_FUNCS.use_card({config = {ref_table = card}})
end)

G.FUNCS.tcp_listen("BUY", function(data)
  if data.type == "shop_jokers" then
    local e = findDescendantOfElementByConfig(G.shop_jokers.cards[data.index], "func", "can_buy")
    if not e then return end
    G.SINGLEPLAYER_FUNCS.buy_card(e)
  else
    local card = G[data.type].cards[data.index]
    G.SINGLEPLAYER_FUNCS.use_card({config = {ref_table = card}})
  end
end)

G.FUNCS.tcp_listen("BUY_AND_USE", function(data)
  local e = findDescendantOfElementByConfig(G.shop_jokers.cards[data.index], "id", "buy_and_use")
  if not e then return end
  G.SINGLEPLAYER_FUNCS.buy_card(e)
end)