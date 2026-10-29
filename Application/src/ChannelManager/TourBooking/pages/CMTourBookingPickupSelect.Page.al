page 6150987 "NPR CMTourBookingPickupSelect"
{
    Extensible = false;
    Caption = 'Select Booking to Pick Up';
    PageType = List;
    SourceTable = "NPR CMOrder";
    SourceTableTemporary = true;
    SourceTableView = sorting(ReceivedAt) order(descending);
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

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
                    ToolTip = 'The booking reference the customer shows at pick-up.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The state of the booking. It controls how the booking can be handled.';
                    StyleExpr = _StatusStyle;
                }
                field(PartnerName; _PartnerName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Partner';
                    ToolTip = 'The partner the booking belongs to.';
                }
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The order reference we give the customer for the booking. It is unique per channel manager partner.';
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
                    ToolTip = 'The email address on the booking.';
                }
                field(ReceivedAt; Rec.ReceivedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Created At';
                    ToolTip = 'When the booking was created.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        _PartnerName := '';
        PartnerSetup.SetLoadFields(Name);
        if (PartnerSetup.Get(Rec.PartnerId)) then
            _PartnerName := PartnerSetup.Name;

        _StatusStyle := 'Favorable';
        if (Rec.Status = Rec.Status::Draft) then
            _StatusStyle := 'Attention';
    end;

    internal procedure SetOrders(var TempOrder: Record "NPR CMOrder" temporary)
    begin
        Rec.Copy(TempOrder, true);
    end;

    var
        _StatusStyle: Text;
        _PartnerName: Text[100];
}
