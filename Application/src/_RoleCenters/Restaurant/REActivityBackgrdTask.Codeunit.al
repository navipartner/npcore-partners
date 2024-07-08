codeunit 6184661 "NPR RE Activity Backgrd Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        RestaurantCue: Record "NPR Restaurant Cue";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        Result: Dictionary of [Text, Text];
        RestaurantFilter: Text;
        SeatingLocationFilter: Text;
        POSUnitFilter: Text;
    begin
        if not RestaurantCue.Get() then
            exit;
        RestaurantCue.SetRange("Date Filter", WorkDate());
        RestaurantCue.SetRange("User ID Filter", UserId);

        if Evaluate(RestaurantFilter, Page.GetBackgroundParameters().Get(RestaurantCue.FieldCaption("Restaurant Filter"))) then
            if RestaurantFilter <> '' then
                RestaurantCue.SetFilter("Restaurant Filter", RestaurantFilter);
        if Evaluate(SeatingLocationFilter, Page.GetBackgroundParameters().Get(RestaurantCue.FieldCaption("Seating Location Filter"))) then
            if SeatingLocationFilter <> '' then
                RestaurantCue.SetFilter("Seating Location Filter", SeatingLocationFilter);
        if Evaluate(POSUnitFilter, Page.GetBackgroundParameters().Get(RestaurantCue.FieldCaption("POS Unit Filter"))) then
            if POSUnitFilter <> '' then
                RestaurantCue.SetFilter("POS Unit Filter", POSUnitFilter);

        if not RestaurantSetup.Get() then
            Clear(RestaurantSetup);
        RestaurantCue.SetRange("Ready Seating Status Filter", RestaurantSetup."Seat.Status: Ready");
        RestaurantCue.SetRange("Occupied Seating Status Filter", RestaurantSetup."Seat.Status: Occupied");
        RestaurantCue.SetRange("Cleaning R. Seat.Status Filter", RestaurantSetup."Seat.Status: Cleaning Required");
        RestaurantCue.SetRange("Reserved Seating Status Filter", RestaurantSetup."Seat.Status: Reserved");
        RestaurantCue.CalcFields("Kitchen Requests - Open", "Seatings: Ready", "Seatings: Occupied", "Seatings: Reserved", "Seatings: Cleaning Required", "Available Seats");
        RecalculateCues(RestaurantCue);

        Result.Add(Format(RestaurantCue.FieldNo("Waiter Pads - Open")), Format(RestaurantCue."Waiter Pads - Open", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Kitchen Requests - Open")), Format(RestaurantCue."Kitchen Requests - Open", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Seatings: Ready")), Format(RestaurantCue."Seatings: Ready", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Seatings: Occupied")), Format(RestaurantCue."Seatings: Occupied", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Seatings: Reserved")), Format(RestaurantCue."Seatings: Reserved", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Seatings: Cleaning Required")), Format(RestaurantCue."Seatings: Cleaning Required", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Available Seats")), Format(RestaurantCue."Available Seats", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Inhouse Guests")), Format(RestaurantCue."Inhouse Guests", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Turnover (LCY)")), Format(RestaurantCue."Turnover (LCY)", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("No. of Sales")), Format(RestaurantCue."No. of Sales", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Total No. of Guests")), Format(RestaurantCue."Total No. of Guests", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Average per Sale (LCY)")), Format(RestaurantCue."Average per Sale (LCY)", 0, 9));
        Result.Add(Format(RestaurantCue.FieldNo("Average per Guest (LCY)")), Format(RestaurantCue."Average per Guest (LCY)", 0, 9));

        Page.SetBackgroundTaskResult(Result);
    end;

    local procedure RecalculateCues(var RestaurantCue: Record "NPR Restaurant Cue")
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSEntryQry: Query "NPR POS Entry with Sales Lines";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
    begin
        RestaurantCue."Turnover (LCY)" := 0;
        RestaurantCue."No. of Sales" := 0;
        RestaurantCue."Total No. of Guests" := 0;

        if RestaurantCue.GetFilter("Date Filter") <> '' then
            POSEntryQry.SetFilter(Posting_Date, RestaurantCue.GetFilter("Date Filter"));
        if RestaurantCue.GetFilter("POS Unit Filter") <> '' then
            POSEntryQry.SetFilter(POS_Unit_No, RestaurantCue.GetFilter("POS Unit Filter"));
        POSEntryQry.SetRange(Type, POSSalesLine.Type::Item);
        POSEntryQry.Open();
        while POSEntryQry.Read() do
            if POSSalesLine.Get(POSEntryQry.POS_Entry_No, POSEntryQry.Line_No) then begin
                RestaurantCue."Turnover (LCY)" += POSSalesLine."Amount Excl. VAT (LCY)";
                if POSEntry.Get(POSSalesLine."POS Entry No.") then
                    if not POSEntry.Mark() then begin
                        POSEntry.Mark(true);
                        RestaurantCue."No. of Sales" += 1;
                        RestaurantCue."Total No. of Guests" += POSEntry."NPRE Number of Guests";
                    end;
            end;
        POSEntryQry.Close();

        if RestaurantCue."Total No. of Guests" <> 0 then
            RestaurantCue."Average per Guest (LCY)" := Round(RestaurantCue."Turnover (LCY)" / RestaurantCue."Total No. of Guests")
        else
            RestaurantCue."Average per Guest (LCY)" := 0;
        if RestaurantCue."No. of Sales" <> 0 then
            RestaurantCue."Average per Sale (LCY)" := Round(RestaurantCue."Turnover (LCY)" / RestaurantCue."No. of Sales")
        else
            RestaurantCue."Average per Sale (LCY)" := 0;

        //Calc inhouse number of guests
        RestaurantCue."Inhouse Guests" := 0;
        RestaurantCue."Waiter Pads - Open" := 0;
        if RestaurantCue.GetFilter("Seating Location Filter") <> '' then
            SeatingWPLinkQry.SetFilter(SeatingLocation, RestaurantCue.GetFilter("Seating Location Filter"));
        SeatingWPLinkQry.SetRange(SeatingClosed, false);
        SeatingWPLinkQry.Open();
        while SeatingWPLinkQry.Read() do
            if WaiterPad.Get(SeatingWPLinkQry.WaiterPadNo) then
                if not WaiterPad.Mark() then begin
                    WaiterPad.Mark(true);
                    RestaurantCue."Inhouse Guests" += SeatingWPLinkQry.NumberOfGuests;
                    RestaurantCue."Waiter Pads - Open" += 1;
                end;
        SeatingWPLinkQry.Close();
    end;
}
