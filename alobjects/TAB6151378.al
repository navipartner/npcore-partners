table 6151378 "CS Field Defaults"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Field Defaults';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Use Case Code"; Code[20])
        {
            Caption = 'Use Case Code';
            DataClassification = CustomerContent;
        }
        field(3; "Field No"; Integer)
        {
            Caption = 'Field No';
            DataClassification = CustomerContent;
        }
        field(10; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Use Case Code", "Field No")
        {
        }
    }

    fieldgroups
    {
    }
}

