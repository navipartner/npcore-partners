table 6150685 "NPR NPRE Location Layout"
{
    Access = Internal;
    Caption = 'NPRE Location Layout';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Type; Text[30])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(3; "Seating Location"; Code[10])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location";
        }
        field(5; "Seating No."; Text[20])
        {
            Caption = 'Seating No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; "Frontend Properties"; Blob)
        {
            Caption = 'Frontend Properties';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Key2; "Seating Location", "Seating No.")
        { }
    }
}
