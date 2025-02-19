//戦闘背景を描画
draw_sprite(battleBackground, 0 ,x, y);

//ユニットを描画
var _unitWithCurrentTurn = unitTurnOrder[turn].id;
for (var i = 0; i < array_length(unitRenderOrder); i++)
{
    with (unitRenderOrder[i])
    {
        draw_self();
    }
}

//UIを描画
draw_sprite_stretched(sBox, 0, x + 75, y + 120, 245, 60);
draw_sprite_stretched(sBox, 0, x, y + 120, 74, 60);

//ポジション
#macro COLUMN_ENEMY 15
#macro COLUMN_NAME 90
#macro COLUMN_HP 160
#macro COLUMN_MP 220

//draw headings
draw_set_font(fnM3x6);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_gray);
draw_text(x + COLUMN_ENEMY, y + 120, "ENEMY");
draw_text(x + COLUMN_NAME, y + 120, "NAME");
draw_text(x + COLUMN_HP, y + 120, "HP");
draw_text(x + COLUMN_MP, y + 120, "MP");

//draw enemy names
draw_set_font(fnOpenSansPX);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
var _drawlimit = 3;
var _drawn = 0;
for (var i = 0; (i < array_length(enemyUnits)) && (_drawn < _drawlimit); i++)
{
    var _char = enemyUnits[i];
    if (_char.hp > 0)
    {
        _drawn++;
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        if (_char.id == _unitWithCurrentTurn) draw_set_color(c_yellow);
            draw_text(x + COLUMN_ENEMY, y + 130 + (i * 12), _char.name);
    }
}

//draw party info
for (var i = 0; i < array_length(partyUnits); i++)
{
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    var _char = partyUnits[i];
    if (_char.id == _unitWithCurrentTurn) draw_set_color(c_yellow);
        if (_char.hp <= 0) draw_set_color(c_red);
            draw_text(x + COLUMN_NAME, y + 130 + (i * 12), _char.name);
    draw_set_halign(fa_right);
    
    //HP描画
    draw_set_color(c_white);
    if (_char.hp < (_char.hpMax * 0.5)) draw_set_color(c_orange);
    if (_char.hp <= 0) draw_set_color(c_red);
    draw_text(x + COLUMN_HP + 50, y + 130 + (i * 12), string(_char.hp) + "/" + string(_char.hpMax));
    
    //MP描画
    draw_set_color(c_white);
    if (_char.mp < (_char.mpMax * 0.5)) draw_set_color(c_orange);
    if (_char.hp <= 0) draw_set_color(c_red);
    draw_text(x + COLUMN_MP + 50, y + 130 + (i * 12), string(_char.mp) + "/" + string(_char.mpMax));
    
    draw_set_color(c_white);
}


