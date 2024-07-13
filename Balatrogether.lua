--- STEAMODDED HEADER
--- MOD_NAME: Balatrogether
--- MOD_ID: Balatrogether
--- MOD_AUTHOR: [Irreflexive]
--- MOD_DESCRIPTION: Play co-op Balatro with your friends!
--- BADGE_COLOUR: 00FF64

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.Balatrogether()
  sendDebugMessage("Launching Balatrogether!")
end

function G.UIDEF.run_setup(from_game_over)
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
              tab_definition_function = G.UIDEF.Balatrogether,
              chosen = false,
            }
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.Balatrogether()
  local t = create_UIBox_generic_options({no_back = true, no_esc = true, contents = {
    {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
      create_tabs(
        {tabs = {
          -- {
          --   label = "Host",
          --   chosen = false,
          --   tab_definition_function = G.UIDEF.Balatrogether_host,
          --   tab_definition_function_args = 'Host'
          -- },
          -- {
          --   label = "Join",
          --   chosen = false,
          --   tab_definition_function = G.UIDEF.Balatrogether_join,
          --   tab_definition_function_args = 'Join'
          -- }
        },
        snap_to_nav = true})
    }}
  }})
  return t
end

----------------------------------------------
------------MOD CODE END----------------------