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
	assert(load(love.filesystem.read(mod.path .. "UI_definitions.lua")))()
end

G.MULTIPLAYER = {
  started = false,
  code = "",
  players = {},
  id = 0,
  in_game = false,
}

G.FUNCS.start_server = function()
  sendDebugMessage("Starting server!")
  local chars = "0123456789ABCDEF"
  local code = ""
  for i = 1, 6 do
    local index = math.random(1, #chars)
    code = code .. chars:sub(index, index)
  end
  sendDebugMessage("Code: " .. code)
  G.MULTIPLAYER.started = true
  G.MULTIPLAYER.code = code
  G.MULTIPLAYER.players = {G.STEAM.user.getSteamID()}
  G.MULTIPLAYER.id = 1
  -- Load UI
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(),
  }
  G.OVERLAY_MENU.config.no_esc = true
end

G.FUNCS.change_player_list_page = function(args)
  if not args or not args.cycle_config then return end
  if G.OVERLAY_MENU then
    local pl_list = G.OVERLAY_MENU:get_UIE_by_ID('server_player_list')
    if pl_list then 
      if pl_list.config.object then 
        pl_list.config.object:remove() 
      end
      pl_list.config.object = UIBox{
        definition =  G.UIDEF.player_list_page(args.cycle_config.current_option-1),
        config = {offset = {x=0,y=0}, align = 'cm', parent = pl_list}
      }
    end
  end
end

G.FUNCS.copy_server_code = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = G.MULTIPLAYER.code
  else
    love.system.setClipboardText(G.MULTIPLAYER.code)
  end 
end

----------------------------------------------
------------MOD CODE END----------------------