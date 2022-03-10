page 6059853 "NPR Stripe Create Subs. Wiz."
{
    Caption = 'CREATE SUBSCRIPTION';
    Extensible = false;
    HelpLink = 'https://www.navipartner.com/pricing-pos-app/';
    PageType = NavigatePage;
    SourceTable = "NPR Stripe Customer";

    layout
    {
        area(Content)
        {
            group(BannerStandard)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep < 6);
                field("Media Resources Standard"; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    ShowCaption = false;
                    ToolTip = 'Media.';
                }
            }
            group(BannerDone)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep = 6);
                field("Media Resources Done"; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = NPRRetail;
                    ShowCaption = false;
                    ToolTip = 'Media.';
                }
            }
            group(Step1)
            {
                Visible = (CurrentStep = 1);
                group(Plan)
                {
                    Caption = 'Choose a plan';
                    InstructionalText = 'Choose a subscription plan from the list below';
                    part(Plans; "NPR Stripe Plan Subpart")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Step2)
            {
                Visible = (CurrentStep = 2);
                group(PlanTier)
                {
                    Caption = 'Plan details';
                    InstructionalText = 'Details of the choosen subscription plan';
                    part(PlanTiers; "NPR Stripe Plan Tier Subpart")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Step3)
            {
                Visible = (CurrentStep = 3);
                group(POSUSer)
                {
                    Caption = 'POS users';
                    InstructionalText = 'Choose the users that have access to the POS app';
                    part(POSUSers; "NPR Stripe POS User Subpart")
                    {
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Step4)
            {
                Visible = (CurrentStep = 4);
                group(Customer)
                {
                    Caption = 'Customer details';
                    InstructionalText = 'Provide your company details';
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the name of your company.';
                    }
                    field(Address; Rec.Address)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the address of your company.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the additional address information of your company.';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the country/region of your company.';

                        trigger OnValidate()
                        begin
                            IsCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
                            IsVATRegistrationNoMandatory := Rec.VATRegistrationNoMandatory();
                        end;
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the city of your company.';
                    }
                    group(CountyGroup)
                    {
                        ShowCaption = false;
                        Visible = IsCountyVisible;
                        field(County; Rec.County)
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the state, province or county of your company.';
                        }
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the postal code of your company.';
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the telephone number of your company.';
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the email address of your company.';
                    }
                    field("VAT Registration No."; Rec."VAT Registration No.")
                    {
                        ApplicationArea = NPRRetail;
                        ShowMandatory = IsVATRegistrationNoMandatory;
                        ToolTip = 'Specifies the VAT registration number of your company.';
                    }

                }
            }
            group(Step5)
            {
                Visible = (CurrentStep = 5);
                group(CreditCardInstruction)
                {
                    Caption = 'Credit card details';
                    InstructionalText = 'Please fill in your credit card details below. They will be safely stored with our payment provider Stripe. No credit card information will be stored in Microsoft Dynamics 365 Bussiness Central .';
                }
                group(CreditCardDetails)
                {
                    ShowCaption = false;
                    usercontrol(CreditCardControl; "NPR StripeCreditCardControl")
                    {
                        ApplicationArea = NPRRetail;

                        trigger ControlAddInReady()
                        begin
                            CheckoutControlIsReady := true;
                            InializeCheckoutControl();
                        end;

                        trigger InputChanged(complete: Boolean)
                        begin
                            CreditCardInputComplete := complete;
                            SetControls();
                        end;

                        trigger StripeTokenCreated(newTokenId: Text)
                        begin
                            Rec."Token Id" := CopyStr(newTokenId, 1, MaxStrLen(Rec."Token Id"));
                            if xRec."Token Id" = '' then
                                CurrentStep += 1;
                            SetControls();
                        end;
                    }
                }
            }
            group(Step6)
            {
                Visible = (CurrentStep = 6);
                group(Overview)
                {
                    Caption = 'All done';
                    InstructionalText = 'Click on Finish to create your subscription. Thank you for choosing the NP Retail POS app!';
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
                Enabled = ActionBackAllowed;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Go Back.';

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Go Next.';

                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Finish';
                Enabled = ActionFinishAllowed;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Finish setup and create subscription.';

                trigger OnAction()
                begin
                    Finish();
                end;
            }

        }
    }

    var
        MediaResourcesDone, MediaResourcesStandard : Record "Media Resources";
        FormatAddress: Codeunit "Format Address";
        [InDataSet]
        ActionBackAllowed, ActionFinishAllowed, ActionNextAllowed : Boolean;
        CheckoutControlIsReady, CreditCardInputComplete : Boolean;
        [InDataSet]
        IsCountyVisible: Boolean;
        IsVATRegistrationNoMandatory: Boolean;
        [InDataSet]
        TopBannerVisible: Boolean;
        CurrentStep: Integer;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if CurrentStep = 4 then begin
            IsCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
            IsVATRegistrationNoMandatory := Rec.VATRegistrationNoMandatory();
        end;
    end;

