table 6059947 "CashKeeper Overview"
{
    // NPR5.43/CLVA/20180620 CASE 319764 Object created

    Caption = 'CashKeeper Overview';

    fields
    {
        field(1;"Transaction No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Transaction No.';
        }
        field(11;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(12;"Total Amount";Decimal)
        {
            Caption = 'Amount';
        }
        field(13;"Value In Cents";Integer)
        {
            Caption = 'Value In Cents';
        }
        field(14;Salesperson;Code[10])
        {
            Caption = 'Salesperson';
        }
        field(15;"User Id";Code[10])
        {
            Caption = 'User Id';
        }
        field(16;"Lookup Timestamp";DateTime)
        {
            Caption = 'Lookup Timestamp';
        }
        field(17;"CashKeeper IP";Text[20])
        {
            Caption = 'CashKeeper IP';
        }
    }

    keys
    {
        key(Key1;"Transaction No.")
        {
        }
    }

    fieldgroups
    {
    }
}

