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

--- @class ClickedInternal
local Addon = select(2, ...)

local characterCache = {}
local byteCache = {}
local averageCache = {}

--- @param str string
--- @param index integer
--- @return string
local function CharAt(str, index)
	if characterCache[str] == nil then
		characterCache[str] = {}
	end

	if characterCache[str][index] == nil then
		characterCache[str][index] = Addon:CharAt(str, index)
	end

	return characterCache[str][index]
end

--- @param str string
--- @param index integer
--- @return integer
local function ByteAt(str, index)
	local char = CharAt(str, index)

	if byteCache[char] == nil then
		byteCache[char] = string.byte(char)
	end

	return byteCache[char]
end

--- @param input number[]
local function GetAverage(input)
	local sum = 0

	for _, value in ipairs(input) do
		sum = sum + value
	end

	return sum / #input
end

-- Private addon API

--- @class StringUtils
local StringUtils = {}

-- Longest common subsequence
do
	--- @type integer[][]
	local matrix = {}

	--- @param rows integer
	--- @param cols integer
	local function InitializeMatrix(rows, cols)
		for i = 0, rows do
			matrix[i] = {}

			for j = 0, cols do
				matrix[i][j] = 0
			end
		end

		for i = 1, rows do
			matrix[i][0] = 0
		end

		for j = 1, cols do
			matrix[0][j] = 0
		end
	end

	--- Find the longest common subsequence by backtracking over the specified strings.
	---
	--- @param source string
	--- @param target string
	--- @param i integer
	--- @param j integer
	--- @return string
	local function Backtrack(source, target, i, j)
		if i == 0 or j == 0 then
			return ""
		end

		if ByteAt(source, i) == ByteAt(target, j) then
			return Backtrack(source, target, i - 1, j - 1) .. CharAt(source, i)
		end

		if matrix[i][j - 1] > matrix[i - 1][j] then
			return Backtrack(source, target, i, j - 1)
		else
			return Backtrack(source, target, i - 1, j)
		end
	end

	--- Find the longest common subsequence between two strings.
	---
	--- @param source string
	--- @param target string
	--- @param sourceLength integer?
	--- @param targetLength integer?
	--- @return string
	function StringUtils:LongestCommonSubsequence(source, target, sourceLength, targetLength)
		sourceLength = sourceLength or strlenutf8(source)
		targetLength = targetLength or strlenutf8(target)

		if sourceLength == 0 or targetLength == 0 then
			return ""
		end

		if source == target then
			return source
		end

		InitializeMatrix(sourceLength, targetLength)

		for i = 1, sourceLength do
			for j = 1, targetLength do
				if ByteAt(source, i) == ByteAt(target, j) then
					matrix[i][j] = matrix[i - 1][j - 1] + 1
				else
					local insertion = matrix[i][j - 1]
					local deletion = matrix[i - 1][j]

					matrix[i][j] = math.max(insertion, deletion)
				end
			end
		end

		return Backtrack(source, target, sourceLength, targetLength)
	end
end

