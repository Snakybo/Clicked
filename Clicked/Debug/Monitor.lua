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

--- @class PerformanceMonitorSegment
--- @field public start number
--- @field public duration number

--- @class PerformanceMonitorSegmentResult
--- @field public total number
--- @field public min number
--- @field public max number
--- @field public mean number
--- @field public count number
--- @field public percentage? number
--- @field public _fmt? string

--- @class PerformanceMonitorResult : table<string, PerformanceMonitorSegmentResult>
--- @field public total number

--- @type number
local start = 0

--- @type number
local duration = 0

--- @type table<string, PerformanceMonitorSegment[]>
local segments = {}

--- @class PerformanceMonitor
local Prototype = {}

function Prototype.Restart()
	start = debugprofilestop()
	duration = 0
	wipe(segments)
end

--- @return number
function Prototype.Stop()
	if duration == 0 then
		duration = debugprofilestop() - start
	end

	return duration
end

--- @return number
function Prototype.GetDuration()
	return duration
end

--- @return PerformanceMonitorResult
function Prototype.GetResult()
	Prototype.Stop()

	local result = Prototype.GetSegments()

	if duration > 0 then
		for _, segment in pairs(result) do
			segment.percentage = math.floor(segment.total / duration * 100)
			segment._fmt = "{total:.2f}ms {percentage}% (x{count} {min:.2f}ms-{max:.2f}ms ±{mean:.2f}ms)"
		end
	end

	result.total = duration

	return result
end

--- @param name string
function Prototype.StartSegment(name)
	--- @type PerformanceMonitorSegment[]
	local stack = segments[name] or {}
	if stack[name] == nil then
		segments[name] = stack
	end

	--- @type PerformanceMonitorSegment
	stack[#stack + 1] = {
		start = debugprofilestop(),
		duration = 0
	}
end

--- @param name string
--- @return number
function Prototype.StopSegment(name)
	local stack = segments[name]
	if stack == nil then
		return 0
	end

	local segment = stack[#stack]
	segment.duration = debugprofilestop() - segment.start

	return segment.duration
end

--- @param name string
--- @return PerformanceMonitorSegmentResult?
function Prototype.GetSegment(name)
	local stack = segments[name]
	if stack == nil then
		return nil
	end

	local result = {
		total = 0,
		min = math.huge,
		max = 0,
		count = #stack
	}

	for i = 1, #stack do
		local segment = stack[i]
		local elapsed = segment.duration == 0 and (debugprofilestop() - segment.start) or segment.duration

		result.total = result.total + elapsed
		result.min = math.min(result.min, elapsed)
		result.max = math.max(result.max, elapsed)
	end

	result.mean = result.total / result.count
	return result
end

--- @return table<string, PerformanceMonitorSegmentResult>
function Prototype.GetSegments()
	local result = {}

	for name in pairs(segments) do
		result[name] = Prototype.GetSegment(name)
	end

	return result
end

Addon.Perf = Prototype
