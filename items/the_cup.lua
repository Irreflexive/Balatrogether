function load_the_cup(mod_path)
  local loc_def = {
    ["name"] = "The Cup",
    ["text"] = {
        [1] = "Earn {C:money}$8{} for each",
        [2] = "opponent that has",
        [3] = "been {C:attention}eliminated{}"
    }
  }

  local the_cup = SMODS.Tarot:new(
    "The Cup", 
    "the_cup", 
    {}, 
    {x = 0, y = 1}, 
    loc_def, 
    3, 
    "",
    true, 
    true, 
    "Balatrogether" 
  )

  SMODS.Sprite:new("c_the_cup", mod_path, "sprites.png", 71, 95, "asset_atli"):register();
  the_cup:register()

  return {
    tarot = the_cup
  }
end