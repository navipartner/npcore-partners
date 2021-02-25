table 6150685 "NPR NPRE Location Layout"
{
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
    }
}