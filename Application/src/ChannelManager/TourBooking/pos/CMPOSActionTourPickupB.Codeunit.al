codeunit 6151541 "NPR CMPOSActionTourPickupB"
{
    Access = Internal;

    #region Pick-up
    internal procedure PickupOrder(SearchText: Text; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        Order: Record "NPR CMOrder";
        SalePOS: Record "NPR POS Sale";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        ReceiptNo: Code[20];
        AlreadyPaidMsg: Label 'Booking %1 was already paid on receipt %2. It has now been confirmed.', Comment = '%1 = booking reference, %2 = POS receipt no.';
    begin
        if (not SelectOrder(SearchText, Order)) then
            exit;

        if (not ReviewOrder(Order)) then
            exit;

        if (Order.Status = Order.Status::Issued) then begin
            PrintWallets(Order);
            exit;
        end;

        if (TourBookingMgt.IsFullyPaid(Order, ReceiptNo)) then begin
            TourBookingMgt.ConfirmOrder(Order);
            Message(AlreadyPaidMsg, Order.DocumentNo, ReceiptNo);
            PrintWallets(Order);
            exit;
        end;

        Sale.GetCurrentSale(SalePOS);
        AddOrderToSale(Order, SalePOS, SaleLine);
    end;

    local procedure SelectOrder(SearchText: Text; var Order: Record "NPR CMOrder"): Boolean
    var
        TempOrder: Record "NPR CMOrder" temporary;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        PickupSelect: Page "NPR CMTourBookingPickupSelect";
        LocalToday: Date;
        NoMatchingOrderErr: Label 'There is no booking to pick up that matches ''%1''.', Comment = '%1 = the search text';
        SearchTextRequiredErr: Label 'Enter a booking reference, customer no. or email.';
    begin
        SearchText := DelChr(SearchText, '<>', ' ');
        if (SearchText = '') then
            Error(SearchTextRequiredErr);

        Order.SetCurrentKey(Status, ReceivedAt);
        Order.SetFilter(Status, '=%1|=%2', Order.Status::Draft, Order.Status::Issued);

        if (not SetSearchFilter(Order, SearchText)) then
            Error(NoMatchingOrderErr, SearchText);

        LocalToday := DT2Date(TimeHelper.GetLocalTimeAtAdmission(''));
        if (Order.FindSet()) then
            repeat
                if (IsPickupCandidate(Order, LocalToday)) then begin
                    TempOrder := Order;
                    TempOrder.Insert();
                end;
            until (Order.Next() = 0);

        case TempOrder.Count() of
            0:
                Error(NoMatchingOrderErr, SearchText);
            1:
                TempOrder.FindFirst();
            else begin
                PickupSelect.SetOrders(TempOrder);
                PickupSelect.LookupMode(true);
                if (PickupSelect.RunModal() <> Action::LookupOK) then
                    exit(false);
                PickupSelect.GetRecord(TempOrder);
            end;
        end;

        Order.Reset();
        exit(Order.Get(TempOrder.OrderId));
    end;

    local procedure IsPickupCandidate(var Order: Record "NPR CMOrder"; LocalToday: Date): Boolean
    begin
        // An API order is paid through its partner, so only a confirmed one can be picked up.
        if ((Order.PartnerType = Order.PartnerType::API) and (Order.Status = Order.Status::Draft)) then
            exit(false);
        if (not HasVisitFrom(Order, LocalToday)) then
            exit(false);
        exit(true);
    end;

    local procedure HasVisitFrom(var Order: Record "NPR CMOrder"; FromDate: Date): Boolean
    var
        OrderLine: Record "NPR CMOrderLine";
        Component: Record "NPR CMOrderComponent";
    begin
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderLine.SetFilter(VisitDate, '>=%1', FromDate);
        if (not OrderLine.IsEmpty()) then
            exit(true);

        Component.SetFilter(OrderId, '=%1', Order.OrderId);
        Component.SetFilter(VisitDate, '>=%1', FromDate);
        if (not Component.IsEmpty()) then
            exit(true);

        exit(false);
    end;

    local procedure SetSearchFilter(var Order: Record "NPR CMOrder"; SearchText: Text) HasFilter: Boolean
    begin
        Order.FilterGroup(-1);
        if (StrLen(SearchText) <= MaxStrLen(Order.DocumentNo)) then begin
            Order.SetFilter(DocumentNo, '=%1', UpperCase(SearchText));
            Order.SetFilter(SellToCustomerNo, '=%1', UpperCase(SearchText));
            HasFilter := true;
        end;
        if (StrLen(SearchText) <= MaxStrLen(Order.SellToOrderReference)) then begin
            Order.SetFilter(SellToOrderReference, '=%1', UpperCase(SearchText));
            HasFilter := true;
        end;
        if (StrLen(SearchText) <= MaxStrLen(Order.SellToEmail)) then begin
            Order.SetFilter(SellToEmail, '=%1', LowerCase(SearchText));
            HasFilter := true;
        end;
        Order.FilterGroup(0);
    end;

    local procedure PrintWallets(var Order: Record "NPR CMOrder")
    var
        OrderWallet: Record "NPR CMOrderWallet";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNos: List of [Integer];
        NoWalletsErr: Label 'Booking %1 has no wallets to print.', Comment = '%1 = booking reference';
    begin
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderWallet.SetFilter(WalletEntryNo, '<>%1', 0);
        OrderWallet.SetLoadFields(WalletEntryNo);
        if (OrderWallet.FindSet()) then
            repeat
                if (not WalletEntryNos.Contains(OrderWallet.WalletEntryNo)) then
                    WalletEntryNos.Add(OrderWallet.WalletEntryNo);
            until (OrderWallet.Next() = 0);

        if (WalletEntryNos.Count() = 0) then
            Error(NoWalletsErr, Order.DocumentNo);

        WalletFacade.PrintWallet(WalletEntryNos, Enum::"NPR WalletPrintType"::WALLET);
    end;

    local procedure ReviewOrder(var Order: Record "NPR CMOrder"): Boolean
    var
        ReviewedOrder: Record "NPR CMOrder";
        PickupReview: Page "NPR CMTourBookingPickupReview";
    begin
        ReviewedOrder.SetFilter(OrderId, '=%1', Order.OrderId);
        PickupReview.SetTableView(ReviewedOrder);
        PickupReview.LookupMode(true);
        exit(PickupReview.RunModal() = Action::LookupOK);
    end;

    local procedure AddOrderToSale(var Order: Record "NPR CMOrder"; SalePOS: Record "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        OrderLine: Record "NPR CMOrderLine";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        ReceiptNo: Code[20];
        NotOpenErr: Label 'Booking %1 is no longer open for pick-up.', Comment = '%1 = booking reference';
        InOtherSaleErr: Label 'Line %1 of booking %2 is already in another POS sale.', Comment = '%1 = line no., %2 = booking reference';
        InParkedSaleErr: Label 'Line %1 of booking %2 is in a parked sale.', Comment = '%1 = line no., %2 = booking reference';
        NothingToAddErr: Label 'All lines of booking %1 are already in this sale.', Comment = '%1 = booking reference';
    begin
        Order.ReadIsolation := IsolationLevel::UpdLock;
        Order.Get(Order.OrderId);
        if ((Order.Status <> Order.Status::Draft) or (Order.PaymentReference <> '')) then
            Error(NotOpenErr, Order.DocumentNo);

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (OrderLine.FindSet()) then
            repeat
                case TourBookingMgt.GetLineState(OrderLine, ReceiptNo) of
                    "NPR CMOrderLinePickupState"::Open:
                        begin
                            TempOrderLine := OrderLine;
                            TempOrderLine.Insert();
                        end;
                    "NPR CMOrderLinePickupState"::InPosSale:
                        if (not IsLineInSale(OrderLine.PosSaleLineId, SalePOS)) then
                            Error(InOtherSaleErr, OrderLine.LineNo, Order.DocumentNo);
                    "NPR CMOrderLinePickupState"::ParkedSale:
                        Error(InParkedSaleErr, OrderLine.LineNo, Order.DocumentNo);
                end;
            until (OrderLine.Next() = 0);

        if (not TempOrderLine.FindSet()) then
            Error(NothingToAddErr, Order.DocumentNo);

        // Every line must be postable before the first one is added, since each insert commits.
        repeat
            ValidatePostingSetup(SalePOS, TempOrderLine.ItemNo);
        until (TempOrderLine.Next() = 0);

        TempOrderLine.FindSet();
        repeat
            AddPickupLine(Order, TempOrderLine, SalePOS, SaleLine);
        until (TempOrderLine.Next() = 0);
    end;

    local procedure IsLineInSale(PosSaleLineId: Guid; SalePOS: Record "NPR POS Sale"): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetFilter(SystemId, '=%1', PosSaleLineId);
        POSSaleLine.SetFilter("Register No.", '=%1', SalePOS."Register No.");
        POSSaleLine.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        exit(not POSSaleLine.IsEmpty());
    end;

    // A G/L line, not an item line: revenue and VAT follow the item's posting groups without running the item line's asset hooks.
    local procedure AddPickupLine(var Order: Record "NPR CMOrder"; var TempOrderLine: Record "NPR CMOrderLine" temporary; SalePOS: Record "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        Item: Record Item;
        Line: Record "NPR POS Sale Line";
        OrderLine: Record "NPR CMOrderLine";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        WalletCount: Integer;
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
        CurrencyCode: Code[10];
        DescriptionLbl: Label '%1 %2', Locked = true;
        NoWalletsErr: Label 'Line %1 of Channel Manager order %2 is in Draft without wallets. This is a programming bug.', Locked = true;
    begin
        TourBookingMgt.GetLineTotals(TempOrderLine, WalletCount, AmountExclVat, AmountInclVat, CurrencyCode);
        if (WalletCount = 0) then
            Error(NoWalletsErr, TempOrderLine.LineNo, Order.DocumentNo);

        Item.SetLoadFields(Description, "Gen. Prod. Posting Group", "VAT Prod. Posting Group", "Tax Group Code");
        Item.Get(TempOrderLine.ItemNo);

        SaleLine.GetNewSaleLine(Line);
        Line."Line Type" := Line."Line Type"::"GL Payment";
        Line.SetSkipPOSInfo(true);
        Line.Validate("No.", GetSalesAccount(SalePOS, Item));

        Line."Gen. Posting Type" := Line."Gen. Posting Type"::Sale;
        Line."Gen. Bus. Posting Group" := SalePOS."Gen. Bus. Posting Group";
        Line."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        Line."VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        Line."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        Line."Tax Group Code" := Item."Tax Group Code";
        Line.UpdateVATSetup();

        Line."Custom Descr" := true;
        Line.Description := CopyStr(StrSubstNo(DescriptionLbl, Order.DocumentNo, Item.Description), 1, MaxStrLen(Line.Description));
        Line.Quantity := WalletCount;
        if (Line."Price Includes VAT") then
            Line."Unit Price" := AmountInclVat / WalletCount
        else
            Line."Unit Price" := AmountExclVat / WalletCount;
        Line.SetSkipCalcDiscount(true);
        Line.SystemId := CreateGuid();

        OrderLine.Get(TempOrderLine.OrderId, TempOrderLine.LineNo);
        OrderLine.PosSaleLineId := Line.SystemId;
        OrderLine.Modify();

        SaleLine.SetUseCustomSystemId(true);
        SaleLine.InsertLineRaw(Line, false);
        SaleLine.SetUseCustomSystemId(false);
    end;

    local procedure ValidatePostingSetup(SalePOS: Record "NPR POS Sale"; ItemNo: Code[20])
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Item.SetLoadFields("Gen. Prod. Posting Group", "VAT Prod. Posting Group");
        Item.Get(ItemNo);
        GetSalesAccount(SalePOS, Item);
        VATPostingSetup.Get(SalePOS."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
    end;

    local procedure GetSalesAccount(SalePOS: Record "NPR POS Sale"; Item: Record Item): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Get(SalePOS."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        exit(GeneralPostingSetup.GetSalesAccount());
    end;
    #endregion

    #region End of sale
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure ConfirmPickedUpOrdersOnAfterEndSale(SalePOS: Record "NPR POS Sale")
    var
        Order: Record "NPR CMOrder";
        Sentry: Codeunit "NPR Sentry";
        OrderIds: List of [Guid];
        OrderId: Guid;
        ConfirmFailedMsg: Label 'Booking %1 was paid, but it could not be confirmed: %2\Confirm it from the booking card.', Comment = '%1 = booking reference, %2 = error text';
        NotFullyPaidMsg: Label 'Booking %1 is not fully paid. Its tickets are activated when all of its lines are paid.', Comment = '%1 = booking reference';
    begin
        if (not FindPickedUpOrders(SalePOS, OrderIds)) then
            exit;

        // Each order confirms in its own transaction, so one failure neither rolls back nor blocks the others.
        Commit();
        foreach OrderId in OrderIds do
            if (Order.Get(OrderId)) then begin
                ClearLastError();
                if (not Codeunit.Run(Codeunit::"NPR CMTourBookingMgt", Order)) then begin
                    Sentry.AddLastErrorIfProgrammingBug();
                    Message(ConfirmFailedMsg, Order.DocumentNo, GetLastErrorText());
                end else begin
                    Order.Get(OrderId);
                    if (Order.Status = Order.Status::Draft) then
                        Message(NotFullyPaidMsg, Order.DocumentNo);
                end;
            end;
    end;

    local procedure FindPickedUpOrders(SalePOS: Record "NPR POS Sale"; var OrderIds: List of [Guid]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        OrderLine: Record "NPR CMOrderLine";
    begin
        POSEntry.SetLoadFields("Entry Type");
        if (not POSEntry.GetBySystemId(SalePOS.SystemId)) then
            exit(false);
        if (POSEntry."Entry Type" <> POSEntry."Entry Type"::"Direct Sale") then
            exit(false);

        POSEntrySalesLine.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '=%1', POSEntrySalesLine.Type::"G/L Account");
        POSEntrySalesLine.SetLoadFields(Type);
        if (not POSEntrySalesLine.FindSet()) then
            exit(false);

        OrderLine.SetCurrentKey(PosSaleLineId);
        OrderLine.SetLoadFields(OrderId);
        repeat
            OrderLine.SetFilter(PosSaleLineId, '=%1', POSEntrySalesLine.SystemId);
            if (OrderLine.FindFirst()) then
                if (not OrderIds.Contains(OrderLine.OrderId)) then
                    OrderIds.Add(OrderLine.OrderId);
        until (POSEntrySalesLine.Next() = 0);

        exit(OrderIds.Count() > 0);
    end;
    #endregion
}
