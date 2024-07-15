function load_annie_and_hallie(mod_path)
  local loc_def = {
    ["name"] = "Annie and Hallie",
    ["text"] = {
        [1] = "Sell this card to",
        [2] = "{C:attention}swap{} Jokers with",
        [3] = "a random {C:attention}opponent{}"
    }
  }

  local annie_and_hallie = SMODS.Joker:new(
    "Annie and Hallie", 
    "annie_and_hallie", 
    {}, 
    {x = 0, y = 0}, 
    loc_def, 
    4, 
    20, 
    true, 
    true, 
    false, 
    true, 
    "", 
    "Balatrogether", 
    {x = 1, y = 0}
  )

  local function calculate(self, context)
    if context.selling_self and G.FUNCS.is_versus_game() then
      local jokers = {}
      for k, v in pairs(G.jokers.cards) do
        if v.ID ~= self.ID then
          table.insert(jokers, {
            T = {x = v.T.x, y = v.T.y},
            config = {center = v.config.center, card = v.config.card},
            ability = v.ability,
            edition = v.edition,
          })
        end
      end
      G.FUNCS.tcp_send({ cmd = "ANNIE_AND_HALLIE", jokers = jokers })
    end
  end

  SMODS.Sprite:new("j_annie_and_hallie", mod_path, "sprites.png", 71, 95, "asset_atli"):register();
  annie_and_hallie:register()
  
  return {
    joker = annie_and_hallie,
    calculate = calculate
  }
end