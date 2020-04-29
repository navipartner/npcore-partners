table 6184498 "Pepper Card Type Fee"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fee';

    fields
    {
        field(10;"Card Type Code";Code[4])
        {
            Caption = 'Card Type Code';
        }
        field(20;"Minimum Amount";Decimal)
        {
            Caption = 'Minimum Amount';
        }
        field(30;"Merchant Fee %";Decimal)
        {
            Caption = 'Merchant Fee %';
            MinValue = 0;
        }
        field(40;"Merchant Fee Amount";Decimal)
        {
            Caption = 'Merchant Fee Amount';
            MinValue = 0;
        }
        field(50;"Customer Surcharge %";Decimal)
        {
            Caption = 'Customer Surcharge %';
            MinValue = 0;
        }
        field(60;"Customer Surcharge Amount";Decimal)
        {
            Caption = 'Customer Surcharge Amount';
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1;"Card Type Code","Minimum Amount")
        {
        }
    }

    fieldgroups
    {
    }
}

