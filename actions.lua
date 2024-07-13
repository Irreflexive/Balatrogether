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
local reroll = G.FUNCS.reroll_shop

local buy_card = function(e)
  local c1 = e.config.ref_table
  if c1 and c1:is(Card) then
    if e.config.id ~= 'buy_and_use' then
      if not G.FUNCS.check_for_buy_space(c1) then
        e.disable_button = nil
        return false
      end
    end
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = function()
        c1.area:remove_card(c1)
        c1:add_to_deck()
        if c1.children.price then c1.children.price:remove() end
        c1.children.price = nil
        if c1.children.buy_button then c1.children.buy_button:remove() end
        c1.children.buy_button = nil
        remove_nils(c1.children)
        if c1.ability.set == 'Default' or c1.ability.set == 'Enhanced' then
          inc_career_stat('c_playing_cards_bought', 1)
          G.playing_card = (G.playing_card and G.playing_card + 1) or 1
          G.deck:emplace(c1)
          c1.playing_card = G.playing_card
          playing_card_joker_effects({c1})
          table.insert(G.playing_cards, c1)
        elseif e.config.id ~= 'buy_and_use' then
          if c1.ability.consumeable then
            G.consumeables:emplace(c1)
          else
            G.jokers:emplace(c1)
          end
          G.E_MANAGER:add_event(Event({func = function() c1:calculate_joker({buying_card = true, card = c1}) return true end}))
        end
        --Tallies for unlocks
        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
        if c1.ability.consumeable then
          if c1.config.center.set == 'Planet' then
            inc_career_stat('c_planets_bought', 1)
          elseif c1.config.center.set == 'Tarot' then
            inc_career_stat('c_tarots_bought', 1)
          end
        elseif c1.ability.set == 'Joker' then
          G.GAME.current_round.jokers_purchased = G.GAME.current_round.jokers_purchased + 1
        end

        for i = 1, #G.jokers.cards do
          G.jokers.cards[i]:calculate_joker({buying_card = true, card = c1})
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
        inc_career_stat('c_shop_dollars_spent', c1.cost)
        if c1.cost ~= 0 then
          ease_dollars(-c1.cost)
        end
        G.CONTROLLER:save_cardarea_focus('jokers')
        G.CONTROLLER:recall_cardarea_focus('jokers')

        if e.config.id == 'buy_and_use' then 
          use_card(e, true)
        end
        return true
      end
    }))
  end
end

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
    G.GAME.selected_back = Back(get_deck_from_name(data.deck))
    G.FUNCS.start_run(nil, { seed = data.seed, stake = data.stake, challenge = {
      name = 'Multiplayer Test',
      id = 'c_multiplayer_test',
      rules = {
          custom = {
          },
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
      vouchers = {
      },
      deck = {
          type = G.GAME.selected_back.name,
      },
      restrictions = {
          banned_cards = {
          },
          banned_tags = {
          },
          banned_other = {
          }
      }
    }})
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
    if data.type == "shop_jokers" then
      local e = findDescendantOfElementByConfig(G.shop_jokers.cards[data.index], "func", "can_buy")
      buy_card(e)
    else
      local card = G[data.type].cards[data.index]
      use_card({config = {ref_table = card}})
    end
  end,

  BUY_AND_USE = function(data)
    local e = findDescendantOfElementByConfig(G.shop_jokers.cards[data.index], "id", "buy_and_use")
    buy_card(e)
  end,

  REROLL = function(data)
    reroll()
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
  local card = e.config.ref_table
  if G.MULTIPLAYER.enabled and card.area then
    local index = 1
    for k,v in ipairs(card.area.cards) do
      if v.ID == card.ID then index = k end
    end
    G.FUNCS.tcp_send({ cmd = "SELL", index = index, type = card.area == G.jokers and 'jokers' or 'consumeables' })
  else
    sell_card(e, ...)
  end
end

G.FUNCS.use_card = function(e, ...)
  local card = e.config.ref_table
  if G.MULTIPLAYER.enabled then
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
    use_card(e, ...)
  end
end

G.FUNCS.buy_from_shop = function(e)
  local card = e.config.ref_table
  if G.MULTIPLAYER.enabled then
    local index = 1
    for k,v in ipairs(G.shop_jokers.cards) do
      if v.ID == card.ID then index = k end
    end
    G.FUNCS.tcp_send({ cmd = e.config.id == 'buy_and_use' and "BUY_AND_USE" or "BUY", index = index, type = "shop_jokers" })
  else
    buy_card(e)
  end
end

G.FUNCS.reroll_shop = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "REROLL" })
  else
    reroll(...)
  end
end

----------------------------------------------
------------MOD CODE END----------------------