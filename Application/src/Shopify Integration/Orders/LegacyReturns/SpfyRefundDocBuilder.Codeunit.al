codeunit 6151263 "NPR Spfy Refund Doc. Builder"
{
    Access = Internal;

    var
        _SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        _SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        _DiscrepancyAccountMissingErr: Label 'Shopify refunded %1 beyond the lines of %2, but %3 is blank on the %4. Set it so the amount can be posted.', Comment = '%1 = amount paid beyond the lines, %2 = Shopify document caption, %3 = Refund Discrepancy G/L Acc. caption, %4 = Shopify Store table caption';
        _ShipmentNotFoundErr: Label 'No posted %1 of this store carries Shopify line item %2 of %3 for the quantity refunded, so the item charge cannot be assigned. Handle it manually.', Comment = '%1 = Sales Shipment Line table caption, %2 = Shopify order line item id, %3 = Shopify document caption';

    /// <summary>
    /// Builds a stamped Sales Return Order from parsed Shopify detail, or says why it waits or has nothing to credit; never reads or writes a queue row.
    /// </summary>
    internal procedure BuildReturnOrder(ShopifyStore: Record "NPR Spfy Store"; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; var SalesHeader: Record "Sales Header"; var UsedLocationFallback: Boolean; var OutcomeMessage: Text) Outcome: Enum "NPR Spfy Refund Build Outcome"
    var
        NpEcStore: Record "NPR NpEc Store";
        Customer: Record Customer;
        OrderToken: JsonToken;
        LocationCode: Code[10];
        DisplayName: Text[50];
        DroppedAmount: Decimal;
        ExpectedTotal: Decimal;
        HadLines: Boolean;
        AppliedAmount: Decimal;
        ShippingAccountMissingErr: Label 'Shopify refunded %1 of shipping for Shopify %2, but %3 is blank on the %4. Set it so the shipping refund can be posted.', Comment = '%1 = shipping refund amount, %2 = Shopify document caption, %3 = Return Shipping Refund G/L Acc. caption, %4 = Shopify Store table caption';
        ReturnFeeAccountMissingErr: Label 'Shopify held back %1 of the refund for Shopify %2, but %3 is blank on the %4. Set it so the withheld amount can be posted.', Comment = '%1 = fee amount, %2 = Shopify document caption, %3 = Return Fee G/L Account No. caption, %4 = Shopify Store table caption';
        RefundDiscrepancyLbl: Label 'Refunded beyond the lines';
        NothingToCreditMsg: Label 'Every unit Shopify %1 refunds was left off the invoices of order %2, so Business Central never invoiced or received it and nothing is credited.', Comment = '%1 = Shopify document caption, %2 = Shopify order name';
        NothingLeftAfterWithheldErr: Label 'Business Central never received %2 of the %3 Shopify %1 refunds, so once the amount Shopify withheld is taken off nothing is left to credit. Handle this refund manually.', Comment = '%1 = Shopify document caption, %2 = amount for units left off the invoices, %3 = refund total';
        ShippingRefundLbl: Label 'Shipping refund';
        ReturnFeeLbl: Label 'Return fee withheld';
    begin
        UsedLocationFallback := false;
        OutcomeMessage := '';
        DisplayName := _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id");
        CheckSourceIsImportable(TempReturnBuffer);
        if RefundStillPending(TempReturnBuffer, OutcomeMessage) then
            exit(Outcome::Waiting);
        if TempReturnBuffer."Source Type" = TempReturnBuffer."Source Type"::Refund then begin
            if OrderStillOpen(ShopifyStore.Code, TempReturnBuffer."Order Id", TempReturnBuffer."Order Name", OutcomeMessage) then
                exit(Outcome::Waiting);
            CheckInvoicedThroughOrder(ShopifyStore.Code, DisplayName, TempReturnBuffer);
            if OrderNeverInvoiced(ShopifyStore.Code, DisplayName, TempReturnBuffer, Outcome, OutcomeMessage) then
                exit(Outcome);
            HadLines := not TempLineBuffer.IsEmpty();
            DroppedAmount := AllocateDroppedUnits(ShopifyStore.Code, DisplayName, TempReturnBuffer, TempLineBuffer, TempOtherLineBuffer);
            // Money beyond the dropped units goes on to the discount rule, which credits it or refuses it.
            if HadLines and TempLineBuffer.IsEmpty() and (TempReturnBuffer."Shipping Refund Amount" = 0) and (TempReturnBuffer."Refund Beyond Lines Amount" = 0) and (RefundTotal(TempRefundTxnBuffer) - DroppedAmount <= 0) then begin
                OutcomeMessage := StrSubstNo(NothingToCreditMsg, DisplayName, TempReturnBuffer."Order Name");
                exit(Outcome::"Nothing to Credit");
            end;
            // A withheld amount larger than what BC is left to credit would make a credit memo charge the customer.
            if (DroppedAmount > 0) and (RefundTotal(TempRefundTxnBuffer) - DroppedAmount <= 0) then
                Error(NothingLeftAfterWithheldErr, DisplayName, DroppedAmount, RefundTotal(TempRefundTxnBuffer));
        end;
        if OtherDraftSettlesOrderInvoice(ShopifyStore.Code, TempReturnBuffer."Order Id", TempReturnBuffer."Source Type", TempReturnBuffer."Return Id", DisplayName, true, OutcomeMessage) then
            exit(Outcome::Waiting);
        TempReturnBuffer.GetOrderJson(OrderToken);
        _OrderMgt.FindNpEcStore(ShopifyStore.Code, TempReturnBuffer."Source Name", NpEcStore);
        FindCustomer(NpEcStore, OrderToken, Customer);
        // Nothing is received when a refund restocks nothing, so the store's location is used without flagging a fallback.
        if (TempReturnBuffer."Source Type" = TempReturnBuffer."Source Type"::Refund) and not RestocksAnything(TempLineBuffer) then
            LocationCode := NpEcStore.LocationCode
        else
            ResolveHeaderLocation(ShopifyStore.Code, NpEcStore, DisplayName, TempLineBuffer, LocationCode, UsedLocationFallback);
        CreateSalesHeader(ShopifyStore, NpEcStore, Customer, LocationCode, TempReturnBuffer, SalesHeader);
        CreateSalesLines(ShopifyStore, DisplayName, TempLineBuffer, SalesHeader);
        // Skipping the line would leave its amount unexplained, which the discount rule below would take for a discount or refuse.
        if (TempReturnBuffer."Shipping Refund Amount" <> 0) and (ShopifyStore."Ret. Shipping Refund G/L Acc." = '') then
            Error(ShippingAccountMissingErr, TempReturnBuffer."Shipping Refund Amount", DisplayName, ShopifyStore.FieldCaption("Ret. Shipping Refund G/L Acc."), ShopifyStore.TableCaption());
        CreateGLLine(SalesHeader, ShopifyStore."Ret. Shipping Refund G/L Acc.", TempReturnBuffer."Shipping Refund Amount", ShippingRefundLbl);
        if TempReturnBuffer."Fee Amount" <> 0 then begin
            if ShopifyStore."Return Fee G/L Account No." = '' then
                Error(ReturnFeeAccountMissingErr, TempReturnBuffer."Fee Amount", DisplayName, ShopifyStore.FieldCaption("Return Fee G/L Account No."), ShopifyStore.TableCaption());
            CreateGLLine(SalesHeader, ShopifyStore."Return Fee G/L Account No.", -TempReturnBuffer."Fee Amount", ReturnFeeLbl);
        end;
        if TempReturnBuffer."Refund Beyond Lines Amount" <> 0 then begin
            if ShopifyStore."Refund Discrepancy G/L Acc." = '' then
                Error(_DiscrepancyAccountMissingErr, TempReturnBuffer."Refund Beyond Lines Amount", DisplayName, ShopifyStore.FieldCaption("Refund Discrepancy G/L Acc."), ShopifyStore.TableCaption());
            CreateGLLine(SalesHeader, ShopifyStore."Refund Discrepancy G/L Acc.", TempReturnBuffer."Refund Beyond Lines Amount", RefundDiscrepancyLbl);
        end;
        // The dropped units' money never reached BC: the order import capped the payment at the smaller invoice.
        ExpectedTotal := RefundTotal(TempRefundTxnBuffer) - DroppedAmount;
        BookUnexplainedRefund(SalesHeader, ShopifyStore, TempReturnBuffer, OrderToken, DisplayName, ExpectedTotal);
        SetQuantitiesToPost(SalesHeader);
        VerifyDocumentCoversRefund(SalesHeader, ShopifyStore, DisplayName, ExpectedTotal);
        AppliedAmount := ApplyToOpenInvoice(ShopifyStore.Code, TempReturnBuffer."Order Id", DisplayName, ExpectedTotal, SalesHeader);
        InsertPaymentLines(SalesHeader, ShopifyStore.Code, TempReturnBuffer."Return Id", DisplayName, TempRefundTxnBuffer, DroppedAmount + AppliedAmount, AppliedAmount > 0);
        _SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), _SpfyLegacyReturnMgt.SourceDocIdType(TempReturnBuffer."Source Type"), TempReturnBuffer."Return Id", false);
        _SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", ShopifyStore.Code, false);
        WriteSettlement(ShopifyStore.Code, SalesHeader, TempReturnBuffer, TempRefundTxnBuffer, AppliedAmount);
        exit(Outcome::Built);
    end;

    /// <summary>
    /// Records what the posting has to settle for this document, keyed by the ids the document is stamped with.
    /// </summary>
    internal procedure WriteSettlement(ShopifyStoreCode: Code[20]; SalesHeader: Record "Sales Header"; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; AppliedAmount: Decimal)
    var
        Settlement: Record "NPR Spfy Refund Settlement";
        GiftCardId: Text[30];
        VoucherNo: Code[20];
        GiftCardRefundAmount: Decimal;
        VoucherRefundAmount: Decimal;
        VoucherRefundAmountLCY: Decimal;
        MultipleGiftCards: Boolean;
        VoucherAmbiguous: Boolean;
        GiftCardsAmbiguousErr: Label 'Shopify %1 puts money back on gift cards that Business Central cannot tell apart, so it cannot credit the right vouchers. Credit the vouchers by hand and dismiss the queue row.', Comment = '%1 = Shopify document caption';
    begin
        SummariseGiftCardRefund(TempRefundTxnBuffer, GiftCardId, GiftCardRefundAmount, VoucherRefundAmount, VoucherRefundAmountLCY, MultipleGiftCards);
        // A card left without its share keeps Shopify's balance above BC's, and the balance sync would later take the difference back off the card.
        if MultipleGiftCards then
            Error(GiftCardsAmbiguousErr, _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id"));
        if VoucherRefundAmount > 0 then begin
            VoucherNo := ResolveVoucherNo(ShopifyStoreCode, TempReturnBuffer."Order Id", GiftCardId, VoucherAmbiguous);
            if VoucherAmbiguous then
                Error(GiftCardsAmbiguousErr, _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id"));
        end;
        if not Settlement.Get(ShopifyStoreCode, TempReturnBuffer."Source Type", TempReturnBuffer."Return Id") then begin
            Settlement.Init();
            Settlement."Shopify Store Code" := ShopifyStoreCode;
            Settlement."Source Doc. Type" := TempReturnBuffer."Source Type";
            Settlement."Shopify Id" := TempReturnBuffer."Return Id";
            Settlement.Insert();
        end;
        Settlement."Display Name" := _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id");
        Settlement."Order Id" := TempReturnBuffer."Order Id";
        Settlement."Return Order No." := SalesHeader."No.";
        Settlement."Gift Card Refund Amount" := GiftCardRefundAmount;
        // Store credit has no voucher: the card is credited back with its own share only.
        Settlement."Voucher No." := VoucherNo;
        Settlement."Voucher Refund Amount" := 0;
        Settlement."Voucher Refund Amount (LCY)" := 0;
        if VoucherNo <> '' then begin
            Settlement."Voucher Refund Amount" := VoucherRefundAmount;
            Settlement."Voucher Refund Amount (LCY)" := VoucherRefundAmountLCY;
        end;
        Settlement."Applied Amount" := AppliedAmount;
        Settlement.Modify();
    end;

    /// <summary>
    /// Sums the refund money that stays with Shopify as a customer liability (gift cards and store credit), and the gift cards' own share,
    /// also in LCY as Shopify booked it when its shop currency is the LCY, as the order import books the card's payment.
    /// </summary>
    local procedure SummariseGiftCardRefund(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; var GiftCardId: Text[30]; var GiftCardRefundAmount: Decimal; var VoucherRefundAmount: Decimal; var VoucherRefundAmountLCY: Decimal; var MultipleGiftCards: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        GiftCardIds: List of [Text];
        UnknownGiftCardCount: Integer;
        LCYKnown: Boolean;
    begin
        Clear(GiftCardId);
        Clear(GiftCardRefundAmount);
        Clear(VoucherRefundAmount);
        Clear(VoucherRefundAmountLCY);
        GLSetup.Get();
        LCYKnown := true;
        TempRefundTxnBuffer.Reset();
        if TempRefundTxnBuffer.FindSet() then
            repeat
                if _SpfyLegacyReturnMgt.IsStoreCreditRefundTxn(TempRefundTxnBuffer) then
                    GiftCardRefundAmount += TempRefundTxnBuffer.Amount
                else
                    if _SpfyLegacyReturnMgt.IsGiftCardRefundTxn(TempRefundTxnBuffer) then begin
                        GiftCardRefundAmount += TempRefundTxnBuffer.Amount;
                        VoucherRefundAmount += TempRefundTxnBuffer.Amount;
                        if (TempRefundTxnBuffer."Amount (Store Currency)" <> 0) and ((TempRefundTxnBuffer."Store Currency Code" = '') or (TempRefundTxnBuffer."Store Currency Code" = GLSetup."LCY Code")) then
                            VoucherRefundAmountLCY += TempRefundTxnBuffer."Amount (Store Currency)"
                        else
                            LCYKnown := false;
                        // Count cards, not transactions; a gift card transaction without an id counts as its own card.
                        if TempRefundTxnBuffer."Gift Card Id" = '' then
                            UnknownGiftCardCount += 1
                        else
                            if not GiftCardIds.Contains(TempRefundTxnBuffer."Gift Card Id") then
                                GiftCardIds.Add(TempRefundTxnBuffer."Gift Card Id");
                    end;
            until TempRefundTxnBuffer.Next() = 0;
        if not LCYKnown then
            VoucherRefundAmountLCY := 0;
        MultipleGiftCards := GiftCardIds.Count() + UnknownGiftCardCount > 1;
        if (not MultipleGiftCards) and (GiftCardIds.Count() = 1) then
            GiftCardId := CopyStr(GiftCardIds.Get(1), 1, MaxStrLen(GiftCardId));
    end;

    /// <summary>
    /// Refusals before anything is built or adopted: a return that is not closed or carries an exchange, a refund that belongs to a return.
    /// </summary>
    internal procedure CheckSourceIsImportable(var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary)
    var
        ExchangeNotSupportedErr: Label 'Shopify return %1 contains an exchange line. Exchanges are not imported; handle this return manually.', Comment = '%1 = Shopify return name';
        ReturnNotClosedErr: Label 'Shopify return %1 is %2, not closed, so it is not imported yet. The row is retried; once the return is closed, Discard Draft and Retry queues it again.', Comment = '%1 = Shopify return name, %2 = Shopify return status';
        RefundOfAReturnErr: Label 'Shopify %1 belongs to a return, so it is imported with that return and not on its own. Dismiss this row.', Comment = '%1 = Shopify document caption';
    begin
        if TempReturnBuffer."Source Type" = TempReturnBuffer."Source Type"::Refund then begin
            if TempReturnBuffer."Belongs to Return" then
                Error(RefundOfAReturnErr, _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id"));
            exit;
        end;
        if TempReturnBuffer.Status <> 'CLOSED' then
            Error(ReturnNotClosedErr, TempReturnBuffer."Return Name", TempReturnBuffer.Status);
        if TempReturnBuffer."Has Exchange Line" then
            Error(ExchangeNotSupportedErr, TempReturnBuffer."Return Name");
    end;

    local procedure FindCustomer(NpEcStore: Record "NPR NpEc Store"; OrderToken: JsonToken; var Customer: Record Customer)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        JsonHelper: Codeunit "NPR Json Helper";
        CountryCode: Code[10];
        ShopifyCustomerID: Text[30];
        Email: Text;
        Phone: Text;
        FirstName: Text;
        LastName: Text;
        PostCode: Text;
        BillingAdd1: Text;
        BillingAdd2: Text;
        BillingCity: Text;
        CustomerName: Text;
    begin
        _OrderMgt.GetCustomerIdentifiers(OrderToken, Email, Phone, ShopifyCustomerID, 'customer.defaultAddress.phone', true);
        FirstName := JsonHelper.GetJText(OrderToken, 'customer.firstName', false);
        LastName := JsonHelper.GetJText(OrderToken, 'customer.lastName', false);
        if _OrderMgt.TryFindCustomer(NpEcStore, OrderToken, ShopifyCustomerID, Email, Phone, FirstName, LastName, Customer, SpfyStoreCustomerLink) then
            exit;
        CountryCode := _OrderMgt.GetCountryCode(NpEcStore, OrderToken, 'billingAddress.countryCodeV2', false);
        PostCode := JsonHelper.GetJCode(OrderToken, 'billingAddress.zip', MaxStrLen(Customer."Post Code"), false);
        BillingAdd1 := JsonHelper.GetJText(OrderToken, 'billingAddress.address1', MaxStrLen(Customer.Address), false);
        BillingAdd2 := JsonHelper.GetJText(OrderToken, 'billingAddress.address2', MaxStrLen(Customer."Address 2"), false);
        BillingCity := JsonHelper.GetJText(OrderToken, 'billingAddress.city', MaxStrLen(Customer.City), false);
        CustomerName := (FirstName + ' ' + LastName).Trim();
        _OrderMgt.ResolveCustomer(NpEcStore, Email, Phone, BillingCity, BillingAdd1, BillingAdd2, CountryCode, PostCode, ShopifyCustomerID, CustomerName, Customer, SpfyStoreCustomerLink);
    end;

    local procedure LineCaption(TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary): Text
    begin
        if TempLineBuffer.SKU <> '' then
            exit(TempLineBuffer.SKU);
        exit(TempLineBuffer.Title);
    end;

    /// <summary>
    /// A refund transaction Shopify has not completed yet may still succeed, so the document waits rather than failing on the total.
    /// </summary>
    internal procedure RefundStillPending(var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var WaitingMessage: Text): Boolean
    var
        WaitingForPendingRefundMsg: Label 'Waiting until Shopify completes %1 pending refund transaction(s) of Shopify %2; it is imported then.', Comment = '%1 = number of pending transactions, %2 = Shopify document caption';
    begin
        if TempReturnBuffer."Pending Refund Txns" <= 0 then
            exit(false);
        WaitingMessage := StrSubstNo(WaitingForPendingRefundMsg, TempReturnBuffer."Pending Refund Txns", _SpfyLegacyReturnAPI.DocumentCaption(TempReturnBuffer."Source Type", TempReturnBuffer."Return Name", TempReturnBuffer."Return Id"));
        exit(true);
    end;

    /// <summary>
    /// An order BC never invoiced: not imported yet when BC has no Sales Order for it, or never to be invoiced when Shopify cancelled it, or when its Sales Order has nothing left to post and Shopify shipped nothing, so BC received nothing for it.
    /// A fulfilled order is shipped and invoiced by the order import whatever was refunded since, so its refund waits for the invoice even while the Sales Order shows nothing to post.
    /// </summary>
    local procedure OrderNeverInvoiced(ShopifyStoreCode: Code[20]; DisplayName: Text[50]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var Outcome: Enum "NPR Spfy Refund Build Outcome"; var OutcomeMessage: Text): Boolean
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        SalesHeader: Record "Sales Header";
        WaitingForOrderImportMsg: Label 'Waiting until Business Central has invoiced Shopify order %1, which has no %2 or %3 here yet; %4 is imported then. If the order is never imported here, dismiss it.', Comment = '%1 = Shopify order name, %2 = Sales Header table caption, %3 = Sales Invoice Header table caption, %4 = Shopify document caption';
        NothingLeftNeverInvoicedMsg: Label 'Business Central never invoiced Shopify order %1, and its %2 %3 has nothing left to ship or invoice, so Business Central never received money for it and %4 has nothing to credit.', Comment = '%1 = Shopify order name, %2 = Sales Header table caption, %3 = Sales Order no., %4 = Shopify document caption';
        WaitingForFulfilledOrderMsg: Label 'Waiting until Business Central has invoiced Shopify order %1: Shopify has shipped it, but its %2 %3 has nothing to ship or invoice yet. Shopify %4 is imported once the order is invoiced. If %3 cannot be posted, correct it; if the order is never invoiced here, dismiss this row.', Comment = '%1 = Shopify order name, %2 = Sales Header table caption, %3 = Sales Order no., %4 = Shopify document caption';
        CancelledNeverInvoicedMsg: Label 'Shopify order %1 was cancelled before Business Central invoiced any of it, so Business Central never received money for it and %2 has nothing to credit.', Comment = '%1 = Shopify order name, %2 = Shopify document caption';
    begin
        if CollectOrderInvoices(ShopifyStoreCode, TempReturnBuffer."Order Id", TempSalesInvoiceHeader) then
            exit(false);
        // OrderStillOpen ran first, so a Sales Order found here has nothing left to post.
        if FindSalesOrder(ShopifyStoreCode, TempReturnBuffer."Order Id", false, SalesHeader) then begin
            if TempReturnBuffer."Order Fulfilled" and not TempReturnBuffer."Order Cancelled" then begin
                Outcome := Outcome::Waiting;
                OutcomeMessage := StrSubstNo(WaitingForFulfilledOrderMsg, TempReturnBuffer."Order Name", SalesHeader.TableCaption(), SalesHeader."No.", DisplayName);
            end else begin
                Outcome := Outcome::"Nothing to Credit";
                OutcomeMessage := StrSubstNo(NothingLeftNeverInvoicedMsg, TempReturnBuffer."Order Name", SalesHeader.TableCaption(), SalesHeader."No.", DisplayName);
            end;
        end else
            if TempReturnBuffer."Order Cancelled" then begin
                Outcome := Outcome::"Nothing to Credit";
                OutcomeMessage := StrSubstNo(CancelledNeverInvoicedMsg, TempReturnBuffer."Order Name", DisplayName);
            end else begin
                Outcome := Outcome::Waiting;
                OutcomeMessage := StrSubstNo(WaitingForOrderImportMsg, TempReturnBuffer."Order Name", SalesHeader.TableCaption(), TempSalesInvoiceHeader.TableCaption(), DisplayName);
            end;
        exit(true);
    end;

    /// <summary>
    /// The order's other refunds only share out units the order import left off the invoices and count against this refund's cancels, so the import fetches them only when the refund is measured and one of those applies.
    /// </summary>
    internal procedure NeedsOtherRefunds(ShopifyStoreCode: Code[20]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary): Boolean
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        Invoiced: Dictionary of [Text, Decimal];
        InvoicedQuantity: Decimal;
        WaitingMessage: Text;
    begin
        if TempReturnBuffer."Source Type" <> TempReturnBuffer."Source Type"::Refund then
            exit(false);
        if RefundStillPending(TempReturnBuffer, WaitingMessage) then
            exit(false);
        if OrderStillOpen(ShopifyStoreCode, TempReturnBuffer."Order Id", TempReturnBuffer."Order Name", WaitingMessage) then
            exit(false);
        if not CollectOrderInvoices(ShopifyStoreCode, TempReturnBuffer."Order Id", TempSalesInvoiceHeader) then
            exit(false);
        CollectInvoiced(ShopifyStoreCode, TempReturnBuffer."Order Id", Invoiced);
        TempLineBuffer.Reset();
        if TempLineBuffer.FindSet() then
            repeat
                if TempLineBuffer."Restock Type" = 'CANCEL' then
                    exit(true);
                InvoicedQuantity := 0;
                if Invoiced.ContainsKey(TempLineBuffer."Order Line Item Id") then
                    InvoicedQuantity := Invoiced.Get(TempLineBuffer."Order Line Item Id");
                if TempLineBuffer."Ordered Quantity" > InvoicedQuantity then
                    exit(true);
            until TempLineBuffer.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// While the Sales Order has something left to ship or invoice, the order import still owns the order and its quantities may not reflect the refund yet, so nothing can be measured. A Sales Order with nothing left is never posted again, so it does not hold the refund back.
    /// </summary>
    internal procedure OrderStillOpen(ShopifyStoreCode: Code[20]; OrderId: Text[30]; OrderName: Text; var WaitingMessage: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        WaitingForOrderMsg: Label 'Waiting until Business Central has invoiced Shopify order %1 (%2 %3); this refund is imported then.', Comment = '%1 = Shopify order name, %2 = Sales Header table caption, %3 = Sales Order no.';
    begin
        if not FindSalesOrder(ShopifyStoreCode, OrderId, true, SalesHeader) then
            exit(false);
        if OrderName = '' then
            OrderName := OrderId;
        WaitingMessage := StrSubstNo(WaitingForOrderMsg, OrderName, SalesHeader.TableCaption(), SalesHeader."No.");
        exit(true);
    end;

    local procedure FindSalesOrder(ShopifyStoreCode: Code[20]; OrderId: Text[30]; WithQuantityLeftToPost: Boolean; var SalesHeader: Record "Sales Header"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        RecRef: RecordRef;
    begin
        if OrderId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Header", "NPR Spfy ID Type"::"Entry ID", OrderId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesHeader);
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                            if not WithQuantityLeftToPost then
                                exit(true)
                            else
                                if HasQuantityLeftToPost(SalesHeader) then
                                    exit(true);
                end;
            until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;

    local procedure HasQuantityLeftToPost(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Outstanding Quantity", '<>0');
        if not SalesLine.IsEmpty() then
            exit(true);
        SalesLine.SetRange("Outstanding Quantity");
        SalesLine.SetFilter("Qty. Shipped Not Invoiced", '<>0');
        exit(not SalesLine.IsEmpty());
    end;

    /// <summary>
    /// Sums the invoiced quantity per Shopify line item over the order's invoices of this store.
    /// </summary>
    local procedure CollectInvoiced(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var Invoiced: Dictionary of [Text, Decimal])
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        SalesInvoiceLine: Record "Sales Invoice Line";
        LineItemId: Text;
        Qty: Decimal;
    begin
        if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit;
        TempSalesInvoiceHeader.FindSet();
        repeat
            SalesInvoiceLine.SetRange("Document No.", TempSalesInvoiceHeader."No.");
            if SalesInvoiceLine.FindSet() then
                repeat
                    LineItemId := _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvoiceLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    if LineItemId <> '' then begin
                        Qty := 0;
                        if Invoiced.ContainsKey(LineItemId) then
                            Qty := Invoiced.Get(LineItemId);
                        Invoiced.Set(LineItemId, Qty + SalesInvoiceLine.Quantity);
                    end;
                until SalesInvoiceLine.Next() = 0;
        until TempSalesInvoiceHeader.Next() = 0;
    end;

    /// <summary>
    /// Invoices made from posted shipments (Get Shipment Lines, Combine Shipments) carry no Shopify stamps, so what BC invoiced could not be measured from them.
    /// The order's shipments still show what was invoiced; more there than on the stamped invoices means part of the order was invoiced outside its Sales Order.
    /// </summary>
    local procedure CheckInvoicedThroughOrder(ShopifyStoreCode: Code[20]; DisplayName: Text[50]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary)
    var
        Invoiced: Dictionary of [Text, Decimal];
        ShipmentInvoiced: Dictionary of [Text, Decimal];
        LineItemId: Text;
        StampedQuantity: Decimal;
        InvoicedOutsideOrderErr: Label 'Shopify order %1 was invoiced in Business Central partly outside its Sales Order, for example from posted shipments, so %2 cannot be measured against its invoices. Handle it manually and dismiss the queue row.', Comment = '%1 = Shopify order name, %2 = Shopify document caption';
    begin
        CollectShipmentInvoiced(ShopifyStoreCode, TempReturnBuffer."Order Id", ShipmentInvoiced);
        if ShipmentInvoiced.Count() = 0 then
            exit;
        CollectInvoiced(ShopifyStoreCode, TempReturnBuffer."Order Id", Invoiced);
        foreach LineItemId in ShipmentInvoiced.Keys() do begin
            StampedQuantity := 0;
            if Invoiced.ContainsKey(LineItemId) then
                StampedQuantity := Invoiced.Get(LineItemId);
            if ShipmentInvoiced.Get(LineItemId) > StampedQuantity then
                Error(InvoicedOutsideOrderErr, TempReturnBuffer."Order Name", DisplayName);
        end;
    end;

    /// <summary>
    /// Sums the invoiced quantity per Shopify line item over the order's posted shipments of this store.
    /// </summary>
    local procedure CollectShipmentInvoiced(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var ShipmentInvoiced: Dictionary of [Text, Decimal])
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        RecRef: RecordRef;
        LineItemId: Text;
        Qty: Decimal;
    begin
        if OrderId = '' then
            exit;
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Shipment Header", "NPR Spfy ID Type"::"Entry ID", OrderId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if _SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                    if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                        RecRef.SetTable(SalesShipmentHeader);
                        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                        // An undone shipment's two lines are both marked Correction, and the reversing one carries no stamp.
                        SalesShipmentLine.SetRange(Correction, false);
                        SalesShipmentLine.SetFilter("Quantity Invoiced", '<>0');
                        if SalesShipmentLine.FindSet() then
                            repeat
                                LineItemId := _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesShipmentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                                if LineItemId <> '' then begin
                                    Qty := 0;
                                    if ShipmentInvoiced.ContainsKey(LineItemId) then
                                        Qty := ShipmentInvoiced.Get(LineItemId);
                                    ShipmentInvoiced.Set(LineItemId, Qty + SalesShipmentLine."Quantity Invoiced");
                                end;
                            until SalesShipmentLine.Next() = 0;
                    end;
            until ShopifyAssignedID.Next() = 0;
    end;

    /// <summary>
    /// The posted invoices of the Shopify order on this store, found by the stamps the order import puts on them.
    /// </summary>
    internal procedure CollectOrderInvoices(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        TempSalesInvoiceHeader.Reset();
        TempSalesInvoiceHeader.DeleteAll();
        if OrderId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Invoice Header", "NPR Spfy ID Type"::"Entry ID", OrderId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if _SpfyAssignedIDMgt.GetAssignedShopifyID(ShopifyAssignedID."BC Record ID", "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                    if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                        RecRef.SetTable(SalesInvoiceHeader);
                        TempSalesInvoiceHeader := SalesInvoiceHeader;
                        if TempSalesInvoiceHeader.Insert() then;
                    end;
            until ShopifyAssignedID.Next() = 0;
        exit(not TempSalesInvoiceHeader.IsEmpty());
    end;

    /// <summary>
    /// Takes the units the order import left off the order's invoices out of the refund: BC never invoiced them and never received their money, so they are not credited.
    /// </summary>
    local procedure AllocateDroppedUnits(ShopifyStoreCode: Code[20]; DisplayName: Text[50]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary) DroppedAmount: Decimal
    var
        Invoiced: Dictionary of [Text, Decimal];
        LineItemIds: List of [Text];
        LineItemId: Text;
        InvoicedQuantity: Decimal;
        RoundingPrecision: Decimal;
    begin
        CollectInvoiced(ShopifyStoreCode, TempReturnBuffer."Order Id", Invoiced);
        RoundingPrecision := _SpfyLegacyReturnAPI.AmountRoundingPrecision(ShopifyStoreCode, TempReturnBuffer."Presentment Currency Code");
        TempLineBuffer.Reset();
        if TempLineBuffer.FindSet() then
            repeat
                if not LineItemIds.Contains(TempLineBuffer."Order Line Item Id") then
                    LineItemIds.Add(TempLineBuffer."Order Line Item Id");
            until TempLineBuffer.Next() = 0;
        foreach LineItemId in LineItemIds do begin
            InvoicedQuantity := 0;
            if Invoiced.ContainsKey(LineItemId) then
                InvoicedQuantity := Invoiced.Get(LineItemId);
            DroppedAmount += AllocateLineItem(DisplayName, TempReturnBuffer."Order Name", LineItemId, InvoicedQuantity, TempReturnBuffer."Other Refunds Incomplete", RoundingPrecision, TempLineBuffer, TempOtherLineBuffer);
        end;
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange(Quantity, 0);
        TempLineBuffer.DeleteAll();
        TempLineBuffer.Reset();
    end;

    /// <summary>
    /// Dropped units never shipped, so across the order's refunds they go to CANCEL, then NO_RESTOCK, then LEGACY_RESTOCK, then the rest, oldest refund first within a kind.
    /// </summary>
    local procedure AllocateLineItem(DisplayName: Text[50]; OrderName: Text; LineItemId: Text; InvoicedQuantity: Decimal; OtherRefundsIncomplete: Boolean; RoundingPrecision: Decimal; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary) DroppedAmount: Decimal
    var
        Dropped: Decimal;
        CancelQuantity: Decimal;
        OwnCancelQuantity: Decimal;
        EarlierCancelQuantity: Decimal;
        Remaining: Decimal;
        Kind: Integer;
        CancelledBeyondDroppedErr: Label 'Shopify %1 and the refunds before it cancel %2 unit(s) of %3, but Business Central left only %4 of them off the invoices of order %5. Check the order''s invoices and handle this refund manually.', Comment = '%1 = Shopify document caption, %2 = quantity cancelled by this and earlier refunds, %3 = SKU or title of the line, %4 = quantity left off the invoices, %5 = Shopify order name';
        OtherRefundsIncompleteErr: Label 'Units of Shopify %1 were left off the invoices of order %2, but the order''s other refunds could not be read in full, so they cannot be allocated between the refunds. Handle this refund manually.', Comment = '%1 = Shopify document caption, %2 = Shopify order name';
    begin
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange("Order Line Item Id", LineItemId);
        TempLineBuffer.FindFirst();
        Dropped := TempLineBuffer."Ordered Quantity" - InvoicedQuantity;
        if Dropped < 0 then
            Dropped := 0;
        if (Dropped > 0) and OtherRefundsIncomplete then
            Error(OtherRefundsIncompleteErr, DisplayName, OrderName);
        OwnCancelQuantity := SumOfKind(TempLineBuffer, LineItemId, 1, false, false);
        EarlierCancelQuantity := SumOfKind(TempOtherLineBuffer, LineItemId, 1, true, false);
        // Cancels take the dropped units oldest first; this refund is refused only when its own no longer fit.
        if (OwnCancelQuantity > 0) and (EarlierCancelQuantity + OwnCancelQuantity > Dropped) then begin
            TempLineBuffer.Reset();
            TempLineBuffer.SetRange("Order Line Item Id", LineItemId);
            TempLineBuffer.FindFirst();
            Error(CancelledBeyondDroppedErr, DisplayName, EarlierCancelQuantity + OwnCancelQuantity, LineCaption(TempLineBuffer), Dropped, OrderName);
        end;
        CancelQuantity := SmallerOf(Dropped, EarlierCancelQuantity + OwnCancelQuantity + SumOfKind(TempOtherLineBuffer, LineItemId, 1, true, true));
        Remaining := Dropped - CancelQuantity;
        for Kind := 1 to 4 do begin
            if Kind > 1 then
                Remaining -= SmallerOf(Remaining, SumOfKind(TempOtherLineBuffer, LineItemId, Kind, true, false));
            SetKindFilter(TempLineBuffer, LineItemId, Kind);
            if TempLineBuffer.FindSet() then
                repeat
                    if Kind = 1 then
                        DroppedAmount += DropUnits(TempLineBuffer, TempLineBuffer.Quantity, RoundingPrecision)
                    else
                        DroppedAmount += DropFromLine(TempLineBuffer, Remaining, RoundingPrecision);
                until TempLineBuffer.Next() = 0;
            if Kind > 1 then
                Remaining -= SmallerOf(Remaining, SumOfKind(TempOtherLineBuffer, LineItemId, Kind, true, true));
        end;
        TempLineBuffer.Reset();
    end;

    /// <summary>
    /// The quantity of one restock kind for the line item; in the other refunds' buffer, of the earlier or the later ones only.
    /// </summary>
    local procedure SumOfKind(var TempBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; LineItemId: Text; Kind: Integer; OtherRefunds: Boolean; Later: Boolean): Decimal
    begin
        SetKindFilter(TempBuffer, LineItemId, Kind);
        if OtherRefunds then
            TempBuffer.SetRange("Later Refund", Later);
        TempBuffer.CalcSums(Quantity);
        exit(TempBuffer.Quantity);
    end;

    local procedure SetKindFilter(var TempBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; LineItemId: Text; Kind: Integer)
    begin
        TempBuffer.Reset();
        TempBuffer.SetRange("Order Line Item Id", LineItemId);
        case Kind of
            1:
                TempBuffer.SetRange("Restock Type", 'CANCEL');
            2:
                TempBuffer.SetRange("Restock Type", 'NO_RESTOCK');
            3:
                TempBuffer.SetRange("Restock Type", 'LEGACY_RESTOCK');
            4:
                TempBuffer.SetFilter("Restock Type", '<>%1&<>%2&<>%3', 'CANCEL', 'NO_RESTOCK', 'LEGACY_RESTOCK');
        end;
    end;

    local procedure SmallerOf(A: Decimal; B: Decimal): Decimal
    begin
        if A < B then
            exit(A);
        exit(B);
    end;

    local procedure DropFromLine(var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var Remaining: Decimal; RoundingPrecision: Decimal): Decimal
    var
        LineDropped: Decimal;
    begin
        if Remaining <= 0 then
            exit(0);
        LineDropped := TempLineBuffer.Quantity;
        if LineDropped > Remaining then
            LineDropped := Remaining;
        Remaining -= LineDropped;
        exit(DropUnits(TempLineBuffer, LineDropped, RoundingPrecision));
    end;

    local procedure DropUnits(var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; Units: Decimal; RoundingPrecision: Decimal) DroppedAmount: Decimal
    begin
        if Units <= 0 then
            exit(0);
        if Units >= TempLineBuffer.Quantity then begin
            DroppedAmount := TempLineBuffer."Line Amount";
            TempLineBuffer.Quantity := 0;
            TempLineBuffer."Line Amount" := 0;
        end else begin
            // At the document's precision, so the line left and the expected total round alike.
            DroppedAmount := Round(TempLineBuffer."Line Amount" * Units / TempLineBuffer.Quantity, RoundingPrecision);
            TempLineBuffer.Quantity -= Units;
            TempLineBuffer."Line Amount" -= DroppedAmount;
            // Rounded up, as the parser does: Sales Line refuses a Line Amount above Quantity * Unit Price.
            TempLineBuffer."Unit Price" := Round(TempLineBuffer."Line Amount" / TempLineBuffer.Quantity, 0.01, '>');
        end;
        TempLineBuffer.Modify();
    end;

    local procedure RestocksAnything(var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary) Restocks: Boolean
    begin
        TempLineBuffer.Reset();
        TempLineBuffer.SetFilter("Restock Type", '%1|%2', 'RETURN', 'LEGACY_RESTOCK');
        Restocks := not TempLineBuffer.IsEmpty();
        TempLineBuffer.Reset();
    end;

    local procedure ResolveHeaderLocation(ShopifyStoreCode: Code[20]; NpEcStore: Record "NPR NpEc Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var LocationCode: Code[10]; var UsedFallback: Boolean)
    var
        Location: Record Location;
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        CandidateLocationCode: Code[10];
        FirstResolvedLocationCode: Code[10];
        AllAgree: Boolean;
        AnyResolved: Boolean;
        NoLocationErr: Label 'No %1 could be resolved for Shopify %2: none of its restock locations is linked to the store and the %3 has no %4.', Comment = '%1 = Location table caption, %2 = Shopify document caption, %3 = NpEc Store table caption, %4 = NpEc Store Location Code field caption';
    begin
        AllAgree := true;
        TempLineBuffer.Reset();
        if TempLineBuffer.FindSet() then
            repeat
                if SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID(ShopifyStoreCode, TempLineBuffer."Disposition Location Id", CandidateLocationCode) then
                    if not AnyResolved then begin
                        FirstResolvedLocationCode := CandidateLocationCode;
                        AnyResolved := true;
                    end else
                        if CandidateLocationCode <> FirstResolvedLocationCode then
                            AllAgree := false;
            until TempLineBuffer.Next() = 0;
        UsedFallback := false;
        if AnyResolved and AllAgree then begin
            LocationCode := FirstResolvedLocationCode;
            exit;
        end;
        UsedFallback := true;
        if NpEcStore.LocationCode <> '' then begin
            LocationCode := NpEcStore.LocationCode;
            exit;
        end;
        if AnyResolved then begin
            LocationCode := FirstResolvedLocationCode;
            exit;
        end;
        Error(NoLocationErr, Location.TableCaption(), ReturnName, NpEcStore.TableCaption(), NpEcStore.FieldCaption(LocationCode));
    end;

    local procedure CreateSalesHeader(ShopifyStore: Record "NPR Spfy Store"; NpEcStore: Record "NPR NpEc Store"; Customer: Record Customer; LocationCode: Code[10]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var SalesHeader: Record "Sales Header")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        CurrencyCode: Code[10];
        CurrencyIsLCY: Boolean;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Location Code", LocationCode);
        if TempReturnBuffer."Posting DateTime" <> 0DT then
            SalesHeader.Validate("Posting Date", DT2Date(TempReturnBuffer."Posting DateTime"));
        SalesHeader.Validate("Prices Including VAT", true);
        CurrencyCode := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(TempReturnBuffer."Presentment Currency Code", SpfyIntegrationMgt.CurrencyBlankForLCY(ShopifyStore.Code), CurrencyIsLCY);
        if CurrencyCode <> SalesHeader."Currency Code" then
            SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader."External Document No." := CopyStr(SpfyIntegrationMgt.BuildExternalDocumentNo(ShopifyStore.Code, TempReturnBuffer."Order No.", TempReturnBuffer."Order Name", MaxStrLen(SalesHeader."External Document No.")), 1, MaxStrLen(SalesHeader."External Document No."));
        if NpEcStore."Salesperson/Purchaser Code" <> '' then
            SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");
        // Blank: BC would otherwise balance the credit memo itself and the settlement would fail.
        SalesHeader.Validate("Payment Method Code", '');
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLines(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header")
    var
        LineNo: Integer;
    begin
        TempLineBuffer.Reset();
        if not TempLineBuffer.FindSet() then
            exit;
        repeat
            LineNo += 10000;
            if TempLineBuffer."Gift Card" then
                CreateGiftCardLine(ShopifyStore, ReturnName, TempLineBuffer, SalesHeader, LineNo)
            else
                if TempLineBuffer."Restock Type" = 'NO_RESTOCK' then
                    CreateItemChargeLine(ShopifyStore, ReturnName, TempLineBuffer, SalesHeader, LineNo)
                else
                    CreateItemLine(ShopifyStore, ReturnName, TempLineBuffer, SalesHeader, LineNo);
        until TempLineBuffer.Next() = 0;
    end;

    local procedure CreateItemLine(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header"; LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        LineItemToken: JsonToken;
        Sku: Text;
        LineLocationCode: Code[10];
        UseGenericItem: Boolean;
        ItemNotFoundErr: Label 'No %1 could be matched for SKU %2 on Shopify %3.', Comment = '%1 = Item table caption, %2 = SKU, %3 = Shopify document caption';
    begin
        UseGenericItem := UsesGenericItem(ShopifyStore, TempLineBuffer.SKU);
        if UseGenericItem then
            Item.Get(ShopifyStore."Return Generic Item No.")
        else begin
            TempLineBuffer.GetLineItemJson(LineItemToken);
            if not SpfyItemMgt.ParseItemForDocumentImport(ShopifyStore.Code, LineItemToken, ItemVariant, Item, Sku) then
                Error(ItemNotFoundErr, Item.TableCaption(), TempLineBuffer.SKU, ReturnName);
        end;

        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        if ItemVariant.Code <> '' then
            SalesLine.Validate("Variant Code", ItemVariant.Code);
        if UseGenericItem then begin
            if TempLineBuffer.Title <> '' then
                SalesLine.Description := CopyStr(TempLineBuffer.Title, 1, MaxStrLen(SalesLine.Description));
            SalesLine."Description 2" := CopyStr(TempLineBuffer.SKU, 1, MaxStrLen(SalesLine."Description 2"));
        end;
        if Item.IsInventoriableType() then
            if SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID(ShopifyStore.Code, TempLineBuffer."Disposition Location Id", LineLocationCode) then
                SalesLine.Validate("Location Code", LineLocationCode);
        // VAT % stays at the VAT Posting Setup, as on the order import.
        SetQuantityAndAmounts(TempLineBuffer, SalesLine);
    end;

    /// <summary>
    /// A returned gift card is credited on the account its sale was posted on, and the vouchers that sale issued are attached for reversal at posting.
    /// </summary>
    local procedure CreateGiftCardLine(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header"; LineNo: Integer)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        SalesLine: Record "Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        UnusedCount: Integer;
        GiftCardSaleNotFoundErr: Label 'No posted %1 carries Shopify line item %2 of Shopify %3, so the gift card vouchers to revoke cannot be found. Handle it manually.', Comment = '%1 = Sales Invoice Line table caption, %2 = Shopify order line item id, %3 = Shopify document caption';
        GiftCardUsedErr: Label 'Shopify %1 credits %2 gift card(s) sold on %3 %4, but only %5 of the vouchers issued for that line are still untouched, not reserved as a payment and not claimed by another open return. Handle it manually.', Comment = '%1 = Shopify document caption, %2 = returned quantity, %3 = Sales Invoice Header table caption, %4 = posted invoice no(s)., %5 = number of vouchers still available';
        GiftCardNoRefundErr: Label 'Shopify %1 credits gift card line item %2 but refunds nothing for it, so there is no credit to revoke the vouchers against. Handle it manually.', Comment = '%1 = Shopify document caption, %2 = Shopify order line item id';
    begin
        // Without a refund there is nothing to credit, and a zero line would leave the cards active.
        if TempLineBuffer."Line Amount" <= 0 then
            Error(GiftCardNoRefundErr, ReturnName, TempLineBuffer."Order Line Item Id");
        if not FindPostedGiftCardSaleLines(ShopifyStore.Code, TempLineBuffer."Order Line Item Id", TempSalesInvoiceLine) then
            Error(GiftCardSaleNotFoundErr, TempSalesInvoiceLine.TableCaption(), TempLineBuffer."Order Line Item Id", ReturnName);
        UnusedCount := CollectUnusedVouchers(TempSalesInvoiceLine, TempLineBuffer.Quantity, TempVoucher);
        if UnusedCount < TempLineBuffer.Quantity then
            Error(GiftCardUsedErr, ReturnName, TempLineBuffer.Quantity, SalesInvoiceHeader.TableCaption(), InvoiceNos(TempSalesInvoiceLine), UnusedCount);

        // Every sale line of the gift card carries the same account; the first supplies the posting groups.
        TempSalesInvoiceLine.FindFirst();
        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", TempSalesInvoiceLine."No.");
        if SalesLine."Gen. Prod. Posting Group" <> TempSalesInvoiceLine."Gen. Prod. Posting Group" then
            SalesLine.Validate("Gen. Prod. Posting Group", TempSalesInvoiceLine."Gen. Prod. Posting Group");
        if SalesLine."VAT Prod. Posting Group" <> TempSalesInvoiceLine."VAT Prod. Posting Group" then
            SalesLine.Validate("VAT Prod. Posting Group", TempSalesInvoiceLine."VAT Prod. Posting Group");
        SalesLine.Description := TempSalesInvoiceLine.Description;
        SetQuantityAndAmounts(TempLineBuffer, SalesLine);
        AttachVouchersToRevoke(SalesHeader, SalesLine, TempVoucher);
    end;

    /// <summary>
    /// Quantity, price and gross amount as refunded, stamped with the Shopify line item it credits.
    /// </summary>
    local procedure SetQuantityAndAmounts(var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Validate(Quantity, TempLineBuffer.Quantity);
        // Before anything that depends on them, such as an item charge assignment.
        SetLineQuantitiesToPost(SalesLine);
        SalesLine.Validate("Unit Price", TempLineBuffer."Unit Price");
        if TempLineBuffer."Line Amount" <> 0 then
            SalesLine.Validate("Line Amount", TempLineBuffer."Line Amount");
        SalesLine.Modify(true);
        if TempLineBuffer."Order Line Item Id" <> '' then
            _SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempLineBuffer."Order Line Item Id", false);
    end;

    /// <summary>
    /// A line refunded while the customer keeps the goods reduces the sale on its original shipment and creates no stock.
    /// </summary>
    local procedure CreateItemChargeLine(ShopifyStore: Record "NPR Spfy Store"; ReturnName: Text[50]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; SalesHeader: Record "Sales Header"; LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        TempSalesShipmentLine: Record "Sales Shipment Line" temporary;
        ItemChargeMissingErr: Label 'Shopify %1 refunds %2 without the goods coming back, but %3 is blank on the %4. Set it so the refund can be credited as an item charge on the original shipment.', Comment = '%1 = Shopify document caption, %2 = SKU or title, %3 = Refund Item Charge No. caption, %4 = Shopify Store table caption';
    begin
        if ShopifyStore."Refund Item Charge No." = '' then
            Error(ItemChargeMissingErr, ReturnName, LineCaption(TempLineBuffer), ShopifyStore.FieldCaption("Refund Item Charge No."), ShopifyStore.TableCaption());
        if not CollectShipmentLines(ShopifyStore.Code, TempLineBuffer."Order Line Item Id", TempSalesShipmentLine) then
            Error(_ShipmentNotFoundErr, TempSalesShipmentLine.TableCaption(), TempLineBuffer."Order Line Item Id", ReturnName);
        TempSalesShipmentLine.FindFirst();
        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", ShopifyStore."Refund Item Charge No.");
        // VAT follows the item, as on the sale being reduced.
        if SalesLine."VAT Prod. Posting Group" <> TempSalesShipmentLine."VAT Prod. Posting Group" then
            SalesLine.Validate("VAT Prod. Posting Group", TempSalesShipmentLine."VAT Prod. Posting Group");
        if TempLineBuffer.Title <> '' then
            SalesLine.Description := CopyStr(TempLineBuffer.Title, 1, MaxStrLen(SalesLine.Description));
        SetQuantityAndAmounts(TempLineBuffer, SalesLine);
        AssignChargeToShipments(SalesLine, ReturnName, TempLineBuffer."Order Line Item Id", TempSalesShipmentLine);
    end;

    local procedure CollectShipmentLines(ShopifyStoreCode: Code[20]; OrderLineItemId: Text[30]; var TempSalesShipmentLine: Record "Sales Shipment Line" temporary): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        RecRef: RecordRef;
    begin
        TempSalesShipmentLine.Reset();
        TempSalesShipmentLine.DeleteAll();
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Shipment Line", "NPR Spfy ID Type"::"Entry ID", OrderLineItemId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesShipmentLine);
                    // An undone shipment keeps its line, marked Correction; the charge belongs on the shipment that replaced it.
                    if (SalesShipmentLine.Type = SalesShipmentLine.Type::Item) and (SalesShipmentLine.Quantity > 0) and not SalesShipmentLine.Correction then
                        if SalesShipmentHeader.Get(SalesShipmentLine."Document No.") then
                            if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesShipmentHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then begin
                                TempSalesShipmentLine := SalesShipmentLine;
                                if TempSalesShipmentLine.Insert() then;
                            end;
                end;
            until ShopifyAssignedID.Next() = 0;
        exit(not TempSalesShipmentLine.IsEmpty());
    end;

    local procedure AssignChargeToShipments(SalesLine: Record "Sales Line"; ReturnName: Text[50]; OrderLineItemId: Text[30]; var TempSalesShipmentLine: Record "Sales Shipment Line" temporary)
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        ToAssign: Decimal;
        QtyOnLine: Decimal;
        AssignmentLineNo: Integer;
    begin
        ToAssign := SalesLine.Quantity;
        TempSalesShipmentLine.FindSet();
        repeat
            QtyOnLine := TempSalesShipmentLine.Quantity;
            if QtyOnLine > ToAssign then
                QtyOnLine := ToAssign;
            if QtyOnLine > 0 then begin
                AssignmentLineNo += 10000;
                ItemChargeAssgntSales.Init();
                ItemChargeAssgntSales."Document Type" := SalesLine."Document Type";
                ItemChargeAssgntSales."Document No." := SalesLine."Document No.";
                ItemChargeAssgntSales."Document Line No." := SalesLine."Line No.";
                ItemChargeAssgntSales."Line No." := AssignmentLineNo;
                ItemChargeAssgntSales."Item Charge No." := SalesLine."No.";
                ItemChargeAssgntSales."Item No." := TempSalesShipmentLine."No.";
                ItemChargeAssgntSales.Description := TempSalesShipmentLine.Description;
                ItemChargeAssgntSales."Applies-to Doc. Type" := ItemChargeAssgntSales."Applies-to Doc. Type"::Shipment;
                ItemChargeAssgntSales."Applies-to Doc. No." := TempSalesShipmentLine."Document No.";
                ItemChargeAssgntSales."Applies-to Doc. Line No." := TempSalesShipmentLine."Line No.";
                ItemChargeAssgntSales.Insert();
                ItemChargeAssgntSales.Validate("Qty. to Assign", QtyOnLine);
                if ItemChargeAssgntSales."Qty. to Handle" <> QtyOnLine then
                    ItemChargeAssgntSales.Validate("Qty. to Handle", QtyOnLine);
                ItemChargeAssgntSales.Modify();
                ToAssign -= QtyOnLine;
            end;
        until (TempSalesShipmentLine.Next() = 0) or (ToAssign <= 0);
        if ToAssign > 0 then
            Error(_ShipmentNotFoundErr, TempSalesShipmentLine.TableCaption(), OrderLineItemId, ReturnName);
        // The platform's own amounts per assignment (net of VAT and line discount), as posting recalculates them anyway.
        SalesLine.UpdateItemChargeAssgnt();
    end;

    local procedure InitSalesLine(SalesHeader: Record "Sales Header"; LineNo: Integer; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
    end;

    /// <summary>
    /// Collects every posted G/L invoice line of the store that carries the Shopify line item: one line can be invoiced in parts.
    /// </summary>
    local procedure FindPostedGiftCardSaleLines(ShopifyStoreCode: Code[20]; OrderLineItemId: Text[30]; var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        RecRef: RecordRef;
    begin
        TempSalesInvoiceLine.Reset();
        TempSalesInvoiceLine.DeleteAll();
        if OrderLineItemId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Invoice Line", "NPR Spfy ID Type"::"Entry ID", OrderLineItemId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesInvoiceLine);
                    if SalesInvoiceLine.Type = SalesInvoiceLine.Type::"G/L Account" then
                        if SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.") then
                            if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then begin
                                TempSalesInvoiceLine := SalesInvoiceLine;
                                if TempSalesInvoiceLine.Insert() then;
                            end;
                end;
            until ShopifyAssignedID.Next() = 0;
        exit(not TempSalesInvoiceLine.IsEmpty());
    end;

    local procedure InvoiceNos(var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary) Nos: Text
    var
        Seen: List of [Code[20]];
    begin
        TempSalesInvoiceLine.FindSet();
        repeat
            if not Seen.Contains(TempSalesInvoiceLine."Document No.") then begin
                Seen.Add(TempSalesInvoiceLine."Document No.");
                if Nos <> '' then
                    Nos += ', ';
                Nos += TempSalesInvoiceLine."Document No.";
            end;
        until TempSalesInvoiceLine.Next() = 0;
    end;

    /// <summary>
    /// Collects up to MaxCount untouched vouchers of the invoice lines that no open document claims; used, topped-up or revoked cards are skipped.
    /// </summary>
    local procedure CollectUnusedVouchers(var TempSalesInvoiceLine: Record "Sales Invoice Line" temporary; MaxCount: Decimal; var TempVoucher: Record "NPR NpRv Voucher" temporary) Collected: Integer
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
    begin
        TempSalesInvoiceLine.FindSet();
        repeat
            VoucherEntry.Reset();
            VoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.", "Document Line No.");
            VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
            VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
            VoucherEntry.SetRange("Document No.", TempSalesInvoiceLine."Document No.");
            VoucherEntry.SetRange("Document Line No.", TempSalesInvoiceLine."Line No.");
            if VoucherEntry.FindSet() then
                repeat
                    if Collected < MaxCount then
                        if Voucher.Get(VoucherEntry."Voucher No.") then
                            if IsUnusedVoucher(Voucher) then
                                if not IsClaimedByOpenDocument(Voucher."No.") then begin
                                    TempVoucher := Voucher;
                                    TempVoucher.Insert();
                                    Collected += 1;
                                end;
                until VoucherEntry.Next() = 0;
        until TempSalesInvoiceLine.Next() = 0;
    end;

    /// <summary>
    /// A card referenced by an unposted voucher sales line is claimed by an open draft; posting deletes those lines, so a posted return never claims.
    /// </summary>
    local procedure IsClaimedByOpenDocument(VoucherNo: Code[20]): Boolean
    var
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLineRef.SetRange("Voucher No.", VoucherNo);
        NpRvSalesLineRef.SetRange(Posted, false);
        if not NpRvSalesLineRef.FindSet() then
            exit(false);
        repeat
            if NpRvSalesLine.Get(NpRvSalesLineRef."Sales Line Id") then
                if not NpRvSalesLine.Posted then
                    exit(true);
        until NpRvSalesLineRef.Next() = 0;
        exit(false);
    end;

    local procedure IsUnusedVoucher(Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        // A card in use as a payment, reserved by amount or by a global reservation, is spoken for and is left alone.
        Voucher.CalcFields("Reserved Amount", "In-use Quantity");
        if (Voucher."Reserved Amount" <> 0) or (Voucher."In-use Quantity" <> 0) then
            exit(false);
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        if VoucherEntry.Count() <> 1 then
            exit(false);
        VoucherEntry.FindFirst();
        if VoucherEntry."Entry Type" <> VoucherEntry."Entry Type"::"Issue Voucher" then
            exit(false);
        exit(VoucherEntry.Open and (VoucherEntry.Amount > 0) and (VoucherEntry."Remaining Amount" = VoucherEntry.Amount));
    end;

    /// <summary>
    /// Attaches the voucher module's reversal shape: a voucher sales line with one reference per card, posted as a corrective entry on each voucher.
    /// </summary>
    local procedure AttachVouchersToRevoke(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        TempVoucher.Reset();
        TempVoucher.FindSet();
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
        NpRvSalesLine."External Document No." := SalesHeader."External Document No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := TempVoucher."Voucher Type";
        NpRvSalesLine.Description := CopyStr(SalesLine.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        if TempVoucher.Count() = 1 then begin
            NpRvSalesLine."Voucher No." := TempVoucher."No.";
            NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        end;
        NpRvSalesLine.Insert(true);
        repeat
            Voucher := TempVoucher;
            NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, Voucher);
        until TempVoucher.Next() = 0;
    end;

    local procedure UsesGenericItem(ShopifyStore: Record "NPR Spfy Store"; Sku: Text[100]): Boolean
    begin
        if (ShopifyStore."Return Generic SKU Prefix" = '') or (ShopifyStore."Return Generic Item No." = '') or (Sku = '') then
            exit(false);
        exit(UpperCase(CopyStr(Sku, 1, StrLen(ShopifyStore."Return Generic SKU Prefix"))) = UpperCase(ShopifyStore."Return Generic SKU Prefix"));
    end;

    local procedure CreateGLLine(SalesHeader: Record "Sales Header"; GLAccountNo: Code[20]; Amount: Decimal; Description: Text)
    var
        SalesLine: Record "Sales Line";
    begin
        CreateGLLine(SalesHeader, GLAccountNo, '', Amount, Description, SalesLine);
    end;

    /// <summary>
    /// A VATProdPostingGroup replaces the account's own VAT group.
    /// </summary>
    local procedure CreateGLLine(SalesHeader: Record "Sales Header"; GLAccountNo: Code[20]; VATProdPostingGroup: Code[20]; Amount: Decimal; Description: Text; var SalesLine: Record "Sales Line")
    var
        LineNo: Integer;
    begin
        if (GLAccountNo = '') or (Amount = 0) then
            exit;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No.";
        LineNo += 10000;
        InitSalesLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        if (VATProdPostingGroup <> '') and (SalesLine."VAT Prod. Posting Group" <> VATProdPostingGroup) then
            SalesLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        SalesLine.Description := CopyStr(Description, 1, MaxStrLen(SalesLine.Description));
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", Amount);
        SalesLine.Modify(true);
    end;

    /// <summary>
    /// Credits what the refund leaves unexplained as discounts given after the sale that BC still owes, each with the VAT of the line it reduces.
    /// The rest is refused: BC may have invoiced the reduced price and never received it.
    /// </summary>
    local procedure BookUnexplainedRefund(SalesHeader: Record "Sales Header"; ShopifyStore: Record "NPR Spfy Store"; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; OrderToken: JsonToken; DisplayName: Text[50]; ExpectedTotal: Decimal)
    var
        TempInvoicedLine: Record "Sales Invoice Line" temporary;
        SalesLine: Record "Sales Line";
        Unexplained: Decimal;
        Remaining: Decimal;
        Discount: Decimal;
        RoundingPrecision: Decimal;
        DiscountLines: Integer;
        PostSaleDiscountLbl: Label 'Discount after the sale: %1', Comment = '%1 = description of the invoiced line the discount reduces';
        UnexplainedRefundErr: Label 'Shopify %1 refunds %2 that its lines, shipping and adjustments do not explain, and only %3 of it is a discount given after the sale that Business Central invoiced and has not credited yet. If Business Central invoiced order %4 at the reduced price, it never received the rest and has nothing to credit for it; check the order''s invoices and handle this manually.', Comment = '%1 = Shopify document caption, %2 = unexplained amount, %3 = part of it that is a discount given after the sale, %4 = Shopify order name';
    begin
        Unexplained := ExpectedTotal - DocumentTotal(SalesHeader);
        if Unexplained <= 0 then
            exit;
        RoundingPrecision := _SpfyLegacyReturnAPI.AmountRoundingPrecision(ShopifyStore.Code, TempReturnBuffer."Presentment Currency Code");
        CollectInvoicedLineItems(ShopifyStore.Code, TempReturnBuffer."Order Id", TempInvoicedLine);
        Remaining := Unexplained;
        if TempInvoicedLine.FindSet() then
            repeat
                Discount := SmallerOf(Remaining, DiscountStillOwed(ShopifyStore.Code, TempReturnBuffer."Return Id", OrderToken, TempInvoicedLine, RoundingPrecision));
                if Discount > 0 then begin
                    TempInvoicedLine."Line Discount Amount" := Discount;
                    TempInvoicedLine.Modify();
                    Remaining -= Discount;
                    DiscountLines += 1;
                end;
            until (TempInvoicedLine.Next() = 0) or (Remaining <= 0);
        TempInvoicedLine.SetFilter("Line Discount Amount", '>0');
        // Shopify allocates a discount per unit and the order import spreads it over the units, so the two can part by a rounding unit a line.
        if (Remaining > 0) and (Remaining <= RoundingPrecision * DiscountLines) then begin
            TempInvoicedLine.FindLast();
            TempInvoicedLine."Line Discount Amount" += Remaining;
            TempInvoicedLine.Modify();
            Remaining := 0;
        end;
        if Remaining > 0 then
            Error(UnexplainedRefundErr, DisplayName, Unexplained, Unexplained - Remaining, TempReturnBuffer."Order Name");
        if ShopifyStore."Refund Discrepancy G/L Acc." = '' then
            Error(_DiscrepancyAccountMissingErr, Unexplained, DisplayName, ShopifyStore.FieldCaption("Refund Discrepancy G/L Acc."), ShopifyStore.TableCaption());
        TempInvoicedLine.FindSet();
        repeat
            Clear(SalesLine);
            CreateGLLine(SalesHeader, ShopifyStore."Refund Discrepancy G/L Acc.", TempInvoicedLine."VAT Prod. Posting Group", TempInvoicedLine."Line Discount Amount", StrSubstNo(PostSaleDiscountLbl, TempInvoicedLine.Description), SalesLine);
            // Lets a later refund of the same order line see that this discount is credited.
            _SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID", CopyStr(TempInvoicedLine."Description 2", 1, 30), false);
        until TempInvoicedLine.Next() = 0;
    end;

    /// <summary>
    /// One row per Shopify line item over the order's invoices of this store, with the line item id in Description 2, the invoiced quantity and gross amount summed, and the first line's description and VAT group.
    /// </summary>
    local procedure CollectInvoicedLineItems(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var TempInvoicedLine: Record "Sales Invoice Line" temporary)
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        SalesInvoiceLine: Record "Sales Invoice Line";
        LineItemId: Text[30];
        LineNo: Integer;
    begin
        TempInvoicedLine.Reset();
        TempInvoicedLine.DeleteAll();
        if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit;
        TempSalesInvoiceHeader.FindSet();
        repeat
            SalesInvoiceLine.SetRange("Document No.", TempSalesInvoiceHeader."No.");
            if SalesInvoiceLine.FindSet() then
                repeat
                    LineItemId := _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvoiceLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    if LineItemId <> '' then begin
                        TempInvoicedLine.SetRange("Description 2", LineItemId);
                        if TempInvoicedLine.FindFirst() then begin
                            TempInvoicedLine.Quantity += SalesInvoiceLine.Quantity;
                            TempInvoicedLine."Amount Including VAT" += SalesInvoiceLine."Amount Including VAT";
                            TempInvoicedLine.Modify();
                        end else begin
                            LineNo += 1;
                            TempInvoicedLine.Init();
                            TempInvoicedLine."Line No." := LineNo;
                            TempInvoicedLine."Description 2" := LineItemId;
                            TempInvoicedLine.Description := SalesInvoiceLine.Description;
                            TempInvoicedLine."VAT Prod. Posting Group" := SalesInvoiceLine."VAT Prod. Posting Group";
                            TempInvoicedLine.Quantity := SalesInvoiceLine.Quantity;
                            TempInvoicedLine."Amount Including VAT" := SalesInvoiceLine."Amount Including VAT";
                            TempInvoicedLine.Insert();
                        end;
                        TempInvoicedLine.SetRange("Description 2");
                    end;
                until SalesInvoiceLine.Next() = 0;
        until TempSalesInvoiceHeader.Next() = 0;
    end;

    /// <summary>
    /// The discount given after the sale on one order line that BC still owes: what BC invoiced for it, minus what Shopify charges now for the same units, minus what documents of the store already credit as its discount.
    /// </summary>
    local procedure DiscountStillOwed(ShopifyStoreCode: Code[20]; DocId: Text[30]; OrderToken: JsonToken; TempInvoicedLine: Record "Sales Invoice Line" temporary; RoundingPrecision: Decimal) Owed: Decimal
    var
        CurrentGross: Decimal;
    begin
        if TempInvoicedLine.Quantity <= 0 then
            exit(0);
        if not _SpfyLegacyReturnAPI.CurrentOrderLineGross(DocId, OrderToken, TempInvoicedLine."Description 2", TempInvoicedLine.Quantity, RoundingPrecision, CurrentGross) then
            exit(0);
        Owed := TempInvoicedLine."Amount Including VAT" - CurrentGross - DiscountAlreadyCredited(ShopifyStoreCode, CopyStr(TempInvoicedLine."Description 2", 1, 30));
        if Owed < 0 then
            Owed := 0;
    end;

    /// <summary>
    /// What posted credit memos and open documents of the store credit as a discount given after the sale on the order line.
    /// </summary>
    local procedure DiscountAlreadyCredited(ShopifyStoreCode: Code[20]; LineItemId: Text[30]) Credited: Decimal
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RecRef: RecordRef;
    begin
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Cr.Memo Line", "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID", LineItemId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesCrMemoLine);
                    if SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.") then
                        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                            Credited += SalesCrMemoLine."Amount Including VAT";
                end;
            until ShopifyAssignedID.Next() = 0;
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Line", "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID", LineItemId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesLine);
                    if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
                        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code") = ShopifyStoreCode then
                            Credited += SalesLine."Amount Including VAT";
                end;
            until ShopifyAssignedID.Next() = 0;
    end;

    local procedure DocumentTotal(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.CalcSums("Amount Including VAT");
        exit(SalesLine."Amount Including VAT");
    end;

    internal procedure VerifyDocumentCoversRefund(SalesHeader: Record "Sales Header"; ShopifyStore: Record "NPR Spfy Store"; DisplayName: Text[50]; TotalRefund: Decimal)
    var
        TotalDocument: Decimal;
        NoRefundFoundErr: Label 'Shopify %1 carries no completed refund, so a credit memo of %2 cannot be justified. For a return, the refund may sit on the order instead.', Comment = '%1 = Shopify document caption, %2 = document total';
        RefundTotalOverErr: Label 'The document total %1 for Shopify %2 exceeds the %3 Shopify refunded by %4. Crediting more than was refunded would leave the difference open on the customer account; a withheld fee is probably not accounted for.', Comment = '%1 = document total, %2 = Shopify document caption, %3 = refund total, %4 = difference';
    begin
        TotalDocument := DocumentTotal(SalesHeader);
        if TotalRefund = 0 then
            Error(NoRefundFoundErr, DisplayName, TotalDocument);
        // Exact: an over-credit would be settled as a payout, and the posting guard tolerates only invoice rounding.
        VerifyDocumentNotShort(SalesHeader, DisplayName, TotalRefund);
        if TotalDocument > TotalRefund then
            Error(RefundTotalOverErr, TotalDocument, DisplayName, TotalRefund, TotalDocument - TotalRefund);
    end;

    /// <summary>
    /// A document below what Shopify refunded would settle less than was paid out and give a gift card back less than Shopify put on it.
    /// </summary>
    internal procedure VerifyDocumentNotShort(SalesHeader: Record "Sales Header"; DisplayName: Text[50]; TotalRefund: Decimal)
    var
        TotalDocument: Decimal;
        RefundTotalShortErr: Label 'The document total %1 for Shopify %2 is below the %3 Shopify refunded, short by %4. The document was changed after it was built; discard the draft and retry, or handle it manually.', Comment = '%1 = document total, %2 = Shopify document caption, %3 = refund total, %4 = difference';
    begin
        TotalDocument := DocumentTotal(SalesHeader);
        if TotalDocument < TotalRefund then
            Error(RefundTotalShortErr, TotalDocument, DisplayName, TotalRefund, TotalRefund - TotalDocument);
    end;

    internal procedure RefundTotal(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary): Decimal
    begin
        TempRefundTxnBuffer.Reset();
        TempRefundTxnBuffer.CalcSums(Amount);
        exit(TempRefundTxnBuffer.Amount);
    end;

    /// <summary>
    /// An order invoice still open was not paid in full; the credit memo settles what is open instead of paying money out.
    /// </summary>
    local procedure ApplyToOpenInvoice(ShopifyStoreCode: Code[20]; OrderId: Text[30]; DisplayName: Text[50]; ExpectedTotal: Decimal; var SalesHeader: Record "Sales Header") AppliedAmount: Decimal
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        OpenInvoiceNo: Code[20];
        OpenInvoiceNos: Text;
        OpenAmount: Decimal;
        OpenCount: Integer;
        SeveralOpenInvoicesErr: Label 'Shopify %1 refunds an order with more than one unpaid %2 (%3), and the credit memo can be applied to one only. Handle it manually.', Comment = '%1 = Shopify document caption, %2 = Sales Invoice Header table caption, %3 = invoice numbers';
        OpenInvoiceOtherCustomerErr: Label 'Shopify %1 refunds an order whose unpaid %2 %3 is posted to %4 %5, not to %4 %6 the refund is credited to. Handle it manually.', Comment = '%1 = Shopify document caption, %2 = Sales Invoice Header table caption, %3 = invoice no., %4 = Customer table caption, %5 = customer no. of the invoice, %6 = Bill-to Customer No. of the Return Order';
    begin
        if ExpectedTotal <= 0 then
            exit(0);
        if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit(0);
        TempSalesInvoiceHeader.FindSet();
        repeat
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SetRange("Document No.", TempSalesInvoiceHeader."No.");
            CustLedgerEntry.SetRange(Open, true);
            if CustLedgerEntry.FindFirst() then begin
                // The credit memo can only be applied to its own customer's invoice; paying out instead would leave the invoice open.
                if CustLedgerEntry."Customer No." <> SalesHeader."Bill-to Customer No." then
                    Error(OpenInvoiceOtherCustomerErr, DisplayName, TempSalesInvoiceHeader.TableCaption(), TempSalesInvoiceHeader."No.", Customer.TableCaption(), CustLedgerEntry."Customer No.", SalesHeader."Bill-to Customer No.");
                CustLedgerEntry.CalcFields("Remaining Amount");
                OpenCount += 1;
                OpenInvoiceNo := TempSalesInvoiceHeader."No.";
                OpenAmount := CustLedgerEntry."Remaining Amount";
                if OpenInvoiceNos <> '' then
                    OpenInvoiceNos += ', ';
                OpenInvoiceNos += TempSalesInvoiceHeader."No.";
            end;
        until TempSalesInvoiceHeader.Next() = 0;
        if OpenCount = 0 then
            exit(0);
        if OpenCount > 1 then
            Error(SeveralOpenInvoicesErr, DisplayName, TempSalesInvoiceHeader.TableCaption(), OpenInvoiceNos);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Invoice);
        SalesHeader.Validate("Applies-to Doc. No.", OpenInvoiceNo);
        SalesHeader.Modify(true);
        AppliedAmount := OpenAmount;
        if AppliedAmount > ExpectedTotal then
            AppliedAmount := ExpectedTotal;
    end;

    /// <summary>
    /// True while another unposted Return Order or Credit Memo is applied to an unpaid invoice of the order: BC applies a credit memo's whole amount at posting.
    /// LockEntries locks the order's posted invoice headers, which Sales-Post of a credit memo does not write, so concurrent builds of the order run one after the other.
    /// </summary>
    internal procedure OtherDraftSettlesOrderInvoice(ShopifyStoreCode: Code[20]; OrderId: Text[30]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; DisplayName: Text[50]; LockEntries: Boolean; var WaitingMessage: Text): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OtherSalesHeader: Record "Sales Header";
        InvoiceNo: Code[20];
        WaitingForOtherDraftMsg: Label 'Waiting until %1 %2, which settles the unpaid %3 %4 of the same Shopify order, is posted or deleted; Shopify %5 is imported then.', Comment = '%1 = document type (Return Order or Credit Memo), %2 = document no., %3 = Sales Invoice Header table caption, %4 = invoice no., %5 = Shopify document caption';
    begin
        if not FindOtherDraftSettlingOrderInvoice(ShopifyStoreCode, OrderId, SourceDocType, ShopifyId, LockEntries, OtherSalesHeader, InvoiceNo) then
            exit(false);
        WaitingMessage := StrSubstNo(WaitingForOtherDraftMsg, OtherSalesHeader."Document Type", OtherSalesHeader."No.", SalesInvoiceHeader.TableCaption(), InvoiceNo, DisplayName);
        exit(true);
    end;

    local procedure FindOtherDraftSettlingOrderInvoice(ShopifyStoreCode: Code[20]; OrderId: Text[30]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; LockEntries: Boolean; var OtherSalesHeader: Record "Sales Header"; var InvoiceNo: Code[20]): Boolean
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit(false);
        TempSalesInvoiceHeader.FindSet();
        repeat
            if LockEntries then begin
                SalesInvoiceHeader.ReadIsolation := IsolationLevel::UpdLock;
                SalesInvoiceHeader.Get(TempSalesInvoiceHeader."No.");
            end;
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SetRange("Document No.", TempSalesInvoiceHeader."No.");
            CustLedgerEntry.SetRange(Open, true);
            if CustLedgerEntry.FindFirst() then begin
                OtherSalesHeader.SetFilter("Document Type", '%1|%2', OtherSalesHeader."Document Type"::"Return Order", OtherSalesHeader."Document Type"::"Credit Memo");
                OtherSalesHeader.SetRange("Applies-to Doc. Type", OtherSalesHeader."Applies-to Doc. Type"::Invoice);
                OtherSalesHeader.SetRange("Applies-to Doc. No.", TempSalesInvoiceHeader."No.");
                if OtherSalesHeader.FindSet() then
                    repeat
                        if _SpfyAssignedIDMgt.GetAssignedShopifyID(OtherSalesHeader.RecordId(), _SpfyLegacyReturnMgt.SourceDocIdType(SourceDocType)) <> ShopifyId then begin
                            InvoiceNo := TempSalesInvoiceHeader."No.";
                            exit(true);
                        end;
                    until OtherSalesHeader.Next() = 0;
            end;
        until TempSalesInvoiceHeader.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// The document a row's note names, found by the same checks as the import: for a waiting row a Sales Order with something left to post or another draft settling the order's unpaid invoice;
    /// for a waiting row or one with nothing to credit, a Sales Order with nothing to post while the order has no invoice. False when the note names no document here, as when the row waits on Shopify.
    /// </summary>
    internal procedure FindDocumentNamedInNote(ShopifyStoreCode: Code[20]; OrderId: Text[30]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; RowWaits: Boolean; var SalesHeader: Record "Sales Header"): Boolean
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        InvoiceNo: Code[20];
    begin
        if RowWaits then begin
            if SourceDocType = SourceDocType::Refund then
                if FindSalesOrder(ShopifyStoreCode, OrderId, true, SalesHeader) then
                    exit(true);
            if FindOtherDraftSettlingOrderInvoice(ShopifyStoreCode, OrderId, SourceDocType, ShopifyId, false, SalesHeader, InvoiceNo) then
                exit(true);
        end;
        if SourceDocType = SourceDocType::Refund then
            if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
                exit(FindSalesOrder(ShopifyStoreCode, OrderId, false, SalesHeader));
        exit(false);
    end;

    /// <summary>
    /// A draft that settles part of an invoice pays out less than its total, so the invoice must still have that much open when it posts; otherwise it is refused before posting.
    /// </summary>
    internal procedure CheckAppliedInvoiceStillOpen(SalesHeader: Record "Sales Header"; DisplayName: Text[50]; AppliedAmount: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        AppliedInvoiceSettledErr: Label '%1 %2 of Shopify %3 is applied to %4 %5, which no longer has the %6 open that the draft settles on it, so posting it would not settle what it was built for. Discard the draft and retry.', Comment = '%1 = Sales Header table caption, %2 = Return Order no., %3 = Shopify document caption, %4 = Sales Invoice Header table caption, %5 = invoice no., %6 = applied amount';
    begin
        if AppliedAmount <= 0 then
            exit;
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesHeader."Applies-to Doc. No.");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.FindFirst() then begin
            CustLedgerEntry.CalcFields("Remaining Amount");
            if CustLedgerEntry."Remaining Amount" >= AppliedAmount then
                exit;
        end;
        Error(AppliedInvoiceSettledErr, SalesHeader.TableCaption(), SalesHeader."No.", DisplayName, SalesInvoiceHeader.TableCaption(), SalesHeader."Applies-to Doc. No.", AppliedAmount);
    end;

    /// <summary>
    /// One payment line per refund transaction that pays anything out; what is not paid out comes off the card refunds, never off a gift card or store credit share.
    /// </summary>
    local procedure InsertPaymentLines(SalesHeader: Record "Sales Header"; ShopifyStoreCode: Code[20]; ReturnId: Text[30]; DisplayName: Text[50]; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; Deduction: Decimal; AllowAdjust: Boolean)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        Amounts: Dictionary of [Integer, Decimal];
        Amount: Decimal;
        Remaining: Decimal;
        IsLiability: Boolean;
        LineNo: Integer;
        DeductionReachesGiftCardErr: Label 'Shopify %1 refunds %2 that is not paid out, because Business Central never received it or it settles an open invoice, but only gift card or store credit refunds are left to take it from. Handle this refund manually.', Comment = '%1 = Shopify document caption, %2 = amount';
    begin
        TempRefundTxnBuffer.Reset();
        if not TempRefundTxnBuffer.FindSet() then
            exit;
        Remaining := Deduction;
        repeat
            Amount := TempRefundTxnBuffer.Amount;
            IsLiability := _SpfyLegacyReturnMgt.IsStoreCreditRefundTxn(TempRefundTxnBuffer);
            if not IsLiability then
                IsLiability := _SpfyLegacyReturnMgt.IsGiftCardRefundTxn(TempRefundTxnBuffer);
            if (not IsLiability) and (Remaining > 0) then
                if Remaining >= Amount then begin
                    Remaining -= Amount;
                    Amount := 0;
                end else begin
                    Amount -= Remaining;
                    Remaining := 0;
                end;
            Amounts.Add(TempRefundTxnBuffer."Line No.", Amount);
        until TempRefundTxnBuffer.Next() = 0;
        if Remaining > 0 then
            Error(DeductionReachesGiftCardErr, DisplayName, Remaining);
        TempRefundTxnBuffer.FindSet();
        repeat
            Amount := Amounts.Get(TempRefundTxnBuffer."Line No.");
            if Amount <> 0 then begin
                LineNo += 10000;
                PaymentLine.Init();
                PaymentLine."Document Table No." := Database::"Sales Header";
                PaymentLine."Document Type" := SalesHeader."Document Type";
                PaymentLine."Document No." := SalesHeader."No.";
                PaymentLine."Line No." := LineNo;
                PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
                PaymentLine.Description := CopyStr(TempRefundTxnBuffer.Gateway + ' ' + ReturnId, 1, MaxStrLen(PaymentLine.Description));
                PaymentLine.Amount := Amount;
                PaymentLine."Requested Amount" := Amount;
                PaymentLine."Amount (Store Currency)" := StoreCurrencyShare(TempRefundTxnBuffer, Amount);
                PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine."Amount (Store Currency)";
                PaymentLine."Store Currency Code" := TempRefundTxnBuffer."Store Currency Code";
                PaymentLine."Posting Date" := SalesHeader."Posting Date";
                PaymentLine."External Payment Type" := TempRefundTxnBuffer.Kind;
                PaymentLine."External Payment Method Code" := TempRefundTxnBuffer.Gateway;
                PaymentLine."External Payment Gateway" := CopyStr(TempRefundTxnBuffer.Gateway, 1, MaxStrLen(PaymentLine."External Payment Gateway"));
                PaymentLine."External Reference No." := CopyStr(TempRefundTxnBuffer."Transaction Id", 1, MaxStrLen(PaymentLine."External Reference No."));
                PaymentLine."Transaction ID" := TempRefundTxnBuffer."Transaction Id";
                PaymentLine."Payment Gateway Code" := SpfyCapturePayment.ShopifyPaymentGateway(TempRefundTxnBuffer."Store Currency Code");
                PaymentLine."Date Refunded" := RefundDate(TempRefundTxnBuffer."Processed At", TempRefundTxnBuffer."Created At", SalesHeader."Posting Date");
                // Invoice rounding can lift the credit memo above the refund; the mapping's flag lets the posting accept it, as on the order import.
                if SpfyCapturePayment.FindPaymentMapping(TempRefundTxnBuffer.Gateway, TempRefundTxnBuffer."Credit Card Company", ShopifyStoreCode, PaymentMapping) then
                    PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
                // Part of the credit memo settles an open invoice, so the lines pay out less than the document; the posting subscriber checks the rest.
                if AllowAdjust then
                    PaymentLine."Allow Adjust Amount" := true;
                PaymentLine.Insert(true);
                _SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TempRefundTxnBuffer."Transaction Id", false);
            end;
        until TempRefundTxnBuffer.Next() = 0;
    end;

    local procedure StoreCurrencyShare(var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; Amount: Decimal): Decimal
    begin
        if (Amount = TempRefundTxnBuffer.Amount) or (TempRefundTxnBuffer.Amount = 0) then
            exit(TempRefundTxnBuffer."Amount (Store Currency)");
        exit(Round(TempRefundTxnBuffer."Amount (Store Currency)" * Amount / TempRefundTxnBuffer.Amount, 0.01));
    end;

    internal procedure StampRefundDateOnPaymentLines(SalesHeader: Record "Sales Header"; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        TransactionId: Text[30];
        ProcessedAt: DateTime;
        CreatedAt: DateTime;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if not PaymentLine.FindSet(true) then
            exit;
        repeat
            if PaymentLine."Date Refunded" = 0D then begin
                ProcessedAt := 0DT;
                CreatedAt := 0DT;
                TransactionId := _SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                if TransactionId <> '' then begin
                    TempRefundTxnBuffer.Reset();
                    TempRefundTxnBuffer.SetRange("Transaction Id", TransactionId);
                    if TempRefundTxnBuffer.FindFirst() then begin
                        ProcessedAt := TempRefundTxnBuffer."Processed At";
                        CreatedAt := TempRefundTxnBuffer."Created At";
                    end;
                end;
                PaymentLine."Date Refunded" := RefundDate(ProcessedAt, CreatedAt, SalesHeader."Posting Date");
                PaymentLine.Modify(true);
            end;
        until PaymentLine.Next() = 0;
        TempRefundTxnBuffer.Reset();
    end;

    /// <summary>
    /// Refund date for a payment line. Never blank, or posting would ask the payment gateway to refund it again.
    /// </summary>
    local procedure RefundDate(ProcessedAt: DateTime; CreatedAt: DateTime; PostingDate: Date): Date
    begin
        if ProcessedAt <> 0DT then
            exit(DT2Date(ProcessedAt));
        if CreatedAt <> 0DT then
            exit(DT2Date(CreatedAt));
        exit(PostingDate);
    end;

    /// <summary>
    /// The voucher behind the refunded card. Ambiguous when the card is not named and the order was paid with more than one voucher.
    /// </summary>
    local procedure ResolveVoucherNo(ShopifyStoreCode: Code[20]; OrderId: Text[30]; GiftCardId: Text[30]; var Ambiguous: Boolean): Code[20]
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherCount: Integer;
        Found: Boolean;
    begin
        Ambiguous := false;
        // No "or": AL evaluates both operands, and both write the voucher.
        Found := FindVoucherByGiftCardId(GiftCardId, Voucher);
        // A card id BC does not know may be a different card, so the order's voucher is only a guess without one.
        if (not Found) and (GiftCardId = '') then begin
            Found := FindVoucherForShopifyOrder(ShopifyStoreCode, OrderId, Voucher, VoucherCount);
            Ambiguous := VoucherCount > 1;
        end;
        if Found then
            exit(Voucher."No.");
        exit('');
    end;

    local procedure FindVoucherByGiftCardId(GiftCardId: Text[30]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        if GiftCardId = '' then
            exit(false);
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Voucher", "NPR Spfy ID Type"::"Entry ID", GiftCardId, ShopifyAssignedID);
        if ShopifyAssignedID.FindLast() then
            if Voucher.Get(ShopifyAssignedID."BC Record ID") then
                exit(true);
        // A card spent to zero is archived with its Shopify id; the row carries the card's own number and the posting restores it.
        _SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Arch. Voucher", "NPR Spfy ID Type"::"Entry ID", GiftCardId, ShopifyAssignedID);
        if not ShopifyAssignedID.FindLast() then
            exit(false);
        if not ArchVoucher.Get(ShopifyAssignedID."BC Record ID") then
            exit(false);
        Voucher.Init();
        Voucher."No." := ArchVoucher."Arch. No.";
        if Voucher."No." = '' then
            Voucher."No." := ArchVoucher."No.";
        exit(true);
    end;

    local procedure FindVoucherForShopifyOrder(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var Voucher: Record "NPR NpRv Voucher"; var VoucherCount: Integer): Boolean
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        PaymentLine: Record "NPR Magento Payment Line";
        VoucherPaymentLine: Record "NPR Magento Payment Line";
        VoucherKeys: List of [Text];
        VoucherKey: Text;
    begin
        VoucherCount := 0;
        if not CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit(false);
        // Exactly one voucher across the order's invoices, or none: never guess between cards. Partial invoicing keeps the payment lines on one invoice.
        // Count vouchers, not lines: a card charged in two transactions has a payment line for each.
        TempSalesInvoiceHeader.FindSet();
        repeat
            PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
            PaymentLine.SetRange("Document Type", Enum::"Sales Document Type".FromInteger(0));
            PaymentLine.SetRange("Document No.", TempSalesInvoiceHeader."No.");
            PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
            if PaymentLine.FindSet() then
                repeat
                    if PaymentLine."Source No." <> '' then
                        VoucherKey := 'S:' + PaymentLine."Source No."
                    else
                        VoucherKey := 'R:' + PaymentLine."No.";
                    if not VoucherKeys.Contains(VoucherKey) then
                        VoucherKeys.Add(VoucherKey);
                    VoucherPaymentLine := PaymentLine;
                until PaymentLine.Next() = 0;
        until TempSalesInvoiceHeader.Next() = 0;
        VoucherCount := VoucherKeys.Count();
        if VoucherCount <> 1 then
            exit(false);
        if VoucherPaymentLine."Source No." <> '' then
            if Voucher.Get(VoucherPaymentLine."Source No.") then
                exit(true);
        if VoucherPaymentLine."No." = '' then
            exit(false);
        Voucher.Reset();
        Voucher.SetRange("Reference No.", VoucherPaymentLine."No.");
        exit(Voucher.FindFirst());
    end;

    /// <summary>
    /// A return is posted in full whatever "Default Quantity to Ship" says: with Blank the platform leaves the quantities to post at zero.
    /// </summary>
    internal procedure SetQuantitiesToPost(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>0');
        if not SalesLine.FindSet(true) then
            exit;
        repeat
            SetLineQuantitiesToPost(SalesLine);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;
    end;

    local procedure SetLineQuantitiesToPost(var SalesLine: Record "Sales Line")
    begin
        if SalesLine."Return Qty. to Receive" <> SalesLine.Quantity then
            SalesLine.Validate("Return Qty. to Receive", SalesLine.Quantity);
        if SalesLine."Qty. to Invoice" <> SalesLine.Quantity then
            SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity);
    end;
}
