table 6151022 "NPR NPDesignerSetup"

{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'NPDesigner Setup';

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(10; DesignerURL; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Designer URL';
        }

        field(20; ApiAuthorization; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'API Authorization';
        }

        field(30; PublicTicketURL; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Public Ticket URL';
        }

        field(40; PublicOrderURL; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Public Order URL';
        }

        field(50; EnableManifest; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Manifest';
            InitValue = false;
        }
        field(55; AssetsUrl; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Assets URL';
            InitValue = 'https://assets.npretail.com/';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}