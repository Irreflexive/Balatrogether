function findDescendantOfElementByConfig(element, property, value) 
  if not element or not element.children then return nil end
  for k, child in pairs(element.children) do
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

function findDescendantOfNodeTreeByConfig(t, property, value)
  if not t or not t.nodes then return nil end
  for k, child in pairs(t.nodes) do
    if child.config[property] == value then
      return child
    else
      local result = findDescendantOfNodeTreeByConfig(child, property, value)
      if result then 
        return result 
      end
    end
  end
  return nil
end