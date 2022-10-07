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
                                    Members, Memberships, Membercards, "Ticket Types", "Ticket Admission BOM", TicketItems);

        if not RetailEntertainmentCue.Get() then
            exit;

        Result.Add(Format(RetailEntertainmentCue.FieldNo("Issued Tickets")), Format(RetailEntertainmentCue."Issued Tickets", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Requests")), Format(RetailEntertainmentCue."Ticket Requests", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Schedules")), Format(RetailEntertainmentCue."Ticket Schedules", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Admissions")), Format(RetailEntertainmentCue."Ticket Admissions", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Items)), Format(RetailEntertainmentCue.Items, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Contacts)), Format(RetailEntertainmentCue.Contacts, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Customers)), Format(RetailEntertainmentCue.Customers, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Members)), Format(RetailEntertainmentCue.Members, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Memberships)), Format(RetailEntertainmentCue.Memberships, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(Membercards)), Format(RetailEntertainmentCue.Membercards, 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Types")), Format(RetailEntertainmentCue."Ticket Types", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo("Ticket Admission BOM")), Format(RetailEntertainmentCue."Ticket Admission BOM", 0, 9));
        Result.Add(Format(RetailEntertainmentCue.FieldNo(TicketItems)), Format(RetailEntertainmentCue.TicketItems, 0, 9));
        Page.SetBackgroundTaskResult(Result);
    end;
}
