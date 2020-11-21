codeunit 6150888 "NPR SubMenu Action" implements "NPR IAction", "NPR IJsonSerializable"
{
    // This codeunit is there to support enum implementation. It is not intended to be used, and any attempt to actually use it will result in an error.
    var
        TextDoNotUse: Label 'Do not use codeunit "NPR SubMenu Action" directly.';

    procedure Type() ActionType: Enum "NPR Action Type";
    begin
        exit(ActionType::SubMenu);
    end;

    procedure Content(): JsonObject;
    begin
        Error(TextDoNotUse);
    end;

    procedure Parameters(): JsonObject;
    begin
        Error(TextDoNotUse);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Error(TextDoNotUse);
    end;

    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
    begin
        exit(true);
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
    begin
        Error(TextDoNotUse);
    end;
}
