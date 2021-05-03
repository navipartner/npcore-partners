table 6150662 "NPR NPRE Seat.: WaiterPadLink"
{
    Caption = 'Seating - Waiter Pad Link';
    DataClassification = CustomerContent;

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
        }
        field(11; "No. Of Seating For Waiter Pad"; Integer)
        {
            Caption = 'No. Of Seating For Waiter Pad';
            DataClassification = CustomerContent;
        }
        field(12; "Seating Description FF"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Seating".Description WHERE(Code = FIELD("Seating Code")));
            Caption = 'Seating Description';
            FieldClass = FlowField;
        }
        field(13; "Waiter Pad Description FF"; Text[50])
        {
            CalcFormula = Lookup("NPR NPRE Waiter Pad".Description WHERE("No." = FIELD("Waiter Pad No.")));
            Caption = 'Waiter Pad Description';
            FieldClass = FlowField;
        }
        field(20; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
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
