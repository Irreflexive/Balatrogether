G.FUNCS.load_versus_jokers = function(mod_path)
  local jokers = {
    load_annie_and_hallie()
  }
  for _,joker in ipairs(jokers) do
    joker.joker:register()
    SMODS.Jokers[joker.joker.slug].calculate = joker.calculate
  end
  SMODS.Sprite:new("Balatrogether", mod_path, "sprites.png", 71, 95, "asset_atli"):register();
end