table 6014539 "NPR MobilePayV10 Payment Setup"
{
    Caption = 'MobilePayV10 Payment Setup';

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
            Caption = 'POS Unit No.';
        }
        field(10; Environment; Enum "NPR MobilePayV10 Environment")
        {
            DataClassification = CustomerContent;
            Caption = 'Environment';
        }
        field(20; "Merchant VAT Number"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant VAT Number';
        }
        field(30; "Log Level"; Enum "NPR MobilePayV10 Log Level")
        {
            DataClassification = CustomerContent;
            Caption = 'Log Level';
        }
    }

    keys
    {
        key(PK; "Payment Type POS")
        {
            Clustered = true;
        }
    }
}