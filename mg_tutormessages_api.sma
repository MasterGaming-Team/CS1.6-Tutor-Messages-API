#include <amxmodx>
#include <amxmisc>
#include <mg_tutormessages_api_const>

#define PLUGIN "[MG] Tutor Messages API"
#define VERSION "1.0.0"
#define AUTHOR "Vieni"

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

public plugin_precache()
{
    for(new i; i < sizeof(tutorResources); i++)
        precache_generic(tutorResources[i])
}

public userSetTutorMessage(id, const text[], type = (1<<3))
{
	message_begin(MSG_ONE, gMsgTutorStart, _, id)
	write_string(text)
	write_byte(0)
	write_short(0)
	write_short(0)
	write_short(type)// 1 - RED[SKULL], 2 - BLUE[SKULL], 3 - YELLOW[INFO], 4 - GREEN[INFO]
	message_end()
}

public userRemoveTutorMessage(id)
{
	message_begin(MSG_ONE, gMsgTutorClose, _, id)
	message_end()
}