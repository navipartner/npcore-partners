codeunit 6184687 "NPR POS Action: BG SISCashierB"
{
    Access = Internal;

    internal procedure PrepareHTTPRequest(Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier; POSUnitNo: Code[10]; SalespersonCode: Code[20]) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        Salesperson: Record "Salesperson/Purchaser";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        case Method of
            Method::getCashierData:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForGetCashierData(SalespersonCode));
            Method::isCashierSet:
                Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForGetCashierData(SalespersonCode));
            Method::setCashier:
                begin
                    SelectSalesperson(Salesperson);
                    Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForSetCashier(Salesperson));
                end;
            Method::deleteCashier:
                begin
                    SelectSalesperson(Salesperson);
                    Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForDeleteCashier(Salesperson));
                end;
            Method::trySetCashier:
                begin
                    Salesperson.Get(SalespersonCode);
                    Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForSetCashier(Salesperson));
                end;
        end;
    end;

    internal procedure HandleResponse(ResponseText: Text; Method: Option getCashierData,isCashierSet,setCashier,deleteCashier,trySetCashier; SalespersonCode: Code[20])
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        case Method of
            Method::getCashierData:
                BGSISCommunicationMgt.ProcessGetCashierDataResponse(ResponseText);
            Method::isCashierSet:
                BGSISCommunicationMgt.ProcessIsCashierSetResponse(SalespersonCode, ResponseText);
            Method::setCashier:
                BGSISCommunicationMgt.ProcessSetCashierResponse(ResponseText);
            Method::deleteCashier:
                BGSISCommunicationMgt.ProcessDeleteCashierResponse(ResponseText);
            Method::trySetCashier:
                if BGSISCommunicationMgt.TryProcessSetCashierResponse(ResponseText) then;
        end;
    end;

    local procedure SelectSalesperson(var Salesperson: Record "Salesperson/Purchaser"): Boolean
    begin
        exit(Page.RunModal(0, Salesperson) = Action::LookupOK);
    end;
}
