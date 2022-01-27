table 6014558 "NPR RP Data Join Buffer"
{
    Access = Internal;
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0

    Caption = 'Data Join Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Unique Record No."; Integer)
        {
            Caption = 'Unique Record No.';
            DataClassification = CustomerContent;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(4; "Data Item Name"; Text[50])
        {
            Caption = 'Data Item Name';
            DataClassification = CustomerContent;
        }
        field(5; "Join Level"; Integer)
        {
            Caption = 'Join Level';
            DataClassification = CustomerContent;
        }
        field(20; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Unique Record No.", "Data Item Name", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

