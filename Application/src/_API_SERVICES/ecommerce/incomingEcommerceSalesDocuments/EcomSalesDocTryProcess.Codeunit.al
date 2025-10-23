#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248611 "NPR EcomSalesDocTryProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    trigger OnRun()
    begin
        RunAPIBasedOnVersion(Rec);
    end;

    local procedure RunAPIBasedOnVersion(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        IncEcomSalesDocImpl: Codeunit "NPR Ecom Sales Doc Impl";
        IncEcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        case EcomSalesHeader."API Version Date" of
            IncEcomSalesDocImplV2.GetApiVersion():
                IncEcomSalesDocImplV2.Process(EcomSalesHeader);
            else
                IncEcomSalesDocImpl.Process(EcomSalesHeader);
        // Add new api-date-version cases here as needed
        end;
    end;

}
#endif