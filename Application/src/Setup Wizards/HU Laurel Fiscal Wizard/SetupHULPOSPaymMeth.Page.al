page 6185021 "NPR Setup HU L POS Paym. Meth."
{
    Caption = 'Setup HU Laurel POS Payment Methods';
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
                    Caption = 'Welcome to HU Laurel POS Payment Method Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This essential step ensures accurate transaction processing and compliance. Set up POS Payment Methods and their mappings for seamless financial operations and reconciliation';
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

            // POS Payment Method Setup
            group(POSPaymentMethodStep)
            {
                Visible = POSPaymentMethodStepVisible;
                group(POSPaymentMethods)
                {
                    Caption = 'Setup POS Payment Methods';
                    Editable = true;
                    ShowCaption = false;
                    part(HULPOSPaymMethodStep; "NPR HU L POS Paym. Meth. Step")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Configuring rounding settings for POS Payment Methods is essential to ensure accurate transaction processing and reconciliation.';
                    }
                }
            }
            // HU L POS Payment Method Mapping
            group(POSPaymentMethodMappStep)
            {
                Visible = HULPOSPaymentMethodMappStepVisible;
                group(HULPOSPaymMethods)
                {
                    Caption = 'Setup HU Laurel POS Payment Method Mapping';
                    Editable = true;
                    ShowCaption = false;
                    part(HULPOSPaymentMethodMappStep; "NPR HUL POS Paym Meth Map Step")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Select a POS Payment Method and choose its corresponding mapping. This ensures accurate reporting and reconciliation of transactions.';
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
                    Caption = '';
                    InstructionalText = 'Unable to complete HU Laurel POS Payment Method Setup. Please ensure that you have set up roudning for POS Payment Methods correctly, as well as created at least one POS Payment Method Mapping entry.';
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
                ToolTip = 'Go to the previous step.';

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
                ToolTip = 'Go to the next step.';

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
                ToolTip = 'Finish this step.';
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
        POSPaymentMethodStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        HULPOSPaymentMethodMappStepVisible: Boolean;
        POSPaymentMethodDataToCreate: Boolean;
        POSPaymMethMappingDataToCreate: Boolean;
        AnyDataToCreate: Boolean;
        Step: Option Start,POSPaymentMethodStep,POSPaymMethMappStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::POSPaymentMethodStep:
                ShowPOSPaymentMethodStep();
            Step::POSPaymMethMappStep:
                ShowHULPOSPaymMethMappingStep();
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

    local procedure ShowPOSPaymentMethodStep()
    begin
        CurrPage.HULPOSPaymMethodStep.Page.CopyRealToTemp();
        POSPaymentMethodStepVisible := true;
    end;

    local procedure ShowHULPOSPaymMethMappingStep()
    begin
        CheckIfDataFilledIn();
        CurrPage.HULPOSPaymMethodStep.Page.CreatePOSPaymentMethodData();
        CurrPage.HULPOSPaymentMethodMappStep.Page.CopyRealToTemp();
        HULPOSPaymentMethodMappStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := POSPaymentMethodDataToCreate and POSPaymMethMappingDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        POSPaymentMethodDataToCreate := CurrPage.HULPOSPaymMethodStep.Page.IsDataPopulated();
        POSPaymMethMappingDataToCreate := CurrPage.HULPOSPaymentMethodMappStep.Page.IsDataPopulated();
        AnyDataToCreate := POSPaymentMethodDataToCreate or POSPaymMethMappingDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.HULPOSPaymMethodStep.Page.CreatePOSPaymentMethodData();
        CurrPage.HULPOSPaymentMethodMappStep.Page.CreatePOSPaymMethodMappingData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        POSPaymentMethodStepVisible := false;
        HULPOSPaymentMethodMappStepVisible := false;
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
    local procedure OnAfterFinishStep(DataPopulated: Boolean)
    begin
    end;
}
