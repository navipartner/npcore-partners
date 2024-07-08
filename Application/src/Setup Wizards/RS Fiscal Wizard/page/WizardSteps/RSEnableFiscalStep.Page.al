page 6151393 "NPR RS Enable Fiscal Step"
{
    Caption = 'Enable RS Fiscal';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS Fiscalisation Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable RS Fiscal"; Rec."Enable RS Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS Fiscalization field.';
                }
                field("Allow Offline Use"; Rec."Allow Offline Use")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Offline Use field.';
                }
                field(Training; Rec.Training)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Training field.';
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
        if not RSFiscalizationSetup.FindFirst() then
            exit;
        Rec.TransferFields(RSFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure RSSetupToCreate(): Boolean
    begin
        exit(Rec."Enable RS Fiscal");
    end;

    internal procedure CreateRSFiscalEnableData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not RSFiscalizationSetup.FindFirst() then
            RSFiscalizationSetup.Init();
        RSFiscalizationSetup."Enable RS Fiscal" := Rec."Enable RS Fiscal";
        if not RSFiscalizationSetup.Insert() then
            RSFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable RS Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
}
