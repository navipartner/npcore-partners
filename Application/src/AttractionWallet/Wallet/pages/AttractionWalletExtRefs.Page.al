page 6185039 "NPR AttractionWalletExtRefs"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "NPR AttractionWalletExtRef";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(ReferenceRepeater)
            {
                field(ExternalReference; Rec.ExternalReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Reference field.';
                }
                field(BlockedAt; Rec.BlockedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Blocked At field.';
                }
                field(ExpiresAt; Rec.ExpiresAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expires At field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(BlockExternalReference)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Block External Reference';
                ToolTip = 'Running the action will block the selected external reference.';
                Image = CancelLine;

                trigger OnAction()
                var
                    AttractionWallet: Codeunit "NPR AttractionWallet";
                begin
                    AttractionWallet.BlockExternalReference(Rec.ExternalReference);
                    Rec.BlockedAt := CurrentDateTime(); // This is not entirely true...
                    Rec.Modify();
                end;
            }
        }
    }

    internal procedure ShowSelectedWallets(var Wallets: Record "NPR AttractionWallet" temporary)
    var
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
    begin
        Rec.Reset();
        if (Rec.IsTemporary()) then
            Rec.DeleteAll();

        Wallets.Reset();
        if (Wallets.FindSet()) then
            repeat
                WalletExternalReference.Reset();
                WalletExternalReference.SetRange(WalletEntryNo, Wallets.EntryNo);
                if (WalletExternalReference.FindSet()) then
                    repeat
                        Rec.TransferFields(WalletExternalReference, true);
                        Rec.SystemId := WalletExternalReference.SystemId;
                        if (not Rec.Insert()) then;
                    until WalletExternalReference.Next() = 0;
            until Wallets.Next() = 0;
    end;
}