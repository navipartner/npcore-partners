page 6151363 "NPR MS HU Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'HU MultiSoft/NaviPartner EInvoice Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/hungary/how-to/setup/';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HU MS Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable HU Fiscal"; Rec."Enable HU Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable HU Fiscalization field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable HU Fiscal" <> Rec."Enable HU Fiscal" then
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