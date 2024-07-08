page 6151392 "NPR Setup RS Fiscal"
{
    Caption = 'Setup RS Fiscalization';
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
                group("Welcome to RS Fiscal")
                {
                    Caption = 'Welcome to Serbian Fiscalization Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = ' This essential step ensures your business adheres to Croatian fiscal regulations. Enable RS fiscalization, set up Fiscal Bill Mailing, input Configuration parameters and set up Allowed Tax Rates for a comprehensive and compliant financial foundation.';
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

            // RS Fiscal Setup
            group(EnableFiscalStep)
            {
                Visible = EnableFiscalStepVisible;
                group(EnableRSFiscal)
                {
                    ShowCaption = false;
                    Editable = true;
                    part(RSEnableFiscalPage; "NPR RS Enable Fiscal Step")
                    {
                        Caption = 'Enabling RS Fiscalization in the setup is essential for the effective operation of fiscalization.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(FiscalBillMailingStep)
            {
                Visible = FiscalBillMailingStepVisible;
                group(SetupFiscBillMailingStep)
                {
                    ShowCaption = false;
                    part(RSFiscalBillMailingPage; "NPR RS Fisc. Bill Mailing Step")
                    {
                        Caption = 'Configure Fiscal Bill Mailing to streamline communication. Set up preferences for sending fiscal bills, ensuring efficient delivery and compliance with regulatory requirements.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(ConfigurationSetupStep)
            {
                Visible = ConfigurationSetupStepVisible;
                group(SetupConfiguration)
                {
                    ShowCaption = false;
                    part(RSConfigurationSetupPage; "NPR RS Configuration Step")
                    {
                        Caption = 'Configure L-PFR and Sandbox API settings. Provide the L-PFR Access Sandbox URL and Configuration URL. After entering the Configuration URL, initiate the ''Fill SUF Configuration'' action to test the URL and obtain all necessary configuration setups';
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(AllowedTaxRatesSetupStep)
            {
                Visible = AllowedTaxRatesSetupStepVisible;
                group(SetupAllowedTaxRates)
                {
                    ShowCaption = false;
                    part(RSAllowedTaxRatesSetupPage; "NPR RS Allowed Tax Rates Step")
                    {
                        Caption = 'Utilize the ''Get Allowed Tax Rates'' action to automatically populate the table with the allowed tax rates obtained from the Tax Authority.';
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
                    InstructionalText = 'Fiscalization Setup Incomplete: It appears there are errors in your fiscalization configuration. Kindly revisit the setup steps and ensure accurate completion before proceeding.';
                    Visible = not RSSetupDataToCreate;
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
        RSMailingDataToModify: Boolean;
        RSConfigurationDataToModify: Boolean;
        RSSetupDataToCreate: Boolean;
        EnableFiscalStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        ConfigurationSetupStepVisible: Boolean;
        TopBannerVisible: Boolean;
        FiscalBillMailingStepVisible: Boolean;
        AllowedTaxRatesSetupStepVisible: Boolean;
        RSAllowedTaxRatesDataToCreate: Boolean;
        Step: Option Start,EnableFiscalStep,FiscalBillMailingStep,SetupConfiguration,SetupAllowedTaxRates,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::EnableFiscalStep:
                ShowEnableFiscalStep();
            Step::FiscalBillMailingStep:
                ShowFiscalBillMailingStep();
            Step::SetupConfiguration:
                ShowConfigurationSetupStep();
            Step::SetupAllowedTaxRates:
                ShowAllowedTaxRatesSetupStep();
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

    local procedure ShowEnableFiscalStep()
    begin
        CurrPage.RSEnableFiscalPage.Page.CopyRealToTemp();
        EnableFiscalStepVisible := true;
    end;

    local procedure ShowFiscalBillMailingStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSEnableFiscalPage.Page.CreateRSFiscalEnableData();
        CurrPage.RSFiscalBillMailingPage.Page.CopyRealToTemp();
        FiscalBillMailingStepVisible := true;
    end;

    local procedure ShowConfigurationSetupStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSFiscalBillMailingPage.Page.CreateRSFiscalBillMailingData();
        CurrPage.RSConfigurationSetupPage.Page.CopyRealToTemp();
        ConfigurationSetupStepVisible := true;
    end;

    local procedure ShowAllowedTaxRatesSetupStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.RSConfigurationSetupPage.Page.CreateRSConfigurationData();
        CurrPage.RSAllowedTaxRatesSetupPage.Page.CopyRealToTemp();
        AllowedTaxRatesSetupStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSSetupDataToCreate and RSMailingDataToModify and RSConfigurationDataToModify;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSSetupDataToCreate := CurrPage.RSEnableFiscalPage.Page.RSSetupToCreate();
        RSMailingDataToModify := CurrPage.RSFiscalBillMailingPage.Page.RSFiscalBillMailingToModify();
        RSConfigurationDataToModify := CurrPage.RSConfigurationSetupPage.Page.RSConfigurationToModify();
        RSAllowedTaxRatesDataToCreate := CurrPage.RSAllowedTaxRatesSetupPage.Page.RSAllowedTaxRatesDataToCreate();
        AnyDataToCreate := RSSetupDataToCreate or RSMailingDataToModify or RSConfigurationDataToModify or RSAllowedTaxRatesDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEnableFiscalPage.Page.CreateRSFiscalEnableData();
        CurrPage.RSFiscalBillMailingPage.Page.CreateRSFiscalBillMailingData();
        CurrPage.RSConfigurationSetupPage.Page.CreateRSConfigurationData();
        CurrPage.RSAllowedTaxRatesSetupPage.Page.CreateRSAllowedTaxRatesData();
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
        FiscalBillMailingStepVisible := false;
        ConfigurationSetupStepVisible := false;
        AllowedTaxRatesSetupStepVisible := false;
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
