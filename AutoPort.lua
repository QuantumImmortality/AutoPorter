local ActiveKeyTerms = {"org", "uc", "orgrimmar", "undercity", "orgrimar", "ogrimar", "og"} --Default
Portal_EventFrame = CreateFrame("Frame")

function load()
	local _, _, classIndex = UnitClass("player");
	
	if classIndex == 8 then--Mage
		createZoneListener()
		afkChecker()
		initialise()
	end
end

function initialise() 

	Portal_EventFrame:RegisterEvent("CHAT_MSG_SAY")
	Portal_EventFrame:RegisterEvent("CHAT_MSG_YELL")
	Portal_EventFrame:RegisterEvent("CHAT_MSG_WHISPER")

	Portal_EventFrame:SetScript("OnEvent", ChatMessageEvent)
end

function ChatMessageEvent(states,event,message,sender,_,_,_,_,_,_,_,_,_,guid)
    if message then
        local message, phrase = string.lower(message)
        for _, details in pairs(ActiveKeyTerms) do
            phrase = message:match("%f[%a]"..details.."%f[%A]")
            if phrase then 
            	InviteUnit(sender)
            	print(Ambiguate(sender, "all") .. ": " .. string.upper(phrase))
                break
                --[[states[guid] = {
                    show = true,
                    changed = true,
                    icon = details.icon,
                    text = details.text,
                    sender = Ambiguate(sender, "all"),
                    joined = false, 
                    duration = aura_env.config.timeOut,
                    autoHide = true,
                }
                return true --]]
            end
        end
    end
end
--[[

	Org = 1454
	Durotar = 1411
	Mulgore = 1412
	Thunderbluff = 1456
	Undercity = 1458	
	STV = 1434	
	Burning Steppes = 1428
	Duskwood = 1431
	Elwyn Forest = 1429
	Redridge Mountains = 1433
	Searing Gorge = 1427
	Badlands = 1415
--]]	

-- "switch" statement of options to prevent reacting to people calling the main city they and you are already in
--TB to added to rest once level > 50
local zone_actions = {
	[1415] = function() --Badlands
				ActiveKeyTerms = {"org", "uc", "orgrimmar", "undercity", "orgrimar", "ogrimar", "og"}
			end,
	[1454] = function() --Org
				ActiveKeyTerms = {"uc", "undercity"}
			end,
	[1456] = function() --TB
				ActiveKeyTerms = {"org", "uc", "orgrimmar", "undercity", "orgrimar", "ogrimar", "og"}
			end,
	[1458] = function() --UC
				ActiveKeyTerms = {"org", "orgrimmar", "orgrimar", "ogrimar", "og"}
			end
}


function createZoneListener()
  	local Zone_EventFrame = CreateFrame("Frame")
  	Zone_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

  	setDefault(zone_actions, function() print("default") end)

  	Zone_EventFrame:SetScript("OnEvent",
  		function (self, event, ...)
			local mapID = C_Map.GetBestMapForUnit("player")
			print(mapID)
			zone_actions[mapID]()
		end
	)
end

function setDefault (t, d)
	t.___ = d
	setmetatable(t, {__index = function (t) return t.___ end})
end

--Accessable Icon of LDB
local Paused = false

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("AutoPort", {
	type = "launcher",
	icon = "Interface\\Icons\\Spell_Nature_StormReach",
	OnClick = function(clickedframe, button)
		if Paused then
			print("------- Auto Port UNPAUSED -------")
			Paused = false
			Portal_EventFrame:SetScript("OnEvent", ChatMessageEvent)
		else
			print("------- Auto Port PAUSED -------")
			Portal_EventFrame:SetScript("OnEvent", function()end)
			Paused = true			
		end
	end,
})

function afkChecker()	
	local AFK_EventFrame = CreateFrame("Frame")
  	AFK_EventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
  	AFK_EventFrame:SetScript("OnEvent",
  		function (self, event, ...)
  			if UnitIsAFK("player") then
				print("------- Auto Port AFK PAUSED -------")
  				Portal_EventFrame:SetScript("OnEvent", function()end)
  			else
  				Portal_EventFrame:SetScript("OnEvent", ChatMessageEvent)
				print("------- Auto Port AFK UNPAUSED -------")
			end
		end
	)
end