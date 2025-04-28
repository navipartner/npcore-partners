page 6184942 "NPR HU L VAT Post. Setup Mapp."
{
    ApplicationArea = NPRHULaurelFiscal;
    Caption = 'HU Laurel VAT Posting Setup Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L VAT Post. Setup Mapp.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(VATPostingSetupMappingLines)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the VAT Bus. Posting Group. for which the mapping is set.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the VAT Prod. Posting Group. for which the mapping is set.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the VAT % field.';
                }
                field("Laurel VAT Index"; Rec."Laurel VAT Index")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Laurel VAT Index field.';
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
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Init VAT Posting Setup Lines';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize HU Laurel VAT Posting Setup Lines Mapping with non existing VAT Posting Setup Lines';
                trigger OnAction()
                var
                    HULVATPostSetupMapping: Record "NPR HU L VAT Post. Setup Mapp.";
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;
                    VATPostingSetup.FindSet();
                    repeat
                        if not HULVATPostSetupMapping.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            HULVATPostSetupMapping.Init();
                            HULVATPostSetupMapping."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            HULVATPostSetupMapping."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            HULVATPostSetupMapping.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }
}