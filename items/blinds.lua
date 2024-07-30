SMODS.Blind{
  key = "the_duel",
  pos = {x = 0, y = 0},
  discovered = false,
  boss = { min = 2, max = 6 },
  boss_colour = {21/255, 203/255, 92/255, 1},
  atlas = "Balatrogether_blinds",
  in_pool = function(self)
    local ante = G.GAME.round_resets.ante
    return G.FUNCS.is_versus_game() and 
      ante % 2 == 0 and 
      ante < G.GAME.win_ante and 
      G.FUNCS.get_duel_threshold() >= 2
  end,
  vars = {8},
  loc_vars = function(self)
    return {vars = { G.FUNCS.get_duel_threshold() }}
  end,
  defeat = function(self)
    Balatrogether.server.leaderboard_blind = true
    G.FUNCS.tcp_send({ cmd = "DEFEATED_BOSS", score = G.GAME.chips })
  end
}

SMODS.Blind{
  key = "final_showdown",
  pos = {x = 0, y = 1},
  discovered = false,
  boss_colour = {21/255, 203/255, 92/255, 1},
  boss = { min = 8, max = 8 },
  showdown = true,
  dollars = 8,
  atlas = "Balatrogether_blinds",
  in_pool = function(self)
    return G.FUNCS.is_versus_game() and G.GAME.round_resets.ante == G.GAME.win_ante
  end,
  defeat = function(self)
    Balatrogether.server.leaderboard_blind = true
    G.FUNCS.tcp_send({ cmd = "DEFEATED_BOSS", score = G.GAME.chips })
  end
}