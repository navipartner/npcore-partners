page 6150792 "NPR Create Retail Vchr. Types"
{
    Caption = 'Create Retail Voucher Types';
    PageType = NavigatePage;
    Extensible = false;

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
                    Caption = 'Welcome to POS Stores & Units Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Utilize this wizard to generate Retail Voucher Types, streamlining the process of defining and managing critical parameters. In the following steps, you will be prompted to enter the necessary information, including the associated posting account, print template, number series and barcode references. Upon completion, you retain the flexibility to review and modify the generated data, ensuring a seamless and tailored setup for your Retail Voucher Types.';
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

            group(RetailVoucherTypesCreateStep)
            {
                Visible = CreateRetailVoucherTypesStepVisible;
                group(RetailVoucherTypesCreate)
                {
                    Caption = 'Create Retail Voucher Types';
                    group(Empty1)
                    {
                        Caption = '';
                        field(EmptyVar1; EmptyVar)
                        {
                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(RetailVoucherTypesPG; "NPR Retail Voucher Types Step")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }

            group(RetailVoucherTypesModifyStep)
            {
                Visible = ModifyRetailVoucherTypesStepVisible;
                group(RetailVoucherTypesModify)
                {
                    Caption = 'Modify Retail Voucher Types';
                    group(Empty3)
                    {
                        Caption = '';
                        field(EmptyVar3; EmptyVar)
                        {

                            Caption = ' ';
                            ToolTip = 'Specifies the value of the EmptyVar field';
                            Visible = false;
                            ApplicationArea = NPRRetail;
                        }
                    }
                    part(RetailVoucherTypesModifyPG; "NPR Vchr. Types Modify Step")
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
                    Visible = RetailVoucherTypesDataToCreate;
                    group(MandatoryDataMissing)
                    {
                        group(RetailVoucherTypesDataMissing)
                        {
                            Caption = '';
                            Visible = RetailVoucherTypesDataToCreate;

                            label(RetailVoucherTypesLabel)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = '- Retail Voucher Types';
                            }
                        }
                    }
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
        TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary;
        AnyDataToCreate: Boolean;
        BackActionEnabled: Boolean;
        CreateRetailVoucherTypesStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        FinishStepVisible: Boolean;
        IntroStepVisible: Boolean;
        ModifyRetailVoucherTypesStepVisible: Boolean;
        NextActionEnabled: Boolean;
        RetailVoucherTypesDataToCreate: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        Step: Option Start,CreateRetailVoucherTypes,ModifyRetailVoucherTypes,Finish;
        MandatoryFieldsNotPopulatedErrLbl: Label 'Fields marked with a red star (*) are mandatory. Ensure all required fields are populated in order to continue.';


    #region HANDLE STEPS FUNCTIONS

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CreateRetailVoucherTypes:
                ShowCreateRetailVoucherTypesStep();
            Step::ModifyRetailVoucherTypes:
                ShowModifyRetailVoucherTypesStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure ShowIntroStep()
    begin
        IntroStepVisible := true;
        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinishStep()
    begin
        CheckIfDataFilledIn();
        FinishStepVisible := true;
        FinishActionEnabled := true;
        NextActionEnabled := false;
        CreateRetailVoucherTypesStepVisible := false;
        ModifyRetailVoucherTypesStepVisible := false;
    end;

    local procedure ShowCreateRetailVoucherTypesStep()
    begin
        CreateRetailVoucherTypesStepVisible := true;
        ModifyRetailVoucherTypesStepVisible := false;
    end;

    local procedure ShowModifyRetailVoucherTypesStep()
    begin
        ModifyRetailVoucherTypesStepVisible := true;
        CreateRetailVoucherTypesStepVisible := false;
        CurrPage.RetailVoucherTypesPG.Page.CopyTempRetailVoucherTypes(TempNpRvVoucherType);
        CurrPage.RetailVoucherTypesModifyPG.Page.CopyTemp(TempNpRvVoucherType);
    end;

    #endregion HANDLE STEPS FUNCTIONS

    #region HELPER FUNCTIONS

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        FinishStepVisible := false;
        CreateRetailVoucherTypesStepVisible := false;
        ModifyRetailVoucherTypesStepVisible := false;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step = Step::CreateRetailVoucherTypes) and (not Backwards) then
            CurrPage.RetailVoucherTypesPG.Page.CreateTempRetailVoucherTypes();

        if (Step = Step::CreateRetailVoucherTypes) and (not Backwards) then
            if not CurrPage.RetailVoucherTypesPG.Page.MandatoryFieldsPopulated() then
                Error(MandatoryFieldsNotPopulatedErrLbl);

        if (Step = Step::ModifyRetailVoucherTypes) and (not Backwards) then
            if not CurrPage.RetailVoucherTypesModifyPG.Page.MandatoryFieldsPopulated() then
                Error(MandatoryFieldsNotPopulatedErrLbl);

        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure CheckIfDataFilledIn()
    begin
        RetailVoucherTypesDataToCreate := CurrPage.RetailVoucherTypesPG.Page.RetailVoucherTypesToCreate();
        AnyDataToCreate := RetailVoucherTypesDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.RetailVoucherTypesModifyPG.Page.CreateRetailVoucherTypesData();
        OnAfterFinishStep(AnyDataToCreate);
        CurrPage.Close();
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

    #endregion HELPER FUNCTIONS

    [BusinessEvent(false)]
    local procedure OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
    end;
}