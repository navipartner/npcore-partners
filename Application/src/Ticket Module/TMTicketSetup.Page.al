﻿page 6060079 "NPR TM Ticket Setup"
{
    Extensible = False;
    Caption = 'Ticket Setup';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/ticket_setup_wizard/';
    PageType = Card;
    SourceTable = "NPR TM Ticket Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced, NPRRetail;
    AdditionalSearchTerms = 'Ticket Wizard, Ticket Application Area';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Authorization Code Scheme"; Rec."Authorization Code Scheme")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Authorization Code Scheme field';
                }
                field("Import Default Ext. Ticket Pattern"; Rec."Imp. Def. Ext. Ticket Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the Import Default External Ticket Pattern. The pattern can include fixed text, the original ticket number and random characters. Any characters not within the [ and ] will be treated as fixed text. [N] – Random number, [N*4] – 4 random numbers, [A] – Random character, [A*4] – 4 random characters An example could be: TK-[N*4] which would result in TK-<four random numbers>';
                }
                field("Retire Used Tickets After"; Rec."Retire Used Tickets After")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the amount of time until a used ticket and its associated information may be deleted. Does not affect generated statistics.';
                }
                field("Duration Retire Tickets (Min.)"; Rec."Duration Retire Tickets (Min.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the max duration (in minutes) the retire ticket job is allowed to run. Specify -1 for indefinite. ';
                }

            }
            group("Ticket Print")
            {
                field("Print Server Generator URL"; Rec."Print Server Generator URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Generator URL field';
                }
                field("Print Server Gen. Username"; Rec."Print Server Gen. Username")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Gen. Username field';
                }
                field("Print Server Gen. Password"; Rec."Print Server Gen. Password")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Gen. Password field';
                }
                field("Print Server Ticket URL"; Rec."Print Server Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Ticket URL field';
                }
                field("Print Server Order URL"; Rec."Print Server Order URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Order URL field';
                }
                field("Default Ticket Language"; Rec."Default Ticket Language")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default Ticket Language field';
                }
                field("Timeout (ms)"; Rec."Timeout (ms)")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Timeout (ms) field';
                }
                group("Description Selection")
                {
                    field("Store Code"; Rec."Store Code")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Store Code field';
                    }
                    field("Ticket Title"; Rec."Ticket Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        Tooltip = 'Specifies the source of Ticket Title for tickets rendered by Ticket Server';
                    }
                    field("Ticket Sub Title"; Rec."Ticket Sub Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the source of Ticket Sub Title for tickets rendered by Ticket Server';
                    }
                    field("Ticket Name"; Rec."Ticket Name")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the source of Ticket Name for tickets rendered by Ticket Server';
                    }
                    field("Ticket Description"; Rec."Ticket Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the source of Ticket Description for tickets rendered by Ticket Server';
                    }
                    field("Ticket Full Description"; Rec."Ticket Full Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the source of Ticket Full Description for tickets rendered by Ticket Server';
                    }
                }
            }
            group(eTicket)
            {
                Caption = 'eTicket';
                field("NP-Pass Server Base URL"; Rec."NP-Pass Server Base URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Server Base URL field';
                }
                field("NP-Pass Notification Method"; Rec."NP-Pass Notification Method")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Notification Method field';
                }
                field("NP-Pass API"; Rec."NP-Pass API")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass API field';
                }
                field("NP-Pass Token"; Rec."NP-Pass Token")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Token field';
                }
                group(Control)
                {
                    Caption = 'Control';
                    field("Suppress Print When eTicket"; Rec."Suppress Print When eTicket")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Suppress Print When eTicket field';
                    }
                    field("Show Send Fail Message In POS"; Rec."Show Send Fail Message In POS")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Show Send Fail Message In POS field';
                    }
                    field("Show Message Body (Debug)"; Rec."Show Message Body (Debug)")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Show Message Body (Debug) field';
                    }
                }
            }
            group(mPos)
            {
                Caption = 'mPos';
                field("Ticket Admission Web Url"; Rec."Ticket Admission Web Url")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies an Url to open the ticket admission web page from mobile POS (mPos)';
                }
            }
            group("Prepaid / Postpaid")
            {
                Caption = 'Prepaid / Postpaid';
                group(Prepaid)
                {
                    Caption = 'Prepaid';
                    field("Prepaid Excel Export Prompt"; Rec."Prepaid Excel Export Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Excel Export Prompt field';
                    }
                    field("Prepaid Offline Valid. Prompt"; Rec."Prepaid Offline Valid. Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Offline Valid. Prompt field';
                    }
                    field("Prepaid Ticket Result List"; Rec."Prepaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Ticket Result List field';
                    }
                    field("Prepaid Default Quantity"; Rec."Prepaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Default Quantity field';
                    }
                    field("Prepaid Ticket Server Export"; Rec."Prepaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Ticket Server Export field';
                    }
                }
                group(Postpaid)
                {
                    Caption = 'Postpaid';
                    field("Postpaid Excel Export Prompt"; Rec."Postpaid Excel Export Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Excel Export Prompt field';
                    }
                    field("Postpaid Ticket Result List"; Rec."Postpaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Ticket Result List field';
                    }
                    field("Postpaid Default Quantity"; Rec."Postpaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Default Quantity field';
                    }
                    field("Postpaid Ticket Server Export"; Rec."Postpaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Ticket Server Export field';
                    }
                }
            }
            group(Wizard)
            {
                Caption = 'Wizard';
                field("Wizard Ticket Type No. Series"; Rec."Wizard Ticket Type No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Type No. Series field';
                }
                field("Wizard Ticket Type Template"; Rec."Wizard Ticket Type Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Type Template field';
                }
                field("Wizard Ticket Bom Template"; Rec."Wizard Ticket Bom Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Bom Template field';
                }
                field("Wizard Adm. Code No. Series"; Rec."Wizard Adm. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Adm. Code No. Series field';
                }
                field("Wizard Admission Template"; Rec."Wizard Admission Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Admission Template field';
                }
                field("Wizard Sch. Code No. Series"; Rec."Wizard Sch. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Sch. Code No. Series field';
                }
                field("Wizard Item No. Series"; Rec."Wizard Item No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Item No. Series field';
                }
            }
            group(Advanced)
            {
                Caption = 'Advanced Settings';

                group(ExpiryTime)
                {
                    Caption = 'Ticket Expiry';
                    field(DefaultExpireTimeSeconds; Rec.DefaultExpireTimeSeconds)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Default Expire Time (Seconds) field.';
                    }
                    field(UserDefaultExpireTimeSeconds; Rec.UserDefaultExpireTimeSeconds)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the User Expire Time (Seconds) field.';
                    }
                    field(PosExternalExpireTimeSeconds; Rec.PosExternalExpireTimeSeconds)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the POS External Expire Time (Seconds) field.';
                    }
                    field(PosUnattendedExpireTimeSeconds; Rec.PosUnattendedExpireTimeSeconds)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the POS Unattended Expire Time (Seconds) field.';
                    }
                }
                group(SOAPSanityCheck)
                {
                    Caption = 'SOAP Ticket Limits';

                    field(MaxTicketsPerSOAPRequest; Rec.MaxTicketsPerSOAPRequest)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Max Tickets Per SOAP Request field.';
                    }
                    field(MaxDurationSOAPMakeTicketRes; Rec.MaxDurationSOAPMakeTicketRes)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Max Duration MakeTicketReservation Request (Seconds) field.';
                    }
                    field(CheckSOAPProgressAfterPct; Rec.CheckSOAPProgressAfterPct)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Check SOAP Request Progress After % field.';
                    }
                }

                group(UX)
                {
                    Caption = 'User Experience';
                    field(UseFrontEndScheduleUX; Rec.UseFrontEndScheduleUX)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Use Front End Schedule UX field';
                    }
                }

                group(TimeZone)
                {
                    Caption = 'Time Zone';

                    field(ServerDateTime; _UserDateTime)
                    {
                        Caption = 'User Date Time';
                        ToolTip = 'Specifies the value of the Server Date Time with Server Time Zone applied.';
                        ApplicationArea = NPRTicketAdvanced;
                        Editable = false;
                        Visible = false;
                    }
                    field(ServerDateTimeWithTimeZone; _ServerDateTimeWithTimeZone)
                    {
                        Caption = 'Server Date Time and Time Zone';
                        ToolTip = 'Specifies the value of the Server Date Time without Time Zone applied.';
                        ApplicationArea = NPRTicketAdvanced;
                        Editable = false;
                        Visible = false;
                    }

                    field(ServiceTimeZoneNo; Rec.ServiceTimeZoneNo)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        Caption = 'Service Time Zone No.';
                        ToolTip = 'Specifies the value of the default value for the Service Time Zone field';
                        Visible = false;
                        trigger OnValidate()
                        begin
                            DisplayTimeInTimeZone(Rec.ServiceTimeZoneNo);
                        end;
                    }
                    field(ServiceTimeZone; _ServiceTimeZoneDescription)
                    {
                        Caption = 'Service Time Zone';
                        ToolTip = 'Specifies the value of the Default Time Zone field';
                        ApplicationArea = NPRTicketAdvanced;
                        Editable = false;
                        trigger OnAssistEdit()
                        var
                            TimeZone: Record "Time Zone";
#if (BC17 or BC18)
                            TimeZones: Page "Time Zones";
#else
                            TimeZones: Page "Time Zones Lookup";
#endif                            
                            PageAction: Action;
                        begin
                            TimeZones.LookupMode(true);
                            PageAction := TimeZones.RunModal();
                            if (not (PageAction = Action::LookupOK)) then
                                exit;

                            if (not CurrPage.Editable()) then
                                exit;

                            TimeZones.GetRecord(TimeZone);
                            Rec.ServiceTimeZoneNo := TimeZone."No.";
                            DisplayTimeInTimeZone(Rec.ServiceTimeZoneNo);

                            CurrPage.Update(true);
                        end;
                    }

                    field(LocalCurrentDateTime; _ServiceDateTime)
                    {
                        Caption = 'Service Date Time';
                        ToolTip = 'Specifies the value for apparent local date time with the selected time zone applied.';
                        ApplicationArea = NPRTicketAdvanced;
                        Editable = false;
                    }
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TicketWizard)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Create all required setup for a ticket from a single page.';
                Caption = 'Ticket Item Wizard';
                Image = Action;
                Ellipsis = true;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketWizardMgr: Codeunit "NPR TM Ticket Wizard";
                begin
                    TicketWizardMgr.Run();
                end;
            }


            group(Setup)
            {
                Caption = 'Setup';

                action(DemoData)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Create Demo Data';
                    ToolTip = 'Creates the NPR Demo Setup used when demonstrating ticketing.';
                    Image = CarryOutActionMessage;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        TicketDemoSetup: Codeunit "NPR TM Ticket Create Demo Data";
                        ConfirmSetup: Label 'Do you want to setup demo data for ticketing?';
                    begin
                        if (Confirm(ConfirmSetup, true)) then
                            TicketDemoSetup.CreateTicketDemoData(false);
                    end;
                }

                action(RetireTicketData)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Delete Obsolete Ticket Data';
                    ToolTip = 'This action will delete obsolete ticket data, including unused schedule entries.';
                    Image = DeleteExpiredComponents;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        RetentionTicketData: Codeunit "NPR TM Retention Ticket Data";
                    begin
                        RetentionTicketData.MainWithConfirm();
                    end;
                }
                action(AddRecurringJobToRetireTicketData)
                {
                    Caption = 'Schedule Ticket Data Cleanup';
                    ToolTip = 'Adds a new periodic job, responsible for obsolete ticket data cleanup, including unused schedule entries.';
                    Image = AddAction;
                    ApplicationArea = NPRTicketAdvanced;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        JobQueueEntry: Record "Job Queue Entry";
                        RetentionTicketData: Codeunit "NPR TM Retention Ticket Data";
                    begin
                        if RetentionTicketData.AddTicketDataRetentionJobQueue(JobQueueEntry, false) then
                            Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                    end;
                }
                action(DeployRapidPackageFromAzureBlob)
                {
                    Caption = 'Deploy Rapid Package From Azure';
                    Image = ImportDatabase;
                    RunObject = page "NPR TM Ticket Rapid Packages";
                    ToolTip = 'Executes the Deploy Rapid Start Package for Ticket module From Azure Blob Storage';
                    ApplicationArea = NPRTicketAdvanced;
                    Ellipsis = true;
                }

                action(PublishedWebService)
                {
                    Caption = 'Publish Ticketing WebServices';
                    ToolTip = 'Creates and publishes the ticketing web services.';
                    Image = Setup;
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                    trigger OnAction()
                    var
                        WebServiceMgt: Codeunit "Web Service Management";
                        WebServiceObjectType: Option ,,,,,"Codeunit",,,"Page","Query",,,,,,,,,,;
                        TicketServiceName: Label 'ticket_services', Locked = true;
                        TicketStatisticsName: Label 'ticket_statistics', Locked = true;
                        TicketNotificationName: Label 'NPR_TicketNotifications', Locked = true;
                        CityCardServiceName: Label 'NPR_DocLxCityCard', Locked = true;
                        OkMessage: Label 'Services published: [%1, %2, %3, %4]';
                    begin
                        WebServiceMgt.CreateTenantWebService(WebServiceObjectType::"Codeunit", Codeunit::"NPR TM Ticket WebService", TicketServiceName, true);
                        WebServiceMgt.CreateTenantWebService(WebServiceObjectType::"Codeunit", Codeunit::"NPR TM Statistics WebService", TicketStatisticsName, true);
                        WebServiceMgt.CreateTenantWebService(WebServiceObjectType::"Page", Page::"NPR APIV1 - TM Notifications", TicketNotificationName, true);

                        Message(StrSubstNo(OkMessage, TicketServiceName, TicketStatisticsName, TicketNotificationName, CityCardServiceName));
                    end;
                }
                action(SetUserTimeZone)
                {
                    Caption = 'Reset Service Time Zone';
                    ToolTip = 'Reset the service time zone to user-impersonation.';
                    Image = Setup;
                    ApplicationArea = NPRTicketAdvanced;

                    trigger OnAction()
                    begin
                        Rec.ServiceTimeZoneNo := 0;
                        CurrPage.Update(true);
                    end;
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
                            SecretDisplayNameLbl: Label 'NaviPartner Ticketing Integration - %1', Comment = '%1 = today''s date';
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
                            SecretDisplayNameLbl: Label 'NaviPartner Ticketing Integration - %1', Comment = '%1 = today''s date';
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

    trigger OnAfterGetRecord()
    begin
        DisplayTimeInTimeZone(Rec.ServiceTimeZoneNo);
    end;

    local procedure DisplayTimeInTimeZone(TimeZoneNumber: Integer)
    var
        BCTimeZone: Record "Time Zone";
        TypeHelper: Codeunit "Type Helper";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        UsersTimeZone: Label 'User-Impersonation';
    begin
        _UserDateTime := Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
        _ServerDateTimeWithTimeZone := TypeHelper.FormatDateTime(TypeHelper.GetCurrUTCDateTime(), 'yyyy-MM-dd HH:mm:ss zzz', '');

        _ServiceTimeZoneDescription := UsersTimeZone;
        if (BCTimeZone.Get(TimeZoneNumber)) then
            _ServiceTimeZoneDescription := BCTimeZone."Display Name";

        _ServiceDateTime := TimeHelper.GetLocalTimeForServiceAsText();
    end;

    var
        HasAzureADConnection: Boolean;
        _ServiceTimeZoneDescription: Text;
        _ServiceDateTime: Text;
        _UserDateTime: Text;
        _ServerDateTimeWithTimeZone: Text;
}

