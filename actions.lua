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
local next_round = G.FUNCS.toggle_shop
local go_to_shop = G.FUNCS.cash_out

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

  NEXT_ROUND = function(data)
    next_round()
  end,

  GO_TO_SHOP = function(data)
    local e = G.next_round_button:get_UIE_by_ID('cash_out_button')
    go_to_shop(e)
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

G.FUNCS.toggle_shop = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "NEXT_ROUND" })
  else
    next_round(...)
  end
end

G.FUNCS.cash_out = function(...)
  if G.MULTIPLAYER.enabled then
    G.FUNCS.tcp_send({ cmd = "GO_TO_SHOP" })
  else
    go_to_shop(...)
  end
end

function add_round_eval_row(config)
  local config = config or {}
  local width = G.round_eval.T.w - 0.51
  local num_dollars = config.dollars or 1
  local scale = 0.9

  if config.name ~= 'bottom' then
      if config.name ~= 'blind1' then
          if not G.round_eval.divider_added then 
              G.E_MANAGER:add_event(Event({
                  trigger = 'after',delay = 0.25,
                  func = function() 
                      local spacer = {n=G.UIT.R, config={align = "cm", minw = width}, nodes={
                          {n=G.UIT.O, config={object = DynaText({string = {'......................................'}, colours = {G.C.WHITE},shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0})}}
                      }}
                      G.round_eval:add_child(spacer,G.round_eval:get_UIE_by_ID(config.bonus and 'bonus_round_eval' or 'base_round_eval'))
                      return true
                  end
              }))
              delay(0.6)
              G.round_eval.divider_added = true
          end
      else
          delay(0.2)
      end

      delay(0.2)

      G.E_MANAGER:add_event(Event({
          trigger = 'before',delay = 0.5,
          func = function()
              --Add the far left text and context first:
              local left_text = {}
              if config.name == 'blind1' then
                  local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
                  local blind_sprite = AnimatedSprite(0, 0, 1.2,1.2, G.ANIMATION_ATLAS['blind_chips'], copy_table(G.GAME.blind.pos))
                  blind_sprite:define_draw_steps({
                      {shader = 'dissolve', shadow_height = 0.05},
                      {shader = 'dissolve'}
                  })
                  table.insert(left_text, {n=G.UIT.O, config={w=1.2,h=1.2 , object = blind_sprite, hover = true, can_collide = false}})

                  table.insert(left_text,                  
                  config.saved and 
                  {n=G.UIT.C, config={padding = 0.05, align = 'cm'}, nodes={
                      {n=G.UIT.R, config={align = 'cm'}, nodes={
                          {n=G.UIT.O, config={object = DynaText({string = {' '..localize('ph_mr_bones')..' '}, colours = {G.C.FILTER}, shadow = true, pop_in = 0, scale = 0.5*scale, silent = true})}}
                      }}
                  }}
                  or {n=G.UIT.C, config={padding = 0.05, align = 'cm'}, nodes={
                      {n=G.UIT.R, config={align = 'cm'}, nodes={
                          {n=G.UIT.O, config={object = DynaText({string = {' '..localize('ph_score_at_least')..' '}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}}
                      }},
                      {n=G.UIT.R, config={align = 'cm', minh = 0.8}, nodes={
                          {n=G.UIT.O, config={w=0.5,h=0.5 , object = stake_sprite, hover = true, can_collide = false}},
                          {n=G.UIT.T, config={text = G.GAME.blind.chip_text, scale = scale_number(G.GAME.blind.chips, scale, 100000), colour = G.C.RED, shadow = true}}
                      }}
                  }}) 
              elseif string.find(config.name, 'tag') then
                  local blind_sprite = Sprite(0, 0, 0.7,0.7, G.ASSET_ATLAS['tags'], copy_table(config.pos))
                  blind_sprite:define_draw_steps({
                      {shader = 'dissolve', shadow_height = 0.05},
                      {shader = 'dissolve'}
                  })
                  blind_sprite:juice_up()
                  table.insert(left_text, {n=G.UIT.O, config={w=0.7,h=0.7 , object = blind_sprite, hover = true, can_collide = false}})
                  table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = {config.condition}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})                   
              elseif config.name == 'hands' then
                  table.insert(left_text, {n=G.UIT.T, config={text = config.disp or config.dollars, scale = 0.8*scale, colour = G.C.BLUE, shadow = true, juice = true}})
                  table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = {" "..localize{type = 'variable', key = 'remaining_hand_money', vars = {G.GAME.modifiers.money_per_hand or 1}}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
              elseif config.name == 'discards' then
                  table.insert(left_text, {n=G.UIT.T, config={text = config.disp or config.dollars, scale = 0.8*scale, colour = G.C.RED, shadow = true, juice = true}})
                  table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = {" "..localize{type = 'variable', key = 'remaining_discard_money', vars = {G.GAME.modifiers.money_per_discard or 0}}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
              elseif string.find(config.name, 'joker') then
                  table.insert(left_text, {n=G.UIT.O, config={object = DynaText({string = localize{type = 'name_text', set = config.card.config.center.set, key = config.card.config.center.key}, colours = {G.C.FILTER}, shadow = true, pop_in = 0, scale = 0.6*scale, silent = true})}})
              elseif config.name == 'interest' then
                  table.insert(left_text, {n=G.UIT.T, config={text = num_dollars, scale = 0.8*scale, colour = G.C.MONEY, shadow = true, juice = true}})
                  table.insert(left_text,{n=G.UIT.O, config={object = DynaText({string = {" "..localize{type = 'variable', key = 'interest', vars = {G.GAME.interest_amount, 5, G.GAME.interest_amount*G.GAME.interest_cap/5}}}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
              end
              local full_row = {n=G.UIT.R, config={align = "cm", minw = 5}, nodes={
                  {n=G.UIT.C, config={padding = 0.05, minw = width*0.55, minh = 0.61, align = "cl"}, nodes=left_text},
                  {n=G.UIT.C, config={padding = 0.05,minw = width*0.45, align = "cr"}, nodes={{n=G.UIT.C, config={align = "cm", id = 'dollar_'..config.name},nodes={}}}}
              }}
      
              if config.name == 'blind1' then
                  G.GAME.blind:juice_up()
              end
              G.round_eval:add_child(full_row,G.round_eval:get_UIE_by_ID(config.bonus and 'bonus_round_eval' or 'base_round_eval'))
              play_sound('cancel', config.pitch or 1)
              play_sound('highlight1',( 1.5*config.pitch) or 1, 0.2)
              if config.card then config.card:juice_up(0.7, 0.46) end
              return true
          end
      }))
      local dollar_row = 0
      if num_dollars > 60 then 
          local dollar_string = localize('$')..num_dollars
          G.E_MANAGER:add_event(Event({
              trigger = 'before',delay = 0.38,
              func = function()
                  G.round_eval:add_child(
                          {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..config.name}, nodes={
                              {n=G.UIT.O, config={object = DynaText({string = {localize('$')..num_dollars}, colours = {G.C.MONEY}, shadow = true, pop_in = 0, scale = 0.65, float = true})}}
                          }},
                          G.round_eval:get_UIE_by_ID('dollar_'..config.name))

                  play_sound('coin3', 0.9+0.2*math.random(), 0.7)
                  play_sound('coin6', 1.3, 0.8)
                  return true
              end
          }))
      else
          for i = 1, num_dollars or 1 do
              G.E_MANAGER:add_event(Event({
                  trigger = 'before',delay = 0.18 - ((num_dollars > 20 and 0.13) or (num_dollars > 9 and 0.1) or 0),
                  func = function()
                      if i%30 == 1 then 
                          G.round_eval:add_child(
                              {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..config.name}, nodes={}},
                              G.round_eval:get_UIE_by_ID('dollar_'..config.name))
                              dollar_row = dollar_row+1
                      end

                      local r = {n=G.UIT.T, config={text = localize('$'), colour = G.C.MONEY, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true}}
                      play_sound('coin3', 0.9+0.2*math.random(), 0.7 - (num_dollars > 20 and 0.2 or 0))
                      
                      if config.name == 'blind1' then 
                          G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
                      end

                      G.round_eval:add_child(r,G.round_eval:get_UIE_by_ID('dollar_row_'..(dollar_row)..'_'..config.name))
                      G.VIBRATION = G.VIBRATION + 0.4
                      return true
                  end
              }))
          end
      end
  else
      delay(0.4)
      G.E_MANAGER:add_event(Event({
          trigger = 'before',delay = 0.5,
          func = function()
              G.next_round_button = UIBox{
                  definition = {n=G.UIT.ROOT, config={align = 'cm', colour = G.C.CLEAR}, nodes={
                      {n=G.UIT.R, config={id = 'cash_out_button', align = "cm", padding = 0.1, minw = 7, r = 0.15, colour = G.C.ORANGE, shadow = true, hover = true, one_press = true, button = 'cash_out', focus_args = {snap_to = true}}, nodes={
                          {n=G.UIT.T, config={text = localize('b_cash_out')..": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
                          {n=G.UIT.T, config={text = localize('$')..config.dollars, scale = 1.2*scale, colour = G.C.WHITE, shadow = true, juice = true}}
                  }},}},
                  config = {
                    align = 'tmi',
                    offset ={x=0,y=0.4},
                    major = G.round_eval}
              }

              --local left_text = {n=G.UIT.R, config={id = 'cash_out_button', align = "cm", padding = 0.1, minw = 2, r = 0.15, colour = G.C.ORANGE, shadow = true, hover = true, one_press = true, button = 'cash_out', focus_args = {snap_to = true}}, nodes={
              --    {n=G.UIT.T, config={text = localize('b_cash_out')..": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
              --    {n=G.UIT.T, config={text = localize('$')..config.dollars, scale = 1.3*scale, colour = G.C.WHITE, shadow = true, juice = true}}
              --}}
              --G.round_eval:add_child(left_text,G.round_eval:get_UIE_by_ID('eval_bottom'))

              G.GAME.current_round.dollars = config.dollars
              
              play_sound('coin6', config.pitch or 1)
              G.VIBRATION = G.VIBRATION + 1
              return true
          end
      }))
  end
end

----------------------------------------------
------------MOD CODE END----------------------