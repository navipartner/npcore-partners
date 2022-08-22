codeunit 6150883 "NPR Item Action" implements "NPR IAction", "NPR IJsonSerializable"
{
    Access = Internal;

    var
        _code: Text;
        _base: Codeunit "NPR Base Action";

    procedure Code(): Text;
    begin
        exit(_code);
    end;

    procedure SetCode(NewCode: Text);
    begin
        _code := NewCode;
    end;

    procedure Type() ActionType: Enum "NPR Action Type";
    begin
        exit(ActionType::Item);
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
        Json.Add('Type', 'Item');
        Json.Add('Code', _code);
    end;

#pragma warning disable AA0150
    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
#pragma warning restore
    begin
        exit(true);
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
    var
        Metadata: JsonObject;
        Instance: Codeunit "NPR Item Action";
    begin
        AddItemInfoToMetadata(MenuButton, Metadata);
        MenuButton.OnRetrieveItemMetadata(Metadata);

        Instance.SetCode(MenuButton."Action Code");
        Instance.Content().Add('Metadata', Metadata);

        ActionOut := Instance;
    end;

    local procedure AddItemInfoToMetadata(MenuButton: Record "NPR POS Menu Button"; Metadata: JsonObject)
    var
        Item: Record Item;
    begin
        if (MenuButton."Action Type" <> MenuButton."Action Type"::Item) or (MenuButton."Action Code" = '') then
            exit;
        Item.SetLoadFields(Description, "Description 2");
        if not Item.Get(MenuButton."Action Code") then
            exit;
        if Item.Description <> '' then
            Metadata.Add('ItemDescription', Item.Description);
        if Item."Description 2" <> '' then
            Metadata.Add('ItemDescription2', Item."Description 2");
    end;
}
