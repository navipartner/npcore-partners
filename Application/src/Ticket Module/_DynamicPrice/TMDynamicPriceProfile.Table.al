table 6014669 "NPR TM Dynamic Price Profile"
{
    Access = Internal;

    DataClassification = CustomerContent;
    LookupPageId = "NPR TM Dynamic Price Profiles";
    Caption = 'Ticket Price Profile';

    fields
    {
        field(1; ProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Profile Code';
        }
        field(10; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; ProfileCode)
        {
            Clustered = true;
        }
    }

}