#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6059942 "NPR Entria Store Sync State"
{
    Caption = 'Entria Store Sync State';
    Access = Internal;
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Last Orders Imported At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Store Code")
        {
            Clustered = true;
        }
    }

}
#endif
