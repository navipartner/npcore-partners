page 6150944 "NPR CMOrders"
{
    Extensible = false;
    Caption = 'Channel Manager Orders';
    PageType = List;
    SourceTable = "NPR CMOrder";
    SourceTableView = Sorting(ReceivedAt) Order(Descending);
    CardPageId = "NPR CMOrderCard";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'When the order arrived from the channel partner.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Current lifecycle state of the order.';
                    StyleExpr = StatusStyle;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        if (Rec.StatusMessage <> '') then
                            Message(Rec.StatusMessage);
                    end;
                }
                field(PartnerId; Rec.PartnerId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Channel partner that submitted the order.';
                    Visible = false;
                }
                field(PartnerName; PartnerName)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Partner';
                    ToolTip = 'Name of the channel partner that submitted the order.';
                }
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Partner''s own order reference.';
                }
                field(SellToName; Rec.SellToName)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Customer name on the order.';
                }
                field(SellToEmail; Rec.SellToEmail)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Default customer e-mail address on the order.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Partner''s payment reference.';
                }
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Ticket import Job Id used to mint the order''s tickets.';
                }
                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Server-issued order identifier returned to the channel partner.';
                    Visible = false;
                }
                field(StatusMessage; Rec.StatusMessage)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Detailed message about the order''s current status, useful for troubleshooting.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteOrder)
            {
                Caption = 'Delete Order';
                Image = Delete;
                ToolTip = 'Destructively delete the order: every ticket, wallet, line and component is hard-deleted (admission capacity freed).';
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                var
                    TicketIssuer: Codeunit "NPR CMTicketIssuer";
                    ConfirmDelete: Label 'Delete order ''%1''? All tickets, wallets and order content will be destroyed.', Comment = '%1 = sell-to order reference';
                    InvalidStatus: Label 'Only orders in Cancelled or Error status can be deleted.';
                begin
                    if not (Rec.Status in [Rec.Status::Cancelled, Rec.Status::Error]) then
                        Error(InvalidStatus);

                    if (not Confirm(ConfirmDelete, false, Rec.SellToOrderReference)) then
                        exit;

                    TicketIssuer.DestroyOrderAssets(Rec);
                    Rec.Delete();
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
        if (PartnerSetup.Get(Rec.PartnerId)) then
            PartnerName := PartnerSetup.Name;

        StatusStyle := Rec.GetStatusStyle();
    end;

    var
        PartnerName: Text[100];
        StatusStyle: Text;
}
