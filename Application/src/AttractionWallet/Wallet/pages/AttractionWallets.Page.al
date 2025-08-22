page 6185089 "NPR AttractionWallets"
{
    Extensible = False;
    PageType = List;
    Editable = true;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR AttractionWallet";
    SourceTableView = order(descending);
    CardPageId = "NPR AttractionWalletCard";
    Caption = 'Issued Attraction Wallets';
    AdditionalSearchTerms = 'Issued Wallets';
    DeleteAllowed = false;
    InsertAllowed = false;
    ShowFilter = false;

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
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_WalletReference = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    FindWalletAssets(_WalletReference);
                    ShowSelectedWallets();
                end;
            }

            repeater(GroupName)
            {
                Editable = false;
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference Number field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(OriginatesFromItemNo; Rec.OriginatesFromItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Originates From Item No. field.';
                }
                field(PrintCount; Rec.PrintCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Print Count field.';
                }
                field(LastPrintAt; Rec.LastPrintAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Last Print Date field.';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field.';
                }
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the System ID field.';
                    Visible = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
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
                ToolTip = 'Create a new empty Wallet';
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
                    if (not (NewWallet.Get(WalletManager.CreateWalletFromFacade('', '', _WalletReference)))) then
                        exit;

                    FindWalletAssets(_WalletReference);
                    ShowSelectedWallets();
                end;
            }

            action(PrintWallet)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Print Wallet';
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    WalletMgr: Codeunit "NPR AttractionWallet";
                begin
                    WalletMgr.PrintWallet(Rec.EntryNo, Enum::"NPR WalletPrintType"::WALLET);
                end;
            }
        }

        area(Navigation)
        {
            action(Header)
            {
                Caption = 'Headers';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetHeader";
                ToolTip = 'Show All Headers';
                Visible = false;
            }

            action(HeaderRef)
            {
                Caption = 'Header Reference';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetHeaderRef";
                ToolTip = 'Show All Headers Reference';
                Visible = false;
            }

            action(Line)
            {
                Caption = 'Lines';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetLine";
                ToolTip = 'Show All Lines';
                Visible = false;
            }
            action(LineRef)
            {
                Caption = 'Lines Ref';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-AssetLineRef";
                ToolTip = 'Show All Lines Reference';
                Visible = false;
            }
            action(ShowWallet)
            {
                Caption = 'Wallets (raw)';
                Image = Info;
                ApplicationArea = NPRRetail;
                RunObject = Page "NPR TMP-Wallet";
                ToolTip = 'Show Wallet Raw';
                Visible = false;
            }
        }

    }
    var
        _WalletReference: Text[50];
        TempSelectedWallets: Record "NPR AttractionWallet" temporary;

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
        CurrPage.Update(false);
    end;

    local procedure FindWalletAssets(WalletReference: Text[50])
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        AssetLine: Record "NPR WalletAssetLine";
        AssetHeader: Record "NPR WalletAssetHeader";
    begin
        TempSelectedWallets.Reset();
        if (TempSelectedWallets.IsTemporary) then
            TempSelectedWallets.DeleteAll();

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

            Wallet.Reset();

            // if reference is a Wallet or external reference then Assets Held By Wallet
            WalletExternalReference.SetLoadFields(WalletEntryNo);
            if (WalletExternalReference.Get(WalletReference)) then
                Wallet.SetFilter(EntryNo, '=%1', WalletExternalReference.WalletEntryNo)
            else begin
                Wallet.SetCurrentKey(ReferenceNumber);
                Wallet.SetFilter(ReferenceNumber, '=%1', WalletReference);
            end;

            if (Wallet.FindFirst()) then begin
                TempSelectedWallets.TransferFields(Wallet, true);
                TempSelectedWallets.SystemId := Wallet.SystemId;
                if (TempSelectedWallets.Insert()) then;
            end;
        end;
    end;

}