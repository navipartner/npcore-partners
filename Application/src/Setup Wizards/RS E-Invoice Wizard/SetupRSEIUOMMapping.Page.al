page 6184722 "NPR Setup RS EI UOM Mapping"
{
    Caption = 'Setup RS E-Invoice UOM Mapping';
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
                    Caption = 'Welcome to UOM Mapping Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This wizard will guide you through the process of mapping your units of measure to ensure consistency and accuracy across all your transactions. Proper UOM mapping is crucial for maintaining clear communication with your customers and partners, as well as for accurate inventory and billing records.';
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
            // RS EI Allowed UOM Step
            group(SetupAllowedUOMStep)
            {
                Visible = SetupAllowedUOMStepVisible;
                group(AllowedUOMStep)
                {
                    ShowCaption = false;
                    Editable = true;
                    InstructionalText = 'In this step, we will retrieve the list of allowed units of measure from SEF to ensure accuracy and compliance. Use Get Allowed UOM action to automatically populate the permitted units of measure. This will help standardize your data and ensure consistency across all your transactions.';
                    part(RSEIAllowedUOMSetupStep; "NPR RS EI Allowed UOM Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            // RS EI UOM Mapping Step
            group(SetupUOMMappingStep)
            {
                Visible = SetupUOMMappingStepVisible;

                group(UOMMappingStep)
                {
                    ShowCaption = false;
                    Editable = true;
                    InstructionalText = 'In this step, map your units of measure to the allowed units. This step ensures that all your units are standardized and aligned with the permitted measures. Select the appropriate allowed unit for each of your existing units to maintain consistency and accuracy in your records.';

                    part(RSEIUOMMappingSetupStep; "NPR RS EI UOM Mapping Step")
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
                    InstructionalText = 'You must map at least one unit of measure to proceed. Please ensure that at least one necessary unit is correctly mapped to the allowed units of measure before continuing.';
                    Visible = not RSEIUOMMappingDataToCreate;
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To finish the setup, choose Finish.';
                    Visible = RSEIUOMMappingDataToCreate;
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
        RSEIUOMMappingDataToCreate: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        NextActionEnabled: Boolean;
        SetupUOMMappingStepVisible: Boolean;
        TopBannerVisible: Boolean;
        SetupAllowedUOMStepVisible: Boolean;
        RSEIAllowedUOMDataToCreate: Boolean;
        Step: Option Start,SetupAllowedUOMStep,SetupUOMMappingStep,Finish;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::SetupAllowedUOMStep:
                ShowSetupAllowedUOMStep();
            Step::SetupUOMMappingStep:
                ShowSetupUOMMappingStep();
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

    local procedure ShowSetupAllowedUOMStep()
    begin
        CurrPage.RSEIAllowedUOMSetupStep.Page.CopyRealToTemp();
        SetupAllowedUOMStepVisible := true;
    end;

    local procedure ShowSetupUOMMappingStep()
    begin
        CurrPage.RSEIAllowedUOMSetupStep.Page.CreateRSEIAllowedUOMData();
        CurrPage.RSEIUOMMappingSetupStep.Page.CopyRealToTemp();
        SetupUOMMappingStepVisible := true;
    end;

    local procedure ShowFinishStep()
    begin
        CurrPage.RSEIUOMMappingSetupStep.Page.CreateRSEIUOMMappingData();
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := RSEIUOMMappingDataToCreate;
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RSEIAllowedUOMDataToCreate := CurrPage.RSEIAllowedUOMSetupStep.Page.RSEIAllowedUOMDataToCreate();
        RSEIUOMMappingDataToCreate := CurrPage.RSEIUOMMappingSetupStep.Page.RSEIUOMMappingDataToCreate();
    end;

    local procedure FinishAction();
    begin
        CurrPage.RSEIUOMMappingSetupStep.Page.CreateRSEIUOMMappingData();
        CurrPage.RSEIUOMMappingSetupStep.Page.CreateRSEIUOMMappingData();
        OnAfterFinishStep(RSEIAllowedUOMDataToCreate and RSEIUOMMappingDataToCreate);
        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        SetupAllowedUOMStepVisible := false;
        SetupUOMMappingStepVisible := false;
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