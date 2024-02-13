page 6151342 "NPR CRO Enable Fiscal Step"
{
    Caption = 'CRO Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR CRO Fiscalization Setup";
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

                field("Enable CRO Fiscal"; Rec."Enable CRO Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the CRO Fiscalization is enabled.';
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
        if not CROFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(CROFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CROSetupToCreate(): Boolean
    begin
        exit(Rec."Enable CRO Fiscal");
    end;

    internal procedure CreateCROFiscalEnableData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not CROFiscalizationSetup.FindFirst() then
            CROFiscalizationSetup.Init();
        CROFiscalizationSetup."Enable CRO Fiscal" := Rec."Enable CRO Fiscal";
        if not CROFiscalizationSetup.Insert() then
            CROFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable CRO Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
}
