instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitBattleOrder = [];

turnCount = 0;
roundCount = 0;
battleWaitTimeFrames = 30;
battleWaitTimeRemaining = 0;
currentUser = noone;
currentAction = -1;
currentTargets = noone;


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

function BattleStateSelectAction()
{
    //現在のユニットを取得
    var _unit = unitTurnOrder[turn];
    
    //ユニットが行動可能か確認
    if (!instance_exists(_unit)) || (_unit.hp <= 0)
    {
        battleState = BattleStateVictoryCheck;
        exit;
    }
    
    //実行するアクションを選択
    BeginAction(_unit.id, global.actionLibrary.attack, _unit.id);
}

function BeginAction(_user, _action, _targets)
{
    currentUser = _user;
    currentAction = _action;
    currentTargets = _targets;
    if (!is_array(currentTargets)) currentTargets = [currentTargets];
        battleWaitTimeRemaining = battleWaitTimeFrames;
    with (_user)
    {
        acting = true;
        //アニメーションを再生
        if (!is_undefined(_action[$ "userAnimation"])) && (is_undefined(_user.sprites[$ _action.userAnimation]))
        {
            sprite_index = sprites[$ _action.userAnimation];
            image_index = 0;
        }
    }
    battleState = BattleStatePerformAction;
}

function BattleStatePerformAction()
{
}

function BattleStateVictoryCheck()
{
}

function BattleStateTurnProgression()
{
}

battleState = BattleStateSelectAction;
