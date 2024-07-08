table 6150740 "NPR EFT Planet Integ. Config"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Planet Pax Integration Config';
    Extensible = false;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(2; "Log Level"; Enum "NPR EFT Planet Pax Log Lvl")
        {
            Caption = 'Log level';
            DataClassification = CustomerContent;
        }
    }
}
