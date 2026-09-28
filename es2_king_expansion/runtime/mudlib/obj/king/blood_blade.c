#include <weapon.h>

inherit F_BLADE;

void create()
{
    set_name("靈刀祭血", ({ "blood blade", "blade" }));
    set_weight(4000);
    // ES2tips Historical Evidence：8-41 / 力量修正90% / 乘數等級3。
    // Original identify.c：min=roll+multiplier；max=roll+multiplier*range，
    // 因此可還原為 setup_blade(3,12,90,5)。
    setup_blade(3, 12, 90, 5);

    if (!clonep()) {
        set("wield_as", "blade");
        set("unit", "把");
        set("value", 0);
        set("rigidity", 20);
        set("es2_king/owner_weapon", 1);
        set("es2_king/evidence", "HISTORICAL CONFIRMED / ES2tips 2013-05");
        set("long", "一把血紅的單刀，刀輕質硬，色呈紅色半透明。\n");
        // Historical：大邪七損刀訣 +10、拆招卸力之法 +10。
        // KING 現行 Runtime 的大邪七損刀正式 ID 為 qisun_blade；parry 為 Original base skill。
        set("apply_weapon/blade", ([
            "qisun_blade": 10,
            "parry": 10,
        ]));
    }
    setup();
}
