page 6185050 "NPR PL Digmatix Fisc. Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'PL Digmatix Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR PL Digmatix Fisc. Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable PL Fiscal"; Rec."Enable PL Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Polish fiscalization is enabled.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable PL Fiscal" <> Rec."Enable PL Fiscal" then
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
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany(); // refresh of experience tier has to be done in order to trigger OnGetEssentialExperienceAppAreas publisher
    end;

    var
        EnabledValueChanged: Boolean;
}