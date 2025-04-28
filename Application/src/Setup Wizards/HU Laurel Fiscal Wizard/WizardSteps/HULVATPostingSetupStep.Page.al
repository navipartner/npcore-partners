page 6185008 "NPR HUL VAT Posting Setup Step"
{
    Extensible = false;
    Caption = 'HU Laurel VAT Posting Setup';
    PageType = ListPart;
    SourceTable = "NPR HU L VAT Post. Setup Mapp.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(VATPostingSetupMappingLines)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                }
                field("Laurel VAT Index"; Rec."Laurel VAT Index")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Laurel VAT Index field.';
                }
            }
        }
    }
    internal procedure CopyRealToTemp()
    begin
        if not HULVATPostSetupMapp.FindSet() then
            exit;

        repeat
            Rec.TransferFields(HULVATPostSetupMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until HULVATPostSetupMapp.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreateVATPostingSetupMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            HULVATPostSetupMapp.TransferFields(Rec);
            if not HULVATPostSetupMapp.Insert() then
                HULVATPostSetupMapp.Modify();
        until Rec.Next() = 0;
    end;

    var
        HULVATPostSetupMapp: Record "NPR HU L VAT Post. Setup Mapp.";
}