table 6060085 "NPR BG Fiscalization Setup"
{
    Access = Internal;
    Caption = 'BG Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG Fiscalization Setup";
    LookupPageId = "NPR BG Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable BG Fiscal"; Boolean)
        {
            Caption = 'Enable BG Fiscalisation';
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