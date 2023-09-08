table 6059835 "NPR SI Fiscalization Setup"
{
    Access = Internal;
    Caption = 'SI Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SI Fiscalization Setup";
    LookupPageId = "NPR SI Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable SI Fiscal"; Boolean)
        {
            Caption = 'Enable SI Fiscalisation';
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