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