page 6184578 "NPR AT Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'AT Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR AT Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("AT Fiscal Enabled"; Rec."AT Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Austrian Fiscalization is enabled.';
                    trigger OnValidate()
                    begin
                        if xRec."AT Fiscal Enabled" <> Rec."AT Fiscal Enabled" then
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