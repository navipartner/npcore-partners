page 6184846 "NPR AttractionWallet"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR AttractionWallet";
    Caption = 'Attraction Wallet';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field(Search; _WalletReference)
            {
                Editable = true;
                Caption = 'Search';
                ApplicationArea = NPRRetail;
                ToolTip = 'Search for Wallet Reference';
                trigger OnValidate()
                begin
                    TempSelectedWallets.Reset();
                    if (TempSelectedWallets.IsTemporary) then
                        TempSelectedWallets.DeleteAll();

                    FindWalletAssets(_WalletReference);
                    ShowSelectedWallets();
                end;
            }
            repeater(GroupName)
            {

                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    Caption = 'Wallet Reference Number';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference Number field.', Comment = '%';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    Editable = true;
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field.', Comment = '%';
                    Editable = true;
                }
            }

            part(Assets; "NPR AttractionWalletAssets")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Assets';
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewWallet)
            {
                ApplicationArea = NPRRetail;
                Caption = 'New Wallet';
                ToolTip = 'Create a new Wallet';
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Page;
                trigger OnAction()
                var
                    WalletManager: Codeunit "NPR AttractionWallet";
                    NewWallet: Record "NPR AttractionWallet";
                begin
                    if (not (NewWallet.Get(WalletManager.AddNewWalletAsLineAsset(Rec)))) then
                        exit;

                    TempSelectedWallets.TransferFields(NewWallet, true);
                    TempSelectedWallets.SystemId := NewWallet.SystemId;
                    TempSelectedWallets.Insert();
                    ShowSelectedWallets();
                end;
            }

            action(AddWallet)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Add Wallet';
                ToolTip = 'Add Existing Wallet';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Page;
                trigger OnAction()
                var
                    Wallet: Record "NPR AttractionWallet";
                    WalletListPage: Page "NPR AttractionWalletList";
                    PageAction: Action;
                begin
                    WalletListPage.LookupMode(true);
                    WalletListPage.Editable(false);
                    PageAction := WalletListPage.RunModal();
                    if (PageAction = Action::LookupOK) then begin
                        WalletListPage.GetRecord(Wallet);
                        TempSelectedWallets.TransferFields(Wallet, true);
                        TempSelectedWallets.SystemId := Wallet.SystemId;
                        TempSelectedWallets.Insert();
                        ShowSelectedWallets();
                    end;

                end;
            }
        }
        area(Navigation)
        {

            action(NavigateToAsset)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Navigate to Asset';
                Caption = 'Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    WalletPage: Page "NPR AttractionWallet";
                begin
                    WalletPage.SetSearch(Rec.ReferenceNumber);
                    WalletPage.Editable(false);
                    WalletPage.Run();
                end;
            }
            action(Header)
            {
                Caption = 'Headers';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetHeader";
                ToolTip = 'Show All Headers';
            }

            action(HeaderRef)
            {
                Caption = 'Header Reference';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetHeaderRef";
                ToolTip = 'Show All Headers Reference';
            }

            action(Line)
            {
                Caption = 'Lines';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetLine";
                ToolTip = 'Show All Lines';
            }
            action(LineRef)
            {
                Caption = 'Lines Ref';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetLineRef";
                ToolTip = 'Show All Lines Reference';
            }
            action(ShowWallet)
            {
                Caption = 'Wallets (raw)';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-Wallet";
                ToolTip = 'Show Wallet Raw';
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.MarkedOnly(true);
        if (_WalletReference <> '') then begin
            FindWalletAssets(_WalletReference);
            ShowSelectedWallets();
        end;
    end;

    var
        _WalletReference: Code[30];
        TempSelectedWallets: Record "NPR AttractionWallet" temporary;

    internal procedure SetSearch(WalletReference: Code[30]);
    begin
        _WalletReference := WalletReference;
    end;

    local procedure ShowSelectedWallets()
    begin
        Rec.Reset();
        Rec.ClearMarks();
        Rec.MarkedOnly(true);

        TempSelectedWallets.Reset();
        if (TempSelectedWallets.FindSet()) then
            repeat
                TempSelectedWallets.Mark(true);
            until (TempSelectedWallets.Next() = 0);

        Rec.Copy(TempSelectedWallets);
        Rec.MarkedOnly(true);

        CurrPage.Assets.Page.ShowSelectedAssets(TempSelectedWallets);
        CurrPage.Update(false);
    end;

    local procedure FindWalletAssets(WalletReference: Code[30])
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        AssetLine: Record "NPR WalletAssetLine";
        AssetHeader: Record "NPR WalletAssetHeader";
    begin
        if (WalletReference <> '') then begin

            // Assets Owned
            WalletAssetHeaderRef.SetCurrentKey(LinkToReference, SupersededBy);
            WalletAssetHeaderRef.SetFilter(LinkToReference, '=%1', WalletReference);
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
                            TempSelectedWallets.TransferFields(Wallet, true);
                            TempSelectedWallets.SystemId := Wallet.SystemId;
                            if (TempSelectedWallets.Insert()) then;
                        until (AssetLine.Next() = 0);
                until (WalletAssetHeaderRef.Next() = 0);
            end;

            // if reference is a Wallet then Assets Held By Wallet
            Wallet.Reset();
            Wallet.SetCurrentKey(ReferenceNumber);
            Wallet.SetFilter(ReferenceNumber, '=%1', WalletReference);
            if (Wallet.FindFirst()) then begin
                TempSelectedWallets.TransferFields(Wallet, true);
                TempSelectedWallets.SystemId := Wallet.SystemId;
                if (TempSelectedWallets.Insert()) then;
            end;
        end;
    end;

}