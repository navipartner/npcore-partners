table 6184498 "NPR Pepper Card Type Fee"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fee';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Card Type Code"; Code[4])
        {
            Caption = 'Card Type Code';
            DataClassification = CustomerContent;
        }
        field(20; "Minimum Amount"; Decimal)
        {
            Caption = 'Minimum Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Merchant Fee %"; Decimal)
        {
            Caption = 'Merchant Fee %';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(40; "Merchant Fee Amount"; Decimal)
        {
            Caption = 'Merchant Fee Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50; "Customer Surcharge %"; Decimal)
        {
            Caption = 'Customer Surcharge %';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(60; "Customer Surcharge Amount"; Decimal)
        {
            Caption = 'Customer Surcharge Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "Card Type Code", "Minimum Amount")
        {
        }
    }

    fieldgroups
    {
    }
}

