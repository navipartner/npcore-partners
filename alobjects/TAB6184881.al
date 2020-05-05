table 6184881 "FTP Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Overview';

    fields
    {
        field(1;"Host Code";Code[10])
        {
            Caption = 'FTP Host Code';
            TableRelation = "FTP Setup".Code;
        }
        field(10;"File Name";Text[250])
        {
            Caption = 'File Name';
        }
        field(20;Name;Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Host Code","File Name",Name)
        {
        }
    }

    fieldgroups
    {
    }
}

