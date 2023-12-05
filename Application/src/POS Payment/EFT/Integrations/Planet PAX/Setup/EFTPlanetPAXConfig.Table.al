table 6060077 "NPR EFT Planet PAX Config"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR EFT Planet PAX Config List";
    Caption = 'Planet Pax Config';
    Extensible = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "Terminal ID"; Code[50])
        {
            Caption = 'Terminal ID';
            DataClassification = CustomerContent;
        }
        field(3; "Location ID"; Code[50])
        {
            Caption = 'Location ID';
            DataClassification = CustomerContent;
        }
        field(4; "Url Endpoint"; Text[300])
        {
            Caption = 'Url Endpoint';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Register No.")
        {
            Clustered = true;
        }
    }
}
