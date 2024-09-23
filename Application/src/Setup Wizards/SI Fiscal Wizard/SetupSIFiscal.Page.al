page 6151567 "NPR Setup SI Fiscal"
{
    Caption = 'Setup SI Fiscalization';
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
                    Caption = 'Welcome to Slovenian Fiscalization Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = ' This essential step ensures your business adheres to Slovenian fiscal regulations. Enable SI fiscalization, set up Number Series, and securely upload your fiscal certificate for a comprehensive and compliant financial foundation.';
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

            // SI Fiscal Setup
            group(EnableFiscalStep)
            {
                Visible = EnableFiscalStepVisible;
                group(EnableSIFiscal)
                {
                    Caption = 'Enable SI Fiscalization';
                    ShowCaption = false;
                    Editable = true;
                    part(SIEnableFiscalPage; "NPR SI Enable Fiscal Step")
                    {
                        Caption = 'Enabling SI Fiscalization in the setup is essential for the effective operation of fiscalization.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(UploadCertificateStep)
            {
                Visible = UploadCertificateStepVisible;

                group(UploadCertificateInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Upload your Fiscal Certificate for secure signing and transmission of fiscal bill information to the Tax authorities.';
                }
                group(UploadSICertificate)
                {
                    Caption = 'Upload a fiscalization certificate';
                    ShowCaption = false;
                    part(SIUploadCertificatePage; "NPR SI Upload Cert. Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(NoSeriesSetupStep)
            {
                Visible = SetupNoSeriesStepVisible;
                group(NoSeriesSetupInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Select the appropriate No. Series for your fiscal bills. This helps ensure proper sequencing and tracking of your financial documents.';
                }
                group(SetupNoSeries)
                {
                    Caption = 'Set up Fiscal Bill No. Series';
                    ShowCaption = false;
                    part(SISetupNoSeries; "NPR SI Setup No. Series Step")
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
                    InstructionalText = 'Unable to complete SI Fiscalization Setup. Please ensure all required fields, including enabling SI fiscalization, configuring Number Series, and uploading the fiscal certificate, are filled correctly';
                    Visible = not SISetupDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = AnyDataToCreate;
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
        AnyDataToCreate: Boolean;
        BackActionEnabled: Boolean;
        SICertificateDataToModify: Boolean;
        SINoSeriesDataToModify: Boolean;
        SISetupDataToCreate: Boolean;
        EnableFiscalStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupNoSeriesStepVisible: Boolean;
        TopBannerVisible: Boolean;
        UploadCertificateStepVisible: Boolean;
        Step: Option Start,EnableFiscalStep,UploadCertificateStep,SetupNoSeries,Finish;

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
            Step::SetupNoSeries:
                ShowSetupNoSeriesStep();
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
        CurrPage.SIEnableFiscalPage.Page.CopyRealToTemp();
        EnableFiscalStepVisible := true;
    end;

    local procedure ShowUploadCertificateStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.SIEnableFiscalPage.Page.CreateSIFiscalEnableData();
        CurrPage.SIUploadCertificatePage.Page.CopyRealToTemp();
        UploadCertificateStepVisible := true;
    end;

    local procedure ShowSetupNoSeriesStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.SIUploadCertificatePage.Page.CreateSIFiscalCertificateData();
        CurrPage.SISetupNoSeries.Page.CopyRealToTemp();
        SetupNoSeriesStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := SISetupDataToCreate and SICertificateDataToModify and SINoSeriesDataToModify;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        SISetupDataToCreate := CurrPage.SIEnableFiscalPage.Page.SISetupToCreate();
        SICertificateDataToModify := CurrPage.SIUploadCertificatePage.Page.SICertificateToModify();
        SINoSeriesDataToModify := CurrPage.SISetupNoSeries.Page.SINoSeriesToModify();
        AnyDataToCreate := SISetupDataToCreate or SICertificateDataToModify or SINoSeriesDataToModify;
    end;

    local procedure FinishAction();
    begin
        CurrPage.SIEnableFiscalPage.Page.CreateSIFiscalEnableData();
        CurrPage.SIUploadCertificatePage.Page.CreateSIFiscalCertificateData();
        CurrPage.SISetupNoSeries.Page.CreateNoSeriesSetupData();
        OnAfterFinishStep(AnyDataToCreate);
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
        SetupNoSeriesStepVisible := false;
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
