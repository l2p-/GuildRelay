local COMM_PREFIX = "GuildRelay";
local COMM_ASK_FOR_MASTER = "WhoIsMaster";
local COMM_I_AM_MASTER = "IAmMaster:";
local COMM_ID_CHECK_PREFIX = "IdCheck:";

local debugMode = true;
local clientId = 0;
local relayMaster = nil;
local relayMasterId = 0;
local playerName = nil;

local relayChannelName = "GuildRelay";
local isInititalized = false;

RegisterAddonMessagePrefix(COMM_PREFIX);

local function debugMessage(message)
	if debugMode then
		DEFAULT_CHAT_FRAME:AddMessage(">GuildRelay DEBUG< " .. message, 1, 1, 1);
	end
end

local function isRelayMaster()
	if relayMaster == GetUnitName("player", false) then
		debugMessage("This client is relay master");
		return true;
	else
		debugMessage("This client is not relay master");
		return false;
	end
end

local function sendAddonBroadcast(message)
	SendAddonMessage(COMM_PREFIX, message, "GUILD");
end

local function sendAddonWhisper(message, target)
	SendAddonMessage(COMM_PREFIX, message, "WHISPER", target);
end

local function setDebugMode(mode)
	debugMode = mode;
	debugMessage("Set debug mode to " .. debugMode);
end

local function initalize()
	debugMessage("Initializing GuildRelay channels");

	clientId = GetTime() * 1000;

	JoinTemporaryChannel(relayChannelName);

	sendAddonBroadcast(COMM_ASK_FOR_MASTER);
	relayMaster = GetUnitName("player", false);
	relayMasterId = clientId;

	isInititalized = true;
end

local function setRelayChannel(channelName)
	LeaveChannelByName(relayChannelName);
	relayChannelName = channelName;
	JoinTemporaryChannel(relayChannelName);

	debugMessage("Set relay channel to " .. relayChannelName);
end

local frame = CreateFrame("FRAME");
frame:RegisterEvent("CHAT_MSG_GUILD");
local function relayMessage(self, event, ...)

	if not isInititalized then
		initalize();
	end

	debugMessage("Recieved chat message to relay");

	unitName, unitRealm = UnitName("player");
	playerName = unitName .. "-" .. GetRealmName();

	message, author, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, lineId, senderGuid = ...;
	if isRelayMaster() then
		number, name, id = GetChannelName(relayChannelName);
		SendChatMessage("[" .. author .. "]: " .. message ,"CHANNEL" ,nil ,number);
	end
end
frame:SetScript("OnEvent", relayMessage);

local frame1 = CreateFrame("FRAME");
frame1:RegisterEvent("PLAYER_LOGIN");
local function initiateRelay(self, event, ...)
	DEFAULT_CHAT_FRAME:AddMessage("GuildRelay loaded", 1, 1, 1);
end
frame1:SetScript("OnEvent", initiateRelay);

local frame2 = CreateFrame("FRAME");
frame2:RegisterEvent("CHAT_MSG_ADDON");
local function handleComm(self, event, ...)
	prefix, message, channel, sender = ...;

	if prefix == COMM_PREFIX then

		if message == COMM_ASK_FOR_MASTER then
			debugMessage(COMM_ASK_FOR_MASTER);
			if not (sender == playerName) then
				debugMessage("sender: " .. sender .. " playerName: " .. playerName);
				if isRelayMaster() then
					sendAddonBroadcast(COMM_I_AM_MASTER .. clientId);
				end
			end

		elseif string.sub(message, 1, string.len(COMM_I_AM_MASTER)) == COMM_I_AM_MASTER then
			if not (sender == playerName) then
				relayMaster = sender;
				relayMasterId = tonumber(string.sub(message, string.len(COMM_I_AM_MASTER) + 1));
			end

		elseif string.sub(message, 1, string.len(COMM_ID_CHECK_PREFIX)) == COMM_ID_CHECK_PREFIX then
			if not (sender == playerName) then
				if tonumber(string.sub(message, string.len(COMM_ID_CHECK_PREFIX) + 1)) > relayMasterId then
					relayMaster = sender;
					relayMasterId = tonumber(string.sub(message, string.len(COMM_ID_CHECK_PREFIX) + 1));
				end
			end
		end

		debugMessage("Addon message: " .. prefix .. message .. channel .. sender);
	end
end
frame2:SetScript("OnEvent", handleComm);

local frame3 = CreateFrame("FRAME");
frame3:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE");
local function onChannelEvent(self, event, ...)
	debugMessage("channel event detected: " .. event);

	arg1, name, arg3, channel, arg5, arg6, arg7, channelNumber, channelName = ...;

	if channelName == relayChannelName then
		debugMessage("Someone left the GuildRelay channel");

		if name == relayMaster then
			debugMessage("Relay Master left");
			sendAddonBroadcast(COMM_ID_CHECK_PREFIX .. clientId);

			relayMaster = GetUnitName("player", false);
			relayMasterId = clientId;
		end
	end
end
frame3:SetScript("OnEvent", onChannelEvent);

SLASH_GUILDRELAY1 = "/guildrelay";
SLASH_GUILDRELAY2 = "/gry";
function SlashCmdList.GUILDRELAY(message, editbox)
	local command, rest = message:match("^(%S*)%s*(.-)$");
	debugMessage("slash command detected: Command: " .. command .. " - rest: " .. rest);

	if command == "setdebug" then

		debugMessage("valid command: " .. command);

		if rest == "true" then
			setDebugMode(true);
		elseif rest == "false" then
			setDebugMode(false);
		end
	elseif command == "dump" then
		debugMessage("valid command: " .. command);
		DEFAULT_CHAT_FRAME:AddMessage("debugMode: " .. tostring(debugMode), 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("clientId: " .. clientId, 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("relayMaster: " .. tostring(relayMaster), 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("relayMasterId: " .. relayMasterId, 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("relayChannelName: " .. relayChannelName, 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("isInitialized: " .. tostring(isInititalized), 1, 1, 1);
		DEFAULT_CHAT_FRAME:AddMessage("playerName: " .. tostring(playerName), 1, 1, 1);
	else
		DEFAULT_CHAT_FRAME:AddMessage("\"" .. command .. "\" - " .. "Invalid command", 1, 1, 1);
	end
end

--[[
local function updateIsRelayMaster()

if not isInititalized then
initalize();
end

debugMessage("Updating relay master");

channelNumber, channelName, instanceID = GetChannelName(syncChannelName);

channelNumber = channelNumber + 3;
print(GetNumDisplayChannels());
name, owner, moderator, muted, active, enabled = GetChannelRosterInfo(channelNumber, 1);

if name == GetUnitName("player", false) then
isRelayMaster = true;
debugMessage("This client is now relay master");
end
end
--]]
