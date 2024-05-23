page 6150817 "NPR Modify POS Payment Methods"
{
    Caption = 'Modify POS Payment Methods';
    Extensible = false;
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
                            Label(POSPaymentMethodLabel)
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
                            Label(POSPaymentMethodLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Payment Method';
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';
                            }
                        }
                    }
                }
                group(SetupsNotVisitedWarning)
                {
                    Caption = 'Warning - following setups were not reviewed or edited';
                    Visible = ShowDenominationSetupOpenedWarning or ShowEFTSetupOpenedWarning;

                    group(EFTSetupWarning)
                    {
                        Caption = '';
                        Visible = ShowEFTSetupOpenedWarning;

                        Label(EFTSetupWarningLabel)
                        {
                            ApplicationArea = NPRRetail;
                            Caption = '- EFT Setup';
                        }
                    }
                    group(DenominationSetupWarning)
                    {
                        Caption = '';
                        Visible = ShowDenominationSetupOpenedWarning;
                        Label(DenominationSetupWarningLabel)
                        {
                            ApplicationArea = NPRRetail;
                            Caption = '- Denomination Setup';
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
            Action(ActionBack)
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
            Action(ActionNext)
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
            Action(ActionFinish)
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
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        BackActionEnabled: Boolean;
        ShowDenominationSetupOpenedWarning: Boolean;
        ShowEFTSetupOpenedWarning: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        POSPaymentMethodDataToCreate: Boolean;
        POSPaymentMethodStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,POSPaymentMethodStep,Finish;

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
    var
        MandatoryFieldsNotPopulatedErrLbl: Label 'Fields marked with a red star (*) are mandatory. Ensure all required fields are populated in order to continue.';
    begin
        if (Step = Step::POSPaymentMethodStep) and (not Backwards) then begin
            if not CurrPage.POSPaymentMethodsPG.Page.MandatoryFieldsPopulated() then
                Error(MandatoryFieldsNotPopulatedErrLbl);
            if not ShouldContinueWithoutOtherSetupsVisited() then
                exit;
        end;

        if Backwards then
            Step := Step - 1
        else
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
        ShowEFTSetupOpenedWarning := not CurrPage.POSPaymentMethodsPG.Page.EFTSetupVisited();
        ShowDenominationSetupOpenedWarning := not CurrPage.POSPaymentMethodsPG.Page.DenominationSetupVisited();
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

    local procedure ShouldContinueWithoutOtherSetupsVisited(): Boolean
    var
        WarningMsgTxt: Text;
        ContinueQstLbl: Label '\Do you still want to continue?';
        DenominationSetupNotOpenedLbl: Label 'Denomination Setup was not edited or reviewed.\';
        EFTSetupNotOpenedLbl: Label 'EFT Setup was not edited or reviewed.\';
        EFTSetupVisited, DenominationSetupVisited : Boolean;
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        EFTSetupVisited := CurrPage.POSPaymentMethodsPG.Page.EFTSetupVisited();
        DenominationSetupVisited := CurrPage.POSPaymentMethodsPG.Page.DenominationSetupVisited();

        if EFTSetupVisited and DenominationSetupVisited then
            exit(true);

        if not EFTSetupVisited then
            WarningMsgTxt += EFTSetupNotOpenedLbl;

        if not DenominationSetupVisited then
            WarningMsgTxt += DenominationSetupNotOpenedLbl;

        WarningMsgTxt += ContinueQstLbl;

        if not ConfirmManagement.GetResponseOrDefault(WarningMsgTxt, true) then
            exit(false);

        exit(true);
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
    local procedure OnAfterFinishStep(AnyDataToModify: Boolean)
    begin
    end;
}
