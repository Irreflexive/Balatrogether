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
    -- Here we copy and paste from buy_from_shop directly because there is a bug after buying when jokers are full
    -- TODO: Find a way to do this without copying the source
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = function()
        card.area:remove_card(card)
        card:add_to_deck()
        if card.children.price then card.children.price:remove() end
        card.children.price = nil
        if card.children.buy_button then card.children.buy_button:remove() end
        card.children.buy_button = nil
        remove_nils(card.children)
        if card.ability.set == 'Default' or card.ability.set == 'Enhanced' then
          inc_career_stat('c_playing_cards_bought', 1)
          G.playing_card = (G.playing_card and G.playing_card + 1) or 1
          G.deck:emplace(card)
          card.playing_card = G.playing_card
          playing_card_joker_effects({card})
          table.insert(G.playing_cards, card)
        elseif e.config.id ~= 'buy_and_use' then
          if card.ability.consumeable then
            G.consumeables:emplace(card)
          else
            G.jokers:emplace(card)
          end
          G.E_MANAGER:add_event(Event({func = function() card:calculate_joker({buying_card = true, card = card}) return true end}))
        end
        --Tallies for unlocks
        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
        if card.ability.consumeable then
          if card.config.center.set == 'Planet' then
            inc_career_stat('c_planets_bought', 1)
          elseif card.config.center.set == 'Tarot' then
            inc_career_stat('c_tarots_bought', 1)
          end
        elseif card.ability.set == 'Joker' then
          G.GAME.current_round.jokers_purchased = G.GAME.current_round.jokers_purchased + 1
        end

        for i = 1, #G.jokers.cards do
          G.jokers.cards[i]:calculate_joker({buying_card = true, card = card})
        end

        if G.GAME.modifiers.inflation then 
          G.GAME.inflation = G.GAME.inflation + 1
          G.E_MANAGER:add_event(Event({func = function()
            for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
            end
            return true end }))
        end

        play_sound('card1')
        inc_career_stat('c_shop_dollars_spent', card.cost)
        if card.cost ~= 0 then
          ease_dollars(-card.cost)
        end
        G.CONTROLLER:save_cardarea_focus('jokers')
        G.CONTROLLER:recall_cardarea_focus('jokers')

        if e.config.id == 'buy_and_use' then 
          G.SINGLEPLAYER_FUNCS.use_card(e, true)
        end
        return true
      end
    }))
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