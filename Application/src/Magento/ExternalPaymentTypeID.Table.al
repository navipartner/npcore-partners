table 6151189 "NPR External Payment Type ID"
{
    Access = Internal;
    Caption = 'External Payment Type Identifier';
    DataClassification = CustomerContent;
    LookupPageId = "NPR External Payment Type IDs";
    DrillDownPageId = "NPR External Payment Type IDs";

    fields
    {
        field(10; "External Payment Type ID"; Text[50])
        {
            Caption = 'External Payment Type ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
#if not BC17
            TableRelation = "NPR Spfy Store".Code;
#endif
        }
        field(30; "Payment Gateway"; Text[250])
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
        }
        field(40; "Credit Card Company"; Text[100])
        {
            Caption = 'Credit Card Company';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "External Payment Type ID")
        {
            Clustered = true;
        }
        key(Key2; "Store Code", "Payment Gateway", "Credit Card Company") { }
    }
}
