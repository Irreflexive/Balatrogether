SMODS.Voucher{
  key = "eraser",
  pos = {x = 3, y = 0},
  discovered = false,
  atlas = "Balatrogether_cards",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
  redeem = function(self)
    G.FUNCS.tcp_send({ cmd = "ERASER" })
  end,
}

SMODS.Voucher{
  key = "bucket",
  pos = {x = 3, y = 1},
  discovered = false,
  atlas = "Balatrogether_cards",
  requires = {createCollectionId('v', 'eraser')},
  redeem = function(self)
    G.FUNCS.tcp_send({ cmd = "PAINT_BUCKET" })
  end,
}

SMODS.Voucher:take_ownership("hieroglyph", {
  in_pool = function(self)
    return not G.FUNCS.is_versus_game()
  end,
})