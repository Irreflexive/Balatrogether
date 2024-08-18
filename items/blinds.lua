SMODS.Blind{
  key = "the_duel",
  pos = {x = 0, y = 0},
  discovered = false,
  boss = { min = 1, max = 39 },
  boss_colour = {21/255, 203/255, 92/255, 1},
  atlas = "blinds",
  in_pool = function(self)
    local ante = G.GAME.round_resets.ante
    return G.FUNCS.is_versus_game() and 
      ante % G.FUNCS.get_duel_period() == 0 and 
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
  boss = { showdown = true },
  dollars = 8,
  atlas = "blinds",
  in_pool = function(self)
    return G.FUNCS.is_versus_game() and G.GAME.round_resets.ante == G.GAME.win_ante
  end,
  defeat = function(self)
    Balatrogether.server.leaderboard_blind = true
    G.FUNCS.tcp_send({ cmd = "DEFEATED_BOSS", score = G.GAME.chips })
  end
}

G.FUNCS.get_duel_threshold = function()
  return math.ceil((Balatrogether.server.game_state.remaining or 0) / 2)
end

G.FUNCS.get_duel_period = function()
  local n = math.max(math.log(Balatrogether.server.game_state.remaining) / math.log(2), 1)
  return math.ceil(G.GAME.win_ante / n)
end

local get_new_boss_ref = get_new_boss
function get_new_boss()
  if G.FUNCS.is_versus_game() then
    local the_duel = createCollectionId('bl', 'the_duel')
    local the_showdown = createCollectionId('bl', 'final_showdown')
    local old_perscribed = G.GAME.perscribed_bosses
    G.GAME.perscribed_bosses = old_perscribed or {}
    local ante = G.GAME.round_resets.ante
    if G.FUNCS.get_duel_threshold() >= 2 and ante % G.FUNCS.get_duel_period() == 0 then
      G.GAME.perscribed_bosses[ante] = the_duel
    end
    G.GAME.perscribed_bosses[G.GAME.win_ante] = the_showdown
    local boss = get_new_boss_ref()
    G.GAME.perscribed_bosses = old_perscribed
    return boss
  end
  return get_new_boss_ref()
end