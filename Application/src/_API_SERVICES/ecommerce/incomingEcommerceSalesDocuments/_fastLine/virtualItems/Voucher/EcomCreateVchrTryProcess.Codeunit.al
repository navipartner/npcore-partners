#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248509 "NPR EcomCreateVchrTryProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    trigger OnRun()
    var
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        EcomCreateVchrImpl.Process(Rec);
    end;
}
#endif