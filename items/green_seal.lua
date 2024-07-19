local loc_def = {
  label = "Green Seal",
  description = {
    name = "Green Seal",
    text = {
        "Opponents lose {C:money}$#1#{}",
        "when this card is played",
        "and scores, and earn {C:money}$#1#{}",
        "{C:inactive}(Versus only){}",
    }
  }
}

SMODS.Seal{
  name = "Green Seal",
  key = "green",
  pos = { x = 2, y = 0 },
  loc_txt = loc_def,
  badge_colour = HEX('15CB5C'),
  config = { money = 1 },
  atlas = "Balatrogether_cards",
  loc_vars = function(self, info_queue)
      return { vars = {self.config.money} }
  end,
  calculate = function(self, card, context)
    if not G.FUNCS.is_versus_game() then return end
    if not context.repetition_only and context.cardarea == G.play then
      G.FUNCS.tcp_send({ cmd = "GREEN_SEAL" })
      ease_dollars(self.config.money)
      return {}
    end
  end
}