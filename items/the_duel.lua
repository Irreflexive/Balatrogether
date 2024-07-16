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
  boss = {min = 2, max = 6},
  pos = {x = 0, y = 0},
  discovered = true,
  loc_txt = loc_def,
  boss_colour = {21/255, 203/255, 92/255, 1},
  atlas = "Balatrogether_blinds"
}