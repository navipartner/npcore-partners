page 6014400 "NPR Magento Wizard"
{
    Caption = 'NP Magento Wizard';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
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
                }
            }

            group(Step1)
            {
                Visible = StartStepVisible;
                group("Welcome to Magento")
                {
                    Caption = 'Welcome to Magento Setup';
                    Visible = StartStepVisible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'Use this Wizard to configure Magento settings.';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'Click Next to start the process.';
                    }
                }
            }

            // Magento Website Step
            group(MagentoWebsiteStep)
            {
                Visible = MagentoWebsiteStepVisible;
                group(MagentoWebsite)
                {
                    Caption = 'Magento Website';
                    part(MagentoWebsites; "NPR Website List WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Store Step
            group(MagentoStoreStep)
            {
                Visible = MagentoStoreStepVisible;
                group(MagentoStore)
                {
                    Caption = 'Magento Store';
                    part(MagentoStores; "NPR Stores WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Customer Mapping Step
            group(MagentoCustomerMappingStep)
            {
                Visible = MagentoCustomerMappingStepVisible;
                group(MagentoCustomerMapping)
                {
                    Caption = 'Magento Customer Mapping';
                    part(MagentCustMappings; "NPR Customer Mapping WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Payment Gateway Step
            group(MagentoPaymentGatewayStep)
            {
                Visible = MagentoPaymentGatewayStepVisible;
                group(MagentoPaymentGateway)
                {
                    Caption = 'Magento Payment Gateway';
                    part(MagentoPaymentGateways; "NPR Payment Gateways WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Payment Mapping Step
            group(MagentoPaymentMappingStep)
            {
                Visible = MagentoPaymentMappingStepVisible;
                group(MagentoPaymentMapping)
                {
                    Caption = 'Magento Payment Mapping';
                    part(MagentoPaymentMappings; "NPR Payment Mapping WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Shippment Mapping Step
            group(MagentoShippmentMappingStep)
            {
                Visible = MagentoShippmentMappingStepVisible;
                group(MagentoShippmentMapping)
                {
                    Caption = 'Magento Shippment Mapping';
                    part(MagentoShippingMappings; "NPR Shipment Mapping WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Brand Step
            group(MagentoBrandStep)
            {
                Visible = MagentoBrandStepVisible;
                group(MagentoBrand)
                {
                    Caption = 'Magento Brand';
                    part(MagentoBrands; "NPR Brands WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Display Group Step
            group(MagentoDisplayGroupStep)
            {
                Visible = MagentoDisplayGroupStepVisible;
                group(MagentoDisplayGroup)
                {
                    Caption = 'Magento Display Group';
                    part(MagentoDisplayGroups; "NPR Display Groups WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            // Magento Display Config Step
            group(MagentoDisplayConfigStep)
            {
                Visible = MagentoDisplayConfigStepVisible;
                group(MagentoDisplayConfig)
                {
                    Caption = 'Magento Display Config';
                    part(MagentoDisplayConfigs; "NPR Display Config WP")
                    {
                        ApplicationArea = All;
                    }
                }
            }

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
                        group(MagentoStoreMissing)
                        {
                            Caption = '';
                            Visible = not MagentoStoreDataFilledIn;
                            field(MagentoStoreLabel; MagentoStoreLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoWebsiteMissing)
                        {
                            Caption = '';
                            Visible = not MagentoWebsiteDataFilledIn;
                            field(MagentoWebsiteLabel; MagentoWebsiteLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoCustomerMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoCustomerMappingDataFilledIn;
                            field(MagentoCustomerMappingLabel; MagentoCustomerMappingLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoPaymentGatewaygMissing)
                        {
                            Caption = '';
                            Visible = not MagentoPaymentGatewayDataFilledIn;
                            field(MagentoPaymentGatewayLabel; MagentoPaymentGatewayLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoPaymentMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoPaymentMappingDataFilledIn;
                            field(MagentoPaymentMappingLabel; MagentoPaymentMappingLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoShippmentMappingMissing)
                        {
                            Caption = '';
                            Visible = not MagentoShippmentMappingDataFilledIn;
                            field(MagentoShippmentMappingLabel; MagentoShippmentMappingLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoBrandMissing)
                        {
                            Caption = '';
                            Visible = not MagentoBrandDataFilledIn;
                            field(MagentoBrandsLabel; MagentoBrandLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoDisplayGroupMissing)
                        {
                            Caption = '';
                            Visible = not MagentoDisplayGroupDataFilledIn;
                            field(MagentoDisplayGroupLabel; MagentoDisplayGroupLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
                            }
                        }
                        group(MagentoDisplayConfigMissing)
                        {
                            Caption = '';
                            Visible = not MagentoDisplayConfigDataFilledIn;
                            field(MagentoDisplayConfigLabel; MagentoDisplayConfigLabel)
                            {
                                ApplicationArea = All;
                                Caption = '';
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

                    group(MagentoStoreExists)
                    {
                        Caption = '';
                        Visible = MagentoStoreDataFilledIn;
                        field(MagentoStoreLabel1; MagentoStoreLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoWebsiteExists)
                    {
                        Caption = '';
                        Visible = MagentoWebsiteDataFilledIn;
                        field(MagentoWebsiteLabel1; MagentoWebsiteLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoCustomerMappingExists)
                    {
                        Caption = '';
                        Visible = MagentoCustomerMappingDataFilledIn;
                        field(MagentoCustomerMappingLabel1; MagentoCustomerMappingLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoPaymentGatewaygExists)
                    {
                        Caption = '';
                        Visible = MagentoPaymentGatewayDataFilledIn;
                        field(MagentoPaymentGatewayLabel1; MagentoPaymentGatewayLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoPaymentMappingExists)
                    {
                        Caption = '';
                        Visible = MagentoPaymentMappingDataFilledIn;
                        field(MagentoPaymentMappingLabel1; MagentoPaymentMappingLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoShippmentMappingExists)
                    {
                        Caption = '';
                        Visible = MagentoShippmentMappingDataFilledIn;
                        field(MagentoShippmentMappingLabel1; MagentoShippmentMappingLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoBrandsExists)
                    {
                        Caption = '';
                        Visible = MagentoBrandDataFilledIn;
                        field(MagentoBrandsLabel1; MagentoBrandLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoDisplayGroupExists)
                    {
                        Caption = '';
                        Visible = MagentoDisplayGroupDataFilledIn;
                        field(MagentoDisplayGroupLabel1; MagentoDisplayGroupLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
                        }
                    }
                    group(MagentoDisplayConfigExists)
                    {
                        Caption = '';
                        Visible = MagentoDisplayConfigDataFilledIn;
                        field(MagentoDisplayConfigLabel1; MagentoDisplayConfigLabel)
                        {
                            ApplicationArea = All;
                            Caption = '';
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
        Step := Step::StartStep;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        TempMagentoWebsiteGlobal: Record "NPR Magento Website" temporary;
        TempMagentPaymentGatewayGlobal: Record "NPR Magento Payment Gateway" temporary;
        TempMagentoBrand: Record "NPR Magento Brand" temporary;
        TempMagDisplayGroup: Record "NPR Magento Display Group" temporary;
        Step: Option StartStep,MagentoWebsiteStep,MagentoStoreStep,MagentoCustomerMappingStep,MagentoPaymentGatewayStep,MagentoPaymentMappingStep,MagentoShippmentMappingStep,MagentoBrandStep,MagentoDisplayGroupStep,MagentoDisplayConfigStep,FinishStep;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        StartStepVisible: Boolean;
        FinishStepVisible: Boolean;
        TopBannerVisible: Boolean;
        MagentoStoreStepVisible: Boolean;
        MagentoWebsiteStepVisible: Boolean;
        MagentoCustomerMappingStepVisible: Boolean;
        MagentoPaymentGatewayStepVisible: Boolean;
        MagentoPaymentMappingStepVisible: Boolean;
        MagentoShippmentMappingStepVisible: Boolean;
        MagentoBrandStepVisible: Boolean;
        MagentoDisplayGroupStepVisible: Boolean;
        MagentoDisplayConfigstepVisible: Boolean;
        MagentoStoreDataFilledIn: Boolean;
        MagentoWebsiteDataFilledIn: Boolean;
        MagentoCustomerMappingDataFilledIn: Boolean;
        MagentoPaymentGatewayDataFilledIn: Boolean;
        MagentoPaymentMappingDataFilledIn: Boolean;
        MagentoShippmentMappingDataFilledIn: Boolean;
        MagentoBrandDataFilledIn: Boolean;
        MagentoDisplayGroupDataFilledIn: Boolean;
        MagentoDisplayConfigDataFilledIn: Boolean;
        AllDataFilledIn: Boolean;
        AnyDataToCreate: Boolean;
        MagentoWebsiteLabel: Label '- Magento Website';
        MagentoStoreLabel: Label '- Magento Store';
        MagentoCustomerMappingLabel: Label '- Magento Customer Mapping';
        MagentoPaymentGatewayLabel: Label '- Magento Payment Gateway';
        MagentoPaymentMappingLabel: Label '- Magento Payment Mapping';
        MagentoShippmentMappingLabel: Label '- Magento Shippment Mapping';
        MagentoBrandLabel: Label '- Magento Brand';
        MagentoDisplayGroupLabel: Label '- Magento Display Group';
        MagentoDisplayConfigLabel: Label '- Magento Display Config';

    local procedure EnableControls();
    begin
        ResetControls();

        // STEPS
        // 1. Magento Website
        // 2. Magento Store
        // 3. Magento Customer Mapping
        // 4. Magento Payment Gateway
        // 5. Magento Payment Mapping
        // 6. Magento Shippment Mapping
        // 7. Magento Brand
        // 8. Magento Display Group
        // 9. Magento Display Config

        case Step of
            Step::StartStep:
                ShowStartStep();
            Step::MagentoWebsiteStep:
                ShowMagentoWebsiteStep();
            Step::MagentoStoreStep:
                ShowMagentoStoreStep();
            Step::MagentoCustomerMappingStep:
                ShowMagentoCustomerMappingStep();
            Step::MagentoPaymentGatewayStep:
                ShowMagentoPaymentGatewayStep();
            Step::MagentoPaymentMappingStep:
                ShowMagentoPaymentMappingStep();
            Step::MagentoShippmentMappingStep:
                ShowMagentoShippmentMappingStep();
            Step::MagentoBrandStep:
                ShowMagentoBrandStep();
            Step::MagentoDisplayGroupStep:
                ShowMagentoDisplayGroupStep();
            Step::MagentoDisplayConfigStep:
                ShowMagentoDisplayConfigstep();
            Step::FinishStep:
                ShowFinishStep();
        end;
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        StartStepVisible := false;
        MagentoStoreStepVisible := false;
        MagentoWebsiteStepVisible := false;
        MagentoCustomerMappingStepVisible := false;
        MagentoPaymentGatewayStepVisible := false;
        MagentoPaymentMappingStepVisible := false;
        MagentoShippmentMappingStepVisible := false;
        MagentoBrandStepVisible := false;
        MagentoDisplayGroupStepVisible := false;
        MagentoDisplayConfigstepVisible := false;

        FinishStepVisible := false;
    end;

    procedure ShowStartStep();
    begin
        StartStepVisible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    procedure ShowMagentoWebsiteStep();
    begin
        MagentoWebsiteStepVisible := true;
    end;

    procedure ShowMagentoStoreStep();
    begin
        MagentoStoreStepVisible := true;

        CurrPage.MagentoWebsites.Page.CopyRealAndTemp(TempMagentoWebsiteGlobal);
        CurrPage.MagentoStores.Page.SetGlobals(TempMagentoWebsiteGlobal);
    end;

    procedure ShowMagentoCustomerMappingStep();
    begin
        MagentoCustomerMappingStepVisible := true;
    end;

    procedure ShowMagentoPaymentGatewayStep();
    begin
        MagentoPaymentGatewayStepVisible := true;
    end;

    procedure ShowMagentoPaymentMappingStep();
    begin
        MagentoPaymentMappingStepVisible := true;

        CurrPage.MagentoPaymentGateways.Page.CopyRealAndTemp(TempMagentPaymentGatewayGlobal);
        CurrPage.MagentoPaymentMappings.Page.SetGlobals(TempMagentPaymentGatewayGlobal);
    end;

    procedure ShowMagentoShippmentMappingStep();
    begin
        MagentoShippmentMappingStepVisible := true;
    end;

    procedure ShowMagentoBrandStep();
    begin
        MagentoBrandStepVisible := true;
    end;

    procedure ShowMagentoDisplayGroupStep();
    begin
        MagentoDisplayGroupStepVisible := true;

        CurrPage.MagentoBrands.Page.CopyRealAndTemp(TempMagentoBrand);
    end;

    procedure ShowMagentoDisplayConfigstep();
    begin
        MagentoDisplayConfigstepVisible := true;

        CurrPage.MagentoDisplayGroups.Page.CopyRealAndTemp(TempMagDisplayGroup);

        CurrPage.MagentoDisplayConfigs.Page.SetGlobals(TempMagentoBrand, TempMagDisplayGroup, 0);
        CurrPage.MagentoDisplayConfigs.Page.SetGlobals(TempMagentoBrand, TempMagDisplayGroup, 1);
    end;

    procedure ShowFinishStep();
    begin
        FinishStepVisible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;

        CheckIfDataFilledIn();
    end;

    local procedure FinishAction();
    begin
        StoreData();
        CurrPage.Close();
    end;

    local procedure StoreData();
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if AnyDataToCreate then
            if not MagentoSetup.Get() then
                MagentoSetup.Insert();

        CurrPage.MagentoWebsites.Page.CreateMagentoWebsiteData();
        CurrPage.MagentoStores.Page.CreateMagentoStoreData();
        CurrPage.MagentCustMappings.Page.CreateMagentoCustomerMappingData();
        CurrPage.MagentoPaymentGateways.Page.CreateMagentoPaymentGatewayData();
        CurrPage.MagentoPaymentMappings.Page.CreateMagentoPaymentMapping();
        CurrPage.MagentoShippingMappings.Page.CreateMagentoShipmentMapping();
        CurrPage.MagentoBrands.Page.CreateMagentoBrand();
        CurrPage.MagentoDisplayGroups.Page.CreateMagentoDisplayGroup();
        CurrPage.MagentoDisplayConfigs.Page.CreateMagentoDisplayConfig();
    end;

    local procedure CheckIfDataFilledIn()
    begin
        MagentoWebsiteDataFilledIn := CurrPage.MagentoWebsites.Page.MagentoWebsiteDataToCreate();
        MagentoStoreDataFilledIn := CurrPage.MagentoStores.Page.MagentoStoreDataToCreate();
        MagentoCustomerMappingDataFilledIn := CurrPage.MagentCustMappings.Page.MagentoCustomerMappingDataToCreate();
        MagentoPaymentGatewayDataFilledIn := CurrPage.MagentoPaymentGateways.Page.MagentoPaymentGatewayDataToCreate();
        MagentoPaymentMappingDataFilledIn := CurrPage.MagentoPaymentMappings.Page.MagentoPaymentMappingToCreate();
        MagentoShippmentMappingDataFilledIn := CurrPage.MagentoShippingMappings.Page.MagentoShipmentMappingToCreate();
        MagentoBrandDataFilledIn := CurrPage.MagentoBrands.Page.MagentoBrandToCreate();
        MagentoDisplayGroupDataFilledIn := CurrPage.MagentoDisplayGroups.Page.MagentoDisplayGroupToCreate();
        MagentoDisplayConfigDataFilledIn := CurrPage.MagentoDisplayConfigs.Page.MagentoDisplayConfigToCreate();

        AllDataFilledIn := MagentoWebsiteDataFilledIn and
                           MagentoStoreDataFilledIn and
                           MagentoCustomerMappingDataFilledIn and
                           MagentoPaymentGatewayDataFilledIn and
                           MagentoPaymentMappingDataFilledIn and
                           MagentoShippmentMappingDataFilledIn and
                           MagentoBrandDataFilledIn and
                           MagentoDisplayGroupDataFilledIn and
                           MagentoDisplayConfigDataFilledIn;

        AnyDataToCreate := MagentoWebsiteDataFilledIn or
                           MagentoStoreDataFilledIn or
                           MagentoCustomerMappingDataFilledIn or
                           MagentoPaymentGatewayDataFilledIn or
                           MagentoPaymentMappingDataFilledIn or
                           MagentoShippmentMappingDataFilledIn or
                           MagentoBrandDataFilledIn or
                           MagentoDisplayGroupDataFilledIn or
                           MagentoDisplayConfigDataFilledIn;
    end;

    local procedure LoadTopBanners();
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