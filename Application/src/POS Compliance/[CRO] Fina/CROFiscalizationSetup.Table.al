table 6060030 "NPR CRO Fiscalization Setup"
{
    Access = Internal;
    Caption = 'CRO Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO Fiscalization Setup";
    LookupPageId = "NPR CRO Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable CRO Fiscal"; Boolean)
        {
            Caption = 'Enable CRO Fiscalisation';
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