page 6014694 "NPR GraphApi Setup Wizard"
{
    Caption = 'GraphApi Setup';
    PageType = NavigatePage;
    SourceTable = "NPR GraphApi Setup";
    SourceTableTemporary = true;

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
                    ApplicationArea = NPRRetail;
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
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to GraphApi Setup")
                {
                    Caption = 'Welcome to GraphApi Setup Setup';
                    Visible = Step1Visible;
                    group(Group18)
                    {
                        Caption = '';
                        InstructionalText = 'This wizard will help you set up GraphAPI connection. If you want to use default values, you can finish this wizard without changes.';
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Group22)
                    {
                        Caption = '';
                        InstructionalText = 'With GraphAPI you can use default endpoints for v1 and Navi Partner Azure Application. If you want to use your own, or endpoints change in the future, you can use GraphAPI Setup to change that.';
                    }
                }
            }

            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Enter paramateres of your Azure Application.';
                Visible = Step2Visible;
                //You might want to add fields here

                field("Client Id"; Rec."Client Id")
                {
                    ToolTip = 'Specifies the value of the Client Id of your Azure Application.';
                    ApplicationArea = NPRRetail;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ToolTip = 'Specifies the value of the Client Secret of your Azure Application.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Step3)
            {
                Caption = '';
                InstructionalText = 'Enter paramateres for GraphAPI.';
                Visible = Step3Visible;

                field("Graph Event Url"; Rec."Graph Event Url")
                {
                    ToolTip = 'Specifies the value of the Graph Event Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("Graph Me Url"; Rec."Graph Me Url")
                {
                    ToolTip = 'Specifies the value of the Graph Me Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("OAuth Authority Url"; Rec."OAuth Authority Url")
                {
                    ToolTip = 'Specifies the value of the OAuth Authority Url field.';
                    ApplicationArea = NPRRetail;
                }
                field("OAuth Token Url"; Rec."OAuth Token Url")
                {
                    ToolTip = 'Specifies the value of the OAuth Token Url field.';
                    ApplicationArea = NPRRetail;
                }
            }


            group(Step4)
            {
                Visible = Step4Visible;
                group(Group23)
                {
                    Caption = '';
                    InstructionalText = 'GraphAPI Setup completed.';
                }
                group("That's it!")
                {
                    Caption = 'That''s it!';
                    group(Group25)
                    {
                        Caption = '';
                        InstructionalText = 'To save this setup, choose Finish.';
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
        Rec.Init();
        SetDefaultsValues();
        Rec.Insert();

        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        Step: Option Start,Step2,Step3,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        TopBannerVisible: Boolean;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::Finish:
                ShowStep4();
        end;
    end;

    local procedure StoreGraphAPISetup();
    var
        GraphAPISetup: Record "NPR GraphApi Setup";
    begin
        if not GraphAPISetup.Get() then begin
            GraphAPISetup.Init();
            GraphAPISetup.Insert();
        end;

        GraphAPISetup.TransferFields(Rec, false);
        GraphAPISetup.Modify(true);
    end;


#IF BC17
    local procedure FinishAction();
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        StoreGraphAPISetup();
        AssistedSetup.Complete(Page::"NPR GraphApi Setup Wizard");
        CurrPage.Close();
    end;
#ELSE
    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        StoreGraphAPISetup();
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR GraphApi Setup Wizard");
        CurrPage.Close();
    end;
#ENDIF

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
    end;

    local procedure ShowStep3();
    begin
        Step3Visible := true;
    end;

    local procedure ShowStep4();
    begin
        Step4Visible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
        Step4Visible := false;
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

    local procedure SetDefaultsValues()
    var
        ClientIdTxt: Label '476a0575-a8b3-4fcb-bb43-9d85ac787226', Locked = true;
        ClientSecret: Label 'U7i_7F5SIvY_qrB.v0GYI0Ld39U.Nv36P.', Locked = true;
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize', Locked = true;
        OAuthTokenUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2/v2.0/token', Locked = true;
        GraphEventUrl: Label 'https://graph.microsoft.com/v1.0/me/events/', Locked = true;
        GraphMeUrl: Label 'https://graph.microsoft.com/v1.0/me', Locked = true;
    begin
        Rec."Client Id" := ClientIdTxt;
        Rec."Client Secret" := ClientSecret;
        Rec."OAuth Authority Url" := OAuthAuthorityUrlTxt;
        Rec."OAuth Token Url" := OAuthTokenUrlTxt;
        Rec."Graph Event Url" := GraphEventUrl;
        Rec."Graph Me Url" := GraphMeUrl;
    end;


}