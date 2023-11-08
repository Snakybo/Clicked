-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

--- @class ClickedInternal
local Addon = select(2, ...)

--- @class KeyButton
--- @field private id? string
--- @field public key? string
--- @field public abbreviation? string
--- @field public x? integer
--- @field public y? integer
--- @field public xOffset? integer
--- @field public yOffset? integer
--- @field public width? integer
--- @field public height? integer
--- @field public relativeTo? string
--- @field public overrides? table<KeyboardSize,KeyButton>
--- @field public disabled? boolean

--- @class KeyboardButtonLayout
--- @field public keys KeyButton[]
--- @field public sizes table<KeyboardSize,string[]>

--- @enum KeyboardLayout
Addon.KeyboardLayouts = {
	QWERTY = "QWERTY",
	QWERTZ = "QWERTZ",
	AZERTY = "AZERTY"
}

--- @enum KeyboardSize
Addon.KeyboardSizes = {
	SIZE_100 = 100,
	SIZE_80 = 80,
	SIZE_60 = 60
}

--- @class KeyButton
local KeyButtonMixin = {}

--- @return string?
function KeyButtonMixin:GetId()
	return self.id or self.key
end

--- @return string?
function KeyButtonMixin:GetAbbreviation()
	return self.abbreviation or self.key
end

--- @type KeyboardButtonLayout
local KeyboardLayoutQwerty = {
	keys = {
		{ key="ESC", x=0, width=50, height=50, disabled=true },

		{ key="F1", xOffset=50, width=50, height=50, relativeTo="ESC" },
		{ key="F2" },
		{ key="F3" },
		{ key="F4" },
		{ key="F5", xOffset=25 },
		{ key="F6" },
		{ key="F7" },
		{ key="F8" },
		{ key="F9", xOffset=25 },
		{ key="F10" },
		{ key="F11" },
		{ key="F12" },

		{ key="`", x=0, yOffset=65, width=50, height=50, relativeTo="ESC" },
		{ key="1", overrides = { [Addon.KeyboardSizes.SIZE_60] = { width=50, height=50, relativeTo="ESC" } } },
		{ key="2" },
		{ key="3" },
		{ key="4" },
		{ key="5" },
		{ key="6" },
		{ key="7" },
		{ key="8" },
		{ key="9" },
		{ key="0" },
		{ key="-" },
		{ key="=" },
		{ key="BACKSPACE", width=100 },

		{ key="TAB", x=0, yOffset=50, width=75, height=50, relativeTo="`", overrides = { [Addon.KeyboardSizes.SIZE_60] = { relativeTo = "ESC" }} },
		{ key="Q", width=50 },
		{ key="W" },
		{ key="E" },
		{ key="R" },
		{ key="T" },
		{ key="Y" },
		{ key="U" },
		{ key="I" },
		{ key="O" },
		{ key="P" },
		{ key="[" },
		{ key="]" },
		{ key="\\", width=75 },

		{ key="CAPSLOCK", x=0, yOffset=50, width=82.5, height=50, relativeTo="TAB" },
		{ key="A", width=50 },
		{ key="S" },
		{ key="D" },
		{ key="F" },
		{ key="G" },
		{ key="H" },
		{ key="J" },
		{ key="K" },
		{ key="L" },
		{ key=";" },
		{ key="'" },
		{ key="ENTER", width=117.5 },

		{ key="LSHIFT", x=0, yOffset=50, width=112.5, height=50, relativeTo="CAPSLOCK", disabled=true },
		{ key="Z", width=50 },
		{ key="X" },
		{ key="C" },
		{ key="V" },
		{ key="B" },
		{ key="N" },
		{ key="M" },
		{ key="," },
		{ key="." },
		{ key="/" },
		{ key="RSHIFT", width=137.5, disabled=true },

		{ key="LCTRL", x=0, yOffset=50, width=64.3, height=50, relativeTo="LSHIFT", disabled=true },
		{ key="LMETA", disabled=true },
		{ key="LALT", disabled=true },
		{ key="SPACE", width=300 },
		{ key="RALT", width=64.3, disabled=true },
		{ key="RMETA", xOffset=64.3, disabled=true },
		{ key="RCTRL", disabled=true },

		{ key="PRINTSCREEN", abbreviation="PRTSC", xOffset=15, width=50, height=50, relativeTo="F12" },
		{ key="SCROLLLOCK", abbreviation="SCRLK", disabled=true },
		{ key="PAUSE", disabled=true },

		{ key="INSERT", abbreviation="INS", xOffset=15, width=50, height=50, relativeTo="BACKSPACE" },
		{ key="HOME" },
		{ key="PAGEUP", abbreviation="PG UP" },

		{ key="DELETE", abbreviation="DEL", xOffset=15, width=50, height=50, relativeTo="\\" },
		{ key="END" },
		{ key="PAGEDOWN", abbreviation="PG DN" },

		{ key="UP", abbreviation="^", xOffset=65, width=50, height=50, relativeTo="RSHIFT" },

		{ key="LEFT", abbreviation="<", xOffset=15, width=50, height=50, relativeTo="RCTRL" },
		{ key="DOWN", abbreviation="v" },
		{ key="RIGHT", abbreviation=">" },

		{ key="NUMLOCK", abbreviation="NUM", xOffset=15, width=50, height=50, relativeTo="PAGEUP" },
		{ key="NUMPADDIVIDE", abbreviation="/" },
		{ key="NUMPADMULTIPLY", abbreviation="*" },
		{ key="NUMPADMINUS", abbreviation="-" },

		{ key="NUMPAD7", abbreviation="7", xOffset=15, width=50, height=50, relativeTo="PAGEDOWN" },
		{ key="NUMPAD8", abbreviation="8" },
		{ key="NUMPAD9", abbreviation="9" },
		{ key="NUMPADPLUS", abbreviation="+", height=100 },

		{ key="NUMPAD4", abbreviation="4", xOffset=180, width=50, height=50, relativeTo="ENTER" },
		{ key="NUMPAD5", abbreviation="5" },
		{ key="NUMPAD6", abbreviation="6" },

		{ key="NUMPAD1", abbreviation="1", xOffset=65, width=50, height=50, relativeTo="UP" },
		{ key="NUMPAD2", abbreviation="2" },
		{ key="NUMPAD3", abbreviation="3" },
		{ id="NUMPADENTER", key="ENTER", height=100 },

		{ key="NUMPAD0", abbreviation="0", xOffset=15, width=100, height=50, relativeTo="RIGHT" },
		{ key="NUMPADDECIMAL", abbreviation=".", width=50 },
	},
	sizes = {
		[Addon.KeyboardSizes.SIZE_100] = {
			"NUMLOCK", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS",
			"NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADPLUS",
			"NUMPAD4", "NUMPAD5", "NUMPAD6",
			"NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPADENTER",
			"NUMPAD0", "NUMPADDECIMAL"
		},
		[Addon.KeyboardSizes.SIZE_80] = {
			"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
			"`",
			"PRINTSCREEN", "SCROLLLOCK", "PAUSE",
			"INSERT", "HOME", "PAGEUP",
			"DELETE", "END", "PAGEDOWN",
			"UP", "LEFT", "DOWN", "RIGHT"
		},
		[Addon.KeyboardSizes.SIZE_60] = {
			"ESC",
			"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BACKSPACE",
			"TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\",
			"CAPSLOCK", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "ENTER",
			"LSHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "RSHIFT",
			"LCTRL", "LMETA", "LALT", "SPACE", "RALT", "RMETA", "RCTRL"
		}
	}
}

