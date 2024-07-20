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

  if config.name == "bottom" and G.MULTIPLAYER.enabled then
    delay(0.4)
    G.E_MANAGER:add_event(Event({
      trigger = 'before',delay = 0.5,
      func = function()
        local is_wait_boss = G.FUNCS.is_versus_game() and G.MULTIPLAYER.leaderboard_blind
        local should_wait = is_wait_boss and not G.MULTIPLAYER.leaderboard
        local color = should_wait and G.C.UI.BACKGROUND_INACTIVE or G.C.ORANGE
        local button_func = is_wait_boss and (should_wait and 'nil' or 'view_leaderboard') or 'cash_out'
        G.NEXT_ROUND_BUTTON = UIBox{
            definition = {n=G.UIT.ROOT, config={align = 'cm', colour = G.C.CLEAR}, nodes={
                {n=G.UIT.R, config={id = 'cash_out_button', align = "cm", padding = 0.1, minw = 7, r = 0.15, colour = color, shadow = true, hover = true, one_press = true, button = button_func, focus_args = {snap_to = true}}, nodes={
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

G.FUNCS.tcp_listen("SKIP_BOOSTER", function(data)
  G.SINGLEPLAYER_FUNCS.skip_booster()
end)

G.FUNCS.tcp_listen("REROLL", function(data)
  G.SINGLEPLAYER_FUNCS.reroll()
end)

G.FUNCS.tcp_listen("NEXT_ROUND", function(data)
  G.SINGLEPLAYER_FUNCS.next_round()
end)

G.FUNCS.tcp_listen("GO_TO_SHOP", function(data)
  local e = G.NEXT_ROUND_BUTTON:get_UIE_by_ID('cash_out_button')
  G.SINGLEPLAYER_FUNCS.go_to_shop(e)
end)

G.FUNCS.tcp_listen("LEADERBOARD", function(data)
  G.MULTIPLAYER.leaderboard = data.leaderboard
  local e = G.NEXT_ROUND_BUTTON and G.NEXT_ROUND_BUTTON:get_UIE_by_ID('cash_out_button')
  if not e then return end
  e.config.button = "view_leaderboard"
  e.config.colour = G.C.ORANGE
end)