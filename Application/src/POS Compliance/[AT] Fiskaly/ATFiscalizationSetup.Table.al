table 6150828 "NPR AT Fiscalization Setup"
{
    Access = Internal;
    Caption = 'AT Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT Fiscalization Setup";
    LookupPageId = "NPR AT Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "AT Fiscal Enabled"; Boolean)
        {
            Caption = 'AT Fiscalization Enabled';
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