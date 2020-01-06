table 6014586 "Sales Statistics Time Period"
{
    // NPR5.52/ZESO/20191010  Object created

    Caption = 'Sales Statistics Time Period';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Sales (Qty)";Decimal)
        {
            Caption = 'Sales (Qty)';
        }
        field(4;"Sales (LCY)";Decimal)
        {
            Caption = 'Sales (LCY)';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

