table 6014597 "NPR GraphApi Setup"
{
    Access = Internal;
    Caption = 'GraphApi Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Client Id"; Text[50])
        {
            Caption = 'Client Id';
            DataClassification = CustomerContent;
        }
        field(20; "Client Secret"; Text[50])
        {
            Caption = 'Client Secret';
            DataClassification = CustomerContent;
        }
        field(30; "OAuth Authority Url"; Text[100])
        {
            Caption = 'OAuth Authority Url';
            DataClassification = CustomerContent;
        }
        field(40; "OAuth Token Url"; Text[100])
        {
            Caption = 'OAuth Token Url';
            DataClassification = CustomerContent;
        }
        field(50; "Graph Event Url"; Text[100])
        {
            Caption = 'Graph Event Url';
            DataClassification = CustomerContent;
        }
        field(60; "Graph Me Url"; Text[100])
        {
            Caption = 'Graph Me Url';
            DataClassification = CustomerContent;
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
