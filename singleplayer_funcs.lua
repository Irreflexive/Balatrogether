G.SINGLEPLAYER_FUNCS = {
  play_hand = G.FUNCS.play_cards_from_highlighted,
  discard_hand = G.FUNCS.discard_cards_from_highlighted,
  sort_by_value = G.FUNCS.sort_hand_value,
  sort_by_suit = G.FUNCS.sort_hand_suit,
  select_blind = G.FUNCS.select_blind,
  skip_blind = G.FUNCS.skip_blind,
  sell_card = G.FUNCS.sell_card,
  use_card = G.FUNCS.use_card,
  reroll = G.FUNCS.reroll_shop,
  next_round = G.FUNCS.toggle_shop,
  go_to_shop = G.FUNCS.cash_out,
  skip_booster = G.FUNCS.skip_booster,
}

G.SINGLEPLAYER_FUNCS.buy_card = function(e)
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
          G.SINGLEPLAYER_FUNCS.use_card(e, true)
        end
        return true
      end
    }))
  end
end