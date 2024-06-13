if LibStub == nil then
	error("LibMacroSyntaxHighlight-1.0 requires LibStub")
end

--- @class LibMacroSyntaxHighlight-1.0
local Library = LibStub:NewLibrary("LibMacroSyntaxHighlight-1.0", 1)

--- @class LibMacroSyntaxHighlight-1.0.Token
--- @field public str string
--- @field public type LibMacroSyntaxHighlight-1.0.TokenType
--- @field public from integer
--- @field public to integer

--- @alias LibMacroSyntaxHighlight-1.0.ColorTable { [LibMacroSyntaxHighlight-1.0.TokenType]: string }

if Library == nil then
	return
end

--- @enum LibMacroSyntaxHighlight-1.0.TokenType
Library.TokenType = {
	NUMBER = 1,
	WHITESPACE = 2,
	LINEBREAK = 3,
	SEMICOLON = 4,
	COLON = 5,
	LEFT_BRACKET = 6,
	RIGHT_BRACKET = 7,
	COMMA = 8,
	SLASH = 9,
	SPELL_NAME = 10,
	SLASH_COMMAND = 11,
	CONDITION = 12,
	TARGET_UNIT = 13,
	SHEBANG = 14,
}

--- @type LibMacroSyntaxHighlight-1.0.ColorTable
local defaultColorTable = {
	[Library.TokenType.NUMBER] = "ffb5cea8",
	[Library.TokenType.SEMICOLON] = "ffdcdcaa",
	[Library.TokenType.COLON] = "ffffffff",
	[Library.TokenType.LEFT_BRACKET] = "ffffffff",
	[Library.TokenType.RIGHT_BRACKET] = "ffffffff",
	[Library.TokenType.COMMA] = "ffffffff",
	[Library.TokenType.SLASH] = "ffffffff",
	[Library.TokenType.SPELL_NAME] = "ffce9178",
	[Library.TokenType.SLASH_COMMAND] = "ffdcdcaa",
	[Library.TokenType.CONDITION] = "ff9cdcfe",
	[Library.TokenType.TARGET_UNIT] = "ff4ec9b0",
	[Library.TokenType.SHEBANG] = "ffffffff",
}

local bytes = {
	["LINEBREAK_UNIX"] = string.byte("\n"),
	["LINEBREAK_MAC"] = string.byte("\r"),
	["WHITESPACE"] = string.byte(" "),
	["TAB"] = string.byte("\t"),
	["LEFT_BRACKET"] = string.byte("["),
	["RIGHT_BRACKET"] = string.byte("]"),
	["COMMA"] = string.byte(","),
	["SEMICOLON"] = string.byte(";"),
	["COLON"] = string.byte(":"),
	["SLASH"] = string.byte("/"),
	["NUM_0"] = string.byte("0"),
	["NUM_9"] = string.byte("9"),
	["AT"] = string.byte("@"),
	["SHEBANG"] = string.byte("#")
}

local linebreaks = {
	[bytes.LINEBREAK_UNIX] = true,
	[bytes.LINEBREAK_MAC] = true
}

local whitespace = {
	[bytes.WHITESPACE] = true,
	[bytes.TAB] = true
}

--- @param text string
--- @param position integer
local function IsStartOfLine(text, position)
	if position == 1 then
		return true
	end

	local previousByte = string.byte(text, position - 1)
	if previousByte == nil then
		return true
	end

	if linebreaks[previousByte] then
		return true
	end

	return false
end

local function IsSpecialByte(byte)
	for _, v in pairs(bytes) do
		if v == byte then
			return true
		end
	end
end

