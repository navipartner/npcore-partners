page 6184750 "NPR DE VAT Posting Setup Step"
{
    Extensible = False;
    Caption = 'DE VAT Posting Setup Mapping';
    PageType = ListPart;
    SourceTable = "NPR VAT Post. Group Mapper";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Pos. Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Prod. Posting Group.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Bus. Posting Group.';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Identifier for Fiskaly.';
                }
                field("DE VAT Rate"; Rec."Fiskaly VAT Rate Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Rate related to the combination of VAT Business and VAT Product Posting Groups which is possible to use in Austria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        DEVATPostingSetupMap: Record "NPR VAT Post. Group Mapper";
    begin
        if not DEVATPostingSetupMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(DEVATPostingSetupMap);
            if not Rec.Insert() then
                Rec.Modify();
        until DEVATPostingSetupMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateVATPostingSetupMappingData()
    var
        DEVATPostingSetupMap: Record "NPR VAT Post. Group Mapper";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            DEVATPostingSetupMap.TransferFields(Rec);
            if not DEVATPostingSetupMap.Insert() then
                DEVATPostingSetupMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."VAT Bus. Posting Group" = '') or
                (Rec."VAT Prod. Pos. Group" = '') or
                (Rec."VAT Identifier" = '') or
                (Rec."Fiskaly VAT Rate Type" = Rec."Fiskaly VAT Rate Type"::" ")
            then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}