table 6150922 "NPR HU L Fiscalization Setup"
{
    Access = Internal;
    Caption = 'HU Laurel Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L Fiscalization Setup";
    LookupPageId = "NPR HU L Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "HU Laurel Fiscal Enabled"; Boolean)
        {
            Caption = 'HU Laurel Fiscalization Enabled';
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