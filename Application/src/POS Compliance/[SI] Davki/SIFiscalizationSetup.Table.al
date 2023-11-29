table 6059835 "NPR SI Fiscalization Setup"
{
    Access = Internal;
    Caption = 'SI Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SI Fiscalization Setup";
    LookupPageId = "NPR SI Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable SI Fiscal"; Boolean)
        {
            Caption = 'Enable SI Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(3; "Receipt No. Series"; Code[20])
        {
            Caption = 'Receipt No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "Environment URL"; Text[2048])
        {
            Caption = 'Environment URL';
            DataClassification = CustomerContent;
        }
        field(10; "Signing Certificate"; Blob)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(11; "Signing Certificate Password"; Text[100])
        {
            Caption = 'Signing Certificate Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(12; "Signing Certificate Thumbprint"; Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(13; "Certificate Serial No."; Text[2048])
        {
            Caption = 'Certificate Serial No.';
            DataClassification = CustomerContent;
        }
        field(14; "Certificate Private Key"; Blob)
        {
            Caption = 'Certificate Private Key';
            DataClassification = CustomerContent;
        }
        field(15; "Certificate Subject Ident."; Code[20])
        {
            Caption = 'Certificate Subject Identification';
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