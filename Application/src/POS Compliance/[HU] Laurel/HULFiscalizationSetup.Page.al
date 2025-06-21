page 6184826 "NPR HU L Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'HU Laurel Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HU L Fiscalization Setup";
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("HU Laurel Fiscal Enabled"; Rec."HU Laurel Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Laurel Hungarian fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."HU Laurel Fiscal Enabled" <> Rec."HU Laurel Fiscal Enabled" then
                            EnabledValueChanged := true;
                    end;
                }
            }
            group(FiscalSettings)
            {
                Caption = 'Fiscal Settings';
                Visible = Rec."HU Laurel Fiscal Enabled";

                field("HU Laurel Print EFT Information"; Rec."HU L Print EFT Information")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Print EFT Information';
                    ToolTip = 'Specifies whether the EFT information should be printed on the fiscal receipt at the end of sale if there is any EFT information.';
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