codeunit 6248259 "NPR POS Action: HU L Receipt B"
{
    Access = Internal;

    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";

    #region POS Action: HU L Receipt B: Prepare Request
    internal procedure SetRequestValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    begin
        Context.SetContext('hwcRequest', PrepareHwcRequest(Context, Sale));
        Context.SetContext('showSpinner', true);
    end;

    local procedure PrepareHwcRequest(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") HwcRequest: JsonObject
    var
        POSSale: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
    begin
        Sale.GetCurrentSale(POSSale);
        HULCommunicationMgt.SetBaseHwcRequestValues(HwcRequest, POSSale."Register No.");
        GetPOSEntryBySalesTicketNo(POSEntry, GetSalesTicketNo(Context));
        CreatePrintReceiptRequest(HwcRequest, POSEntry);
    end;

    internal procedure CreatePrintReceiptRequest(var HwcRequest: JsonObject; POSEntry: Record "NPR POS Entry")
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        AuditLogNotFoundErr: Label 'Audit Log has not been found for POS Entry No: %1', Comment = '%1 = POS Entry No.';
    begin
        if not HULPOSAuditLogAux.FindAuditLog(POSEntry."Entry No.") then
            Error(AuditLogNotFoundErr, POSEntry."Entry No.");

        case HULPOSAuditLogAux."Transaction Type" of
            HULPOSAuditLogAux."Transaction Type"::"Standard Receipt":
                HwcRequest.Add('Payload', HULCommunicationMgt.CreatePrintReceiptRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::"Simple Invoice":
                HwcRequest.Add('Payload', HULCommunicationMgt.CreateSimplifiedInvoiceRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::Return:
                HwcRequest.Add('Payload', HULCommunicationMgt.CreateReturnSaleRequest(POSEntry, HULPOSAuditLogAux));
            HULPOSAuditLogAux."Transaction Type"::Void:
                HwcRequest.Add('Payload', HULCommunicationMgt.CreateVoidSaleRequest(POSEntry, HULPOSAuditLogAux));
        end;
    end;

    #endregion POS Action: HU L Receipt B: Prepare Request

    #region POS Action: HU L Receipt B: Handle Response

    internal procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject
    var
        POSEntry: Record "NPR POS Entry";
    begin
        Response := ParseHwcResponse(Context);
        GetPOSEntryBySalesTicketNo(POSEntry, GetSalesTicketNo(Context));

        ProcessLaurelMiniPOSResponse(Response, POSEntry);
    end;

    internal procedure ProcessLaurelMiniPOSResponse(Response: JsonObject; POSEntry: Record "NPR POS Entry")
    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
        ResponseMessage: JsonObject;
        ResponseMsgToken: JsonToken;
    begin
        HULCommunicationMgt.ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response);

        Response.Get('ResponseMessage', ResponseMsgToken);
        ResponseMessage := ResponseMsgToken.AsObject();

        HULCommunicationMgt.ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMessage); //Handles iErrCode and sErrMsg from ResponseMessage

        HULAuditMgt.InsertHULPOSAuditLogAuxResponseData(POSEntry, ResponseMessage);
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

    #endregion POS Action: HU L Receipt B: Handle Response

    #region POS Action: HU L Receipt B: Helper Procedures

    local procedure GetPOSEntryBySalesTicketNo(var POSEntry: Record "NPR POS Entry"; SalesTicketNo: Code[20]): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", SalesTicketNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure GetSalesTicketNo(var Context: Codeunit "NPR POS JSON Helper") SalesTicketNo: Code[20];
    var
        CustomParameters: JsonObject;
        JsonToken: JsonToken;
    begin
        CustomParameters := Context.GetJsonObject('customParameters');
        CustomParameters.Get('salesTicketNo', JsonToken);
        SalesTicketNo := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(SalesTicketNo));
    end;

    #endregion POS Action: HU L Receipt B: Helper Procedures
}