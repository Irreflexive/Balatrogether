--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play co-op Balatro with your friends!
--- BADGE_COLOUR: 00FF64

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Balatrogether()
	local mod = SMODS.findModByID("Balatrogether")
  sendDebugMessage("Launching Balatrogether!")
	assert(load(love.filesystem.read(mod.path .. "ui_setup.lua")))()
end

G.FUNCS.start_server = function()
  sendDebugMessage("Starting server!")
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local code = ""
  for i = 1, 6 do
    local index = math.random(1, #chars)
    code = code .. chars:sub(index, index)
  end
  sendDebugMessage("Code: " .. code)
end

----------------------------------------------
------------MOD CODE END----------------------