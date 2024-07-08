page 6151312 "NPR IT Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'IT Tax Fiscalization Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/italy/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR IT Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("Enable IT Fiscal"; Rec."Enable IT Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Italian Fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable IT Fiscal" <> Rec."Enable IT Fiscal" then
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