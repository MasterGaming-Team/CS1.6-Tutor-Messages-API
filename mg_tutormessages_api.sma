#include <amxmodx>
#include <amxmisc>
#include <mg_levelsystem_api>
#include <mg_missions_api>
#include <mg_tutormessages_api_const>

#define PLUGIN "[MG] Tutor Messages API"
#define VERSION "1.0.0"
#define AUTHOR "Vieni"

#define TASKID_TUTOR	1

#define TUTORTEXTSIZE	120

new Array:arrayTutorMessageText[33]
new Array:arrayTutorMessageType[33]
new Array:arrayTutorMessageTime[33]
new Array:arrayTutorMessageSFX[33]

new gMsgTutorStart
new gMsgTutorClose

new const tutorResources[][] =
{
	"gfx/career/icon_!.tga",
	"gfx/career/icon_!-bigger.tga",
	"gfx/career/icon_i.tga",
	"gfx/career/icon_i-bigger.tga",
	"gfx/career/icon_skulls.tga",
	"gfx/career/round_corner_ne.tga",
	"gfx/career/round_corner_nw.tga",
	"gfx/career/round_corner_se.tga",
	"gfx/career/round_corner_sw.tga",
	"resource/TutorScheme.res",
	"resource/UI/TutorTextWindow.res"
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

	gMsgTutorStart = get_user_msgid("TutorText")
	gMsgTutorClose = get_user_msgid("TutorClose")
}

public plugin_natives()
{
	register_native("mg_tutormessage_send", "native_send")
	register_native("mg_tutormessage_clear", "native_clear")
}

public plugin_precache()
{
    for(new i; i < sizeof(tutorResources); i++)
        precache_generic(tutorResources[i])
}

public check_tutor_messagelist(taskid)
{
	new id = taskid-TASKID_TUTOR

	if(!is_user_connected(id))
		return
	
	new lArraySize = ArraySize(arrayTutorMessageType)

	if(lArraySize == 0)
	{
		userRemoveTutorMessage(id)
		return
	}

	new lText[64]
	ArrayGetString(arrayTutorMessageText, 0, lText, charsmax(lText))
	new lType = ArrayGetCell(arrayTutorMessageType, 0)
	new Float:lTime = ArrayGetCell(arrayTutorMessageTime, 0)
	new lSoundEffect[64]
	ArrayGetString(arrayTutorMessageSFX, 0, lSoundEffect, charsmax(lSoundEffect))

	userSetTutorMessage(id, lText, lType)
	userPlaySound(id, lSoundEffect)

	ArrayDeleteItem(arrayTutorMessageText, 0)
	ArrayDeleteItem(arrayTutorMessageType, 0)
	ArrayDeleteItem(arrayTutorMessageTime, 0)
	ArrayDeleteItem(arrayTutorMessageSFX, 0)

	set_task(lTime, "check_tutor_messagelist", taskid)
}

public native_send(plugin_id, param_num)
{
	new id = get_param(1)
	
	if(!is_user_connected(id))
		return false
	
	new lText[TUTORTEXTSIZE]
	get_string(2, lText, charsmax(lText))
	new lType = get_param(3)
	new Float:lTime = get_param_f(4)
	new lSoundEffect[64]
	get_string(5, lSoundEffect, charsmax(lSoundEffect))
	new lPrimary = get_param(6)
	new lImmediately = get_param(7)

	if(task_exists(TASKID_TUTOR+id))
	{
		if(lPrimary)
		{
			if(lImmediately)
			{
				remove_task(TASKID_TUTOR+id)
				userSetTutorMessage(id, lText, lType)
				userPlaySound(id, lSoundEffect)
				set_task(lTime, "check_tutor_messagelist", TASKID_TUTOR+id)

				return true
			}

			if(ArraySize(arrayTutorMessageType) == 0)
			{
				ArrayPushString(arrayTutorMessageText, lText)
				ArrayPushCell(arrayTutorMessageType, lType)
				ArrayPushCell(arrayTutorMessageTime, lTime)
				ArrayPushString(arrayTutorMessageSFX, lSoundEffect)

				return true
			}
			else
			{
				ArrayInsertStringBefore(arrayTutorMessageText, 0, lText)
				ArrayInsertCellBefore(arrayTutorMessageType, 0, lType)
				ArrayInsertCellBefore(arrayTutorMessageTime, 0, lTime)
				ArrayInsertStringBefore(arrayTutorMessageSFX, 0, lSoundEffect)

				return true
			}
		}
		else
		{
			if(lImmediately)
			{
				remove_task(TASKID_TUTOR+id)
				userSetTutorMessage(id, lText, lType)
				userPlaySound(id, lSoundEffect)
				set_task(lTime, "check_tutor_messagelist", TASKID_TUTOR+id)

				return true
			}

			ArrayPushString(arrayTutorMessageText, lText)
			ArrayPushCell(arrayTutorMessageType, lType)
			ArrayPushCell(arrayTutorMessageTime, lTime)
			ArrayPushString(arrayTutorMessageSFX, lSoundEffect)
			return true
		}
	}
	else
	{
		ArrayPushString(arrayTutorMessageText, lText)
		ArrayPushCell(arrayTutorMessageType, lType)
		ArrayPushCell(arrayTutorMessageTime, lTime)
		ArrayPushString(arrayTutorMessageSFX, lSoundEffect)

		check_tutor_messagelist(TASKID_TUTOR+id)

		return true
	}	
}

public native_clear(plugin_id, param_num)
{
	new id = get_param(1)

	if(!is_user_connected(id))
		return false

	userRemoveTutorMessage(id)

	return true
}

public mg_fw_client_levelup(id, level)
{
	
}

public mg_fw_client_mission_done(id, missionId)
{

}

public client_putinserver(id)
{
	arrayTutorMessageText[id] = ArrayCreate(TUTORTEXTSIZE)
	arrayTutorMessageType[id] = ArrayCreate(1)
	arrayTutorMessageTime[id] = ArrayCreate(1)
	arrayTutorMessageSFX[id] = ArrayCreate(64)
}

public client_disconnected(id)
{
	ArrayDestroy(arrayTutorMessageText[id])
	ArrayDestroy(arrayTutorMessageType[id])
	ArrayDestroy(arrayTutorMessageTime[id])
	ArrayDestroy(arrayTutorMessageSFX[id])
}

userPlaySound(id, const sound[])
{
	client_cmd(id, "spk ^"%s^"", sound)
}

userSetTutorMessage(id, const text[], type = (1<<3))
{
	message_begin(MSG_ONE, gMsgTutorStart, _, id)
	write_string(text)
	write_byte(0)
	write_short(0)
	write_short(0)
	write_short(type)// 1 - RED[SKULL], 2 - BLUE[SKULL], 3 - YELLOW[INFO], 4 - GREEN[INFO]
	message_end()
}

userRemoveTutorMessage(id)
{
	message_begin(MSG_ONE, gMsgTutorClose, _, id)
	message_end()
}