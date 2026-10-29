page 6150985 "NPR CMTourBookings"
{
    Extensible = false;
    Caption = 'Tour Bookings';
    PageType = List;
    SourceTable = "NPR CMOrder";
    SourceTableView = sorting(PartnerType, ReceivedAt) order(descending) where(PartnerType = const(TourBooking));
    CardPageId = "NPR CMTourBookingCard";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    Editable = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Booking Reference';
                    ToolTip = 'The booking reference. The customer shows it at pick-up.';
                }
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The order reference we give the customer for the booking. It is unique per channel manager partner.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The state of the booking. It controls how the booking can be handled.';
                    StyleExpr = _StatusStyle;

                    trigger OnDrillDown()
                    begin
                        if (Rec.StatusMessage <> '') then
                            Message(Rec.StatusMessage);
                    end;
                }
                field(SellToCustomerNo; Rec.SellToCustomerNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The customer the booking is for.';
                }
                field(SellToName; Rec.SellToName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The name on the booking.';
                }
                field(SellToEmail; Rec.SellToEmail)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The email address the order confirmation and the wallets are sent to.';
                }
                field(PaymentOption; Rec.PaymentOption)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Whether the booking is prepaid, invoiced or paid at pick-up.';
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The payment reference. For bookings paid at pick-up, it is the POS receipt no. It opens the document the payment is on.';

                    trigger OnDrillDown()
                    var
                        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
                    begin
                        TourBookingMgt.ShowPaymentDocument(Rec);
                    end;
                }
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Created At';
                    ToolTip = 'When the booking was created.';
                }
                field(PartnerName; _PartnerName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Partner';
                    ToolTip = 'The Tour Booking partner the booking belongs to.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewOrder)
            {
                Caption = 'New';
                Image = NewDocument;
                ToolTip = 'Create a new booking and open it.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                trigger OnAction()
                var
                    Order: Record "NPR CMOrder";
                    TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
                    PartnerId: Guid;
                begin
                    if (not TourBookingMgt.SelectTourBookingPartner(PartnerId)) then
                        exit;
                    TourBookingMgt.InitNewOrder(Order, PartnerId);
                    Order.SetRecFilter();
                    Page.Run(Page::"NPR CMTourBookingCard", Order);
                end;
            }
            action(ClearPersonalData)
            {
                Caption = 'Clear Personal Data';
                Image = ClearLog;
                ToolTip = 'Remove the personal data from the selected bookings: the names are cleared and the email addresses are replaced by ones that cannot receive mail. The clear follows through to the tickets and wallets issued from the booking and to its mails, and mails not yet sent are dropped. The booking and payment references are kept. A cancelled booking can be cleared at any time, an issued booking from six months after its last visit. Irreversible.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;

                trigger OnAction()
                var
                    Order: Record "NPR CMOrder";
                    TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
                begin
                    CurrPage.SetSelectionFilter(Order);
                    TourBookingMgt.AnonymizeBookings(Order);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(NewOrder_Promoted; NewOrder) { }
        }
    }

    trigger OnAfterGetRecord()
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        _PartnerName := '';
        if (PartnerSetup.Get(Rec.PartnerId)) then
            _PartnerName := PartnerSetup.Name;

        _StatusStyle := Rec.GetStatusStyle();
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
    begin
        TourBookingMgt.DeleteOrderContent(Rec);
        exit(true);
    end;

    var
        _PartnerName: Text[100];
        _StatusStyle: Text;
}
