table 6150806 "NPR Adyen Merchant Account"
{
    Access = Internal;

    Caption = 'Adyen Merchant Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(10; "Company ID"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Company ID';
        }
    }
    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

}
