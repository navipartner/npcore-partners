table 6150737 "NPR IT Fiscalization Setup"
{
    Access = Internal;
    Caption = 'IT Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR IT Fiscalization Setup";
    LookupPageId = "NPR IT Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable IT Fiscal"; Boolean)
        {
            Caption = 'Enable IT Fiscalization';
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