page 6150986 "NPR CMTourBookingPickupReview"
{
    Extensible = false;
    Caption = 'Pick Up Booking';
    PageType = Card;
    SourceTable = "NPR CMOrder";
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataCaptionExpression = Rec.GetDataCaption();

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Booking';

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
                    ToolTip = 'The email address the wallets are sent to when the booking is paid.';
                }
                field(AmountToPay; _AmountToPay)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Amount to Pay Incl. VAT';
                    ToolTip = 'The amount still to be paid for the booking.';
                    AutoFormatType = 1;
                    Style = Strong;
                }
            }
            part(Lines; "NPR CMTourBookingLines")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Lines';
                SubPageLink = OrderId = field(OrderId);
                Editable = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        OrderLine: Record "NPR CMOrderLine";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        WalletCount: Integer;
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
        CurrencyCode: Code[10];
        ReceiptNo: Code[20];
    begin
        _AmountToPay := 0;
        if (Rec.Status <> Rec.Status::Draft) then
            exit;

        OrderLine.SetFilter(OrderId, '=%1', Rec.OrderId);
        if (OrderLine.FindSet()) then
            repeat
                if (TourBookingMgt.GetLineState(OrderLine, ReceiptNo) = "NPR CMOrderLinePickupState"::Open) then begin
                    TourBookingMgt.GetLineTotals(OrderLine, WalletCount, AmountExclVat, AmountInclVat, CurrencyCode);
                    _AmountToPay += AmountInclVat;
                end;
            until (OrderLine.Next() = 0);
    end;

    var
        _AmountToPay: Decimal;
}
