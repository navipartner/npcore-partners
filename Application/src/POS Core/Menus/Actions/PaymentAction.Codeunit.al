codeunit 6150885 "NPR Payment Action" implements "NPR IAction", "NPR IJsonSerializable"
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
        exit(ActionType::PaymentType);
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
        Json.Add('Type', 'Payment');
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
        Instance: Codeunit "NPR Payment Action";
    begin
        MenuButton.OnRetrievePaymentMetadata(Metadata);

        Instance.SetCode(MenuButton."Action Code");
        Instance.Content().Add('Metadata', Metadata);

        ActionOut := Instance;
    end;
}
