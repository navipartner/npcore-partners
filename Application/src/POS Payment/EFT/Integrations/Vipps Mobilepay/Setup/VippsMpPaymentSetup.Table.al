table 6150755 "NPR Vipps Mp Payment Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Vipps MobilePay Integration Config';
    Extensible = false;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(2; "Log Level"; Enum "NPR Vipps Mp Log Lvl")
        {
            Caption = 'Log level';
            DataClassification = CustomerContent;
        }
    }
}
