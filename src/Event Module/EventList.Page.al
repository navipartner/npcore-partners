page 6060152 "NPR Event List"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.30/TJ  /20170309 CASE 263434 Moved global variable EventCopy to be local on action CopyAttribute
    // NPR5.31/TJ  /20170315 CASE 269162 Added controls "Starting Date", "Total Amount" and "Person Responsible Name"
    //                                   Added code to Copy Attributes action
    //                                   Change Attributes action to use new attributes funcionality
    // NPR5.32/NPKNAV/20170526  CASE 275974 Transport NPR5.32 - 26 May 2017
    // NPR5.33/TJ  /20170606 CASE 277972 Changed page to be opened on Attributes action
    // NPR5.34/TJ  /20170707 CASE 277938 New action Exch. Int. Templates
    // NPR5.34/TJ  /20170727 CASE 275991 Added field "Organizer E-Mail Password" with Visible property set to FALSE. This serves as temporary solution to hide password from the user
    // NPR5.43/TJ  /20170817 CASE 262079 New ActionGroup Tickets with new action "Collected Ticket Printouts"
    // NPR5.36/TJ  /20170911 CASE 287804 Action Create Job &Sales Invoice now sets current job as a filter
    // NPR5.37/TJ  /20170927 CASE 287806 Statistics now shows page Event Statistics (instead default Job Statistics page)
    // NPR5.38/TJ  /20171027 CASE 285194 Removed field "Organizer E-Mail Password"
    // NPR5.39/NPKNAV/20180223  CASE 285388 Transport NPR5.39 - 23 February 2018
    // NPR5.48/TJ  /20190131 CASE 342308 Added field "Est. Total Amount Incl. VAT"
    // NPR5.49/TJ  /20190124 CASE 331208 Control SalesInvoicesCreditMemos renamed to SalesDocuments and changed code
    //                                   Action Job Task Lines renamed to Event Task Lines and changed page to run
    // NPR5.49/TJ  /20190307 CASE 345048 Added field "Bill-to Name"
    // NPR5.50/JAVA/20190429 CASE 353381 BC14: Implement changes done in page 542 (use generic SetMultiRecord() function instead of specific functions).
    // NPR5.54/TJ  /20200302 CASE 392832 Added field "Creation Date"
    // NPR5.55/TJ  /20200205 CASE 374887 New parameter was added for email sending function

    Caption = 'Event List';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = List;
    SourceTable = Job;
    SourceTableView = WHERE("NPR Event" = CONST(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = All;
                }
                field("Event Status"; "NPR Event Status")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Person Responsible"; "Person Responsible")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Next Invoice Date"; "Next Invoice Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job Posting Group"; "Job Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; "NPR Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Est. Total Amount Incl. VAT"; "NPR Est. Total Amt. Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Person Responsible Name"; "NPR Person Responsible Name")
                {
                    ApplicationArea = All;
                }
                field("% of Overdue Planning Lines"; PercentOverdue)
                {
                    ApplicationArea = All;
                    Caption = '% of Overdue Planning Lines';
                    Editable = false;
                    Visible = false;
                }
                field("% Completed"; PercentCompleted)
                {
                    ApplicationArea = All;
                    Caption = '% Completed';
                    Editable = false;
                    Visible = false;
                }
                field("% Invoiced"; PercentInvoiced)
                {
                    ApplicationArea = All;
                    Caption = '% Invoiced';
                    Editable = false;
                    Visible = false;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control1907234507; "Sales Hist. Bill-to FactBox")
            {
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
                Visible = false;
                ApplicationArea = All;
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
                Visible = false;
                ApplicationArea = All;
            }
            part(Control1905650007; "Job WIP/Recognition FactBox")
            {
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
                ApplicationArea = All;
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Event")
            {
                Caption = '&Event';
                Image = Job;
                action("Event Task &Lines")
                {
                    Caption = 'Event Task &Lines';
                    Image = TaskList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Task Lines";
                    RunPageLink = "Job No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+T';
                    ApplicationArea = All;
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    action("Dimensions-&Single")
                    {
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(167),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ApplicationArea = All;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            Job: Record Job;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Job);
                            //-NPR5.50 [353381]
                            //DefaultDimMultiple.SetMultiJob(Job);
                            DefaultDimMultiple.SetMultiRecord(Job, Job.FieldNo("No."));
                            //+NPR5.50 [353381]
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                action("&Statistics")
                {
                    Caption = '&Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                    ApplicationArea = All;
                }
                action(SalesDocuments)
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EventInvoices: Page "NPR Event Invoices";
                    begin
                        //-NPR5.49 [331208]
                        /*
                        JobInvoices.SetPrJob(Rec);
                        JobInvoices.RUNMODAL;
                        */
                        EventInvoices.SetPrJob(Rec);
                        EventInvoices.RunModal;
                        //+NPR5.49 [331208]

                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Job),
                                  "No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(RecordId);
                    end;
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = BulletList;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Attributes";
                    RunPageLink = "Job No." = FIELD("No.");
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        //-NPR5.33 [277972]
                        /*
                        EventAttributeMatrix.SetJob(Rec."No.");
                        EventAttributeMatrix.RUN;
                        */
                        //+NPR5.33 [277972]

                    end;
                }
                action(WordLayouts)
                {
                    Caption = 'Word Layouts';
                    Image = Quote;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EventWordLayouts: Page "NPR Event Word Layouts";
                    begin
                        EventWordLayouts.SetEvent(Rec);
                        EventWordLayouts.RunModal;
                    end;
                }
                action(ExchIntTemplates)
                {
                    Caption = 'Exch. Int. Templates';
                    Image = InteractionTemplate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EventExchIntTempEntries: Page "NPR Event Exch.Int.Tmp.Entries";
                        EventExchIntTempEntry: Record "NPR Event Exch.Int.Temp.Entry";
                    begin
                        EventExchIntTempEntry.SetRange("Source Record ID", Rec.RecordId);
                        EventExchIntTempEntries.SetTableView(EventExchIntTempEntry);
                        EventExchIntTempEntries.Run;
                    end;
                }
                action(ExchIntEmailSummary)
                {
                    Caption = 'Exch. Int. E-mail Summary';
                    Image = ValidateEmailLoggingSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        EventEWSMgt.ShowExchIntSummary(Rec);
                    end;
                }
            }
            group("&Prices")
            {
                Caption = '&Prices';
                Image = Price;
                action("&Resource")
                {
                    Caption = '&Resource';
                    Image = Resource;
                    RunObject = Page "Job Resource Prices";
                    RunPageLink = "Job No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("&Item")
                {
                    Caption = '&Item';
                    Image = Item;
                    RunObject = Page "Job Item Prices";
                    RunPageLink = "Job No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("&G/L Account")
                {
                    Caption = '&G/L Account';
                    Image = JobPrice;
                    RunObject = Page "Job G/L Account Prices";
                    RunPageLink = "Job No." = FIELD("No.");
                    ApplicationArea = All;
                }
            }
            group("Plan&ning")
            {
                Caption = 'Plan&ning';
                Image = Planning;
                action("Resource &Allocated per Job")
                {
                    Caption = 'Resource &Allocated per Job';
                    Image = ViewJob;
                    RunObject = Page "Resource Allocated per Job";
                    ApplicationArea = All;
                }
                action("Res. Group All&ocated per Job")
                {
                    Caption = 'Res. Group All&ocated per Job';
                    Image = ViewJob;
                    RunObject = Page "Res. Gr. Allocated per Job";
                    ApplicationArea = All;
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("No.");
                    RunPageView = SORTING("Job No.", "Job Task No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                }
            }
        }
        area(processing)
        {
            group(Tickets)
            {
                Caption = 'Tickets';
                action(CollectTicketPrintouts)
                {
                    Caption = 'Collect Ticket Printouts';
                    Image = GetSourceDoc;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        EventTicketMgt.CollectTickets(Rec);
                    end;
                }
            }
            group("<Action9>")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CopyEvent)
                {
                    Caption = '&Copy Event';
                    Ellipsis = true;
                    Image = CopyFromTask;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EventCopy: Page "NPR Event Copy";
                        EventCard: Page "NPR Event Card";
                        NewJob: Record Job;
                    begin
                        //-NPR5.32 [275974]
                        /*
                        CopyJob.SetFromJob(Rec);
                        CopyJob.RUNMODAL;
                        */
                        EventCopy.SetFromJob(Rec);
                        EventCopy.RunModal;
                        if EventCopy.GetConfirmAnswer then begin
                            EventCopy.GetTargetJob(NewJob);
                            EventCard.SetTableView(NewJob);
                            EventCard.Run;
                        end;
                        //+NPR5.32 [275974]

                    end;
                }
                action("Create Job &Sales Invoice")
                {
                    Caption = 'Create Job &Sales Invoice';
                    Image = CreateJobSalesInvoice;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        JobCreateSalesInvoice: Report "Job Create Sales Invoice";
                        JobTask: Record "Job Task";
                    begin
                        //-NPR5.36 [287804]
                        JobTask.SetRange("Job No.", Rec."No.");
                        JobCreateSalesInvoice.SetTableView(JobTask);
                        JobCreateSalesInvoice.Run;
                        //+NPR5.36 [287804]
                    end;
                }
                action(CopyAttribute)
                {
                    Caption = 'Copy Attributes';
                    Ellipsis = true;
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EventCopy: Page "NPR Event Copy Attr./Templ.";
                    begin
                        //-NPR5.31 [269162]
                        //EventCopy.SetFromEvent(Rec,0);
                        EventCopy.SetFromEvent("No.", 0);
                        //+NPR5.31 [269162]
                        EventCopy.RunModal;
                    end;
                }
            }
            group(Outlook)
            {
                Caption = 'Outlook';
                action(SendToCalendar)
                {
                    Caption = 'Send to Calendar';
                    Ellipsis = true;
                    Image = Calendar;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.SendToCalendar(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(RemoveFromCalendar)
                {
                    Caption = 'Remove from Calendar';
                    Ellipsis = true;
                    Image = RemoveContacts;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.RemoveFromCalendar(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(GetResponse)
                {
                    Caption = 'Get Attendee Response';
                    Image = Answers;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        EventCalendarMgt.GetCalendarAttendeeResponses(Rec);
                        CurrPage.Update(false);
                    end;
                }
                group("Send E-Mail to")
                {
                    Caption = 'Send E-Mail to';
                    Image = SendMail;
                    action(SendEmailToCustomer)
                    {
                        Caption = 'Customer';
                        Ellipsis = true;
                        Image = Customer;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            //-NPR5.55 [374887]
                            //EventEmailMgt.SendEMail(Rec,0);
                            EventEmailMgt.SendEMail(Rec, 0, 0);
                            //+NPR5.55 [374887]
                            CurrPage.Update(false);
                        end;
                    }
                    action(SendEmailToTeam)
                    {
                        Caption = 'Team';
                        Ellipsis = true;
                        Image = TeamSales;
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            //-NPR5.55 [374887]
                            //EventEmailMgt.SendEMail(Rec,1);
                            EventEmailMgt.SendEMail(Rec, 1, 0);
                            //+NPR5.55 [374887]
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Job Actual to Budget")
            {
                Caption = 'Job Actual to Budget';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Actual To Budget";
                ApplicationArea = All;
            }
            action("Job Analysis")
            {
                Caption = 'Job Analysis';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Analysis";
                ApplicationArea = All;
            }
            action("Job - Planning Lines")
            {
                Caption = 'Job - Planning Lines';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job - Planning Lines";
                ApplicationArea = All;
            }
            action("Job - Suggested Billing")
            {
                Caption = 'Job - Suggested Billing';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Suggested Billing";
                ApplicationArea = All;
            }
            action("Jobs per Customer")
            {
                Caption = 'Jobs per Customer';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Customer";
                ApplicationArea = All;
            }
            action("Items per Job")
            {
                Caption = 'Items per Job';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Items per Job";
                ApplicationArea = All;
            }
            action("Jobs per Item")
            {
                Caption = 'Jobs per Item';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Item";
                ApplicationArea = All;
            }
            group("Financial Management")
            {
                Caption = 'Financial Management';
                Image = "Report";
                action("Job WIP to G/L")
                {
                    Caption = 'Job WIP to G/L';
                    Image = "Report";
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job WIP To G/L";
                    ApplicationArea = All;
                }
            }
            group(ActionGroup23)
            {
                Caption = 'History';
                Image = "Report";
                action("Jobs - Transaction Detail")
                {
                    Caption = 'Jobs - Transaction Detail';
                    Image = "Report";
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job - Transaction Detail";
                    ApplicationArea = All;
                }
                action("Job Register")
                {
                    Caption = 'Job Register';
                    Image = "Report";
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job Register";
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "NPR Event" := true;
    end;

    var
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventEmailMgt: Codeunit "NPR Event Email Management";
        EventMgt: Codeunit "NPR Event Management";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
}

