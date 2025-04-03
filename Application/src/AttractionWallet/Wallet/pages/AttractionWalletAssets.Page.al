page 6184847 "NPR AttractionWalletAssets"
{
    Extensible = False;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR WalletAssetLine";
    //SourceTableView = sorting(LinkToTableId, LinkToSystemId);
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Type field.';
                    Editable = false;
                }

                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                    Editable = false;
                }

                field(LineTypeReference; Rec.LineTypeReference)
                {
                    Caption = 'Asset Reference Number';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Asset Reference field.';
                    Editable = false;
                }

                field(AssetBlocked; _AssetBlocked)
                {
                    Caption = 'Blocked';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Blocked field for the asset in question.';
                    Editable = false;
                }

                field(DocumentNumber; Rec.DocumentNumber)
                {
                    Caption = 'Document Number';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document Number field.';
                    Editable = false;
                }

                field(BundleReferenceNo; _BundleReferenceNumber)
                {
                    Caption = 'Bundle Ref. No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bundle Reference Number field.';
                    Editable = false;
                }
                field(Holder; _WalletHolder)
                {
                    Editable = true;
                    Caption = 'Wallet Reference Number';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Holder field.';
                    trigger OnValidate()
                    var
                        AssetLineRefNew: Record "NPR WalletAssetLineReference";
                        AssetLineRefOriginal: Record "NPR WalletAssetLineReference";
                    begin
                        // Validate reference is a wallet in our list of valid wallets
                        TempWallet.SetCurrentKey(ReferenceNumber);
                        TempWallet.SetFilter(ReferenceNumber, '=%1', CopyStr(_WalletHolder, 1, MaxStrLen(TempWallet.ReferenceNumber)));
                        TempWallet.FindFirst(); // Hard fail on invalid wallet

                        // Get the existing link between wallet and asset
                        TempAssetLineRef.SetCurrentKey(WalletAssetLineEntryNo);
                        TempAssetLineRef.SetFilter(WalletAssetLineEntryNo, '=%1', Rec.EntryNo);
                        TempAssetLineRef.FindFirst(); // Hard fail on missing link

                        // Create a new link between target wallet and asset
                        AssetLineRefNew.Get(TempAssetLineRef.EntryNo);
                        AssetLineRefNew.EntryNo := 0;
                        AssetLineRefNew.WalletEntryNo := TempWallet.EntryNo;
                        AssetLineRefNew.Insert();

                        // Update the existing link to point to the new link to maintain history
                        AssetLineRefOriginal.Get(TempAssetLineRef.EntryNo);
                        AssetLineRefOriginal.SupersededBy := AssetLineRefNew.EntryNo;
                        AssetLineRefOriginal.Modify();

                        // Update the asset in memory to point to the new link
                        TempAssetLineRef.WalletEntryNo := AssetLineRefNew.WalletEntryNo;
                        TempAssetLineRef.Modify();

                        CurrPage.Update(false);
                    end;
                }

                field(TransferControlledBy; Rec.TransferControlledBy)
                {
                    Caption = 'Located Via';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transfer Controlled By field.';
                    Editable = false;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(NavigateToAsset)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to the asset';
                Caption = 'Navigate';
                Image = Navigate;
                Scope = Repeater;
                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    Coupon: Record "NPR NpDc Coupon";
                    MembershipCard: Record "NPR MM Member Card";
                begin
                    case Rec.Type of
                        Rec.Type::TICKET:
                            begin
                                Ticket.GetBySystemId(Rec.LineTypeSystemId);
                                Ticket.SetRecFilter();
                                Page.Run(Page::"NPR TM Ticket List", Ticket);
                            end;
                        Rec.Type::COUPON:
                            begin
                                Coupon.GetBySystemId(Rec.LineTypeSystemId);
                                Coupon.SetRecFilter();
                                Page.Run(Page::"NPR NpDc Coupons", Coupon);
                            end;
                        Rec.Type::MEMBERSHIP:
                            begin
                                MembershipCard.GetBySystemId(Rec.LineTypeSystemId);
                                MembershipCard.SetRecFilter();
                                Page.Run(Page::"NPR MM Member Card List", MembershipCard);
                            end;
                    end;
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        Ticket: Record "NPR TM Ticket";
        BundledAssets: Record "NPR NpIa POSEntryLineBndlAsset";
        BundleId: Record "NPR NpIa POSEntryLineBundleId";
        Wallet: Record "NPR AttractionWallet";
    begin
        _BundleReferenceNumber := '';
        _WalletHolder := '';
        TempAssetLineRef.Reset();
        TempAssetLineRef.SetCurrentKey(WalletAssetLineEntryNo);
        TempAssetLineRef.SetFilter(WalletAssetLineEntryNo, '=%1', Rec.EntryNo);
        TempAssetLineRef.SetFilter(SupersededBy, '=%1', 0);
        if (TempAssetLineRef.FindFirst()) then begin
            if (TempWallet.Get(TempAssetLineRef.WalletEntryNo)) then begin
                _WalletHolder := TempWallet.ReferenceNumber;
                if (TempWallet.Description <> '') then
                    _WalletHolder := TempWallet.Description;
            end else
                if (Wallet.Get(TempAssetLineRef.WalletEntryNo)) then
                    _WalletHolder := Wallet.ReferenceNumber; // This means I am the not the holder of the asset

        end;

        case Rec.Type of
            Rec.Type::TICKET:
                begin
                    if (Ticket.GetBySystemId(Rec.LineTypeSystemId)) then
                        _AssetBlocked := Ticket.Blocked;
                    BundledAssets.SetCurrentKey(AssetTableId, AssetSystemId);
                    BundledAssets.SetFilter(AssetTableId, '=%1', Database::"NPR TM Ticket");
                    BundledAssets.SetFilter(AssetSystemId, '=%1', Rec.LineTypeSystemId);
                    if (BundledAssets.FindFirst()) then
                        if (BundleId.Get(BundledAssets.AppliesToSaleLineId, BundledAssets.Bundle)) then
                            _BundleReferenceNumber := BundleId.ReferenceNumber;
                end;
            else
                _AssetBlocked := false;
        end;
    end;

    internal procedure ShowSelectedAssets(var Wallets: Record "NPR AttractionWallet" temporary)
    var
        AssetLine: Record "NPR WalletAssetLine";
        AssetLineRef: Record "NPR WalletAssetLineReference";
        AssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        AssetHeader: Record "NPR WalletAssetHeader";
    begin
        Rec.Reset();
        if (Rec.IsTemporary) then
            Rec.DeleteAll();

        TempWallet.Reset();
        if (TempWallet.IsTemporary) then
            TempWallet.DeleteAll();

        TempAssetLineRef.Reset();
        if (TempAssetLineRef.IsTemporary) then
            TempAssetLineRef.DeleteAll();

        // Set of Wallets are holders of current assets
        Wallets.Reset();
        if (Wallets.FindSet()) then begin
            repeat
                TempWallet.TransferFields(Wallets, true);
                TempWallet.SystemId := Wallets.SystemId;
                if (TempWallet.Insert()) then;

                AssetLineRef.Reset();
                AssetLineRef.SetCurrentKey(WalletEntryNo);
                AssetLineRef.SetFilter(WalletEntryNo, '=%1', Wallets.EntryNo);
                AssetLineRef.SetFilter(SupersededBy, '=%1', 0);
                if (AssetLineRef.FindSet()) then begin
                    repeat
                        AssetLine.Get(AssetLineRef.WalletAssetLineEntryNo);

                        TempAssetLineRef.TransferFields(AssetLineRef, true);
                        TempAssetLineRef.SystemId := AssetLineRef.SystemId;
                        if (TempAssetLineRef.Insert()) then;

                        Rec.TransferFields(AssetLine, true);
                        Rec.SystemId := AssetLine.SystemId;
                        // Only show non-wallet assets
                        if (AssetLine.Type <> AssetLine.Type::WALLET) then
                            if (Rec.Insert()) then;
                    until (AssetLineRef.Next() = 0);
                end;
            until (Wallets.Next() = 0);
        end;

        // Add those assets wallet was once an owner of.
        // Insert will fail on insert if I am already the holder of the asset
        Wallets.Reset();
        if (Wallets.FindSet()) then begin
            repeat
                AssetHeaderRef.Reset();
                AssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
                AssetHeaderRef.SetFilter(LinkToTableId, '=%1', Database::"NPR AttractionWallet");
                AssetHeaderRef.SetFilter(LinkToSystemId, '=%1', Wallets.SystemId);
                AssetHeaderRef.SetFilter(SupersededBy, '=%1', 0);
                if (AssetHeaderRef.FindSet()) then begin
                    repeat
                        AssetHeader.Get(AssetHeaderRef.WalletHeaderEntryNo);

                        AssetLine.Reset();
                        AssetLine.SetCurrentKey(TransactionId);
                        AssetLine.SetFilter(TransactionId, '=%1', AssetHeader.TransactionId);

                        if (AssetLine.FindSet()) then
                            repeat
                                AssetLineRef.Reset();
                                AssetLineRef.SetCurrentKey(WalletAssetLineEntryNo);
                                AssetLineRef.SetFilter(WalletAssetLineEntryNo, '=%1', AssetLine.EntryNo);
                                AssetLineRef.SetFilter(SupersededBy, '=%1', 0); // current holder
                                if (AssetLineRef.FindFirst()) then begin
                                    TempAssetLineRef.TransferFields(AssetLineRef, true);
                                    TempAssetLineRef.SystemId := AssetLineRef.SystemId;
                                    if (TempAssetLineRef.Insert()) then;
                                end;

                                Rec.TransferFields(AssetLine, true);
                                Rec.SystemId := AssetLine.SystemId;
                                Rec.TransferControlledBy := Enum::"NPR WalletRole"::Owner;
                                // Only show non-wallet assets
                                if (AssetLine.Type <> AssetLine.Type::WALLET) then
                                    if (Rec.Insert()) then;
                            until (AssetLine.Next() = 0);

                    until (AssetHeaderRef.Next() = 0);
                end;
            until (Wallets.Next() = 0);
        end
    end;

    var
        TempAssetLineRef: Record "NPR WalletAssetLineReference" temporary;
        TempWallet: Record "NPR AttractionWallet" temporary;
        _WalletHolder: Text;
        _AssetBlocked: Boolean;
        _BundleReferenceNumber: Text[50];

}