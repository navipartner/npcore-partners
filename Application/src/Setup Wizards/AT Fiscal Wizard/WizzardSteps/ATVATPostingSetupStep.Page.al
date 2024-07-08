page 6184677 "NPR AT VAT Posting Setup Step"
{
    Extensible = False;
    Caption = 'AT VAT Posting Setup Mapping';
    PageType = ListPart;
    SourceTable = "NPR AT VAT Posting Setup Map";
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
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Identifier for Fiskaly.';
                }
                field("AT VAT Rate"; Rec."AT VAT Rate")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Rate related to the combination of VAT Business and VAT Product Posting Groups which is possible to use in Austria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
    begin
        if not ATVATPostingSetupMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(ATVATPostingSetupMap);
            if not Rec.Insert() then
                Rec.Modify();
        until ATVATPostingSetupMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateVATPostingSetupMappingData()
    var
        ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            ATVATPostingSetupMap.TransferFields(Rec);
            if not ATVATPostingSetupMap.Insert() then
                ATVATPostingSetupMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."VAT Bus. Posting Group" = '') or
                (Rec."VAT Prod. Posting Group" = '') or
                (Rec."VAT Identifier" = '') or
                (Rec."AT VAT Rate" = Rec."AT VAT Rate"::" ")
            then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}