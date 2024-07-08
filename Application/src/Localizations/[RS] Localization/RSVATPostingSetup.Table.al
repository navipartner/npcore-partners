table 6060024 "NPR RS VAT Posting Setup"
{
    Caption = 'RS VAT Posting Setup';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table SystemId"; Guid)
        {
            Caption = 'Table SystemId';
            DataClassification = CustomerContent;
        }
        field(6014413; "Sales Prep. VAT Account"; Code[20])
        {
            Caption = 'Sales Prepayment VAT Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure Save()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure Read(IncSystemId: Guid)
    var
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not Rec.Get(IncSystemId) then begin
            Rec.Init();
            Rec."Table SystemId" := IncSystemId;
        end;
    end;
}