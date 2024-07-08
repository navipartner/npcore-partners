table 6060020 "NPR RS Vendor Posting Group"
{
    Caption = 'RS Vendor Posting Group';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table SystemId"; Guid)
        {
            Caption = 'Table SystemId';
            DataClassification = CustomerContent;
        }
        field(6014400; "Prepayment Account"; Code[20])
        {
            Caption = 'Prepayment Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.CheckGLAccount("Prepayment Account", false, false, GLAccountCategory."Account Category"::Liabilities, GLAccountCategoryMgt.GetCurrentLiabilities());
            end;
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