-- Levenshtein distance
do
	--- @type integer[][]
	local matrix = {}

	--- @param rows integer
	--- @param cols integer
	local function InitializeMatrix(rows, cols)
		for i = 0, rows do
			matrix[i] = {}

			for j = 0, cols do
				matrix[i][j] = 0
			end
		end

		for i = 1, rows do
			matrix[i][0] = i
		end

		for j = 1, cols do
			matrix[0][j] = j
		end
	end

	--- Calculate the number of insertions, deletions, or substitutions required to transform the source string into the target string.
	---
	--- https://en.wikipedia.org/wiki/Levenshtein_distance
	---
	--- https://planetcalc.com/1721/
	---
	--- @param source string
	--- @param target string
	--- @param sourceLength integer?
	--- @param targetLength integer?
	--- @return integer
	function StringUtils:LevenshteinDistance(source, target, sourceLength, targetLength)
		sourceLength = sourceLength or strlenutf8(source)
		targetLength = targetLength or strlenutf8(target)

		if sourceLength == 0 then
			return targetLength
		end

		if targetLength == 0 then
			return sourceLength
		end

		if source == target then
			return 0
		end

		InitializeMatrix(sourceLength, targetLength)

		for i = 1, sourceLength do
			for j = 1, targetLength do
				if ByteAt(source, i) == ByteAt(target, j) then
					matrix[i][j] = matrix[i - 1][j - 1]
				else
					local insertion = matrix[i][j - 1] + 1
					local deletion = matrix[i - 1][j] + 1
					local subsitution = matrix[i - 1][j - 1] + 1

					matrix[i][j] = math.min(insertion, deletion, subsitution)
				end
			end
		end

		return matrix[sourceLength][targetLength]
	end

	--- Calculate the upper bounds of the Levenshtein distance between two strings. The upper is either the length of the longest string, or the Hamming
	--- distance.
	---
	--- @param source string
	--- @param target string
	--- @param sourceLength integer?
	--- @param targetLength integer?
	--- @return integer
	function StringUtils:LevenshteinDistanceUpperBounds(source, target, sourceLength, targetLength)
		sourceLength = sourceLength or strlenutf8(source)
		targetLength = targetLength or strlenutf8(target)

		if sourceLength == targetLength then
			return self:HammingDistance(source, target, sourceLength, targetLength)
		end

		return sourceLength > targetLength and sourceLength or targetLength
	end
end

-- Hamming distance
do
	--- Calculate the Hamming distance between two strings of equal length. The Hamming distance is the number of positions at which the corresponding symbols
	--- are different.
	---
	--- https://en.wikipedia.org/wiki/Hamming_distance
	---
	---@param source string
	---@param target string
	---@param sourceLength integer?
	---@param targetLength integer?
	function StringUtils:HammingDistance(source, target, sourceLength, targetLength)
		sourceLength = sourceLength or strlenutf8(source)
		targetLength = targetLength or strlenutf8(target)

		if sourceLength ~= targetLength then
			return 99999
		end

		local distance = 0

		for i = 1, sourceLength do
			if ByteAt(source, i) ~= ByteAt(target, i) then
				distance = distance + 1
			end
		end

		return distance
	end
end

--- Calculate the average distance between two strings.
---
--- @param source string
--- @param target string
--- @param caseSensitive boolean?
--- @return number
function StringUtils:GetAverageDistance(source, target, caseSensitive)
	if not caseSensitive then
		source = string.lower(source)
		target = string.lower(target)
	end

	local results = {}
	local sourceLength = strlenutf8(source)
	local targetLength = strlenutf8(target)

	-- Performance optimization, this will make scoring less accurate if the source string is longer than the target string, but it will be much faster
	if sourceLength > targetLength then
		source = string.sub(source, 1, targetLength)
		sourceLength = targetLength
	end

	averageCache[source] = averageCache[source] or {}
	if averageCache[source][target] ~= nil then
		return averageCache[source][target]
	end

	do
		local distance = self:LevenshteinDistance(source, target, sourceLength, targetLength)
		local length = self:LevenshteinDistanceUpperBounds(source, target, sourceLength, targetLength)
		local weight = (distance == 0 and length == 0) and 0 or distance / length

		table.insert(results, weight)
	end

	do
		local subsequence = self:LongestCommonSubsequence(source, target, sourceLength, targetLength)
		local length = math.min(sourceLength, targetLength)
		local weight = 1 - (strlenutf8(subsequence) / length)

		table.insert(results, weight)
	end

	local average = GetAverage(results)
	averageCache[source][target] = average

	return average
end

--- Check if a string is approximately equal to another string.
---
--- @param source string
--- @param target string
--- @param caseSensitive boolean?
--- @param tolerance number?
--- @return boolean
function StringUtils:ApproximatelyEquals(source, target, caseSensitive, tolerance)
	tolerance = tolerance or 0.5

	local result = self:GetAverageDistance(source, target, caseSensitive)
	return result < tolerance
end

Addon.StringUtils = StringUtils
