#include <weapon.h>

inherit F_STAFF;

void create()
{
    set_name("九曲十彎", ({ "god cane", "cane", "staff" }));
    set_weight(6000);
    // ES2tips Historical Evidence：twohanded staff 13-82 / 225% / multiplier 3。
    // Original setup_staff 對 twohanded staff 轉換為 x+1、y*3/2、z*3/2；
    // 反推 Original base parameters 為 setup_staff(2,16,150,10)。
    setup_staff(2, 16, 150, 10);

    if (!clonep()) {
        set("wield_as", "twohanded staff");
        set("unit", "根");
        set("value", 0);
        set("rigidity", 20);
        set("es2_king/owner_weapon", 1);
        set("es2_king/evidence", "HISTORICAL CONFIRMED / ES2tips");
        set("long", "青邪宮殘蟻師太所創的獨門兵器，是一根奇形怪狀的彎曲拐杖。\n");
        set("apply_weapon/twohanded staff", ([
            "cps": 3,
            "str": 3,
            "con": 3,
            "wis": 3,
        ]));
    }
    setup();
}
