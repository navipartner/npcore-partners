table 6150909 "NPR BE Fiscalisation Setup"
{
    Access = Internal;
    Caption = 'BE Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BE Fiscalisation Setup";
    LookupPageId = "NPR BE Fiscalisation Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable BE Fiscal"; Boolean)
        {
            Caption = 'Enable BE Fiscalization';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}