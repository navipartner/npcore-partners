page 6184784 "NPR SE Enable Fiscal Step"
{
    Caption = 'SE Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR SE Fiscalization Setup.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';
                ShowCaption = false;

                field("Enable SE Fiscal"; Rec."Enable SE Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the SE Fiscalization is enabled.';
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

    internal procedure CopyRealToTemp()
    begin
        if not SEFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(SEFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure SESetupToCreate(): Boolean
    begin
        exit(Rec."Enable SE Fiscal");
    end;

    internal procedure CreateSEFiscalEnableData()
    begin
        Rec.Get();
        if not SEFiscalizationSetup.Get() then
            SEFiscalizationSetup.Init();
        SEFiscalizationSetup."Enable SE Fiscal" := Rec."Enable SE Fiscal";
        if not SEFiscalizationSetup.Insert() then
            SEFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable SE Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        SEFiscalizationSetup: Record "NPR SE Fiscalization Setup.";
}