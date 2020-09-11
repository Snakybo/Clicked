local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

function Clicked:GetDatabaseDefaults()
	return {
		profile = {
			version = nil,
			bindings = {},
			minimap = {
				hide = false
			}
		}
	}
end

-- Don't use any constants in this function to prevent breaking the updater
-- when the value of a constant changes. Always use direct values that are
-- read from the database.

function Clicked:UpgradeDatabaseProfile(profile)
	if profile.version == self.VERSION then
		return
	end

	-- If there are no bindings configured for the profile
	-- it's likely new. In any case there's nothing to upgrade
	-- so don't bother trying.
	if #profile.bindings == 0 then
		profile.version = self.VERSION
		return
	end

	-- version 0.4.x to 0.5.0
	do
		-- Versions prior to 0.5.0 didn't have a version number serialized,
		-- so all (and only) old profiles won't have a version field, and
		-- we can safely assume the profile is from 0.4.0 or older
		if profile.version == nil or self:StartsWith(profile.version, "0.4") then
			for _, binding in ipairs(profile.bindings) do
				if #binding.targets > 0 and binding.targets[1].unit == "GLOBAL" then
					binding.targetingMode = "GLOBAL"
					binding.targets = {
						self:GetNewBindingTargetTemplate()
					}
				else
					binding.targetingMode = "DYNAMIC_PRIORITY"
				end

				binding.load.inGroup = {
					selected = false,
					state = "IN_GROUP_PARTY_OR_RAID"
				}

				binding.load.playerInGroup = {
					selected = false,
					player = ""
				}
			end

			print(L["MSG_PROFILE_UPDATED"]:format(profile.version or "UNKNOWN", "0.5.0"))
			profile.version = "0.5.0"
		end
	end

	-- version 0.5.x to 0.6.0
	do
		if self:StartsWith(profile.version, "0.5") then
			for _, binding in ipairs(profile.bindings) do
				binding.load.stance = {
					selected = 0,
					single = 1,
					multiple = {
						1
					}
				}

				binding.load.talent = {
					selected = 0,
					single = 1,
					multiple = {
						1
					}
				}
			end

			print(L["MSG_PROFILE_UPDATED"]:format(profile.version, "0.6.0"))
			profile.version = "0.6.0"
		end
	end

	profile.version = self.VERSION
end
