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
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies internal unique Id of the seating';
                    ApplicationArea = NPRRetail;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies a user friendly id of the seating (table number)';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the value of the Seating Location field';
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
                    ToolTip = 'Specifies the value of the Capacity field';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ToolTip = 'Specifies the value of the Fixed Capasity field';
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
