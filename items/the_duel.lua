local loc_def = {
  name = "The Duel",
  text = {
      "Player with the lowest",
      "round score is eliminated",
  }
}

SMODS.Blind{
  name = "The Duel",
  key = "the_duel",
  pos = {x = 0, y = 0},
  discovered = false,
  loc_txt = loc_def,
  boss_colour = {21/255, 203/255, 92/255, 1},
  boss = { min = 2, max = 6 },
  atlas = "Balatrogether_blinds",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
}