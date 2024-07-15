function load_annie_and_hallie()
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
    if context.selling_self and G.MULTIPLAYER.enabled then
      G.FUNCS.tcp_send({ cmd = "JOKER", joker = "annie_and_hallie" })
    end
  end

  return {
    joker = annie_and_hallie,
    calculate = calculate
  }
end