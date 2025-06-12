codeunit 6185062 "NPR AttractionWallet"
{
    Access = Internal;
    internal procedure IsWalletEnabled(): boolean
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        exit(Setup.Enabled);
    end;

    internal procedure IsEndOfSalePrintEnabled(): boolean
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        exit(Setup.EnableEndOfSalePrint and Setup.Enabled);
    end;

    // Wallets Created per quantity when source is a Wallet Template Addon
    [CommitBehavior(CommitBehavior::Error)]
    internal procedure CreateAssetsFromPosSaleLine(POSSale: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        WalletEntryNoList: List of [Integer];
    begin
        if (not IsWalletEnabled()) then
            exit;

        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', POSSale.SystemId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLinePOS."Line No.");
        if (IntermediaryWalletLine.IsEmpty()) then
            exit;

        CreateWallets(POSSale.SystemId, SaleLinePOS."Line No.", SaleLinePOS.Quantity, SaleLinePOS."No.", WalletEntryNoList);
        CreateAssets(WalletEntryNoList, POSSale."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."No.", SaleLinePOS.Quantity);
        AddReferencesToWalletFromPosSale(POSSale, WalletEntryNoList);

    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure AddNewWalletAsLineAsset(OwnerWallet: Record "NPR AttractionWallet") WalletEntryNo: Integer
    var
        OwnerWalletAssetHeader: Record "NPR WalletAssetHeader";
        OwnerWalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        NewWalletAssetHeader: Record "NPR WalletAssetHeader";
        AssetEntryNo: Integer;
    begin
        OwnerWalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', Database::"NPR AttractionWallet");
        OwnerWalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', OwnerWallet.SystemId);
        if (not OwnerWalletAssetHeaderRef.FindSet()) then
            exit(0);

        if (not OwnerWalletAssetHeader.Get(OwnerWalletAssetHeaderRef.WalletHeaderEntryNo)) then
            exit(0);

        WalletEntryNo := CreateWallet(NewWalletAssetHeader);
        AssetEntryNo := AddWalletAsLineAsset(OwnerWalletAssetHeader, WalletEntryNo);

        AddAssetToWallet(AssetEntryNo, OwnerWallet.EntryNo);
    end;

    internal procedure PrintWallets(TableId: Integer; SystemId: Guid; PrintContext: Enum "NPR WalletPrintType")
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        AssetLine: Record "NPR WalletAssetLine";
        AssetHeader: Record "NPR WalletAssetHeader";
        WalletEntryNoList: List of [Integer];
    begin
        if (not IsWalletEnabled()) then
            exit;

        // Assets Owned by receipt number
        WalletAssetHeaderRef.SetCurrentKey(LinkToReference, SupersededBy);
        WalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', TableId);
        WalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', SystemId);
        WalletAssetHeaderRef.SetFilter(SupersededBy, '=%1', 0);
        if (WalletAssetHeaderRef.FindSet()) then begin
            repeat
                AssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);

                AssetLine.SetCurrentKey(TransactionId);
                AssetLine.SetFilter(TransactionId, '=%1', AssetHeader.TransactionId);
                AssetLine.SetFilter(Type, '=%1', AssetLine.Type::WALLET);
                if (AssetLine.FindSet()) then
                    repeat
                        Wallet.Reset();
                        Wallet.GetBySystemId(AssetLine.LineTypeSystemId);
                        if (not WalletEntryNoList.Contains(Wallet.EntryNo)) then
                            WalletEntryNoList.Add(Wallet.EntryNo);

                    until (AssetLine.Next() = 0);
            until (WalletAssetHeaderRef.Next() = 0);
        end;

        if (WalletEntryNoList.Count() > 0) then
            PrintWalletsInternal(WalletEntryNoList, PrintContext);
    end;

    internal procedure PrintWallets(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType")
    begin
        if (not IsWalletEnabled()) then
            exit;

        if (WalletEntryNoList.Count() > 0) then
            PrintWalletsInternal(WalletEntryNoList, PrintContext);
    end;

    internal procedure PrintWallet(WalletEntryNo: Integer; PrintContext: Enum "NPR WalletPrintType")
    var
        WalletEntryNoList: List of [Integer];
    begin
        if (not IsWalletEnabled()) then
            exit;

        WalletEntryNoList.Add(WalletEntryNo);
        PrintWalletsInternal(WalletEntryNoList, PrintContext);
    end;

    internal procedure IsTicketInWallet(Ticket: Record "NPR TM Ticket"): boolean
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
    begin
        if (not IsWalletEnabled()) then
            exit;

        WalletAssetLine.SetCurrentKey(Type, LineTypeSystemId);
        WalletAssetLine.SetFilter(Type, '=%1', WalletAssetLine.Type::Ticket);
        WalletAssetLine.SetFilter(LineTypeSystemId, '=%1', Ticket.SystemId);
        exit(not WalletAssetLine.IsEmpty());
    end;

    // ********* Local functions
    local procedure AddReferencesToWalletFromPosSale(POSSale: Record "NPR POS Sale"; WalletEntryNoList: List of [Integer])
    var
        WalletEntryNo: Integer;
    begin
        foreach WalletEntryNo in WalletEntryNoList do
            AddReferencesToWalletFromPosSale(POSSale, WalletEntryNo);
    end;

    local procedure AddReferencesToWalletFromPosSale(POSSale: Record "NPR POS Sale"; WalletEntryNo: Integer)
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        Wallet: Record "NPR AttractionWallet";
    begin
        Wallet.Get(WalletEntryNo);
        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', Database::"NPR AttractionWallet");
        WalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', Wallet.SystemId);
        if (WalletAssetHeaderRef.FindFirst()) then begin
            WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);
            AddPosSaleHeaderReference(WalletAssetHeader.EntryNo, POSSale);
            AddCustomerHeaderReference(WalletAssetHeader.EntryNo, POSSale."Customer No.");
            AddCustomerMemberCards(WalletAssetHeader.EntryNo, POSSale."Customer No.");

            AddWalletAsLineAsset(WalletAssetHeader, WalletEntryNo);
        end;

    end;

    local procedure CreateAssets(var WalletEntryNoList: List of [Integer]; SalesTicketNo: Code[20]; SaleLineNo: Integer; SalesItemNo: Code[20]; SalesQuantity: Decimal)
    var
        Item: Record Item;
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        WalletCoupon: Record "NPR WalletCouponSetup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        InfoCapture: Record "NPR MM Member Info Capture";
        Quantity: Integer;
    begin

        if (WalletEntryNoList.Count() = 0) then
            exit;

        if (not Item.Get(SalesItemNo)) then
            exit;

        Quantity := Round(SalesQuantity, 1);

        if (Item."NPR Ticket Type" <> '') then begin
            ReservationRequest.SetCurrentKey("Receipt No.", "Line No.");
            ReservationRequest.SetFilter("Receipt No.", '=%1', SalesTicketNo);
            ReservationRequest.SetFilter("Line No.", '=%1', SaleLineNo);
            ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
            AddTicketAssets(WalletEntryNoList, ReservationRequest);
        end;

        WalletCoupon.SetFilter(TriggerOnItemNo, '=%1', SalesItemNo);
        if (WalletCoupon.FindFirst()) then
            AddCouponAssets(WalletEntryNoList, WalletCoupon."Coupon Type", SalesItemNo, Item.Description, Quantity, SalesTicketNo);

        MembershipSalesSetup.SetFilter("No.", '=%1', SalesItemNo);
        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        if (MembershipSalesSetup.FindFirst()) then begin
            InfoCapture.SetCurrentKey("Receipt No.", "Line No.");
            InfoCapture.SetFilter("Receipt No.", '=%1', SalesTicketNo);
            InfoCapture.SetFilter("Line No.", '=%1', SaleLineNo);
            AddMembershipCardAssets(WalletEntryNoList, InfoCapture);
        end;
    end;

    local procedure AddCustomerMemberCards(EntryNo: Integer; CustomerNo: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipCard: Record "NPR MM Member Card";
    begin
        Membership.SetCurrentKey("Customer No.");
        Membership.SetFilter("Customer No.", '=%1', CustomerNo);
        Membership.SetFilter(Blocked, '=%1', false);
        if (Membership.FindFirst()) then begin

            MembershipRole.SetCurrentKey("Membership Entry No.");
            MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
            MembershipRole.SetFilter(Blocked, '=%1', false);
            MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::GUARDIAN);
            if (MembershipRole.FindFirst()) then begin
                MembershipCard.SetCurrentKey("Membership Entry No.");
                MembershipCard.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipCard.SetFilter("Member Entry No.", '=%1', MembershipRole."Member Entry No.");
                MembershipCard.SetFilter(Blocked, '=%1', false);
                if (MembershipCard.FindSet()) then begin
                    repeat
                        AddMemberCardHeaderReference(EntryNo, MembershipCard);
                    until (MembershipCard.Next() = 0);
                end;
            end;
        end;
    end;

    internal procedure AddTicketsToWallet(WalletEntryNo: Integer; TicketIds: List of [Guid])
    var
        TicketId: Guid;
    begin
        foreach TicketId in TicketIds do
            AddTicketToWallet(WalletEntryNo, TicketId);
    end;

    internal procedure AddTicketToWallet(WalletEntryNo: Integer; TicketId: Guid)
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
    begin

        Ticket.GetBySystemId(TicketId);
        Item.Get(Ticket."Item No.");

        WalletAssetLine.SetCurrentKey(Type, LineTypeSystemId);
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::Ticket);
        WalletAssetLine.SetFilter(LineTypeSystemId, '=%1', Ticket.SystemId);
        if (not WalletAssetLine.FindFirst()) then begin
            WalletAssetLine.Init();
            WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
            WalletAssetLine.ItemNo := Ticket."Item No.";
            WalletAssetLine.Description := Item.Description;
            WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
            WalletAssetLine.Type := ENUM::"NPR WalletLineType"::Ticket;
            WalletAssetLine.DocumentNumber := Ticket."Sales Receipt No.";
            if (WalletAssetLine.DocumentNumber = '') then
                WalletAssetLine.DocumentNumber := Ticket."Sales Header No.";

            WalletAssetLine.EntryNo := 0;
            WalletAssetLine.LineTypeSystemId := Ticket.SystemId;
            WalletAssetLine.LineTypeReference := Ticket."External Ticket No.";
            WalletAssetLine.Insert();
        end;

        AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
    end;

    local procedure AddTicketAssets(WalletEntryNoList: List of [Integer]; var ReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        WalletEntryNo: Integer;
        WalletIndex: Integer;
    begin

        if (not ReservationRequest.FindSet()) then
            exit;

        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', ReservationRequest."Entry No.");

            WalletIndex := 0;
            if (Ticket.FindSet()) then begin

                repeat
                    WalletIndex := WalletIndex MOD WalletEntryNoList.Count();
                    WalletEntryNoList.Get(WalletIndex + 1, WalletEntryNo);
                    WalletIndex += 1;

                    AddTicketToWallet(WalletEntryNo, Ticket.SystemId);
                until (Ticket.Next() = 0);
            end;
        until (ReservationRequest.Next() = 0);
    end;

    internal procedure AddCouponsToWallet(WalletEntryNo: Integer; CouponIds: List of [Guid]; ItemNo: Code[20]; DocumentNumber: Code[20])
    var
        CouponId: Guid;
    begin
        foreach CouponId in CouponIds do
            AddCouponToWallet(WalletEntryNo, CouponId, ItemNo, DocumentNumber);
    end;

    local procedure AddCouponToWallet(WalletEntryNo: Integer; CouponId: Guid; ItemNo: Code[20]; DocumentNumber: Code[20])
    var
        Coupon: Record "NPR NpDc Coupon";
        WalletAssetLine: Record "NPR WalletAssetLine";
    begin
        Coupon.GetBySystemId(CouponId);

        WalletAssetLine.SetCurrentKey(Type, LineTypeSystemId);
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::COUPON);
        WalletAssetLine.SetFilter(LineTypeSystemId, '=%1', Coupon.SystemId);
        if (not WalletAssetLine.FindFirst()) then begin
            WalletAssetLine.Init();
            WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
            WalletAssetLine.ItemNo := ItemNo;
            WalletAssetLine.Description := Coupon.Description;
            WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
            WalletAssetLine.Type := ENUM::"NPR WalletLineType"::COUPON;
            WalletAssetLine.DocumentNumber := DocumentNumber;

            WalletAssetLine.EntryNo := 0;
            WalletAssetLine.LineTypeSystemId := Coupon.SystemId;
            WalletAssetLine.LineTypeReference := Coupon."Reference No.";
            WalletAssetLine.Insert();
        end;

        AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
    end;

    local procedure AddCouponAssets(WalletEntryNoList: List of [Integer]; CouponType: Code[20]; ItemNo: Code[20]; Description: Text[100]; SalesQuantity: Decimal; DocumentNumber: Code[20])
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        WalletCoupon: Codeunit "NPR AttractionWalletCoupon";
        WalletEntryNo: Integer;
        WalletIndex: Integer;
    begin
        WalletCoupon.IssueCoupons(CouponType, SalesQuantity, TempCoupon);
        if (not TempCoupon.FindSet()) then
            exit;

        WalletIndex := 0;
        repeat
            WalletIndex := WalletIndex MOD WalletEntryNoList.Count();
            WalletEntryNoList.Get(WalletIndex + 1, WalletEntryNo);
            WalletIndex += 1;

            WalletAssetLine.Init();
            WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
            WalletAssetLine.ItemNo := ItemNo;
            WalletAssetLine.Description := Description;
            WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
            WalletAssetLine.Type := ENUM::"NPR WalletLineType"::Coupon;
            WalletAssetLine.DocumentNumber := DocumentNumber;

            WalletAssetLine.EntryNo := 0;
            WalletAssetLine.LineTypeSystemId := TempCoupon.SystemId;
            WalletAssetLine.LineTypeReference := TempCoupon."Reference No.";
            WalletAssetLine.Insert();

            AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
        until (TempCoupon.Next() = 0);
    end;

    internal procedure AddMemberCardsToWallet(WalletEntryNo: Integer; MemberCardIds: List of [Guid])
    var
        MemberCardId: Guid;
    begin
        foreach MemberCardId in MemberCardIds do
            AddMemberCardToWallet(WalletEntryNo, MemberCardId);
    end;

    internal procedure AddMemberCardToWallet(WalletEntryNo: Integer; MemberCardId: Guid)
    var
        MembershipCard: Record "NPR MM Member Card";
        WalletAssetLine: Record "NPR WalletAssetLine";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        MembershipCard.GetBySystemId(MemberCardId);

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipCard."Membership Entry No.");
        MembershipEntry.SetFilter(Context, '=%1', MembershipEntry.Context::NEW);
        MembershipEntry.FindFirst();

        WalletAssetLine.SetCurrentKey(Type, LineTypeSystemId);
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::MEMBERSHIP);
        WalletAssetLine.SetFilter(LineTypeSystemId, '=%1', MembershipCard.SystemId);
        if (not WalletAssetLine.FindFirst()) then begin
            WalletAssetLine.Init();
            WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
            WalletAssetLine.ItemNo := MembershipEntry."Item No.";
            WalletAssetLine.Description := MembershipEntry.Description;
            WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
            WalletAssetLine.Type := ENUM::"NPR WalletLineType"::MEMBERSHIP;
            WalletAssetLine.DocumentNumber := MembershipEntry."Receipt No.";
            if (WalletAssetLine.DocumentNumber = '') then
                WalletAssetLine.DocumentNumber := MembershipEntry."Document No.";

            WalletAssetLine.EntryNo := 0;
            WalletAssetLine.LineTypeSystemId := MembershipCard.SystemId;
            WalletAssetLine.LineTypeReference := MembershipCard."External Card No.";
            WalletAssetLine.Insert();
        end;

        AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);

    end;

    local procedure AddMembershipCardAssets(WalletEntryNoList: List of [Integer]; var InfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipCard: Record "NPR MM Member Card";
        WalletEntryNo: Integer;
        WalletIndex: Integer;
    begin
        if (not InfoCapture.FindSet()) then
            exit;

        repeat
            WalletIndex := 0;
            WalletIndex := WalletIndex MOD WalletEntryNoList.Count();
            WalletEntryNoList.Get(WalletIndex + 1, WalletEntryNo);
            WalletIndex += 1;

            MembershipCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");
            MembershipCard.SetFilter("Membership Entry No.", '=%1', InfoCapture."Membership Entry No.");
            MembershipCard.SetFilter("Member Entry No.", '=%1', InfoCapture."Member Entry No");
            if (MembershipCard.FindFirst()) then
                AddMemberCardToWallet(WalletEntryNo, MembershipCard.SystemId);

        until (InfoCapture.Next() = 0);
    end;

    local procedure AddPosSaleHeaderReference(EntryNo: Integer; POSSale: Record "NPR POS Sale")
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::"NPR POS Entry"; // Not an error - POS Entry and POS Sale share the same SystemId
        WalletAssetHeaderRef.LinkToSystemId := POSSale.SystemId;
        WalletAssetHeaderRef.LinkToReference := POSSale."Sales Ticket No.";
        WalletAssetHeaderRef.Insert();
    end;

    local procedure AddCustomerHeaderReference(EntryNo: Integer; CustomerNo: Code[20])
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        Customer: Record Customer;
    begin
        if (not Customer.Get(CustomerNo)) then
            exit;

        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::Customer;
        WalletAssetHeaderRef.LinkToSystemId := Customer.SystemId;
        WalletAssetHeaderRef.LinkToReference := CustomerNo;
        WalletAssetHeaderRef.Insert();
    end;

    local procedure AddMemberCardHeaderReference(EntryNo: Integer; MembershipCard: Record "NPR MM Member Card")
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::Customer;
        WalletAssetHeaderRef.LinkToSystemId := MembershipCard.SystemId;
        WalletAssetHeaderRef.LinkToReference := MembershipCard."External Card No.";
        WalletAssetHeaderRef.Insert();
    end;

    local procedure AddWalletHeaderReference(EntryNo: Integer; WalletHolderEntryNo: Integer)
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        Wallet: Record "NPR AttractionWallet";
    begin
        if (not Wallet.Get(WalletHolderEntryNo)) then
            exit;

        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::"NPR AttractionWallet";
        WalletAssetHeaderRef.LinkToSystemId := Wallet.SystemId;
        WalletAssetHeaderRef.LinkToReference := Wallet.ReferenceNumber;
        WalletAssetHeaderRef.Insert();
    end;

    internal procedure AddHeaderReference(WalletEntryNo: Integer; TableId: Integer; SystemId: Guid; Reference: Text[100])
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        Wallet: Record "NPR AttractionWallet";
    begin

        Wallet.Get(WalletEntryNo);
        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', Database::"NPR AttractionWallet");
        WalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', Wallet.SystemId);
        if (not WalletAssetHeaderRef.FindFirst()) then begin
            GetWalletTransactionId(WalletEntryNo);
            WalletAssetHeaderRef.FindFirst();
            WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);
            AddWalletAsLineAsset(WalletAssetHeader, WalletEntryNo);
        end;

        WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', TableId);
        WalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', SystemId);
        WalletAssetHeaderRef.SetFilter(LinkToReference, '=%1', Reference);
        WalletAssetHeaderRef.SetFilter(WalletHeaderEntryNo, '=%1', WalletAssetHeader.EntryNo);
        if (not WalletAssetHeaderRef.IsEmpty()) then
            exit;

        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := WalletAssetHeader.EntryNo;
        WalletAssetHeaderRef.LinkToTableId := TableId;
        WalletAssetHeaderRef.LinkToSystemId := SystemId;
        WalletAssetHeaderRef.LinkToReference := Reference;
        WalletAssetHeaderRef.Insert();
    end;

    internal procedure UpdateEmailAddressOnAllWallets(FromEmail: Text[100]; ToEmail: Text[100])
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        NullGuid: Guid;
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        WalletAssetHeaderRef.LockTable();
#else
        WalletAssetHeaderRef.ReadIsolation := IsolationLevel::UpdLock;
