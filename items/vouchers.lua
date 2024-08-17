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
-- TODO: doesn't work properly, fix
function get_current_pool(_type, _rarity, _legendary, _append)
  local _pool, _pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append)
  if _type == "Voucher" then
    if G.FUNCS.is_versus_game() then
      for i = 1, #_pool, -1 do
        if _pool[i] == 'v_hieroglyph' or _pool[i] == 'v_petroglyph' then
          table.remove(_pool, i)
        end
      end
    else
      for i = 1, #_pool, -1 do
        if _pool[i] == createCollectionId('v', 'eraser') or _pool[i] == createCollectionId('v', 'bucket') then
          table.remove(_pool, i)
        end
      end
    end
  end
  return _pool, _pool_key
end