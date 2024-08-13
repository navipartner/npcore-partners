page 6184725 "NPR Setup RS E-Invoice"
{
    Caption = 'Setup RS E-Invoicing';
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
                    Caption = 'Welcome to RS E-Invoicing Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This setup wizard will guide you through the initial configuration steps to ensure your invoicing process is smooth and efficient.';
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

            // RS E-Invoice Setup
            group(EnableRSEInvoicingStep)
            {
                Visible = EnableRSEInvoicingStepVisible;
                group(EnableRSEInvoicing)
                {
                    Caption = 'Enable RS E-Invoicing';
                    ShowCaption = false;
                    Editable = true;
                    part(RSEIEnableStepPage; "NPR RS EI Enable Step")
                    {
                        Caption = 'Activate the E-Invoicing feature to automate and simplify your billing process. By enabling E-Invoicing, you''ll be able to send, receive, and manage invoices electronically.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(SetupAPIParametersStep)
            {
                Visible = SetupAPIParametersStepVisible;

                group(SetupAPIParametersInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Configure the necessary API settings to integrate with your existing systems and facilitate seamless data exchange.';
                }
                group(SetupAPIPaths)
                {
                    Caption = 'Set up API configuration';
                    ShowCaption = false;
                    part(RSEIAPIPathsStepPage; "NPR RS EI API Parameters Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(DefaultsSetupStep)
            {
                Visible = DefaultsSetupStepVisible;
                group(DefaultsSetupInstructions)
                {
                    Caption = '';
                    InstructionalText = 'Customize your invoicing experience by setting up default parameters. Define key settings such as your default unit of measure to ensure consistency and accuracy across all your invoices. This step will help streamline your invoicing process and save you time on every transaction.';
                }
                group(DefaultsSetup)
                {
                    Caption = 'Set up Defaults';
                    ShowCaption = false;
                    part(RSEIDefaultsSetupStepPage; "NPR RS EI Defaults Setup Step")
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
                    InstructionalText = 'It looks like some mandatory information is missing. Please ensure that all required fields are filled in before proceeding. This will help us set up your E-Invoicing correctly and avoid any issues later on.';
                    Visible = not RSEInvoiceSetupDataToCreate;
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
        RSEIAPIPathDataToCreate: Boolean;
        RSEIDefaultsSetupDataToCreate: Boolean;
        RSEInvoiceSetupDataToCreate: Boolean;
        EnableRSEInvoicingStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        DefaultsSetupStepVisible: Boolean;
        TopBannerVisible: Boolean;
        SetupAPIParametersStepVisible: Boolean;
        Step: Option Start,EnableEInvoiceStep,InputAPIPathsStep,DefaultsSetupStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::EnableEInvoiceStep:
                ShowEnableEInvoiceStep();
            Step::InputAPIPathsStep:
                ShowInputAPIPathsStep();
            Step::DefaultsSetupStep:
                ShowDefaultsSetupStepStep();
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

    local procedure ShowEnableEInvoiceStep()
    begin
        CurrPage.RSEIEnableStepPage.Page.CopyRealToTemp();
        EnableRSEInvoicingStepVisible := true;
    end;

    local procedure ShowInputAPIPathsStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSEIEnableStepPage.Page.CreateRSEISetupData();
        CurrPage.RSEIAPIPathsStepPage.Page.CopyRealToTemp();
        SetupAPIParametersStepVisible := true;
    end;

    local procedure ShowDefaultsSetupStepStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSEIAPIPathsStepPage.Page.CreateRSEISetupData();
        CurrPage.RSEIDefaultsSetupStepPage.Page.CopyRealToTemp();
        DefaultsSetupStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSEIDefaultsSetupStepPage.Page.CreateRSEISetupData();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSEInvoiceSetupDataToCreate and RSEIAPIPathDataToCreate and RSEIDefaultsSetupDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSEInvoiceSetupDataToCreate := CurrPage.RSEIEnableStepPage.Page.RSEISetupDataToCreate();
        RSEIAPIPathDataToCreate := CurrPage.RSEIAPIPathsStepPage.Page.RSEISetupDataToCreate();
        RSEIDefaultsSetupDataToCreate := CurrPage.RSEIDefaultsSetupStepPage.Page.RSEISetupDataToCreate();
        AnyDataToCreate := RSEInvoiceSetupDataToCreate or RSEIAPIPathDataToCreate or RSEIDefaultsSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEIEnableStepPage.Page.CreateRSEISetupData();
        CurrPage.RSEIAPIPathsStepPage.Page.CreateRSEISetupData();
        CurrPage.RSEIDefaultsSetupStepPage.Page.CreateRSEISetupData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        EnableRSEInvoicingStepVisible := false;
        SetupAPIParametersStepVisible := false;
        DefaultsSetupStepVisible := false;
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
