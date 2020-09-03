table 6150666 "NPR NPRE Seating Location"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kintchen order'
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

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
            CalcFormula = Count ("NPR NPRE Seating" WHERE("Seating Location" = FIELD(Code)));
            Caption = 'Seatings';
            FieldClass = FlowField;
        }
        field(11; Seats; Integer)
        {
            CalcFormula = Sum ("NPR NPRE Seating".Capacity WHERE("Seating Location" = FIELD(Code)));
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

    fieldgroups
    {
    }
}

