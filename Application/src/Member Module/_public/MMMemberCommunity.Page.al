page 6060132 "NPR MM Member Community"
{
    Caption = 'Member Community';
    ContextSensitiveHelpPage = 'docs/entertainment/loyalty/how-to/setup/';
    PageType = List;
    SourceTable = "NPR MM Member Community";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External No. Search Order"; Rec."External No. Search Order")
                {

                    ToolTip = 'Specifies the value of the External No. Search Order field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No. Series"; Rec."External Membership No. Series")
                {

                    ToolTip = 'Specifies the value of the External Membership No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No. Series"; Rec."External Member No. Series")
                {

                    ToolTip = 'Specifies the value of the External Member No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No. Series"; Rec."Customer No. Series")
                {

                    ToolTip = 'Specifies the value of the Customer No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Unique Identity"; Rec."Member Unique Identity")
                {

                    ToolTip = 'Specifies the value of the Member Unique Identity field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Member UI Violation"; Rec."Create Member UI Violation")
                {

                    ToolTip = 'Specifies the value of the Create Member UI Violation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Logon Credentials"; Rec."Member Logon Credentials")
                {

                    ToolTip = 'Specifies the value of the Member Logon Credentials field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership to Cust. Rel."; Rec."Membership to Cust. Rel.")
                {

                    ToolTip = 'Specifies the value of the Membership to Cust. Rel. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(MemberDefaultCountryCode; Rec.MemberDefaultCountryCode)
                {
                    ToolTip = 'Specifies the value of the Member Default Country Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {

                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Activate Loyalty Program"; Rec."Activate Loyalty Program")
                {

                    ToolTip = 'Specifies the value of the Activate Loyalty Program field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Foreign Membership"; Rec."Foreign Membership")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Foreign Membership field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Membership Setup";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Membership Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            action("Loyalty Setup")
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                RunObject = Page "NPR MM Loyalty Setup";
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the Loyalty Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';
                ObsoleteReason = 'Misplaced button';
            }
            action(LoyaltySetup)
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                RunObject = Page "NPR MM Loyalty Setup";
                ToolTip = 'Executes the Loyalty Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            action("Notification Setup")
            {
                Caption = 'Notification Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Member Notific. Setup";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Notification Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6150626)
            {
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';
                ObsoleteReason = 'Not required anymore.';
            }
            action("Process Auto Renew")
            {
                Caption = 'Auto Renew Process';
                Ellipsis = true;
                Image = AutoReserve;
                RunObject = Page "NPR MM Members. AutoRenew List";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Auto Renew Process action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014406)
            {
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';
                ObsoleteReason = 'Not required anymore.';
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Memberships action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            separator(Separator6014405)
            {
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';
                ObsoleteReason = 'Not required anymore.';
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = InteractionLog;
                RunObject = Page "NPR MM Membership Notific.";

                ToolTip = 'Executes the Notifications action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action("Foreign Membership Setup")
            {
                Caption = 'Foreign Membership Setup';
                Ellipsis = true;
                Image = ElectronicBanking;
                RunObject = Page "NPR MM Foreign Members. Setup";
                RunPageLink = "Community Code" = FIELD(Code);

                ToolTip = 'Executes the Foreign Membership Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        area(processing)
        {
            action("Update Memberships Customer")
            {
                Caption = 'Update Memberships Customer';
                Image = CreateInteraction;
                RunObject = Report "NPR MM Sync. Community Cust.";

                ToolTip = 'Executes the Update Memberships Customer action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            group(SetUp)
            {
                Caption = 'Application Setup';

                action(CreateDemoData)
                {
                    Caption = 'Create Demo Data';
                    ToolTip = 'Executes the Create Demo Data action';
                    Image = Action;
                    ApplicationArea = NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        CreateDemo: Codeunit "NPR MM Member Create Demo Data";
                    begin
                        CreateDemo.CreateDemoData(false);
                    end;
                }
                action(PublishedWebService)
                {
                    Caption = 'Publish Memberships WebServices';
                    ToolTip = 'Creates and publishes the membership web services.';
                    Image = Setup;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        WebServiceMgt: Codeunit "Web Service Management";
                        MemberServiceName: Label 'member_services', Locked = true;
                        M2AccountServiceName: Label 'm2_account_services', Locked = true;
                        LoyaltyServiceName: Label 'loyalty_services', Locked = true;
                        AdmissionAppServices: Label 'NPR_AdmissionAppServices', Locked = true;
                        OkMessage: Label 'Services published.';
                    begin
                        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MM Member WebService", MemberServiceName, true);
                        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR M2 Account WebService", M2AccountServiceName, true);
                        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MM Loyalty WebService", LoyaltyServiceName, true);
                        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MMAdmissionAppWebService", AdmissionAppServices, true);
                        Message(OkMessage);
                    end;
                }
                group(AzureAAD)
                {
                    Caption = 'OAuth Credentials';
                    Visible = HasAzureADConnection;
                    Image = XMLSetup;

                    action(CreateNewAzureADApplication)
                    {
                        Caption = 'Create New Azure AD Application';
                        ToolTip = 'Running this action will create an Azure AD App and a accompanying client secret.';
                        Image = Setup;
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                        trigger OnAction()
                        var
                            PermissionSets: List of [Code[20]];
                            AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                            AppDisplayNameLbl: Label 'NaviPartner Ticketing Integration';
                            SecretDisplayNameLbl: Label 'NaviPartner Membership Integration - %1', Comment = '%1 = today''s date';
                        begin
                            PermissionSets.Add('D365 BUS FULL ACCESS');
#if BC17
                            PermissionSets.Add('NP RETAIL');
#else
                            PermissionSets.Add('NPR NP RETAIL');
#endif

                            AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)), PermissionSets);
                        end;
                    }

                    action(CreateNewAADApplicationSecret)
                    {
                        Caption = 'Create New Azure AD Application Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Azure AD App.';
                        Image = Setup;
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                        trigger OnAction()
                        var
                            AppInfo: ModuleInfo;
                            AADApplication: Record "AAD Application";
                            AADApplicationList: Page "AAD Application List";
                            AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                            NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage';
                            SecretDisplayNameLbl: Label 'NaviPartner Membership Integration - %1', Comment = '%1 = today''s date';
                        begin
                            NavApp.GetCurrentModuleInfo(AppInfo);

                            AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
                            if (AADApplication.IsEmpty()) then
                                Error(NoAppsToManageErr, AppInfo.Name);

                            AADApplicationList.LookupMode(true);
                            AADApplicationList.SetTableView(AADApplication);
                            if (AADApplicationList.RunModal() <> Action::LookupOK) then
                                exit;

                            AADApplicationList.GetRecord(AADApplication);
                            AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        HasAzureADConnection := (AzureADTenant.GetAadTenantId() <> '');
    end;

    var
        HasAzureADConnection: Boolean;
}

