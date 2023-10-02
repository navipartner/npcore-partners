table 6060060 "NPR NO Fiscalization Setup"
{
    Access = Internal;
    Caption = 'NO Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR NO Fiscalization Setup";
    LookupPageId = "NPR NO Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable NO Fiscal"; Boolean)
        {
            Caption = 'Enable NO Fiscalisation';
            DataClassification = CustomerContent;
        }
        field(10; "Signing Certificate"; Blob)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(11; "Signing Certificate Password"; Text[250])
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
        field(50; "SAF-T Audit File Sender"; Code[20])
        {
            Caption = 'SAF-T Audit File Sender';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(51; "SAF-T Contact No."; Code[20])
        {
            Caption = 'SAF-T Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Employee;
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