#if not BC17
    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if CloseAction = Action::OK then
            if GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, Page::"NPR Stripe Create Subs. Wiz.") then
                ErrorIfNotConfirmToExitSetup();
    end;

    local procedure ErrorIfNotConfirmToExitSetup()
    var
        NotSetUpQst: Label 'NP Retail POS app subscription has not been set up.\\Are you sure that you want to exit?';
    begin
        if not Confirm(NotSetUpQst) then
            Error('');
    end;
#endif

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := (CurrentStep < 5) or ((CurrentStep = 5) and CreditCardInputComplete);
        ActionFinishAllowed := CurrentStep = 6;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        if (CurrentStep = 5) and (Step = 1) and (Rec."Token Id" = '') then
            Step := 0;
        CheckCustomerData();
        CurrentStep += Step;
        SetControls();
    end;

    local procedure Finish()
    var
        StripePlan: Record "NPR Stripe Plan";
#if not BC17
        GuidedExperience: Codeunit "Guided Experience";
#endif
    begin
        CurrPage.Plans.Page.GetSelectedPlan(StripePlan);
#if not BC17
        if Rec.CreateSubscription(StripePlan) then begin
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Stripe Create Subs. Wiz.");
            Commit();
        end;
#else
        if Rec.CreateSubscription(StripePlan) then
            Commit();
#endif
        CurrPage.Close();
    end;

    local procedure LoadTopBanners()
    var
        MediaRepositoryDone, MediaRepositoryStandard : Record "Media Repository";
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure CheckCustomerData()
    var
        StripePlan: Record "NPR Stripe Plan";
        StripePlanTier: Record "NPR Stripe Plan Tier";
        NoPlanSelectedErr: Label 'Please select a plan.';
    begin
        case CurrentStep of
            1:
                begin
                    if not CurrPage.Plans.Page.HasSelectedPlan() then
                        Error(NoPlanSelectedErr);

                    CurrPage.Plans.Page.GetSelectedPlan(StripePlan);
                    StripePlanTier.SetRange("Plan Id", StripePlan.Id);
                    CurrPage.PlanTiers.Page.SetTableView(StripePlanTier);
                end;
            4:
                Rec.TestDetails();
            5:
                CurrPage.CreditCardControl.CreateStripeToken();
        end;
    end;

    [NonDebuggable]
    local procedure InializeCheckoutControl()
    begin
        if not CheckoutControlIsReady then
            exit;

        CurrPage.CreditCardControl.InitializeCheckOutForm(GetPublishableKey());
    end;

    [NonDebuggable]
    local procedure GetPublishableKey(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if EnvironmentInformation.IsOnPrem() then // this key is meant for testing purposes
            exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('TestStripePublishableKey'));

        if EnvironmentInformation.IsSaaS() then
            exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('LiveStripePublishableKey'));
    end;
}