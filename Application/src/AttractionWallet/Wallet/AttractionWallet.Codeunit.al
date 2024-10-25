codeunit 6185062 "NPR AttractionWallet"
{
    Access = Internal;


    // 1 Wallet Created for any POS Sale
    internal procedure CreateAssetFromPosEntry(POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        WalletEntryNoList: List of [Integer];
    begin

        if (not IsWalletEnabled()) then
            exit;

        POSEntrySalesLine.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        if (not POSEntrySalesLine.FindSet()) then
            exit;

        CreateWallets(1, WalletEntryNoList);
        repeat
            CreateAssets(WalletEntryNoList, POSEntrySalesLine."Document No.", POSEntrySalesLine."Line No.", POSEntrySalesLine."No.", POSEntrySalesLine.Quantity);
        until (POSEntrySalesLine.Next() = 0);
        AddReferencesToWalletFromPosEntry(POSEntry, WalletEntryNoList);

    end;

    // Wallets Created per quantity when source is a Wallet Template Addon
    internal procedure CreateAssetsFromPosSaleLine(POSEntry: Record "NPR POS Entry"; POSSaleLine: Record "NPR POS Sale Line")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        AddOnSaleLine: Record "NPR POS Sale Line";
        WalletEntryNoList: List of [Integer];
    begin
        if (not IsWalletEnabled()) then
            exit;

        SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
        SaleLinePOSAddOn.SetFilter("Register No.", '=%1', POSSaleLine."Register No.");
        SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', POSSaleLine."Sales Ticket No.");
        SaleLinePOSAddOn.SetFilter("Sale Type", '=%1', SaleLinePOSAddOn."Sale Type"::Sale);
        SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', POSSaleLine.Date);
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '=%1', POSSaleLine."Line No.");
        SaleLinePOSAddOn.SetFilter(AddToWallet, '=%1', true);

        if (SaleLinePOSAddOn.FindSet()) then begin
            CreateWallets(POSSaleLine.Quantity, WalletEntryNoList);
            repeat
                AddOnSaleLine.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Sale Line No.");
                CreateAssets(WalletEntryNoList, SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Line No.", SaleLinePOSAddOn.AddOnItemNo, AddOnSaleLine.Quantity);
            until (SaleLinePOSAddOn.Next() = 0);

            AddReferencesToWalletFromPosEntry(POSEntry, WalletEntryNoList);
        end;
    end;

    local procedure AddReferencesToWalletFromPosEntry(POSEntry: Record "NPR POS Entry"; WalletEntryNoList: List of [Integer])
    var
        WalletEntryNo: Integer;
    begin
        foreach WalletEntryNo in WalletEntryNoList do
            AddReferencesToWalletFromPosEntry(POSEntry, WalletEntryNo);
    end;

    local procedure AddReferencesToWalletFromPosEntry(POSEntry: Record "NPR POS Entry"; WalletEntryNo: Integer)
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
            AddPosEntryHeaderReference(WalletAssetHeader.EntryNo, PosEntry);
            AddCustomerHeaderReference(WalletAssetHeader.EntryNo, POSEntry."Customer No.");
            AddCustomerMemberCards(WalletAssetHeader.EntryNo, POSEntry."Customer No.");

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

        if (not Item.Get(SalesItemNo)) then
            exit;

        Quantity := Round(SalesQuantity, 1);

        if (Item."NPR Ticket Type" <> '') then begin
            ReservationRequest.SetCurrentKey("Receipt No.", "Line No.");
            ReservationRequest.SetFilter("Receipt No.", '=%1', SalesTicketNo);
            ReservationRequest.SetFilter("Line No.", '=%1', SaleLineNo);
            ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
            AddTicketAssets(WalletEntryNoList, SalesItemNo, Item.Description, ReservationRequest);
        end;

        WalletCoupon.SetFilter(TriggerOnItemNo, '=%1', SalesItemNo);
        if (WalletCoupon.FindFirst()) then
            AddCouponAssets(WalletEntryNoList, WalletCoupon."Coupon Type", SalesItemNo, Item.Description, Quantity);

        MembershipSalesSetup.SetFilter("No.", '=%1', SalesItemNo);
        MembershipSalesSetup.SetFilter("Business Flow Type", '=%1', MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        if (MembershipSalesSetup.FindFirst()) then begin
            InfoCapture.SetCurrentKey("Receipt No.", "Line No.");
            InfoCapture.SetFilter("Receipt No.", '=%1', SalesTicketNo);
            InfoCapture.SetFilter("Line No.", '=%1', SaleLineNo);
            AddMembershipCardAssets(WalletEntryNoList, SalesItemNo, Item.Description, InfoCapture);
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

    local procedure AddTicketAssets(WalletEntryNoList: List of [Integer]; ItemNo: Code[20]; Description: Text[100]; var ReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
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

                    WalletAssetLine.Init();
                    WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
                    WalletAssetLine.ItemNo := ItemNo;
                    WalletAssetLine.Description := Description;
                    WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
                    WalletAssetLine.Type := ENUM::"NPR WalletLineType"::Ticket;

                    WalletAssetLine.EntryNo := 0;
                    WalletAssetLine.LineTypeSystemId := Ticket.SystemId;
                    WalletAssetLine.LineTypeReference := Ticket."External Ticket No.";
                    WalletAssetLine.Insert();

                    AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
                until (Ticket.Next() = 0);
            end;
        until (ReservationRequest.Next() = 0);
    end;

    local procedure AddCouponAssets(WalletEntryNoList: List of [Integer]; CouponType: Code[20]; ItemNo: Code[20]; Description: Text[100]; SalesQuantity: Decimal)
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

            WalletAssetLine.EntryNo := 0;
            WalletAssetLine.LineTypeSystemId := TempCoupon.SystemId;
            WalletAssetLine.LineTypeReference := TempCoupon."Reference No.";
            WalletAssetLine.Insert();

            AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
        until (TempCoupon.Next() = 0);
    end;

    local procedure AddMembershipCardAssets(WalletEntryNoList: List of [Integer]; ItemNo: Code[20]; Description: Text[100]; var InfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipCard: Record "NPR MM Member Card";

        WalletAssetLine: Record "NPR WalletAssetLine";
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
            if (MembershipCard.FindFirst()) then begin
                WalletAssetLine.Init();
                WalletAssetLine.TransactionId := GetWalletTransactionId(WalletEntryNo);
                WalletAssetLine.ItemNo := ItemNo;
                WalletAssetLine.Description := Description;
                WalletAssetLine.TransferControlledBy := ENUM::"NPR WalletRole"::Holder;
                WalletAssetLine.Type := ENUM::"NPR WalletLineType"::MEMBERSHIP;

                WalletAssetLine.EntryNo := 0;
                WalletAssetLine.LineTypeSystemId := MembershipCard.SystemId;
                WalletAssetLine.LineTypeReference := MembershipCard."External Card No.";
                WalletAssetLine.Insert();
                AddAssetToWallet(WalletAssetLine.EntryNo, WalletEntryNo);
            end;
        until (InfoCapture.Next() = 0);
    end;

    local procedure AddPosEntryHeaderReference(EntryNo: Integer; POSEntry: Record "NPR POS Entry")
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        Clear(WalletAssetHeaderRef);
        WalletAssetHeaderRef.WalletHeaderEntryNo := EntryNo;
        WalletAssetHeaderRef.LinkToTableId := Database::"NPR POS Entry";
        WalletAssetHeaderRef.LinkToSystemId := POSEntry.SystemId;
        WalletAssetHeaderRef.LinkToReference := POSEntry."Document No.";
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

    local procedure CreateOwnerWallet(var WalletAssetHeader: Record "NPR WalletAssetHeader"): Integer
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        CreateWallet(CreateGuid(), Wallet);

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

    local procedure CreateWallets(Quantity: Integer; var WalletEntryNoList: List of [Integer])
    var
        i: Integer;
        Wallet: Record "NPR AttractionWallet";
    begin
        for i := 1 to Quantity do
            WalletEntryNoList.Add(CreateWallet(CreateGuid(), Wallet));
    end;

    local procedure CreateWallet(WalletSystemId: Guid; var Wallet: Record "NPR AttractionWallet"): Integer
    var
        WalletSequenceNumber: Text[30];
    begin
        Wallet.Init();
        Wallet.EntryNo := 0;
        Wallet.SystemId := WalletSystemId;
        if (not Wallet.Insert()) then
            error(GetLastErrorText());

        WalletSequenceNumber := Format(Wallet."EntryNo", 0, 9);
#pragma warning disable AA0139 // PadLeft returns a Text, not a Code[20]
        Wallet.ReferenceNumber := GenerateWalletReference(WalletSequenceNumber.PadLeft(10, '0'));
#pragma warning restore AA0139
        Wallet.Modify();

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

    local procedure GetWalletTransactionId(WalletEntryNo: Integer): Guid
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
        WalletAssetLineRef: Record "NPR WalletAssetLineReference";
        WalletAssetLine: Record "NPR WalletAssetLine";
    begin
        if (not WalletAssetLine.Get(AssetEntryNo)) then
            exit;

        if (not AttractionWallet.Get(WalletEntryNo)) then
            exit;

        WalletAssetLineRef.EntryNo := 0;
        WalletAssetLineRef.WalletAssetLineEntryNo := WalletAssetLine.EntryNo;
        WalletAssetLineRef.WalletEntryNo := WalletEntryNo;
        WalletAssetLineRef.Insert();

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

    internal procedure CreateWalletAssetHeader(var WalletAssetHeader: Record "NPR WalletAssetHeader"): boolean
    begin
        if (not IsWalletEnabled()) then
            exit(false);

        WalletAssetHeader.EntryNo := 0;
        WalletAssetHeader.TransactionId := System.CreateGuid();
        exit(WalletAssetHeader.Insert());
    end;

    local procedure IsWalletEnabled(): boolean
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then
            Setup.Init();

        exit(Setup.Enabled);
    end;
}
