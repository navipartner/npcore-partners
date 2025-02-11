page 6184761 "NPR Setup ES Fiskaly"
{
    Caption = 'Setup ES Fiskaly';
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
                    Caption = 'Welcome to ES Fiskaly Integration Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This essential step ensures your business adheres to Spain integration with Fiskaly. Set up related settings necessary for its execution.';
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

            // ES Organizations 
            group(SetESOrganizationsStep)
            {
                Visible = ESOrganizationsStepVisible;
                group(SetESOrganizationsStepInfo)
                {
                    Caption = 'Setup ES Organizations.';
                    InstructionalText = 'Setup at least one ES Organization, assign Fiskaly''s connection credentials and create taxpayer for it.';
                }
                group(OpenESOrganizationsGroup)
                {
                    ShowCaption = false;
                    field(OpenESOrganizations; OpenESOrganizationsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ESOganizationStep: Page "NPR ES Organizations Step";
                        begin
                            ESOganizationStep.RunModal();
                            UpdateESOrganizationsInfo();
                        end;
                    }
                    field(ESOrganizationsInfo; ESOrganizationsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'ES organizations set:';
                        Editable = false;
                        ToolTip = 'Specifies the number of ES orgnaizations fully set.';
                    }
                }
            }

            // ES Signers
            group(SetESSignersStep)
            {
                Visible = ESSignersStepVisible;
                group(SetESSignersStepInfo)
                {
                    Caption = 'Setup ES Signers.';
                    InstructionalText = 'Setup at least one ES Signer and create it at Fiskaly.';
                }
                group(OpenESSignersGroup)
                {
                    ShowCaption = false;
                    field(OpenESSigners; OpenESSignersLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ESSignersStep: Page "NPR ES Signers Step";
                        begin
                            ESSignersStep.RunModal();
                            UpdateESSignersInfo();
                        end;
                    }
                    field(ESSignersInfo; ESSignersCreated)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'ES signers created:';
                        Editable = false;
                        ToolTip = 'Specifies the number of ES signers created.';
                    }
                }
            }

            // ES Clients
            group(SetESClientsStep)
            {
                Visible = ESClientsStepVisible;
                group(SetESClientsStepInfo)
                {
                    Caption = 'Setup ES Clients.';
                    InstructionalText = 'Setup at least one ES Client and create it at Fiskaly.';
                }
                group(OpenESClientsGroup)
                {
                    ShowCaption = false;
                    field(OpenESClients; OpenESClientsLbl)
                    {
                        ApplicationArea = NPRRetail;
                        ShowCaption = false;
                        Style = StandardAccent;
                        StyleExpr = true;

                        trigger OnDrillDown()
                        var
                            ESClientsStep: Page "NPR ES Clients Step";
                        begin
                            ESClientsStep.RunModal();
                            UpdateESClientsInfo();
                        end;
                    }
                    field(ESClientsInfo; ESClientsSet)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'ES Clients created:';
                        Editable = false;
                        ToolTip = 'Specifies the number of ES Clients fully set.';
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
                    InstructionalText = 'Unable to complete ES Fiskaly Setup. Please ensure all required data is created and set correctly.';
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
        ESOrganizationsStepVisible: Boolean;
        ESSignersStepVisible: Boolean;
        ESClientsStepVisible: Boolean;
        BackActionEnabled: Boolean;
        DataPopulated: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        TopBannerVisible: Boolean;
        ESOrganizationsSet: Text[20];
        ESSignersCreated: Text[20];
        ESClientsSet: Text[20];
        Step: Option Start,ESOrganizations,ESSigners,ESClients,Finish;
        OpenESOrganizationsLbl: Label 'Open the ES organizations page to set them up.';
        OpenESSignersLbl: Label 'Open the ES signers page to set them up.';
        OpenESClientsLbl: Label 'Open the ES clients page to set them up.';

    local procedure CheckIsFiscalizationEnabled()
    var
        ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
        ESFiscalizationNotEnabledMsg: Label 'ES Fiscalization should be enabled in order to proceed with other setups.';
    begin
        if not ESAuditMgt.IsESFiscalizationEnabled() then begin
            Message(ESFiscalizationNotEnabledMsg);
            Error('');
        end;
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::ESOrganizations:
                ShowESOrganizationsStep();
            Step::ESSigners:
                ShowESSignersStep();
            Step::ESClients:
                ShowESClientsStep();
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

    local procedure ShowESOrganizationsStep()
    begin
        UpdateESOrganizationsInfo();
        ESOrganizationsStepVisible := true;
    end;

    local procedure ShowESSignersStep()
    begin
        UpdateESSignersInfo();
        ESSignersStepVisible := true;
    end;

    local procedure ShowESClientsStep()
    begin
        UpdateESClientsInfo();
        ESClientsStepVisible := true;
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
        DataPopulated := (ESOrganizationsSet <> '') and (ESSignersCreated <> '') and (ESClientsSet <> '');
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
        ESOrganizationsStepVisible := false;
        ESSignersStepVisible := false;
        ESClientsStepVisible := false;
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

    local procedure UpdateESOrganizationsInfo()
    var
        ESOrganization: Record "NPR ES Organization";
        ESSecretMgt: Codeunit "NPR AT Secret Mgt.";
        ESOrganizationsSetCounter: Integer;
    begin
        Clear(ESOrganizationsSet);

        ESOrganization.SetRange("Taxpayer Created", true);
        ESOrganization.SetRange(Disabled, false);
        if ESOrganization.IsEmpty() then
            exit;

        ESOrganization.FindSet();

        repeat
            if ESSecretMgt.GetSecretKey(ESOrganization.GetAPIKeyName()) <> '' then
                if ESSecretMgt.GetSecretKey(ESOrganization.GetAPISecretName()) <> '' then
                    ESOrganizationsSetCounter += 1;
        until ESOrganization.Next() = 0;

        if ESOrganizationsSetCounter <> 0 then
            ESOrganizationsSet := Format(ESOrganizationsSetCounter);
    end;

    local procedure UpdateESSignersInfo()
    var
        ESSigner: Record "NPR ES Signer";
        ESSignersCreatedCounter: Integer;
    begin
        ESSigner.SetRange(State, ESSigner.State::ENABLED);
        ESSignersCreatedCounter := ESSigner.Count();

        if ESSignersCreatedCounter <> 0 then
            ESSignersCreated := Format(ESSignersCreatedCounter);
    end;

    local procedure UpdateESClientsInfo()
    var
        ESClient: Record "NPR ES Client";
        ESClientsSetCounter: Integer;
    begin
        ESClient.SetRange(State, ESClient.State::ENABLED);
        ESClient.SetFilter("Invoice No. Series", '<>%1', '');
        ESClient.SetFilter("Complete Invoice No. Series", '<>%1', '');
        ESClient.SetFilter("Correction Invoice No. Series", '<>%1', '');
        ESClientsSetCounter := ESClient.Count();

        if ESClientsSetCounter <> 0 then
            ESClientsSet := Format(ESClientsSetCounter);
    end;

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(DataPopulated: Boolean)
    begin
    end;
}