--- @type KeyboardButtonLayout
local KeyboardLayoutQwertz = {
	keys = {
		{ key="ESC", x=0, width=50, height=50, disabled=true },

		{ key="F1", xOffset=50, width=50, height=50, relativeTo="ESC" },
		{ key="F2" },
		{ key="F3" },
		{ key="F4" },
		{ key="F5", xOffset=25 },
		{ key="F6" },
		{ key="F7" },
		{ key="F8" },
		{ key="F9", xOffset=25 },
		{ key="F10" },
		{ key="F11" },
		{ key="F12" },

		{ key="^", x=0, yOffset=65, width=50, height=50, relativeTo="ESC" },
		{ key="1", overrides = { [Addon.KeyboardSizes.SIZE_60] = { width=50, height=50, relativeTo="ESC" } } },
		{ key="2" },
		{ key="3" },
		{ key="4" },
		{ key="5" },
		{ key="6" },
		{ key="7" },
		{ key="8" },
		{ key="9" },
		{ key="0" },
		{ key="ß" },
		{ key="´" },
		{ key="BACKSPACE", width=100 },

		{ key="TAB", x=0, yOffset=50, width=75, height=50, relativeTo="^", overrides = { [Addon.KeyboardSizes.SIZE_60] = { relativeTo = "ESC" }} },
		{ key="Q", width=50 },
		{ key="W" },
		{ key="E" },
		{ key="R" },
		{ key="T" },
		{ key="Z" },
		{ key="U" },
		{ key="I" },
		{ key="O" },
		{ key="P" },
		{ key="ü" },
		{ key="+" },
		{ key="ENTER", xOffset=7, width=67.5, height=100 },

		{ key="CAPSLOCK", x=0, yOffset=50, width=82.5, height=50, relativeTo="TAB" },
		{ key="A", width=50 },
		{ key="S" },
		{ key="D" },
		{ key="F" },
		{ key="G" },
		{ key="H" },
		{ key="J" },
		{ key="K" },
		{ key="L" },
		{ key="ö" },
		{ key="ä" },
		{ key="#" },

		{ key="LSHIFT", x=0, yOffset=50, width=75, height=50, relativeTo="CAPSLOCK", disabled=true },
		{ key="<", width=50 },
		{ key="Y" },
		{ key="X" },
		{ key="C" },
		{ key="V" },
		{ key="B" },
		{ key="N" },
		{ key="M" },
		{ key="," },
		{ key="." },
		{ key="-" },
		{ key="RSHIFT", width=125, disabled=true },

		{ key="LCTRL", x=0, yOffset=50, width=64.3, height=50, relativeTo="LSHIFT", disabled=true },
		{ key="LMETA", disabled=true },
		{ key="LALT", disabled=true },
		{ key="SPACE", width=300 },
		{ key="RALT", width=64.3, disabled=true },
		{ key="RMETA", xOffset=64.3, disabled=true },
		{ key="RCTRL", disabled=true },

		{ key="PRINTSCREEN", abbreviation="PRTSC", xOffset=15, width=50, height=50, relativeTo="F12" },
		{ key="SCROLLLOCK", abbreviation="SCRLK", disabled=true },
		{ key="PAUSE", disabled=true },

		{ key="INSERT", abbreviation="INS", xOffset=15, width=50, height=50, relativeTo="BACKSPACE" },
		{ key="HOME" },
		{ key="PAGEUP", abbreviation="PG UP" },

		{ key="DELETE", abbreviation="DEL", xOffset=15, width=50, height=50, relativeTo="ENTER" },
		{ key="END" },
		{ key="PAGEDOWN", abbreviation="PG DN" },

		{ key="UP", abbreviation="^", xOffset=65, width=50, height=50, relativeTo="RSHIFT" },

		{ key="LEFT", abbreviation="<", xOffset=15, width=50, height=50, relativeTo="RCTRL" },
		{ key="DOWN", abbreviation="v" },
		{ key="RIGHT", abbreviation=">" },

		{ key="NUMLOCK", abbreviation="NUM", xOffset=15, width=50, height=50, relativeTo="PAGEUP" },
		{ key="NUMPADDIVIDE", abbreviation="/" },
		{ key="NUMPADMULTIPLY", abbreviation="*" },
		{ key="NUMPADMINUS", abbreviation="-" },

		{ key="NUMPAD7", abbreviation="7", xOffset=15, width=50, height=50, relativeTo="PAGEDOWN" },
		{ key="NUMPAD8", abbreviation="8" },
		{ key="NUMPAD9", abbreviation="9" },
		{ key="NUMPADPLUS", abbreviation="+", height=100 },

		{ key="NUMPAD4", abbreviation="4", xOffset=247, width=50, height=50, relativeTo="#" },
		{ key="NUMPAD5", abbreviation="5" },
		{ key="NUMPAD6", abbreviation="6" },

		{ key="NUMPAD1", abbreviation="1", xOffset=65, width=50, height=50, relativeTo="UP" },
		{ key="NUMPAD2", abbreviation="2" },
		{ key="NUMPAD3", abbreviation="3" },
		{ id="NUMPADENTER", key="ENTER", height=100 },

		{ key="NUMPAD0", abbreviation="0", xOffset=15, width=100, height=50, relativeTo="RIGHT" },
		{ key="NUMPADDECIMAL", abbreviation=".", width=50 },
	},
	sizes = {
		[Addon.KeyboardSizes.SIZE_100] = {
			"NUMLOCK", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS",
			"NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADPLUS",
			"NUMPAD4", "NUMPAD5", "NUMPAD6",
			"NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPADENTER",
			"NUMPAD0", "NUMPADDECIMAL"
		},
		[Addon.KeyboardSizes.SIZE_80] = {
			"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
			"^",
			"PRINTSCREEN", "SCROLLLOCK", "PAUSE",
			"INSERT", "HOME", "PAGEUP",
			"DELETE", "END", "PAGEDOWN",
			"UP", "LEFT", "DOWN", "RIGHT"
		},
		[Addon.KeyboardSizes.SIZE_60] = {
			"ESC",
			"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "ß", "´", "BACKSPACE",
			"TAB", "Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P", "ü", "+", "ENTER",
			"CAPSLOCK", "A", "S", "D", "F", "G", "H", "J", "K", "L", "ö", "ä", "#",
			"LSHIFT", "<", "Y", "X", "C", "V", "B", "N", "M", ",", ".", "-", "RSHIFT",
			"LCTRL", "LMETA", "LALT", "SPACE", "RALT", "RMETA", "RCTRL"
		}
	}
}

