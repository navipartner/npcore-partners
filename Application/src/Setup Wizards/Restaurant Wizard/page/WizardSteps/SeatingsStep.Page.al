page 6150885 "NPR Seatings Step"
{
    Extensible = False;
    Caption = 'Seatings';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Seating";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the current status of the seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies a user friendly id of the seating (table number)';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating.';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the seating is blocked. Waiter pads cannot be created for blocked locations.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the location this seating is created at.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR NPRE Seating Location", TempSeatingLocation_) = Action::LookupOK then begin
                            Rec."Seating Location" := TempSeatingLocation_.Code;
                        end;
                    end;
                }
                field(Capacity; Rec.Capacity)
                {
                    ToolTip = 'Specifies the current capacity of the table, that is the number of guests, which actually can be seated at the table without rearranging/borrowing chairs from other seatings.';
                    ApplicationArea = NPRRetail;
                }
                field("Min Party Size"; Rec."Min Party Size")
                {
                    ToolTip = 'Specifies the minimal number of guests allowed for the table.';
                    ApplicationArea = NPRRetail;
                }
                field("Max Party Size"; Rec."Max Party Size")
                {
                    ToolTip = 'Specifies the maximal number of guests that potentially can be seated at the table, given there are chairs available for borrowing at other tables.';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ToolTip = 'Specifies if the seating has a fixed capacity.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        TempSeatingLocation_: Record "NPR NPRE Seating Location" temporary;

    internal procedure CopyLiveData()
    var
        Seatings: Record "NPR NPRE Seating";
    begin
        Rec.DeleteAll();

        if Seatings.FindSet() then
            repeat
                Rec := Seatings;
                if not Rec.Insert() then
                    Rec.Modify();
            until Seatings.Next() = 0;
    end;

    internal procedure SeatingsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateSeatings()
    var
        Seatings: Record "NPR NPRE Seating";
    begin
        if Rec.FindSet() then
            repeat
                Seatings := Rec;
                if not Seatings.Insert() then
                    Seatings.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempSeatingLocations(var TempSeatingLocation: Record "NPR NPRE Seating Location")
    begin

        If TempSeatingLocation.FindSet() then
            repeat
                TempSeatingLocation_ := TempSeatingLocation;
                if TempSeatingLocation_.Insert() then;
            until TempSeatingLocation.Next() = 0;
    end;
}
