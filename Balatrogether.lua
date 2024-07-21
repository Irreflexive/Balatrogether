--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play co-op Balatro with your friends!
--- VERSION: 1.0.0
--- PREFIX: btgr
--- LOADER_VERSION_GEQ: 1.0.0

----------------------------------------------
------------MOD CODE -------------------------

G.MULTIPLAYER = {
  enabled = false,
  address = "",
  players = {},
  versus = false,
  tcp = nil,
  send_queue = {},
  debug = true,
  actions = {},
}

G.new_multiplayer_run_config = {
  versus = false,
}

local mod = SMODS.current_mod
sendDebugMessage("Launching Balatrogether!")
assert(load(NFS.read(mod.path .. "json.lua")))()
assert(load(NFS.read(mod.path .. "util.lua")))()
assert(load(NFS.read(mod.path .. "singleplayer_funcs.lua")))()
assert(load(NFS.read(mod.path .. "UI_definitions.lua")))()
assert(load(NFS.read(mod.path .. "connection.lua")))()
for _,file in ipairs(NFS.getDirectoryItems(mod.path .. "actions")) do
  assert(load(NFS.read(mod.path .. "actions/" .. file)))()
end

SMODS.Atlas{
  key = "Balatrogether_cards",
  path = "sprites.png",
  px = 71,
  py = 95
}
SMODS.Atlas{
  key = "Balatrogether_blinds",
  path = "blinds.png",
  atlas_table = "ANIMATION_ATLAS",
  frames = 21,
  px = 34,
  py = 34
}
for _,file in ipairs(NFS.getDirectoryItems(mod.path .. "items")) do
  assert(load(NFS.read(mod.path .. "items/" .. file)))()
end

local old_update = love.update
function love.update(dt)
  old_update(dt)
  G.FUNCS.tcp_update(dt)
end

G.FUNCS.join_server = function()
  sendDebugMessage("Joining server!")
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
end

G.FUNCS.join_saved_server = function(e)
  G.MULTIPLAYER.address = e.config.id
  G.FUNCS.join_server()
end

G.FUNCS.is_coop_game = function()
  return G.MULTIPLAYER.enabled and not G.MULTIPLAYER.versus
end

G.FUNCS.is_versus_game = function()
  return G.MULTIPLAYER.enabled and G.MULTIPLAYER.versus
end

G.FUNCS.is_host = function(e)
  local _is_host = tostring(G.STEAM.user.getSteamID()) == G.MULTIPLAYER.players[1]
  if e and e.config and e.config.func then
    if not _is_host then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
    e.config.func = nil
  end
  return _is_host
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

local current_server_list_page = 1
G.FUNCS.change_server_list_page = function(args)
  if not args or not args.cycle_config then args = {cycle_config = {current_option = current_server_list_page}} end
  current_server_list_page = args.cycle_config.current_option
  if G.OVERLAY_MENU then
    local pl_list = G.OVERLAY_MENU:get_UIE_by_ID('saved_servers_list')
    if pl_list then 
      if pl_list.config.object then 
        pl_list.config.object:remove() 
      end
      pl_list.config.object = UIBox{
        definition =  G.UIDEF.saved_servers_page(args.cycle_config.current_option-1),
        config = {offset = {x=0,y=0}, align = 'cm', parent = pl_list}
      }
    end
  end
end

G.FUNCS.copy_server_code = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = G.MULTIPLAYER.address
  else
    love.system.setClipboardText(G.MULTIPLAYER.address)
  end 
end

G.FUNCS.save_server = function(e)
  local servers = G.PROFILES[G.SETTINGS.profile].saved_servers
  for _,server in ipairs(servers) do
    if server == G.MULTIPLAYER.address then
      return
    end
  end
  servers[#servers+1] = G.MULTIPLAYER.address
  G.PROFILES[G.SETTINGS.profile].saved_servers = servers
end

G.FUNCS.remove_server = function(e)
  local servers = G.PROFILES[G.SETTINGS.profile].saved_servers
  local id = e.config.id:match("remove_(.*)")
  for i,server in ipairs(servers) do
    if server == id then
      table.remove(servers, i)
      G.PROFILES[G.SETTINGS.profile].saved_servers = servers
      G.FUNCS.change_server_list_page()
      return
    end
  end
end

G.FUNCS.setup_run_multiplayer = function(e)
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(e),
  }
end

G.FUNCS.view_leaderboard = function(e)
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.boss_leaderboard(G.MULTIPLAYER.leaderboard),
  }
  G.OVERLAY_MENU.config.no_esc = true
  G.MULTIPLAYER.leaderboard_blind = false
  G.MULTIPLAYER.leaderboard = nil
end

G.FUNCS.close_leaderboard = function(e)
  G.FUNCS.exit_overlay_menu()
  G.FUNCS.cash_out(e)
end

G.FUNCS.paste_address = function(e)
  G.CONTROLLER.text_input_hook = e.UIBox:get_UIE_by_ID('text_input').children[1].children[1]
  for i = 1, 16 do
    G.FUNCS.text_input_key({key = 'right'})
  end
  for i = 1, 16 do
      G.FUNCS.text_input_key({key = 'backspace'})
  end
  local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ''
  clipboard = clipboard:gsub("[^%w%.]", "")
  for i = 1, #clipboard do
    local c = clipboard:sub(i,i)
    G.FUNCS.text_input_key({key = c})
  end
  G.FUNCS.text_input_key({key = 'return'})
end

local get_new_boss_ref = get_new_boss
function get_new_boss()
  if G.FUNCS.is_versus_game() then
    local the_duel = 'bl_' .. SMODS.current_mod.prefix .. '_the_duel'
    local the_showdown = 'bl_' .. SMODS.current_mod.prefix .. '_final_showdown'
    local old_perscribed = G.GAME.perscribed_bosses
    G.GAME.perscribed_bosses = {nil, the_duel, nil, the_duel, nil, the_duel, nil, the_showdown}
    local boss = get_new_boss_ref()
    G.GAME.perscribed_bosses = old_perscribed
    return boss
  end
  return get_new_boss_ref()
end

----------------------------------------------
------------MOD CODE END----------------------