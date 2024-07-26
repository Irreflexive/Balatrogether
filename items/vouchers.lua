local loc_def1 = {
  name = "Eraser",
  text = {
      "{C:attention}-1{} hand size",
      "to a random {C:attention}opponent{}",
  }
}

SMODS.Voucher{
  name = "Eraser",
  key = "eraser",
  pos = {x = 3, y = 0},
  discovered = false,
  loc_txt = loc_def1,
  atlas = "Balatrogether_cards",
  in_pool = function(self)
    return G.FUNCS.is_versus_game()
  end,
  redeem = function(self)
    G.FUNCS.tcp_send({ cmd = "ERASER" })
  end,
}

local loc_def2 = {
  name = "Paint Bucket",
  text = {
      "{C:attention}-1{} hand size",
      "to {C:attention}all opponents{}",
  }
}

SMODS.Voucher{
  name = "Paint Bucket",
  key = "bucket",
  pos = {x = 3, y = 1},
  discovered = false,
  loc_txt = loc_def2,
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