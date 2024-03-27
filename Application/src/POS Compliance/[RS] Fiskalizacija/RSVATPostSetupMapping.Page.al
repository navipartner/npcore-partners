page 6150721 "NPR RS VAT Post. Setup Mapping"
{
    ApplicationArea = NPRRSFiscal;
    Caption = 'RS VAT Posting Setup Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/serbia/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS VAT Post. Setup Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(VATPostingSetupMappingLines)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the VAT Bus. Posting Group. for which the mapping is set.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the VAT Prod. Posting Group. for which the mapping is set.';
                }
                field("NPR RS Tax Category Name"; Rec."RS Tax Category Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    DrillDown = true;
                    Lookup = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the RS Tax Category Name that is linked to Allowed Tax Rate that will be used for calculating the VAT amount for transactions related to selected combination of VAT Bus. and VAT Prod. Posting Groups.';
                    trigger OnDrillDown()
                    var
                        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
                        RSAllowedTaxRatesList: Page "NPR RS Allowed Tax Rates List";
                    begin
                        Commit();
                        RSAllowedTaxRatesList.LookupMode := true;
                        RSAllowedTaxRates.FilterGroup(2);
                        Rec.CalcFields("VAT %");
                        RSAllowedTaxRates.SetFilter("Tax Category Rate", '%1', Rec."VAT %");
                        RSAllowedTaxRates.FilterGroup(0);
                        RSAllowedTaxRatesList.SetTableView(RSAllowedTaxRates);
                        if not (RSAllowedTaxRatesList.RunModal() = Action::LookupOK) then
                            exit;
                        RSAllowedTaxRatesList.GetRecord(RSAllowedTaxRates);
                        Rec.Validate("RS Tax Category Label", RSAllowedTaxRates."Tax Category Rate Label");
                        Rec."RS Tax Category Name" := RSAllowedTaxRates."Tax Category Name";
                        Rec.Modify();
                    end;
                }
                field("NPR RS Tax Category Label"; Rec."RS Tax Category Label")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the RS Tax Category Label. The given label will be shown on Fiscal Bills made from transactions that are related to the selected combination of VAT Bus. and VAT Prod. Posting Groups.';
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
                ApplicationArea = NPRRSFiscal;
                Caption = 'Init VAT Posting Setup Lines';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize RS VAT Posting Setup Lines Mapping with non existing VAT Posting Setup Lines';
                trigger OnAction()
                var
                    RSVATPostSetupMapping: Record "NPR RS VAT Post. Setup Mapping";
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;
                    VATPostingSetup.FindSet();
                    repeat
                        if not RSVATPostSetupMapping.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            RSVATPostSetupMapping.Init();
                            RSVATPostSetupMapping."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            RSVATPostSetupMapping."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            RSVATPostSetupMapping.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }
}