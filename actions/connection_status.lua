G.FUNCS.update_connection_status = function()
  local ui = G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('connection_status')
  if ui then
    if ui.config.object then
      ui.config.object:remove()
    end
    ui.config.object = UIBox{
      definition = G.UIDEF.connection_status(),
      config = {offset = {x=0,y=0}, align = 'cm', parent = ui}
    }
  end
end

G.FUNCS.tcp_listen("CONNECTION_STATUS", function(data)
  Balatrogether.connection_status = data ~= "" and localize(data) or ""
  G.FUNCS.update_connection_status()
end)