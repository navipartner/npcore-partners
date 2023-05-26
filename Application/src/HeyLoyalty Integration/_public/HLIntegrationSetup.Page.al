page 6150720 "NPR HL Integration Setup"
{
    Extensible = true;
    Caption = 'HeyLoyalty Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HL Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRHeyLoyalty;
    ContextSensitiveHelpPage = 'heyloyaltyintegration.html';
    PromotedActionCategories = 'New,Process,Report,Data Migration';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable Integration"; Rec."Enable Integration")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies whether the integration is enabled. This is the master on/off switch for the integration.';

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("Instant Task Enqueue"; Rec."Instant Task Enqueue")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the HeyLoyalty task scheduling routine is executed immediately after a change has been registered in the system. This mode is only allowed on test/sandbox environments.';
                }
                group(MemberListIntegrationArea)
                {
                    Caption = 'Member List Integration Area';
                    field("Member Integration"; Rec."Member Integration")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = IntegrationIsEnabled;
                        ToolTip = 'Specifies whether the Member List integration area is enabled. This will enable member information to be sent to HeyLoyalty.';

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("HeyLoyalty List Id"; Rec."HeyLoyalty Member List Id")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies the HeyLoyalty member list Id integration is coupled with.';
                    }
                    field("Membership HL Field ID"; Rec."Membership HL Field ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership code.';
                    }
                    field("Unsubscribe if Blocked"; Rec."Unsubscribe if Blocked")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies whether member should be unsubscribed from HeyLoyalty, if the member, or their membership has been blocked in BC.';
                    }
                    field("Read Member Data from Webhook"; Rec."Read Member Data from Webhook")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = false;  //Is not yet supported by HeyLoyalty at the moment
                        Importance = Additional;
                        ToolTip = 'Specifies whether member data is going to be read from received HeyLoyalty webhook payload. If disabled, for each incoming webhook request system will issue an additional GET call to HeyLoyalty server in order to retrieve the most recent member data available at HeyLoyalty.';
                    }
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';
                field("HeyLoyalty Api Url"; Rec."HeyLoyalty Api Url")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the URL for HeyLoyalty Api, for example: https://api.heyloyalty.com/loyalty/v1';
                }
                field("HeyLoyalty Api Key"; Rec."HeyLoyalty Api Key")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the HeyLoyalty Api Key.';
                }
                field("HeyLoyalty Api Secret"; Rec."HeyLoyalty Api Secret")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the HeyLoyalty Api Secret.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(InitialSetup)
            {
                Caption = 'Initial Setup';
                action(TestConnection)
                {
                    Caption = 'Test Connection';
                    ToolTip = 'Check if connection parameters are correct, and specified HeyLoyalty member list is accessible.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = LinkWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
                        ResponseJToken: JsonToken;
                        SuccessMsg: Label 'Connection successfully established.';
                    begin
                        CurrPage.SaveRecord();
                        Clear(HLIntegrationMgt);
                        if not HLIntegrationMgt.InvokeGetMemberListInfo(ResponseJToken) then
                            Error(GetLastErrorText());
                        Message(SuccessMsg);
                    end;
                }
                group("Azure Active Directory OAuth")
                {
                    Caption = 'Azure Active Directory OAuth';
                    Image = XMLSetup;
                    Visible = HasAzureADConnection;
                    action("Create Azure AD App")
                    {
                        Caption = 'Create Azure AD App';
                        ToolTip = 'Running this action will create an Azure AD App and a accompaning client secret.';
                        ApplicationArea = NPRHeyLoyalty;
                        Image = Setup;

                        trigger OnAction()
                        var
                            HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
                        begin
                            HLIntegrationMgt.CreateAzureADApplication();
                        end;
                    }
                    action("Create Azure AD App Secret")
                    {
                        Caption = 'Create Azure AD App Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Azure AD App.';
                        ApplicationArea = NPRHeyLoyalty;
                        Image = Setup;

                        trigger OnAction()
                        var
                            HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
                        begin
                            HLIntegrationMgt.CreateAzureADApplicationSecret();
                        end;
                    }
                }
                action(MultiChoiceFields)
                {
                    Caption = 'MultiChoice Fields';
                    ToolTip = 'Setup integrated HeyLoyalty multiple choice fields.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = SelectMore;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR HL MultiChoice Fields";
                }
                action(SyncMembersToHL)
                {
                    Caption = 'Sync. Members';
                    ToolTip = 'Executes intial member synchronization between BC and HeyLoyalty. System will go through members in BC and send synchronization request for each of them to HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = CheckList;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Member: Record "NPR MM Member";
                        HLMemberMgt: Codeunit "NPR HL Member Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        HLMemberMgt.DoInitialSync(Member, true);
                    end;
                }
                action(ImportMembersFromFile)
                {
                    Caption = 'Import Members from Excel';
                    ToolTip = 'Import data from an Excel file, containing HeyLoyalty members. System will overwrite existing member data and create new members, if necessary, according to data coming from the file.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = ImportDatabase;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Report.Run(Report::"NPR HL Import Members", false);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        xSetup := Rec;
        UpdateControlVisibility();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SessionSetting: SessionSettings;
        ReloginRequiredMsg: Label 'You have changed %1. All active users will have to restart their sessions for the changes to take effect.\Do you want to restart your session now?', Comment = '%1 - tablecaption';
    begin
        if Format(Rec) <> Format(xSetup) then
            if Confirm(ReloginRequiredMsg, true, Rec.TableCaption) then
                SessionSetting.RequestSessionUpdate(false);
    end;

    local procedure UpdateControlVisibility()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        IntegrationIsEnabled := Rec."Enable Integration";
        MemberListIntegrationIsEnabled := Rec."Enable Integration" and Rec."Member Integration";
        HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
    end;

    var
        xSetup: Record "NPR HL Integration Setup";
        HasAzureADConnection: Boolean;
        IntegrationIsEnabled: Boolean;
        MemberListIntegrationIsEnabled: Boolean;
}