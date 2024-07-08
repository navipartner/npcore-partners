page 6151456 "NPR RS VAT Posting Step"
{
    Extensible = False;
    Caption = 'RS VAT Posting Setup';
    PageType = ListPart;
    SourceTable = "NPR RS VAT Post. Setup Mapping";
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
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field.';
                }
                field("NPR RS Tax Category Name"; Rec."RS Tax Category Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    DrillDown = true;
                    Lookup = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the NPR RS Tax Category Name field.';
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
                    ToolTip = 'Specifies the value of the RS Tax Category Label field.';
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
                ToolTip = 'Initialize RS VAT Posting Setup Lines Mapping with non existing VAT Posting Setup Lines';
                trigger OnAction()
                var
                    VATPostingSetup: Record "VAT Posting Setup";
                begin
                    if VATPostingSetup.IsEmpty() then
                        exit;
                    VATPostingSetup.FindSet();
                    repeat
                        if not Rec.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
                            Rec.Init();
                            Rec."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
                            Rec."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
                            Rec.Insert();
                        end;
                    until VATPostingSetup.Next() = 0;
                end;
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        RSVATPostingSetup.SetRange("VAT Bus. Posting Group", Rec."VAT Bus. Posting Group");
        RSVATPostingSetup.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
        if not RSVATPostingSetup.FindFirst() then
            RSVATPostingSetup.Init();
        RSVATPostingSetup."RS Tax Category Name" := Rec."RS Tax Category Name";
        RSVATPostingSetup."RS Tax Category Label" := Rec."RS Tax Category Label";
        RSVATPostingSetup."VAT Bus. Posting Group" := Rec."VAT Bus. Posting Group";
        RSVATPostingSetup."VAT Prod. Posting Group" := Rec."VAT Prod. Posting Group";
        RSVATPostingSetup.CalcFields("VAT %");
        if not RSVATPostingSetup.Insert() then
            RSVATPostingSetup.Modify();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not RSVATPostingSetup.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSVATPostingSetup);
            if not Rec.Insert() then
                Rec.Modify();
        until RSVATPostingSetup.Next() = 0;
    end;

    internal procedure RSVATPostingSetupMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreateVATPostingMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSVATPostingSetup.TransferFields(Rec);
            if not RSVATPostingSetup.Insert() then
                RSVATPostingSetup.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            RSVATPostingSetup.SetRange("VAT Bus. Posting Group", Rec."VAT Bus. Posting Group");
            RSVATPostingSetup.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
            if RSVATPostingSetup.FindFirst() then
                if (RSVATPostingSetup."RS Tax Category Name" <> '') and (RSVATPostingSetup."RS Tax Category Label" <> '') then
                    exit(true);
        until Rec.Next() = 0;
    end;

    var
        RSVATPostingSetup: Record "NPR RS VAT Post. Setup Mapping";
}