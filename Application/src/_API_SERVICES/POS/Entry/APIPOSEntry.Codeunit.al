#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248620 "NPR API POS Entry"
{
    Access = Internal;

    internal procedure ListEntries(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSEntry: Record "NPR POS Entry";
        JsonArray: Codeunit "NPR Json Builder";
        Params: Dictionary of [Text, Text];
        WithLines: Boolean;
        POSStoreFilter: Text;
        POSUnitFilter: Text;
        DocumentNoFilter: Text;
        PageSize: Integer;
        PageContinuation: Boolean;
        RecRef: RecordRef;
        DataFound: Boolean;
        MoreRecords: Boolean;
        Itt: Integer;
        PageKey: Text;
        JObject: JsonObject;
        SyncMode: Boolean;
        LastRowVersion: BigInteger;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        Params := Request.QueryParams();

        if (Params.Get('posStore', POSStoreFilter)) then
            POSEntry.SetRange("POS Store Code", POSStoreFilter);
        if (Params.Get('posUnit', POSUnitFilter)) then
            POSEntry.SetRange("POS Unit No.", POSUnitFilter);
        if (Params.Get('documentNo', DocumentNoFilter)) then
            POSEntry.SetRange("Document No.", DocumentNoFilter);

        POSEntry.SetFilter("Entry Type", '<>%1', POSEntry."Entry Type"::Other);

        if Params.ContainsKey('withLines') then
            Evaluate(WithLines, Params.Get('withLines'));

        if Params.ContainsKey('sync') then
            Evaluate(SyncMode, Params.Get('sync'));

        if SyncMode then begin
            RecRef.GetTable(POSEntry);
            Request.SetKeyToRowVersion(RecRef);
            RecRef.SetTable(POSEntry);
            Evaluate(LastRowVersion, Params.Get('lastRowVersion'));
            POSEntry.SetFilter(SystemRowVersion, '>%1', LastRowVersion);
        end;

        if (Params.ContainsKey('pageSize')) then
            Evaluate(PageSize, Params.Get('pageSize'))
        else
            PageSize := 50;

        if PageSize > 100 then
            PageSize := 100;
        if PageSize < 1 then
            PageSize := 1;

        if (Params.ContainsKey('pageKey')) then begin
            RecRef.GetTable(POSEntry);
            Request.ApplyPageKey(Params.Get('pageKey'), RecRef);
            RecRef.SetTable(POSEntry);
            PageContinuation := true;
        end;

        JsonArray.StartArray();

        POSEntry.SetLoadFields(
            POSEntry."Entry No.",
            POSEntry."Document No.",
            POSEntry."Fiscal No.",
            POSEntry."Entry Date",
            POSEntry."Starting Time",
            POSEntry."Ending Time",
            POSEntry."POS Store Code",
            POSEntry."POS Unit No.",
            POSEntry."Entry Type",
            POSEntry.Description,
            POSEntry."Customer No.",
            POSEntry."Salesperson Code",
            POSEntry."Amount Incl. Tax & Round",
            POSEntry."Tax Amount",
            POSEntry."Post Entry Status",
            POSEntry."Post Item Entry Status",
            POSEntry."Posting Date",
            POSEntry."Document Date",
            POSEntry."External Document No.",
            POSEntry.SystemId
        );
        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;

        if (PageContinuation) then
            DataFound := POSEntry.Find('>')
        else
            DataFound := POSEntry.Find('-');

        if (DataFound) then
            repeat
                JsonArray.AddObject(EntryToJson(JsonArray, POSEntry, WithLines, SyncMode));
                Itt += 1;
                if (Itt = PageSize) then begin
                    RecRef.GetTable(POSEntry);
                    PageKey := Request.GetPageKey(RecRef);
                end;
                MoreRecords := POSEntry.Next() <> 0;
            until (not MoreRecords) or (Itt = PageSize);

        JsonArray.EndArray();

        JObject.Add('morePages', MoreRecords);
        JObject.Add('nextPageKey', PageKey);
        JObject.Add('nextPageURL', Request.GetNextPageUrl(PageKey));
        JObject.Add('data', JsonArray.BuildAsArray());

        exit(Response.RespondOK(JObject));
    end;

    internal procedure PrintPosEntry(var Request: Codeunit "NPR API Request"; ReportSelectionType: Enum "NPR Report Selection Type") Response: Codeunit "NPR API Response"
    var
        POSEntry: Record "NPR POS Entry";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIPrintHandler: Codeunit "NPR API Retail Print Handler";
        HandlerAsInterface: Interface "NPR IRetail Print Handler";
        RetailReportSelectMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        entryId: Text;
        JsonResponse: JsonObject;
    begin
        entryId := Request.Paths().Get(3);
        if (entryId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: entryId'));

        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        if (not POSEntry.GetBySystemId(entryId)) then
            exit(Response.RespondResourceNotFound());

        HandlerAsInterface := APIPrintHandler;
        APIPrintHandler.InitSelfReference(HandlerAsInterface);
        BindSubscription(APIPrintHandler);

        case ReportSelectionType of
            ReportSelectionType::"Terminal Receipt":
                begin
                    EFTTransactionRequest.SetRange("Sales Ticket No.", POSEntry."Document No.");
                    EFTTransactionRequest.SetRange("Register No.", POSEntry."POS Unit No.");
                    if EFTTransactionRequest.FindSet() then
                        repeat
                            EFTTransactionRequest.PrintReceipts(true);
                        until EFTTransactionRequest.Next() = 0;
                end;
            ReportSelectionType::"Sales Receipt (POS Entry)":
                begin
                    if POSEntry.Get(POSEntry."Entry No.") then begin
                        RetailReportSelectMgt.SetRegisterNo(POSEntry."POS Unit No.");
                        RecRef.GetTable(POSEntry);
                        RecRef.SetRecFilter();
                        RetailReportSelectMgt.RunObjects(RecRef, ReportSelectionType.AsInteger());
                    end;
                end;
        end;

        JsonResponse.Add('entryId', Format(POSEntry.SystemId, 0, 4).ToLower());
        JsonResponse.Add('prints', APIPrintHandler.GetCapturedJobs());

        exit(Response.RespondOK(JsonResponse));
    end;

    internal procedure GetEntry(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSEntry: Record "NPR POS Entry";
        Json: Codeunit "NPR Json Builder";
        entryId: Text;
    begin
        entryId := Request.Paths().Get(3);
        if (entryId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: entryId'));

        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        POSEntry.SetLoadFields(
            POSEntry."Entry No.",
            POSEntry."Document No.",
            POSEntry."Fiscal No.",
            POSEntry."Entry Date",
            POSEntry."Starting Time",
            POSEntry."Ending Time",
            POSEntry."POS Store Code",
            POSEntry."POS Unit No.",
            POSEntry."Entry Type",
            POSEntry.Description,
            POSEntry."Customer No.",
            POSEntry."Salesperson Code",
            POSEntry."Amount Incl. Tax & Round",
            POSEntry."Tax Amount",
            POSEntry."Post Entry Status",
            POSEntry."Post Item Entry Status",
            POSEntry."Posting Date",
            POSEntry."Document Date",
            POSEntry."External Document No.",
            POSEntry.SystemId
        );
        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        if (not POSEntry.GetBySystemId(entryId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(EntryToJson(Json, POSEntry, true, false)));
    end;

    #region JSON serialization
    internal procedure EntryToJson(var Json: Codeunit "NPR Json Builder"; POSEntry: Record "NPR POS Entry"; WithLines: Boolean; SyncMode: Boolean): Codeunit "NPR Json Builder"
    var
        Customer: Record Customer;
        CustomerIdText: Text;
        RecRef: RecordRef;
    begin
        CustomerIdText := '';
        if (POSEntry."Customer No." <> '') then begin
            Customer.SetLoadFields("No.", SystemId);
            if (Customer.Get(POSEntry."Customer No.")) then
                CustomerIdText := Format(Customer.SystemId, 0, 4).ToLower();
        end;

        Json.StartObject()
            .AddProperty('entryId', Format(POSEntry.SystemId, 0, 4).ToLower());

        if SyncMode then begin
            RecRef.GetTable(POSEntry);
            Json.AddProperty('rowVersion', Format(POSEntry.SystemRowVersion));
        end;

        Json.AddProperty('entryNo', POSEntry."Entry No.")
            .AddProperty('documentNo', POSEntry."Document No.")
            .AddProperty('fiscalNo', POSEntry."Fiscal No.")
            .AddProperty('entryDate', POSEntry."Entry Date")
            .AddProperty('startingTime', POSEntry."Starting Time")
            .AddProperty('endingTime', POSEntry."Ending Time")
            .AddProperty('posStore', POSEntry."POS Store Code")
            .AddProperty('posUnit', POSEntry."POS Unit No.")
            .AddProperty('entryType', Format(POSEntry."Entry Type"))
            .AddProperty('description', POSEntry.Description)
            .AddProperty('customerNo', POSEntry."Customer No.")
            .AddProperty('customerId', CustomerIdText)
            .AddProperty('salespersonCode', POSEntry."Salesperson Code")
            .AddProperty('totalAmountInclVat', POSEntry."Amount Incl. Tax & Round")
            .AddProperty('taxAmount', POSEntry."Tax Amount")
            .AddProperty('postEntryStatus', Format(POSEntry."Post Entry Status"))
            .AddProperty('postItemEntryStatus', Format(POSEntry."Post Item Entry Status"))
            .AddProperty('postingDate', POSEntry."Posting Date")
            .AddProperty('documentDate', POSEntry."Document Date")
            .AddProperty('externalDocumentNo', POSEntry."External Document No.");

        if (WithLines) then begin
            AddSalesLinesToJson(Json, POSEntry."Entry No.");
            AddPaymentLinesToJson(Json, POSEntry."Entry No.");
            AddTaxLinesToJson(Json, POSEntry."Entry No.");
        end;

        Json.EndObject();
        exit(Json);
    end;

    local procedure AddSalesLinesToJson(var Json: Codeunit "NPR Json Builder"; EntryNo: Integer)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        Json.StartArray('salesLines');
        POSEntrySalesLine.ReadIsolation := IsolationLevel::ReadCommitted;
        POSEntrySalesLine.SetRange("POS Entry No.", EntryNo);
        POSEntrySalesLine.SetLoadFields(
            POSEntrySalesLine."Line No.",
            POSEntrySalesLine.Type,
            POSEntrySalesLine."No.",
            POSEntrySalesLine."Variant Code",
            POSEntrySalesLine.Description,
            POSEntrySalesLine."Description 2",
            POSEntrySalesLine.Quantity,
            POSEntrySalesLine."Unit Price",
            POSEntrySalesLine."VAT %",
            POSEntrySalesLine."Line Discount %",
            POSEntrySalesLine."Line Discount Amount Incl. VAT",
            POSEntrySalesLine."Amount Excl. VAT (LCY)",
            POSEntrySalesLine."Amount Incl. VAT (LCY)",
            POSEntrySalesLine."Unit of Measure Code",
            POSEntrySalesLine."Location Code",
            POSEntrySalesLine.SystemId
        );
        if (POSEntrySalesLine.FindSet()) then
            repeat
                Json.StartObject()
                    .AddProperty('lineId', Format(POSEntrySalesLine.SystemId, 0, 4).ToLower())
                    .AddProperty('sortKey', POSEntrySalesLine."Line No.")
                    .AddProperty('type', Format(POSEntrySalesLine.Type))
                    .AddProperty('code', POSEntrySalesLine."No.")
                    .AddProperty('variantCode', POSEntrySalesLine."Variant Code")
                    .AddProperty('description', POSEntrySalesLine.Description)
                    .AddProperty('description2', POSEntrySalesLine."Description 2")
                    .AddProperty('quantity', POSEntrySalesLine.Quantity)
                    .AddProperty('unitPrice', POSEntrySalesLine."Unit Price")
                    .AddProperty('vatPercent', POSEntrySalesLine."VAT %")
                    .AddProperty('discountPct', POSEntrySalesLine."Line Discount %")
                    .AddProperty('discountAmount', POSEntrySalesLine."Line Discount Amount Incl. VAT")
                    .AddProperty('amountInclVat', POSEntrySalesLine."Amount Incl. VAT (LCY)")
                    .AddProperty('taxAmount', POSEntrySalesLine."Amount Incl. VAT (LCY)" - POSEntrySalesLine."Amount Excl. VAT (LCY)")
                    .AddProperty('unitOfMeasure', POSEntrySalesLine."Unit of Measure Code")
                    .AddProperty('locationCode', POSEntrySalesLine."Location Code")
                    .EndObject();
            until POSEntrySalesLine.Next() = 0;
        Json.EndArray();
    end;

    local procedure AddPaymentLinesToJson(var Json: Codeunit "NPR Json Builder"; EntryNo: Integer)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        Json.StartArray('paymentLines');
        POSEntryPaymentLine.ReadIsolation := IsolationLevel::ReadCommitted;
        POSEntryPaymentLine.SetRange("POS Entry No.", EntryNo);
        POSEntryPaymentLine.SetLoadFields(
            POSEntryPaymentLine."Line No.",
            POSEntryPaymentLine."POS Payment Method Code",
            POSEntryPaymentLine.Description,
            POSEntryPaymentLine.Amount,
            POSEntryPaymentLine.EFT,
            POSEntryPaymentLine."External Document No.",
            POSEntryPaymentLine.SystemId
        );
        if (POSEntryPaymentLine.FindSet()) then
            repeat
                Json.StartObject()
                    .AddProperty('lineId', Format(POSEntryPaymentLine.SystemId, 0, 4).ToLower())
                    .AddProperty('sortKey', POSEntryPaymentLine."Line No.")
                    .AddProperty('paymentMethodCode', POSEntryPaymentLine."POS Payment Method Code")
                    .AddProperty('description', POSEntryPaymentLine.Description)
                    .AddProperty('amountInclVat', POSEntryPaymentLine.Amount)
                    .AddProperty('isEFT', POSEntryPaymentLine.EFT)
                    .AddProperty('externalDocumentNo', POSEntryPaymentLine."External Document No.")
                    .EndObject();
            until POSEntryPaymentLine.Next() = 0;
        Json.EndArray();
    end;

    local procedure AddTaxLinesToJson(var Json: Codeunit "NPR Json Builder"; EntryNo: Integer)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Json.StartArray('taxLines');
        POSEntryTaxLine.ReadIsolation := IsolationLevel::ReadCommitted;
        POSEntryTaxLine.SetRange("POS Entry No.", EntryNo);
        POSEntryTaxLine.SetLoadFields(
            POSEntryTaxLine."Tax Jurisdiction Code",
            POSEntryTaxLine."VAT Identifier",
            POSEntryTaxLine."Tax %",
            POSEntryTaxLine."Tax Base Amount",
            POSEntryTaxLine."Tax Amount"
        );
        if (POSEntryTaxLine.FindSet()) then
            repeat
                Json.StartObject()
                    .AddProperty('taxJurisdictionCode', POSEntryTaxLine."Tax Jurisdiction Code")
                    .AddProperty('taxIdentifier', POSEntryTaxLine."VAT Identifier")
                    .AddProperty('taxPercent', POSEntryTaxLine."Tax %")
                    .AddProperty('taxBaseAmount', POSEntryTaxLine."Tax Base Amount")
                    .AddProperty('taxAmount', POSEntryTaxLine."Tax Amount")
                    .EndObject();
            until POSEntryTaxLine.Next() = 0;
        Json.EndArray();
    end;

    #endregion

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR POS Entry");
        TableIds.Add(Database::"NPR POS Entry Sales Line");
        TableIds.Add(Database::"NPR POS Entry Payment Line");
        TableIds.Add(Database::"NPR POS Entry Tax Line");
    end;
}
#endif
