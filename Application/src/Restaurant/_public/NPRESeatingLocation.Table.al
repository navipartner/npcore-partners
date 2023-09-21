table 6150666 "NPR NPRE Seating Location"
{
    Caption = 'Seating Location';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Seating Location";
    LookupPageID = "NPR NPRE Seating Location";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(10; Seatings; Integer)
        {
            CalcFormula = Count("NPR NPRE Seating" WHERE("Seating Location" = FIELD(Code)));
            Caption = 'Seatings';
            FieldClass = FlowField;
        }
        field(11; Seats; Integer)
        {
            CalcFormula = Sum("NPR NPRE Seating".Capacity WHERE("Seating Location" = FIELD(Code)));
            Caption = 'Seats';
            FieldClass = FlowField;
        }
        field(20; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store".Code;
        }
        field(30; "Auto Send Kitchen Order"; Enum "NPR NPRE Auto Send Kitch.Order")
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
        }
        field(31; "Resend All On New Lines"; Enum "NPR NPRE Send All on New Lines")
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
        }
        field(40; "Send by Print Category"; Boolean)
        {
            Caption = 'Send by Print Category';
            DataClassification = CustomerContent;
        }
        field(50; "Default Number of Guests"; Enum "NPR NPRE Default No. of Guests")
        {
            Caption = 'Default Number of Guests';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code") { }
        key(Key2; "Restaurant Code") { }
    }
}
