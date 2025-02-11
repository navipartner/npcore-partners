page 6184757 "NPR ES Enable Fiscal Step"
{
    Caption = 'ES Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR ES Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';

                field("ES Fiscal Enabled"; Rec."ES Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the Spain Fiscalization is enabled.';
                }
                field(Live; Rec.Live)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the fiscalization is in live mode or not.';
                }
            }
            group(Endpoints)
            {
                Caption = 'Endpoints';

                field("Test Fiskaly API URL"; Rec."Test Fiskaly API URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL for the test Fiskaly API.';
                }
                field("Live Fiskaly API URL"; Rec."Live Fiskaly API URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL for the live Fiskaly API.';
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';

                field("Simplified Invoice Limit"; Rec."Simplified Invoice Limit")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the limit up to which simplified invoice can be issued.';
                }
                field("Invoice Description"; Rec."Invoice Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the general description of the transactions of the invoice.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            if Rec."Test Fiskaly API URL" = '' then
                Rec."Test Fiskaly API URL" := TestFiskalyAPIURLLbl;
            if Rec."Live Fiskaly API URL" = '' then
                Rec."Live Fiskaly API URL" := LiveFiskalyAPIURLLbl;
            Rec.Insert();
        end;
    end;

    var
        TestFiskalyAPIURLLbl: Label 'https://test.es.sign.fiskaly.com/api/v1/', Locked = true;
        LiveFiskalyAPIURLLbl: Label 'https://live.es.sign.fiskaly.com/api/v1/', Locked = true;

    internal procedure CopyToTemp()
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if not ESFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(ESFiscalizationSetup);
        Rec.SystemId := ESFiscalizationSetup.SystemId;
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."ES Fiscal Enabled" and (Rec."Test Fiskaly API URL" <> '') and (Rec."Live Fiskaly API URL" <> '') and (Rec."Simplified Invoice Limit" <> 0) and (Rec."Invoice Description" <> ''));
    end;

    internal procedure CreateFiscalSetupData()
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if not Rec.Get() then
            exit;

        if not ESFiscalizationSetup.Get() then
            ESFiscalizationSetup.Init();

        ESFiscalizationSetup."ES Fiscal Enabled" := Rec."ES Fiscal Enabled";
        ESFiscalizationSetup."Test Fiskaly API URL" := Rec."Test Fiskaly API URL";
        ESFiscalizationSetup."Live Fiskaly API URL" := Rec."Live Fiskaly API URL";
        ESFiscalizationSetup.Live := Rec.Live;
        ESFiscalizationSetup."Simplified Invoice Limit" := Rec."Simplified Invoice Limit";
        ESFiscalizationSetup."Invoice Description" := Rec."Invoice Description";

        if not ESFiscalizationSetup.Insert() then
            ESFiscalizationSetup.Modify();

        EnableApplicationArea();
    end;

    local procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."ES Fiscal Enabled" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}
