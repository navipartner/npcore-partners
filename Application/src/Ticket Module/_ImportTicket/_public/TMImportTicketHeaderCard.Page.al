page 6151358 "NPR TM ImportTicketHeaderCard"
{
    Extensible = true;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR TM ImportTicketHeader";
    Caption = 'Import Tickets Order Archive';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Order';
                field(OrderId; Rec.OrderId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Order ID field.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Payment Reference field.';
                }
                field(SalesDate; Rec.SalesDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Date field.';
                }
                field(TicketHolderEMail; Rec.TicketHolderEMail)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Email Address field.';
                }
                field(TicketHolderName; Rec.TicketHolderName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Holder Name field.';
                }
                group(OrderAmounts)
                {
                    Caption = 'Order Amount';
                    field(CurrencyCode; Rec.CurrencyCode)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Currency Code field.';
                    }
                    field(TotalAmount; Rec.TotalAmount)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Total Amount field.';
                    }
                    field(TotalAmountInclVat; Rec.TotalAmountInclVat)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Total Amount Incl. VAT field.';
                    }
                    field(TotalAmountLcyInclVat; Rec.TotalAmountLcyInclVat)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Total Amount Incl. VAT (LCY) field.';
                    }
                    field(TotalDiscountAmountInclVat; Rec.TotalDiscountAmountInclVat)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Total Discount Amount Incl. VAT field.';
                    }
                }
                group(Reference)
                {
                    Caption = 'Internal References';
                    field(JobId; Rec.JobId)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Job ID field.';
                    }
                    field(TicketRequestToken; Rec.TicketRequestToken)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Request Token field.';
                    }
                    field(SystemCreatedAt; Rec.SystemCreatedAt)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    }
                }
            }
            part(OrderLines; "NPR TM ImportTicketLinePart")
            {
                Caption = 'Order Lines';
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                SubPageLink = OrderId = field(OrderId), JobId = field(JobId);
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Issued Tickets")
            {
                ToolTip = 'Navigate to Ticket List';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Navigate;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    TempTickets: Record "NPR TM Ticket" temporary;
                    TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                begin
                    TicketReservationRequest.Reset();
                    TicketReservationRequest.SetCurrentKey("Session Token ID");
                    TicketReservationRequest.SetFilter("Session Token ID", '=%1', Rec.TicketRequestToken);
                    if (TicketReservationRequest.FindSet()) then
                        repeat
                            Ticket.Reset();
                            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                            if (Ticket.FindSet()) then
                                repeat
                                    TempTickets.TransferFields(Ticket, true);
                                    if (not TempTickets.Insert()) then;
                                until (Ticket.Next() = 0);
                        until (TicketReservationRequest.Next() = 0);

                    Page.Run(Page::"NPR TM Ticket List", TempTickets);
                end;
            }
        }
    }
}