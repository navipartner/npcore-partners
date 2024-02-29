table 6059855 "NPR BG Vision Local. Setup"
{
    Access = Internal;
    Caption = 'BG VISION Localisation Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG VISION Local. Setup";
    LookupPageId = "NPR BG VISION Local. Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable BG VISION Local"; Boolean)
        {
            Caption = 'Enable BG VISION Localisation';
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
