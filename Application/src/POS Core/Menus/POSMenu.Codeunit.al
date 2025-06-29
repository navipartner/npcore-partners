﻿codeunit 6150890 "NPR POS Menu" implements "NPR ISubMenu", "NPR IJsonSerializable"
{
    Access = Internal;

    var
        _id: Text;
        _caption: Text;
        _tooltip: Text;
        _globalClass: Text;
        _menuButtons: JsonArray;

    procedure Id(): Text;
    begin
        exit(_id);
    end;

    procedure SetId(NewId: Text);
    begin
        _id := NewId;
    end;

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

    procedure Class(): Text;
    begin
        exit(_globalClass);
    end;

    procedure SetClass(NewClass: Text);
    begin
        _globalClass := NewClass;
    end;

    procedure AddMenuButton(MenuButton: Codeunit "NPR POS Menu Button");
    begin
        _menuButtons.Add(MenuButton.GetJson());
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Id', _id);
        Json.Add('Caption', _caption);
        Json.Add('Tooltip', _tooltip);
        Json.Add('Class', _globalClass);
        Json.Add('MenuButtons', _menuButtons);
    end;
}
