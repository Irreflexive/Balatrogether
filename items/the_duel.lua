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
    return G.FUNCS.is_versus_game() and G.GAME.round_resets.ante % 2 == 0
  end,
}

for k, v in pairs(G.P_BLINDS) do
  local blind_key = v.key:match("bl_(.*)")
  if not blind_key:match("the_duel") and v.boss and not v.boss.showdown then
    local in_pool = v.in_pool
    SMODS.Blind:take_ownership(blind_key, {
      in_pool = function(self)
        local ante = G.GAME.round_resets.ante
        if G.FUNCS.is_versus_game() and ante % 2 == 0 then
          return false
        end
        if in_pool then
          return in_pool(self)
        end
        if self.boss and self.boss.min and ante < self.boss.min then
          return false
        end
        if self.boss and self.boss.max and ante > self.boss.max then
          return false
        end
        return true
      end
    })
  end
end