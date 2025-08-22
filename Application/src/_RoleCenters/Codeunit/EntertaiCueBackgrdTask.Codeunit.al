codeunit 6059772 "NPR Entertai. Cue Backgrd Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        RetailEntertainmentCue: Record "NPR Retail Entertainment Cue";
        Result: Dictionary of [Text, Text];
    begin

        RetailEntertainmentCue.SetAutoCalcFields("Issued Tickets", "Ticket Requests", "Ticket Schedules", "Ticket Admissions", Items, Contacts, Customers,
                                    Members, Memberships, Membercards, "Ticket Types", "Ticket Admission BOM", TicketItems, "No. of Sub Pay Req Error", "No. of Sub Req Error",
                                    "No. of Sub Pay Req New", "No. of Sub Pay Req Captured", "No. of Sub Pay Req Rejected", "No. of Sub Req Pending", "No. of Sub Req Confirmed", "No. of Sub Req Rejected",
                                    Coupons,
                                    Vouchers,
                                    IssuedAttractionWalletsCount, AttractionPackageTemplateCount);

        RetailEntertainmentCue.SetRange("Subs. Date Filter", Today());
        if not RetailEntertainmentCue.Get() then
            exit;

        Result.Add(Format(RetailEntertainmentCue.FieldNo("Issued Tickets")), Format(RetailEntertainmentCue."Issued Tickets", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Requests")), Format(RetailEntertainmentCue."Ticket Requests", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Schedules")), Format(RetailEntertainmentCue."Ticket Schedules", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Admissions")), Format(RetailEntertainmentCue."Ticket Admissions", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Types")), Format(RetailEntertainmentCue."Ticket Types", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Admission BOM")), Format(RetailEntertainmentCue."Ticket Admission BOM", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(TicketItems)), Format(RetailEntertainmentCue.TicketItems, 0, 9));

        Result.Add(Format(RetailEntertainmentCue.FieldNo(Items)), Format(RetailEntertainmentCue.Items, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Contacts)), Format(RetailEntertainmentCue.Contacts, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Customers)), Format(RetailEntertainmentCue.Customers, 0, 9));

        Result.Add(Format(RetailEntertainmentCue.FieldNo(Members)), Format(RetailEntertainmentCue.Members, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Memberships)), Format(RetailEntertainmentCue.Memberships, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Membercards)), Format(RetailEntertainmentCue.Membercards, 0, 9));

        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Pay Req Error")), Format(RetailEntertainmentCue."No. of Sub Pay Req Error", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Req Error")), Format(RetailEntertainmentCue."No. of Sub Req Error", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Pay Req New")), Format(RetailEntertainmentCue."No. of Sub Pay Req New", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Pay Req Captured")), Format(RetailEntertainmentCue."No. of Sub Pay Req Captured", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Pay Req Rejected")), Format(RetailEntertainmentCue."No. of Sub Pay Req Rejected", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Req Pending")), Format(RetailEntertainmentCue."No. of Sub Req Pending", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Req Confirmed")), Format(RetailEntertainmentCue."No. of Sub Req Confirmed", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("No. of Sub Req Rejected")), Format(RetailEntertainmentCue."No. of Sub Req Rejected", 0, 9));

        Result.Add(Format(RetailEntertainmentCue.FieldNo(Coupons)), Format(RetailEntertainmentCue.Coupons, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Vouchers)), Format(RetailEntertainmentCue.Vouchers, 0, 9));

        Result.Add(Format(RetailEntertainmentCue.FieldNo(IssuedAttractionWalletsCount)), Format(RetailEntertainmentCue.IssuedAttractionWalletsCount, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(AttractionPackageTemplateCount)), Format(RetailEntertainmentCue.AttractionPackageTemplateCount, 0, 9));

        Page.SetBackgroundTaskResult(Result);
    end;
}
