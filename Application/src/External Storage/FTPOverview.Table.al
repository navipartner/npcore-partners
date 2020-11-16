table 6184881 "NPR FTP Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Overview';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Host Code"; Code[10])
        {
            Caption = 'FTP Host Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR FTP Setup".Code;
        }
        field(10; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Host Code", "File Name", Name)
        {
        }
    }

    fieldgroups
    {
    }
}

