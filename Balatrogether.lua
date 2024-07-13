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
	assert(load(NFS.read(mod.path .. "json.lua")))()
	assert(load(NFS.read(mod.path .. "UI_definitions.lua")))()
	assert(load(NFS.read(mod.path .. "connection.lua")))()
end

G.join_room_code = ""
G.MULTIPLAYER = {
  enabled = false,
  code = "",
  players = {},
  id = 0,
  in_game = false,
  tcp = nil,
}

local old_update = love.update
function love.update(dt)
  old_update(dt)
  G.FUNCS.tcp_listen()
end

G.FUNCS.start_server = function()
  sendDebugMessage("Starting server!")
  G.FUNCS.tcp_connect()
  local command = {
    cmd = "CREATE", 
    versus = false,
  }
  G.FUNCS.tcp_send(command)
end

G.FUNCS.join_server = function()
  sendDebugMessage("Joining server!")
  G.FUNCS.tcp_connect()
  local command = {
    cmd = "JOIN", 
    code = G.join_room_code, 
  }
  G.FUNCS.tcp_send(command)
end

G.FUNCS.leave_server = function()
  sendDebugMessage("Leaving server!")
  G.FUNCS.tcp_close()
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