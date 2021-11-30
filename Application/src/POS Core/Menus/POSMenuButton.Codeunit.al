codeunit 6150889 "NPR POS Menu Button" implements "NPR IJsonSerializable", "NPR ISubMenu"
{
    var
        _caption: Text;
        _tooltip: Text;
        _action: Interface "NPR IAction";
        _actionInitialized: Boolean;
        _backgroundColor: Text;
        _color: Text;
        _iconClass: Text;
        _class: Text;
        _bold: Boolean;
        _fontSize: Enum "NPR Button Font Size";
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

    procedure Color(): Text;
    begin
        exit(_color);
    end;

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
        exit(_class);
    end;

    procedure SetClass(NewClass: Text);
    begin
        _class := NewClass;
    end;

    [Obsolete('Procedure is not needed anymore. Case 498936')]
    procedure Bold(): Boolean;
    begin
        exit(_bold);
    end;

    [Obsolete('Procedure is not needed anymore. Case 498936')]
    procedure SetBold(NewBold: Boolean);
    begin
        _bold := NewBold;
    end;

    [Obsolete('Procedure is not needed anymore. Case 498936')]
    procedure FontSize(): Enum "NPR Button Font Size";
    begin
        exit(_fontSize);
    end;

    [Obsolete('Procedure is not needed anymore. Case 498936')]
    procedure SetFontSize(NewFontSize: Enum "NPR Button Font Size");
    begin
        _fontSize := NewFontSize;
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
        Json.Add('Class', _class);
        Json.Add('Row', _row);
        Json.Add('Column', _column);
        Json.Add('Enabled', _enabledState.AsInteger());
        Json.Add('Content', _content);
        Json.Add('MenuButtons', _menuButtons);
    end;
}
