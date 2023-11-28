page 6151273 "NPR BG SIS VAT Post. Setup Map"
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG SIS VAT Posting Setup Mapping';
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
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                }
                field("BG SIS VAT Category"; Rec."BG SIS VAT Category")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the BG SIS VAT Category field.';
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