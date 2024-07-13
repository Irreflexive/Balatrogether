--- STEAMODDED HEADER
--- SECONDARY MOD FILE

----------------------------------------------
------------MOD CODE--------------------------

function findDescendantOfElementByConfig(element, property, value) 
  if not element or not element.children then return nil end
  for k, child in pairs(element.children) do
    sendDebugMessage(tostring(element) .. " " .. tostring(k) .. " " .. tostring(child.config[property]) .. " " .. tostring(value))
    if (child.definition) then
      sendDebugMessage(tostring(element) .. " " .. tostring(k) .. " " .. tostring(child.definition.config[property]) .. " " .. tostring(value))
    end
    if child.config[property] == value or (child.definition and child.definition.config[property] == value) then
      return child.definition or child
    else
      local result = findDescendantOfElementByConfig(child, property, value)
      if result then
        return result
      end
    end
  end
  return nil
end

----------------------------------------------
------------MOD CODE END----------------------