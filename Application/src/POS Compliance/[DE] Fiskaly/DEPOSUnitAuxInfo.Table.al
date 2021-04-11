table 6014532 "NPR DE POS Unit Aux. Info"
{
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
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }
}