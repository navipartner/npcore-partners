#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248365 "NPR IncEcomSalesDocTryProcess"
{
    Access = Internal;
    TableNo = "NPR Inc Ecom Sales Header";
    ObsoleteState = "Pending";
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR EcomSalesDocTryProcess';

    trigger OnRun()
    begin
        RunAPIBasedOnVersion(Rec);
    end;

    local procedure RunAPIBasedOnVersion(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesDocImpl: Codeunit "NPR Inc Ecom Sales Doc Impl";
        IncEcomSalesDocImplV2: Codeunit "NPR Inc Ecom Sales Doc Impl V2";
    begin
        case IncEcomSalesHeader."API Version Date" of
            IncEcomSalesDocImplV2.GetApiVersion():
                IncEcomSalesDocImplV2.Process(IncEcomSalesHeader);
            else
                IncEcomSalesDocImpl.Process(IncEcomSalesHeader);
        // Add new api-date-version cases here as needed
        end;
    end;
}
#endif