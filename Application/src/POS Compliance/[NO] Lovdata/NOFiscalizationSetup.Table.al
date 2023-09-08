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
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}