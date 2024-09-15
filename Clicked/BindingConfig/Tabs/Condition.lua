-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--- @class BindingConditionDrawer
--- @field public fieldName string
--- @field public condition Condition
--- @field public bindings Binding[]
--- @field public container AceGUIContainer
--- @field public status table
--- @field public requestAvailableValues fun():...
--- @field public requestRedraw fun(dependendsOnly?: boolean)
--- @field public Draw? fun(self: BindingConditionDrawer)
--- @field public Update? fun(self: BindingConditionDrawer)

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigConditionTab : BindingConfigTab
--- @field public content RuntimeConditionSet
--- @field private drawers table<string, BindingConditionDrawer>
--- @field private status table
Addon.BindingConfig.BindingConditionTab = {
	drawers = {},
	status = {}
}

--- @protected
function Addon.BindingConfig.BindingConditionTab:Show()
end

--- @protected
function Addon.BindingConfig.BindingConditionTab:Hide()
	table.wipe(self.drawers)
	table.wipe(self.status)
end

--- @protected
function Addon.BindingConfig.BindingConditionTab:Redraw()
	table.wipe(self.drawers)

	for _, condition in ipairs(self.content.config) do
		local drawer = self:CreateDrawer(condition)

		if drawer ~= nil then
			self.drawers[condition.id] = drawer

			Addon:SafeCall(drawer.Draw, drawer)
		end
	end
end

--- @private
--- @param condition string
function Addon.BindingConfig.BindingConditionTab:RedrawItem(condition)
	local drawer = self.drawers[condition]
	if drawer == nil then
		return
	end

	Addon:SafeCall(drawer.Update, drawer)
end

--- @private
--- @param condition Condition
--- @return BindingConditionDrawer?
function Addon.BindingConfig.BindingConditionTab:CreateDrawer(condition)
	local template = Addon.BindingConfig.BindingConditionDrawers[condition.drawer.type]
	if template == nil then
		return nil
	end

	self.status[condition.id] = self.status[condition.id] or {}

	local impl = CreateFromMixins(template, {
		fieldName = condition.id,
		condition = condition,
		bindings = self.bindings,
		container = self.container,
		status = self.status[condition.id],
		requestAvailableValues = function()
			return self:GetAvailableValues(condition)
		end,
		requestRedraw = function(dependendsOnly) --- @param dependendsOnly? boolean
			if dependendsOnly then
				local graph = self.content.dependencyGraph[condition.id]

				for _, dependend in ipairs(graph) do
					self:RedrawItem(dependend)
				end
			else
				self.controller:RedrawTab()
			end
		end
	})

	return impl
end

--- @private
--- @param condition Condition
function Addon.BindingConfig.BindingConditionTab:GetAvailableValues(condition)
	--- @type any[]
	local dependencies = {}

	if condition.dependencies ~= nil then
		for i, dependencyId in ipairs(condition.dependencies) do
			local dependency = Addon.Condition.Registry:GetConditionById(dependencyId)

			dependencies[i] = dependencies[i] or {}

			if dependency ~= nil then
				for _, binding in ipairs(self.bindings) do
					local load = binding.load[dependencyId] or dependency.init()
					local value = dependency.unpack(load)

					if type(value) == "table" and value[1] ~= nil then
						for j = 1, #value do
							if not tContains(dependencies[i], value[j]) then
								table.insert(dependencies[i], value[j])
							end
						end
					elseif value ~= nil then
						if not tContains(dependencies[i], value) then
							table.insert(dependencies[i], value)
						end
					end
				end
			end
		end
	end

	local result = { Addon:SafeCall(condition.drawer.availableValues, SafeUnpack(dependencies)) }
	table.remove(result, 1)

	return SafeUnpack(result)
end
