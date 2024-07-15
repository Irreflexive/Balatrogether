--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play co-op Balatro with your friends!

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Balatrogether()
	local mod = SMODS.findModByID("Balatrogether")
  sendDebugMessage("Launching Balatrogether!")
	assert(load(NFS.read(mod.path .. "json.lua")))()
	assert(load(NFS.read(mod.path .. "util.lua")))()
	assert(load(NFS.read(mod.path .. "singleplayer_funcs.lua")))()
	assert(load(NFS.read(mod.path .. "UI_definitions.lua")))()
	assert(load(NFS.read(mod.path .. "connection.lua")))()
  assert(load(NFS.read(mod.path .. "versus_jokers.lua")))()
  for _,file in ipairs(NFS.getDirectoryItems(mod.path .. "actions")) do
    sendDebugMessage("Loading network actions: " .. file)
    assert(load(NFS.read(mod.path .. "actions/" .. file)))()
  end
  for _,file in ipairs(NFS.getDirectoryItems(mod.path .. "jokers")) do
    sendDebugMessage("Loading joker: " .. file)
    assert(load(NFS.read(mod.path .. "jokers/" .. file)))()
  end
  G.FUNCS.load_versus_jokers(mod.path)
end

G.MULTIPLAYER = {
  enabled = false,
  address = "",
  players = {},
  versus = false,
  tcp = nil,
  debug = false,
  actions = {},
}

G.new_multiplayer_run_config = {
  versus = false,
}

local old_update = love.update
function love.update(dt)
  old_update(dt)
  G.FUNCS.tcp_listen()
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
  if e.config.func then
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

G.FUNCS.quit_server = function(e)
  remove_save()
  G.FUNCS.tcp_close()
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

G.FUNCS.text_input_key = function(args)
  args = args or {}

  if args.key == '[' or args.key == ']' then return end

  --shortcut to hook config
  local hook_config = G.CONTROLLER.text_input_hook.config.ref_table
  hook_config.orig_colour = hook_config.orig_colour or copy_table(hook_config.colour)

  args.key = args.key or '%'
  args.caps = args.caps or G.CONTROLLER.capslock or hook_config.all_caps --capitalize if caps lock or hook requires

  --Some special keys need to be mapped accordingly before passing through the corpus
  local keymap = {
    space = ' ',
    backspace = 'BACKSPACE',
    delete = 'DELETE',
    ['return'] = 'RETURN',
    right = 'RIGHT',
    left = 'LEFT'
  }
  local hook = G.CONTROLLER.text_input_hook
  local corpus = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'..(hook.config.ref_table.extended_corpus and " 0!$&()<>?:{}+-=,.[]_" or '')
  
  if hook.config.ref_table.extended_corpus then 
    local lower_ext = '1234567890-=;\',./'
    local upper_ext = '!@#$%^&*()_+:"<>?'
    if string.find(lower_ext, args.key) and args.caps then 
      args.key = string.sub(string.sub(upper_ext,string.find(lower_ext, args.key)), 0, 1)
    end
  end
  local text = hook_config.text

  --set key to mapped key or upper if caps is true
  args.key = keymap[args.key] or (args.caps and string.upper(args.key) or args.key)
  
  --Start by setting the cursor position to the correct location
  TRANSPOSE_TEXT_INPUT(0)

  if string.len(text.ref_table[text.ref_value]) > 0 and args.key == 'BACKSPACE' then --If not at start, remove preceding letter
    MODIFY_TEXT_INPUT{
      letter = '',
      text_table = text,
      pos = text.current_position,
      delete = true
    }
    TRANSPOSE_TEXT_INPUT(-1)
  elseif string.len(text.ref_table[text.ref_value]) > 0 and args.key == 'DELETE' then --if not at end, remove following letter
    MODIFY_TEXT_INPUT{
      letter = '',
      text_table = text,
      pos = text.current_position+1,
      delete = true
    }
    TRANSPOSE_TEXT_INPUT(0)
  elseif args.key == 'RETURN' then --Release the hook
    if hook.config.ref_table.callback then hook.config.ref_table.callback() end
    hook.parent.parent.config.colour = hook_config.colour
    local temp_colour = copy_table(hook_config.orig_colour)
    hook_config.colour[1] = G.C.WHITE[1]
    hook_config.colour[2] = G.C.WHITE[2]
    hook_config.colour[3] = G.C.WHITE[3]
    ease_colour(hook_config.colour, temp_colour)
    G.CONTROLLER.text_input_hook = nil
  elseif args.key == 'LEFT' then --Move cursor position to the left
    TRANSPOSE_TEXT_INPUT(-1)
  elseif args.key == 'RIGHT' then --Move cursor position to the right
    TRANSPOSE_TEXT_INPUT(1)
  elseif hook_config.max_length > string.len(text.ref_table[text.ref_value]) and
        (string.len(args.key) == 1) and
        string.find( corpus,  args.key , 1, true) then --check to make sure the key is in the valid corpus, add it to the string
    MODIFY_TEXT_INPUT{
      letter = args.key,
      text_table = text,
      pos = text.current_position+1
    }
    TRANSPOSE_TEXT_INPUT(1)
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

----------------------------------------------
------------MOD CODE END----------------------