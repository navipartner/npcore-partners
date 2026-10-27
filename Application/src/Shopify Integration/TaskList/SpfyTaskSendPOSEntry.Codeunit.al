// Native sibling of frozen codeunit "NPR Spfy Send BC Transaction": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151486 "NPR Spfy Task Send POS Entry"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

    trigger OnRun()
    begin
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::"NPR POS Entry":
                SendPOSEntry(Rec);
        end;
    end;

    var
        _GLSetup: Record "General Ledger Setup";
        _SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GLSetupRetrieved: Boolean;
        _GraphQLClientSet: Boolean;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure SendPOSEntry(var SpfyTask: Record "NPR Spfy Task")
    var
        POSEntry: Record "NPR POS Entry";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ReturnResolver: Codeunit "NPR Spfy POS Return Resolver";
        ShopifyCustomerID: Text[30];
        POSEntryNotEligibleMsg: Label 'The POS entry number %1 is not eligible for synchronization. The entry will not be sent to Shopify.', Comment = '%1 - POS entry number';
        PendingAtSendErr: Label 'Line %1 cannot be sent yet: its original POS sale %2 is still to be sent to Shopify. The task is retried after it.', Comment = '%1 = POS entry sales line number, %2 = original POS entry number';
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();

        if not LoadPOSEntryAndCustomer(SpfyTask, POSEntry, ShopifyCustomerID) then
            exit;
        if not SpfyPOSEntryExportMgt.IsEligibleForSync(POSEntry, true) then begin
            SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(POSEntryNotEligibleMsg, POSEntry."Entry No."));
            SpfyTask.Modify();
            exit;
        end;

        ReturnResolver.Resolve(POSEntry, SpfyTask."Store Code", TempReturnLineBuf);
        // The precondition passed a moment ago; an original that has become pending since then must not be passed over.
        TempReturnLineBuf.SetRange("Return Case", TempReturnLineBuf."Return Case"::Pending);
        if TempReturnLineBuf.FindFirst() then
            Error(PendingAtSendErr, TempReturnLineBuf."Line No.", TempReturnLineBuf."Original POS Entry No.");
        TempReturnLineBuf.Reset();
        if ReturnResolver.HasSaleLines(POSEntry) then
            SendSalePart(SpfyTask, POSEntry, ShopifyCustomerID, TempReturnLineBuf);
        if not TempReturnLineBuf.IsEmpty() then
            SendReturnPart(SpfyTask, POSEntry, TempReturnLineBuf);
    end;

    local procedure LoadPOSEntryAndCustomer(var SpfyTask: Record "NPR Spfy Task"; var POSEntry: Record "NPR POS Entry"; var ShopifyCustomerID: Text[30]): Boolean
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyTaskSendCustomers: Codeunit "NPR Spfy Task Send Customers";
        RecRef: RecordRef;
        CustomerlessPOSEntryMsg: Label 'The POS entry number %1 was posted without a customer number being specified. The entry will not be sent to Shopify.', Comment = '%1 - POS entry number';
        CustomerNotSyncedErr: Label 'The customer number %1 has not yet been synchronized with Shopify store code %2.', Comment = '%1 - customer number, %2 - Shopify store code';
    begin
        SpfyTask.TestField("Store Code");
        RecRef.Get(SpfyTask."Record ID");
        RecRef.SetTable(POSEntry);

        if POSEntry."Customer No." = '' then begin
            SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(CustomerlessPOSEntryMsg, POSEntry."Entry No."));
            SpfyTask.Modify();
            exit(false);
        end;
        if not SpfyTaskSendCustomers.GetStoreCustomerLink(POSEntry."Customer No.", SpfyTask."Store Code", false, SpfyStoreCustomerLink) then
            Error(CustomerNotSyncedErr, POSEntry."Customer No.", SpfyTask."Store Code");
        ShopifyCustomerID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyCustomerID = '' then
            Error(CustomerNotSyncedErr, POSEntry."Customer No.", SpfyTask."Store Code");
        exit(true);
    end;

    local procedure SendSalePart(var SpfyTask: Record "NPR Spfy Task"; POSEntry: Record "NPR POS Entry"; ShopifyCustomerID: Text[30]; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        SpfyStore: Record "NPR Spfy Store";
        TempSpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyResponse: JsonToken;
        QueryStream: OutStream;
        IsExchange: Boolean;
        ExchangeSaleAmount: Decimal;
        POSEntryAlreadySyncedMsg: Label 'The POS entry number %1 has already been synchronized with Shopify store code %2.', Comment = '%1 - POS entry number, %2 - Shopify store code';
    begin
        TempSpfyStorePOSEntryLink."POS Entry No." := POSEntry."Entry No.";
        TempSpfyStorePOSEntryLink."Shopify Store Code" := SpfyTask."Store Code";
        if AssignedShopifyOrderID(SpfyTask."Store Code", POSEntry."Entry No.") <> '' then begin
            SpfyIntegrationMgt.SetResponse(SpfyTask, StrSubstNo(POSEntryAlreadySyncedMsg, POSEntry."Entry No.", SpfyTask."Store Code"));
            SpfyTask.Modify();
            exit(true);
        end;

        SpfyStore.Get(SpfyTask."Store Code");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '>%1', 0); //Shopify only supports lines with a positive quantity
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        IsExchange := PaidWithExchangeSale(ReturnLineBuf, POSEntryPaymentLine);
        if IsExchange then
            ExchangeSaleAmount := SaleAmountFundedByReturns(POSEntrySalesLine, ReturnLineBuf);
        SpfyTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyOrderCreateQuery(SpfyStore, ShopifyCustomerID, POSEntry, POSEntrySalesLine, POSEntryPaymentLine, IsExchange, ExchangeSaleAmount).WriteTo(QueryStream);

        if not GetGraphQLClient().ExecuteRequest(SpfyTask, true, ShopifyResponse) then begin
            SpfyTask.Modify();
            Commit();
            Error(GetLastErrorText());
        end;
        SpfyTask.Modify();
        Commit();
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');

        AssignShopifyOrderID(TempSpfyStorePOSEntryLink, ShopifyResponse);
        Commit();
        exit(true);
    end;

    local procedure SendReturnPart(var SpfyTask: Record "NPR Spfy Task"; POSEntry: Record "NPR POS Entry"; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ReturnResolver: Codeunit "NPR Spfy POS Return Resolver";
        GroupNotes: TextBuilder;
        TargetOrderID: Text[30];
        OwnOrderID: Text;
        GroupErrorText: Text;
        FirstGroupErrorText: Text;
        ResponseText: Text;
        OwnOrderLbl: Label 'Shopify order %1 holds the entry''s sale lines.', Comment = '%1 = Shopify order id';
        ErrorWithSummaryTok: Label '%1\%2', Locked = true;
    begin
        // This part writes the task response, so an exchange's own order is named in it as well.
        OwnOrderID := AssignedShopifyOrderID(SpfyTask."Store Code", POSEntry."Entry No.");
        if OwnOrderID <> '' then
            GroupNotes.AppendLine(StrSubstNo(OwnOrderLbl, OwnOrderID));
        // One group per original Shopify order; each group commits its own outcome so a retry resumes after the last recorded refund.
        // A refusal or a missing order repeats on every retry, so it is raised only after the other groups have been refunded.
        TargetOrderID := '';
        while NextLinkedGroup(ReturnLineBuf, TargetOrderID) do begin
            ReturnLineBuf.SetRange("Return Case", ReturnLineBuf."Return Case"::Linked);
            ReturnLineBuf.SetRange("Target Shopify Order ID", TargetOrderID);
            RefundGroup(SpfyTask, POSEntry, ReturnLineBuf, TargetOrderID, GroupNotes, GroupErrorText);
            SpfyIntegrationMgt.SetResponse(SpfyTask, GroupNotes.ToText() + ReturnResolver.SummaryText(ReturnLineBuf));
            SpfyTask.Modify();
            Commit();
            if (GroupErrorText <> '') and (FirstGroupErrorText = '') then
                FirstGroupErrorText := GroupErrorText;
        end;
        ResponseText := GroupNotes.ToText() + ReturnResolver.SummaryText(ReturnLineBuf);
        SpfyIntegrationMgt.SetResponse(SpfyTask, ResponseText);
        SpfyTask.Modify();
        // The queue replaces the response of a failed attempt with the error text, so the error carries the whole summary.
        if FirstGroupErrorText <> '' then
            Error(ErrorWithSummaryTok, FirstGroupErrorText, ResponseText);
    end;

    local procedure NextLinkedGroup(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; var TargetOrderID: Text[30]): Boolean
    begin
        ReturnLineBuf.Reset();
        ReturnLineBuf.SetCurrentKey("Target Shopify Order ID");
        ReturnLineBuf.SetRange("Return Case", ReturnLineBuf."Return Case"::Linked);
        ReturnLineBuf.SetFilter("Target Shopify Order ID", '>%1', TargetOrderID);
        if not ReturnLineBuf.FindFirst() then
            exit(false);
        TargetOrderID := ReturnLineBuf."Target Shopify Order ID";
        exit(true);
    end;

    // The buffer arrives filtered to the Linked lines of one Shopify order.
    local procedure RefundGroup(var SpfyTask: Record "NPR Spfy Task"; POSEntry: Record "NPR POS Entry"; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; TargetOrderID: Text[30]; var GroupNotes: TextBuilder; var GroupErrorText: Text)
    var
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        ReturnResolver: Codeunit "NPR Spfy POS Return Resolver";
        OrderResponse: JsonToken;
        SuggestResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        NoteMarker: Text;
        OrderCurrency: Code[3];
        StoreCurrency: Code[3];
        RefundID: Text[30];
        RequestedAmount: Decimal;
        RefundedAmount: Decimal;
        UserErrorText: Text;
        StoreCurrencyDiffersLbl: Label 'The Shopify order currency %1 differs from the store currency %2; refunds on orders in another currency are not supported yet.', Comment = '%1 = Shopify order currency, %2 = Shopify store currency';
        NoPaymentLeftLbl: Label 'The Shopify order has no payment left to refund.';
        NothingToRefundLbl: Label 'The line has no amount to refund.';
        AlreadyRecordedLbl: Label 'Refund %1 already recorded for order %2.', Comment = '%1 = Shopify refund id, %2 = Shopify order id';
        AdoptedLbl: Label 'Adopted refund %1 on order %2.', Comment = '%1 = Shopify refund id, %2 = Shopify order id';
        OrderNotFoundErr: Label 'Shopify order %1 was not found in store %2. If the order is older than 60 days, the store''s Shopify app needs the read_all_orders access scope.', Comment = '%1 = Shopify order id, %2 = Shopify store code';
        CreatedLbl: Label 'Refund %1 created on order %2 for %3 %4.', Comment = '%1 = Shopify refund id, %2 = Shopify order id, %3 = amount, %4 = currency';
        ShortfallLbl: Label 'Refund %1 created on order %2 for %3 %4, short by %5 because the order has no more to refund.', Comment = '%1 = Shopify refund id, %2 = Shopify order id, %3 = amount, %4 = currency, %5 = shortfall';
        NotMatchedLbl: Label 'No line item on the Shopify order matches this line, or nothing is left to refund.';
        PartialQtyLbl: Label 'Line %1: refund on Shopify order %2, quantity %3 of %4 (the rest has nothing left to refund).', Comment = '%1 = line number, %2 = Shopify order id, %3 = refunded quantity, %4 = returned quantity';
        RefusedNoteLbl: Label 'Shopify refused the refund on order %1: %2', Comment = '%1 = Shopify order id, %2 = Shopify user errors';
    begin
        GroupErrorText := '';
        // A recorded group's lines keep Refund Quantity 0, which the summary reports as covered by that refund.
        if SpfyPOSEntryRefund.Find(SpfyTask."Store Code", POSEntry."Entry No.", TargetOrderID) then begin
            GroupNotes.AppendLine(StrSubstNo(AlreadyRecordedLbl, SpfyPOSEntryRefund."Shopify Refund ID", TargetOrderID));
            exit;
        end;

        NoteMarker := ReturnResolver.NoteMarker(POSEntry."Entry No.", POSEntry."Document No.");
        SpfyPOSRefundRequest.QueryOrder(SpfyTask, GetGraphQLClient(), TargetOrderID, OrderResponse);
        if not SpfyPOSRefundRequest.OrderExists(OrderResponse) then begin
            GroupErrorText := StrSubstNo(OrderNotFoundErr, TargetOrderID, SpfyTask."Store Code");
            ReclassifyGroup(ReturnLineBuf, GroupErrorText);
            exit;
        end;

        RefundID := SpfyPOSRefundRequest.FindRefundByNote(OrderResponse, NoteMarker, RefundedAmount);
        OrderCurrency := SpfyPOSRefundRequest.PresentmentCurrency(OrderResponse);
        if RefundID <> '' then begin
            SpfyPOSEntryRefund.Store(SpfyTask."Store Code", POSEntry."Entry No.", TargetOrderID, RefundID, RefundedAmount, OrderCurrency);
            GroupNotes.AppendLine(StrSubstNo(AdoptedLbl, RefundID, TargetOrderID));
            exit;
        end;

        // Multi-currency refunds have not been verified against Shopify (which currency OrderTransactionInput.amount is read in), so they are held back.
        StoreCurrency := StoreCurrencyISOCode(SpfyTask."Store Code");
        if StoreCurrency <> OrderCurrency then begin
            ReclassifyGroup(ReturnLineBuf, StrSubstNo(StoreCurrencyDiffersLbl, OrderCurrency, StoreCurrency));
            exit;
        end;

        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, ReturnLineBuf, SpfyTask."Store Code", LineItemQuantities);
        RequestedAmount := 0;
        if ReturnLineBuf.FindSet() then
            repeat
                if ReturnLineBuf."Refund Quantity" = 0 then begin
                    ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Unlinked;
                    ReturnLineBuf."Unlinked Reason" := NotMatchedLbl;
                    ReturnLineBuf.Modify();
                end else begin
                    ReturnLineBuf."Refund Amount" := Round(ReturnLineBuf."Amount Incl. VAT" * ReturnLineBuf."Refund Quantity" / ReturnLineBuf.Quantity, AmountRoundingPrecision(POSEntry));
                    ReturnLineBuf.Modify();
                    RequestedAmount += ReturnLineBuf."Refund Amount";
                end;
            until ReturnLineBuf.Next() = 0;
        ReturnLineBuf.SetRange("Return Case", ReturnLineBuf."Return Case"::Linked);
        if ReturnLineBuf.IsEmpty() then
            exit;
        // Not positive also when a negative-priced line taken back outweighs the rest: that is money the customer pays.
        if RequestedAmount <= 0 then begin
            ReclassifyGroup(ReturnLineBuf, NothingToRefundLbl);
            exit;
        end;

        SpfyPOSRefundRequest.QuerySuggestedRefund(SpfyTask, GetGraphQLClient(), TargetOrderID, LineItemQuantities, SuggestResponse);
        if SpfyPOSRefundRequest.AllocatableAmount(TargetOrderID, SuggestResponse, RequestedAmount, AmountRoundingPrecision(POSEntry)) <= 0 then begin
            // A refund without a transaction is accepted by Shopify but books a refund discrepancy instead of paying anything back.
            ReclassifyGroup(ReturnLineBuf, NoPaymentLeftLbl);
            exit;
        end;

        if not SpfyPOSRefundRequest.SendRefund(SpfyTask, GetGraphQLClient(), TargetOrderID, LineItemQuantities, SuggestResponse, RequestedAmount, AmountRoundingPrecision(POSEntry), OrderCurrency, ReturnResolver.RefundNote(NoteMarker, ReturnLineBuf, ReturnResolver.PaidBackAs(POSEntry)), RefundID, RefundedAmount, UserErrorText) then begin
            SpfyTask.Modify();
            Commit();
            Error(GetLastErrorText());
        end;
        SpfyTask.Modify();
        if UserErrorText <> '' then begin
            GroupErrorText := StrSubstNo(RefusedNoteLbl, TargetOrderID, UserErrorText);
            ReclassifyGroup(ReturnLineBuf, GroupErrorText);
            exit;
        end;

        SpfyPOSEntryRefund.Store(SpfyTask."Store Code", POSEntry."Entry No.", TargetOrderID, RefundID, RefundedAmount, OrderCurrency);
        if RefundedAmount < RequestedAmount - AmountRoundingPrecision(POSEntry) / 2 then
            GroupNotes.AppendLine(StrSubstNo(ShortfallLbl, RefundID, TargetOrderID, RefundedAmount, OrderCurrency, RequestedAmount - RefundedAmount))
        else
            GroupNotes.AppendLine(StrSubstNo(CreatedLbl, RefundID, TargetOrderID, RefundedAmount, OrderCurrency));
        if ReturnLineBuf.FindSet() then
            repeat
                if ReturnLineBuf."Refund Quantity" < ReturnLineBuf.Quantity then
                    GroupNotes.AppendLine(StrSubstNo(PartialQtyLbl, ReturnLineBuf."Line No.", TargetOrderID, ReturnLineBuf."Refund Quantity", ReturnLineBuf.Quantity));
            until ReturnLineBuf.Next() = 0;
        Commit();
    end;

    local procedure ReclassifyGroup(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; Reason: Text)
    begin
        if ReturnLineBuf.FindSet() then
            repeat
                ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Unlinked;
                ReturnLineBuf."Unlinked Reason" := CopyStr(Reason, 1, MaxStrLen(ReturnLineBuf."Unlinked Reason"));
                ReturnLineBuf.Modify();
            until ReturnLineBuf.Next() = 0;
    end;

    local procedure StoreCurrencyISOCode(ShopifyStoreCode: Code[20]): Code[3]
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(_SpfyPaymentGatewayHdlr.CurrencyISOCode(SpfyIntegrationMgt.StoreCurrencyCode(ShopifyStoreCode)));
    end;

    local procedure AssignedShopifyOrderID(ShopifyStoreCode: Code[20]; POSEntryNo: Integer): Text
    var
        TempSpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        TempSpfyStorePOSEntryLink."POS Entry No." := POSEntryNo;
        TempSpfyStorePOSEntryLink."Shopify Store Code" := ShopifyStoreCode;
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(TempSpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"));
    end;

    local procedure AssignShopifyOrderID(SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link"; ShopifyResponse: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyOrderID: Text[30];
    begin
#pragma warning disable AA0139
        ShopifyOrderID := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyResponse, 'data.orderCreate.order.id', false), '/');
