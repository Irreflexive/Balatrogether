--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

local run_setup_ref = G.UIDEF.run_setup
function G.UIDEF.run_setup(from_game_over)
  if not G.STEAM then return run_setup_ref(from_game_over) end
  G.run_setup_seed = nil
  local _challenge_chosen = from_game_over == 'challenge_list'
  from_game_over = from_game_over and not (from_game_over == 'challenge_list')

  local _can_continue = G.MAIN_MENU_UI and G.FUNCS.can_continue({config = {func = true}})
  G.FUNCS.false_ret = function() return false end
  local t =   create_UIBox_generic_options({no_back = from_game_over, no_esc = from_game_over, contents ={
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
            {
              label = localize('b_new_run'),
              chosen = (not _challenge_chosen) and (not _can_continue),
              tab_definition_function = G.UIDEF.run_setup_option,
              tab_definition_function_args = 'New Run'
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
              label = localize('b_continue'),
              chosen = (not _challenge_chosen) and _can_continue,
              tab_definition_function = G.UIDEF.run_setup_option,
              tab_definition_function_args = 'Continue',
              func = 'can_continue'
            } or {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            } or nil,
            {
              label = "Balatrogether",
              tab_definition_function = G.UIDEF.multiplayer_join,
            }
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.multiplayer_join()
  local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 3, minw = 6}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
      {n=G.UIT.C, config={align = "cm", minw = 1}, nodes={
        create_text_input({ref_table = G.MULTIPLAYER, extended_corpus = true, keep_zeroes = true, ref_value = 'address', prompt_text = "IP Address"}),
        {n=G.UIT.C, config={align = "cm", minw = 0.1}, nodes={}},
        UIBox_button({label = {"Paste"}, minw = 1, minh = 0.6, button = 'paste_address', colour = G.C.BLUE, scale = 0.3, col = true})
      }},
    }},
    {n=G.UIT.R, config={align = "cm", minh = 0.5}, nodes={}},
    {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.9}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 4, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.GREEN, button = "join_server", shadow = true}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.T, config={text = 'JOIN', scale = 0.8, colour = G.C.UI.TEXT_LIGHT, func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
          }}
        }}
      }
    }}
  }
  return t
end

function G.UIDEF.server_config(e)
  local in_game = G.STAGE ~= G.STAGES.MAIN_MENU
  local no_escape = e and (e.config.id == 'from_game_over' or e.config.id == 'from_game_won')
  local t =   create_UIBox_generic_options({no_esc = not in_game or no_escape, no_back = no_escape, back_func = not in_game and "tcp_close" or nil, contents ={
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
            {
              label = 'Players',
              chosen = true,
              tab_definition_function = G.UIDEF.player_list,
            },
            {
              label = 'Start Run',
              chosen = false,
              tab_definition_function = G.UIDEF.run_setup_multiplayer,
              func = 'is_host'
            },
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.run_setup_multiplayer()
  local t = G.UIDEF.run_setup_option('Multiplayer Run')
  table.insert(t.nodes, 1, create_toggle({
    label = "Versus Mode",
    ref_table = G.MULTIPLAYER.new_run_config,
    ref_value = "versus",
    callback = function(_set_toggle)
      G.MULTIPLAYER.new_run_config.versus = _set_toggle
    end,
  }))
  return t
end

function G.UIDEF.player_list()
  G.SERVER_PLAYERS_PAGE_SIZE = 4
  local player_pages = {}
  for i = 1, math.ceil(#G.MULTIPLAYER.players/G.SERVER_PLAYERS_PAGE_SIZE) do
    table.insert(player_pages, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.MULTIPLAYER.players/G.SERVER_PLAYERS_PAGE_SIZE)))
  end
  G.E_MANAGER:add_event(Event({func = (function()
    G.FUNCS.change_player_list_page{cycle_config = {current_option = 1}}
  return true end)}))

  local t = {n=G.UIT.ROOT, config={id = 'balatrogether_player_list', align = "cm", colour = G.C.CLEAR, minh = 7, minw = 4.2}, nodes={
    {n=G.UIT.R, config={align = "cm", padding = 0.0}, nodes={
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = 'IP Address', scale = 0.5, colour = G.C.WHITE}},
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        UIBox_button({id = 'server_code', col = true, label = {G.MULTIPLAYER.address}, button = 'nil', colour = G.C.BLUE, scale = 0.5, minw = 3, minh = 0.6}),
        UIBox_button({id = 'copy_code', col = true, label = {'Copy'}, button = 'copy_server_code', colour = G.C.BLUE, scale = 0.5, minw = 2, minh = 0.6}),
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.3}, nodes={}},
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        {n=G.UIT.T, config={text = 'Player List', scale = 0.5, colour = G.C.WHITE}},
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 2.8, minw = 4.2}, nodes={
        {n=G.UIT.O, config={id = 'server_player_list', object = Moveable()}},
      }},
      {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
        create_option_cycle({id = 'player_page',scale = 0.9, h = 0.3, w = 3.5, options = player_pages, cycle_shoulders = true, opt_callback = 'change_player_list_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true}})
      }},
    }},
  }}
  return t
