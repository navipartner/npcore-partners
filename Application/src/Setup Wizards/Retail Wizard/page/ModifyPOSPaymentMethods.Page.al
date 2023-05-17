page 6150817 "NPR Modify POS Payment Methods"
{
    Extensible = False;
    Caption = 'Modify POS Payment Methods';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            // Banners
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesStandard.Media Reference field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {

                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the MediaResourcesDone.Media Reference field';
                    ApplicationArea = NPRRetail;
                }
            }

            // Introduction Step
            group(IntroStep)
            {
                Visible = IntroStepVisible;
                group("Welcome to Retail")
                {
                    Caption = 'Welcome to POS Payment Methods Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to modify POS payment methods. Please check the Rounding Precision, Rounding Type and Rounding Accounts fields. Rounding Precision specifies how precise the rounding is. The field should represent lowest denomination used for the selected POS Payment Method. Rounding Type specifies which rounding type will be applied to the amount. Rounding Accounts specifies which G/L Accounts will be used for rounding gains and losses.';
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

            // POS Payment Method Step
            group(POSPaymentMethodStep)
            {
                Visible = POSPaymentMethodStepVisible;
                group(POSPaymentMethod)
                {
                    Caption = 'Modify Payment Methods';

                    part(POSPaymentMethodsPG; "NPR POS Pmt. Method List Step")
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

                group(MissingData)
                {
                    Caption = 'The following data won''t be created: ';
                    Visible = not AllDataFilledIn;
                    group(MandatoryDataMissing)
                    {
                        Caption = '';
                        group(POSPaymentMethodDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPaymentMethodDataToCreate;
                            label(POSPaymentMethodLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Method';
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';

                            }
                        }
                    }
                }
                group(NotAllMandatoryDataFilledInMsg)
                {
                    Caption = ' ';
                    InstructionalText = 'Please go back and review.';
                    Visible = not AllDataFilledIn;
                }
                group(FilledInData)
                {
                    Caption = 'The following data will be created: ';
                    Visible = AnyDataToCreate;
                    group(MandatoryDataFilledIn)
                    {
                        Caption = '';
                        group(POSPaymentMethodDataExists)
                        {
                            Caption = '';
                            Visible = POSPaymentMethodDataToCreate;
                            label(POSPaymentMethodLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Method';
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';
                            }
                        }
                    }
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To Modify the data, choose Finish.';
                    Visible = AnyDataToCreate;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {

                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Back action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {

                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Executes the Next action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {

                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Executes the Finish action';
                ApplicationArea = NPRRetail;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }
    trigger OnInit();
    var
    begin
        LoadTopBanners();
        Commit();
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
        Step: Option Start,POSPaymentMethodStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        POSPaymentMethodStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        AllDataFilledIn: Boolean;
        POSPaymentMethodDataToCreate: Boolean;
        AnyDataToCreate: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::POSPaymentMethodStep:
                ShowPOSPaymentMethodStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowPOSPaymentMethodStep()
    begin
        POSPaymentMethodStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        POSPaymentMethodDataToCreate := CurrPage.POSPaymentMethodsPG.Page.POSPaymentMethodsToModify();
        AllDataFilledIn := POSPaymentMethodDataToCreate;
        AnyDataToCreate := POSPaymentMethodDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.POSPaymentMethodsPG.Page.ModifyPOSPaymentMethodData();
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
        FinishStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToModify: Boolean)
    begin
    end;
}
