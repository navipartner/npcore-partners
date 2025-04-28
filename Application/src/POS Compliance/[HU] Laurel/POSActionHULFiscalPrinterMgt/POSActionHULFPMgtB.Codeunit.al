codeunit 6248366 "NPR POS Action: HU L FP Mgt. B"
{
    Access = Internal;
    SingleInstance = true;

    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";
        POSUnitMappingNotFoundErr: Label 'POS Unit Mapping not found for POS Unit: %1. Please create a mapping entry.', Comment = '%1 = POS Unit No.';
        RefiscalizeAuditEntryNo, VoidAuditEntryNo : Integer;

    internal procedure SetRequestValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    begin
        Context.SetContext('hwcRequest', PrepareHwcRequest(Context, Sale));
        Context.SetContext('showSpinner', true);
    end;

    local procedure PrepareHwcRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") HwcRequest: JsonObject
    var
        POSSale: Record "NPR POS Sale";
        Method: Option openFiscalDay,closeFiscalDay,cashierFCUReport,getDailyTotal,resetPrinter,setEuroRate,printReceiptCopy,refiscalizeAuditLog,voidCurrentSale;
    begin
        ClearGlobalVars();
        Sale.GetCurrentSale(POSSale);
        HULCommunicationMgt.SetBaseHwcRequestValues(HwcRequest, POSSale."Register No.");

        Method := Context.GetIntegerParameter('Method');
        case Method of
            Method::openFiscalDay:
                HwcRequest.Add('Payload', PrepareOpenFiscalDayRequest(POSSale));
            Method::closeFiscalDay:
                HwcRequest.Add('Payload', PrepareCloseFiscalDayRequest(POSSale));
            Method::cashierFCUReport:
                HwcRequest.Add('Payload', PrepareCashierFCUReportRequest());
            Method::getDailyTotal:
                HwcRequest.Add('Payload', PrepareGetDailyTotalRequest());
            Method::resetPrinter:
                HwcRequest.Add('Payload', PrepareResetPrinterRequest());
            Method::setEuroRate:
                HwcRequest.Add('Payload', PrepareSetEuroRateRequest());
            Method::printReceiptCopy:
                HwcRequest.Add('Payload', PreparePrintReceiptCopy());
            Method::refiscalizeAuditLog:
                HwcRequest.Add('Payload', PrepareRefiscalizeAuditLog());
            Method::voidCurrentSale:
                HwcRequest.Add('Payload', PrepareVoidCurrentSale(POSSale));
        end;
    end;

    internal procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        Method: Option openFiscalDay,closeFiscalDay,cashierFCUReport,getDailyTotal,resetPrinter,setEuroRate,printReceiptCopy,refiscalizeAuditLog,voidCurrentSale;
    begin
        Response := ParseHwcResponse(Context);
        Method := Context.GetIntegerParameter('Method');

        ProcessLaurelMiniPOSResponse(Response, Setup.GetPOSUnitNo(), Method);
    end;

    internal procedure ProcessLaurelMiniPOSResponse(Response: JsonObject; POSUnitNo: Code[10]; Method: Option openFiscalDay,closeFiscalDay,cashierFCUReport,getDailyTotal,resetPrinter,setEuroRate,printReceiptCopy,refiscalizeAuditLog,voidCurrentSale)
    var
        ResponseMessage: JsonObject;
        ResponseMsgToken: JsonToken;
    begin
        HULCommunicationMgt.ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response); //Handles Success boolean from HWC and Error Message

        Response.Get('ResponseMessage', ResponseMsgToken);
        ResponseMessage := ResponseMsgToken.AsObject();

        HULCommunicationMgt.ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMessage); //Handles iErrCode and sErrMsg from ResponseMessage

        case Method of
            Method::openFiscalDay:
                HandleOpenDayResponse(POSUnitNo);
            Method::closeFiscalDay:
                HandleCloseDayResponse(POSUnitNo);
            Method::getDailyTotal:
                HandleGetDailyTotalResponse(ResponseMessage, POSUnitNo);
            Method::refiscalizeAuditLog:
                HandleRefiscalizeAuditLog(ResponseMessage);
            Method::voidCurrentSale:
                HandleVoidCurrentTransaction(ResponseMessage);
        end;
    end;

    local procedure ParseHwcResponse(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HwcResponse: JsonObject;
        JsonTok: JsonToken;
    begin
        // HWC data
        Response.Add('ShowSuccessMessage', false);

        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcResponse.Get('Success', JsonTok);
        Response.Add('Success', JsonTok.AsValue().AsBoolean());

        HwcResponse.Get('ResponseMessage', JsonTok);
        JsonTok.ReadFrom(JsonTok.AsValue().AsText().Replace('\"', '"'));
        Response.Add('ResponseMessage', JsonTok);

        HwcResponse.Get('ErrorMessage', JsonTok);
        Response.Add('ErrorMessage', JsonTok);
    end;

    #region POS Action: HU L FP Mgt - Requests

    internal procedure PrepareOpenFiscalDayRequest(POSSale: Record "NPR POS Sale"): Text
    begin
        CheckPOSControlUnitStatusOpen(POSSale."Register No.");
        exit(HULCommunicationMgt.OpenFiscalDay(POSSale));
    end;

    internal procedure PrepareCloseFiscalDayRequest(POSSale: Record "NPR POS Sale"): Text
    begin
        CheckPOSControlUnitStatusClosed(POSSale."Register No.");
        exit(HULCommunicationMgt.CloseFiscalDay());
    end;

    local procedure PrepareCashierFCUReportRequest(): Text
    begin
        exit(HULCommunicationMgt.PrintCashierFCUReport());
    end;

    internal procedure PrepareGetDailyTotalRequest(): Text
    begin
        exit(HULCommunicationMgt.GetDailyTotal());
    end;

    local procedure PrepareResetPrinterRequest(): Text
    begin
        exit(HULCommunicationMgt.ResetPrinter());
    end;

    local procedure PrepareSetEuroRateRequest(): Text
    begin
        exit(HULCommunicationMgt.SetEuroRate());
    end;

    local procedure PreparePrintReceiptCopy(): Text
    begin
        exit(HULCommunicationMgt.PrintReceiptCopy());
    end;

    local procedure PrepareRefiscalizeAuditLog(): Text
    begin
        exit(HULCommunicationMgt.RefiscalizeAuditLog(RefiscalizeAuditEntryNo));
    end;

    local procedure PrepareVoidCurrentSale(POSSale: Record "NPR POS Sale"): Text
    begin
        exit(HULCommunicationMgt.VoidCurrentSale(VoidAuditEntryNo, POSSale));
    end;
    #endregion POS Action: HU L FP Mgt - Requests

    #region POS Action: HU L FP Mgt - Responses
    local procedure HandleOpenDayResponse(POSUnitNo: Code[10])
    begin
        HULCommunicationMgt.SetOpenDayOnPOSUnitMapping(POSUnitNo);
    end;

    local procedure HandleCloseDayResponse(POSUnitNo: Code[10])
    begin
        HULCommunicationMgt.SetCloseDayOnPOSUnitMapping(POSUnitNo);
    end;

    local procedure HandleGetDailyTotalResponse(Response: JsonObject; POSUnitNo: Code[10])
    begin
        HULCommunicationMgt.SaveDailyTotalsToPOSUnitMapping(Response, POSUnitNo);
    end;

    local procedure HandleRefiscalizeAuditLog(Response: JsonObject): Text
    var
        POSEntry: Record "NPR POS Entry";
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
    begin
        HULPOSAuditLogAux.Get(HULPOSAuditLogAux."Audit Entry Type"::"POS Entry", RefiscalizeAuditEntryNo);
        POSEntry.Get(HULPOSAuditLogAux."POS Entry No.");
        HULAuditMgt.InsertHULPOSAuditLogAuxResponseData(POSEntry, Response);
    end;

    local procedure HandleVoidCurrentTransaction(Response: JsonObject)
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
    begin
        HULAuditMgt.InsertHULPOSAuditLogAuxResponseData(VoidAuditEntryNo, Response);
    end;
    #endregion POS Action: HU L FP Mgt - Responses

    #region POS Action: HU L FP Mgt - Helper Procedures
    local procedure CheckPOSControlUnitStatusOpen(POSUnitNo: Code[20])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        POSControlUnitAlreadyOpenErr: Label 'Fiscal day is already opened for POS Unit: %1', Comment = '%1 = POS Unit No.';
    begin
        if not HULPOSUnitMapping.Get(POSUnitNo) then
            Error(POSUnitMappingNotFoundErr, POSUnitNo);

        if HULPOSUnitMapping."POS FCU Day Status" = HULPOSUnitMapping."POS FCU Day Status"::OPEN then
            Error(POSControlUnitAlreadyOpenErr, POSUnitNo);
    end;

    local procedure CheckPOSControlUnitStatusClosed(POSUnitNo: Code[20])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        POSControlUnitAlreadyClosedErr: Label 'Fiscal day is already closed for POS Unit: %1', Comment = '%1 = POS Unit No.';
    begin
        if not HULPOSUnitMapping.Get(POSUnitNo) then
            Error(POSUnitMappingNotFoundErr, POSUnitNo);

        if HULPOSUnitMapping."POS FCU Day Status" = HULPOSUnitMapping."POS FCU Day Status"::CLOSED then
            Error(POSControlUnitAlreadyClosedErr, POSUnitNo);
    end;

    local procedure ClearGlobalVars()
    begin
        Clear(RefiscalizeAuditEntryNo);
        Clear(VoidAuditEntryNo);
    end;
    #endregion POS Action: HU L FP Mgt - Helper Procedures
}