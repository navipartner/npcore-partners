codeunit 6184545 "NPR CMTourBookingMgt"
{
    Access = Internal;
    TableNo = "NPR CMOrder";

    trigger OnRun()
    begin
        ConfirmOrder(Rec);
    end;

    #region Partner
    internal procedure SelectTourBookingPartner(var PartnerId: Guid): Boolean
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        NoTourBookingPartnerErr: Label 'There is no active Tour Booking partner.';
    begin
        PartnerSetup.SetFilter(PartnerType, '=%1', PartnerSetup.PartnerType::TourBooking);
        PartnerSetup.SetFilter(Active, '=%1', true);
        case PartnerSetup.Count() of
            0:
                Error(NoTourBookingPartnerErr);
            1:
                PartnerSetup.FindFirst();
            else
                if (Page.RunModal(Page::"NPR CMPartnerSetupList", PartnerSetup) <> Action::LookupOK) then
                    exit(false);
        end;

        PartnerId := PartnerSetup.PartnerId;
        exit(true);
    end;

    internal procedure IsMailDistributed(PartnerId: Guid): Boolean
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        PartnerSetup.SetLoadFields(Distribution);
        PartnerSetup.Get(PartnerId);
        exit(PartnerSetup.Distribution = PartnerSetup.Distribution::NPMail);
    end;
    #endregion

    #region Editing
    internal procedure InitNewOrder(var Order: Record "NPR CMOrder"; PartnerId: Guid)
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
    begin
        Order.OrderId := CreateGuid();
        Order.Status := Order.Status::WIP;
        Order.ReceivedAt := CurrentDateTime();
        Order.PartnerId := PartnerId;
        Order.PartnerType := Order.PartnerType::TourBooking;
        Order.DocumentNo := OrderIssuer.GenerateDocumentNo(Order.PartnerId);
        Order.SellToOrderReference := Order.DocumentNo;
        Order.Insert();
    end;

    internal procedure IsEditable(var Order: Record "NPR CMOrder"): Boolean
    begin
        exit(Order.Status in [Order.Status::WIP, Order.Status::Error]);
    end;

    internal procedure ValidateOrderIsEditable(var Order: Record "NPR CMOrder")
    var
        NotEditableErr: Label 'Booking %1 cannot be changed in status %2.', Comment = '%1 = booking reference, %2 = status';
    begin
        if (not IsEditable(Order)) then
            Error(NotEditableErr, Order.DocumentNo, Format(Order.Status));
    end;

    internal procedure CanReleaseOrder(var Order: Record "NPR CMOrder"): Boolean
    begin
        if (not (Order.Status in [Order.Status::WIP, Order.Status::Draft, Order.Status::Error])) then
            exit(false);
        if (IsPickupStarted(Order)) then
            exit(false);
        exit(true);
    end;

    // The lock serializes with a POS pick-up of the same booking, which takes the same lock before it adds lines.
    local procedure ValidateOrderCanBeReleased(var Order: Record "NPR CMOrder")
    var
        LockedOrder: Record "NPR CMOrder";
        NotReleasableErr: Label 'The assets of booking %1 can no longer be released: the booking is %2, or its pick-up has started in the POS.', Comment = '%1 = booking reference, %2 = status';
    begin
        LockedOrder.ReadIsolation := IsolationLevel::UpdLock;
        LockedOrder.Get(Order.OrderId);
        if (not CanReleaseOrder(LockedOrder)) then
            Error(NotReleasableErr, LockedOrder.DocumentNo, Format(LockedOrder.Status));
    end;

    internal procedure ReopenOrder(var Order: Record "NPR CMOrder")
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        NotDraftErr: Label 'Only bookings in status %1 can be reopened.', Comment = '%1 = the Draft status';
    begin
        if (Order.Status <> Order.Status::Draft) then
            Error(NotDraftErr, Format(Order.Status::Draft));
        ValidateOrderCanBeReleased(Order);

        OrderIssuer.ReleaseOrderAssets(Order);
        Order.Status := Order.Status::WIP;
        Order.Modify();
    end;

    internal procedure GetNextLineNo(OrderId: Guid): Integer
    var
        LastLine: Record "NPR CMOrderLine";
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
    begin
        LastLine.SetFilter(OrderId, '=%1', OrderId);
        LastLine.SetLoadFields(LineNo);
        if (LastLine.FindLast()) then;
        exit(LastLine.LineNo + TicketIssuer.GetLineNoSpacing());
    end;

    internal procedure ValidateUniqueOrderReference(var Order: Record "NPR CMOrder")
    var
        OtherOrder: Record "NPR CMOrder";
        DuplicateReferenceErr: Label 'Another booking already uses the reference ''%1''.', Comment = '%1 = the reference';
    begin
        OtherOrder.SetCurrentKey(PartnerId, SellToOrderReference);
        OtherOrder.SetFilter(PartnerId, '=%1', Order.PartnerId);
        OtherOrder.SetFilter(SellToOrderReference, '=%1', Order.SellToOrderReference);
        OtherOrder.SetFilter(OrderId, '<>%1', Order.OrderId);
        if (not OtherOrder.IsEmpty()) then
            Error(DuplicateReferenceErr, Order.SellToOrderReference);
    end;

    internal procedure ValidateLineItem(var OrderLine: Record "NPR CMOrderLine")
    var
        Item: Record Item;
        NotTicketErr: Label '%1 %2 is neither a ticket item nor a package item, so it cannot be issued in a wallet.', Comment = '%1 = Item table caption, %2 = item no.';
    begin
        OrderLine.IsPackage := false;
        OrderLine.IsGroupTicket := false;
        if (OrderLine.ItemNo = '') then
            exit;

        Item.SetLoadFields(Blocked, "NPR Ticket Type", "NPR Item AddOn No.");
        Item.Get(OrderLine.ItemNo);
        Item.TestField(Blocked, false);
        if ((Item."NPR Ticket Type" = '') and (Item."NPR Item AddOn No." = '')) then
            Error(NotTicketErr, Item.TableCaption(), Item."No.");

        OrderLine.IsPackage := IsPackageItem(Item);
        OrderLine.IsGroupTicket := (not OrderLine.IsPackage) and IsGroupTicketItem(Item);

        if (OrderLine.IsPackage) then
            ValidatePackageAdmissions(Item)
        else
            ValidateSingleAdmission(Item."No.");
    end;

    local procedure ValidatePackageAdmissions(var PackageItem: Record Item)
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        AddOnItem: Record Item;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
    begin
        ItemAddOn.SetLoadFields(Enabled);
        ItemAddOn.Get(PackageItem."NPR Item AddOn No.");
        ItemAddOn.TestField(Enabled, true);

        AddOnItem.SetLoadFields(Blocked, "NPR Ticket Type");
        AddOnLine.SetFilter("AddOn No.", '=%1', PackageItem."NPR Item AddOn No.");
        AddOnLine.SetFilter(Type, '=%1', AddOnLine.Type::Quantity);
        AddOnLine.SetFilter("Item No.", '<>%1', '');
        if (not AddOnLine.FindSet()) then
            exit;

        repeat
            AddOnItem.Get(AddOnLine."Item No.");
            AddOnItem.TestField(Blocked, false);
            if (AddOnItem."NPR Ticket Type" <> '') then
                ValidateSingleAdmission(AddOnItem."No.");
        until (AddOnLine.Next() = 0);
    end;

    local procedure ValidateSingleAdmission(TicketItemNo: Code[20])
    var
        Item: Record Item;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionCount: Integer;
        AdmissionLimitErr: Label '%1 %2 has %3 admissions. Only tickets with one admission are supported.', Comment = '%1 = Item table caption, %2 = item no., %3 = number of admissions';
    begin
        TicketBOM.SetFilter("Item No.", '=%1', TicketItemNo);
        TicketBOM.SetFilter("Variant Code", '=%1', '');
        AdmissionCount := TicketBOM.Count();
        if (AdmissionCount <> 1) then
            Error(AdmissionLimitErr, Item.TableCaption(), TicketItemNo, AdmissionCount);
    end;

    internal procedure DeleteOrderContent(var Order: Record "NPR CMOrder")
    var
        OrderLine: Record "NPR CMOrderLine";
        OrderComponent: Record "NPR CMOrderComponent";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
    begin
        if (Order.Status = Order.Status::Cancelled) then
            exit;

        ValidateOrderCanBeReleased(Order);
        OrderIssuer.ReleaseOrderAssets(Order);

        OrderComponent.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderComponent.DeleteAll();
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderLine.DeleteAll();
    end;
    #endregion

    #region Visits
    internal procedure LoadVisits(var OrderLine: Record "NPR CMOrderLine"; var Visit: Record "NPR CMTourBookingVisit")
    var
        Item: Record Item;
        AddOnItem: Record Item;
        AddOnLine: Record "NPR NpIa Item AddOn Line";
        Component: Record "NPR CMOrderComponent";
        ComponentItemNos: List of [Code[20]];
    begin
        Visit.Reset();
        Visit.DeleteAll();

        Item.SetLoadFields(Description, "NPR Item AddOn No.");
        Item.Get(OrderLine.ItemNo);

        Visit.Init();
        Visit.LineNo := OrderLine.LineNo;
        Visit.OrderId := OrderLine.OrderId;
        Visit.ItemNo := OrderLine.ItemNo;
        Visit.Description := Item.Description;
        Visit.VisitDate := OrderLine.VisitDate;
        Visit.VisitTime := OrderLine.VisitTime;
        Visit.Insert();

        if (not OrderLine.IsPackage) then
            exit;

        AddOnItem.SetLoadFields(Description, "NPR Ticket Type");
        AddOnLine.SetFilter("AddOn No.", '=%1', Item."NPR Item AddOn No.");
        AddOnLine.SetFilter(Type, '=%1', AddOnLine.Type::Quantity);
        AddOnLine.SetFilter("Item No.", '<>%1', '');
        if (not AddOnLine.FindSet()) then
            exit;

        repeat
            AddOnItem.Get(AddOnLine."Item No.");
            if ((AddOnItem."NPR Ticket Type" <> '') and (not ComponentItemNos.Contains(AddOnItem."No."))) then begin
                ComponentItemNos.Add(AddOnItem."No.");

                Visit.Init();
                Visit.LineNo := OrderLine.LineNo;
                Visit.SubLineNo := ComponentItemNos.Count();
                Visit.OrderId := OrderLine.OrderId;
                Visit.ItemNo := AddOnItem."No.";
                Visit.Description := AddOnItem.Description;
                Visit.Indentation := 1;
                Visit.IsComponent := true;

                Component.SetFilter(OrderId, '=%1', OrderLine.OrderId);
                Component.SetFilter(LineNo, '=%1', OrderLine.LineNo);
                Component.SetFilter(ComponentItemNo, '=%1', AddOnItem."No.");
                if (Component.FindFirst()) then begin
                    Visit.VisitDate := Component.VisitDate;
                    Visit.VisitTime := Component.VisitTime;
                end else begin
                    Visit.VisitDate := OrderLine.VisitDate;
                    Visit.VisitTime := OrderLine.VisitTime;
                end;
                Visit.Insert();
            end;
        until (AddOnLine.Next() = 0);
    end;

    // A package ticket has a component row only when it has its own visit; without one, the issuer uses the line's visit and the tree shows it.
    internal procedure SaveVisit(var Visit: Record "NPR CMTourBookingVisit")
    var
        OrderLine: Record "NPR CMOrderLine";
        Component: Record "NPR CMOrderComponent";
        LastComponent: Record "NPR CMOrderComponent";
    begin
        OrderLine.Get(Visit.OrderId, Visit.LineNo);
        if (not Visit.IsComponent) then begin
            OrderLine.VisitDate := Visit.VisitDate;
            OrderLine.VisitTime := Visit.VisitTime;
            OrderLine.Modify();
            ShowLineVisitOnFollowingTickets(Visit);
            exit;
        end;

        Component.SetFilter(OrderId, '=%1', Visit.OrderId);
        Component.SetFilter(LineNo, '=%1', Visit.LineNo);
        Component.SetFilter(ComponentItemNo, '=%1', Visit.ItemNo);
        if (Visit.VisitDate = 0D) then begin
            Component.DeleteAll();
            Visit.VisitDate := OrderLine.VisitDate;
            Visit.VisitTime := OrderLine.VisitTime;
            exit;
        end;

        if (not Component.FindFirst()) then begin
            LastComponent.SetFilter(OrderId, '=%1', Visit.OrderId);
            LastComponent.SetFilter(LineNo, '=%1', Visit.LineNo);
            if (LastComponent.FindLast()) then;

            Component.Init();
            Component.OrderId := Visit.OrderId;
            Component.LineNo := Visit.LineNo;
            Component.ComponentNo := LastComponent.ComponentNo + 10000;
            Component.ComponentItemNo := Visit.ItemNo;
            Component.Insert();
        end;

        Component.VisitDate := Visit.VisitDate;
        Component.VisitTime := Visit.VisitTime;
        Component.Modify();
    end;

    local procedure ShowLineVisitOnFollowingTickets(var LineVisit: Record "NPR CMTourBookingVisit")
    var
        TempComponentVisit: Record "NPR CMTourBookingVisit" temporary;
        Component: Record "NPR CMOrderComponent";
    begin
        TempComponentVisit.Copy(LineVisit, true);
        TempComponentVisit.Reset();
        TempComponentVisit.SetFilter(LineNo, '=%1', LineVisit.LineNo);
        TempComponentVisit.SetFilter(IsComponent, '=%1', true);
        if (not TempComponentVisit.FindSet()) then
            exit;

        Component.SetFilter(OrderId, '=%1', LineVisit.OrderId);
        Component.SetFilter(LineNo, '=%1', LineVisit.LineNo);
        repeat
            Component.SetFilter(ComponentItemNo, '=%1', TempComponentVisit.ItemNo);
            if (Component.IsEmpty()) then begin
                TempComponentVisit.VisitDate := LineVisit.VisitDate;
                TempComponentVisit.VisitTime := LineVisit.VisitTime;
                TempComponentVisit.Modify();
            end;
        until (TempComponentVisit.Next() = 0);
    end;

    internal procedure InheritVisitFromSameItem(var OrderLine: Record "NPR CMOrderLine"): Integer
    var
        OtherLine: Record "NPR CMOrderLine";
    begin
        if (OrderLine.VisitDate <> 0D) then
            exit(0);

        OtherLine.SetFilter(OrderId, '=%1', OrderLine.OrderId);
        OtherLine.SetFilter(LineNo, '<>%1', OrderLine.LineNo);
        OtherLine.SetFilter(ItemNo, '=%1', OrderLine.ItemNo);
        OtherLine.SetFilter(VisitDate, '<>%1', 0D);
        if (not OtherLine.FindLast()) then
            exit(0);

        OrderLine.VisitDate := OtherLine.VisitDate;
        OrderLine.VisitTime := OtherLine.VisitTime;
        exit(OtherLine.LineNo);
    end;

    internal procedure CopyLineComponents(OrderId: Guid; FromLineNo: Integer; ToLineNo: Integer)
    var
        FromComponent: Record "NPR CMOrderComponent";
        ToComponent: Record "NPR CMOrderComponent";
    begin
        FromComponent.SetFilter(OrderId, '=%1', OrderId);
        FromComponent.SetFilter(LineNo, '=%1', FromLineNo);
        if (not FromComponent.FindSet()) then
            exit;

        repeat
            ToComponent := FromComponent;
            ToComponent.LineNo := ToLineNo;
            ToComponent.Insert();
        until (FromComponent.Next() = 0);
    end;

    internal procedure DefaultLineVisitFromComponents(OrderId: Guid; LineNo: Integer)
    var
        OrderLine: Record "NPR CMOrderLine";
        Component: Record "NPR CMOrderComponent";
        EarliestComponent: Record "NPR CMOrderComponent";
    begin
        OrderLine.Get(OrderId, LineNo);
        if (OrderLine.VisitDate <> 0D) then
            exit;

        Component.SetFilter(OrderId, '=%1', OrderId);
        Component.SetFilter(LineNo, '=%1', LineNo);
        if (not Component.FindSet()) then
            exit;

        EarliestComponent := Component;
        repeat
            if ((Component.VisitDate < EarliestComponent.VisitDate) or
                ((Component.VisitDate = EarliestComponent.VisitDate) and (Component.VisitTime < EarliestComponent.VisitTime))) then
                EarliestComponent := Component;
        until (Component.Next() = 0);

        OrderLine.VisitDate := EarliestComponent.VisitDate;
        OrderLine.VisitTime := EarliestComponent.VisitTime;
        OrderLine.Modify();
    end;

    internal procedure DeleteLineComponents(var OrderLine: Record "NPR CMOrderLine")
    var
        Component: Record "NPR CMOrderComponent";
    begin
        Component.SetFilter(OrderId, '=%1', OrderLine.OrderId);
        Component.SetFilter(LineNo, '=%1', OrderLine.LineNo);
        Component.DeleteAll();
    end;
    #endregion

    #region Issue
    local procedure ValidateOrder(var Order: Record "NPR CMOrder")
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        OrderLine: Record "NPR CMOrderLine";
        Component: Record "NPR CMOrderComponent";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        TicketIssuer: Codeunit "NPR CMTicketIssuer";
        LocalToday: Date;
        NoLinesErr: Label 'Booking %1 has no lines.', Comment = '%1 = booking reference';
        WalletLimitErr: Label '%1 on line %2 is %3. A line holds at most %4 wallets.', Comment = '%1 = Quantity field caption, %2 = line no., %3 = the quantity, %4 = maximum number of wallets per line';
        VisitDateInPastErr: Label '%1 %2 on line %3 is in the past.', Comment = '%1 = Visit Date field caption, %2 = the visit date, %3 = line no.';
        ComponentVisitDateInPastErr: Label '%1 %2 for %3 on line %4 is in the past.', Comment = '%1 = Visit Date field caption, %2 = the visit date, %3 = package ticket item no., %4 = line no.';
        MissingReferenceErr: Label 'Booking %1 is %2, so it needs a %3 before it can be issued.', Comment = '%1 = booking reference, %2 = the payment option, %3 = Payment Reference field caption';
        NoDesignLayoutErr: Label '%1 is not set on partner %2 or in the Attraction Wallet Setup.', Comment = '%1 = Design Layout Label field caption, %2 = partner name';
    begin
        ValidateOrderIsEditable(Order);

        Order.TestField(SellToCustomerNo);
        Order.TestField(SellToOrderReference);
        if ((Order.PaymentOption in [Order.PaymentOption::Prepaid, Order.PaymentOption::Invoice]) and (Order.PaymentReference = '')) then
            Error(MissingReferenceErr, Order.DocumentNo, Format(Order.PaymentOption), Order.FieldCaption(PaymentReference));
        PartnerSetup.Get(Order.PartnerId);
        if (PartnerSetup.Distribution = PartnerSetup.Distribution::NPMail) then begin
            Order.TestField(SellToEmail);
            if (PartnerSetup.WalletEmailTemplateId <> '') then
                if (PartnerSetup.GetDesignLayoutId() = '') then
                    Error(NoDesignLayoutErr, PartnerSetup.FieldCaption(NPDesignerTemplateLabel), PartnerSetup.Name);
        end;

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (not OrderLine.FindSet()) then
            Error(NoLinesErr, Order.DocumentNo);

        LocalToday := DT2Date(TimeHelper.GetLocalTimeAtAdmission(''));
        repeat
            OrderLine.TestField(ItemNo);
            OrderLine.TestField(VisitDate);
            ValidateLineItem(OrderLine);
            if (ExpectedWalletCount(OrderLine) > TicketIssuer.GetMaxWalletsPerLine()) then
                Error(WalletLimitErr, OrderLine.FieldCaption(Quantity), OrderLine.LineNo, OrderLine.Quantity, TicketIssuer.GetMaxWalletsPerLine());
            if (OrderLine.VisitDate < LocalToday) then
                Error(VisitDateInPastErr, OrderLine.FieldCaption(VisitDate), OrderLine.VisitDate, OrderLine.LineNo);
            OrderLine.Modify();
        until (OrderLine.Next() = 0);

        Component.SetFilter(OrderId, '=%1', Order.OrderId);
        Component.SetFilter(VisitDate, '<%1', LocalToday);
        if (Component.FindFirst()) then
            Error(ComponentVisitDateInPastErr, Component.FieldCaption(VisitDate), Component.VisitDate, Component.ComponentItemNo, Component.LineNo);
    end;

    internal procedure IssueOrder(var Order: Record "NPR CMOrder") Success: Boolean
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Sentry: Codeunit "NPR Sentry";
        ErrorMessage: Text;
    begin
        ValidateOrder(Order);
        OrderIssuer.ReleaseOrderAssets(Order);
        CreateWalletShells(Order);

        Order.Status := Order.Status::Scheduled;
        Order.StatusMessage := '';
        Order.Modify();
        Commit();

        ClearLastError();
        Success := Codeunit.Run(Codeunit::"NPR CMOrderIssuer", Order);
        if (not Success) then begin
            Sentry.AddLastErrorIfProgrammingBug();
            ErrorMessage := GetLastErrorText();
        end;

        Order.Get(Order.OrderId);
        if (not Success) then begin
            Order.Status := Order.Status::Error;
            Order.StatusMessage := CopyStr(ErrorMessage, 1, MaxStrLen(Order.StatusMessage));
            Order.Modify();
            Commit();
        end;
    end;

    local procedure CreateWalletShells(var Order: Record "NPR CMOrder")
    var
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        SeqNo: Integer;
    begin
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderLine.FindSet();
        repeat
            for SeqNo := 1 to ExpectedWalletCount(OrderLine) do begin
                OrderWallet.Init();
                OrderWallet.OrderId := OrderLine.OrderId;
                OrderWallet.LineNo := OrderLine.LineNo;
                OrderWallet.SeqNo := SeqNo;
                OrderWallet.WalletName := OrderLine.Name;
                OrderWallet.Insert();
            end;
        until (OrderLine.Next() = 0);
    end;

    local procedure ExpectedWalletCount(var OrderLine: Record "NPR CMOrderLine"): Integer
    begin
        if (OrderLine.IsGroupTicket) then
            exit(1);
        exit(OrderLine.Quantity);
    end;

    local procedure IsPackageItem(Item: Record Item): Boolean
    begin
        exit(Item."NPR Item AddOn No." <> '');
    end;

    local procedure IsGroupTicketItem(Item: Record Item): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        if (Item."NPR Ticket Type" = '') then
            exit(false);
        if (not TicketType.Get(Item."NPR Ticket Type")) then
            exit(false);
        exit(TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP);
    end;
    #endregion

    #region Cancel
    internal procedure CancelOrder(var Order: Record "NPR CMOrder")
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
    begin
        ValidateOrderCanBeReleased(Order);
        OrderIssuer.DestroyOrderAssets(Order);
    end;
    #endregion

    #region Clear Personal Data
    internal procedure AnonymizeBookings(var Order: Record "NPR CMOrder")
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        AffectedAssets: Dictionary of [Guid, Integer];
        OrderAssets: Dictionary of [Guid, Integer];
        ClearQst: Label 'Remove the personal data from %1 booking(s) and the tickets and wallets issued from them?\\This cannot be undone.', Comment = '%1 = the number of bookings';
        ClearedMsg: Label 'The personal data was removed from %1 record(s).', Comment = '%1 = the number of records changed';
        NothingToClearMsg: Label 'There was no personal data left to remove.';
    begin
        if (Order.IsEmpty()) then
            exit;

        if (not Confirm(ClearQst, false, Order.Count())) then
            exit;

        Order.FindSet();
        repeat
            OrderIssuer.AnonymizeOrder(Order, OrderAssets);
            OrderIssuer.MergeAffectedAssets(OrderAssets, AffectedAssets);
        until (Order.Next() = 0);

        if (AffectedAssets.Count() = 0) then
            Message(NothingToClearMsg)
        else
            Message(ClearedMsg, AffectedAssets.Count());
    end;
    #endregion

    #region Pick-up state and confirm
    internal procedure IsPickupStarted(var Order: Record "NPR CMOrder"): Boolean
    var
        OrderLine: Record "NPR CMOrderLine";
        ReceiptNo: Code[20];
        NoPosSaleLine: Guid;
    begin
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderLine.SetFilter(PosSaleLineId, '<>%1', NoPosSaleLine);
        if (OrderLine.FindSet()) then
            repeat
                if (GetLineState(OrderLine, ReceiptNo) <> "NPR CMOrderLinePickupState"::Open) then
                    exit(true);
            until (OrderLine.Next() = 0);
        exit(false);
    end;

    internal procedure GetLineState(var OrderLine: Record "NPR CMOrderLine"; var ReceiptNo: Code[20]): Enum "NPR CMOrderLinePickupState"
    var
        POSSaleLine: Record "NPR POS Sale Line";
        SavedSaleLine: Record "NPR POS Saved Sale Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
    begin
        ReceiptNo := '';
        if (IsNullGuid(OrderLine.PosSaleLineId)) then
            exit("NPR CMOrderLinePickupState"::Open);

        POSEntrySalesLine.SetLoadFields("POS Entry No.");
        if (POSEntrySalesLine.GetBySystemId(OrderLine.PosSaleLineId)) then begin
            // A cancelled sale also copies its lines, with their SystemIds, into a POS entry.
            POSEntry.SetLoadFields("Entry Type", "Document No.");
            if (POSEntry.Get(POSEntrySalesLine."POS Entry No.")) then
                if (POSEntry."Entry Type" = POSEntry."Entry Type"::"Direct Sale") then begin
                    ReceiptNo := POSEntry."Document No.";
                    exit("NPR CMOrderLinePickupState"::Paid);
                end;
            exit("NPR CMOrderLinePickupState"::Open);
        end;

        POSSaleLine.SetFilter(SystemId, '=%1', OrderLine.PosSaleLineId);
        if (not POSSaleLine.IsEmpty()) then
            exit("NPR CMOrderLinePickupState"::InPosSale);

        SavedSaleLine.SetFilter(SystemId, '=%1', OrderLine.PosSaleLineId);
        if (not SavedSaleLine.IsEmpty()) then
            exit("NPR CMOrderLinePickupState"::ParkedSale);

        exit("NPR CMOrderLinePickupState"::Open);
    end;

    internal procedure IsFullyPaid(var Order: Record "NPR CMOrder"; var ReceiptNo: Code[20]): Boolean
    var
        OrderLine: Record "NPR CMOrderLine";
        LineReceiptNo: Code[20];
    begin
        ReceiptNo := '';
        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (not OrderLine.FindSet()) then
            exit(false);

        repeat
            if (GetLineState(OrderLine, LineReceiptNo) <> "NPR CMOrderLinePickupState"::Paid) then
                exit(false);
            ReceiptNo := LineReceiptNo;
        until (OrderLine.Next() = 0);

        exit(true);
    end;

    internal procedure ConfirmOrder(var Order: Record "NPR CMOrder"): Boolean
    var
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        ReceiptNo: Code[20];
    begin
        if (Order.Status <> Order.Status::Draft) then
            exit(false);

        if (not IsFullyPaid(Order, ReceiptNo)) then
            exit(false);

        Order.PaymentReference := ReceiptNo;
        Order.Modify();

        OrderIssuer.ConfirmOrder(Order);
        exit(true);
    end;

    internal procedure GetLineTotals(var OrderLine: Record "NPR CMOrderLine"; var WalletCount: Integer; var AmountExclVat: Decimal; var AmountInclVat: Decimal; var CurrencyCode: Code[10])
    var
        OrderWallet: Record "NPR CMOrderWallet";
    begin
        WalletCount := 0;
        AmountExclVat := 0;
        AmountInclVat := 0;
        CurrencyCode := '';

        OrderWallet.SetFilter(OrderId, '=%1', OrderLine.OrderId);
        OrderWallet.SetFilter(LineNo, '=%1', OrderLine.LineNo);
        OrderWallet.SetLoadFields(UnitPriceExclVat, UnitPriceInclVat, CurrencyCode);
        if (not OrderWallet.FindSet()) then
            exit;

        repeat
            WalletCount += 1;
            AmountExclVat += OrderWallet.UnitPriceExclVat;
            AmountInclVat += OrderWallet.UnitPriceInclVat;
            if (OrderWallet.CurrencyCode <> '') then
                CurrencyCode := OrderWallet.CurrencyCode;
        until (OrderWallet.Next() = 0);
    end;
    #endregion

    #region Invoice
    // The ticket revenue deferral finds the posted invoice by its External Document No., which must be the booking reference, and the tickets by its item lines.
    internal procedure CreateSalesInvoice(var Order: Record "NPR CMOrder"; var SalesHeader: Record "Sales Header")
    var
        OrderLine: Record "NPR CMOrderLine";
        ItemLineNo: Integer;
        LineNo: Integer;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Order.SellToCustomerNo);
        // Booking prices are in the local currency.
        SalesHeader.Validate("Currency Code", '');
        SalesHeader.Validate("External Document No.", Order.DocumentNo);
        if (Order.SellToOrderReference <> Order.DocumentNo) then
            SalesHeader.Validate("Your Reference", CopyStr(Order.SellToOrderReference, 1, MaxStrLen(SalesHeader."Your Reference")));
        SalesHeader.Modify(true);

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        OrderLine.FindSet();
        repeat
            ItemLineNo := LineNo + 10000;
            LineNo := ItemLineNo + 10000;
            AddInvoiceItemLine(SalesHeader, OrderLine, ItemLineNo);
            AddInvoiceVisitLine(SalesHeader, OrderLine, LineNo, ItemLineNo);
        until (OrderLine.Next() = 0);
    end;

    internal procedure FindSalesInvoice(var Order: Record "NPR CMOrder"; var SalesHeader: Record "Sales Header"): Boolean
    begin
        SalesHeader.SetFilter("Document Type", '=%1', SalesHeader."Document Type"::Invoice);
        SalesHeader.SetFilter("External Document No.", '=%1', Order.DocumentNo);
        exit(SalesHeader.FindLast());
    end;

    internal procedure GetSalesInvoiceStatus(var Order: Record "NPR CMOrder"): Text
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        PostedLbl: Label 'Posted';
        NotFoundLbl: Label 'Not Found';
    begin
        if (Order.PaymentReference = '') then
            exit(NotFoundLbl);
        if (FindPostedSalesInvoices(Order, false, SalesInvoiceHeader)) then
            exit(PostedLbl);
        if (FindSalesInvoice(Order, SalesHeader)) then
            exit(Format(SalesHeader.Status));
        if (FindPostedSalesInvoices(Order, true, SalesInvoiceHeader)) then
            exit(PostedLbl);
        exit(NotFoundLbl);
    end;

    // Sales Invoice Header has no key that starts with External Document No., so the booking's customer is tried first and every customer only when that finds nothing.
    local procedure FindPostedSalesInvoices(var Order: Record "NPR CMOrder"; AnyCustomer: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        SalesInvoiceHeader.Reset();
        if (not AnyCustomer) then begin
            SalesInvoiceHeader.SetCurrentKey("Sell-to Customer No.", "External Document No.");
            SalesInvoiceHeader.SetFilter("Sell-to Customer No.", '=%1', Order.SellToCustomerNo);
        end;
        SalesInvoiceHeader.SetFilter("External Document No.", '=%1', Order.PaymentReference);
        exit(not SalesInvoiceHeader.IsEmpty());
    end;

    local procedure AddInvoiceItemLine(var SalesHeader: Record "Sales Header"; var OrderLine: Record "NPR CMOrderLine"; LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        WalletCount: Integer;
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
        CurrencyCode: Code[10];
    begin
        GetLineTotals(OrderLine, WalletCount, AmountExclVat, AmountInclVat, CurrencyCode);

        InitInvoiceLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", OrderLine.ItemNo);
        SalesLine.Validate("Location Code", '');
        SalesLine.Validate(Quantity, OrderLine.Quantity);
        if (SalesHeader."Prices Including VAT") then
            SalesLine.Validate("Unit Price", AmountInclVat / OrderLine.Quantity)
        else
            SalesLine.Validate("Unit Price", AmountExclVat / OrderLine.Quantity);
        SalesLine.Validate("Line Discount %", 0);
        SalesLine.Insert(true);
    end;

    local procedure AddInvoiceVisitLine(var SalesHeader: Record "Sales Header"; var OrderLine: Record "NPR CMOrderLine"; LineNo: Integer; ItemLineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        Distribution: Codeunit "NPR CMOrderDistribution";
        VisitLbl: Label 'Visit %1 %2', Comment = '%1 = visit date, %2 = visit time';
    begin
        InitInvoiceLine(SalesHeader, LineNo, SalesLine);
        SalesLine.Type := SalesLine.Type::" ";
        SalesLine.Description := CopyStr(DelChr(StrSubstNo(VisitLbl, Distribution.FormatVisitDate(OrderLine.VisitDate), Distribution.FormatVisitTime(OrderLine.VisitTime)), '>', ' '), 1, MaxStrLen(SalesLine.Description));
        SalesLine."Attached to Line No." := ItemLineNo;
        SalesLine.Insert(true);
    end;

    local procedure InitInvoiceLine(var SalesHeader: Record "Sales Header"; LineNo: Integer; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
    end;
    #endregion

    #region Payment document
    internal procedure ShowPaymentDocument(var Order: Record "NPR CMOrder")
    begin
        if (Order.PaymentReference = '') then
            exit;

        if (Order.PaymentOption = Order.PaymentOption::PayAtPickup) then
            ShowPOSEntry(Order)
        else
            ShowSalesInvoice(Order);
    end;

    local procedure ShowPOSEntry(var Order: Record "NPR CMOrder")
    var
        POSEntry: Record "NPR POS Entry";
        NoPOSEntryMsg: Label 'There is no %1 with %2 %3.', Comment = '%1 = POS Entry table caption, %2 = Document No. field caption, %3 = the POS receipt no.';
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetFilter("Document No.", '=%1', Order.PaymentReference);
        if (not POSEntry.FindFirst()) then begin
            Message(NoPOSEntryMsg, POSEntry.TableCaption(), POSEntry.FieldCaption("Document No."), Order.PaymentReference);
            exit;
        end;

        Page.Run(Page::"NPR POS Entry Card", POSEntry);
    end;

    local procedure ShowSalesInvoice(var Order: Record "NPR CMOrder")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        NoSalesInvoiceMsg: Label 'There is no %1 with %2 %3.', Comment = '%1 = Sales Invoice Header table caption, %2 = External Document No. field caption, %3 = the payment reference';
        CreateSalesInvoiceQst: Label 'Booking %1 has no sales invoice. Create one?', Comment = '%1 = booking reference';
    begin
        if (FindPostedSalesInvoices(Order, false, SalesInvoiceHeader)) then begin
            RunPostedSalesInvoices(SalesInvoiceHeader);
            exit;
        end;

        if (Order.PaymentOption = Order.PaymentOption::Invoice) then
            if (FindSalesInvoice(Order, SalesHeader)) then begin
                Page.Run(Page::"Sales Invoice", SalesHeader);
                exit;
            end;

        if (FindPostedSalesInvoices(Order, true, SalesInvoiceHeader)) then begin
            RunPostedSalesInvoices(SalesInvoiceHeader);
            exit;
        end;

        if ((Order.PaymentOption = Order.PaymentOption::Invoice) and (Order.Status = Order.Status::Issued)) then begin
            if (Confirm(CreateSalesInvoiceQst, true, Order.DocumentNo)) then begin
                CreateSalesInvoice(Order, SalesHeader);
                Page.Run(Page::"Sales Invoice", SalesHeader);
            end;
            exit;
        end;

        Message(NoSalesInvoiceMsg, SalesInvoiceHeader.TableCaption(), SalesInvoiceHeader.FieldCaption("External Document No."), Order.PaymentReference);
    end;

    local procedure RunPostedSalesInvoices(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.FindFirst();
        if (SalesInvoiceHeader.Count() = 1) then
            Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader)
        else
            Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);
    end;
    #endregion
}