#endif
        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToReference, SupersededBy);
        WalletAssetHeaderRef.SetRange(LinkToTableId, 0);
        WalletAssetHeaderRef.SetRange(LinkToSystemId, NullGuid);
        WalletAssetHeaderRef.SetRange(LinkToReference, FromEmail);
        WalletAssetHeaderRef.SetRange(SupersededBy, 0);
        if (WalletAssetHeaderRef.FindSet()) then
            repeat
                WalletAssetHeaderRef.LinkToReference := ToEmail;
                WalletAssetHeaderRef.Modify();
            until WalletAssetHeaderRef.Next() = 0;
    end;

    internal procedure CreateNewExternalReference(WalletEntryNo: Integer)
    var
        Wallet: Record "NPR AttractionWallet";
    begin
        Wallet.Get(WalletEntryNo);
        CreateNewExternalReference(Wallet);
    end;

    internal procedure CreateNewExternalReference(Wallet: Record "NPR AttractionWallet")
    var
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
        WalletExternalReference.Init();
        WalletExternalReference.ExternalReference := GenerateWalletExternalReference(CopyStr(Wallet.ReferenceNumber, 1, 20));
        WalletExternalReference.WalletEntryNo := Wallet.EntryNo;
        WalletExternalReference.Insert(true);
    end;

    internal procedure BlockAllExternalReferences(WalletEntryNo: Integer)
    var
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        BlockTime: DateTime;
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        WalletExternalReference.LockTable();
#else
        WalletExternalReference.ReadIsolation := IsolationLevel::UpdLock;
