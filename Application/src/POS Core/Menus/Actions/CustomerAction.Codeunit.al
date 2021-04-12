codeunit 6150884 "NPR Customer Action" implements "NPR IAction", "NPR IJsonSerializable"
{
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
        exit(ActionType::Customer);
    end;

    procedure Content(): JsonObject;
    begin
        exit(_base.Content);
    end;

    procedure Parameters(): JsonObject;
    begin
        exit(_base.Parameters);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json := _base.GetJson();
        Json.Add('Type', 'Customer');
        Json.Add('Code', _code);
    end;

    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
    begin
        exit(true);
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
    var
        Metadata: JsonObject;
        Instance: Codeunit "NPR Customer Action";
    begin
        MenuButton.OnRetrieveCustomerMetadata(Metadata);

        Instance.SetCode(MenuButton."Action Code");
        Instance.Content.Add('Metadata', Metadata);

        ActionOut := Instance;
    end;
}
