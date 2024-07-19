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
  G.FUNCS.tcp_receive()
end

G.FUNCS.join_server = function()
  sendDebugMessage("Joining server!")
  G.FUNCS.tcp_connect()
  G.FUNCS.tcp_send({ cmd = "JOIN" })
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

G.FUNCS.copy_server_code = function(e)
  if G.F_LOCAL_CLIPBOARD then
    G.CLIPBOARD = G.MULTIPLAYER.address
  else
    love.system.setClipboardText(G.MULTIPLAYER.address)
  end 
end

G.FUNCS.start_setup_run = function(e)
  if G.OVERLAY_MENU then G.FUNCS.exit_overlay_menu() end
  if G.SETTINGS.current_setup == 'New Run' then 
    if not G.GAME or (not G.GAME.won and not G.GAME.seeded) then
      if G.SAVED_GAME ~= nil then
        if not G.SAVED_GAME.GAME.won then 
          G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
        end
        G:save_settings()
      end
    end
    local _seed = G.run_setup_seed and G.setup_seed or G.forced_seed or nil
    local _challenge = G.challenge_tab or nil
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.start_run(e, {stake = _stake, seed = _seed, challenge = _challenge})
  
  elseif G.SETTINGS.current_setup == 'Multiplayer Run' then
    local _stake = G.forced_stake or G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    local _deck = G.PROFILES[G.SETTINGS.profile].MEMORY.deck or "Red Deck"
    G.FUNCS.tcp_send({
      cmd = "START", 
      stake = _stake, 
      seed = generate_starting_seed(), 
      challenge = nil, 
      deck = _deck, 
      versus = G.new_multiplayer_run_config.versus
    })

  elseif G.SETTINGS.current_setup == 'Continue' then
    if G.SAVED_GAME ~= nil then
      G.FUNCS.start_run(nil, {savetext = G.SAVED_GAME})
    end
  end
end

G.FUNCS.setup_run_multiplayer = function(e)
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.server_config(e),
  }
end

function Controller:queue_R_cursor_press(x, y)
  if self.locks.frame then return end
  if not G.SETTINGS.paused and G.hand and G.hand.highlighted[1] then 
      if (G.play and #G.play.cards > 0) or
      (self.locked) or 
      (self.locks.frame) or
      (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) then return end
      if G.FUNCS.is_coop_game() then
        G.FUNCS.tcp_send({ cmd = "UNHIGHLIGHT_ALL" })
      end
      G.hand:unhighlight_all()
  end
end

function Controller:key_hold_update(key, dt)
  if ((self.locked) and not G.SETTINGS.paused) or (self.locks.frame) or (self.frame_buttonpress) then return end
  --self.frame_buttonpress = true
  if self.held_key_times[key] then
      if key == "r" and not G.SETTINGS.paused then
          if self.held_key_times[key] > 0.7 then
              if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
                  G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
              end
              G:save_settings()
              self.held_key_times[key] = nil
              if G.MULTIPLAYER.enabled then
                G.SETTINGS.current_setup = 'Multiplayer Run'
              else
                G.SETTINGS.current_setup = 'New Run'
              end
              G.GAME.viewed_back = nil
              G.run_setup_seed = G.GAME.seeded
              G.challenge_tab = G.GAME and G.GAME.challenge and G.GAME.challenge_tab or nil
              G.forced_seed, G.setup_seed = nil, nil
              if G.GAME.seeded then G.forced_seed = G.GAME.pseudorandom.seed end
              G.forced_stake = G.GAME.stake
              if G.STAGE == G.STAGES.RUN then G.FUNCS.start_setup_run() end
              G.forced_stake = nil
              G.challenge_tab = nil
              G.forced_seed = nil
          else
              self.held_key_times[key] = self.held_key_times[key] + dt
          end
      end
  end
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