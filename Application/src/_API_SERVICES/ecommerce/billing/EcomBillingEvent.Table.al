#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6248743 "NPR Ecom Billing Event"
{
    Access = Internal;
    Caption = 'Ecommerce Billing Event';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; Channel; Enum "NPR Ecom Sales Doc Source")
        {
            Caption = 'Channel';
            DataClassification = CustomerContent;
        }
        field(3; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
        }
        field(4; "External No."; Code[20])
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(5; "Event Type"; Enum "NPR Billing Event Type")
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(9; "Registered At"; DateTime)
        {
            Caption = 'Registered At';
            DataClassification = CustomerContent;
        }
        field(10; "Billing Queue Entry No."; BigInteger)
        {
            Caption = 'Billing Queue Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(SK1; Channel, "Store Code", "External No.", "Event Type")
        {
        }
    }
}
#endif
