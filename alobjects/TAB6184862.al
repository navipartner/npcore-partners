table 6184862 "Azure Storage Cognitive Search"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Cognitive Search';

    fields
    {
        field(1;"Account Name";Text[24])
        {
            Caption = 'Azure Account Name';
        }
        field(10;"Search Service Name";Text[60])
        {
            Caption = 'Search Service Name';
        }
        field(20;Index;Text[60])
        {
            Caption = 'Search Index';
        }
        field(30;Description;Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Account Name","Search Service Name",Index)
        {
        }
    }

    fieldgroups
    {
    }
}

