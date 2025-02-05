page 6184943 "NPR Setup DE Fiskaly"
{
    Caption = 'Setup DE Fiskaly';
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
                    Caption = 'Welcome to DE Fiskaly Integration Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This essential step ensures your business adheres to German integration with Fiskaly. Set up related settings necessary for its execution.';
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

            // DE Connection Parameter Sets 
            group(SetDEConnectionParameterSetsStep)
            {
                Visible = DEConnectionParameterSetsStepVisible;
                group(SetDEConnectionParameterSetsStepInfo)
                {
                    Caption = 'Setup DE Connection Parameter Sets.';
                    InstructionalText = 'Setup at least one DE Connection Parameter Set, assign Fiskaly''s connection credentials and create taxpayer for it at Fiskaly.';
                }
                group(OpenDEConnectionParameterSetsGroup)
                {
                    ShowCaption = false;
                    field(OpenDEConnectionParameterSets; OpenDEConnectionParameterSetsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            DEConnParamSetsStep: Page "NPR DE Conn. Param. Sets Step";
                        begin
                            DEConnParamSetsStep.RunModal();
                            UpdateDEConnectionParameterSetsInfo();
                        end;
                    }
                    field(DEConnectionParameterSetsInfo; DEConnectionParameterSetsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'DE connection parameters sets set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of DE connection parameters sets fully set.';
                    }
                }
            }

            // DE Establishments
            group(SetDEEstablishmentsStep)
            {
                Visible = DEEstablishmentsStepVisible;
                group(SetDEEstablishmentsStepInfo)
                {
                    Caption = 'Setup DE Establishments.';
                    InstructionalText = 'Setup at least one DE Establishment and create it at Fiskaly.';
                }
                group(OpenDEEstablishmentsGroup)
                {
                    ShowCaption = false;
                    field(OpenDEEstablishments; OpenDEEstablishmentsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            DEEstablishmentsStep: Page "NPR DE Establishments Step";
                        begin
                            DEEstablishmentsStep.RunModal();
                            UpdateDEEstablishmentsInfo();
                        end;
                    }
                    field(DEEstablishmentsInfo; DEEstablishmentsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'DE establishments set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of DE establishments fully set.';
                    }
                }
            }

            // DE Technical Security Systems
            group(SetDETSSStep)
            {
                Visible = DETSSStepVisible;
                group(SetDETSSStepInfo)
                {
                    Caption = 'Setup DE Technical Security Systems.';
                    InstructionalText = 'Setup at least one DE Technical Security System and create it at Fiskaly.';
                }
                group(OpenDETSSGroup)
                {
                    ShowCaption = false;
                    field(OpenDETSS; OpenDETSSLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            DETSSStep: Page "NPR DE TSS Step";
                        begin
                            DETSSStep.RunModal();
                            UpdateDETSSInfo();
                        end;
                    }
                    field(DETSSInfo; DETSSSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'DE technical security systems set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of DE technical security systems fully set.';
                    }
                }
            }

            // DE Technical Security Systems
            group(SetDETSSClientsStep)
            {
                Visible = DETSSClientsStepVisible;
                group(SetDETSSClientsStepInfo)
                {
                    Caption = 'Setup DE TSS Clients.';
                    InstructionalText = 'Setup at least one DE TSS Client, create it at Fiskaly and create addditional data for it at Fiskaly.';
                }
                group(OpenDETSSClientsGroup)
                {
                    ShowCaption = false;
                    field(OpenDETSSClients; OpenDETSSClientsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            DETSSClientsStep: Page "NPR DE TSS Clients Step";
                        begin
                            DETSSClientsStep.RunModal();
                            UpdateDETSSClientsInfo();
                        end;
                    }
                    field(DETSSClientsInfo; DETSSClientsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'DE TSS Clients set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of DE TSS Clients fully set.';
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
                    InstructionalText = 'Unable to complete DE Fiskaly Setup. Please ensure all required data is created and set correctly.';
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
        area(processing)
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
        CheckIsFiscalizationEnabled();
        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        DEConnectionParameterSetsStepVisible: Boolean;
        DEEstablishmentsStepVisible: Boolean;
        DETSSStepVisible: Boolean;
        DETSSClientsStepVisible: Boolean;
        DataPopulated: Boolean;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        DEConnectionParameterSetsSet: Text[20];
        DEEstablishmentsSet: Text[20];
        DETSSSet: Text[20];
        DETSSClientsSet: Text[20];
        Step: Option Start,ShowDEConnectParameterSetsStep,ShowDEEstablishmentsStep,ShowDETSSStep,ShowDETSSClientsStep,Finish;
        OpenDEConnectionParameterSetsLbl: Label 'Open the DE connection parameter set page to set them up.';
        OpenDEEstablishmentsLbl: Label 'Open the DE establishments page to set them up.';
        OpenDETSSLbl: Label 'Open the DE technical security systems page to set them up.';
        OpenDETSSClientsLbl: Label 'Open the DE TSS clients page to set them up.';

    local procedure CheckIsFiscalizationEnabled()
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiscalizationNotEnabledMsg: Label 'DE Fiscalization should be enabled in order to proceed with other setups.';
    begin
        if not DEAuditMgt.IsFiscalizationEnabled() then begin
            Message(DEFiscalizationNotEnabledMsg);
            Error('');
        end;
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::ShowDEConnectParameterSetsStep:
                ShowDEConnectParameterSetsStep();
            Step::ShowDEEstablishmentsStep:
                ShowDEEstablishmentsStep();
            Step::ShowDETSSStep:
                ShowDETSSStep();
            Step::ShowDETSSClientsStep:
                ShowDETSSClientsStep();
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

    local procedure ShowDEConnectParameterSetsStep()
    begin
        UpdateDEConnectionParameterSetsInfo();
        DEConnectionParameterSetsStepVisible := true;
    end;

    local procedure ShowDEEstablishmentsStep()
    begin
        UpdateDEEstablishmentsInfo();
        DEEstablishmentsStepVisible := true;
    end;

    local procedure ShowDETSSStep()
    begin
        UpdateDETSSInfo();
        DETSSStepVisible := true;
    end;

    local procedure ShowDETSSClientsStep()
    begin
        UpdateDETSSClientsInfo();
        DETSSClientsStepVisible := true;
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
        DataPopulated := (DEConnectionParameterSetsSet <> '') and (DEEstablishmentsSet <> '') and (DETSSSet <> '') and (DETSSClientsSet <> '');
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
        DEConnectionParameterSetsStepVisible := false;
        DEEstablishmentsStepVisible := false;
        DETSSStepVisible := false;
        DETSSClientsStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', (CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', (CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure UpdateDEConnectionParameterSetsInfo()
    var
        DEConnectionParameterSet: Record "NPR DE Audit Setup";
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        DEConnectionParameterSetCounter: Integer;
    begin
        Clear(DEConnectionParameterSetsSet);

        DEConnectionParameterSet.SetFilter("Api URL", '<>%1', '');
        DEConnectionParameterSet.SetFilter("Submission Api URL", '<>%1', '');
        DEConnectionParameterSet.SetRange("Taxpayer Created", true);
        if DEConnectionParameterSet.IsEmpty() then
            exit;

        DEConnectionParameterSet.FindSet();

        repeat
            if DESecretMgt.GetSecretKey(DEConnectionParameterSet.ApiKeyLbl()) <> '' then
                if DESecretMgt.GetSecretKey(DEConnectionParameterSet.ApiSecretLbl()) <> '' then
                    DEConnectionParameterSetCounter += 1;
        until DEConnectionParameterSet.Next() = 0;

        if DEConnectionParameterSetCounter <> 0 then
            DEConnectionParameterSetsSet := Format(DEConnectionParameterSetCounter);
    end;

    local procedure UpdateDEEstablishmentsInfo()
    var
        DEEstablishment: Record "NPR DE Establishment";
        DEEstablishmentsSetCounter: Integer;
    begin
        Clear(DEEstablishmentsSet);
        DEEstablishment.SetRange(Created, true);
        DEEstablishmentsSetCounter := DEEstablishment.Count();

        if DEEstablishmentsSetCounter <> 0 then
            DEEstablishmentsSet := Format(DEEstablishmentsSetCounter);
    end;

    local procedure UpdateDETSSInfo()
    var
        DETSS: Record "NPR DE TSS";
        DETSSSetCounter: Integer;
    begin
        Clear(DETSSSet);
        DETSS.SetRange("Fiskaly TSS State", DETSS."Fiskaly TSS State"::INITIALIZED);
        DETSSSetCounter := DETSS.Count();

        if DETSSSetCounter <> 0 then
            DETSSSet := Format(DETSSSetCounter);
    end;

    local procedure UpdateDETSSClientsInfo()
    var
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSSClientsSetCounter: Integer;
    begin
        Clear(DETSSClientsSet);
        DETSSClient.SetRange("Fiskaly Client State", DETSSClient."Fiskaly Client State"::REGISTERED);
        DETSSClient.SetRange("Additional Data Created", true);
        DETSSClientsSetCounter := DETSSClient.Count();

        if DETSSClientsSetCounter <> 0 then
            DETSSClientsSet := Format(DETSSClientsSetCounter);
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(DataPopulated: Boolean)
    begin
    end;
}
