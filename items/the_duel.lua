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
  boss = { min = 2, max = 6 },
  loc_txt = loc_def,
  boss_colour = {21/255, 203/255, 92/255, 1},
  atlas = "Balatrogether_blinds",
  in_pool = function(self)
    local ante = G.GAME.round_resets.ante
    return G.FUNCS.is_versus_game() and ante % 2 == 0 and ante < G.GAME.win_ante
  end,
}