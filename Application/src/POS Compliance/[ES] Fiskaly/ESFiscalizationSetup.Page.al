page 6184588 "NPR ES Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'ES Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR ES Fiscalization Setup";
    UsageCategory = Administration;

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
                    trigger OnValidate()
                    begin
                        if xRec."ES Fiscal Enabled" <> Rec."ES Fiscal Enabled" then begin
                            EnabledValueChanged := true;
                            Clear(Rec.Live);
                        end;
                    end;
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

    actions
    {
        area(Navigation)
        {
            action(ESOrganizations)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'ES Organizations';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR ES Organization List";
                ToolTip = 'Opens ES Organizations page.';
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

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        EnabledValueChanged: Boolean;
        TestFiskalyAPIURLLbl: Label 'https://test.es.sign.fiskaly.com/api/v1/', Locked = true;
        LiveFiskalyAPIURLLbl: Label 'https://live.es.sign.fiskaly.com/api/v1/', Locked = true;
}