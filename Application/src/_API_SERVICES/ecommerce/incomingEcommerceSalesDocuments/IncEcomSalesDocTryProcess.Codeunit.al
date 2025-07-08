#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248365 "NPR IncEcomSalesDocTryProcess"
{
    Access = Internal;
    TableNo = "NPR Inc Ecom Sales Header";

    trigger OnRun()
    var
        IncEcomSalesDocImpl: Codeunit "NPR Inc Ecom Sales Doc Impl";
    begin
        IncEcomSalesDocImpl.Process(Rec);
    end;
}
#endif