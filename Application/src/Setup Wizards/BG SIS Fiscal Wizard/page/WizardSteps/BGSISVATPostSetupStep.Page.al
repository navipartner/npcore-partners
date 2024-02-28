page 6151515 "NPR BG SIS VAT Post Setup Step"
{
    Extensible = False;
    Caption = 'BG SIS VAT Posting Setup Mapping';
    PageType = ListPart;
    SourceTable = "NPR BG SIS VAT Post. Setup Map";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Bus. Posting Group.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Prod. Posting Group.';
                }
                field("BG SIS VAT Category"; Rec."BG SIS VAT Category")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Category related to the combination of VAT Business and VAT Product Posting Groups which is possible to use in Bulgaria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    begin
        if not BGSISVATPostSetupMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(BGSISVATPostSetupMap);
            if not Rec.Insert() then
                Rec.Modify();
        until BGSISVATPostSetupMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateVATPostingSetupMappingData()
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            BGSISVATPostSetupMap.TransferFields(Rec);
            if not BGSISVATPostSetupMap.Insert() then
                BGSISVATPostSetupMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."VAT Bus. Posting Group" = '') or
                (Rec."VAT Prod. Posting Group" = '') or
                (Rec."BG SIS VAT Category" = Rec."BG SIS VAT Category"::" ")
            then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;

    var
        BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map";
}