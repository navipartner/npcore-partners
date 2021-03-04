page 6014651 "NPR Retail Wizard"
{
    Caption = 'Retail Wizard';
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    Caption = 'Welcome to Retail Setup';
                    Visible = IntroStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this wizard to configure NP Retail.';
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

            // Company Info Step
            group(CompanyInfoStep)
            {
                Visible = CompanyInfoStepVisible;
                group(Empty)
                {
                    Caption = 'Create Company';
                    field(EmptyVar; EmptyVar)
                    {
                        Visible = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EmptyVar field';
                    }
                }
                group(CompanyInfo)
                {
                    Caption = 'Company Info';
                    part(CompanyInformationPG; "NPR Comp. Inf. Step")
                    {
                        ApplicationArea = All;
                        UpdatePropagation = Both;
                    }
                }
            }

            // POS Store Step
            group(POSStoreStep)
            {
                Visible = POSStoreStepVisible;
                group(POSStores)
                {
                    Caption = 'Create POS Stores';
                    group(Empty2)
                    {
                        Caption = '';
                        field(EmptyVar2; EmptyVar)
                        {
                            Visible = false;
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the EmptyVar field';
                        }
                    }
                    part(POSStoreListPG; "NPR POS Store List Step")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // POS Profiles Step
            group(POSProfileStep)
            {
                Visible = POSProfilesStepVisible;
                Caption = 'If code already exists, it will be incremented to the first available code.';
                group(POSProfiles)
                {
                    Caption = 'Create POS Profiles';
                    group(AuditProfile)
                    {
                        Caption = '';
                        part(POSAuditProfiles; "NPR POS Audit Profiles Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(ViewProfile)
                    {
                        Caption = '';
                        part(POSViewProfiles; "NPR POS View Profiles Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(EODProfile)
                    {
                        Caption = '';
                        part(POSEndOfDayProfiles; "NPR POS EOD Profiles Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(PostingProfile)
                    {
                        Caption = '';
                        part(POSPostingProfiles; "NPR POS Posting Profiles Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(EANBoxProfile)
                    {
                        Caption = '';
                        part(EANBoxSetups; "NPR Ean Box Setup Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(SalWorkflowSetProfile)
                    {
                        Caption = '';
                        part(POSSalesWorkflowSets; "NPR POS Sales Wfl. Sets Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(GlobalPOSSalesProfile)
                    {
                        Caption = '';
                        part(GlobalPOSSalesSetups; "NPR Glob. POS Sal. Setup Step")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }

            // POS Unit Step
            group(POSUnitStep)
            {
                Visible = POSUnitStepVisible;
                Caption = '';
                group(POSUnits)
                {
                    Caption = 'Create POS Units';
                    part(POSUnitListPG; "NPR POS Unit List Step")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // POS Payment Bins Step
            group(POSPaymentBinsStep)
            {
                Visible = POSPaymentBinStepVisible;
                group(PaymentBins)
                {
                    Caption = 'Create POS Payment Bins';
                    part(POSPaymentBinListPG; "NPR POS Payment Bins Step")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // POS Payment Method Step
            group(POSPaymentMethodStep)
            {
                Visible = POSPaymentMethodStepVisible;
                group(POSPaymentMethod)
                {
                    Caption = 'Create Payment Methods';

                    part(POSPaymentMethodsPG; "NPR POS Pmt. Method List Step")
                    {
                        ApplicationArea = All;
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
                        ApplicationArea = All;
                    }
                }
            }

            // Salesperson
            group(SalespersonStep)
            {
                Visible = SalespersonStepVisible;
                group(Salespersons)
                {
                    Caption = 'Create Salespeople';
                    part(SalespersonListPG; "NPR Salesperson/Purchaser Step")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // User Setup Step
            group(UserSetupStep)
            {
                Visible = UserSetupStepVisible;
                group(UserSetup)
                {
                    Caption = 'User setup';
                    part(UserSetupPG; "NPR User Setup Step")
                    {
                        ApplicationArea = All;
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
                    Caption = '';
                    group(MandatoryDataMissing)
                    {
                        Caption = 'The following data won''t be created: ';
                        Visible = not AllDataFilledIn;
                        group(CompanyInfoDataMissing)
                        {
                            Caption = '';
                            Visible = not CompanyInfoDataToCreate;
                            field(CompanyInfoLabel; CompanyInfoLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the CompanyInfoLabel field';
                            }
                        }
                        group(POSStoreDataMissing)
                        {
                            Caption = '';
                            Visible = not POSStoreDataToCreate;
                            field(POSStoreLabel; POSStoreLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSStoreLabel field';
                            }
                        }
                        group(Profiles)
                        {
                            Caption = '';
                            Visible = POSProfileDataMissing;
                            field(ProfilesLabel; ProfilesLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the ProfilesLabel field';
                            }
                            group(POSAuditProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSAuditProfileDataToCreate;
                                field(POSAuditProfileLabel; POSAuditProfileLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the POSAuditProfileLabel field';
                                }
                            }
                            group(POSViewProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSViewProfileDataToCreate;
                                field(POSViewProfileLabel; POSViewProfileLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the POSViewProfileLabel field';
                                }
                            }
                            group(POSEndOfDayProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSEndOfDayProfileDataToCreate;
                                field(POSEndOfDayProfileLabel; POSEndOfDayProfileLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the POSEndOfDayProfileLabel field';
                                }
                            }
                            group(POSPostingProfileDataMissing)
                            {
                                Caption = '';
                                Visible = not POSPostingProfileDataToCreate;
                                field(POSPostingProfileLabel; POSPostingProfileLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the POSPostingProfileLabel field';
                                }
                            }
                            group(EanBoxSetupDataMissing)
                            {
                                Caption = '';
                                Visible = not EanBoxSetupDataToCreate;
                                field(EanBoxSalesSetupLabel; EanBoxSetupLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the EanBoxSetupLabel field';
                                }
                            }
                            group(POSSalesWorkflowSetDataMissing)
                            {
                                Caption = '';
                                Visible = not POSSalesWorkflowSetDataToCreate;
                                field(POSSalesWorkflowLabel; POSSalesWorkflowLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the POSSalesWorkflowLabel field';
                                }
                            }
                            group(GlobalPOSSalesSetupDataMissing)
                            {
                                Caption = '';
                                Visible = not GlobalPOSSalesSetupDataToCreate;
                                field(GlobalPOSSalesSetupLabel; GlobalPOSSalesSetupLabel)
                                {
                                    Caption = '';
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the value of the GlobalPOSSalesSetupLabel field';
                                }
                            }
                        }
                        group(POSUnitDataMissing)
                        {
                            Caption = '';
                            Visible = not POSUnitDataToCreate;
                            field(POSUnitLabel; POSUnitLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSUnitLabel field';
                            }
                        }
                        group(POSPaymentBinDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPaymentBinDataToCreate;
                            field(POSPaymentBinLabel; POSPaymentBinLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSPaymentBinLabel field';
                            }
                        }
                        group(POSPaymentMethodDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPaymentMethodDataToCreate;
                            field(POSPaymentMethodLabel; POSPaymentMethodLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';
                            }
                        }
                        group(POSPostingSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not POSPostingSetupDataToCreate;
                            field(POSPostingSetupLabel; POSPostingSetupLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSPostingSetupLabel field';
                            }
                        }
                        group(SalespersonDataMissing)
                        {
                            Caption = '';
                            Visible = not SalespersonDataToCreate;
                            field(SalespersonLabel; SalespersonLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the SalespersonLabel field';
                            }
                        }
                        group(UserSetupDataMissing)
                        {
                            Caption = '';
                            Visible = not UserSetupDataToCreate;
                            field(UserSetupLabel; UserSetupLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the UserSetupLabel field';
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
                group(MandatoryDataFilledIn)
                {
                    Caption = 'The following data will be created: ';
                    Visible = AnyDataToCreate;

                    group(CompanyInfoDataExists)
                    {
                        Caption = '';
                        Visible = CompanyInfoDataToCreate;
                        field(CompanyInfoLabel1; CompanyInfoLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the CompanyInfoLabel field';
                        }
                    }
                    group(POSStoreDataExists)
                    {
                        Caption = '';
                        Visible = POSStoreDataToCreate;
                        field(POSStoreLabel1; POSStoreLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the POSStoreLabel field';
                        }
                    }
                    group(Profiles1)
                    {
                        Caption = '';
                        Visible = POSProfileDataToCreate;
                        field(ProfilesLabel1; ProfilesLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the ProfilesLabel field';
                        }
                        group(POSAuditProfileDataExists)
                        {
                            Caption = '';
                            Visible = POSAuditProfileDataToCreate;
                            field(POSAuditProfileLabel1; POSAuditProfileLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSAuditProfileLabel field';
                            }
                        }
                        group(POSViewProfileDataExists)
                        {
                            Caption = '';
                            Visible = POSViewProfileDataToCreate;
                            field(POSViewProfileLabel1; POSViewProfileLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSViewProfileLabel field';
                            }
                        }
                        group(POSEndOfDayProfileExists)
                        {
                            Caption = '';
                            Visible = POSEndOfDayProfileDataToCreate;
                            field(POSEndOfDayProfileLabel1; POSEndOfDayProfileLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSEndOfDayProfileLabel field';
                            }
                        }
                        group(POSPostingProfileDataExists)
                        {
                            Caption = '';
                            Visible = POSPostingProfileDataToCreate;
                            field(POSPostingProfileLabel1; POSPostingProfileLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSPostingProfileLabel field';
                            }
                        }
                        group(EanBoxSetupDataExists)
                        {
                            Caption = '';
                            Visible = EanBoxSetupDataToCreate;
                            field(EanBoxSalesSetupLabel1; EanBoxSetupLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the EanBoxSetupLabel field';
                            }
                        }
                        group(POSSalesWorkflowSetDataExisting)
                        {
                            Caption = '';
                            Visible = POSSalesWorkflowSetDataToCreate;
                            field(POSSalesWorkflowLabel1; POSSalesWorkflowLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the POSSalesWorkflowLabel field';
                            }
                        }
                        group(GlobalPOSSalesSetupDataExists)
                        {
                            Caption = '';
                            Visible = GlobalPOSSalesSetupDataToCreate;
                            field(GlobalPOSSalesSetupLabel1; GlobalPOSSalesSetupLabel)
                            {
                                Caption = '';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the GlobalPOSSalesSetupLabel field';
                            }
                        }
                    }
                    group(POSUnitDataExists)
                    {
                        Caption = '';
                        Visible = POSUnitDataToCreate;
                        field(POSUnitLabel1; POSUnitLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the POSUnitLabel field';
                        }
                    }
                    group(POSPaymentBinDataExists)
                    {
                        Caption = '';
                        Visible = POSPaymentBinDataToCreate;
                        field(POSPaymentBinLabel1; POSPaymentBinLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the POSPaymentBinLabel field';
                        }
                    }
                    group(POSPaymentMethodDataExists)
                    {
                        Caption = '';
                        Visible = POSPaymentMethodDataToCreate;
                        field(POSPaymentMethodLabel1; POSPaymentMethodLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the POSPaymentMethodLabel field';
                        }
                    }
                    group(POSPostingSetupDataExists)
                    {
                        Caption = '';
                        Visible = POSPostingSetupDataToCreate;
                        field(POSPostingSetupLabel1; POSPostingSetupLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the POSPostingSetupLabel field';
                        }
                    }
                    group(SalespersonDataExists)
                    {
                        Caption = '';
                        Visible = SalespersonDataToCreate;
                        field(SalespersonLabel1; SalespersonLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the SalespersonLabel field';
                        }
                    }
                    group(UserSetupDataExists)
                    {
                        Caption = '';
                        Visible = UserSetupDataToCreate;
                        field(UserSetupLabel1; UserSetupLabel)
                        {
                            Caption = '';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the UserSetupLabel field';
                        }
                    }
                }
                group(AnyDataFilledInMsg)
                {
                    Caption = '';
                    InstructionalText = 'To create the data, choose Finish.';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
                ApplicationArea = All;
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
        SalespersonBuffer.DeleteAll();
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
        SalespersonBuffer: Record "NPR Salesperson Buffer";
        POSStore: Record "NPR POS Store" temporary;
        TempAllPOSStore: Record "NPR POS Store" temporary;
        POSAuditProfile: Record "NPR POS Audit Profile" temporary;
        TempAllPOSAuditProfile: Record "NPR POS Audit Profile" temporary;
        POSViewProfile: Record "NPR POS View Profile" temporary;
        TempAllPOSViewProfile: Record "NPR POS View Profile" temporary;
        POSEndOfDayProfile: Record "NPR POS End of Day Profile" temporary;
        TempAllPOSEndOfDayProfile: Record "NPR POS End of Day Profile" temporary;
        POSPostingProfile: Record "NPR POS Posting Profile" temporary;
        TempAllPOSPostingProfile: Record "NPR POS Posting Profile" temporary;
        EanBoxSetup: Record "NPR Ean Box Setup" temporary;
        TempAllEanBoxSetup: Record "NPR Ean Box Setup" temporary;
        POSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;
        TempAllPOSSalesWorkflowSet: Record "NPR POS Sales Workflow Set" temporary;
        GlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;
        TempAllGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;
        POSUnitToCreate: Record "NPR POS Unit" temporary;
        TempAllPOSUnit: Record "NPR POS Unit" temporary;
        POSPaymentBinToCreate: Record "NPR POS Payment Bin" temporary;
        TempAllPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        TempAllPOSPaymentMethod: Record "NPR POS Payment Method" temporary;
        TempAllSalesperson: Record "NPR Salesperson Buffer" temporary;
        TempAllUser: Record User temporary;
        Step: Option Start,CompanyInfoStep,POSStoresStep,POSProfilesStep,POSUnitStep,POSPaymentBinStep,POSPaymentMethodStep,POSPostingSetupStep,SalespersonStep,UserSetupStep,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        IntroStepVisible: Boolean;
        CompanyInfoStepVisible: Boolean;
        POSStoreStepVisible: Boolean;
        POSProfilesStepVisible: Boolean;
        POSUnitStepVisible: Boolean;
        POSPaymentBinStepVisible: Boolean;
        POSPaymentMethodStepVisible: Boolean;
        POSPostingSetupStepVisible: Boolean;
        SalespersonStepVisible: Boolean;
        UserSetupStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        EmptyVar: Integer;
        AllDataFilledIn: Boolean;
        IntroDataToCreate: Boolean;
        CompanyInfoDataToCreate: Boolean;
        POSStoreDataToCreate: Boolean;
        POSProfileDataToCreate: Boolean;
        POSProfileDataMissing: Boolean;
        POSAuditProfileDataToCreate: Boolean;
        POSViewProfileDataToCreate: Boolean;
        POSEndOfDayProfileDataToCreate: Boolean;
        POSPostingProfileDataToCreate: Boolean;
        EanBoxSetupDataToCreate: Boolean;
        POSSalesWorkflowSetDataToCreate: Boolean;
        GlobalPOSSalesSetupDataToCreate: Boolean;
        POSUnitDataToCreate: Boolean;
        POSPaymentBinDataToCreate: Boolean;
        POSPaymentMethodDataToCreate: Boolean;
        POSPostingSetupDataToCreate: Boolean;
        SalespersonDataToCreate: Boolean;
        UserSetupDataToCreate: Boolean;
        AnyDataToCreate: Boolean;
        CompanyInfoLabel: Label '- Company Information';
        POSStoreLabel: Label '- POS Store';
        ProfilesLabel: Label '- Profiles: ';
        POSAuditProfileLabel: Label '---- POS Audit Profile';
        POSViewProfileLabel: Label '---- POS View Profile';
        POSEndOfDayProfileLabel: Label '---- POS End of Day Profile';
        POSPostingProfileLabel: Label '---- POS Posting Profile';
        EanBoxSetupLabel: Label '---- Ean Box Setup';
        POSSalesWorkflowLabel: Label '---- POS Sales Workflow Set';
        GlobalPOSSalesSetupLabel: Label '---- Global POS Sales Setup';
        POSUnitLabel: Label '- POS Unit';
        POSPaymentBinLabel: Label '- POS Payment Bin';
        POSPaymentMethodLabel: Label '- POS Payment Method';
        POSPostingSetupLabel: Label '- POS Posting Setup';
        SalespersonLabel: Label '- Salespeople';
        UserLabel: Label '- User';
        UserSetupLabel: Label '- User Setup';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowIntroStep();
            Step::CompanyInfoStep:
                ShowCompanyInfoStep();
            Step::POSStoresStep:
                ShowPOSStoreStep();
            Step::POSProfilesStep:
                ShowPOSProfilesStep();
            Step::POSUnitStep:
                ShowPOSUnitStep();
            Step::POSPaymentBinStep:
                ShowPOSPaymentBinStep();
            Step::POSPaymentMethodStep:
                ShowPOSPaymentMethodStep();
            Step::POSPostingSetupStep:
                ShowPOSPostingSetupStep();
            Step::SalespersonStep:
                ShowSalespersonStep();
            Step::UserSetupStep:
                ShowUserSetupStep();
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

    local procedure ShowCompanyInfoStep()
    begin
        CompanyInfoStepVisible := true;
    end;

    local procedure ShowPOSStoreStep()
    begin
        POSStoreStepVisible := true;
    end;

    local procedure ShowPOSProfilesStep()
    begin
        POSProfilesStepVisible := true;

        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.POSEndOfDayProfiles.Page.SetGlobals(TempAllPOSUnit);
    end;

    local procedure ShowPOSUnitStep()
    begin
        POSUnitStepVisible := true;

        CurrPage.POSStoreListPG.Page.GetRec(POSStore);
        CurrPage.POSStoreListPG.Page.CopyRealAndTemp(TempAllPOSStore);

        CurrPage.POSAuditProfiles.Page.GetRec(POSAuditProfile);
        CurrPage.POSAuditProfiles.Page.CopyRealAndTemp(TempAllPOSAuditProfile);
        CurrPage.POSViewProfiles.Page.GetRec(POSViewProfile);
        CurrPage.POSViewProfiles.Page.CopyRealAndTemp(TempAllPOSViewProfile);
        CurrPage.POSEndOfDayProfiles.Page.GetRec(POSEndOfDayProfile);
        CurrPage.POSEndOfDayProfiles.Page.CopyRealAndTemp(TempAllPOSEndOfDayProfile);
        CurrPage.POSPostingProfiles.Page.GetRec(POSPostingProfile);
        CurrPage.POSPostingProfiles.Page.CopyRealAndTemp(TempAllPOSPostingProfile);
        CurrPage.EANBoxSetups.Page.GetRec(EanBoxSetup);
        CurrPage.EANBoxSetups.Page.CopyRealAndTemp(TempAllEanBoxSetup);
        CurrPage.POSSalesWorkflowSets.Page.GetRec(POSSalesWorkflowSet);
        CurrPage.POSSalesWorkflowSets.Page.CopyRealAndTemp(TempAllPOSSalesWorkflowSet);
        CurrPage.GlobalPOSSalesSetups.Page.GetRec(GlobalPOSSalesSetup);
        CurrPage.GlobalPOSSalesSetups.Page.CopyRealAndTemp(TempAllGlobalPOSSalesSetup);

        CurrPage.POSUnitListPG.Page.SetGlobals(TempAllPOSStore,
                                               TempAllPOSAuditProfile,
                                               TempAllPOSViewProfile,
                                               TempAllPOSEndOfDayProfile,
                                               TempAllPOSPostingProfile,
                                               TempAllEanBoxSetup,
                                               TempAllPOSSalesWorkflowSet,
                                               TempAllGlobalPOSSalesSetup);
    end;

    local procedure ShowPOSPaymentBinStep()
    begin
        POSPaymentBinStepVisible := true;

        CurrPage.POSUnitListPG.Page.GetRec(POSUnitToCreate);
        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.POSPaymentBinListPG.Page.SetGlobals(TempAllPOSUnit);
    end;

    local procedure ShowPOSPaymentMethodStep()
    begin
        POSPaymentMethodStepVisible := true;

        CurrPage.POSPaymentBinListPG.Page.GetRec(POSPaymentBinToCreate);
    end;

    local procedure ShowPOSPostingSetupStep()
    begin
        POSPostingSetupStepVisible := true;

        CurrPage.POSStoreListPG.Page.CopyRealAndTemp(TempAllPOSStore);
        CurrPage.POSPaymentBinListPG.Page.CopyRealAndTemp(TempAllPOSPaymentBin);
        CurrPage.POSPaymentMethodsPG.Page.CopyRealAndTemp(TempAllPOSPaymentMethod);
        CurrPage.POSPostingSetupPG.Page.SetGlobals(TempAllPOSStore, TempAllPOSPaymentMethod, TempAllPOSPaymentBin);
    end;

    local procedure ShowSalespersonStep()
    begin
        SalespersonStepVisible := true;
    end;

    local procedure ShowUserSetupStep()
    begin
        UserSetupStepVisible := true;

        CurrPage.UserSetupPG.Page.CopyRealAndTempUsers(TempAllUser);
        CurrPage.SalespersonListPG.Page.CopyRealAndTemp(TempAllSalesperson);
        CurrPage.POSUnitListPG.Page.CopyRealAndTemp(TempAllPOSUnit);
        CurrPage.UserSetupPG.Page.SetGlobals(TempAllSalesperson, TempAllUser, TempAllPOSUnit);
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
        CompanyInfoDataToCreate := CurrPage.CompanyInformationPG.Page.MandatoryDataFilledIn();
        POSStoreDataToCreate := CurrPage.POSStoreListPG.Page.POSStoresToCreate();

        POSAuditProfileDataToCreate := CurrPage.POSAuditProfiles.Page.POSAuditProfileDataToCreate();
        POSViewProfileDataToCreate := CurrPage.POSViewProfiles.Page.POSViewProfileDataToCreate();
        POSEndOfDayProfileDataToCreate := CurrPage.POSEndOfDayProfiles.Page.POSEndOfDayProfileDataToCreate();
        POSPostingProfileDataToCreate := CurrPage.POSPostingProfiles.Page.POSPOSPostingProfileDataToCreate();
        EanBoxSetupDataToCreate := CurrPage.EANBoxSetups.Page.EanBoxSetupDataToCreate();
        POSSalesWorkflowSetDataToCreate := CurrPage.POSSalesWorkflowSets.Page.POSSalesWorkflowSetDataToCreate();
        GlobalPOSSalesSetupDataToCreate := CurrPage.GlobalPOSSalesSetups.Page.GlobalPOSSalesSetupDataToCreate();

        POSProfileDataToCreate := POSAuditProfileDataToCreate or
                                  POSViewProfileDataToCreate or
                                  POSEndOfDayProfileDataToCreate or
                                  POSPostingProfileDataToCreate or
                                  EanBoxSetupDataToCreate or
                                  POSSalesWorkflowSetDataToCreate or
                                  GlobalPOSSalesSetupDataToCreate;

        POSProfileDataMissing := not POSAuditProfileDataToCreate or
                                 not POSViewProfileDataToCreate or
                                 not POSEndOfDayProfileDataToCreate or
                                 not POSPostingProfileDataToCreate or
                                 not EanBoxSetupDataToCreate or
                                 not POSSalesWorkflowSetDataToCreate or
                                 not GlobalPOSSalesSetupDataToCreate;

        POSUnitDataToCreate := CurrPage.POSUnitListPG.Page.POSUnitsToCreate();
        POSPaymentBinDataToCreate := CurrPage.POSPaymentBinListPG.Page.POSPaymentBinsToCreate();
        POSPaymentMethodDataToCreate := CurrPage.POSPaymentMethodsPG.Page.POSPaymentMethodsToCreate();
        POSPostingSetupDataToCreate := CurrPage.POSPostingSetupPG.Page.POSPostingSetupToCreate();
        SalespersonDataToCreate := CurrPage.SalespersonListPG.Page.SalespersonsToCreate();
        UserSetupDataToCreate := CurrPage.UserSetupPG.Page.UserSetupsToCreate();

        AllDataFilledIn := CompanyInfoDataToCreate and
                           POSStoreDataToCreate and
                           POSAuditProfileDataToCreate and
                           POSViewProfileDataToCreate and
                           POSEndOfDayProfileDataToCreate and
                           POSPostingProfileDataToCreate and
                           EanBoxSetupDataToCreate and
                           POSSalesWorkflowSetDataToCreate and
                           GlobalPOSSalesSetupDataToCreate and
                           POSUnitDataToCreate and
                           POSPaymentBinDataToCreate and
                           POSPaymentMethodDataToCreate and
                           POSPostingSetupDataToCreate and
                           SalespersonDataToCreate and
                           UserSetupDataToCreate;

        AnyDataToCreate := CompanyInfoDataToCreate or
                           POSStoreDataToCreate or
                           POSAuditProfileDataToCreate or
                           POSViewProfileDataToCreate or
                           POSEndOfDayProfileDataToCreate or
                           POSPostingProfileDataToCreate or
                           EanBoxSetupDataToCreate or
                           POSSalesWorkflowSetDataToCreate or
                           GlobalPOSSalesSetupDataToCreate or
                           POSUnitDataToCreate or
                           POSPaymentBinDataToCreate or
                           POSPaymentMethodDataToCreate or
                           POSPostingSetupDataToCreate or
                           SalespersonDataToCreate or
                           UserSetupDataToCreate;
    end;

    local procedure FinishAction();
    begin
        CurrPage.CompanyInformationPG.Page.CreateCompanyInfoData();
        CurrPage.POSStoreListPG.Page.CreatePOSStoreData();

        CurrPage.POSAuditProfiles.Page.CreatePOSAuditProfileData();
        CurrPage.POSViewProfiles.Page.CreatePOSViewProfileData();
        CurrPage.POSEndOfDayProfiles.Page.CreatePOSEndOfDayProfileData();
        CurrPage.POSPostingProfiles.Page.CreatePOSPOSPostingProfileData();
        CurrPage.EANBoxSetups.Page.CreateEanBoxSetupData();
        CurrPage.POSSalesWorkflowSets.Page.CreatePOSSalesWorkflowSetData();
        CurrPage.GlobalPOSSalesSetups.Page.CreateNpGlobalPOSSalesSetupData();

        CurrPage.POSUnitListPG.Page.CreatePOSUnitData(POSUnitToCreate);
        CurrPage.POSPaymentBinListPG.Page.CreatePOSPaymentBinData(POSPaymentBinToCreate);
        CurrPage.POSPaymentMethodsPG.Page.CreatePOSPaymentMethodData();
        CurrPage.POSPostingSetupPG.Page.CreatePOSPostingSetupData();
        CurrPage.SalespersonListPG.Page.CreateSalespersonData();
        CurrPage.UserSetupPG.Page.CreateUserSetupData();

        SalespersonBuffer.DeleteAll();

        CurrPage.Close();
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        IntroStepVisible := false;
        CompanyInfoStepVisible := false;
        POSStoreStepVisible := false;
        POSProfilesStepVisible := false;
        POSUnitStepVisible := false;
        POSPaymentBinStepVisible := false;
        POSPaymentMethodStepVisible := false;
        POSPostingSetupStepVisible := false;
        SalespersonStepVisible := false;
        UserSetupStepVisible := false;
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
}