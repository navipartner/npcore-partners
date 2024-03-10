page 6151568 "NPR SI Enable Fiscal Step"
{
    Caption = 'SI Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR SI Fiscalization Setup";
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

                field("Enable SI Fiscal"; Rec."Enable SI Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the SI Fiscalization is enabled.';
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
        if not SIFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(SIFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure SISetupToCreate(): Boolean
    begin
        exit(Rec."Enable SI Fiscal");
    end;

    internal procedure CreateSIFiscalEnableData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not SIFiscalizationSetup.FindFirst() then
            SIFiscalizationSetup.Init();
        SIFiscalizationSetup."Enable SI Fiscal" := Rec."Enable SI Fiscal";
        if not SIFiscalizationSetup.Insert() then
            SIFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable SI Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
}