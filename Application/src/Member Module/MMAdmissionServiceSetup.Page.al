page 6060090 "NPR MM Admission Service Setup"
{
    Extensible = False;

    Caption = 'MM Admission Service Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Service Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Validate Members"; Rec."Validate Members")
                {

                    ToolTip = 'Specifies the value of the Validate Members field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Validate Tickes"; Rec."Validate Tickes")
                {

                    ToolTip = 'Specifies the value of the Validate Tickes field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Validate Re-Scan"; Rec."Validate Re-Scan")
                {

                    ToolTip = 'Specifies the value of the Validate Re-Scan field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Validate Scanner Station"; Rec."Validate Scanner Station")
                {

                    ToolTip = 'Specifies the value of the Validate Scanner Station field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Allowed Re-Scan Interval"; Rec."Allowed Re-Scan Interval")
                {

                    ToolTip = 'Specifies the value of the Allowed Re-Scan Interval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field("Show Sensitive Info"; Rec."Show Sensitive Info")
                {
                    ToolTip = 'Specifies if the system should show sensitive information like Member Name and Age.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Use Foreign Membership"; Rec."Use Foreign Membership")
                {
                    ToolTip = 'Specifies if the system should use Foreign Membership';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(WebServiceIsPublished; WebServiceIsPublished)
                {
                    Caption = 'Web Service Is Published';
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            part(Turnstiles; "NPR MM Admis. Scanner Stations")
            {
                Caption = 'Turnstiles';
                ShowFilter = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

            }
        }
        area(factboxes)
        {
            part(ServiceSetupFactbox; "NPR Adm. Service Setup Factbox")
            {
                Caption = 'Images';

                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Published Webservice")
            {
                Caption = 'Published Webservice';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Codeunit "NPR MM Admission Service WS";

                ToolTip = 'Executes the Published Webservice action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            group(AzureAAD)
            {
                Caption = 'OAuth Credentials';
                Visible = HasAzureADConnection;
                Image = XMLSetup;

                action(CreateNewAzureADApplication)
                {
                    Caption = 'Create New Entra ID Application';
                    ToolTip = 'Running this action will create a Microsoft Entra ID App and an accompanying client secret.';
                    Image = Setup;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        PermissionSets: List of [Code[20]];
                        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                        AppDisplayNameLbl: Label 'NaviPartner Ticketing Integration';
                        SecretDisplayNameLbl: Label 'NaviPartner Turnstile Integration - %1', Comment = '%1 = today''s date';
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
                    Caption = 'Create New Entra ID Application Secret';
                    ToolTip = 'Running this action will create a client secret for an existing Microsoft Entra ID App.';
                    Image = Setup;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        AppInfo: ModuleInfo;
                        AADApplication: Record "AAD Application";
                        AADApplicationList: Page "AAD Application List";
                        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                        NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage';
                        SecretDisplayNameLbl: Label 'NaviPartner Turnstile Integration - %1', Comment = '%1 = today''s date';
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
            Action(NavigateDefaultAdmission)
            {
                ToolTip = 'Navigate to Admissions per Scanner Station';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Admissions per Scanner Station';
                Image = Default;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM POS Default Admission";
                RunPageLink = "Station Type" = const(SCANNER_STATION);
            }
            action(Entries)
            {
                Caption = 'Entries';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admis. Service Entries";

                ToolTip = 'Executes the Entries action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceIsPublished := false;
        WebServiceManagement.LoadRecords(WebService);
        if WebService.Get(WebService."Object Type"::Codeunit, 'admission_service') then
            WebServiceIsPublished := true;
    end;

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        HasAzureADConnection := (AzureADTenant.GetAadTenantId() <> '');
    end;

    var
        WebServiceIsPublished: Boolean;
        HasAzureADConnection: Boolean;
}
