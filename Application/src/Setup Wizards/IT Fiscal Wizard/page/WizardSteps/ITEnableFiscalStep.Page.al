page 6184538 "NPR IT Enable Fiscal Step"
{
    Caption = 'IT Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR IT Fiscalization Setup";
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

                field("Enable IT Fiscal"; Rec."Enable IT Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the IT Fiscalization is enabled.';
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
        if not ITFiscalizationSetup.Get() then
            exit;
        ITFiscalizationSetup.TransferFields(Rec);
        ITFiscalizationSetup.Modify()
    end;

    internal procedure CopyRealToTemp()
    begin
        if not ITFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(ITFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure ITSetupToCreate(): Boolean
    begin
        exit(Rec."Enable IT Fiscal");
    end;

    internal procedure CreateITFiscalEnableData()
    begin
        Rec.Get();
        if not ITFiscalizationSetup.Get() then
            ITFiscalizationSetup.Init();
        ITFiscalizationSetup."Enable IT Fiscal" := Rec."Enable IT Fiscal";
        if not ITFiscalizationSetup.Insert() then
            ITFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable IT Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        ITFiscalizationSetup: Record "NPR IT Fiscalization Setup";
}