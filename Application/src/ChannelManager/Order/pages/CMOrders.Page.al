page 6150944 "NPR CMOrders"
{
    Extensible = false;
    Caption = 'OTA Channel Manager Orders';
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
                field(BuyFromOrderReference; Rec.DocumentNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Server-generated order reference returned to the channel partner. This is the reference that the channel partner uses in subsequent interactions regarding this order, such as ticket status inquiries.';
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
            action(ProcessOrder)
            {
                Caption = 'Process';
                Image = Process;
                ToolTip = 'Process this order now, equivalent to letting the job queue runner pick it up on the next tick. Enabled for orders in Submitted status (initial processing) or Error status (retry after a prior failure).';
                ApplicationArea = NPRRetail;
                Scope = Repeater;
                Enabled = CanProcess;

                trigger OnAction()
                var
                    JQRunner: Codeunit "NPR CMJobQueueRunner";
                begin
                    JQRunner.ReProcessSingleOrder(Rec);
                    Rec.Find();
                    if (Rec.Status = Rec.Status::Error) then
                        Message(Rec.StatusMessage);
                    CurrPage.Update(false);
                end;
            }
            action(AnonymizeOrderAction)
            {
                Caption = 'Clear Personal Data';
                Image = ClearLog;
                ToolTip = 'Remove the personal data from the selected orders: the sell-to and line names are cleared and the e-mail addresses are replaced by ones that cannot receive mail. The clear follows through to the tickets issued from the order and their associated records. The order and payment references are kept. Irreversible.';
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                begin
                    AnonymizeSelected();
                end;
            }
            action(DeleteOrder)
            {
                Caption = 'Delete Order';
                Image = Delete;
                ToolTip = 'Destructively delete the order: every ticket, wallet, line and component is hard-deleted (admission capacity freed).';
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                var
                    OrderIssuer: Codeunit "NPR CMOrderIssuer";
                    ConfirmDelete: Label 'Delete order ''%1''? All tickets, wallets and order content will be destroyed.', Comment = '%1 = sell-to order reference';
                    InvalidStatus: Label 'Only orders in Cancelled or Error status can be deleted.';
                begin
                    if not (Rec.Status in [Rec.Status::Cancelled, Rec.Status::Error]) then
                        Error(InvalidStatus);

                    if (not Confirm(ConfirmDelete, false, Rec.SellToOrderReference)) then
                        exit;

                    OrderIssuer.DestroyOrderAssets(Rec);
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
        CanProcess := Rec.Status in [Rec.Status::Submitted, Rec.Status::Error];
    end;

    var
        PartnerName: Text[100];
        StatusStyle: Text;
        CanProcess: Boolean;


    local procedure AnonymizeSelected()
    var
        Order: Record "NPR CMOrder";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        AffectedAssets: Dictionary of [Guid, Integer];
        OrderAssets: Dictionary of [Guid, Integer];
        SelectedCount: Integer;
        RecordCount: Integer;
        ConfirmClear: Label 'Remove the personal data from %1 selected order(s) and the tickets issued from them?\\This cannot be undone.', Comment = '%1 = the number of orders selected';
        DoneClear: Label 'The personal data was removed from %1 record(s).', Comment = '%1 = the number of records changed';
        NothingToClear: Label 'There was no personal data left to remove.';
    begin
        CurrPage.SetSelectionFilter(Order);
        SelectedCount := Order.Count();
        if (SelectedCount = 0) then
            exit;

        if (not Confirm(ConfirmClear, false, SelectedCount)) then
            exit;

        Order.FindSet();
        repeat
            OrderIssuer.AnonymizeOrder(Order, OrderAssets);
            OrderIssuer.MergeAffectedAssets(OrderAssets, AffectedAssets);
        until (Order.Next() = 0);

        RecordCount := AffectedAssets.Count();

        CurrPage.Update(false);
        if (RecordCount = 0) then
            Message(NothingToClear)
        else
            Message(DoneClear, RecordCount);
    end;
}
