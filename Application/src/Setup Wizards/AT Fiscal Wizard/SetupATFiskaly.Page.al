page 6184684 "NPR Setup AT Fiskaly"
{
    Caption = 'Setup AT Fiskaly';
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
                    Caption = 'Welcome to AT Fiskaly Integration Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This essential step ensures your business adheres to Austrian integration with Fiskaly. Set up related settings necessary for its execution.';
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

            // AT Organizations 
            group(SetATOrganizationsStep)
            {
                Visible = ATOrganizationsStepVisible;
                group(SetATOrganizationsStepInfo)
                {
                    Caption = 'Setup AT Organizations.';
                    InstructionalText = 'Setup at least one AT Organization, authenticate it with FinanzOnline and assign Fiskaly''s connection credentials.';
                }
                group(OpenATOrganizationsGroup)
                {
                    ShowCaption = false;
                    field(OpenATOrganizations; OpenATOrganizationsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ATOganizationStep: Page "NPR AT Organizations Step";
                        begin
                            ATOganizationStep.RunModal();
                            UpdateATOrganizationsInfo();
                        end;
                    }
                    field(ATOrganizationsInfo; ATOrganizationsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'AT organizations set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of AT orgnaizations fully set.';
                    }
                }
            }

            // AT Signature Creation Units 
            group(SetATSCUsStep)
            {
                Visible = ATSCUsStepVisible;
                group(SetATSCUsStepInfo)
                {
                    Caption = 'Setup AT Signature Creation Units.';
                    InstructionalText = 'Setup at least one AT Signature Creation Unit and initialize it.';
                }
                group(OpenATSCUsGroup)
                {
                    ShowCaption = false;
                    field(OpenATSCUs; OpenATSCUsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ATSCUsStep: Page "NPR AT SCUs Step";
                        begin
                            ATSCUsStep.RunModal();
                            UpdateATSCUsInfo();
                        end;
                    }
                    field(ATSCUsInfo; ATSCUsInitialized)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'AT signature creation units initialized:';
                        Editable = false;
                        ToolTip = 'Specifies the number of AT signature creation units fully initialized.';
                    }
                }
            }

            // AT Cash Registers
            group(SetATCashRegistersStep)
            {
                Visible = ATCashRegistersStepVisible;
                group(SetATCashRegistersStepInfo)
                {
                    Caption = 'Setup AT Cash Registers.';
                    InstructionalText = 'Setup at least one AT Cash Register and initialize it.';
                }
                group(OpenATCashRegistersGroup)
                {
                    ShowCaption = false;
                    field(OpenATCashRegisters; OpenATCashRegistersLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ATCashRegistersStep: Page "NPR AT Cash Registers Step";
                        begin
                            ATCashRegistersStep.RunModal();
                            UpdateATCashRegistersInfo();
                        end;
                    }
                    field(ATCashRegistersInfo; ATCashRegistersInitialized)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'AT cash registers initialized:';
                        Editable = false;
                        ToolTip = 'Specifies the number of AT cash registers fully initialized.';
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
                    InstructionalText = 'Unable to complete AT Fiscalization Setup. Please ensure all required fields, including enabling AT fiscalization are filled correctly.';
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
        CheckIsFiscalizationEnabled();
        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        ATOrganizationsStepVisible: Boolean;
        ATSCUsStepVisible: Boolean;
        ATCashRegistersStepVisible: Boolean;
        BackActionEnabled: Boolean;
        DataPopulated: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        ATOrganizationsSet: Text[20];
        ATSCUsInitialized: Text[20];
        ATCashRegistersInitialized: Text[20];
        Step: Option Start,ATOrganizations,ATSCUs,ATCashRegisters,Finish;
        OpenATOrganizationsLbl: Label 'Open the AT organizations page to set them up.';
        OpenATSCUsLbl: Label 'Open the AT signature creation units page to set them up.';
        OpenATCashRegistersLbl: Label 'Open the AT cash registers page to set them up.';

    local procedure CheckIsFiscalizationEnabled()
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
        ATFiscalizationNotEnabledMsg: Label 'AT Fiscalization should be enabled in order to proceed with other setups.';
    begin
        if not ATAuditMgt.IsATFiscalizationEnabled() then begin
            Message(ATFiscalizationNotEnabledMsg);
            Error('');
        end;
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::ATOrganizations:
                ShowATOrganizationsStep();
            Step::ATSCUs:
                ShowATSCUsStep();
            Step::ATCashRegisters:
                ShowATCashRegistersStep();
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

    local procedure ShowATOrganizationsStep()
    begin
        UpdateATOrganizationsInfo();
        ATOrganizationsStepVisible := true;
    end;

    local procedure ShowATSCUsStep()
    begin
        UpdateATSCUsInfo();
        ATSCUsStepVisible := true;
    end;

    local procedure ShowATCashRegistersStep()
    begin
        UpdateATCashRegistersInfo();
        ATCashRegistersStepVisible := true;
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
        DataPopulated := (ATOrganizationsSet <> '') and (ATSCUsInitialized <> '') and (ATCashRegistersInitialized <> '');
    end;

    local procedure FinishAction();
    begin
        OnAfterFinishStep(DataPopulated);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        ATOrganizationsStepVisible := false;
        ATSCUsStepVisible := false;
        ATCashRegistersStepVisible := false;
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

    local procedure UpdateATOrganizationsInfo()
    var
        ATOrganization: Record "NPR AT Organization";
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";
        ATOrganizationsSetCounter: Integer;
    begin
        Clear(ATOrganizationsSet);

        ATOrganization.SetRange("FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED);
        if ATOrganization.IsEmpty() then
            exit;

        ATOrganization.FindSet();

        repeat
            if ATSecretMgt.GetSecretKey(ATOrganization.GetAPIKeyName()) <> '' then
                if ATSecretMgt.GetSecretKey(ATOrganization.GetAPISecretName()) <> '' then
                    ATOrganizationsSetCounter += 1;
        until ATOrganization.Next() = 0;

        if ATOrganizationsSetCounter <> 0 then
            ATOrganizationsSet := Format(ATOrganizationsSetCounter);
    end;

    local procedure UpdateATSCUsInfo()
    var
        ATSCU: Record "NPR AT SCU";
        ATSCUsInitializedCounter: Integer;
    begin
        Clear(ATSCUsInitialized);

        ATSCU.SetRange(State, ATSCU.State::INITIALIZED);
        ATSCUsInitializedCounter := ATSCU.Count();

        if ATSCUsInitializedCounter <> 0 then
            ATSCUsInitialized := Format(ATSCUsInitializedCounter);
    end;

    local procedure UpdateATCashRegistersInfo()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATCashRegistersInitializedCounter: Integer;
    begin
        Clear(ATCashRegistersInitialized);

        ATCashRegister.SetRange(State, ATCashRegister.State::INITIALIZED);
        ATCashRegistersInitializedCounter := ATCashRegister.Count();

        if ATCashRegistersInitializedCounter <> 0 then
            ATCashRegistersInitialized := Format(ATCashRegistersInitializedCounter);
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(DataPopulated: Boolean)
    begin
    end;
}
