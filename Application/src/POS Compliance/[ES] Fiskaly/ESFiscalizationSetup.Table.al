table 6150838 "NPR ES Fiscalization Setup"
{
    Access = Internal;
    Caption = 'ES Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Fiscalization Setup";
    LookupPageId = "NPR ES Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "ES Fiscal Enabled"; Boolean)
        {
            Caption = 'ES Fiscalization Enabled';
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