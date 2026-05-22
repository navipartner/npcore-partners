page 6150939 "NPR CMOrderCard"
{
    Extensible = false;
    Caption = 'OTA Channel Manager Order';
    PageType = Card;
    SourceTable = "NPR CMOrder";
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    DataCaptionFields = SellToOrderReference, PaymentReference;
    DataCaptionExpression = Rec.SellToOrderReference + ' / ' + Rec.PaymentReference;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Server-issued order identifier.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Current lifecycle state.';
                    StyleExpr = StatusStyle;
                }
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When the order arrived from the channel partner.';
                }

                field(Manifest; GetManifestLabel())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Manifest';
                    ToolTip = 'Click to open the rendered manifest URL for the order.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if (Rec.ManifestUrl <> '') then
                            Hyperlink(Rec.ManifestUrl);
                    end;
                }
            }
            group(Partner)
            {
                Caption = 'Partner';

                field(PartnerId; Rec.PartnerId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Channel partner that submitted the order.';
                }
                field(PartnerName; PartnerName)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Partner Name';
                    ToolTip = 'Name of the channel partner that submitted the order.';
                }
                field(BuyFromOrderReference; Rec.DocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Server-generated order reference returned to the channel partner. This is the reference that the channel partner uses in subsequent interactions regarding this order, such as ticket status inquiries.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Partner''s payment reference.';
                }
            }
            group(SellTo)
            {
                Caption = 'Sell-to';
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Partner''s own order reference.';
                }
                field(SellToName; Rec.SellToName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Customer name on the order (default for lines).';
                }
                field(SellToEmail; Rec.SellToEmail)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default customer e-mail address (default for line notifications).';
                }
                field(SellToLanguage; Rec.SellToLanguage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default language for line-level notifications.';
                }
            }
            part(Lines; "NPR CMOrderLineSubpage")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Lines';
                SubPageLink = OrderId = field(OrderId);
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Wallets)
            {
                Caption = 'Wallets';
                Image = ItemGroup;
                ToolTip = 'Show all wallets issued for this order.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    OrderWallet: Record "NPR CMOrderWallet";
                begin
                    OrderWallet.SetFilter(OrderId, '=%1', Rec.OrderId);
                    Page.Run(Page::"NPR CMOrderWallets", OrderWallet);
                end;
            }
            action(OpenManifest)
            {
                Caption = 'Designer Manifest';
                Image = SendAsPDF;
                ToolTip = 'Open the NPDesigner manifest record for this order.';
                ApplicationArea = NPRRetail;
                Enabled = HasManifest;

                trigger OnAction()
                var
                    Manifest: Record "NPR NPDesignerManifest";
                begin
                    if (IsNullGuid(Rec.ManifestId)) then
                        exit;
                    Manifest.SetCurrentKey(ManifestId);
                    Manifest.SetFilter(ManifestId, '=%1', Rec.ManifestId);
                    Page.Run(Page::"NPR NPDesignerManifestCard", Manifest);
                end;
            }
        }
        area(Processing)
        {
            action(ManuallyConfirm)
            {
                Caption = 'Manually Confirm';
                Image = Confirm;
                ToolTip = 'Confirm a draft order without an external payment reference. The payment reference is stamped as ''Manually Confirmed''.';
                ApplicationArea = NPRRetail;
                Enabled = CanManuallyConfirm;

                trigger OnAction()
                var
                    OrderIssuer: Codeunit "NPR CMOrderIssuer";
                    ConfirmManualQst: Label 'Manually confirm order ''%1''? The order will be marked as Issued with payment reference ''Manually Confirmed''.', Comment = '%1 = sell-to order reference';
                    ManualPaymentRefLbl: Label 'Manually Confirmed', Locked = true;
                begin
                    if (not Confirm(ConfirmManualQst, false, Rec.SellToOrderReference)) then
                        exit;
                    Rec.PaymentReference := CopyStr(ManualPaymentRefLbl, 1, MaxStrLen(Rec.PaymentReference));
                    Rec.Modify();
                    OrderIssuer.ConfirmOrder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelOrder)
            {
                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Destructively empty the order: every ticket, wallet, line and component is hard-deleted (admission capacity freed). The order header remains as a historical record.';
                ApplicationArea = NPRRetail;
                Enabled = CanCancel;

                trigger OnAction()
                var
                    OrderIssuer: Codeunit "NPR CMOrderIssuer";
                    ConfirmCancelQst: Label 'Cancel order ''%1''? All tickets, wallets and order content will be destroyed. Only the order header is kept for audit.', Comment = '%1 = sell-to order reference';
                begin
                    if (not Confirm(ConfirmCancelQst, false, Rec.SellToOrderReference)) then
                        exit;
                    OrderIssuer.DestroyOrderAssets(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        PartnerName := '';
        StatusStyle := Rec.GetStatusStyle();

        if (PartnerSetup.Get(Rec.PartnerId)) then
            PartnerName := PartnerSetup.Name;

        CanCancel := Rec.Status = Rec.Status::Issued;
        CanManuallyConfirm := Rec.Status = Rec.Status::Draft;
        HasManifest := not IsNullGuid(Rec.ManifestId);
    end;

    local procedure GetManifestLabel(): Text[30]
    var
        ClickToOpen: Label 'Click to open';
    begin
        if (Rec.ManifestUrl = '') then
            exit('');
        exit(ClickToOpen);
    end;

    var
        PartnerName: Text[100];
        CanCancel: Boolean;
        CanManuallyConfirm: Boolean;
        HasManifest: Boolean;
        StatusStyle: Text;
}
