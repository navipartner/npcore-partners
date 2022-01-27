table 6150662 "NPR NPRE Seat.: WaiterPadLink"
{
    Access = Internal;
    Caption = 'Seating - Waiter Pad Link';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NPRE Seat.: WaiterPadLink";
    DrillDownPageId = "NPR NPRE Seat.: WaiterPadLink";

    fields
    {
        field(1; "Seating Code"; Code[20])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating".Code;
            ValidateTableRelation = true;
        }
        field(2; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad"."No.";
            ValidateTableRelation = true;
        }
        field(10; "No. Of Waiter Pad For Seating"; Integer)
        {
            Caption = 'No. Of Waiter Pad For Seating';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with a FlowField "No. Of Waiter Pads For Seating"';
        }
        field(11; "No. Of Seating For Waiter Pad"; Integer)
        {
            Caption = 'No. Of Seating For Waiter Pad';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced with a FlowField "No. Of Seatings For Waiter Pad"';
        }
        field(12; "Seating Description FF"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Seating".Description WHERE(Code = FIELD("Seating Code")));
            Caption = 'Seating Description';
            FieldClass = FlowField;
        }
        field(13; "Waiter Pad Description FF"; Text[80])
        {
            CalcFormula = Lookup("NPR NPRE Waiter Pad".Description WHERE("No." = FIELD("Waiter Pad No.")));
            Caption = 'Waiter Pad Description';
            FieldClass = FlowField;
        }
        field(20; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
        }
        field(30; "No. Of Waiter Pads For Seating"; Integer)
        {
            Caption = 'No. Of Waiter Pads For Seating';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seat.: WaiterPadLink" where("Seating Code" = field("Seating Code"), Closed = field(Closed)));
        }
        field(31; "No. Of Seatings For Waiter Pad"; Integer)
        {
            Caption = 'No. Of Seatings For Waiter Pad';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seat.: WaiterPadLink" where("Waiter Pad No." = field("Waiter Pad No."), Closed = field(Closed)));
        }
    }

    keys
    {
        key(Key1; "Seating Code", "Waiter Pad No.")
        {
        }
        key(Key2; Closed)
        {
        }
    }
}
