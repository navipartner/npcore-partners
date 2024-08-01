page 6184660 "NPR RS EI VAT Post. Setup Map."
{
    Caption = 'RS E-Invoice VAT Posting Setup Mapping';
    ApplicationArea = NPRRSEInvoice;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "NPR RS EI VAT Post. Setup Map.";
    Extensible = false;
    AdditionalSearchTerms = 'Serbia E-Invoice VAT Posting Setup Mapping,RS E Invoice VAT Posting Setup Mapping';

    layout
    {
        area(Content)
        {
            repeater(VATPostingSetupMappingLines)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies the VAT Bus. Posting Group. for which the mapping is set.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ToolTip = 'Specifies the VAT Prod. Posting Group. for which the mapping is set.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ToolTip = 'Specifies the value of the VAT % field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("NPR RS EI Tax Category"; Rec."NPR RS EI Tax Category")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the RS Tax Category field.';
                    ApplicationArea = NPRRSEInvoice;
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
                Caption = 'Init VAT Posting Setup Lines';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize RS VAT Posting Setup Lines Mapping with non existing VAT Posting Setup Lines';
                ApplicationArea = NPRRSEInvoice;

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
}