--- @param text string
--- @param position integer
--- @param state table
--- @return LibMacroSyntaxHighlight-1.0.TokenType?
--- @return integer?
local function GetNextToken(text, position, state)
	local byte = string.byte(text, position)
	if byte == nil then
		return nil
	end

	if linebreaks[byte] then
		state.in_slash_command = nil
		return Library.TokenType.LINEBREAK, position + 1
	end

	if whitespace[byte] then
		while true do
			position = position + 1
			byte = string.byte(text, position)

			if byte == nil or not whitespace[byte] then
				return Library.TokenType.WHITESPACE, position
			end
		end
	end

	if byte == bytes.SLASH and IsStartOfLine(text, position) then
		while true do
			position = position + 1
			byte = string.byte(text, position)

			if byte == nil or IsSpecialByte(byte) then
				state.in_slash_command = true
				return Library.TokenType.SLASH_COMMAND, position
			end
		end
	elseif state.in_slash_command then
		if byte == bytes.LEFT_BRACKET then
			state.in_conditions = true
			return Library.TokenType.LEFT_BRACKET, position + 1
		elseif byte == bytes.RIGHT_BRACKET then
			state.in_conditions = nil
			return Library.TokenType.RIGHT_BRACKET, position + 1
		elseif byte == bytes.COMMA then
			return Library.TokenType.COMMA, position + 1
		elseif byte == bytes.SEMICOLON then
			return Library.TokenType.SEMICOLON, position + 1
		elseif state.in_conditions then
			if byte == bytes.COLON then
				return Library.TokenType.COLON, position + 1
			elseif byte >= bytes.NUM_0 and byte <= bytes.NUM_9 then
				return Library.TokenType.NUMBER, position + 1
			elseif byte == bytes.SLASH then
				return Library.TokenType.SLASH, position + 1
			elseif byte == bytes.AT then
				while true do
					position = position + 1
					byte = string.byte(text, position)

					if byte == nil or IsSpecialByte(byte) then
						return Library.TokenType.TARGET_UNIT, position
					end
				end
			else
				while true do
					position = position + 1
					byte = string.byte(text, position)

					if byte == nil or IsSpecialByte(byte) then
						return Library.TokenType.CONDITION, position
					end
				end
			end
		else
			while true do
				position = position + 1
				byte = string.byte(text, position)

				if byte == nil or IsSpecialByte(byte) then
					return Library.TokenType.SPELL_NAME, position
				end
			end
		end
	elseif byte == bytes.SHEBANG and IsStartOfLine(text, position) then
		while true do
			position = position + 1
			byte = string.byte(text, position)

			if byte == nil or IsSpecialByte(byte) then
				return Library.TokenType.SHEBANG, position
			end
		end
	end
end

--- @param text string
--- @return LibMacroSyntaxHighlight-1.0.Token[]
function Library:Tokenize(text)
	local currentPosition = 1
	local state = {}

	--- @type LibMacroSyntaxHighlight-1.0.Token[]
	local result = {}

	while true do
		local tokenType, nextPosition = GetNextToken(text, currentPosition, state)
		if tokenType == nil then
			break
		end

		--- @type LibMacroSyntaxHighlight-1.0.Token
		local token = {
			str = string.sub(text, currentPosition, nextPosition - 1),
			type = tokenType,
			from = currentPosition,
			to = nextPosition - 1
		}

		table.insert(result, token)

		if nextPosition == nil then
			break
		end

		currentPosition = nextPosition
	end

	return result
end

--- @param text string
--- @param colorTable LibMacroSyntaxHighlight-1.0.ColorTable?
--- @return string
function Library:Colorize(text, colorTable)
	assert(type(text) == "string", "bad argument #1, expected string but got " .. type(text))

	if #text == 0 then
		return text
	end

	colorTable = colorTable or defaultColorTable

	local tokens = self:Tokenize(text)

	--- @string[]
	local result = {}

	for _, token in ipairs(tokens) do
		if colorTable[token.type] ~= nil then
			table.insert(result, "|c" .. colorTable[token.type] .. token.str .. "|r")
		else
			table.insert(result, token.str)
		end
	end

	return table.concat(result)
end

--- @return LibMacroSyntaxHighlight-1.0.ColorTable
function Library:GetDefaultColorTable()
	local result = {}

	for k, v in pairs(Library.TokenType) do
		result[k] = v
	end

	return result
end
