page 6184809 "NPR Setup FR Audit"
{
    Caption = 'FR Audit Setup';
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
                    Caption = 'Welcome to French Audit Profile Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to customize French Audit Profile settings to ensure adherence to regulatory requirements.';
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

            // Upload Certificate Step
            group(UploadCertificateStep)
            {
                Visible = UploadCertificateStepVisible;
                group(UploadCertificateInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Upload your Fiscal Certificate for secure signing and transmission of fiscal information to authorities.';
                }
                group(UploadFRCertificate)
                {
                    Caption = 'Upload a fiscal certificate';
                    ShowCaption = false;
                    part(FRUploadCertificatePage; "NPR FR Audit Certificate Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // Workshift Setup Step
            group(WorkshiftSetupStep)
            {
                Visible = WorkshiftSetupStepVisible;
                group(WorkshiftSetupInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Configure your workshift settings, including start and end times, duration, and other related details.';
                }
                group(WorkshiftSetup)
                {
                    Caption = 'Set up Workshift';
                    ShowCaption = false;
                    part(FRWorkshiftSetupPage; "NPR FR Audit Workshift Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // VAT ID Step
            group(VATIDStep)
            {
                Visible = VATIDStepVisible;
                group(VATIDInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Enter your VAT ID details to ensure correct tax handling and compliance.';
                }
                group(VATIDSetup)
                {
                    Caption = 'Set up VAT ID';
                    ShowCaption = false;
                    part(FRVATIDSetupPage; "NPR FR Audit VAT ID Setup Step")
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
                group(NotAllMandatoryDataPopulatedMsg)
                {
                    Caption = ' ';
                    InstructionalText = 'Failed to complete setup. Ensure all required steps including certificate upload, workshift setup, and VAT ID are properly configured.';
                    Visible = not DataPopulated;
                }
                group(AllMandatoryDataPopulatedMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = DataPopulated;
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
        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        BackActionEnabled: Boolean;
        DataPopulated: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        UploadCertificateStepVisible: Boolean;
        WorkshiftSetupStepVisible: Boolean;
        VATIDStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,UploadCertificateStep,WorkshiftSetupStep,VATIDStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::UploadCertificateStep:
                ShowUploadCertificateStep();
            Step::WorkshiftSetupStep:
                ShowWorkshiftSetupStep();
            Step::VATIDStep:
                ShowVATIDStep();
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

    local procedure ShowUploadCertificateStep()
    begin
        CurrPage.FRUploadCertificatePage.Page.CopyRealToTemp();
        UploadCertificateStepVisible := true;
    end;

    local procedure ShowWorkshiftSetupStep()
    begin
        CurrPage.FRWorkshiftSetupPage.Page.CopyRealToTemp();
        WorkshiftSetupStepVisible := true;
    end;

    local procedure ShowVATIDStep()
    begin
        CurrPage.FRVATIDSetupPage.Page.CopyRealToTemp();
        VATIDStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataPopulated();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := DataPopulated;
    end;

    local procedure CheckIfDataPopulated()
    begin
        DataPopulated := CurrPage.FRUploadCertificatePage.Page.IsDataPopulated() and
                         CurrPage.FRWorkshiftSetupPage.Page.IsDataPopulated() and
                         CurrPage.FRVATIDSetupPage.Page.IsDataPopulated();
    end;

    local procedure FinishAction();
    begin
        CurrPage.FRUploadCertificatePage.Page.CreateFRAuditCertificateData();
        CurrPage.FRWorkshiftSetupPage.Page.CreateFRAuditWorkshiftData();
        CurrPage.FRVATIDSetupPage.Page.CreateFRAuditVATIDData();
        OnAfterFinishStep(DataPopulated);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        UploadCertificateStepVisible := false;
        WorkshiftSetupStepVisible := false;
        VATIDStepVisible := false;
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
