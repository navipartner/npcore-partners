page 6151273 "NPR BG SIS VAT Post. Setup Map"
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG SIS VAT Posting Setup Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/bulgaria/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS VAT Post. Setup Map";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the VAT Bus. Posting Group.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the VAT Prod. Posting Group.';
                }
                field("BG SIS VAT Category"; Rec."BG SIS VAT Category")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the VAT Category related to the combination of VAT Business and VAT Product Posting Groups which is possible to use in Bulgaria.';
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
                ApplicationArea = NPRBGSISFiscal;
                Caption = 'Init VAT Posting Setup';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize BG SIS VAT Posting Setup Mapping with non existing VAT Posting Setups.';

                trigger OnAction()
                var
                    BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map";
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;

                    VATPostingSetup.FindSet();

                    repeat
                        if not BGSISVATPostSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            BGSISVATPostSetupMap.Init();
                            BGSISVATPostSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            BGSISVATPostSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            BGSISVATPostSetupMap.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }
}