#include <amxmodx>
#include <amxmisc>
#include <mg_tutormessages_api_const>

#define PLUGIN "[MG] Tutor Messages API"
#define VERSION "1.0.0"
#define AUTHOR "Vieni"

#define TASKID_TUTOR	1

#define TUTORTEXTSIZE	120

new Array:arrayTutorMessageText
new Array:arrayTutorMessageType
new Array:arrayTutorMessageTime

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
	arrayTutorMessageText = ArrayCreate(TUTORTEXTSIZE)
	arrayTutorMessageType = ArrayCreate(1)
	arrayTutorMessageTime = ArrayCreate(1)

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

}

public native_send(plugin_id, param_num)
{
	new id = get_param(1)
	
	if(!is_user_connected(id))
		return false
	
	new lText[TUTORTEXTSIZE]
	get_string(2, lText, charsmax(lText))
	new lType = get_param(3)
	new lTime = get_param(4)
	new lPrimary = get_param(5)
	new lImmediately = get_param(6)

	if(task_exists(TASKID_TUTOR+id))
	{
		if(lPrimary)
		{
			if(lImmediately)
			{
				remove_task(TASKID_TUTOR+id)
				userSetTutorMessage(id, lText, lType)
				set_task(lTime, "check_tutor_messagelist", TASKID_TUTOR+id)

				return true
			}

			if(ArraySize(arrayTutorMessageType) == 0)
			{
				ArrayPushString(arrayTutorMessageText, lText)
				ArrayPushCell(arrayTutorMessageType, lType)
				ArrayPushCell(arrayTutorMessageTime, lTime)

				return true
			}
			else
			{
				ArrayInsertStringBefore(arrayTutorMessageText, 0, lText)
				ArrayInsertCellBefore(arrayTutorMessageType, 0, lType)
				ArrayInsertCellBefore(arrayTutorMessageTime, 0, lTime)

				return true
			}
		}
		else
		{
			if(lImmediately)
			{
				remove_task(TASKID_TUTOR+id)
				userSetTutorMessage(id, lText, lType)
				set_task(lTime, "check_tutor_messagelist", TASKID_TUTOR+id)

				return true
			}

			ArrayPushString(arrayTutorMessageText, lText)
			ArrayPushCell(arrayTutorMessageType, lType)
			ArrayPushCell(arrayTutorMessageTime, lTime)
			return true
		}
	}
	else
	{
		ArrayPushString(arrayTutorMessageText, lText)
		ArrayPushCell(arrayTutorMessageType, lType)
		ArrayPushCell(arrayTutorMessageTime, lTime)

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