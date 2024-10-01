page 6184816 "NPR IRL Enable Fiscal Step"
{
    Caption = 'IRL Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR IRL Fiscalization Setup";
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

                field("Enable IRL Fiscal"; Rec."Enable IRL Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the IRL Fiscalization is enabled.';
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

    trigger OnModifyRecord(): Boolean
    begin
        if not IRLFiscalizationSetup.Get() then
            exit;
        IRLFiscalizationSetup.TransferFields(Rec);
        IRLFiscalizationSetup.Modify()
    end;

    internal procedure CopyRealToTemp()
    begin
        if not IRLFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(IRLFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IRLSetupToCreate(): Boolean
    begin
        exit(Rec."Enable IRL Fiscal");
    end;

    internal procedure CreateIRLFiscalEnableData()
    begin
        Rec.Get();
        if not IRLFiscalizationSetup.Get() then
            IRLFiscalizationSetup.Init();
        IRLFiscalizationSetup."Enable IRL Fiscal" := Rec."Enable IRL Fiscal";
        if not IRLFiscalizationSetup.Insert() then
            IRLFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable IRL Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
}