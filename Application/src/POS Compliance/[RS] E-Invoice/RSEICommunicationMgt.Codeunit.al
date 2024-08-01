codeunit 6184794 "NPR RS EI Communication Mgt."
{
    Access = Internal;
    SingleInstance = true;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        JSONReadErr: Label 'JSON can''t be read from response text.';

    #region RS EI Purchase Invoice Communication Mgt.

    internal procedure ImportNewPurchaseInvoiceDocuments(StartDate: Date; EndDate: Date)
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary;
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        PurchInvIdList: List of [Integer];
        PurchInvId: Integer;
        GetPurchaseInvoiceIdsPathLbl: Label '/api/publicApi/purchase-invoice/ids?dateFrom=%1&dateTo=%2', Locked = true, Comment = '%1 = From Date, %2 = To Date';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(GetPurchaseInvoiceIdsPathLbl, Format(StartDate, 10, '<Year4>-<Month,2>-<Day,2>'), Format(EndDate, 10, '<Year4>-<Month,2>-<Day,2>')));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::POST, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessGetPurchInvoiceIdsResponse(PurchInvIdList, ResponseText);

        if PurchInvIdList.Count = 0 then
            exit;

        foreach PurchInvId in PurchInvIdList do begin
            RSEInvoiceDocument.SetRange(Direction, RSEInvoiceDocument.Direction::Incoming);
            RSEInvoiceDocument.SetRange("Purchase Invoice ID", PurchInvId);
            if RSEInvoiceDocument.IsEmpty() then
                GetPurchaseInvoice(TempRSEInvoiceDocument, PurchInvId);
        end;

        RSEInvoiceMgt.ProcessSelectedPurchaseInvoicesForImporting(TempRSEInvoiceDocument)
    end;

    local procedure GetPurchaseInvoice(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; PurchaseInvoiceId: Integer)
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        RSEIInPurchInvMgt: Codeunit "NPR RS EI In Purch. Inv. Mgt.";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        GetPurchaseInvoiceDocPathLbl: Label '/api/publicApi/purchase-invoice/xml?invoiceId=%1', Locked = true, Comment = '%1 = Invoice Id';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(GetPurchaseInvoiceDocPathLbl, PurchaseInvoiceId));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::GET, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            RSEIInPurchInvMgt.ProcessGetPurchaseInvoiceDocumentResponse(TempRSEInvoiceDocument, ResponseText, PurchaseInvoiceId);
    end;

    internal procedure RefreshPurchaseDocumentsStatus(DateChange: Date)
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        RefreshPurchaseDocumentStatusPathLbl: Label '/api/publicApi/purchase-invoice/changes?date=%1', Locked = true, Comment = '%1 = Date of status change';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(RefreshPurchaseDocumentStatusPathLbl, Format(DateChange, 10, '<Year4>-<Month,2>-<Day,2>')));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::POST, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessRefreshPurchaseDocumentStatusResponse(ResponseText);
    end;

    internal procedure GetPurchaseDocumentStatus(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        GetPurchaseInvoiceStatusPathLbl: Label '/api/publicApi/purchase-invoice?invoiceId=%1', Locked = true, Comment = '%1 = Invoice Id';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(GetPurchaseInvoiceStatusPathLbl, RSEInvoiceDocument."Purchase Invoice ID"));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::GET, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessGetPurchaseDocumentStatusResponse(RSEInvoiceDocument, ResponseText);
    end;

    internal procedure AcceptIncomingPurchaseDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"): Boolean
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        ShouldAcceptInvoiceQst: Label 'Do you want to accept this invoice and send a confirmation to SEF?';
        AcceptingSuccessfullMsg: Label 'You have accepted the invoice successfully.';
        CannotAcceptIfAlreadyRejectedErr: Label 'You cannot accept invoice document if it has already been rejected.';
        JsonObj: JsonObject;
        RequestMessage: HttpRequestMessage;
        Url: Text;
        RequestText: Text;
        ResponseText: Text;
        AcceptPurchaseDocumentLbl: Label '/api/publicApi/purchase-invoice/acceptRejectPurchaseInvoice', Locked = true;
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        if RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::REJECTED] then
            Error(CannotAcceptIfAlreadyRejectedErr);

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        if not (ConfirmManagement.GetResponseOrDefault(ShouldAcceptInvoiceQst, false)) then
            exit(false);

        JsonObj.Add('invoiceId', RSEInvoiceDocument."Purchase Invoice ID");
        JsonObj.Add('accepted', true);
        JsonObj.WriteTo(RequestText);

        Url := FormatUrl(RSEInvoiceSetup."API URL", AcceptPurchaseDocumentLbl);

        SetRequestMessageContent(RequestMessage, RequestText, HttpMethod::POST, 'application/json', Url, RSEInvoiceSetup."API Key", true);

        if not SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(false);
        if not ProcessAcceptIncomingPurchaseDocumentResponse(RSEInvoiceDocument, ResponseText) then
            exit(false);
        Message(AcceptingSuccessfullMsg);
        exit(true);
    end;

    internal procedure RejectIncomingPurchaseDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        InputDialog: Page "NPR Input Dialog";
        HttpMethod: Enum "Http Method";
        ShouldRejectInvoiceQst: Label 'Do you want to reject this invoice and send a confirmation to SEF?';
        RejectingSuccessfullMsg: Label 'You have rejected the invoice successfully.';
        CannotRejectIfAlreadyApprovedErr: Label 'You cannot reject invoice document if it has already been approved.';
        JsonObj: JsonObject;
        RequestMessage: HttpRequestMessage;
        Url: Text;
        RequestText: Text;
        ResponseText: Text;
        RejectingComment: Text;
        RejectingCommentLbl: Label 'Comment for Rejecting Invoice Document';
        RejectingCommentEmptyErr: Label 'Comment must not be empty';
        RejectPurchaseDocumentLbl: Label '/api/publicApi/purchase-invoice/acceptRejectPurchaseInvoice', Locked = true;
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        if RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::APPROVED] then
            Error(CannotRejectIfAlreadyApprovedErr);

        if not (ConfirmManagement.GetResponseOrDefault(ShouldRejectInvoiceQst, false)) then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        InputDialog.SetInput(1, RejectingComment, RejectingCommentLbl);
        InputDialog.RunModal();
        InputDialog.InputText(1, RejectingComment);

        if RejectingComment = '' then
            Error(RejectingCommentEmptyErr);

        JsonObj.Add('invoiceId', RSEInvoiceDocument."Purchase Invoice ID");
        JsonObj.Add('accepted', false);
        JsonObj.Add('comment', RejectingComment);
        JsonObj.WriteTo(RequestText);

        Url := FormatUrl(RSEInvoiceSetup."API URL", RejectPurchaseDocumentLbl);

        SetRequestMessageContent(RequestMessage, RequestText, HttpMethod::POST, 'application/json', Url, RSEInvoiceSetup."API Key", true);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            if ProcessRejectIncomingPurchaseDocumentResponse(RSEInvoiceDocument, ResponseText) then
                Message(RejectingSuccessfullMsg);
    end;

    local procedure ProcessGetPurchInvoiceIdsResponse(var PurchInvIdList: List of [Integer]; ResponseText: Text)
    var
        JsonArray: JsonArray;
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
        i: Integer;
        PurchInvIdTxt: Text;
        PurchInvId: Integer;
    begin
        JsonHeader.ReadFrom(ResponseText);
        if not JsonHeader.Get('PurchaseInvoiceIds', JsonToken) then
            Error(JSONReadErr);

        JsonArray := JsonToken.AsArray();

        if JsonArray.Count = 0 then
            Error(JSONReadErr);

        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonValue := JsonToken.AsValue();
            JsonValue.WriteTo(PurchInvIdTxt);
            Evaluate(PurchInvId, PurchInvIdTxt);
            PurchInvIdList.Add(PurchInvId);
        end;
    end;

    local procedure ProcessRefreshPurchaseDocumentStatusResponse(ResponseText: Text)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        TypeHelper: Codeunit "Type Helper";
        JsonArray: JsonArray;
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
        i: Integer;
        StatusDictionary: Dictionary of [Integer, Text];
        DateDictionary: Dictionary of [Integer, DateTime];
        DateTime: DateTime;
        InvoiceId: Integer;
        Status: Text;
        HelperText: Text;
        InvoiceIds: List of [Integer];
    begin
        if not JsonArray.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonHeader := JsonToken.AsObject();
            JsonHeader.Get('PurchaseInvoiceId', JsonToken);
            JsonToken.WriteTo(HelperText);
            HelperText := HelperText.Replace('"', '');
            Evaluate(InvoiceId, HelperText);
            JsonHeader.Get('NewInvoiceStatus', JsonToken);
            JsonToken.WriteTo(Status);
            Status := Status.Replace('"', '');
            JsonHeader.Get('Date', JsonToken);
            JsonToken.WriteTo(HelperText);
            HelperText := HelperText.Replace('"', '');
            Evaluate(DateTime, HelperText);
            if StatusDictionary.Add(InvoiceId, Status) then
                DateDictionary.Add(InvoiceId, DateTime)
            else
                if TypeHelper.CompareDateTime(DateDictionary.Get(InvoiceId), DateTime) = -1 then begin
                    DateDictionary.Set(InvoiceId, DateTime);
                    StatusDictionary.Set(InvoiceId, Status);
                end;
        end;

        InvoiceIds := StatusDictionary.Keys();

        foreach InvoiceId in InvoiceIds do begin
            RSEInvoiceDocument.SetRange("Purchase Invoice ID", InvoiceId);
            if RSEInvoiceDocument.FindFirst() then begin
                RSEInvoiceDocument."Invoice Status" := "NPR RS E-Invoice Status".FromInteger(GetInvoiceStatusIndexFromText(StatusDictionary.Get(InvoiceId)));
                RSEInvoiceDocument.Modify();
                RSEInvoiceMgt.SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
            end
        end;
    end;

    local procedure ProcessGetPurchaseDocumentStatusResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text)
    var
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
    begin
        JsonHeader.ReadFrom(ResponseText);
        if not JsonHeader.Get('Status', JsonToken) then
            Error(JSONReadErr);
        RSEInvoiceDocument."Invoice Status" := "NPR RS E-Invoice Status".FromInteger(GetInvoiceStatusIndexFromText(JsonToken.AsValue().AsText()));
        RSEInvoiceDocument.Modify();
        RSEInvoiceMgt.SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);

        Commit();
    end;

    local procedure ProcessAcceptIncomingPurchaseDocumentResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text): Boolean
    var
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
    begin
        JsonHeader.ReadFrom(ResponseText);
        if not JsonHeader.Get('Success', JsonToken) then
            Error(JSONReadErr);

        if (JsonToken.AsValue().AsBoolean()) then begin
            RSEInvoiceDocument."Invoice Status" := RSEInvoiceDocument."Invoice Status"::APPROVED;
            RSEInvoiceMgt.SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
            exit(RSEInvoiceDocument.Modify());
        end
        else begin
            JsonHeader.Get('Message', JsonToken);
            Message(JsonToken.AsValue().AsText());
            exit(false);
        end;
    end;

    local procedure ProcessRejectIncomingPurchaseDocumentResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text): Boolean
    var
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
    begin
        JsonHeader.ReadFrom(ResponseText);
        if not JsonHeader.Get('Success', JsonToken) then
            Error(JSONReadErr);

        if (JsonToken.AsValue().AsBoolean()) then begin
            RSEInvoiceDocument."Invoice Status" := RSEInvoiceDocument."Invoice Status"::REJECTED;
            RSEInvoiceMgt.SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
            exit(RSEInvoiceDocument.Modify());
        end
        else begin
            JsonHeader.Get('Message', JsonToken);
            Message(JsonToken.AsValue().AsText());
            exit(false);
        end;
    end;

    local procedure ProcessCancelIncomingPurchaseDocumentResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text): Boolean
    var
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
    begin
        JsonHeader.ReadFrom(ResponseText);
        if not JsonHeader.Get('Status', JsonToken) then
            Error(JSONReadErr);

        RSEInvoiceDocument."Invoice Status" := "NPR RS E-Invoice Status".FromInteger(GetInvoiceStatusIndexFromText(JsonToken.AsValue().AsText()));
        RSEInvoiceMgt.SetPurchaseAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
        exit(RSEInvoiceDocument.Modify());
    end;

    #endregion RS EI Purchase Invoice Communication Mgt.

    #region RS EI Sales Invoice Communication Mgt.
    internal procedure SendSalesDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        RequestText: Text;
        ResponseText: Text;
        Url: Text;
        SendSalesDocumentPathLbl: Label '/api/publicAPi/sales-invoice/ubl?requestId=%1&sendToCir=%2&executeValidation=%3', Locked = true, Comment = '%1 = Request Id, %2 = Should be sent to CIR, %3 = Should Validation Be Executed';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        RSEInvoiceDocument."Request ID" := CreateGuid();
        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(SendSalesDocumentPathLbl, RSEInvoiceDocument."Request ID", RSEInvoiceDocument."CIR Invoice", 'false'));

        RequestText := RSEInvoiceDocument.GetRequestContent();
        SetRequestMessageContent(RequestMessage, RequestText, HttpMethod::POST, 'application/xml', Url, RSEInvoiceSetup."API Key", true);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessSendSalesInvoiceDocumentResponse(RSEInvoiceDocument, ResponseText)
        else
            RSEInvoiceDocument.Delete();
    end;

    internal procedure RefreshSalesDocumentStatus(DateChange: Date)
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        RefreshSalesDocumentStatusPathLbl: Label '/api/publicApi/sales-invoice/changes?date=%1', Locked = true, Comment = '%1 = Date of status change';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(RefreshSalesDocumentStatusPathLbl, Format(DateChange, 10, '<Year4>-<Month,2>-<Day,2>')));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::POST, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessRefreshSalesDocumentStatusResponse(ResponseText);
    end;

    internal procedure GetSalesDocumentStatus(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        Url: Text;
        ResponseText: Text;
        GetSalesInvoiceDocumentStatusPathLbl: Label '/api/publicApi/sales-invoice?invoiceId=%1', Locked = true, Comment = '%1 = Invoice Id';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", StrSubstNo(GetSalesInvoiceDocumentStatusPathLbl, Format(RSEInvoiceDocument."Sales Invoice ID")));

        SetRequestMessageContent(RequestMessage, '', HttpMethod::GET, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            ProcessGetSalesDocumentStatusResponse(RSEInvoiceDocument, ResponseText);
    end;

    internal procedure ResendSalesDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    begin
        SendSalesDocument(RSEInvoiceDocument);
        GetSalesDocumentStatus(RSEInvoiceDocument);
    end;

    internal procedure CancelSalesInvoiceDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        InputDialog: Page "NPR Input Dialog";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        JsonObj: JsonObject;
        Url: Text;
        RequestText: Text;
        ResponseText: Text;
        CancelSalesInvoiceDocumentPathLbl: Label '/api/publicApi/sales-invoice/cancel', Locked = true;
        CannotCancelIfIsApprovedErr: Label 'You cannot cancel an invoice that has already been approved.';
        ShouldCancelInvoiceQst: Label 'Are you sure you want to cancel this invoice?';
        CancelingComment: Text;
        CancelingCommentLbl: Label 'Comment for Canceling Invoice Document';
        CancelingCommentEmptyErr: Label 'Comment must not be empty';
        CancelingSuccessfullMsg: Label 'You have successfully cancelled the invoice.';
    begin
        if RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::APPROVED] then
            Error(CannotCancelIfIsApprovedErr);

        if not (ConfirmManagement.GetResponseOrDefault(ShouldCancelInvoiceQst, false)) then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        InputDialog.SetInput(1, CancelingComment, CancelingCommentLbl);
        InputDialog.RunModal();
        InputDialog.InputText(1, CancelingComment);

        if CancelingComment = '' then
            Error(CancelingCommentEmptyErr);

        JsonObj.Add('invoiceId', RSEInvoiceDocument."Sales Invoice ID");
        JsonObj.Add('cancelComments', CancelingComment);
        JsonObj.WriteTo(RequestText);

        Url := FormatUrl(RSEInvoiceSetup."API URL", CancelSalesInvoiceDocumentPathLbl);

        SetRequestMessageContent(RequestMessage, RequestText, HttpMethod::POST, 'application/json', Url, RSEInvoiceSetup."API Key", true);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            if ProcessCancelIncomingPurchaseDocumentResponse(RSEInvoiceDocument, ResponseText) then
                Message(CancelingSuccessfullMsg);
    end;

    local procedure ProcessSendSalesInvoiceDocumentResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text)
    var
        JsonHeader: JsonObject;
        JsonTok: JsonToken;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        JsonHeader.Get('SalesInvoiceId', JsonTok);
        Evaluate(RSEInvoiceDocument."Sales Invoice ID", JsonTok.AsValue().AsText());

        JsonHeader.Get('PurchaseInvoiceId', JsonTok);
        Evaluate(RSEInvoiceDocument."Purchase Invoice ID", JsonTok.AsValue().AsText());

        RSEInvoiceDocument."Sending Date" := Today();

        RSEInvoiceDocument.SetResponseContent(ResponseText);

        RSEInvoiceDocument.Modify();
    end;

    local procedure ProcessRefreshSalesDocumentStatusResponse(ResponseText: Text)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        TypeHelper: Codeunit "Type Helper";
        JsonArray: JsonArray;
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
        i: Integer;
        StatusDictionary: Dictionary of [Integer, Text];
        DateDictionary: Dictionary of [Integer, DateTime];
        DateTime: DateTime;
        InvoiceId: Integer;
        Status: Text;
        HelperText: Text;
        InvoiceIds: List of [Integer];
    begin
        if not JsonArray.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonHeader := JsonToken.AsObject();
            JsonHeader.Get('SalesInvoiceId', JsonToken);
            JsonToken.WriteTo(HelperText);
            HelperText := HelperText.Replace('"', '');
            Evaluate(InvoiceId, HelperText);
            JsonHeader.Get('NewInvoiceStatus', JsonToken);
            JsonToken.WriteTo(Status);
            Status := Status.Replace('"', '');
            JsonHeader.Get('Date', JsonToken);
            JsonToken.WriteTo(HelperText);
            HelperText := HelperText.Replace('"', '');
            Evaluate(DateTime, HelperText);
            case StatusDictionary.Add(InvoiceId, Status) of
                true:
                    DateDictionary.Add(InvoiceId, DateTime);
                false:
                    if TypeHelper.CompareDateTime(DateDictionary.Get(InvoiceId), DateTime) = -1 then begin
                        DateDictionary.Set(InvoiceId, DateTime);
                        StatusDictionary.Set(InvoiceId, Status);
                    end
            end;
        end;

        InvoiceIds := StatusDictionary.Keys();

        foreach InvoiceId in InvoiceIds do begin
            RSEInvoiceDocument.SetRange("Sales Invoice ID", InvoiceId);
            if RSEInvoiceDocument.FindFirst() then begin
                RSEInvoiceDocument."Invoice Status" := "NPR RS E-Invoice Status".FromInteger(GetInvoiceStatusIndexFromText(StatusDictionary.Get(InvoiceId)));
                RSEInvoiceDocument.Modify();
                RSEInvoiceMgt.SetSalesAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
            end
        end;
    end;

    local procedure ProcessGetSalesDocumentStatusResponse(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; ResponseText: Text)
    var
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
    begin
        if not JsonHeader.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        JsonHeader.Get('Status', JsonToken);
        RSEInvoiceDocument."Invoice Status" := "NPR RS E-Invoice Status".FromInteger(GetInvoiceStatusIndexFromText(JsonToken.AsValue().AsText()));
        RSEInvoiceDocument.Modify();

        RSEInvoiceMgt.SetSalesAuxTablesStatusForInvoiceDocument(RSEInvoiceDocument);
    end;

    #endregion RS EI Sales Invoice Communication Mgt.

    #region RS EI Allowed UOMs
    internal procedure GetAllowedUOMs()
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
        GetAllowedUOMsPathLbl: Label '/api/publicApi/get-unit-measures', Locked = true;
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", GetAllowedUOMsPathLbl);

        SetRequestMessageContent(RequestMessage, '', HttpMethod::GET, 'application/json', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, false) then
            FillAllowedUOMs(ResponseText);
    end;

    local procedure FillAllowedUOMs(ResponseText: Text)
    var
        JsonArray: JsonArray;
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
        AllowedUOMUpdateMsg: Label 'Allowed Units of Measure have been updated.';
        i: Integer;
        UOMsDictionary: Dictionary of [Code[10], Text[10]];
        UOMCode: Text;
        UOMName: Text;
    begin
        if not JsonArray.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        if JsonArray.Count = 0 then
            Error(JSONReadErr);

        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonHeader := JsonToken.AsObject();
            JsonHeader.Get('Code', JsonToken);
            JsonToken.WriteTo(UOMCode);
            UOMCode := UOMCode.Replace('"', '');
            JsonHeader.Get('NameSrbLtn', JsonToken);
            JsonToken.WriteTo(UOMName);
            UOMName := UOMName.Replace('"', '');
            UOMsDictionary.Add(CopyStr(UOMCode, 1, 10), CopyStr(UOMName, 1, 10));
        end;

        if UOMsDictionary.Count = 0 then
            exit;

        UpdateAllowedUOMs(UOMsDictionary);
        Message(AllowedUOMUpdateMsg);
    end;

    local procedure UpdateAllowedUOMs(UOMsDictionary: Dictionary of [Code[10], Text[10]])
    var
        AllowedUOM: Record "NPR RS EI Allowed UOM";
        i: Integer;
        CodeKeys: List of [Code[10]];
        NameVals: List of [Text[10]];
    begin
        AllowedUOM.DeleteAll();

        CodeKeys := UOMsDictionary.Keys;
        NameVals := UOMsDictionary.Values;

        for i := 1 to UOMsDictionary.Count do begin
            AllowedUOM.Init();
            AllowedUOM.Code := CodeKeys.Get(i);
            AllowedUOM.Name := NameVals.Get(i);
            AllowedUOM."Configuration Date" := Today();
            AllowedUOM.Insert();
        end;
    end;
    #endregion RS EI Allowed UOMs

    #region RS EI Tax Exemption Reason List
    internal procedure GetTaxExemptionReasonList()
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        HttpMethod: Enum "Http Method";
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Url: Text;
        GetTaxExemptionListPathLbl: Label '/api/publicApi/sales-invoice/getValueAddedTaxExemptionReasonList', Locked = true;
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        RSEInvoiceSetup.GetRSEInvoiceSetupWithCheck();

        Url := FormatUrl(RSEInvoiceSetup."API URL", GetTaxExemptionListPathLbl);

        SetRequestMessageContent(RequestMessage, '', HttpMethod::GET, 'application/xml', Url, RSEInvoiceSetup."API Key", false);

        if SendHttpRequest(RequestMessage, ResponseText, true) then
            FillTaxExemptionReasonList(ResponseText);
    end;

    local procedure FillTaxExemptionReasonList(ResponseText: Text)
    var
        RSEITaxExemptionReason: Record "NPR RS EI Tax Exemption Reason";
        JsonArray: JsonArray;
        JsonHeader: JsonObject;
        JsonToken: JsonToken;
        TaxExemptionReasonListUpdateMsg: Label 'Tax Exemption Reason List has been updated.';
        i: Integer;
        ReasonKey: Text;
        ExemptCategory: Text;
        ExemptText: Text;
    begin
        if not JsonArray.ReadFrom(ResponseText) then
            Error(JSONReadErr);

        if JsonArray.Count = 0 then
            Error(JSONReadErr);

        RSEITaxExemptionReason.DeleteAll();
        for i := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(i, JsonToken);
            JsonHeader := JsonToken.AsObject();

            JsonHeader.Get('Key', JsonToken);
            JsonToken.WriteTo(ReasonKey);
            ReasonKey := ReasonKey.Replace('"', '');

            JsonHeader.Get('Category', JsonToken);
            JsonToken.WriteTo(ExemptCategory);
            ExemptCategory := ExemptCategory.Replace('"', '');

            JsonHeader.Get('Text', JsonToken);
            JsonToken.WriteTo(ExemptText);
            ExemptText := ExemptText.Replace('"', '');

            RSEITaxExemptionReason.Init();
            RSEITaxExemptionReason."Configuration Date" := Today();
            RSEITaxExemptionReason."Tax Exemption Reason Code" := CopyStr(ReasonKey, 1, MaxStrLen(RSEITaxExemptionReason."Tax Exemption Reason Code"));
            RSEITaxExemptionReason."Tax Category" := CopyStr(ExemptCategory, 1, MaxStrLen(RSEITaxExemptionReason."Tax Category"));
            RSEITaxExemptionReason."Tax Exemption Reason Text" := CopyStr(ExemptText, 1, MaxStrLen(RSEITaxExemptionReason."Tax Exemption Reason Text"));
            RSEITaxExemptionReason.Insert();
        end;

        Message(TaxExemptionReasonListUpdateMsg);
    end;
    #endregion RS EI Tax Exemption Reason List

    #region RS EI HTTP Request

    local procedure SendHttpRequest(var RequestMessage: HttpRequestMessage; var ResponseText: Text; SkipErrorMessage: Boolean): Boolean
    var
        IsResponseSuccess: Boolean;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ErrorText: Text;
    begin
        IsResponseSuccess := Client.Send(RequestMessage, ResponseMessage);
        if (not IsResponseSuccess) then
            if SkipErrorMessage then
                exit(IsResponseSuccess)
            else
                Error(GetLastErrorText);

        IsResponseSuccess := ResponseMessage.IsSuccessStatusCode();
        if (not IsResponseSuccess) and (not SkipErrorMessage) and GuiAllowed then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;
        ResponseMessage.Content.ReadAs(ResponseText);
        exit(IsResponseSuccess);
    end;

    #endregion RS EI HTTP Request

    #region RS E-Invoice Helper Procedures
    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);

        Headers.Add(HeaderName, HeaderValue);
    end;

    local procedure SetRequestMessageContent(var HttpRequestMessage: HttpRequestMessage; RequestContent: Text; HttpMethod: Enum "Http Method"; ContentType: Text; Url: Text; ApiKey: Text[100]; SetRequestContent: Boolean)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        if SetRequestContent then
            Content.WriteFrom(RequestContent);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', ContentType);
        SetHeader(Headers, 'Apikey', ApiKey);

        HttpRequestMessage.SetRequestUri(Url);
        HttpRequestMessage.Method(Format(HttpMethod));
        HttpRequestMessage.Content(Content);
    end;

    local procedure FormatUrl(Url: Text; Path: Text): Text
    begin
        if Url.EndsWith('/') then
            exit(Url + Path.TrimStart('/'))
        else
            exit(Url + Path);
    end;

    local procedure GetInvoiceStatusIndexFromText(EnumText: Text): Integer
    var
        EnumIndex: Integer;
    begin
        EnumIndex := "NPR RS E-Invoice Status".Names().IndexOf(UpperCase(EnumText));
        if EnumIndex > 0 then
            EnumIndex -= 1;
        exit(EnumIndex);
    end;

    #endregion RS E-Invoice Helper Procedures
#endif
}