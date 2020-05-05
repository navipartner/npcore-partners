table 6184861 "Azure Storage Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Overview';

    fields
    {
        field(1;"Account name";Text[24])
        {
            Caption = 'Azure Account Name';
            TableRelation = "Azure Storage API Setup";
        }
        field(10;"Container Name";Text[63])
        {
            Caption = 'Container Name';
        }
        field(20;"File Name";Text[250])
        {
            Caption = 'File Name';
        }
        field(30;Name;Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Account name","Container Name","File Name",Name)
        {
        }
    }

    fieldgroups
    {
    }
}

