codeunit 6151043 "NPR POS Secure Method Helper"
{
    Access = Internal;
    SingleInstance = true;

    var
        SecureMethodContext: Dictionary of [Text, Text];
        SalespersonDict: Dictionary of [Text, Code[20]];

    internal procedure AddContextId(ContextId: Text)
    begin
        SecureMethodContext.Set('Id', ContextId);
    end;

    internal procedure AddSalespersonCodeToContext(ContextId: Text; ApprovedBy: code[20])
    begin
        if SecureMethodContext.get('Id', ContextId) then
            SalespersonDict.Set(ContextId, ApprovedBy);
    end;

    internal procedure ClearAll()
    begin
        Clear(SecureMethodContext);
        Clear(SalespersonDict);
    end;

    internal procedure GetSalespersonCode(Id: Text) SalespersonCode: Code[20]
    begin
        if not SalespersonDict.Get(Id, SalespersonCode) then
            exit;
    end;
}