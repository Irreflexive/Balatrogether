SMODS.Voucher:take_ownership("hieroglyph", {
  in_pool = function(self)
    return not G.FUNCS.is_versus_game()
  end,
})

SMODS.Voucher:take_ownership("petroglyph", {
  in_pool = function(self)
    return not G.FUNCS.is_versus_game()
  end,
})