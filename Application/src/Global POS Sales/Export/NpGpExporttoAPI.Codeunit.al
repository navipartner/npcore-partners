#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248268 "NPR NpGp Export to API"
{
    Access = Internal;
    trigger OnRun()
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGpPOSSalesSetup.FindSet() then
            repeat
                ExportNpGpPOSSalesSetup(NpGpPOSSalesSetup);
            until NpGpPOSSalesSetup.Next() = 0;
    end;

    procedure InitExportControl(POSSalesSetupCode: Code[10])
    var
        NpGpExportControl: Record "NPR NpGp Export Control";
    begin
        if NpGpExportControl.Get(POSSalesSetupCode) then
            exit;
        NpGpExportControl."POS Sales Setup Code" := POSSalesSetupCode;
        NpGpExportControl.Insert(true);
    end;

    procedure ExportLogEntry(EntryNo: Integer)
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        NpGpExportLog: Record "NPR NpGp Export Log";
    begin
        NpGpExportLog.ReadIsolation := IsolationLevel::UpdLock;
        NpGpExportLog.Get(EntryNo);
        if NpGpExportLog.Sent then
            exit;
        NpGpPOSSalesSetup.Get(NpGpExportLog."POS Sales Setup Code");
        NpGpPOSSalesSetup.TestField("Use api");
        ExportAndUpdateLogEntry(NpGpPOSSalesSetup, NpGpExportLog);
        Commit();
    end;

    procedure CreateExportProcessingJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueCategoryCode: Code[10];
        DescriptionLbl: Label 'Processes Export of POS Entries to Global Sale';
        StartDateTime: DateTime;
    begin
        StartDateTime := JobQueueManagement.NowWithDelayInSeconds(5);
        JobQueueCategoryCode := GetJobQueueCategoryCode();

        JobQueueManagement.SetMaxNoOfAttemptsToRun(10);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR NpGp Export to API",
                '',
                DescriptionLbl,
                StartDateTime,
                15,
                JobQueueCategoryCode,
                JobQueueEntry));
    end;

    local procedure ExportNpGpPOSSalesSetup(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        if not NpGpPOSSalesSetup."Use api" then
            exit;
        NpGpPOSSalesSetup.TestField("OData Base Url");
        ProcessFailed(NpGpPOSSalesSetup);
        InitExportControl(NpGpPOSSalesSetup.Code);
        ExportPOSEntries(NpGpPOSSalesSetup);
    end;

    local procedure ExportPOSEntries(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        NpGpExportControl: Record "NPR NpGp Export Control";
        NpGpExportLog: Record "NPR NpGp Export Log";
        POSEntry: Record "NPR POS Entry";
        Completed: Boolean;
    begin
        repeat
            NpGpExportControl.ReadIsolation(IsolationLevel::UpdLock);
            NpGpExportControl.Get(NpGpPOSSalesSetup.Code);
            POSEntry.SetFilter("Entry No.", '>%1', NpGpExportControl."Last Entry No. Exported");
            POSEntry.SetCurrentKey("Entry No.");
            Completed := not POSEntry.FindFirst();
            if not Completed then begin
                NpGpExportLog := InsertLogEntry(NpGpPOSSalesSetup.Code, POSEntry."Entry No.");
                ExportAndUpdateLogEntry(NpGpPOSSalesSetup, NpGpExportLog);
                UpdateExportControl(NpGpExportControl, POSEntry."Entry No.");
                Commit();
            end;
        until Completed;
    end;

    local procedure ProcessFailed(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        NpGpExportLog: Record "NPR NpGp Export Log";
    begin
        NpGpExportLog.SetRange("POS Sales Setup Code", NpGpPOSSalesSetup.Code);
        NpGpExportLog.SetRange(Failed, true);
        NpGpExportLog.SetFilter("Next Resend", '<=%1', CurrentDateTime);
        if NpGpExportLog.FindSet() then
            repeat
                ExportLogEntry(NpGpPOSSalesSetup, NpGpExportLog."Entry No");
                Commit();
            until NpGpExportLog.Next() = 0;
    end;

    local procedure InsertLogEntry(SetupCode: Code[10]; EntryNo: Integer) NpGpExportLog: Record "NPR NpGp Export Log";
    begin
        NpGpExportLog.Init();
        NpGpExportLog."Entry No" := 0;
        NpGpExportLog."POS Entry No." := EntryNo;
        NpGpExportLog."POS Sales Setup Code" := SetupCode;
        NpGpExportLog.Insert(true);
    end;

    local procedure UpdateExportControl(var NpGpExportControl: Record "NPR NpGp Export Control"; EntryNo: Integer)
    begin
        NpGpExportControl."Last Entry No. Exported" := EntryNo;
        NpGpExportControl."Last Exported Date" := CurrentDateTime;
        NpGpExportControl.Modify(true);
    end;

    local procedure ExportLogEntry(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; EntryNo: Integer)
    var
        NpGpExportLog: Record "NPR NpGp Export Log";
    begin
        NpGpExportLog.ReadIsolation := IsolationLevel::UpdLock;
        NpGpExportLog.Get(EntryNo);
        if NpGpExportLog.Sent then
            exit;
        ExportAndUpdateLogEntry(NpGpPOSSalesSetup, NpGpExportLog);
        Commit();
    end;

    local procedure ExportAndUpdateLogEntry(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; NpGpExportLog: Record "NPR NpGp Export Log")
    begin
        if ExportPOSEntry(NpGpPOSSalesSetup, NpGpExportLog) then
            LogSuccess(NpGpExportLog)
        else
            LogError(NpGpExportLog, GetLastErrorText());
    end;

    local procedure LogSuccess(var NpGpExportLog: Record "NPR NpGp Export Log")
    begin
        NpGpExportLog.Sent := true;
        NpGpExportLog.Failed := false;
        NpGpExportLog."Last Error Text" := '';
        NpGpExportLog.Modify(true);
    end;

    local procedure LogError(var NpGpExportLog: Record "NPR NpGp Export Log"; ErrorText: Text)
    begin
        NpGpExportLog.Sent := false;
        NpGpExportLog.Failed := true;
        NpGpExportLog."Last Error Text" := CopyStr(ErrorText, 1, MaxStrLen(NpGpExportLog."Last Error Text"));
        NpGpExportLog."Retry Count" += 1;
        NpGpExportLog.SetNextResend();
        NpGpExportLog.Modify(true);
    end;

    [TryFunction]
    local procedure ExportPOSEntry(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; NpGpExportLog: Record "NPR NpGp Export Log")
    var
        POSEntry: Record "NPR POS Entry";
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        JsonRequest: JsonObject;
        JsonText: Text;
        Response: Text;

    begin
        POSEntry.ReadIsolation(IsolationLevel::ReadCommitted);
        if not POSEntry.Get(NpGpExportLog."POS Entry No.") then
            exit;
        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Direct Sale"]) then
            exit;

        JsonRequest := InitODataReqBody(POSEntry);
        APIPOSGlobalEntryext.OnAfterInitRequestBody(POSEntry, JsonRequest);
        JsonRequest.WriteTo(JsonText);
        RequestMessage.Content.WriteFrom(JsonText);

        RequestMessage.GetHeaders(RequestHeaders);
        RequestMessage.Content.GetHeaders(ContentHeaders);

        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        if NpGpPOSSalesSetup."Environment Type" = NpGpPOSSalesSetup."Environment Type"::Crane then
            ContentHeaders.Add('x-npr-api-remote-type', 'crane');
        ContentHeaders.Add('x-api-version', Format(20250201D, 0, 9));

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."OData Base Url".TrimEnd('/') + '/pos/globalentry');
        RequestMessage.Method := 'POST';

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            if ResponseMessage.Content.ReadAs(Response) then begin
                if (ResponseMessage.HttpStatusCode <> 400) or (not IsDuplicateKeyResponse(Response)) then
                    Error('%1 %2\%3', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, Response);
            end else
                Error('%1 %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
        end;
    end;

    local procedure InitODataReqBody(POSEntry: Record "NPR POS Entry"): JsonObject
    var
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        JsonBuilder: Codeunit "NPR Json Builder";
        ExtensionFieldsData: Dictionary of [Integer, Text];
    begin
        APIPOSGlobalEntryExt.SetPOSEntryExtensionData(POSEntry, ExtensionFieldsData);
        JsonBuilder.StartObject()
            .AddProperty('posStore', POSEntry."POS Store Code")
            .AddProperty('posUnit', POSEntry."POS Unit No.")
            .AddProperty('documentNo', POSEntry."Document No.")
            .AddProperty('entryTime', Format(CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time"), 0, 9))
            .AddProperty('entryType', Format(POSEntry."Entry Type", 0, 2))
            .AddProperty('postingDate', Format(POSEntry."Posting Date", 0, 9))
            .AddProperty('fiscalNumber', POSEntry."Fiscal No.")
            .AddProperty('salesAmount', Format(POSEntry."Item Sales (LCY)", 0, 9))
            .AddProperty('discountAmount', Format(POSEntry."Discount Amount", 0, 9))
            .AddProperty('totalAmountExclVAT', Format(POSEntry."Amount Excl. Tax", 0, 9))
            .AddProperty('totalAmountInclVAT', Format(POSEntry."Amount Incl. Tax", 0, 9))
            .AddProperty('totalVATAmount', Format(POSEntry."Tax Amount", 0, 9))
            .AddProperty('company', CompanyName)
            .AddProperty('customerNo', POSEntry."Customer No.")
            .AddProperty('salesperson', POSEntry."Salesperson Code")
            .AddProperty('currencyCode', POSEntry."Currency Code")
            .AddProperty('currencyFactor', Format(POSEntry."Currency Factor", 0, 9))
            .AddArray(SalesLinesODate(JsonBuilder, POSEntry))
            .AddArray(PaymentLinesODate(JsonBuilder, POSEntry))
            .AddArray(POSInfoODate(JsonBuilder, POSEntry))
            .AddArray(ExtensionFields(JsonBuilder, ExtensionFieldsData))
        .EndObject();
        exit(JsonBuilder.Build());
    end;

    local procedure SalesLinesODate(JsonBuilder: Codeunit "NPR Json Builder"; POSEntry: Record "NPR POS Entry"): Codeunit "NPR Json Builder"
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSCrossReference: Record "NPR POS Cross Reference";
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        ExtensionFieldsData: Dictionary of [Integer, Text];
    begin
        JsonBuilder.StartArray('salesLines');
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSSalesLine.FindSet() then
            repeat
                if not POSCrossReference.GetBySystemId(POSSalesLine.SystemId) then
                    POSCrossReference.Init();
                APIPOSGlobalEntryExt.SetPOSEntrySalesLineExtensionData(POSSalesLine, ExtensionFieldsData);
                JsonBuilder.StartObject()
                    .AddProperty('lineNo', Format(POSSalesLine."Line No.", 0, 9))
                    .AddProperty('type', Format(POSSalesLine.Type, 0, 2))
                    .AddProperty('code', POSSalesLine."No.")
                    .AddProperty('quantity', Format(POSSalesLine.Quantity, 0, 9))
                    .AddProperty('baseQuantity', Format(POSSalesLine."Quantity (Base)", 0, 9))
                    .AddProperty('unitPrice', Format(POSSalesLine."Unit Price", 0, 9))
                    .AddProperty('vatPct', Format(POSSalesLine."VAT %", 0, 9))
                    .AddProperty('lineDiscountPct', Format(POSSalesLine."Line Discount %", 0, 9))
                    .AddProperty('lineDiscountAmountExclVAT', Format(POSSalesLine."Line Discount Amount Excl. VAT", 0, 9))
                    .AddProperty('lineDiscountAmountInclVAT', Format(POSSalesLine."Line Discount Amount Incl. VAT", 0, 9))
                    .AddProperty('lineAmount', Format(POSSalesLine."Line Amount", 0, 9))
                    .AddProperty('amountExclVAT', Format(POSSalesLine."Amount Excl. VAT", 0, 9))
                    .AddProperty('amountInclVAT', Format(POSSalesLine."Amount Incl. VAT", 0, 9))
                    .AddProperty('lineDiscountAmountExclVATLCY', Format(POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)", 0, 9))
                    .AddProperty('lineDiscountAmountInclVATLCY', Format(POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)", 0, 9))
                    .AddProperty('amountExclVATLCY', Format(POSSalesLine."Amount Excl. VAT (LCY)", 0, 9))
                    .AddProperty('amountInclVATLCY', Format(POSSalesLine."Amount Incl. VAT (LCY)", 0, 9))
                    .AddProperty('variantCode', POSSalesLine."Variant Code")
                    .AddProperty('referenceNumber', POSSalesLine."Cross-Reference No.")
                    .AddProperty('bomItemCode', POSSalesLine."BOM Item No.")
                    .AddProperty('locationCode', POSSalesLine."Location Code")
                    .AddProperty('description', POSSalesLine.Description)
                    .AddProperty('description2', POSSalesLine."Description 2")
                    .AddProperty('unitOfMeasureCode', POSSalesLine."Unit of Measure Code")
                    .AddProperty('currencyCode', POSSalesLine."Currency Code")
                    .AddProperty('globalReference', POSCrossReference."Reference No.")
                    .AddArray(ExtensionFields(JsonBuilder, ExtensionFieldsData))
                .EndObject();
            until POSSalesLine.Next() = 0;
        JsonBuilder.EndArray();
        exit(JsonBuilder);
    end;

    local procedure PaymentLinesODate(JsonBuilder: Codeunit "NPR Json Builder"; POSEntry: Record "NPR POS Entry"): Codeunit "NPR Json Builder"
    var
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        ExtensionFieldsData: Dictionary of [Integer, Text];
    begin
        JsonBuilder.StartArray('paymentLines');

        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSPaymentLine.FindSet() then
            repeat
                APIPOSGlobalEntryExt.SetPOSEntryPaymentLineExtensionData(POSPaymentLine, ExtensionFieldsData);
                JsonBuilder.StartObject()
                    .AddProperty('lineNo', Format(POSPaymentLine."Line No.", 0, 9))
                    .AddProperty('paymentMethod', POSPaymentLine."POS Payment Method Code")
                    .AddProperty('amountLCY', Format(POSPaymentLine."Payment Amount", 0, 9))
                    .AddProperty('amount', Format(POSPaymentLine."Amount (LCY)", 0, 9))
                    .AddProperty('documentNo', POSPaymentLine."Document No.")
                    .AddProperty('description', POSPaymentLine.Description)
                    .AddProperty('currencyCode', POSPaymentLine."Currency Code")
                    .AddArray(ExtensionFields(JsonBuilder, ExtensionFieldsData))
                .EndObject();
            until POSPaymentLine.Next() = 0;
        JsonBuilder.EndArray();
        exit(JsonBuilder);
    end;

    local procedure POSInfoODate(JsonBuilder: Codeunit "NPR Json Builder"; POSEntry: Record "NPR POS Entry"): Codeunit "NPR Json Builder"
    var
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        ExtensionFieldsData: Dictionary of [Integer, Text];

    begin
        JsonBuilder.StartArray('posInfos');
        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSInfoPOSEntry.FindSet() then
            repeat
                APIPOSGlobalEntryExt.SetPOSInfoPOSEntryExtensionData(POSInfoPOSEntry, ExtensionFieldsData);
                JsonBuilder.StartObject()
                    .AddProperty('lineNo', Format(POSInfoPOSEntry."Entry No.", 0, 9))
                    .AddProperty('infoCode', POSInfoPOSEntry."POS Info Code")
                    .AddProperty('saleLineNo', Format(POSInfoPOSEntry."Sales Line No.", 0, 9))
                    .AddProperty('description', POSInfoPOSEntry."POS Info")
                    .AddProperty('code', POSInfoPOSEntry."No.")
                    .AddProperty('quantity', Format(POSInfoPOSEntry.Quantity, 0, 9))
                    .AddProperty('price', Format(POSInfoPOSEntry.Price, 0, 9))
                    .AddProperty('netAmount', Format(POSInfoPOSEntry."Net Amount", 0, 9))
                    .AddProperty('grossAmount', Format(POSInfoPOSEntry."Gross Amount", 0, 9))
                    .AddProperty('discountAmount', Format(POSInfoPOSEntry."Discount Amount", 0, 9))
                    .AddArray(ExtensionFields(JsonBuilder, ExtensionFieldsData))
                .EndObject();
            until POSInfoPOSEntry.Next() = 0;

        JsonBuilder.EndArray();
        exit(JsonBuilder);
    end;

    local procedure ExtensionFields(JsonBuilder: Codeunit "NPR Json Builder"; ExtensionFieldsData: Dictionary of [Integer, Text]): Codeunit "NPR Json Builder"
    var
        FieldId: Integer;
    begin
        JsonBuilder.StartArray('extensionFields');
        foreach FieldId in ExtensionFieldsData.Keys() do begin
            JsonBuilder.StartObject()
                .AddProperty('fieldId', FieldId)
                .AddProperty('fieldValue', ExtensionFieldsData.Get(FieldId))
            .EndObject();
        end;
        JsonBuilder.EndArray();
        exit(JsonBuilder);
    end;

    local procedure IsDuplicateKeyResponse(Response: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        APIErrorCode: Enum "NPR API Error Code";
        JObject: JsonObject;
    begin
        if not JObject.ReadFrom(Response) then
            exit(false);
        APIErrorCode := "NPR API Error Code"::globalsale_duplicate_key;
        exit(JsonHelper.GetJText(JObject.AsToken(), 'code', false) = APIErrorCode.Names.Get(APIErrorCode.Ordinals.IndexOf(APIErrorCode.AsInteger())));
    end;

    local procedure GetJobQueueCategoryCode() JobQueueCategoryCode: Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueCategoryCodeLbl: Label 'NPR-NPGP', Locked = true, MaxLength = 10;
        JobQueueCategoryDescriptionLbl: Label 'NPR Global Sale';
    begin
        JobQueueCategory.InsertRec(JobQueueCategoryCodeLbl, JobQueueCategoryDescriptionLbl);
        JobQueueCategoryCode := JobQueueCategoryCodeLbl;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        NpGpPOSSalesSetup.SetRange("Use api", true);
        if NpGpPOSSalesSetup.IsEmpty then
            exit;
        if CreateExportProcessingJobQueueEntry(JobQueueEntry) then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = Codeunit::"NPR NpGp Export to API")
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

}
#endif