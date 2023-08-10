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
            trigger OnValidate()
            begin
                SetApplicationAreaForNPRRSLocal(Rec."Enable RS Local");
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    internal procedure SetApplicationAreaForNPRRSLocal(EnableAppArea: Boolean)
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.SetRange("Company Name", CompanyName());
        if ApplicationAreaSetup.IsEmpty() then
            exit;
        ApplicationAreaSetup.ModifyAll("NPR RS Local", EnableAppArea);
    end;
}