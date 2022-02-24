table 6014537 "NPR MobilePayV10 POS"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR MobilePayV10 POS";
    Caption = 'MobilePayV10 POS';

    fields
    {
        field(1; "MobilePay POS ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MobilePay POS ID';
        }
        // TODO: Align with table "NPR MobilePayV10 Unit Setup" where the field has different length.
        field(10; "Merchant POS ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant POS ID';
        }
        field(20; Name; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(30; "Beacon ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Beacon ID';
        }
    }

    keys
    {
        key(PK; "MobilePay POS ID")
        {
            Clustered = true;
        }
    }
}
