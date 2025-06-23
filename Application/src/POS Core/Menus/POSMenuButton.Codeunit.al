﻿codeunit 6150889 "NPR POS Menu Button" implements "NPR IJsonSerializable", "NPR ISubMenu"
{
#IF NOT BC17
    Access = Internal;      
#ENDIF

    var
        _caption: Text;
        _tooltip: Text;
        _action: Interface "NPR IAction";
        _actionInitialized: Boolean;
        _backgroundColor: Text;
        _color: Text;
        _iconClass: Text;
        _globalClass: Text;
        _row: Integer;
        _column: Integer;
        _enabledState: Enum "NPR Button Enabled State";
        _content: JsonObject;
        _menuButtons: JsonArray;

    procedure Caption(): Text;
    begin
        exit(_caption);
    end;

    procedure SetCaption(NewCaption: Text);
    begin
        _caption := NewCaption;
    end;

    procedure Tooltip(): Text;
    begin
        exit(_tooltip);
    end;

    procedure SetTooltip(NewTooltip: Text);
    begin
        _tooltip := NewTooltip;
    end;

    procedure GetAction(var ActionOut: Interface "NPR IAction");
    begin
        ActionOut := _action;
    end;

    procedure SetAction(NewAction: Interface "NPR IAction");
    begin
        _action := NewAction;
        _actionInitialized := true;
    end;

    procedure BackgroundColor(): Text;
    begin
        exit(_backgroundColor);
    end;

    procedure SetBackgroundColor(NewBackgroundColor: Text);
    begin
        _backgroundColor := NewBackgroundColor;
    end;

    [Obsolete('Not used. Removed in case 516268.', '2023-06-28')]
    procedure Color(): Text;
    begin
        exit(_color);
    end;

    [Obsolete('Not used. Removed in case 516268.', '2023-06-28')]
    procedure SetColor(NewColor: Text);
    begin
        _color := NewColor;
    end;

    procedure IconClass(): Text;
    begin
        exit(_iconClass);
    end;

    procedure SetIconClass(NewIconClass: Text);
    begin
        _iconClass := NewIconClass;
    end;

    procedure Class(): Text;
    begin
        exit(_globalClass);
    end;

    procedure SetClass(NewClass: Text);
    begin
        _globalClass := NewClass;
    end;

    procedure Row(): Integer;
    begin
        exit(_row);
    end;

    procedure SetRow(NewRow: Integer);
    begin
        _row := NewRow;
    end;

    procedure Column(): Integer;
    begin
        exit(_column);
    end;

    procedure SetColumn(NewColumn: Integer);
    begin
        _column := NewColumn;
    end;

    procedure EnabledState(): Enum "NPR Button Enabled State";
    begin
        exit(_enabledState);
    end;

    procedure SetEnabledState(NewEnabledState: Enum "NPR Button Enabled State");
    begin
        _enabledState := NewEnabledState;
    end;

    procedure Content(): JsonObject;
    begin
        exit(_content);
    end;

    procedure AddMenuButton(MenuButton: Codeunit "NPR POS Menu Button");
    begin
        _menuButtons.Add(MenuButton.GetJson());
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Caption', _caption);
        Json.Add('Tooltip', _tooltip);
        if _actionInitialized then
            Json.Add('Action', _action.GetJson());

        Json.Add('BackgroundColor', _backgroundColor);
        Json.Add('Color', _color);
        Json.Add('IconClass', _iconClass);
        Json.Add('Class', _globalClass);
        Json.Add('Row', _row);
        Json.Add('Column', _column);
        Json.Add('Enabled', _enabledState.AsInteger());
        Json.Add('Content', _content);
        Json.Add('MenuButtons', _menuButtons);
    end;
}
