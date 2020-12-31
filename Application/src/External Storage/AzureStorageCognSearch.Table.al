table 6184862 "NPR Azure Storage Cogn. Search"
{
    Caption = 'Azure Storage Cognitive Search';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Name"; Text[24])
        {
            Caption = 'Azure Account Name';
            DataClassification = CustomerContent;
        }
        field(10; "Search Service Name"; Text[60])
        {
            Caption = 'Search Service Name';
            DataClassification = CustomerContent;
        }
        field(20; Index; Text[60])
        {
            Caption = 'Search Index';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Name", "Search Service Name", Index)
        {
        }
    }

    fieldgroups
    {
    }
}

