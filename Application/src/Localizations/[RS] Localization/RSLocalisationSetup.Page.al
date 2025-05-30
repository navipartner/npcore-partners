page 6151108 "NPR RS Localisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'RS Localization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR RS Localisation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Enable RS Local"; Rec."Enable RS Local")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS Localisation field.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable RS Local" <> Rec."Enable RS Local" then
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