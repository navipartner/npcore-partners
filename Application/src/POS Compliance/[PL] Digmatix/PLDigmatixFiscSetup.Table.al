table 6151173 "NPR PL Digmatix Fisc. Setup"
{
    Access = Internal;
    Caption = 'PL Digmatix Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR PL Digmatix Fisc. Setup";
    LookupPageId = "NPR PL Digmatix Fisc. Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Enable PL Fiscal"; Boolean)
        {
            Caption = 'Enable PL Digmatix Fiscalization';
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