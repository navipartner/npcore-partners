table 6184871 "DropBox Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox Overview';

    fields
    {
        field(1;"Account Code";Code[10])
        {
            Caption = 'DropBox Account Code';
            TableRelation = "DropBox API Setup";
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
        key(Key1;"Account Code","File Name",Name)
        {
        }
    }

    fieldgroups
    {
    }
}

