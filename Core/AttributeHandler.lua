local function CreateAttribute(registry, key,  value)
	table.insert(registry, { key = key, value = value })
end

function Clicked:ApplyAttributesToFrame(previousAttributes, newAttributes, frame)
	if frame == nil then
		return
	end

	if previousAttributes ~= nil and #previousAttributes > 0 then
		for _, attribute in ipairs(previousAttributes) do
			frame:SetAttribute(attribute.key, "")
		end
	end
	
	if newAttributes ~= nil and #newAttributes > 0 then
		for _, attribute in ipairs(newAttributes) do
            frame:SetAttribute(attribute.key, attribute.value)
		end
	end
end

function Clicked:ApplyAttributesToFrames(previousAttributes, newAttributes, frames)
    if frames == nil or #frames == 0 then
        return
    end
    
    for _, frame in ipairs(frames) do
        self:ApplyAttributesToFrame(previousAttributes, newAttributes, frame)
    end
end

function Clicked:CreateCommandAttributes(register, command, suffix)
	suffix = suffix or ""
	
	if command.action == Clicked.COMMAND_ACTION_TARGET then
		CreateAttribute(register, "type" .. suffix, "target")
		CreateAttribute(register, "unit" .. suffix, "mouseover")
	elseif command.action == Clicked.COMMAND_ACTION_MENU then
		CreateAttribute(register, "type" .. suffix, "menu")
		CreateAttribute(register, "unit" .. suffix, "mouseover")
	elseif command.action == Clicked.COMMAND_ACTION_MACRO then
		CreateAttribute(register, "type" .. suffix, "macro")
		CreateAttribute(register, "macrotext" .. suffix, command.data)
	else
		error("Clicked: Unhandled action type: " .. command.action)
	end
end
