G.FUNCS.sell_card = function(e, ...)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() and card.area then
    local areaType = getCardAreaType(card.area, {G.jokers, G.consumeables})
    if not areaType then return end
    G.FUNCS.tcp_send({ cmd = "SELL", index = card.Multiplayer_ID, type = areaType })
  else
    G.SINGLEPLAYER_FUNCS.sell_card(e, ...)
  end
end

G.FUNCS.use_card = function(e, ...)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() then
    local areaType = getCardAreaType(card.area, {G.shop_jokers, G.shop_booster, G.shop_vouchers, G.pack_cards, G.consumeables})
    if not areaType then return end
    G.FUNCS.tcp_send(areaType == "consumeables" and { cmd = "USE", index = card.Multiplayer_ID } or { cmd = "BUY", index = card.Multiplayer_ID, type = areaType })
  else
    G.SINGLEPLAYER_FUNCS.use_card(e, ...)
  end
end

G.FUNCS.buy_from_shop = function(e)
  local card = e.config.ref_table
  if G.FUNCS.is_coop_game() then
    local areaType = getCardAreaType(card.area, {G.shop_jokers})
    if not areaType then return end
    if e.config.id ~= 'buy_and_use' then
      if not G.FUNCS.check_for_buy_space(card) then
        e.disable_button = nil
        return
      end
    end
    G.FUNCS.tcp_send({ cmd = e.config.id == 'buy_and_use' and "BUY_AND_USE" or "BUY", index = card.Multiplayer_ID, type = areaType })
  else
    G.SINGLEPLAYER_FUNCS.buy_card(e)
  end
end

G.FUNCS.tcp_listen("SELL", function(data)
  local area = G[data.type]
  local areaType = getCardAreaType(area, {G.jokers, G.consumeables})
  if not areaType then return end
  local card = getCardFromMultiplayerID(area, data.index)
  if not card then return end
  G.SINGLEPLAYER_FUNCS.sell_card({config = {ref_table = card}})
end)

G.FUNCS.tcp_listen("USE", function(data)
  local card = getCardFromMultiplayerID(G.consumeables, data.index)
  if not card then return end
  G.SINGLEPLAYER_FUNCS.use_card({config = {ref_table = card}})
end)

G.FUNCS.tcp_listen("BUY", function(data)
  if data.type == "shop_jokers" then
    local card = getCardFromMultiplayerID(G.shop_jokers, data.index)
    if not card then return end
    local e = findDescendantOfElementByConfig(card, "func", "can_buy")
    if not e then return end
    G.SINGLEPLAYER_FUNCS.run_buy_event(e)
  else
    local area = G[data.type]
    local areaType = getCardAreaType(area, {G.shop_booster, G.shop_vouchers, G.pack_cards})
    if not areaType then return end
    local card = getCardFromMultiplayerID(area, data.index)
    if not card then return end
    G.SINGLEPLAYER_FUNCS.use_card({config = {ref_table = card}})
  end
end)

G.FUNCS.tcp_listen("BUY_AND_USE", function(data)
  local card = getCardFromMultiplayerID(G.shop_jokers, data.index)
  if not card then return end
  local e = findDescendantOfElementByConfig(card, "id", "buy_and_use")
  if not e then return end
  G.SINGLEPLAYER_FUNCS.buy_card(e)
end)