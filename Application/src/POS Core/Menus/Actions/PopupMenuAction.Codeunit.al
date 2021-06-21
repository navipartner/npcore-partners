codeunit 6150887 "NPR Popup Menu Action" implements "NPR IAction", "NPR IJsonSerializable"
{
    var
        _menuId: Text;
        _openAsPopup: Boolean;
        _base: Codeunit "NPR Base Action";

    procedure MenuId(): Text;
    begin
        exit(_menuId);
    end;

    procedure SetMenuId(NewMenuId: Text);
    begin
        _menuId := NewMenuId;
    end;

    procedure OpenAsPopup(): Boolean;
    begin
        exit(_openAsPopup);
    end;

    procedure SetOpenAsPopup(NewOpenAsPopup: Boolean);
    begin
        _openAsPopup := NewOpenAsPopup;
    end;

    procedure Type() ActionType: Enum "NPR Action Type";
    begin
        exit(ActionType::PopupMenu);
    end;

    procedure Content(): JsonObject;
    begin
        exit(_base.Content());
    end;

    procedure Parameters(): JsonObject;
    begin
        exit(_base.Parameters());
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json := _base.GetJson();
        Json.Add('Type', 'Menu');
        Json.Add('MenuId', _menuId);
        Json.Add('OpenAsPopup', _openAsPopup);
    end;

#pragma warning disable AA0150
    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
#pragma warning restore
    begin
        exit(true);
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
    var
        Instance: Codeunit "NPR Popup Menu Action";
    begin
        Instance.SetOpenAsPopup(true);
        Instance.SetMenuId(MenuButton."Action Code");

        ActionOut := Instance;
    end;
}
