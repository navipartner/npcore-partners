#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248632 "NPR API POS Sale"
{
    Access = Internal;

    internal procedure AssertPOSUnitOpenForSale(POSUnitNo: Code[10]): Boolean
    var
        _POSUnit: Record "NPR POS Unit";
    begin
        if not _POSUnit.Get(POSUnitNo) then
            exit(false);
        exit(_POSUnit.Status = _POSUnit.Status::OPEN);
    end;

    procedure GetSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        WithLines: Boolean;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if Request.QueryParams().ContainsKey('withLines') then
            Evaluate(WithLines, Request.QueryParams().Get('withLines'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(POSSaleAsJson(POSSale, WithLines)));
    end;

    procedure SearchSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnitFilter: Text;
        POSSale: Record "NPR POS Sale";
        WithLines: Boolean;
        JsonArray: JsonArray;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        if not Request.QueryParams().ContainsKey('posunit') then
            exit(Response.RespondBadRequest('Missing required query parameter: posunit'));
        POSUnitFilter := Request.QueryParams().Get('posunit');

        if Request.QueryParams().ContainsKey('withLines') then
            Evaluate(WithLines, Request.QueryParams().Get('withLines'));

        POSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        POSSale.SetLoadFields(SystemId, "Sales Ticket No.", "Register No.", "Customer No.", "SystemCreatedAt", Date, "POS Store Code", "Salesperson Code", "VAT Bus. Posting Group");
        POSSale.SetFilter("Register No.", '=%1', POSUnitFilter);

        if (Request.Paths().Count() = 3) and (Request.Paths().Get(2) = 'search') then begin
            //backwards compatibility
            if not POSSale.FindLast() then
                exit(Response.RespondResourceNotFound());

            exit(Response.RespondOK(POSSaleAsJson(POSSale, WithLines)));
        end else begin
            if not POSSale.FindSet() then
                exit(Response.RespondResourceNotFound());

            repeat
                JsonArray.Add(POSSaleAsJson(POSSale, WithLines).Build());
            until POSSale.Next() = 0;
            exit(Response.RespondOK(JsonArray));
        end;

    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure CreateSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        Body: JsonToken;
        POSUnitNo: Code[10];
        CustomerNo: Text;
        TempText: Text;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";
        VATBusinessPostingGroup: Text;
        POSSession: Codeunit "NPR POS Session";
        UserSetup: Record "User Setup";
    begin
        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        Body := Request.BodyJson();

        if not GetJsonText(Body, 'posUnit', TempText) then
            exit(Response.RespondBadRequest('Missing required field: posUnit'));
        POSUnitNo := CopyStr(TempText, 1, MaxStrLen(POSUnitNo));

        if GetJsonText(Body, 'customerNo', TempText) then
            CustomerNo := CopyStr(TempText, 1, MaxStrLen(CustomerNo));

        if GetJsonText(Body, 'vatBusinessPostingGroup', TempText) then
            VATBusinessPostingGroup := CopyStr(TempText, 1, MaxStrLen(VATBusinessPostingGroup));

        if not UserSetup.Get(UserId) then
            exit(Response.RespondBadRequest('API user has no User Setup record. Add the API user to User Setup (with a POS Unit assigned) before calling the POS Sale API.'));
        if UserSetup."NPR POS Unit No." = '' then
            exit(Response.RespondBadRequest('API user has no POS Unit assigned in User Setup. Assign a POS Unit to the API user in User Setup before calling the POS Sale API.'));

        CreateSale(SaleSystemId, POSUnitNo);
        POSSession.GetSale(POSSale);

        if (CustomerNo <> '') or (VATBusinessPostingGroup <> '') then begin
            POSSale.GetCurrentSale(POSSaleRec);
            POSSaleRec.GetBySystemId(POSSaleRec.SystemId);
            if CustomerNo <> '' then
                POSSaleRec.Validate("Customer No.", CustomerNo);
            if VATBusinessPostingGroup <> '' then
                POSSaleRec.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup);
            POSSaleRec.Modify(true);
        end;

        POSSale.GetCurrentSale(POSSaleRec);
        POSSaleRec.GetBySystemId(POSSaleRec.SystemId);
        exit(Response.RespondCreated(POSSaleAsJson(POSSaleRec, true)));
    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure UpdateSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        Body: JsonToken;
        CustomerNo: Code[20];
        VATBusinessPostingGroup: Code[20];
        TempText: Text;
        POSSaleRec: Record "NPR POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        ReconstructSession(SaleSystemId);
        POSSession.GetSale(POSSale);
        DeltaBuilder.StartDataCollection();

        Body := Request.BodyJson();
        if GetJsonText(Body, 'customerNo', TempText) then begin
            CustomerNo := CopyStr(TempText, 1, MaxStrLen(CustomerNo));
            POSSale.GetCurrentSale(POSSaleRec);
            POSSaleRec.Validate("Customer No.", CustomerNo);
            POSSaleRec.Modify(true);
        end;

        if GetJsonText(Body, 'vatBusinessPostingGroup', TempText) then begin
            VATBusinessPostingGroup := CopyStr(TempText, 1, MaxStrLen(VATBusinessPostingGroup));
            POSSale.GetCurrentSale(POSSaleRec);
            POSSaleRec.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup);
            POSSaleRec.Modify(true);
        end;

        exit(Response.RespondOK(DeltaBuilder.BuildDeltaResponse()));
    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure DeleteSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSaleRec: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        ReconstructSession(SaleSystemId);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);

        POSSaleRec.Delete(true);

        exit(Response.RespondOK('Deleted'));
    end;

    procedure CompleteSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSaleRec: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        KitchenOrder: JsonToken;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        ReconstructSession(SaleSystemId);
        POSSession.GetSale(POSSale);

        if Request.BodyJson().IsObject then begin
            if Request.BodyJson().AsObject().Get('kitchenRequest', KitchenOrder) then begin
                CreateKitchenOrder(KitchenOrder.AsObject());
            end;
        end;

        if not POSSale.TryEndSale(POSSession, false) then
            exit(Response.RespondBadRequest('Sale failed to complete. Ensure payments add up to full or higher than sales total.'));

        POSSale.GetLastSalePOSEntry(POSEntry);
        exit(Response.RespondCreated(POSEntryAsJson(POSEntry)));
    end;

    [CommitBehavior(CommitBehavior::Ignore)]
    procedure ParkSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSaleRec: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SavePOSSvSl: Codeunit "NPR POS Action: SavePOSSvSl B";
        Json: Codeunit "NPR JSON Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not AssertPOSUnitOpenForSale(POSSaleRec."Register No.") then
            exit(Response.RespondBadRequest('POS Unit is not open for sales'));

        ReconstructSession(SaleSystemId);
        SavePOSSvSl.SaveSale(POSQuoteEntry);

        Json.StartObject('')
            .AddProperty('saleId', Format(POSQuoteEntry.SystemId, 0, 4).ToLower())
            .AddProperty('receiptNo', POSQuoteEntry."Sales Ticket No.")
            .AddProperty('posUnit', POSQuoteEntry."Register No.")
            .AddProperty('parkedAt', Format(POSQuoteEntry."Created at", 0, 9))
            .EndObject();
        exit(Response.RespondCreated(Json));
    end;

    local procedure POSSaleAsJson(POSSale: Record "NPR POS Sale"; WithLines: Boolean): Codeunit "NPR Json Builder"
    var
        EmptyList: List of [Text];
    begin
        exit(POSSaleAsJson(POSSale, WithLines, false, EmptyList, EmptyList));
    end;

    internal procedure POSSaleAsJson(POSSale: Record "NPR POS Sale"; WithLines: Boolean; OnlyRefreshed: Boolean; RefreshedSaleLineIds: List of [Text]; RefreshedPaymentLineIds: List of [Text]) Json: Codeunit "NPR Json Builder"
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SalesAmountInclVAT: Decimal;
        PaymentAmount: Decimal;
        LineId: Text;
        APIPOSSaleLine: Codeunit "NPR API POS Sale Line";
        APIPOSPaymentLine: Codeunit "NPR API POS Payment Line";
    begin
        Json.StartObject('')
            .AddProperty('saleId', Format(POSSale.SystemId, 0, 4).ToLower())
            .AddProperty('receiptNo', POSSale."Sales Ticket No.")
            .AddProperty('posUnit', POSSale."Register No.")
            .AddProperty('posStore', POSSale."POS Store Code")
            .AddProperty('date', Format(POSSale.Date, 0, 9))
            .AddProperty('startTime', Format(POSSale.SystemCreatedAt, 0, 9))
            .AddProperty('customerNo', POSSale."Customer No.")
            .AddProperty('salespersonCode', POSSale."Salesperson Code")
            .AddProperty('vatBusinessPostingGroup', POSSale."VAT Bus. Posting Group");

        if not WithLines then begin
            Json.EndObject();
            exit;
        end;

        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetFilter("Line Type", '<>%1', POSSaleLine."Line Type"::"POS Payment");

        if OnlyRefreshed then
            Json.StartArray('refreshedSaleLines')
        else
            Json.StartArray('saleLines');
        if POSSaleLine.FindSet() then
            repeat
                if (not OnlyRefreshed) or (RefreshedSaleLineIds.Contains(Format(POSSaleLine.SystemId, 0, 4).ToLower())) then begin
                    APIPOSSaleLine.AddSaleLineToJson(POSSaleLine, Json);
                    RefreshedSaleLineIds.Remove(Format(POSSaleLine.SystemId, 0, 4).ToLower());
                end;

                SalesAmountInclVAT += POSSaleLine."Amount Including VAT";
            until POSSaleLine.Next() = 0;
        Json.EndArray();

        POSSaleLine.SetFilter("Line Type", '=%1', POSSaleLine."Line Type"::"POS Payment");
        if OnlyRefreshed then
            Json.StartArray('refreshedPaymentLines')
        else
            Json.StartArray('paymentLines');
        if POSSaleLine.FindSet() then
            repeat
                if (not OnlyRefreshed) or (RefreshedPaymentLineIds.Contains(Format(POSSaleLine.SystemId, 0, 4).ToLower())) then begin
                    APIPOSPaymentLine.AddPaymentLineToJson(POSSaleLine, Json);
                    RefreshedPaymentLineIds.Remove(Format(POSSaleLine.SystemId, 0, 4).ToLower());
                end;

                PaymentAmount += POSSaleLine."Amount Including VAT";
            until POSSaleLine.Next() = 0;
        Json.EndArray();

        if OnlyRefreshed then begin
            Json.StartArray('deletedSaleLines');
            foreach LineId in RefreshedSaleLineIds do begin
                Json.AddValue(LineId);
            end;
            Json.EndArray();

            Json.StartArray('deletedPaymentLines');
            foreach LineId in RefreshedPaymentLineIds do begin
                Json.AddValue(LineId);
            end;
            Json.EndArray();
        end;

        Json.AddProperty('totalSalesAmountInclVat', SalesAmountInclVAT);
        Json.AddProperty('totalPaymentAmount', PaymentAmount);

        Json.EndObject();
    end;

    local procedure POSEntryAsJson(POSEntry: Record "NPR POS Entry") Json: Codeunit "NPR Json Builder"
    var
        KitchenOrderNo: BigInteger;
        KitchenOrderSystemId: Guid;
    begin
        Json.StartObject('')
            .AddProperty('entryNo', POSEntry."Entry No.")
            .AddProperty('entryId', Format(POSEntry.SystemId, 0, 4).ToLower())
            .AddProperty('documentNo', POSEntry."Document No.")
            .AddProperty('totalAmountInclVat', POSEntry."Amount Incl. Tax");

        KitchenOrderNo := GetKitchenOrderNoFromPOSEntry(POSEntry."Entry No.", KitchenOrderSystemId);
        if KitchenOrderNo <> 0 then begin
            Json.AddProperty('kitchenOrderNo', Format(KitchenOrderNo));
            if not IsNullGuid(KitchenOrderSystemId) then
                Json.AddProperty('kitchenOrderId', Format(KitchenOrderSystemId, 0, 4).ToLower());
        end;

        Json.EndObject();
    end;

    local procedure CreateKitchenOrder(Request: JsonObject)
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SeatingCode: Code[20];
        NoOfGuests: Integer;
        CustomerDetailsJson: JsonToken;
        TableNo: Text;
        PhoneNo: Text;
        Email: Text;
        JsonToken: JsonToken;
        CustomerDetails: Dictionary of [Text, Text];
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSActionNewWaPadB: Codeunit "NPR POSAction New Wa. Pad-B";
        POSActionRunWActB: Codeunit "NPR POSAction: Run WAct-B";
        ActionMessage: Text;
        NewWaiterPadNo: Code[20];
        ResultMessageText: Text;
        CleanupMessageText: Text;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSSaleRec: Record "NPR POS Sale";
        POSNPRERestProfile: Record "NPR POS NPRE Rest. Profile";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(POSSaleRec);
        POSUnit.Get(POSSaleRec."Register No.");

        if POSUnit."POS Restaurant Profile" <> '' then
            POSNPRERestProfile.Get(POSUnit."POS Restaurant Profile")
        else begin
            POSStore.Get(POSUnit."POS Store Code");
            POSNPRERestProfile.Get(POSStore."POS Restaurant Profile");
        end;
        Restaurant.Get(POSNPRERestProfile."Restaurant Code");

        ValidateRestaurantSetupForSelfservice(Restaurant);

        if not Request.Get('seatingCode', JsonToken) then
            Error('Missing required field: seatingCode');
        if not JsonToken.IsValue() then
            Error('Invalid seatingCode format');
        SeatingCode := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(SeatingCode));

        if not GetJsonInteger(Request.AsToken(), 'noOfGuests', NoOfGuests) then
            NoOfGuests := 1;

        if Request.Get('customerDetails', CustomerDetailsJson) then begin
            if GetJsonText(CustomerDetailsJson, 'name', TableNo) then
                CustomerDetails.Set(WaiterPad.FieldName(Description), TableNo);
            if GetJsonText(CustomerDetailsJson, 'phoneNo', PhoneNo) then
                CustomerDetails.Set(WaiterPad.FieldName("Customer Phone No."), PhoneNo);
            if GetJsonText(CustomerDetailsJson, 'email', Email) then
                CustomerDetails.Set(WaiterPad.FieldName("Customer E-Mail"), Email);
        end;

        POSActionNewWaPadB.NewWaiterPad(POSSale, SeatingCode, CustomerDetails, NoOfGuests, false, ActionMessage);
        POSActionRunWActB.RunWaiterPadAction(2, 0, '', false, false, POSSale, POSSaleLine, NewWaiterPadNo, ResultMessageText, CleanupMessageText);
    end;

    local procedure ValidateRestaurantSetupForSelfservice(Restaurant: Record "NPR NPRE Restaurant")
    var
        NPRERestaurantSetup: Record "NPR NPRE Restaurant Setup";
        NPREServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        NPRERestaurantSetup.Get();

        if Restaurant."Auto Send Kitchen Order" = Restaurant."Auto Send Kitchen Order"::Default then
            NPRERestaurantSetup.TestField("Auto-Send Kitchen Order", NPRERestaurantSetup."Auto-Send Kitchen Order"::Yes)
        else
            Restaurant.TestField("Auto Send Kitchen Order", Restaurant."Auto Send Kitchen Order"::Yes);

        if Restaurant."KDS Active" = Restaurant."KDS Active"::Default then
            NPRERestaurantSetup.TestField("KDS Active", true)
        else
            Restaurant.TestField("KDS Active", Restaurant."KDS Active"::Yes);

        NPREServFlowProfile.Get(Restaurant."Service Flow Profile");
        NPREServFlowProfile.TestField("AutoSave to W/Pad on Sale End", true);
        NPREServFlowProfile.TestField("Close Waiter Pad On", NPREServFlowProfile."Close Waiter Pad On"::"Payment if Served");
    end;

    local procedure GetKitchenOrderNoFromPOSEntry(POSEntryNo: Integer; var KitchenOrderSystemId: Guid): BigInteger
    var
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        KitchenReqSrcLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
        POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntryNo);
        if not POSEntryWaiterPadLink.FindFirst() then
            exit(0);

        KitchenReqSrcLink.SetRange("Source Document Type", KitchenReqSrcLink."Source Document Type"::"Waiter Pad");
        KitchenReqSrcLink.SetRange("Source Document No.", POSEntryWaiterPadLink."Waiter Pad No.");
        if not KitchenReqSrcLink.FindFirst() then
            exit(0);

        if not KitchenRequest.Get(KitchenReqSrcLink."Request No.") then
            exit(0);

        KitchenOrder.SetRange("Order ID", KitchenRequest."Order ID");
        if KitchenOrder.FindFirst() then
            KitchenOrderSystemId := KitchenOrder.SystemId;

        exit(KitchenRequest."Order ID");
    end;

    local procedure GetJsonText(Body: JsonToken; PropertyName: Text; var Value: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        Value := JToken.AsValue().AsText();
        exit(true);
    end;

    local procedure GetJsonInteger(Body: JsonToken; PropertyName: Text; var Value: Integer): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsInteger();
            exit(true);
        end;
        exit(false);
    end;

    local procedure POSSaleTableIds(): List of [Integer]
    var
        TableIdList: List of [Integer];
    begin
        TableIdList.Add(Database::"NPR POS Sale");
        TableIdList.Add(Database::"NPR POS Sale Line");
        exit(TableIdList);
    end;

    procedure ReconstructSession(SaleSystemId: Guid)
    var
        POSSaleRec: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSaleRec.GetBySystemId(SaleSystemId);
        POSSession.ConstructFromWebserviceSession(false, POSSaleRec."Register No.", POSSaleRec."Sales Ticket No.");
    end;

    procedure CreateSale(SaleSystemId: Guid; POSUnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSUnit.Get(POSUnitNo);
        POSUnit.TestField("POS Type", POSUnit."POS Type"::UNATTENDED);
        POSUnit.TestField(Status, POSUnit.Status::OPEN);
        VerifyCleanupJobIsScheduled();

        POSSession.ConstructFromWebserviceSession(false, POSUnit."No.", '');
        POSSession.StartTransaction(SaleSystemId);
    end;

    local procedure VerifyCleanupJobIsScheduled()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if JobQueueEntry.IsEmpty() then
            Error('POS Unit is UNATTENDED but the cleanup job "JQ Cleanup Dead POS Sales" is not scheduled in the Job Queue. Schedule it to prevent abandoned sales from accumulating. This is a programming bug.');
    end;

}
#endif
