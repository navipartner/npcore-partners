page 6150720 "NPR HL Integration Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = true;
    Caption = 'HeyLoyalty Integration Setup';
    ContextSensitiveHelpPage = 'docs/integrations/heyloyalty/how-to/aad_app/';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HL Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRHeyLoyalty;
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
                    ToolTip = 'Specifies whether the HeyLoyalty task scheduling routine is executed immediately after a change has been registered in the system. This mode is only allowed in test/sandbox environments.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-10-28';
                    ObsoleteReason = 'Is not needed anymore with the new way of handling outstanding data log entries we have in BC Saas.';

                }
                field("Data Processing Handler ID"; Rec."Data Processing Handler ID")
                {
                    ToolTip = 'Specifies a code used by the system to identify the task processor, ticket notification profile and data log subscribers associated with the HeyLoyalty integration.';
                    ApplicationArea = NPRHeyLoyalty;
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
                    field("Required Contact Info"; Rec."Required Contact Info")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies required contact methods (email and/or phone) that must be specified in the member card before BC will submit the member data to HeyLoyalty.';
                    }
                    field("Require GDPR Approval"; Rec."Require GDPR Approval")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies whether the member must agree to GDPR before BC will submit the member data to HeyLoyalty.';
                    }
                    field("Require Newsletter Subscrip."; Rec."Require Newsletter Subscrip.")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies whether the member must subscribe to the e-mail newsletter ("E-Mail News Letter" field on the member card) before BC will submit the member data to HeyLoyalty.';
                    }
                    field("Unsubscribe if Blocked"; Rec."Unsubscribe if Blocked")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies whether the member should be unsubscribed from HeyLoyalty, if the member, or their membership has been blocked in BC.';
                    }
                    field("Read Member Data from Webhook"; Rec."Read Member Data from Webhook")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = false;  //Is not yet supported by HeyLoyalty at the moment
                        Importance = Additional;
                        ToolTip = 'Specifies whether member data is going to be read from received HeyLoyalty webhook payload. If disabled, for each incoming webhook request system will issue an additional GET call to HeyLoyalty server in order to retrieve the most recent member data available at HeyLoyalty.';
                    }
                }
                group(HeybookingIntegrationArea)
                {
                    Caption = 'Heybooking Integration Area';
                    field("Heybooking Integration Enabled"; Rec."Heybooking Integration Enabled")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = IntegrationIsEnabled;
                        Caption = 'Enabled';
                        ToolTip = 'Specifies whether the Heybooking Integration area is enabled. This will enable booking and transaction information be sent to HeyLoyalty.';

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("Heybooking Integration Id"; Rec."Heybooking Integration Id")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = HeybookingIntegrationIsEnabled;
                        ToolTip = 'Specifies the Heybooking Integration Id.';
                    }
                    field("Send Heybooking Err. to E-Mail"; Rec."Send Heybooking Err. to E-Mail")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = HeybookingIntegrationIsEnabled;
                        ToolTip = 'Specifies the email address notifications are sent to in case of errors while importing data to HeyLoyalty Heycommerce/Booking database.';
                    }
                    field("Send Heybooking Fire Events"; Rec."Send Heybooking Fire Events")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = HeybookingIntegrationIsEnabled;
                        ToolTip = 'By enabeling this option, the system will send Heybooking fire_events trigger to HeyLoyalty. This is used to trigger events in HeyLoyalty when a booking is made or modified.';
                    }
                }
            }
            group(HLFields_MemberList)
            {
                Caption = 'HeyLoyalty Fields (Member List)';
                Enabled = MemberListIntegrationIsEnabled;

                group(HLFieldIDs)
                {
                    Caption = 'HeyLoyalty Field IDs';

                    field("Membership HL Field ID"; Rec."Membership HL Field ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership code. The ID mostly used is "membership_code".';
                    }
                    field("External Membership No. HLF ID"; Rec."External Membership No. HLF ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about external membership number. The ID mostly used is "medlemsnummer".';
                    }
                    field("Membership Issued On HLF ID"; Rec."Membership Issued On HLF ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership issued on date. The ID mostly used is "medlemskab_aktiveringsdato".';
                    }
                    field("Membership Valid Until HLF ID"; Rec."Membership Valid Until HLF ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership valid until date. The ID mostly used is "medlemskab_slutdato".';
                    }
                    field("Membership Item No. HLF ID"; Rec."Membership Item No. HLF ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership item number. The ID mostly used is "item_no".';
                    }
                }
                group("MultiChoice Subscription")
                {
                    Caption = 'MultiChoice Subscription';

                    field("Enable MC Subscription"; Rec."Enable MC Subscription")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies whether the HeyLoyalty multiple choice field subscription is enabled. If enabled, system will use HeyLoyalty multiple choice fields to store information about which HeyLoyalty lists the member is subscribed to.';
                    }

                    field("Member of MCF Code"; Rec."Member of MCF Code")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the multiple choice field code to be used to store which HeyLoyalty lists synchronized entity (member) is going to be part of.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
                        begin
                            exit(HLMultiChoiceFieldMgt.LookupMultiChoiceFieldCode(Text));
                        end;
                    }
                    field("Notification List Opt. ID"; Rec."Notification List Opt. ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the option id of the multiple choice field for members of HeyLoyalty notification list.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
                        begin
                            Rec.TestField("Member of MCF Code");
                            exit(HLMultiChoiceFieldMgt.LookupMultiChoiceFieldOption(Rec."Member of MCF Code", Text));
                        end;
                    }
                    field("Newsletter List Opt. ID"; Rec."Newsletter List Opt. ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        ToolTip = 'Specifies the option id of the multiple choice field for members of HeyLoyalty newsletter list.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
                        begin
                            Rec.TestField("Member of MCF Code");
                            exit(HLMultiChoiceFieldMgt.LookupMultiChoiceFieldOption(Rec."Member of MCF Code", Text));
                        end;
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
                field("Heycommerce/Booking DB Api Url"; Rec."Heycommerce/Booking DB Api Url")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the URL for HeyLoyalty Heycommerce/Booking database Api, for example: https://tracking.heycommerce.dk/api or http://tracking.heyloyalty.com/api';
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
                    Caption = 'Microsoft Entra ID OAuth';
                    Image = XMLSetup;
                    Visible = HasAzureADConnection;
                    action("Create Azure AD App")
                    {
                        Caption = 'Create Entra ID App';
                        ToolTip = 'Running this action will create a Microsoft Entra ID App and an accompanying client secret.';
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
                        Caption = 'Create Entra ID App Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Microsoft Entra ID App.';
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
                action(UpdateMembersForMCFSubscription)
                {
                    Caption = 'Update Members for MCF Subscription';
                    ToolTip = 'Updates HeyLoyalty members with multiple choice field subscription information.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = Action;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        HLMCFSubscriptionMgt: Codeunit "NPR HL MCF Subscription Mgt.";
                        MCSubNotEnabledLbl: Label 'HeyLoyalty multiple choice field subscription is not enabled.\\Please enable it in the HeyLoyalty integration setup first.';
                        MembersUpdatedLbl: Label 'HeyLoyalty members have been updated to use multiple choice field subscription.\\Total members updated: %1', Comment = '%1 - count of updated members';
                        NoMembersUpdatedLbl: Label 'No HeyLoyalty members were updated.';
                        Count: Integer;
                    begin
                        CurrPage.SaveRecord();
                        if not Rec."Enable MC Subscription" then begin
                            Message(MCSubNotEnabledLbl);
                            exit;
                        end;

                        Rec.TestField("Member of MCF Code");

                        HLMCFSubscriptionMgt.UpgradeMembersToUseMCFSubscription(Count);

                        if Count > 0 then
                            Message(MembersUpdatedLbl, Count)
                        else
                            Message(NoMembersUpdatedLbl);
                    end;
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
                        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
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
            Rec.Insert(true);
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
        HeybookingIntegrationIsEnabled := Rec."Enable Integration" and Rec."Heybooking Integration Enabled";
        HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
    end;

    var
        xSetup: Record "NPR HL Integration Setup";
        HasAzureADConnection: Boolean;
        HeybookingIntegrationIsEnabled: Boolean;
        IntegrationIsEnabled: Boolean;
        MemberListIntegrationIsEnabled: Boolean;
}