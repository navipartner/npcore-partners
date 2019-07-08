page 6060152 "Event List"
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

    Caption = 'Event List';
    CardPageID = "Event Card";
    Editable = false;
    PageType = List;
    SourceTable = Job;
    SourceTableView = WHERE(Event=CONST(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Bill-to Customer No.";"Bill-to Customer No.")
                {
                }
                field("Bill-to Name";"Bill-to Name")
                {
                }
                field("Event Status";"Event Status")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Person Responsible";"Person Responsible")
                {
                    Visible = false;
                }
                field("Next Invoice Date";"Next Invoice Date")
                {
                    Visible = false;
                }
                field("Job Posting Group";"Job Posting Group")
                {
                    Visible = false;
                }
                field("Search Description";"Search Description")
                {
                }
                field("Total Amount";"Total Amount")
                {
                }
                field("Est. Total Amount Incl. VAT";"Est. Total Amount Incl. VAT")
                {
                }
                field("Person Responsible Name";"Person Responsible Name")
                {
                }
                field("% of Overdue Planning Lines";PercentOverdue)
                {
                    Caption = '% of Overdue Planning Lines';
                    Editable = false;
                    Visible = false;
                }
                field("% Completed";PercentCompleted)
                {
                    Caption = '% Completed';
                    Editable = false;
                    Visible = false;
                }
                field("% Invoiced";PercentInvoiced)
                {
                    Caption = '% Invoiced';
                    Editable = false;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control1907234507;"Sales Hist. Bill-to FactBox")
            {
                SubPageLink = "No."=FIELD("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1902018507;"Customer Statistics FactBox")
            {
                SubPageLink = "No."=FIELD("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1905650007;"Job WIP/Recognition FactBox")
            {
                SubPageLink = "No."=FIELD("No.");
                Visible = true;
            }
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = true;
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
                    RunObject = Page "Event Task Lines";
                    RunPageLink = "Job No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+T';
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
                        RunPageLink = "Table ID"=CONST(167),
                                      "No."=FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension=R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        trigger OnAction()
                        var
                            Job: Record Job;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Job);
                            //-NPR5.50 [353381]
                            //DefaultDimMultiple.SetMultiJob(Job);
                            DefaultDimMultiple.SetMultiRecord(Job,Job.FieldNo("No."));
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
                    RunObject = Page "Event Statistics";
                    RunPageLink = "No."=FIELD("No.");
                    ShortCutKey = 'F7';
                }
                action(SalesDocuments)
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        EventInvoices: Page "Event Invoices";
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
                    RunPageLink = "Table Name"=CONST(Job),
                                  "No."=FIELD("No.");
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Process;

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
                    RunObject = Page "Event Attributes";
                    RunPageLink = "Job No."=FIELD("No.");

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

                    trigger OnAction()
                    var
                        EventWordLayouts: Page "Event Word Layouts";
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

                    trigger OnAction()
                    var
                        EventExchIntTempEntries: Page "Event Exch. Int. Temp. Entries";
                        EventExchIntTempEntry: Record "Event Exch. Int. Temp. Entry";
                    begin
                        EventExchIntTempEntry.SetRange("Source Record ID",Rec.RecordId);
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
                    RunPageLink = "Job No."=FIELD("No.");
                }
                action("&Item")
                {
                    Caption = '&Item';
                    Image = Item;
                    RunObject = Page "Job Item Prices";
                    RunPageLink = "Job No."=FIELD("No.");
                }
                action("&G/L Account")
                {
                    Caption = '&G/L Account';
                    Image = JobPrice;
                    RunObject = Page "Job G/L Account Prices";
                    RunPageLink = "Job No."=FIELD("No.");
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
                }
                action("Res. Group All&ocated per Job")
                {
                    Caption = 'Res. Group All&ocated per Job';
                    Image = ViewJob;
                    RunObject = Page "Res. Gr. Allocated per Job";
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
                    RunPageLink = "Job No."=FIELD("No.");
                    RunPageView = SORTING("Job No.","Job Task No.","Entry Type","Posting Date");
                    ShortCutKey = 'Ctrl+F7';
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

                    trigger OnAction()
                    var
                        EventCopy: Page "Event Copy";
                        EventCard: Page "Event Card";
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

                    trigger OnAction()
                    var
                        JobCreateSalesInvoice: Report "Job Create Sales Invoice";
                        JobTask: Record "Job Task";
                    begin
                        //-NPR5.36 [287804]
                        JobTask.SetRange("Job No.",Rec."No.");
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

                    trigger OnAction()
                    var
                        EventCopy: Page "Event Copy Attr./Templ.";
                    begin
                        //-NPR5.31 [269162]
                        //EventCopy.SetFromEvent(Rec,0);
                        EventCopy.SetFromEvent("No.",0);
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

                        trigger OnAction()
                        begin
                            EventEmailMgt.SendEMail(Rec,0);
                            CurrPage.Update(false);
                        end;
                    }
                    action(SendEmailToTeam)
                    {
                        Caption = 'Team';
                        Ellipsis = true;
                        Image = TeamSales;

                        trigger OnAction()
                        begin
                            EventEmailMgt.SendEMail(Rec,1);
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
            }
            action("Job Analysis")
            {
                Caption = 'Job Analysis';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Analysis";
            }
            action("Job - Planning Lines")
            {
                Caption = 'Job - Planning Lines';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job - Planning Lines";
            }
            action("Job - Suggested Billing")
            {
                Caption = 'Job - Suggested Billing';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Job Suggested Billing";
            }
            action("Jobs per Customer")
            {
                Caption = 'Jobs per Customer';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Customer";
            }
            action("Items per Job")
            {
                Caption = 'Items per Job';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Items per Job";
            }
            action("Jobs per Item")
            {
                Caption = 'Jobs per Item';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Item";
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
                }
                action("Job Register")
                {
                    Caption = 'Job Register';
                    Image = "Report";
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job Register";
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Event" := true;
    end;

    var
        EventCalendarMgt: Codeunit "Event Calendar Management";
        EventEmailMgt: Codeunit "Event Email Management";
        EventMgt: Codeunit "Event Management";
        EventEWSMgt: Codeunit "Event EWS Management";
        EventTicketMgt: Codeunit "Event Ticket Management";
}

