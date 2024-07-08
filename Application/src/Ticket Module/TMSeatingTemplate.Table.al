table 6151131 "NPR TM Seating Template"
{
    Access = Internal;
    // //-TM1.45 [322432] Initial Version

    Caption = 'Seating Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Parent Entry No."; Integer)
        {
            Caption = 'Parent Entry No.';
            DataClassification = CustomerContent;
        }
        field(7; Ordinal; Integer)
        {
            Caption = 'Ordinal';
            DataClassification = CustomerContent;
        }
        field(8; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(9; "Indent Level"; Integer)
        {
            Caption = 'Indent Level';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Description 2"; Text[80])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(20; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Node,Leaf';
            OptionMembers = NODE,LEAF;
        }
        field(30; Capacity; Integer)
        {
            Caption = 'Capacity';
            DataClassification = CustomerContent;
        }
        field(40; "Reservation Category"; Option)
        {
            Caption = 'Reservation Category';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Available,Blocked,Membership,External,Internal,Not Visible';
            OptionMembers = NA,AVAILABLE,BLOCKED,MEMBERSHIP,EXTERNAL,INTERNAL,HIDDEN;
        }
        field(50; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(60; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(70; "Seating Code"; Code[20])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
        }
        field(71; ElementId; Integer)
        {
            Caption = 'Element Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Admission Code", Path)
        {
        }
        key(Key3; "Parent Entry No.", Ordinal)
        {
        }
    }

    fieldgroups
    {
    }
}

