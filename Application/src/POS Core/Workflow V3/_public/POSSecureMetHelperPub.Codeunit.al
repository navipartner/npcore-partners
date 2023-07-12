codeunit 6059983 "NPR POS Secure Met. Helper Pub"
{
    Access = Public;

    var
        POSSecureMethodHelper: Codeunit "NPR POS Secure Method Helper";

    procedure GetSalespersonCode(Id: Text) SalespersonCode: Code[20]
    begin
        SalespersonCode := POSSecureMethodHelper.GetSalespersonCode(Id);
    end;
}