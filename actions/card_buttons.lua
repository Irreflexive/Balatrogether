G.FUNCS.sell_card = function(e, ...)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() and card.area then
    local index = 1
    for k,v in ipairs(card.area.cards) do
      if v.ID == card.ID then index = k end
    end
    local areaType = getCardAreaType(card.area, {G.jokers, G.consumeables})
    if areaType then
      G.FUNCS.tcp_send({ cmd = "SELL", index = index, type = areaType })
    end
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
    local areaType = getCardAreaType(card.area, {G.shop_jokers, G.shop_booster, G.shop_vouchers, G.pack_cards, G.consumeables})
    if areaType then
      G.FUNCS.tcp_send(areaType == "consumeables" and { cmd = "USE", index = index } or { cmd = "BUY", index = index, type = areaType })
    end
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
    local areaType = getCardAreaType(card.area, {G.shop_jokers})
    if areaType then
      G.FUNCS.tcp_send({ cmd = e.config.id == 'buy_and_use' and "BUY_AND_USE" or "BUY", index = index, type = areaType })
    end
  else
    G.SINGLEPLAYER_FUNCS.buy_card(e)
  end
end

G.FUNCS.tcp_listen("SELL", function(data)
  local area = G[data.type]
  local areaType = getCardAreaType(area, {G.jokers, G.consumeables})
  if areaType then
    local card = area.cards[data.index]
    G.SINGLEPLAYER_FUNCS.sell_card({config = {ref_table = card}})
  end
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
    local area = G[data.type]
    local areaType = getCardAreaType(area, {G.shop_booster, G.shop_vouchers, G.pack_cards})
    if areaType then
      local card = area.cards[data.index]
      G.SINGLEPLAYER_FUNCS.use_card({config = {ref_table = card}})
    end
  end
end)

G.FUNCS.tcp_listen("BUY_AND_USE", function(data)
  local e = findDescendantOfElementByConfig(G.shop_jokers.cards[data.index], "id", "buy_and_use")
  if not e then return end
  G.SINGLEPLAYER_FUNCS.buy_card(e)
end)