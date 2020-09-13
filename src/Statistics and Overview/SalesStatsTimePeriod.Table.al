table 6014586 "NPR Sales Stats Time Period"
{
    // NPR5.52/ZESO/20191010  Object created

    Caption = 'Sales Statistics Time Period';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Sales (Qty)"; Decimal)
        {
            Caption = 'Sales (Qty)';
            DataClassification = CustomerContent;
        }
        field(4; "Sales (LCY)"; Decimal)
        {
            Caption = 'Sales (LCY)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

