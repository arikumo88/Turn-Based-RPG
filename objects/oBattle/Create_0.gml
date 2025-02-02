instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];

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
    partyUnits[i] = instance_create_depth(x + 70 - (i * 10), y + 68 + (i * 15), depth - 10, oBattleUnitPC, global.party[i]);
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
    //BeginAction(_unit.id, global.actionLibrary.attack, _unit.id);
    
    //if unit is player controlled
    if (_unit.object_index == oBattleUnitPC)
    {
        //ランダムなパーティーメンバーに攻撃
        var _action = global.actionLibrary.attack;
        var _possibleTargets = array_filter(oBattle.enemyUnits, function(_unit, _index)
        {
        return (_unit.hp > 0); 
        });
        var _target = _possibleTargets[irandom(array_length(_possibleTargets) - 1)];
        BeginAction(_unit.id, _action, _target);
    }
    else
    {
        //ユニットがAI制御の場合
        var _enemyAction = _unit.AIscript();
        if (_enemyAction != -1) BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
    }
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
        if (!is_undefined(_action[$ "userAnimation"])) && (!is_undefined(_user.sprites[$ _action.userAnimation]))
        {
            sprite_index = sprites[$ _action.userAnimation];
            image_index = 0;
        }
    }
    battleState = BattleStatePerformAction;
}

function BattleStatePerformAction()
{
    //アニメーション再生中の場合
    if (currentUser.acting)
    {
        //終了時、アクションエフェクトを実行する
        if (currentUser.image_index >= currentUser.image_number -1)
        {
            with (currentUser)
            {
                sprite_index = sprites.idle;
                image_index = 0;
                acting = false;
            }
            
            if (variable_struct_exists(currentAction, "effectSprite"))
            {
                if (currentAction.effectOnTarget == MODE.ALWAYS) || ((currentAction.effectOnTarget == MODE.VARIES) && (array_length(currentTargets) <= 1))
                {
                    for (var i = 0; i < array_length(currentTargets); i++)
                    {
                        instance_create_depth(currentTargets[i].x, currentTargets[i].y, currentTargets[i].depth - 1, oBattleEffect,{
                            sprite_index: currentAction.effectSprite});
                    }
                }
                else //play it at 0,0
                {
                    var _effectSprite = currentAction._effectSprite
                    if (variable_struct_exists(currentAction, "effectSpriteNoTarget")) _effectSprite = currentAction.effectSpriteNoTarget;
                        instance_create_depth(x, y, depth - 100, oBattleEffect,{
                        sprite_index: _effectSprite});
                }
            }
            currentAction.func(currentUser, currentTargets);
        }
    }
    else //ディレイ待ちとターン終了
    {
        if (!instance_exists(oBattleEffect))
        {
            battleWaitTimeRemaining--
            if (battleWaitTimeRemaining == 0)
            {
                battleState = BattleStateVictoryCheck;
            }
        }
    }
}

function BattleStateVictoryCheck()
{
    battleState = BattleStateTurnProgression;
}

function BattleStateTurnProgression()
{
    turnCount++;
    turn++;
    //ターンのループ
    if (turn > array_length(unitTurnOrder) - 1)
    {
        turn = 0;
        roundCount++;
    }
    battleState = BattleStateSelectAction;
}

battleState = BattleStateSelectAction;
