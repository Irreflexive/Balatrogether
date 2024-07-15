G.FUNCS.skip_booster = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "SKIP_BOOSTER" })
  else
    G.SINGLEPLAYER_FUNCS.skip_booster(...)
  end
end

G.FUNCS.reroll_shop = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "REROLL" })
  else
    G.SINGLEPLAYER_FUNCS.reroll(...)
  end
end

G.FUNCS.toggle_shop = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "NEXT_ROUND" })
  else
    G.SINGLEPLAYER_FUNCS.next_round(...)
  end
end

G.FUNCS.cash_out = function(...)
  if G.FUNCS.is_coop_game() then
    G.FUNCS.tcp_send({ cmd = "GO_TO_SHOP" })
  else
    G.SINGLEPLAYER_FUNCS.go_to_shop(...)
  end
end

local add_round_eval_row_ref = add_round_eval_row
function add_round_eval_row(config)
  local config = config or {}
  local width = G.round_eval.T.w - 0.51
  local num_dollars = config.dollars or 1
  local scale = 0.9

  if config.name == "bottom" and G.FUNCS.is_coop_game() then
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

        G.GAME.current_round.dollars = config.dollars
        
        play_sound('coin6', config.pitch or 1)
        G.VIBRATION = G.VIBRATION + 1
        return true
      end
    }))
  else
    add_round_eval_row_ref(config)
  end
end

G.MULTIPLAYER.actions.SKIP_BOOSTER = function(data)
  G.SINGLEPLAYER_FUNCS.skip_booster()
end

G.MULTIPLAYER.actions.REROLL = function(data)
  G.SINGLEPLAYER_FUNCS.reroll()
end

G.MULTIPLAYER.actions.NEXT_ROUND = function(data)
  G.SINGLEPLAYER_FUNCS.next_round()
end

G.MULTIPLAYER.actions.GO_TO_SHOP = function(data)
  local e = G.next_round_button:get_UIE_by_ID('cash_out_button')
  G.SINGLEPLAYER_FUNCS.go_to_shop(e)
end