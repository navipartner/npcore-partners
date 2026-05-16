page 6150939 "NPR CMOrderCard"
{
    Extensible = false;
    Caption = 'Channel Manager Order';
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
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Ticket import Job Id used to mint the order''s tickets.';
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
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Partner''s own order reference.';
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
        }
        area(Processing)
        {
            action(CancelOrder)
            {
                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Destructively empty the order: every ticket, wallet, line and component is hard-deleted (admission capacity freed). The order header remains as a historical record.';
                ApplicationArea = NPRRetail;
                Enabled = CanCancel;

                trigger OnAction()
                var
                    TicketIssuer: Codeunit "NPR CMTicketIssuer";
                    ConfirmCancelQst: Label 'Cancel order ''%1''? All tickets, wallets and order content will be destroyed. Only the order header is kept for audit.', Comment = '%1 = sell-to order reference';
                begin
                    if (not Confirm(ConfirmCancelQst, false, Rec.SellToOrderReference)) then
                        exit;
                    TicketIssuer.DestroyOrderAssets(Rec);
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
        StatusStyle: Text;
}