--- @type KeyboardButtonLayout
local KeyboardLayoutAzerty = {
	keys = {
		{ key="ESC", x=0, width=50, height=50, disabled=true },

		{ key="F1", xOffset=50, width=50, height=50, relativeTo="ESC" },
		{ key="F2" },
		{ key="F3" },
		{ key="F4" },
		{ key="F5", xOffset=25 },
		{ key="F6" },
		{ key="F7" },
		{ key="F8" },
		{ key="F9", xOffset=25 },
		{ key="F10" },
		{ key="F11" },
		{ key="F12" },

		{ key="²", x=0, yOffset=65, width=50, height=50, relativeTo="ESC" },
		{ key="1", overrides = { [Addon.KeyboardSizes.SIZE_60] = { width=50, height=50, relativeTo="ESC" } } },
		{ key="2" },
		{ key="3" },
		{ key="4" },
		{ key="5" },
		{ key="6" },
		{ key="7" },
		{ key="8" },
		{ key="9" },
		{ key="0" },
		{ key=")" },
		{ key="=" },
		{ key="BACKSPACE", width=100 },

		{ key="TAB", x=0, yOffset=50, width=75, height=50, relativeTo="²", overrides = { [Addon.KeyboardSizes.SIZE_60] = { relativeTo = "ESC" }} },
		{ key="A", width=50 },
		{ key="Z" },
		{ key="E" },
		{ key="R" },
		{ key="T" },
		{ key="Y" },
		{ key="U" },
		{ key="I" },
		{ key="O" },
		{ key="P" },
		{ key="^" },
		{ key="$" },
		{ key="ENTER", xOffset=7, width=67.5, height=100 },

		{ key="CAPSLOCK", x=0, yOffset=50, width=82.5, height=50, relativeTo="TAB" },
		{ key="Q", width=50 },
		{ key="S" },
		{ key="D" },
		{ key="F" },
		{ key="G" },
		{ key="H" },
		{ key="J" },
		{ key="K" },
		{ key="L" },
		{ key="M" },
		{ key="ù" },
		{ key="*" },

		{ key="LSHIFT", x=0, yOffset=50, width=75, height=50, relativeTo="CAPSLOCK", disabled=true },
		{ key="<", width=50 },
		{ key="W" },
		{ key="X" },
		{ key="C" },
		{ key="V" },
		{ key="B" },
		{ key="N" },
		{ key="," },
		{ key=";" },
		{ key=":" },
		{ key="!" },
		{ key="RSHIFT", width=125, disabled=true },

		{ key="LCTRL", x=0, yOffset=50, width=64.3, height=50, relativeTo="LSHIFT", disabled=true },
		{ key="LMETA", disabled=true },
		{ key="LALT", disabled=true },
		{ key="SPACE", width=300 },
		{ key="RALT", width=64.3, disabled=true },
		{ key="RMETA", xOffset=64.3, disabled=true },
		{ key="RCTRL", disabled=true },

		{ key="PRINTSCREEN", abbreviation="PRTSC", xOffset=15, width=50, height=50, relativeTo="F12" },
		{ key="SCROLLLOCK", abbreviation="SCRLK", disabled=true },
		{ key="PAUSE", disabled=true },

		{ key="INSERT", abbreviation="INS", xOffset=15, width=50, height=50, relativeTo="BACKSPACE" },
		{ key="HOME" },
		{ key="PAGEUP", abbreviation="PG UP" },

		{ key="DELETE", abbreviation="DEL", xOffset=15, width=50, height=50, relativeTo="ENTER" },
		{ key="END" },
		{ key="PAGEDOWN", abbreviation="PG DN" },

		{ key="UP", abbreviation="^", xOffset=65, width=50, height=50, relativeTo="RSHIFT" },

		{ key="LEFT", abbreviation="<", xOffset=15, width=50, height=50, relativeTo="RCTRL" },
		{ key="DOWN", abbreviation="v" },
		{ key="RIGHT", abbreviation=">" },

		{ key="NUMLOCK", abbreviation="NUM", xOffset=15, width=50, height=50, relativeTo="PAGEUP" },
		{ key="NUMPADDIVIDE", abbreviation="/" },
		{ key="NUMPADMULTIPLY", abbreviation="*" },
		{ key="NUMPADMINUS", abbreviation="-" },

		{ key="NUMPAD7", abbreviation="7", xOffset=15, width=50, height=50, relativeTo="PAGEDOWN" },
		{ key="NUMPAD8", abbreviation="8" },
		{ key="NUMPAD9", abbreviation="9" },
		{ key="NUMPADPLUS", abbreviation="+", height=100 },

		{ key="NUMPAD4", abbreviation="4", xOffset=247, width=50, height=50, relativeTo="*" },
		{ key="NUMPAD5", abbreviation="5" },
		{ key="NUMPAD6", abbreviation="6" },

		{ key="NUMPAD1", abbreviation="1", xOffset=65, width=50, height=50, relativeTo="UP" },
		{ key="NUMPAD2", abbreviation="2" },
		{ key="NUMPAD3", abbreviation="3" },
		{ id="NUMPADENTER", key="ENTER", height=100 },

		{ key="NUMPAD0", abbreviation="0", xOffset=15, width=100, height=50, relativeTo="RIGHT" },
		{ key="NUMPADDECIMAL", abbreviation=".", width=50 },
	},
	sizes = {
		[Addon.KeyboardSizes.SIZE_100] = {
			"NUMLOCK", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS",
			"NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADPLUS",
			"NUMPAD4", "NUMPAD5", "NUMPAD6",
			"NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPADENTER",
			"NUMPAD0", "NUMPADDECIMAL"
		},
		[Addon.KeyboardSizes.SIZE_80] = {
			"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
			"²",
			"PRINTSCREEN", "SCROLLLOCK", "PAUSE",
			"INSERT", "HOME", "PAGEUP",
			"DELETE", "END", "PAGEDOWN",
			"UP", "LEFT", "DOWN", "RIGHT"
		},
		[Addon.KeyboardSizes.SIZE_60] = {
			"ESC",
			"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ")", "=", "BACKSPACE",
			"TAB", "A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P", "^", "$", "ENTER",
			"CAPSLOCK", "Q", "S", "D", "F", "G", "H", "J", "K", "L", "M", "ù", "*",
			"LSHIFT", "<", "W", "X", "C", "V", "B", "N", ",", ";", ":", "!", "RSHIFT",
			"LCTRL", "LMETA", "LALT", "SPACE", "RALT", "RMETA", "RCTRL"
		}
	}
}

