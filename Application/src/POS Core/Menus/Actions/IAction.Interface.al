interface "NPR IAction"
{
    procedure Content(): JsonObject;
    procedure Parameters(): JsonObject;
    procedure Type(): Enum "NPR Action Type";
    procedure GetJson(): JsonObject;
    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
}
