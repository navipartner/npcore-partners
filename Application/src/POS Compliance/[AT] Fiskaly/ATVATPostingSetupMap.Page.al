page 6184632 "NPR AT VAT Posting Setup Map"
{
    ApplicationArea = NPRATFiscal;
    Caption = 'AT VAT Posting Setup Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/austria/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT VAT Posting Setup Map";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the VAT Bus. Posting Group.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the VAT Prod. Posting Group.';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the VAT Identifier for Fiskaly.';
                }
                field("AT VAT Rate"; Rec."AT VAT Rate")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the VAT Rate related to the combination of VAT Business and VAT Product Posting Groups which is possible to use in Austria.';
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
                ApplicationArea = NPRATFiscal;
                Caption = 'Init VAT Posting Setup';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize AT VAT Posting Setup Mapping with non existing VAT Posting Setups.';

                trigger OnAction()
                var
                    ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;

                    VATPostingSetup.FindSet();

                    repeat
                        if not ATVATPostingSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            ATVATPostingSetupMap.Init();
                            ATVATPostingSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            ATVATPostingSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            ATVATPostingSetupMap."VAT Identifier" := VATPostingSetup."VAT Identifier";
                            ATVATPostingSetupMap.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }
}