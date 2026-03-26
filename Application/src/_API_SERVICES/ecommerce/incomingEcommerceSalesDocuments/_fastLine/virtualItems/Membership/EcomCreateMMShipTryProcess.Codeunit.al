#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248534 "NPR EcomCreateMMShipTryProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    trigger OnRun()
    var
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        EcomCreateMMShipImpl.Process(Rec);
    end;
}
#endif
