page 6060079 "NPR TM Ticket Setup"
{
    Extensible = False;
    Caption = 'Ticket Setup';
    PageType = Card;
    SourceTable = "NPR TM Ticket Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Ticket Wizard, Ticket Application Area';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Authorization Code Scheme"; Rec."Authorization Code Scheme")
                {
                    ApplicationArea = NPRTicketEssentials, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Authorization Code Scheme field';
                }
                field("Retire Used Tickets After"; Rec."Retire Used Tickets After")
                {
                    ApplicationArea = NPRTicketEssentials, NPRTicketAdvanced;
                    ToolTip = 'Specifies the amount of time until a used ticket and its associated information may be deleted. Does not affect generated statistics.';
                }
                field("Duration Retire Tickets (Min.)"; Rec."Duration Retire Tickets (Min.)")
                {
                    ApplicationArea = NPRTicketEssentials, NPRTicketAdvanced;
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
                        ToolTip = 'Specifies the value of the Ticket Title field';
                    }
                    field("Ticket Sub Title"; Rec."Ticket Sub Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Sub Title field';
                    }
                    field("Ticket Name"; Rec."Ticket Name")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Name field';
                    }
                    field("Ticket Description"; Rec."Ticket Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Description field';
                    }
                    field("Ticket Full Description"; Rec."Ticket Full Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Full Description field';
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
                        Visible = false;
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
        }
    }

    actions
    {
        area(navigation)
        {
            action(ApplicationArea)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Application Area';
                RunObject = Page "NPR Ticket App. Area Setup";
                ToolTip = 'Executes the Ticket Application Area action';
                Image = SetupList;
            }

        }
        area(Processing)
        {
            action(TicketWizard)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Create all required setup for a ticket from a single page.';
                Caption = 'Ticket Wizard';
                Image = Action;
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

            action(DemoData)
            {
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Create Demo Data';
                ToolTip = 'Creates the NPR Demo Setup used when demonstrating ticketing.';
                Image = CarryOutActionMessage;
                Promoted = false;
                Ellipsis = true;

                trigger OnAction()
                var
                    TicketDemoSetup: Codeunit "NPR TM Ticket Create Demo Data";
                begin
                    TicketDemoSetup.CreateTicketDemoData(false);
                end;
            }

            action(RetireTicketData)
            {
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Delete Obsolete Ticket Data';
                ToolTip = 'This action will delete obsolete ticket data, including unused schedule entries.';
                Image = DeleteExpiredComponents;
                Promoted = false;
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
                ToolTip = 'Executes the Deploy Rapidstart Package for Ticket module From Azure Blob Storage';
                ApplicationArea = NPRTicketAdvanced;
            }
        }
    }
}

