page 6184739 "NPR BE Fiscalisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'BE Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR BE Fiscalisation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field("Enable BE Fiscal"; Rec."Enable BE Fiscal")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Enable BE Fiscalization field.';

                trigger OnValidate()
                begin
                    if xRec."Enable BE Fiscal" <> Rec."Enable BE Fiscal" then
                        EnabledValueChanged := true;
                end;
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