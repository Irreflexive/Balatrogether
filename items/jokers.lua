local loc_def = {
  name = "Annie and Hallie",
  text = {
      "Sell this card to",
      "{C:attention}swap{} Jokers with",
      "a random {C:attention}opponent{}"
  }
}

SMODS.Joker{
  name = "Annie and Hallie", 
  key = "annie_and_hallie", 
  rarity = 4, 
  unlocked = true,
  discovered = false,
  pos = {x = 0, y = 0}, 
  cost = 20, 
  config = {},
  loc_txt = loc_def, 
  atlas = "Balatrogether_cards", 
  soul_pos = {x = 1, y = 0},
  calculate = function(self, card, context)
    if context.selling_self and G.FUNCS.is_versus_game() then
      local jokers = G.FUNCS.get_unsecure_jokers()
      local serialized = {}
      for k, v in pairs(jokers) do
        if v.ID ~= card.ID then
          table.insert(serialized, G.FUNCS.serialize_joker(v))
        end
      end
      G.FUNCS.tcp_send({ cmd = "SWAP_JOKERS", jokers = serialized, responding = false })
    end
  end,
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end
}