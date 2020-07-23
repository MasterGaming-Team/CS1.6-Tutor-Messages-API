#include <amxmodx>
#include <amxmisc>

#define PLUGIN "[MG] Tutor Messages API"
#define VERSION "1.0.0"
#define AUTHOR "Vieni"

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
}

public plugin_precache()
{
    for(new i; i < sizeof(tutorResources); i++)
        precache_generic(tutorResources[i])
}