page 6151269 "NPR BG Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'BG Fiscalisation Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/bulgaria/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR BG Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(FiscalIntegrations)
            {
                Caption = 'Fiscal Integrations';

                field("BG SIS Fiscal Enabled"; Rec."BG SIS Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether SIS fiscal integration is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."BG SIS Fiscal Enabled" <> Rec."BG SIS Fiscal Enabled" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(FiscalSettings)
            {
                Caption = 'Fiscal Settings';
                Visible = Rec."BG SIS Fiscal Enabled";

                group(SISFiscalSettings)
                {
                    Caption = 'SIS Fiscal Settings';
                    ShowCaption = false;
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
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        EnabledValueChanged: Boolean;
}