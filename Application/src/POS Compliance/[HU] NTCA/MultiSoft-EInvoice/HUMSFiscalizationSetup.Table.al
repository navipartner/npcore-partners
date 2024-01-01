table 6150760 "NPR HU MS Fiscalization Setup"
{
    Access = Internal;
    Caption = 'HU Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR MS HU Fiscalization Setup";
    LookupPageId = "NPR MS HU Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable HU Fiscal"; Boolean)
        {
            Caption = 'Enable HU Fiscalisation';
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