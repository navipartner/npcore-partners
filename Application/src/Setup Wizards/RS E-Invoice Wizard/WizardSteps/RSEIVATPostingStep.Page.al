page 6184726 "NPR RS EI VAT Posting Step"
{
    Extensible = False;
    Caption = 'VAT Posting Setup';
    PageType = ListPart;
    SourceTable = "NPR RS EI VAT Post. Setup Map.";
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
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the VAT Bus. Posting Group. for which the mapping is set.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the VAT Prod. Posting Group. for which the mapping is set.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the VAT % field.';
                }
                field("NPR RS EI Tax Category"; Rec."NPR RS EI Tax Category")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the RS Tax Category field.';
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Init")
            {
                ApplicationArea = NPRRSEInvoice;
                Caption = 'Init VAT Posting Setup Lines';
                Image = Start;
                ToolTip = 'Initialize RS VAT Posting Setup Lines Mapping with non existing VAT Posting Setup Lines';
                trigger OnAction()
                var
                    RSEIVATPostSetupMapping: Record "NPR RS EI VAT Post. Setup Map.";
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;
                    VATPostingSetup.FindSet();
                    repeat
                        if not RSEIVATPostSetupMapping.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            RSEIVATPostSetupMapping.Init();
                            RSEIVATPostSetupMapping."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            RSEIVATPostSetupMapping."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            RSEIVATPostSetupMapping.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if RSEIVATPostSetupMap.IsEmpty() then
            exit;
        RSEIVATPostSetupMap.FindSet();
        repeat
            Rec.TransferFields(RSEIVATPostSetupMap);
            if not Rec.Insert() then
                Rec.Modify();
        until RSEIVATPostSetupMap.Next() = 0;
    end;

    internal procedure RSEIVATPostingSetupMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreateRSEIVATPostingMappingData()
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet();
        repeat
            RSEIVATPostSetupMap.TransferFields(Rec);
            if not RSEIVATPostSetupMap.Insert() then
                RSEIVATPostSetupMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            Rec.SetRange("VAT Bus. Posting Group", Rec."VAT Bus. Posting Group");
            Rec.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
            if Rec.FindFirst() then
                if (Rec."NPR RS EI Tax Category" <> Rec."NPR RS EI Tax Category"::" ") then
                    exit(true);
        until Rec.Next() = 0;
    end;

    var
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
}