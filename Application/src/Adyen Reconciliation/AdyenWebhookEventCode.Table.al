table 6150875 "NPR Adyen Webhook Event Code"
{
    Access = Internal;

    Caption = 'NP Pay Webhook Event Code';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Event Code"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Event Code';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
