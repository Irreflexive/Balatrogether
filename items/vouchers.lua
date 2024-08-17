SMODS.Voucher{
  key = "eraser",
  pos = {x = 3, y = 0},
  discovered = false,
  atlas = "sprites",
  redeem = function(self)
    G.FUNCS.tcp_send({ cmd = "ERASER" })
  end,
}

SMODS.Voucher{
  key = "bucket",
  pos = {x = 3, y = 1},
  discovered = false,
  atlas = "sprites",
  requires = {createCollectionId('v', 'eraser')},
  redeem = function(self)
    G.FUNCS.tcp_send({ cmd = "PAINT_BUCKET" })
  end,
}

local get_current_pool_ref = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
  if _type == "Voucher" then
    local hieroglyph_banned = G.GAME.banned_keys['v_hieroglyph']
    local petroglyph_banned = G.GAME.banned_keys['v_petroglyph']
    local eraser_banned = G.GAME.banned_keys[createCollectionId('v', 'eraser')]
    local bucket_banned = G.GAME.banned_keys[createCollectionId('v', 'bucket')]
    if G.FUNCS.is_versus_game() then
      G.GAME.banned_keys['v_hieroglyph'] = true
      G.GAME.banned_keys['v_petroglyph'] = true
    else
      G.GAME.banned_keys['v_eraser'] = true
      G.GAME.banned_keys['v_bucket'] = true
    end
    local _pool, _pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append)
    G.GAME.banned_keys['v_hieroglyph'] = hieroglyph_banned
    G.GAME.banned_keys['v_petroglyph'] = petroglyph_banned
    G.GAME.banned_keys['v_eraser'] = eraser_banned
    G.GAME.banned_keys['v_bucket'] = bucket_banned
    return _pool, _pool_key
  else
    return get_current_pool_ref(_type, _rarity, _legendary, _append)
  end
end