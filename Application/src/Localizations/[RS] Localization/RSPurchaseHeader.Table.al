table 6060021 "NPR RS Purchase Header"
{
    Caption = 'RS Purchase Header';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table SystemId"; Guid)
        {
            Caption = 'Table SystemId';
            DataClassification = CustomerContent;
        }
        field(6014506; Prepayment; Boolean)
        {
            Caption = 'Prepayment';
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