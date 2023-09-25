page 6151269 "NPR BG Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'BG Tax Fiscalisation Setup';
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
            group(General)
            {
                Caption = 'General Settings';

                field("Enable BG Fiscal"; Rec."Enable BG Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable BG Fiscalisation field.';
                    trigger OnValidate()
                    begin
                        if xRec."Enable BG Fiscal" <> Rec."Enable BG Fiscal" then
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