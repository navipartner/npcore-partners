page 6184724 "NPR Setup RS EI Paym. Meth."
{
    Caption = 'Setup RS E-Invoice Payment Method Mapping';
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
                    Caption = 'Welcome to Payment Method Mapping Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Systematically map each Payment Method to its corresponding code, ensuring coherence in reporting and facilitating efficient reconciliation processes.';
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

            // RS EI Payment Method Setup
            group(SetupPaymentMethodsStep)
            {
                Visible = SetupPaymentMethodsStepVisible;
                group(PaymentMethods)
                {
                    ShowCaption = false;
                    Editable = true;
                    InstructionalText = 'Select a Payment Method and choose its corresponding mapping. This step ensures that all your units are standardized and aligned with the permitted codes.';
                    part(RSEIPaymentMethodsSetupStep; "NPR RS EI Paym. Method Step")
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
                    InstructionalText = 'Payment Method Mapping Setup could not be completed. Please ensure that any Payment Method is mapped to its corresponding code before moving forward.';
                    Visible = not RSEIPaymentMethodMappDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = RSEIPaymentMethodMappDataToCreate;
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
        RSEIPaymentMethodMappDataToCreate: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupPaymentMethodsStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,SetupPaymentMethodStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupPaymentMethodStep:
                ShowSetupPaymentMethodStep();
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

    local procedure ShowSetupPaymentMethodStep()
    begin
        CurrPage.RSEIPaymentMethodsSetupStep.Page.CopyRealToTemp();
        SetupPaymentMethodsStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSEIPaymentMethodMappDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSEIPaymentMethodMappDataToCreate := CurrPage.RSEIPaymentMethodsSetupStep.Page.RSEIPaymentMethodMappingDataToCreate()
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEIPaymentMethodsSetupStep.Page.CreateRSEIPaymentMethodMappingData();
        OnAfterFinishStep(RSEIPaymentMethodMappDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        SetupPaymentMethodsStepVisible := false;
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