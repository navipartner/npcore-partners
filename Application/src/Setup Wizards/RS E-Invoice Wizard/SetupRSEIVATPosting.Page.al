page 6184721 "NPR Setup RS EI VAT Posting"
{
    Caption = 'Setup RS E-Invoice VAT Posting Setup';
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
                    Caption = 'Welcome to RS EI VAT Posting Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Efficiently establish VAT Posting Setup Mapping with this wizard. Create entries for each unique combination of VAT Product and VAT Business Posting Groups in the upcoming step to ensure accurate and comprehensive VAT reporting.';
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

            // RS EI VAT Posting Setup
            group(SetupVATPostingStep)
            {
                Visible = SetupVATPostingStepVisible;
                group(VATPostingStep)
                {
                    ShowCaption = false;
                    Editable = true;
                    InstructionalText = 'Add VAT Product and VAT Business Posting Group, then select the corresponding Tax Category from the dropdown menu to establish precise configurations.';
                    part(RSEIVATPostingSetupStep; "NPR RS EI VAT Posting Step")
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
                    Visible = not RSPOSAuditDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = RSPOSAuditDataToCreate;
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
        RSPOSAuditDataToCreate: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupVATPostingStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,SetupSetupVATPosting,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupSetupVATPosting:
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
        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowSetupVATPostingSetupStep()
    begin
        CurrPage.RSEIVATPostingSetupStep.Page.CopyRealToTemp();
        SetupVATPostingStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSPOSAuditDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSPOSAuditDataToCreate := CurrPage.RSEIVATPostingSetupStep.Page.RSEIVATPostingSetupMappingDataToCreate();
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEIVATPostingSetupStep.Page.CreateRSEIVATPostingMappingData();
        OnAfterFinishStep(RSPOSAuditDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        SetupVATPostingStepVisible := false;
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
