-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @class Addon
local Addon = select(2, ...)

--- @generic T
--- @param tbl T[]
--- @param item T
--- @return boolean
function Addon.TableContainsItem(tbl, item)
	for i = 1, #tbl do
		if tbl[i] == item then
			return true
		end
	end

	return false
end

--- @generic T
--- @param tbl T[]
--- @param predicate fun(item: T): boolean
--- @return boolean
function Addon.TableContainsPredicate(tbl, predicate)
	for i = 1, #tbl do
		if predicate(tbl[i]) then
			return true
		end
	end

	return false
end

--- @generic T
--- @param tbl T[]
--- @param item T
--- @return integer
function Addon.TableIndexOfItem(tbl, item)
	local index = 0

	for i = 1, #tbl do
		if tbl[i] == item then
			return i
		end
	end

	return 0
end

--- @generic T
--- @param tbl T[]
--- @param element T
--- @return boolean
function Addon.TableRemoveItem2(tbl, element)
	local result = false

	for i = #tbl, 1, -1 do
		if tbl[i] == element then
			table.remove(tbl, i)
			result = true
		end
	end

	return result
end

--- @generic T
--- @param tbl T[]
--- @param predicate fun(item: T): boolean
--- @return boolean
function Addon.TableRemovePredicate(tbl, predicate)
	local result = false

	for i = #tbl, 1, -1 do
		if predicate(tbl[i]) then
			table.remove(tbl, i)
			result = true
		end
	end

	return result
end

--- @generic T
--- @param tbl1 T[]
--- @param tbl2 T[]
--- @return boolean
function Addon.TableEquivalent2(tbl1, tbl2)
	if #tbl1 ~= #tbl2 then
		return false
	end

	--- @type table<any,boolean>
	local set = {}

	for i = 1, #tbl1 do
		local element = tbl1[i]
		set[element] = true
	end

	for i = 1, #tbl2 do
		local element = tbl2[i]

		if set[element] == nil then
			return false
		end
	end

	return true
end

--- @generic T
--- @generic U
--- @param tbl T[]
--- @param selector fun(item: T): U
--- @return U[]
function Addon.TableSelect2(tbl, selector)
	local result = {}

	for i = 1, #tbl do
		local value = selector(tbl[i])

		if value ~= nil then
			table.insert(result, value)
		end
	end

	return result
end
