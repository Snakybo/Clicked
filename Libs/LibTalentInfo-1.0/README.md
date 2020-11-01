# LibTalentInfo-1.0

A library that can retrieve (PvP) talent info for any specialization.

## Examples

### Get talent info for the current spec

```lua
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

local specID = GetSpecializationInfo(GetSpecialization())
local _, name = LibTalentInfo:GetTalentInfo(specID, 1, 1)

print(name)
```

### Get talent info for a different class

```lua
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

local class = "WARRIOR" -- non-localized class identifier
local specs = LibTalentInfo:GetClassSpecIDs(class) -- Follows the order as they appear in-game, so specs[1] will be specID for Arms

for i = 1, #specs do
	local specID = specs[i]

	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local _, name = LibTalentInfo:GetTalentInfo(specID, tier, column)

			print(specID .. ": " .. name)
		end
	end
end
```

### Get talent info from all classes

```lua
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

for class, specs in LibTalentInfo:AllClasses() do
	print("===" .. class .. "===")

	for i = 1, #specs do
		local specID = specs[i]

		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local _, name = LibTalentInfo:GetTalentInfo(specID, tier, column)

				print(specID .. ": " .. name)
			end
		end
	end
end
```

### Get PvP talent info for a spec

```lua
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

local specs = LibTalentInfo:GetClassSpecIDs("WARRIOR")

for i = 1, #specs do
	local specID = specs[i]
	local numTalents = LibTalentInfo:GetNumPvPTalentsForSpec(specID, 1)

	for j = 1, numTalents do
		local _, name = LibTalentInfo:GetPvPTalentInfo(specID, 1, j)

		print(specID .. ": " .. name)
	end
end
```
