local loc_def = {
  name = "Network Pack",
  text = {
      "Choose {C:attention}#1#{} of up to",
      "{C:attention}#2# {C:attention}Playing{} cards or",
      "{C:attention}Jokers{} from {C:attention}opponents{}",
  }
}

SMODS.Booster{
  name = "Network Pack",
  key = "network",
  pos = {x = 1, y = 1},
  discovered = false,
  loc_txt = loc_def,
  weight = 1,
  cost = 6,
  config = {extra = 3, choose = 1},
  atlas = "Balatrogether_cards",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
  create_card = function(self, card)
    return create_card("Joker", G.pack_cards, nil, nil, true, true, nil, 'net')
  end
}