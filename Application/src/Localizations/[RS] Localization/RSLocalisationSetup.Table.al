table 6060009 "NPR RS Localisation Setup"
{
    Access = Internal;
    Caption = 'RS Localisation Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS Localisation Setup";
    LookupPageId = "NPR RS Localisation Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable RS Local"; Boolean)
        {
            Caption = 'Enable RS Localisation';
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