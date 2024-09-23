page 6151609 "NPR Setup SI Audit Profile"
{
    Caption = 'Setup SI POS Audit Profile';
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
                    Caption = 'Welcome to POS Audit Profile Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to customize POS Audit settings to ensure adherence to regulatory requirements. Choose the SI_DAVKI Audit Handler, enable Audit Logs, and make precise adjustments such as ''Do Not Print Receipt on Sale'' for a thorough and secure audit process.';
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
            group(SetupPOSAuditProfileStep)
            {
                Visible = SetupPOSAuditProfileStepVisible;
                group(ChooseAuditProfile)
                {
                    Caption = 'Choose POS Audit Profile';
                    ShowCaption = false;
                    Editable = true;
                    part(SIChooseAuditProfileStep; "NPR SI POS Audit Profile Step")
                    {
                        Caption = 'Select the SI_DAVKI audit handler and enable the audit log for comprehensive transaction tracking.';
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
                    InstructionalText = 'Failed to complete POS Audit Profile Setup. Ensure you''ve chosen the SI_DAVKI Audit Handler and enabled Audit Logs.';
                    Visible = not SIPOSAuditDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = SIPOSAuditDataToCreate;
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
        SIPOSAuditDataToCreate: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupPOSAuditProfileStepVisible: Boolean;
        TopBannerVisible: Boolean;
        Step: Option Start,SetupPOSAuditProfileStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupPOSAuditProfileStep:
                ShowSetupPOSAuditProfileStep();
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

    local procedure ShowSetupPOSAuditProfileStep()
    begin
        CurrPage.SIChooseAuditProfileStep.Page.CopyRealToTemp();
        SetupPOSAuditProfileStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := SIPOSAuditDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        SIPOSAuditDataToCreate := CurrPage.SIChooseAuditProfileStep.Page.SIPOSAuditProfileDataToCreate();
    end;

    local procedure FinishAction();
    begin
        CurrPage.SIChooseAuditProfileStep.Page.CreatePOSAuditProfileData();
        OnAfterFinishStep(SIPOSAuditDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        SetupPOSAuditProfileStepVisible := false;
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