#endif
        WalletExternalReference.SetFilter(WalletEntryNo, '=%1', WalletEntryNo);
        WalletExternalReference.SetFilter(BlockedAt, '=%1', 0DT);
        if (not WalletExternalReference.FindSet()) then
            exit;

        BlockTime := CurrentDateTime();
        repeat
            WalletExternalReference.BlockedAt := BlockTime;
            WalletExternalReference.Modify();
        until WalletExternalReference.Next() = 0;
    end;

    internal procedure BlockExternalReference(ExternalReference: Text[100])
    var
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        WalletExternalReference.LockTable();
#else
        WalletExternalReference.ReadIsolation := IsolationLevel::UpdLock;
#endif
        WalletExternalReference.SetFilter(ExternalReference, '=%1', ExternalReference);
        WalletExternalReference.SetFilter(BlockedAt, '=%1', 0DT);
        if (not WalletExternalReference.FindFirst()) then
            exit;
        WalletExternalReference.BlockedAt := CurrentDateTime();
        WalletExternalReference.Modify();
    end;

    local procedure CreateOwnerWallet(var WalletAssetHeader: Record "NPR WalletAssetHeader"): Integer
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        CreateWallet(CreateGuid(), '', '', Wallet);

        WalletAssetHeaderRef.Init();
        WalletAssetHeaderRef.WalletHeaderEntryNo := WalletAssetHeader.EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::"NPR AttractionWallet";
        WalletAssetHeaderRef.LinkToSystemId := Wallet.SystemId;
        WalletAssetHeaderRef.LinkToReference := Wallet.ReferenceNumber;
        WalletAssetHeaderRef.Insert();

        exit(Wallet.EntryNo);
    end;

    local procedure CreateWallet(var WalletAssetHeader: Record "NPR WalletAssetHeader") WalletEntryNo: Integer
    begin
        if (not CreateWalletAssetHeader(WalletAssetHeader)) then
            exit;

        WalletEntryNo := CreateOwnerWallet(WalletAssetHeader);
    end;

    local procedure CreateWallets(SaleId: Guid; SaleLineNumber: Integer; Quantity: Integer; ItemNo: Code[20]; var WalletEntryNoList: List of [Integer])
    var
        Wallet: Record "NPR AttractionWallet";
        IntermediaryWallet: Record "NPR AttractionWalletSaleHdr";
        IntermediaryWalletLine: Record "NPR AttractionWalletSaleLine";
        WalletEvents: Codeunit "NPR AttractionWalletEvents";
    begin
        if (Quantity <= 0) then
            exit;

        IntermediaryWalletLine.SetCurrentKey(SaleHeaderSystemId, LineNumber);
        IntermediaryWalletLine.SetFilter(SaleHeaderSystemId, '=%1', SaleId);
        IntermediaryWalletLine.SetFilter(LineNumber, '=%1', SaleLineNumber);
        if (IntermediaryWalletLine.FindSet()) then begin
            repeat
                IntermediaryWallet.Get(IntermediaryWalletLine.SaleHeaderSystemId, IntermediaryWalletLine.WalletNumber);
                if (Wallet.Get(IntermediaryWallet.WalletEntryNo)) then begin
                    WalletEntryNoList.Add(Wallet.EntryNo)
                end else begin
                    WalletEntryNoList.Add(CreateWallet(CreateGuid(), ItemNo, IntermediaryWallet.Name, Wallet));
                    IntermediaryWallet.WalletEntryNo := Wallet.EntryNo;
                    IntermediaryWallet.Modify();

                    WalletEvents.OnAfterCreateWalletFromPOSSaleLine(IntermediaryWalletLine.SaleLineId, Wallet.EntryNo);
                end;
            until (IntermediaryWalletLine.Next() = 0);
        end;
    end;

    internal procedure CreateWallet(WalletSystemId: Guid; ItemNo: Code[20]; Description: Text[100]; var Wallet: Record "NPR AttractionWallet"): Integer
    var
        WalletSequenceNumber: Text[30];
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
        Wallet.Init();
        Wallet.EntryNo := 0;
        Wallet.OriginatesFromItemNo := ItemNo;
        Wallet.Description := Description;
        Wallet.SystemId := WalletSystemId;
        if (not Wallet.Insert()) then
            error(GetLastErrorText());

        WalletSequenceNumber := Format(Wallet."EntryNo", 0, 9);
