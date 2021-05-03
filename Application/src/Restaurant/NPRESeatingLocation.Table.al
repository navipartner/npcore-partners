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
            Description = 'NPR5.54';
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
        field(30; "Auto Send Kitchen Order"; Option)
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
            Description = 'NPR5.52,NPR5.54';
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(31; "Resend All On New Lines"; Option)
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(40; "Send by Print Category"; Boolean)
        {
            Caption = 'Send by Print Category';
            DataClassification = CustomerContent;
            Description = 'NPR5.53,NPR5.54';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
