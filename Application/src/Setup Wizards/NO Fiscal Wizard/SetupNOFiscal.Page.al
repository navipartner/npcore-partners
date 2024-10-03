page 6184793 "NPR Setup NO Fiscal"
{
    Caption = 'NO Fiscal Setup';
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
                    Caption = 'Welcome to NO Fiscalization Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to enable NO Fiscalization and ensure compliance with Norwegian tax regulations. The wizard will guide you through enabling fiscalization, uploading the required certificates, and setting up SAF-T for reporting purposes.';
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

            // Enable Fiscalization Step
            group(EnableFiscalStep)
            {
                Visible = EnableFiscalStepVisible;
                group(EnableFiscalInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Enable fiscalization to comply with Norwegian regulations.';
                }
                group(EnableFiscal)
                {
                    Caption = 'Enable Fiscalization';
                    ShowCaption = false;
                    part(NOEnableFiscalPage; "NPR NO Enable Fiscal Step")
                    {
                        ApplicationArea = NPRRetail;
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
                    part(NOCertUploadPage; "NPR NO Cert Upload Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // SAF-T Setup Step
            group(SAFTSetupStep)
            {
                Visible = SAFTSetupStepVisible;
                group(SAFTSetupInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Setup SAF-T for reporting and compliance purposes.';
                }
                group(SAFTSetup)
                {
                    Caption = 'Setup SAF-T';
                    ShowCaption = false;
                    part(NOSAFTSetupPage; "NPR NO SAFT Setup Step")
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
                    InstructionalText = 'Failed to complete setup. Ensure all required steps including fiscalization enabling, certificate upload, and SAF-T setup are properly configured.';
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
        EnableFiscalStepVisible: Boolean;
        UploadCertificateStepVisible: Boolean;
        SAFTSetupStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,EnableFiscalStep,UploadCertificateStep,SAFTSetupStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::EnableFiscalStep:
                ShowEnableFiscalStep();
            Step::UploadCertificateStep:
                ShowUploadCertificateStep();
            Step::SAFTSetupStep:
                ShowSAFTSetupStep();
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

    local procedure ShowEnableFiscalStep()
    begin
        CurrPage.NOEnableFiscalPage.Page.CopyRealToTemp();
        EnableFiscalStepVisible := true;
    end;

    local procedure ShowUploadCertificateStep()
    begin
        CurrPage.NOCertUploadPage.Page.CopyRealToTemp();
        UploadCertificateStepVisible := true;
    end;

    local procedure ShowSAFTSetupStep()
    begin
        CurrPage.NOSAFTSetupPage.Page.CopyRealToTemp();
        SAFTSetupStepVisible := true;
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
        DataPopulated := CurrPage.NOEnableFiscalPage.Page.IsDataPopulated() and
                         CurrPage.NOCertUploadPage.Page.IsDataPopulated() and
                         CurrPage.NOSAFTSetupPage.Page.IsDataPopulated();
    end;

    local procedure FinishAction();
    begin
        CurrPage.NOEnableFiscalPage.Page.CreateNOFiscalEnableData();
        CurrPage.NOCertUploadPage.Page.CreateCertificateData();
        CurrPage.NOSAFTSetupPage.Page.CreateSAFTData();
        OnAfterFinishStep(DataPopulated);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        EnableFiscalStepVisible := false;
        UploadCertificateStepVisible := false;
        SAFTSetupStepVisible := false;
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
