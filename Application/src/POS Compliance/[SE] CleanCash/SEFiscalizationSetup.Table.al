table 6150827 "NPR SE Fiscalization Setup."
{
    Access = Internal;
    Caption = 'SE Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SE Fiscalization Setup";
    LookupPageId = "NPR SE Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable SE Fiscal"; Boolean)
        {
            Caption = 'Enable SE Fiscalisation';
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