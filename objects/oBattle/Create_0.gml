instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitBattleOrder = [];


//エネミー作成
for (var i = 0; i < array_length(enemies); i++)
{
    enemyUnits[i] = instance_create_depth(x + 250 + (i * 10), y + 68 + (i * 20), depth - 10, oBattleUnitEnemy, enemies[i]);
    array_push(units, enemyUnits[i]);
}

//パーティー作成
for (var i = 0; i < array_length(global.party); i++)
{
    partyUnits[i] = instance_create_depth(x + 70 + (i * 10), y + 68 + (i * 15), depth - 10, oBattleUnitPC, global.party[i]);
    array_push(units, partyUnits[i]);
}

//shuffle turn order
unitTurnOrder = array_shuffle(units);

//get render order
RefreshRenderOrder = function()
{
    unitRenderOrder = [];
    array_copy(unitRenderOrder, 0, units, 0, array_length(units));
    array_sort(unitRenderOrder, function(_1, _2)
    {
        return _1.y - _2.y;
    });
}
RefreshRenderOrder();