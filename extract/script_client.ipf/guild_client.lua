---- guild_lua.lua

function CLIENT_GUILD_GOTO_SKILL(skillType)

	local frame = ui.GetFrame("guildmembergo");
	frame:ShowWindow(1);
	GUILDMEMBER_GO_UPDATE_MEMBERLIST(frame, skillType);

end

function CLIENT_GUILD_CALL_SKILL(skillType)

	local frame = ui.GetFrame("guildmembercall");
	frame:ShowWindow(1);
	GUILDMEMBER_GO_UPDATE_MEMBERLIST(frame, skillType);

end

--EVENT_2010_GUILD
function EVENT_2010_GUILD_QUEST_REWARD_C()
	ui.MsgBox(ClMsg("EVENT_2010_GUILD_REWARD_CONFIRM"), "_EVENT_2010_GUILD_QUEST_REWARD_C", "None");
end

function _EVENT_2010_GUILD_QUEST_REWARD_C()
    pc.ReqExecuteTx("EVENT_2010_GUILD_QUEST_REWARD","None")
end

function EVENT_2010_GUILD_QUEST_REWARD_PC_C()
	ui.MsgBox(ClMsg("EVENT_2010_GUILD_REWARD_CONFIRM"), "_EVENT_2010_GUILD_QUEST_REWARD_PC_C", "None");
end

function _EVENT_2010_GUILD_QUEST_REWARD_PC_C()
    pc.ReqExecuteTx("EVENT_STEAM_GUILD_REWARD_PC","None")
end