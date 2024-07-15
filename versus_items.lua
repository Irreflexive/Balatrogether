G.FUNCS.load_versus_items = function(mod_path)
  local items = {
    load_annie_and_hallie(mod_path),
    load_the_cup(mod_path)
  }
  for _,item in ipairs(items) do
    if item.joker then
      SMODS.Jokers[item.joker.slug].calculate = item.calculate
    end
  end
end