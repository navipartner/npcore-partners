table 6014536 "NPR Retail List"
{
    Caption = 'Retail List';
    LookupPageID = "NPR Retail List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Number; Integer)
        {
            Caption = 'Number';
            DataClassification = CustomerContent;
        }
        field(2; Choice; Text[246])
        {
            Caption = 'Choice';
            DataClassification = CustomerContent;
        }
        field(3; Chosen; Boolean)
        {
            Caption = 'Chosen';
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
        key(Key1; Number)
        {
        }
    }
}

