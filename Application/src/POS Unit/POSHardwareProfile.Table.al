table 6151176 "NPR POS Hardware Profile"
{
    Caption = 'POS Hardware Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Hardware Profile";
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "IP Address"; Text[25])
        {
            Caption = 'IP Address';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}