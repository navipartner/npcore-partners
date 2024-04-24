page 6151480 "NPR BG SIS Enable Fiscal Step"
{
    Caption = 'BG SIS Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR BG Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("BG SIS Fiscal Enabled"; Rec."BG SIS Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Fiscalization Enabled';
                    ToolTip = 'Specifies whether SIS fiscal integration is enabled.';
                }
            }
            group(FiscalSettings)
            {
                Caption = 'Fiscal Settings';
                Visible = Rec."BG SIS Fiscal Enabled";

                field("BG SIS on PDF"; Rec."BG SIS on PDF")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'On PDF';
                    ToolTip = 'Specifies whether the fiscal receipt at the end of sale should be printed as PDF or as regular fiscal receipt.';
                }
                field("BG SIS Auto Set Cashier"; Rec."BG SIS Auto Set Cashier")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Auto Set Cashier';
                    ToolTip = 'Specifies whether should try to automatically set cashier in fiscal printer on login.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";

    internal procedure CopyToTemp()
    begin
        if not BGFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(BGFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."BG SIS Fiscal Enabled");
    end;

    internal procedure CreateFiscalSetupData()
    begin
        if not Rec.Get() then
            exit;

        if not BGFiscalizationSetup.Get() then
            BGFiscalizationSetup.Init();

        BGFiscalizationSetup."BG SIS Fiscal Enabled" := Rec."BG SIS Fiscal Enabled";
        BGFiscalizationSetup."BG SIS on PDF" := Rec."BG SIS on PDF";
        BGFiscalizationSetup."BG SIS Auto Set Cashier" := Rec."BG SIS Auto Set Cashier";
        if not BGFiscalizationSetup.Insert() then
            BGFiscalizationSetup.Modify();

        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."BG SIS Fiscal Enabled" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}