end

function G.UIDEF.player_list_page(_page)
  local snapped = false
  local player_list = {}
  for k = G.SERVER_PLAYERS_PAGE_SIZE*(_page or 0) + 1, G.SERVER_PLAYERS_PAGE_SIZE*((_page or 0) + 1) do
    v = G.MULTIPLAYER.players[k]
    if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.config.id == 'player_page' then snapped = true end

    player_list[#player_list+1] = 
    {n=G.UIT.R, config={align = "cm"}, nodes={
      {n=G.UIT.C, config={align = 'cl', minw = 0.8}, nodes = {
        {n=G.UIT.T, config={text = k..'', scale = 0.4, colour = G.C.WHITE}},
      }},
      UIBox_button({id = k, col = true, label = {v and G.STEAM.friends.getFriendPersonaName(G.STEAM.extra.parseUint64(v)) or ''}, button = 'nil', colour = v and (tostring(G.STEAM.user.getSteamID()) == v and G.C.IMPORTANT or G.C.RED) or G.C.GREY, minw = 4, scale = 0.4, minh = 0.6, focus_args = {snap_to = not snapped}}),
    }}      
    snapped = true
  end

  return {n=G.UIT.ROOT, config={align = "cm", padding = 0.1, colour = G.C.CLEAR}, nodes=player_list}
end

function create_UIBox_options()  
  local current_seed = nil
  local restart = nil
  local main_menu = nil
  local your_collection = nil
  local credits = nil

  G.E_MANAGER:add_event(Event({
    blockable = false,
    func = function()
      G.REFRESH_ALERTS = true
    return true
    end
  }))

  if G.STAGE == G.STAGES.RUN then
    if G.MULTIPLAYER.enabled then
      restart = UIBox_button{id = 'server_settings_button', label = {"Server Settings"}, button = "setup_run_multiplayer", minw = 5}
    else
      restart = UIBox_button{id = 'restart_button', label = {localize('b_start_new_run')}, button = "setup_run", minw = 5}
    end
    if G.MULTIPLAYER.enabled then
      main_menu = UIBox_button{ label = {"Leave Server"}, button = "quit_server", minw = 5}
    else
      main_menu = UIBox_button{ label = {localize('b_main_menu')}, button = "go_to_menu", minw = 5}
    end
    your_collection = UIBox_button{ label = {localize('b_collection')}, button = "your_collection", minw = 5, id = 'your_collection'}
    current_seed = {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
        {n=G.UIT.T, config={text = localize('b_seed')..": ", scale = 0.4, colour = G.C.WHITE}}
      }},
      {n=G.UIT.C, config={align = "cm", padding = 0, minh = 0.8}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0, minh = 0.8}, nodes={
          {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.GAME.seeded and G.C.RED or G.C.BLACK, minw = 1.8, minh = 0.5, padding = 0.1, emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
              {n=G.UIT.T, config={ text = tostring(G.GAME.pseudorandom.seed), scale = 0.43, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
            }}
          }}
        }}
      }},
      UIBox_button({col = true, button = 'copy_seed', label = {localize('b_copy')}, colour = G.C.BLUE, scale = 0.3, minw = 1.3, minh = 0.5,}),
    }}
  end
  if G.STAGE == G.STAGES.MAIN_MENU then
    credits = UIBox_button{ label = {localize('b_credits')}, button = "show_credits", minw = 5}
  end

  local settings = UIBox_button({button = 'settings', label = {localize('b_settings')}, minw = 5, focus_args = {snap_to = true}})
  local high_scores = UIBox_button{ label = {localize('b_stats')}, button = "high_scores", minw = 5}

  local t = create_UIBox_generic_options({ contents = {
      settings,
      (G.GAME.seeded and not G.MULTIPLAYER.enabled) and current_seed or nil,
      restart,
      main_menu,
      high_scores,
      your_collection,
      credits
    }})
  return t
end

----------------------------------------------
------------MOD CODE END----------------------