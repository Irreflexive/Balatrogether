--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play multiplayer Balatro with or against your friends!
--- VERSION: 1.0.0
--- PREFIX: btgr
--- LOADER_VERSION_GEQ: 1.0.0

----------------------------------------------
------------MOD CODE -------------------------

Balatrogether = {
  prefix = SMODS.current_mod.prefix,
  file_path = SMODS.current_mod.path,
  mod = SMODS.current_mod,
  new_run_config = {
    versus = false,
  },
  debug = false,
  actions = {},
  address_input = "",
}

Balatrogether.server = {
  enabled = false,
  address = "",
  players = {},
  lobbies = {},
  versus = false,
  max_players = 0,
  game_state = {},
  network_pack = {jokers = {}, cards = {}},
}

sendDebugMessage("Launching Balatrogether!", "Balatrogether")
assert(load(NFS.read(Balatrogether.file_path .. "json.lua")))()
assert(load(NFS.read(Balatrogether.file_path .. "util.lua")))()
assert(load(NFS.read(Balatrogether.file_path .. "card_tagging.lua")))()
assert(load(NFS.read(Balatrogether.file_path .. "singleplayer_funcs.lua")))()
assert(load(NFS.read(Balatrogether.file_path .. "UI_definitions.lua")))()
assert(load(NFS.read(Balatrogether.file_path .. "connection.lua")))()
for _,file in ipairs(NFS.getDirectoryItems(Balatrogether.file_path .. "actions")) do
  assert(load(NFS.read(Balatrogether.file_path .. "actions/" .. file)))()
end

SMODS.Atlas{
  key = "sprites",
  path = "sprites.png",
  px = 71,
  py = 95
}
SMODS.Atlas{
  key = "blinds",
  path = "blinds.png",
  atlas_table = "ANIMATION_ATLAS",
  frames = 21,
  px = 34,
  py = 34
}
for _,file in ipairs(NFS.getDirectoryItems(Balatrogether.file_path .. "items")) do
  assert(load(NFS.read(Balatrogether.file_path .. "items/" .. file)))()
end

local old_update = love.update
function love.update(dt)
  old_update(dt)
  G.FUNCS.tcp_update(dt)
end

G.FUNCS.join_server = function()
  sendDebugMessage("Joining server!", "Balatrogether")
  Balatrogether.server.address = Balatrogether.address_input
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
end

G.FUNCS.refresh_lobbies = function()
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
end

G.FUNCS.join_saved_server = function(e)
  sendDebugMessage("Joining server!", "Balatrogether")
  Balatrogether.server.address = e.config.id
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
end

G.FUNCS.is_coop_game = function()
  return Balatrogether.server.enabled and not Balatrogether.server.versus
end

G.FUNCS.is_versus_game = function()
  return Balatrogether.server.enabled and Balatrogether.server.versus
end

G.FUNCS.is_host = function(e)
  if #Balatrogether.server.players == 0 then return false end
  return tostring(G.STEAM.user.getSteamID()) == Balatrogether.server.players[1].id
end

G.FUNCS.get_player_name = function(player)
  if not player then return "" end
  if type(player) == "userdata" then
    player = tostring(player)
  end
  if type(player) == "string" then
    for _,p in ipairs(Balatrogether.server.players) do
      if p.id == player and p.name then
        return p.name
      end
    end
    player = {id = player}
  end
  return player.name or G.STEAM.friends.getFriendPersonaName(G.STEAM.extra.parseUint64(player.id))
end

G.FUNCS.can_setup_multiplayer_run = function(e)
  local _can_setup = G.FUNCS.is_host() and (#Balatrogether.server.players >= 2 or Balatrogether.debug)
  if e and e.config and e.config.func then
    if not _can_setup then
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
    e.config.func = nil
  end
end

G.FUNCS.copy_server_code = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = Balatrogether.server.address
  else
    love.system.setClipboardText(Balatrogether.server.address)
  end 
end

G.FUNCS.save_server = function(e)
  local servers = Balatrogether.mod.config.saved_servers or {}
  for _,server in ipairs(servers) do
    if server == Balatrogether.server.address then
      return
    end
  end
  servers[#servers+1] = Balatrogether.server.address
  Balatrogether.mod.config.saved_servers = servers
  SMODS.save_mod_config(Balatrogether.mod)
end

G.FUNCS.remove_server = function(e)
  local servers = Balatrogether.mod.config.saved_servers or {}
  local id = e.config.id:match("remove_(.*)")
  for i,server in ipairs(servers) do
    if server == id then
      table.remove(servers, i)
      Balatrogether.mod.config.saved_servers = servers
      SMODS.save_mod_config(Balatrogether.mod)
      G.FUNCS['change_' .. Balatrogether.prefix .. '_saved_servers_list_page']()
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
    definition = G.UIDEF.boss_leaderboard(Balatrogether.server.leaderboard),
  }
  G.OVERLAY_MENU.config.no_esc = true
  Balatrogether.server.leaderboard_blind = false
  Balatrogether.server.leaderboard = nil
end

G.FUNCS.close_leaderboard = function(e)
  G.FUNCS.exit_overlay_menu()
  G.FUNCS.cash_out(e)
end

G.FUNCS.lose_duel_versus = function(e)
  G.FUNCS.exit_overlay_menu()
  G.STATE = G.STATES.GAME_OVER
  G.STATE_COMPLETE = false
end

G.FUNCS.compute_unlock_hash = function()
  local content = {}
  for k,v in pairs(G.P_CENTERS) do
    if v.unlocked and v.set ~= "Back" then
      table.insert(content, k)
    end
  end
  table.sort(content)
  return love.data.encode("string", "base64", love.data.hash("sha512", table.concat(content, ",")))
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

G.FUNCS.get_duel_threshold = function()
  return math.ceil((Balatrogether.server.game_state.remaining or 0) / 2)
end

local get_new_boss_ref = get_new_boss
function get_new_boss()
  if G.FUNCS.is_versus_game() then
    local the_duel = createCollectionId('bl', 'the_duel')
    local the_showdown = createCollectionId('bl', 'final_showdown')
    local old_perscribed = G.GAME.perscribed_bosses
    G.GAME.perscribed_bosses = old_perscribed or {}
    local ante = G.GAME.round_resets.ante
    if G.FUNCS.get_duel_threshold() >= 2 and ante % 2 == 0 then
      G.GAME.perscribed_bosses[ante] = the_duel
    end
    G.GAME.perscribed_bosses[G.GAME.win_ante] = the_showdown
    local boss = get_new_boss_ref()
    G.GAME.perscribed_bosses = old_perscribed
    return boss
  end
  return get_new_boss_ref()
end

local get_pack_ref = get_pack
function get_pack(_key, _type)
  if not G.FUNCS.is_versus_game() then
    G.GAME.banned_keys[createCollectionId('p', 'network')] = true
    G.GAME.banned_keys[createCollectionId('p', 'network_2')] = true
  end
  return get_pack_ref(_key, _type)
end

----------------------------------------------
------------MOD CODE END----------------------