local layouts = {
	[Addon.KeyboardLayouts.QWERTY] = KeyboardLayoutQwerty,
	[Addon.KeyboardLayouts.QWERTZ] = KeyboardLayoutQwertz,
	[Addon.KeyboardLayouts.AZERTY] = KeyboardLayoutAzerty
}

for _, layout in pairs(layouts) do
	for i, key in ipairs(layout.keys) do
		layout.keys[i] = Mixin(key, KeyButtonMixin)
	end
end

--- @class KeyLayout
local KeyLayouts = {}

--- @return string[]
function KeyLayouts:GetKeyboardLayouts()
	local result = {}

	for key in pairs(layouts) do
		table.insert(result, key)
	end

	local function SortFunc(l, r)
		return l < r
	end

	table.sort(result, SortFunc)
	return result
end

--- @param layout KeyboardLayout
--- @return string[]
function KeyLayouts:GetKeyboardSizes(layout)
	local result = {}

	for size in pairs(layouts[layout].sizes) do
		table.insert(result, size)
	end

	local function SortFunc(l, r)
		return l > r
	end

	table.sort(result, SortFunc)
	return result
end

--- @param layout KeyboardLayout
--- @param size KeyboardSize
--- @return KeyButton[]
--- @return string[]
function KeyLayouts:GetKeyboardLayout(layout, size)
	local keys = {}
	local visible = {}

	for _, data in ipairs(layouts[layout].keys) do
		table.insert(keys, data)
	end

	for s, enabledKeys in pairs(layouts[layout].sizes) do
		if s <= size then
			for _, key in ipairs(enabledKeys) do
				table.insert(visible, key)
			end
		end
	end

	return keys, visible
end

Addon.KeyLayouts = KeyLayouts
