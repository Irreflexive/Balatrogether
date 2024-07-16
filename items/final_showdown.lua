local loc_def = {
  name = "Final Showdown",
  text = {
      "Player with the highest",
      "round score wins",
  }
}

SMODS.Blind{
  name = "Final Showdown",
  key = "final_showdown",
  pos = {x = 0, y = 1},
  discovered = false,
  loc_txt = loc_def,
  boss_colour = {21/255, 203/255, 92/255, 1},
  showdown = true,
  atlas = "Balatrogether_blinds",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
}