table 6151222 "NPR NpCs Store Stock Setup"
{
    // #416503/MHA /20200818  CASE 416503 Object created

    Caption = 'Collect Store Stock Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Store Stock Enabled"; Boolean)
        {
            Caption = 'Store Stock Enabled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}