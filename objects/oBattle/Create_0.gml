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
    if (!instance_exists(oMenu))
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
            var _menuOptions = [];
            var _subMenus = {};
            
            var _actionList = _unit.actions;
            
            for (var i = 0; i < array_length(_actionList); i++)
            {
                var _action = _actionList[i];
                var _available = true; //後でMPチェックを実施する
                var _nameAndCount = _action.name; //後でアイテムアクションを実装する
                if (_action.subMenu == -1)
                {
                    array_push(_menuOptions, [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
                }
                else
                {
                    //create or add to a submenu
                    if (is_undefined(_subMenus[$ _action.subMenu]))
                    {
                        variable_struct_set(_subMenus, _action.subMenu, [[_nameAndCount, MenuSelectAction, [_unit, _action], _available]]);
                    }
                    else
                    {
                        array_push(_subMenus[$ _action.subMenu], [_nameAndCount, MenuSelectAction, [_unit, _action], _available]);
                    }
                }
                
                //turn sub menus into an array
                var _subMenusArray = variable_struct_get_names(_subMenus);
                for (var i = 0; i < array_length(_subMenusArray); i++)
                {
                    //sort submenu if needed
                    //
                    
                    //add back option at the end of each submenu
                    array_push(_subMenus[$ _subMenusArray[i]], ["Back", MenuGoBack, -1 ,true]);
                    //add submenu into main menu
                    array_push(_menuOptions, [_subMenusArray[i], SubMenu, [_subMenus[$ _subMenusArray[i]]], true]);
                }
            }
            
            Menu(x + 10, y + 110, _menuOptions, , 74, 60);
        }
        else
        {
            //ユニットがAI制御の場合
            var _enemyAction = _unit.AIscript();
            if (_enemyAction != -1) BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
        }
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
