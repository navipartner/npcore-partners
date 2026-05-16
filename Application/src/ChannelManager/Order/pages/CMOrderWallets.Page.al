page 6150945 "NPR CMOrderWallets"
{
    Extensible = false;
    Caption = 'Channel Manager Order Wallets';
    PageType = List;
    SourceTable = "NPR CMOrderWallet";
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineNo; Rec.LineNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Order line that issued this wallet.';
                }
                field(SeqNo; Rec.SeqNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Sequence number of the wallet within the order line (1..Quantity).';
                }
                field(WalletEntryNo; Rec.WalletEntryNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Attraction Wallet entry number. Drill down to open the wallet card.';
                    Visible = false;
                }
                field(WalletName; Rec.WalletName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Display name for the wallet.';
                }
                field(ExternalReferenceNumber; Rec.ExternalReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'External reference number assigned by the channel partner.';

                    trigger OnDrillDown()
                    var
                        Wallet: Record "NPR AttractionWallet";
                    begin
                        if (Rec.WalletEntryNo = 0) then
                            exit;
                        if (not Wallet.Get(Rec.WalletEntryNo)) then
                            exit;
                        Page.Run(Page::"NPR AttractionWalletCard", Wallet);
                    end;
                }
                field(UnitPriceExclVat; Rec.UnitPriceExclVat)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Unit price excluding VAT, captured at issue time.';
                }
                field(UnitPriceInclVat; Rec.UnitPriceInclVat)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Unit price including VAT, captured at issue time.';
                }
                field(CurrencyCode; Rec.CurrencyCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Currency code for the captured price.';
                }
                field(IssuedAt; Rec.IssuedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When the wallet was minted.';
                }
                field(Manifest; GetManifestLabel())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Manifest';
                    ToolTip = 'Click to open the rendered manifest URL for this wallet.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if (Rec.ManifestUrl <> '') then
                            Hyperlink(Rec.ManifestUrl);
                    end;
                }
                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Parent order identifier.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenWallet)
            {
                Caption = 'Open Wallet';
                Image = View;
                ToolTip = 'Open the AttractionWallet card for the selected row.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Wallet: Record "NPR AttractionWallet";
                begin
                    if (Rec.WalletEntryNo = 0) then
                        exit;
                    if (not Wallet.Get(Rec.WalletEntryNo)) then
                        exit;
                    Page.Run(Page::"NPR AttractionWalletCard", Wallet);
                end;
            }
        }
    }

    local procedure GetManifestLabel(): Text[30]
    var
        ClickToOpen: Label 'Click to open';
    begin
        if (Rec.ManifestUrl = '') then
            exit('');
        exit(ClickToOpen);
    end;
}