#pragma warning restore AA0139
        if ShopifyOrderID <> '' then
            SpfyAssignedIDMgt.AssignShopifyID(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyOrderID, false);
    end;

    local procedure ShopifyOrderCreateQuery(SpfyStore: Record "NPR Spfy Store"; ShopifyCustomerID: Text[30]; POSEntry: Record "NPR POS Entry"; var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"; IsExchange: Boolean; ExchangeSaleAmount: Decimal): JsonObject
    var
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        JsonBuilder: Codeunit "NPR Json Builder";
        LineItemQuantities: List of [Integer];
        LineItemUnitPrices: List of [Decimal];
        LineItemTaxAmounts: List of [Decimal];
        PresentmentMoneyCurrCode: Code[3];
        ShopMoneyCurrCode: Code[3];
        POSEntryProcessedAt: DateTime;
        LineItemIndex: Integer;
        OrderCreateQueryTok: Label 'mutation orderCreate($order: OrderCreateOrderInput!, $options: OrderCreateOptionsInput) {orderCreate(order: $order, options : $options) {userErrors{field message} order{id}}}', Locked = true;
    begin
        GetGLSetup();
        if SpfyStore."Currency Code" = '' then
            SpfyStore."Currency Code" := _GLSetup."LCY Code";
        ShopMoneyCurrCode := _SpfyPaymentGatewayHdlr.CurrencyISOCode(SpfyStore."Currency Code");
        if POSEntry."Currency Code" = '' then
            POSEntry."Currency Code" := _GLSetup."LCY Code";
        if POSEntry."Currency Code" <> SpfyStore."Currency Code" then
            PresentmentMoneyCurrCode := _SpfyPaymentGatewayHdlr.CurrencyISOCode(POSEntry."Currency Code");
        If POSEntry."Entry Date" = DT2Date(POSEntry.SystemCreatedAt) then
            POSEntryProcessedAt := POSEntry.SystemCreatedAt
        else
            POSEntryProcessedAt := CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time");  //It may not be time zone adjusted

        JsonBuilder.StartObject();
        JsonBuilder.AddProperty('query', OrderCreateQueryTok);
        JsonBuilder.StartObject('variables');
        JsonBuilder.StartObject('options');
        JsonBuilder.AddProperty('inventoryBehaviour', 'BYPASS');
        JsonBuilder.AddProperty('sendReceipt', false);
        JsonBuilder.AddProperty('sendFulfillmentReceipt', false);
        JsonBuilder.EndObject();  //options

        JsonBuilder.StartObject('order');
        JsonBuilder.AddProperty('fulfillmentStatus', 'FULFILLED');
        JsonBuilder.AddProperty('financialStatus', 'PAID');
        JsonBuilder.AddProperty('currency', ShopMoneyCurrCode);
        if PresentmentMoneyCurrCode <> '' then
            JsonBuilder.AddProperty('presentmentCurrency', PresentmentMoneyCurrCode);
        JsonBuilder.AddProperty('processedAt', POSEntryProcessedAt);
        JsonBuilder.AddProperty('closedAt', POSEntryProcessedAt);
        JsonBuilder.AddProperty('name', StrSubstNo('POS-%1', Format(POSEntry."Entry No.", 0, 9)));
        JsonBuilder.AddProperty('sourceIdentifier', POSEntry."Document No.");
        JsonBuilder.AddProperty('sourceName', NpRetailPOS_SourceName());
        JsonBuilder.AddProperty('sourceUrl', GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"NPR POS Entry Card", POSEntry));
        JsonBuilder.AddProperty('taxesIncluded', POSEntry."Prices Including VAT");

        JsonBuilder.StartArray('lineItems');
        if POSEntrySalesLine.FindSet() then
            repeat
                SpfyPOSEntryExportMgt.GetLineItemSplit(POSEntrySalesLine, POSEntry."Prices Including VAT", LineItemQuantities, LineItemUnitPrices, LineItemTaxAmounts);
                for LineItemIndex := 1 to LineItemQuantities.Count() do
                    AddLineItem(JsonBuilder, SpfyStore, POSEntry, POSEntrySalesLine, PresentmentMoneyCurrCode, ShopMoneyCurrCode,
                        LineItemQuantities.Get(LineItemIndex), LineItemUnitPrices.Get(LineItemIndex), LineItemTaxAmounts.Get(LineItemIndex));
            until POSEntrySalesLine.Next() = 0;
        JsonBuilder.EndArray();  //lineItems

        JsonBuilder.StartObject('customer');
        JsonBuilder.StartObject('toAssociate');
        JsonBuilder.AddProperty('id', 'gid://shopify/Customer/' + ShopifyCustomerID);
        JsonBuilder.EndObject();  //toAssociate
        JsonBuilder.EndObject();  //customer

        if IsExchange then
            AddExchangeTransaction(JsonBuilder, ExchangeSaleAmount, POSEntryProcessedAt, PresentmentMoneyCurrCode, ShopMoneyCurrCode, POSEntry, SpfyStore)
        else
            AddPaymentTransactions(JsonBuilder, POSEntryPaymentLine, POSEntryProcessedAt, PresentmentMoneyCurrCode, ShopMoneyCurrCode, POSEntry, SpfyStore);
        JsonBuilder.EndObject();  //order
        JsonBuilder.EndObject();  //variables
        JsonBuilder.EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure AddLineItem(var JsonBuilder: Codeunit "NPR Json Builder"; SpfyStore: Record "NPR Spfy Store"; POSEntry: Record "NPR POS Entry"; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; PresentmentMoneyCurrCode: Code[3]; ShopMoneyCurrCode: Code[3]; Quantity: Integer; UnitPrice: Decimal; TaxAmount: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        ShopifyVariantID: Text[30];
        ShopMoneyAmount: Decimal;
    begin
        JsonBuilder.StartObject();  //line item
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item then begin
            ShopifyVariantID := SpfyItemMgt.GetAssignedShopifyVariantID(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code", SpfyStore."Code", true);
            if ShopifyVariantID <> '' then
                JsonBuilder.AddProperty('variantId', 'gid://shopify/ProductVariant/' + ShopifyVariantID);
            JsonBuilder.AddProperty('sku', SpfyItemMgt.GetProductVariantSku(POSEntrySalesLine."No.", POSEntrySalesLine."Variant Code"));
        end;
        JsonBuilder.AddProperty('title', SpfyPOSEntryExportMgt.GetLineItemTitle(POSEntrySalesLine));
        JsonBuilder.AddProperty('giftCard', false); //We cannot set this to true (or base it on POSEntrySalesLine.Type::Voucher), because Shopify will create duplicate gift cards
        JsonBuilder.AddProperty('quantity', Quantity);  //Shopify expects quantity as integer

        JsonBuilder.StartObject('priceSet');
        if PresentmentMoneyCurrCode <> '' then begin
            JsonBuilder.StartObject('presentmentMoney');
            JsonBuilder.AddProperty('amount', UnitPrice);
            JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
            JsonBuilder.EndObject();  //presentmentMoney
            ShopMoneyAmount := CurrExchRate.ExchangeAmount(UnitPrice, POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
        end else
            ShopMoneyAmount := UnitPrice;
        JsonBuilder.StartObject('shopMoney');
        JsonBuilder.AddProperty('amount', ShopMoneyAmount);
        JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
        JsonBuilder.EndObject();  //shopMoney
        JsonBuilder.EndObject();  //priceSet

        JsonBuilder.StartArray('taxLines');
        JsonBuilder.StartObject();  //taxLine
        JsonBuilder.StartObject('priceSet');
        if PresentmentMoneyCurrCode <> '' then begin
            JsonBuilder.StartObject('presentmentMoney');
            JsonBuilder.AddProperty('amount', TaxAmount);
            JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
            JsonBuilder.EndObject();  //presentmentMoney
            ShopMoneyAmount := CurrExchRate.ExchangeAmount(TaxAmount, POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
        end else
            ShopMoneyAmount := TaxAmount;
        JsonBuilder.StartObject('shopMoney');
        JsonBuilder.AddProperty('amount', ShopMoneyAmount);
        JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
        JsonBuilder.EndObject();  //shopMoney
        JsonBuilder.EndObject();  //priceSet (taxLine)
        JsonBuilder.AddProperty('rate', POSEntrySalesLine."VAT %" / 100);
        JsonBuilder.AddProperty('title', Format(POSEntrySalesLine."VAT Calculation Type"));
        JsonBuilder.EndObject();  //taxLine
        JsonBuilder.EndArray();  //taxLines
        JsonBuilder.EndObject();  //line item
    end;

    local procedure AddPaymentTransactions(var JsonBuilder: Codeunit "NPR Json Builder"; var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"; POSEntryProcessedAt: DateTime; PresentmentMoneyCurrCode: Code[3]; ShopMoneyCurrCode: Code[3]; POSEntry: Record "NPR POS Entry"; SpfyStore: Record "NPR Spfy Store")
    var
        TempConsolidatedPOSEntryPaymentLine: Record "NPR POS Entry Payment Line" temporary;
    begin
        SummarizePaymentLines(POSEntryPaymentLine, TempConsolidatedPOSEntryPaymentLine);
        TempConsolidatedPOSEntryPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        if not TempConsolidatedPOSEntryPaymentLine.FindSet() then
            exit;
        JsonBuilder.StartArray('transactions');
        repeat
            JsonBuilder.StartObject();  //transaction
            if TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)" > 0 then
                JsonBuilder.AddProperty('kind', 'SALE')
            else
                JsonBuilder.AddProperty('kind', 'REFUND');
            JsonBuilder.AddProperty('status', 'SUCCESS');
            JsonBuilder.AddProperty('gateway', StrSubstNo('NPRetail.POS.%1', TempConsolidatedPOSEntryPaymentLine."POS Payment Method Code"));
            if TempConsolidatedPOSEntryPaymentLine."POS Payment Line Created At" <> 0DT then
                JsonBuilder.AddProperty('processedAt', TempConsolidatedPOSEntryPaymentLine."POS Payment Line Created At")
            else
                JsonBuilder.AddProperty('processedAt', POSEntryProcessedAt);
            AddAmountSet(JsonBuilder, Abs(TempConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)"), PresentmentMoneyCurrCode, ShopMoneyCurrCode, POSEntry, SpfyStore);
            JsonBuilder.EndObject();  //transaction
        until TempConsolidatedPOSEntryPaymentLine.Next() = 0;
        JsonBuilder.EndArray();  //transactions
    end;

    // An exchange's new order is paid by the returns refunded on their original orders plus the net payment, so one SALE covers its positive lines; a non-positive amount means no transaction.
    local procedure AddExchangeTransaction(var JsonBuilder: Codeunit "NPR Json Builder"; SaleAmount: Decimal; POSEntryProcessedAt: DateTime; PresentmentMoneyCurrCode: Code[3]; ShopMoneyCurrCode: Code[3]; POSEntry: Record "NPR POS Entry"; SpfyStore: Record "NPR Spfy Store")
    var
        ExchangeGatewayTok: Label 'NPRetail.POS.EXCHANGE', Locked = true;
    begin
        if SaleAmount <= 0 then
            exit;
        JsonBuilder.StartArray('transactions');
        JsonBuilder.StartObject();  //transaction
        JsonBuilder.AddProperty('kind', 'SALE');
        JsonBuilder.AddProperty('status', 'SUCCESS');
        JsonBuilder.AddProperty('gateway', ExchangeGatewayTok);
        JsonBuilder.AddProperty('processedAt', POSEntryProcessedAt);
        AddAmountSet(JsonBuilder, SaleAmount, PresentmentMoneyCurrCode, ShopMoneyCurrCode, POSEntry, SpfyStore);
        JsonBuilder.EndObject();  //transaction
        JsonBuilder.EndArray();  //transactions
    end;

    local procedure AddAmountSet(var JsonBuilder: Codeunit "NPR Json Builder"; SalesCurrencyAmount: Decimal; PresentmentMoneyCurrCode: Code[3]; ShopMoneyCurrCode: Code[3]; POSEntry: Record "NPR POS Entry"; SpfyStore: Record "NPR Spfy Store")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        ShopMoneyAmount: Decimal;
    begin
        JsonBuilder.StartObject('amountSet');
        if PresentmentMoneyCurrCode <> '' then begin
            JsonBuilder.StartObject('presentmentMoney');
            JsonBuilder.AddProperty('amount', SalesCurrencyAmount);
            JsonBuilder.AddProperty('currencyCode', PresentmentMoneyCurrCode);
            JsonBuilder.EndObject();  //presentmentMoney
            ShopMoneyAmount := CurrExchRate.ExchangeAmount(SalesCurrencyAmount, POSEntry."Currency Code", SpfyStore."Currency Code", POSEntry."Entry Date");
        end else
            ShopMoneyAmount := SalesCurrencyAmount;
        JsonBuilder.StartObject('shopMoney');
        JsonBuilder.AddProperty('amount', ShopMoneyAmount);
        JsonBuilder.AddProperty('currencyCode', ShopMoneyCurrCode);
        JsonBuilder.EndObject();  //shopMoney
        JsonBuilder.EndObject();  //amountSet
    end;

    // The payment lines show what the customer paid unless a refund on an original order funds part of the sale, or money went back to the customer, which a new order must not carry as a REFUND transaction.
    local procedure PaidWithExchangeSale(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"): Boolean
    var
        TempConsolidatedPOSEntryPaymentLine: Record "NPR POS Entry Payment Line" temporary;
        HasLinkedReturns: Boolean;
    begin
        ReturnLineBuf.Reset();
        if ReturnLineBuf.IsEmpty() then
            exit(false);
        ReturnLineBuf.SetRange("Return Case", ReturnLineBuf."Return Case"::Linked);
        HasLinkedReturns := not ReturnLineBuf.IsEmpty();
        ReturnLineBuf.Reset();
        if HasLinkedReturns then
            exit(true);
        SummarizePaymentLines(POSEntryPaymentLine, TempConsolidatedPOSEntryPaymentLine);
        TempConsolidatedPOSEntryPaymentLine.SetFilter("Amount (Sales Currency)", '<%1', 0);
        exit(not TempConsolidatedPOSEntryPaymentLine.IsEmpty());
    end;

    // The positive lines' value less the returns that are not refunded on an original order: the net payment plus the credit of the refunded returns.
    local procedure SaleAmountFundedByReturns(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary) Amount: Decimal
    begin
        if POSEntrySalesLine.FindSet() then
            repeat
                Amount += POSEntrySalesLine."Amount Incl. VAT";
            until POSEntrySalesLine.Next() = 0;
        ReturnLineBuf.Reset();
        ReturnLineBuf.SetFilter("Return Case", '<>%1', ReturnLineBuf."Return Case"::Linked);
        if ReturnLineBuf.FindSet() then
            repeat
                Amount -= ReturnLineBuf."Amount Incl. VAT";
            until ReturnLineBuf.Next() = 0;
        ReturnLineBuf.Reset();
    end;

    local procedure SummarizePaymentLines(var POSEntryPaymentLine: Record "NPR POS Entry Payment Line"; var ConsolidatedPOSEntryPaymentLine: Record "NPR POS Entry Payment Line")
    begin
        if not ConsolidatedPOSEntryPaymentLine.IsTemporary() then
            FunctionCallOnNonTempVarErr('SummarizePaymentLines');
        ConsolidatedPOSEntryPaymentLine.Reset();
        ConsolidatedPOSEntryPaymentLine.DeleteAll();

        if POSEntryPaymentLine.FindSet() then
            repeat
                ConsolidatedPOSEntryPaymentLine.SetRange("POS Payment Method Code", POSEntryPaymentLine."POS Payment Method Code");
                ConsolidatedPOSEntryPaymentLine.SetRange("Currency Code", POSEntryPaymentLine."Currency Code");
                if not ConsolidatedPOSEntryPaymentLine.FindFirst() then begin
                    ConsolidatedPOSEntryPaymentLine := POSEntryPaymentLine;
                    ConsolidatedPOSEntryPaymentLine.Insert();
                end else begin
                    ConsolidatedPOSEntryPaymentLine."Amount (Sales Currency)" += POSEntryPaymentLine."Amount (Sales Currency)";
                    ConsolidatedPOSEntryPaymentLine.Modify();
                end;
            until POSEntryPaymentLine.Next() = 0;
        ConsolidatedPOSEntryPaymentLine.Reset();
    end;

    // The POS entry's currency is the order's (the resolver unlinks an entry in another currency than the store's, and the refund step holds back an order in another), so its precision is the refund's.
    local procedure AmountRoundingPrecision(POSEntry: Record "NPR POS Entry"): Decimal
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        GetGLSetup();
        if POSEntry."Currency Code" = _GLSetup."LCY Code" then
            POSEntry."Currency Code" := '';
        exit(SpfyIntegrationMgt.AmountRoundingPrecision(POSEntry."Currency Code"));
    end;

    local procedure GetGLSetup()
    begin
        if _GLSetupRetrieved then
            exit;
        _GLSetupRetrieved := true;
        if not _GLSetup.Get() then
            _GLSetup.Init();
    end;

    local procedure NpRetailPOS_SourceName(): Text
    begin
        exit('NPRetailPOS');
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Task Send POS Entry(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Task Send POS Entry");
    end;
}
