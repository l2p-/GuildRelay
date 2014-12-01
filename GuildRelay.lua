
local frame = CreateFrame("FRAME", "GuildRelay");
frame:RegisterEvent("MAIL_SHOW");
local function initiateRelay(self, event, ...)
	DEFAULT_CHAT_FRAME:AddMessage("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 1, 1, 1);
end
frame:SetScript("OnEvent", initiateRelay);

local function isRelayMaster()
	-- some logic here
	return true;
end

local function relayMessage()
	DEFAULT_CHAT_FRAME:AddMessage("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 1, 1, 1);
	-- some logic here
end
