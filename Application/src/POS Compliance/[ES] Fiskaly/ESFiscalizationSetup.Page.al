page 6184588 "NPR ES Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'ES Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR ES Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("ES Fiscal Enabled"; Rec."ES Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Spain Fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."ES Fiscal Enabled" <> Rec."ES Fiscal Enabled" then
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