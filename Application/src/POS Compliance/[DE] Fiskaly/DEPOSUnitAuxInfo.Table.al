table 6014532 "NPR DE POS Unit Aux. Info"
{
    Access = Internal;
    Caption = 'DE POS Unit Aux. Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(2; "Cash Register Brand"; Text[50])
        {
            Caption = 'Cash Register Brand';
            Description = 'Cash Register Brand for DE Fiskaly DSFINKV';
            DataClassification = CustomerContent;
        }
        field(3; "Cash Register Model"; Text[50])
        {
            Caption = 'Cash Register Model';
            Description = 'Cash Register Model for DE Fiskaly DSFINKV';
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            Editable = false;
            Description = 'Client ID for DE Fiskaly';
            DataClassification = CustomerContent;
        }
        field(20; "TSS ID"; Guid)
        {
            Caption = 'TSS ID';
            Editable = false;
            Description = 'TSS ID for DE Fiskaly';
            DataClassification = CustomerContent;
        }
        field(30; "Serial Number"; Text[250])
        {
            Caption = 'Serial Number';
            Description = 'Serial Number for DE Fiskaly';
            DataClassification = CustomerContent;
        }
        field(40; "Cash Register Created"; Boolean)
        {
            Caption = 'Cash Register Created';
            Description = 'Is Cash Register Created for DE Fiskaly DSFINVK';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }
}
