SMODS.Seal{
  key = "green",
  pos = { x = 2, y = 0 },
  badge_colour = G.C.GREEN,
  config = { money = 1 },
  atlas = "sprites",
  weight = 5,
  loc_vars = function(self, info_queue)
      return { vars = {self.config.money} }
  end,
  calculate = function(self, card, context)
    if not G.FUNCS.is_versus_game() then return end
    if not context.repetition_only and context.cardarea == G.play then
      G.FUNCS.tcp_send({ cmd = "GREEN_SEAL" })
      return { dollars = self.config.money }
    end
  end,
  get_weight = function(self)
    return G.FUNCS.is_versus_game() and self.weight or 0
  end,
}