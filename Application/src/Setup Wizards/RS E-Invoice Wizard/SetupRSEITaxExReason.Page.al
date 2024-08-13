page 6184723 "NPR Setup RS EI Tax Ex. Reason"
{
    Caption = 'Setup RS E-Invoice Tax Exemption Reasons';
    Extensible = false;
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            // Banners
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesStandard.Media Reference field';
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesDone.Media Reference field';
                }
            }

            // Introduction Step
            group(IntroStep)
            {
                Visible = IntroStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to RS EI Tax Exemption Reasons Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Configure your tax exemption reasons to ensure accurate and compliant invoicing. By setting up these reasons, you can properly account for any tax exemptions that apply to your transactions. ';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to start the process.';
                    }
                }
            }

            // RS EI Tax Exemption Reason Setup
            group(SetupTaxExemptionReasonsStep)
            {
                Visible = SetupTaxExemptionReasonsStepVisible;
                group(TaxExemptionReasonsStep)
                {
                    ShowCaption = false;
                    Editable = true;
                    InstructionalText = 'In this step, we will retrieve and set up your tax exemption reasons. Use the Get Tax Exemption Reasons action to automatically pull the necessary records from SEF and populate the fields. This will help ensure that your tax exemption details are accurate and up to date.';
                    part(RSEITaxExemptionReasonsSetupStep; "NPR RS EI Tax Ex. Reasons Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            // Finish Step
            group(Finish)
            {
                Visible = FinishStepVisible;
                group(FinishTxt)
                {
                    Caption = 'Finish';
                    InstructionalText = 'That was the last step of this wizard.';
                }
                group(NotAllMandatoryDataFilledInMsg)
                {
                    Caption = ' ';
                    InstructionalText = 'VAT Posting Setup Incomplete: It seems no combinations have been entered into the Setup record. Please revisit the previous steps and ensure you have entered the necessary VAT Posting Setup combinations before proceeding.';
                    Visible = not RSEITaxExemptionDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = RSEITaxExemptionDataToCreate;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action';
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }
    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        CheckIsRSEInvoicingEnabled();
        Step := Step::Start;
        EnableControls();
    end;

    local procedure CheckIsRSEInvoicingEnabled()
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        RSEInvoicingNotEnabledMsg: Label 'RS E-Invoicing should be enabled in order to proceed with other setups.';
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            Error(RSEInvoicingNotEnabledMsg);
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        BackActionEnabled: Boolean;
        RSEITaxExemptionDataToCreate: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupTaxExemptionReasonsStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,SetupPOSAuditProfileStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupPOSAuditProfileStep:
                ShowSetupVATPostingSetupStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
    end;

    local procedure ShowSetupVATPostingSetupStep()
    begin
        CurrPage.RSEITaxExemptionReasonsSetupStep.Page.CopyRealToTemp();
        SetupTaxExemptionReasonsStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSEITaxExemptionDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSEITaxExemptionDataToCreate := CurrPage.RSEITaxExemptionReasonsSetupStep.Page.RSEITaxExemptionReasonSetupMappingDataToCreate();
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEITaxExemptionReasonsSetupStep.Page.CreateRSEITaxExemptionReasonMappingData();
        OnAfterFinishStep(RSEITaxExemptionDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        SetupTaxExemptionReasonsStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}
