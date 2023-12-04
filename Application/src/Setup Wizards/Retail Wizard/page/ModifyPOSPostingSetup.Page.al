page 6150818 "NPR Modify POS Posting Setup"
{
    Caption = 'Modify POS Posting Setup';
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
                    Caption = 'Welcome to POS Posting Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to modify POS posting setup. Before modifying POS posting setup you can set up Difference Accounts info (Difference Account type, Difference Account No. and Difference Account No. (negative)). Values that you enter will be applied to all setup records and if you do not wish to change default values just leave fields empty and skip difference account set up step. On the second page you can modify the all other fields int the POS posting setup like POS Store Code, POS Payment Method Code, POS Payment Bin Code, Account Type and No.';
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

            // POS Posting Setup Step
            group(PrePOSPostingSetupStep)
            {
                Visible = PrePOSPostingSetupStepVisible;
                group(PrePOSPostingSetup)
                {
                    Caption = 'Set Posting Setup';

                    part(PrePOSPostingSetupPG; "NPR Pre POS Posting Setup Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            // POS Posting Setup Step
            group(POSPostingSetupStep)
            {
                Visible = POSPostingSetupStepVisible;
                group(POSPostingSetup)
                {
                    Caption = 'Set Posting Setup';

                    part(POSPostingSetupPG; "NPR POS Posting Setup Step")
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
                    Caption = 'The following data won''t be modified: ';
                    Visible = not AllDataFilledIn;
                    group(MandatoryDataMissing)
                    {
                        Caption = '';
                        group(POSPostingSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPostingSetupDataToCreate;
                            Label(POSPostingSetupLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Posting Setup';
                                ToolTip = 'Specifies the value of the POSPostingSetupLabel field';
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
                    Caption = 'The following data will be modified: ';
                    Visible = AnyDataToCreate;
                    group(MandatoryDataFilledIn)
                    {
                        Caption = '';
                        group(POSPostingSetupDataExists)
                        {
                            Caption = '';
                            Visible = POSPostingSetupDataToCreate;
                            Label(POSPostingSetupLabel1)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- POS Posting Setup';
                                ToolTip = 'Specifies the value of the POSPostingSetupLabel field';
                            }
                        }
                    }
                }
                group(SameAccountNosWarning)
                {
                    Caption = 'Warning - Same Posting accounts';
                    InstructionalText = 'Setting all Account Numbers to the same code may impact your ability to maintain a clear overview of postings for different payment methods. Distinguishing accounts based on unique codes helps ensure accurate tracking and reporting. It''s recommended to review and adjust the Account Numbers to maintain proper visibility into your financial transactions.';
                    Visible = ShowWarningSameAccountNos;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To modify the data, choose Finish.';
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
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        POSPostingSetupDataToCreate: Boolean;
        POSPostingSetupStepVisible: Boolean;
        PrePOSPostingSetupStepVisible: Boolean;
        ShowWarningSameAccountNos: Boolean;
        TopBannerVisible: Boolean;
        _DoNotCopy: Boolean;
        _AccountNo: Code[20];
        _DifferenceAccountNo: Code[20];
        _DifferenceAccountNoNeg: Code[20];
        Step: Option Start,PrePOSPostingSetupStep,POSPostingSetupStep,Finish;
        _AccountType: Option " ","G/L Account","Bank Account",Customer;
        _DifferenceAccountType: Option " ","G/L Account","Bank Account",Customer;
        ContinueWithSameAccountNosQstLbl: Label 'Setting all Account Numbers to the same code may impact your ability to maintain a clear overview of postings for different payment methods. Distinguishing accounts based on unique codes helps ensure accurate tracking and reporting. It''s recommended to review and adjust the Account Numbers to maintain proper visibility into your financial transactions.\Do you still want to continue?';
        MandatoryFieldsNotPopulatedErrLbl: Label 'Fields marked with a red star (*) are mandatory. Ensure all required fields are populated in order to continue.';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::PrePOSPostingSetupStep:
                ShowPrePOSPostingSetupStep();
            Step::POSPostingSetupStep:
                ShowPOSPostingSetupStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step = Step::POSPostingSetupStep) and (not Backwards) then
            if not CurrPage.POSPostingSetupPG.Page.MandatoryFieldsPopulated() then
                Error(MandatoryFieldsNotPopulatedErrLbl);

        if (Step = Step::POSPostingSetupStep) and (not Backwards) then
            if CurrPage.POSPostingSetupPG.Page.AllAccountNosAreEqual() then
                if not ShowWarningAboutSameAccountNos() then
                    exit;

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

    local procedure ShowPrePOSPostingSetupStep()
    begin
        PrePOSPostingSetupStepVisible := true;
        POSPostingSetupStepVisible := false;
    end;

    local procedure ShowPOSPostingSetupStep()
    begin
        CurrPage.POSPostingSetupPG.Page.CopyRealToTemp(_DoNotCopy);
        CurrPage.PrePOSPostingSetupPG.Page.GetGlobals(_AccountType, _AccountNo, _DifferenceAccountType, _DifferenceAccountNo, _DifferenceAccountNoNeg);
        CurrPage.POSPostingSetupPG.Page.ApplyValues(_AccountType, _AccountNo, _DifferenceAccountType, _DifferenceAccountNo, _DifferenceAccountNoNeg);
        PrePOSPostingSetupStepVisible := false;
        POSPostingSetupStepVisible := true;
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
        POSPostingSetupDataToCreate := CurrPage.POSPostingSetupPG.Page.POSPostingSetupToCreate();
        ShowWarningSameAccountNos := CurrPage.POSPostingSetupPG.Page.AllAccountNosAreEqual();
        AllDataFilledIn := POSPostingSetupDataToCreate;
        AnyDataToCreate := POSPostingSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.POSPostingSetupPG.Page.CreatePOSPostingSetupData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        POSPostingSetupStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure ShowWarningAboutSameAccountNos(): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(ContinueWithSameAccountNosQstLbl, true) then
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
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}