#pragma warning disable AA0139 // PadLeft returns a Text, not a Code[20]
        Wallet.ReferenceNumber := GenerateWalletReference(WalletSequenceNumber.PadLeft(10, '0'));
#pragma warning restore AA0139
        Wallet.Modify();

        WalletExternalReference.Init();
#pragma warning disable AA0139 // PadLeft returns a Text, not a Code[20]
        WalletExternalReference.ExternalReference := GenerateWalletExternalReference(WalletSequenceNumber.PadLeft(10, '0'));
#pragma warning disable AA0139
        WalletExternalReference.WalletEntryNo := Wallet.EntryNo;
        WalletExternalReference.Insert(true);

        exit(Wallet.EntryNo);
    end;

    local procedure AddWalletAsLineAsset(WalletAssetHeader: Record "NPR WalletAssetHeader"; WalletEntryNo: Integer): Integer
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetLine: Record "NPR WalletAssetLine";
    begin

        if (not Wallet.Get(WalletEntryNo)) then
            exit;

        WalletAssetLine.Init();
        WalletAssetLine.EntryNo := 0;
        WalletAssetLine.TransactionId := WalletAssetHeader.TransactionId;
        WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
        WalletAssetLine.Type := ENUM::"NPR WalletLineType"::Wallet;
        WalletAssetLine.LineTypeSystemId := Wallet.SystemId;
        WalletAssetLine.LineTypeReference := Wallet.ReferenceNumber;
        WalletAssetLine.Insert();

        exit(WalletAssetLine.EntryNo);
    end;

    internal procedure GetWalletTransactionId(WalletEntryNo: Integer): Guid
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
    begin
        Wallet.Get(WalletEntryNo);

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetFilter(LinkToTableId, '=%1', Database::"NPR AttractionWallet");
        WalletAssetHeaderRef.SetFilter(LinkToSystemId, '=%1', Wallet.SystemId);
        if (not WalletAssetHeaderRef.FindFirst()) then begin
            CreateWalletAssetHeader(WalletAssetHeader);
            AddWalletHeaderReference(WalletAssetHeader.EntryNo, WalletEntryNo);
        end else begin
            WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo);
        end;

        exit(WalletAssetHeader.TransactionId);
    end;

    local procedure AddAssetToWallet(AssetEntryNo: Integer; WalletEntryNo: Integer): Integer
    var
        AttractionWallet: Record "NPR AttractionWallet";
        WalletAssetLineRef, WalletAssetLineRefSuperseded : Record "NPR WalletAssetLineReference";
        WalletAssetLine: Record "NPR WalletAssetLine";
        Superseded: Boolean;
    begin
        if (not WalletAssetLine.Get(AssetEntryNo)) then
            exit;

        if (not AttractionWallet.Get(WalletEntryNo)) then
            exit;

        WalletAssetLineRef.SetCurrentKey(WalletAssetLineEntryNo, SupersededBy);
        WalletAssetLineRefSuperseded.SetFilter(WalletAssetLineEntryNo, '=%1', AssetEntryNo);
        WalletAssetLineRefSuperseded.SetFilter(SupersededBy, '=%1', 0);
        WalletAssetLineRefSuperseded.SetFilter(WalletEntryNo, '=%1', WalletEntryNo);
        if (not WalletAssetLineRefSuperseded.IsEmpty()) then
            exit; // Asset already added to my wallet

        WalletAssetLineRefSuperseded.SetFilter(WalletEntryNo, '<>%1', WalletEntryNo);
        Superseded := WalletAssetLineRefSuperseded.FindFirst();

        WalletAssetLineRef.EntryNo := 0;
        WalletAssetLineRef.WalletAssetLineEntryNo := WalletAssetLine.EntryNo;
        WalletAssetLineRef.WalletEntryNo := WalletEntryNo;
        WalletAssetLineRef.Insert();

        if (Superseded) then begin
            WalletAssetLineRefSuperseded.SupersededBy := WalletAssetLineRef.EntryNo;
            WalletAssetLineRefSuperseded.Modify();
        end;

        exit(WalletAssetLineRef.EntryNo);
    end;

    local procedure GenerateWalletReference(ReferenceNo: Code[20]): Code[30]
    var
        Setup: Record "NPR WalletAssetSetup";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        if (Setup.ReferencePattern = '') then
            Setup.ReferencePattern := '[S]';

        exit(TicketManagement.GenerateNumberPattern(Setup.ReferencePattern, ReferenceNo));
    end;

    local procedure GenerateWalletExternalReference(ReferenceNo: Code[20]): Text[100]
    var
        Setup: Record "NPR WalletAssetSetup";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        if (Setup.ExtReferencePattern = '') then
            Setup.ExtReferencePattern := '[S][N*1]';

        exit(TicketManagement.GenerateNumberPattern(Setup.ExtReferencePattern, ReferenceNo));
    end;

    local procedure CreateWalletAssetHeader(var WalletAssetHeader: Record "NPR WalletAssetHeader"): boolean
    begin
        if (not IsWalletEnabled()) then
            exit(false);

        WalletAssetHeader.EntryNo := 0;
        WalletAssetHeader.TransactionId := System.CreateGuid();
        exit(WalletAssetHeader.Insert());
    end;

    local procedure PrintWalletsInternal(WalletEntryNoList: List of [Integer]; PrintContext: Enum "NPR WalletPrintType")
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        Handled: Boolean;
    begin
        WalletFacade.OnPrint(WalletEntryNoList, PrintContext, Handled);
        PrintWalletsWorker(WalletEntryNoList, Handled, PrintContext);
    end;

    local procedure PrintWalletsWorker(WalletEntryNoList: List of [Integer]; PrintHandled: Boolean; PrintContext: Enum "NPR WalletPrintType")
    var
        EntryNo: Integer;
        Wallet: Record "NPR AttractionWallet";
    begin
        foreach EntryNo in WalletEntryNoList do begin
            if (not PrintHandled) then
                PrintWalletWorker(EntryNo, PrintContext);

            if (Wallet.Get(EntryNo)) then begin
                Wallet.PrintCount += 1;
                Wallet.LastPrintAt := CurrentDateTime;
                Wallet.Modify();
            end;
        end;
    end;

    local procedure PrintWalletWorker(WalletEntryNo: Integer; PrintContext: Enum "NPR WalletPrintType")
    var
        Wallet: Record "NPR AttractionWallet";
    begin
        if (not Wallet.Get(WalletEntryNo)) then
            exit;

        Wallet.SetRecFilter();

        case PrintContext of
            ENUM::"NPR WalletPrintType"::END_OF_SALE:
                if (Wallet.PrintCount = 0) then
                    Codeunit.Run(Codeunit::"NPR WalletPrintEndOfSale", Wallet);

            ENUM::"NPR WalletPrintType"::WALLET:
                Codeunit.Run(Codeunit::"NPR WalletPrintEndOfSale", Wallet);

            ENUM::"NPR WalletPrintType"::NONE:
                ; // Do nothing

            else
                Error('This is a programming error. Print context is not set');
        end;

    end;

    internal procedure CalculateWalletPrice(WalletTemplate: Record "NPR NpIa Item AddOn"; var WalletPrice: Decimal) PriceCalculated: Boolean
    var
        WalletTemplateLine: Record "NPR NpIa Item AddOn Line";
        Item: Record Item;
        TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
        TicketPrice: Decimal;
    begin
        Clear(WalletPrice);

        if (not WalletTemplate.WalletTemplate) then
            exit(false);

        WalletTemplateLine.SetRange("AddOn No.", WalletTemplate."No.");
        if (WalletTemplateLine.FindSet()) then
            repeat
                if (not WalletTemplateLine.Mandatory) then
                    exit(false);

                if (
                    (WalletTemplateLine."Use Unit Price" = WalletTemplateLine."Use Unit Price"::Always) or
                    (WalletTemplateLine."Unit Price" <> 0)
                ) then begin
                    // Use price from wallet template
                    WalletPrice += AdjustForDiscount(WalletTemplateLine, WalletTemplateLine."Unit Price" * WalletTemplateLine.Quantity);
                end else begin
                    // Use price from item card
                    Item.SetLoadFields("NPR Ticket Type", "Unit Price");
                    Item.Get(WalletTemplateLine."Item No.");
                    if (Item."NPR Ticket Type" <> '') then begin
                        if (TicketDynamicPrice.CalculateRequiredTicketUnitPrice(Item."No.", WalletTemplateLine."Variant Code", TicketPrice)) then
                            WalletPrice += AdjustForDiscount(WalletTemplateLine, TicketPrice * WalletTemplateLine.Quantity)
                        else
                            WalletPrice += AdjustForDiscount(WalletTemplateLine, Item."Unit Price" * WalletTemplateLine.Quantity);
                    end else begin
                        WalletPrice += AdjustForDiscount(WalletTemplateLine, Item."Unit Price" * WalletTemplateLine.Quantity);
                    end;
                end;
            until WalletTemplateLine.Next() = 0;

        exit(true);
    end;

    local procedure AdjustForDiscount(WalletTemplateLine: Record "NPR NpIa Item AddOn Line"; PriceIn: Decimal) NewPrice: Decimal
    begin
        if (WalletTemplateLine."Discount %" = 0) then
            NewPrice := PriceIn - WalletTemplateLine.DiscountAmount
        else
            NewPrice := PriceIn / (1 + WalletTemplateLine."Discount %" / 100);
    end;

    #region facade implementation
    internal procedure CreateWalletFromFacade(OriginatesFromItemNo: Code[20]; Name: Text[100]; var WalletReferenceNumber: Text[50]) WalletEntryNo: Integer
    var
        Wallet: Record "NPR AttractionWallet";
    begin
        if (not IsWalletEnabled()) then
            exit(0);

        CreateWallet(CreateGuid(), OriginatesFromItemNo, Name, Wallet);

        WalletReferenceNumber := Wallet.ReferenceNumber;
        AddHeaderReference(Wallet.EntryNo, Database::"NPR AttractionWallet", Wallet.SystemId, Wallet.ReferenceNumber);

        exit(Wallet.EntryNo);
    end;

    #endregion

}
