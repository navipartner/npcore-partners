page 6060152 "NPR Event List"
{
    Caption = 'Event List';
    CardPageID = "NPR Event Card";
    PageType = List;
    SourceTable = Job;
    SourceTableView = WHERE("NPR Event" = CONST(true));
    PromotedActionCategories = 'New,Process,Report,Navigate,Job';
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the event.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who pays for the event.';
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer who pays for the event.';
                }
                field("Event Status"; Rec."NPR Event Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a status for the current event. You can change the status for the event as it progresses. Final calculations can be made on completed events.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified starting date of the event.';
                }
                field("Person Responsible"; Rec."Person Responsible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the person responsible for the event. You can select a number from the list of resources available in the Resource List window. The number is copied from the No. field in the Resource table. You can choose the field to see a list of resources.';
                    Visible = false;
                }
                field("Next Invoice Date"; Rec."Next Invoice Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the next invoice date for the job.';
                    Visible = false;
                }
                field("Job Posting Group"; Rec."Job Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a job posting group code for a job. To see the available codes, choose the field.';
                    Visible = false;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the additional name for the job. The field is used for searching purposes.';
                }
                field("Total Amount"; Rec."NPR Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of "Line Amount (LCY)" of all the planning lines on this event.';
                }
                field("Est. Total Amount Incl. VAT"; Rec."NPR Est. Total Amt. Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of "Est. Total Amount Incl. VAT" of all the planning lines on this event.';
                }
                field("Person Responsible Name"; Rec."NPR Person Responsible Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the person responsible for the event.';
                }
                field("% of Overdue Planning Lines"; Rec.PercentOverdue)
                {
                    ApplicationArea = All;
                    Caption = '% of Overdue Planning Lines';
                    Editable = false;
                    ToolTip = 'Specifies the percent of planning lines that are overdue for this event.';
                    Visible = false;
                }
                field("% Completed"; Rec.PercentCompleted)
                {
                    ApplicationArea = All;
                    Caption = '% Completed';
                    Editable = false;
                    ToolTip = 'Specifies the completion percentage for this event.';
                    Visible = false;
                }
                field("% Invoiced"; Rec.PercentInvoiced)
                {
                    ApplicationArea = All;
                    Caption = '% Invoiced';
                    Editable = false;
                    ToolTip = 'Specifies the invoiced percentage for this event.';
                    Visible = false;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a date when event was created.';
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Task Lines";
                    RunPageLink = "Job No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+T';
                    ApplicationArea = All;
                    ToolTip = 'Plan how you want to set up your planning information. In this window you can specify the tasks involved in an event. To start planning an event or to post usage for an event, you must set up at least one event task.';
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    ToolTip = 'Groups actions related with dimensions.';
                    action("Dimensions-&Single")
                    {
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(167),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ApplicationArea = All;
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            Job: Record Job;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Job);
                            DefaultDimMultiple.SetMultiRecord(Job, Job.FieldNo("No."));
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                action("&Statistics")
                {
                    Caption = '&Statistics';
                    Image = Statistics;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                    ApplicationArea = All;
                    ToolTip = 'View this event''s statistics.';
                }
                action(SalesDocuments)
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'View sales documents that are related to the selected event.';

                    trigger OnAction()
                    var
                        EventInvoices: Page "NPR Event Invoices";
                    begin
                        EventInvoices.SetPrJob(Rec);
                        EventInvoices.RunModal;
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
                    ToolTip = 'View or add comments for the record.';
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'View more details about potential errors/actions that occur on this event.';

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(Rec.RecordId);
                    end;
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    Image = BulletList;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Event Attributes";
                    RunPageLink = "Job No." = FIELD("No.");
                    ApplicationArea = All;
                    ToolTip = 'View or add attributes which will be associated with this event. Attributes are custom made labels that let you track different statistics per event or can be used as a set of multiple cross-labels for which you can define values.';
                }
                action(WordLayouts)
                {
                    Caption = 'Word Layouts';
                    Image = Quote;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'View or add a word document with specific layout/data for this event.';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'View or add different templates to be used for Microsoft Exchange integration. These include e-mails, meeting requests and appointments.';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'View a summary that shows a nice overview of who the sender and receipients are when using Microsoft Exchange integration. Removes the uncertainty of not knowing to whom the e-mail or a meeting request will be send to.';

                    trigger OnAction()
                    begin
                        EventEWSMgt.ShowExchIntSummary(Rec);
                    end;
                }
            }
            group(Prices)
            {
                Caption = '&Prices';
                Image = Price;
                Visible = ExtendedPriceEnabled;
                action(SalesPriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists (Prices)';
                    Image = Price;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different prices for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Price);
                    end;
                }
                action(SalesPriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists (Discounts)';
                    Image = LineDiscount;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Discount);
                    end;
                }
                action(PurchasePriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists (Prices)';
                    Image = Price;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different prices for products that you buy from the vendor. An product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Price);
                    end;
                }
                action(PurchasePriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists (Discounts)';
                    Image = LineDiscount;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. An product discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Discount);
                    end;
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
                    ToolTip = 'View this event''s resource allocation.';
                }
                action("Res. Group All&ocated per Job")
                {
                    Caption = 'Res. Group All&ocated per Job';
                    Image = ViewJob;
                    RunObject = Page "Res. Gr. Allocated per Job";
                    ApplicationArea = All;
                    ToolTip = 'View the event''s resource group allocation.';
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("No.");
                    RunPageView = SORTING("Job No.", "Job Task No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
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
                    ToolTip = 'Collects tickets printouts for all issued tickets. Used for tickets which have a layout defined in Magento.';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Copy an event and its event tasks, planning lines, and prices.';

                    trigger OnAction()
                    var
                        EventCopy: Page "NPR Event Copy";
                        EventCard: Page "NPR Event Card";
                        NewJob: Record Job;
                    begin
                        EventCopy.SetFromJob(Rec);
                        EventCopy.RunModal;
                        if EventCopy.GetConfirmAnswer then begin
                            EventCopy.GetTargetJob(NewJob);
                            EventCard.SetTableView(NewJob);
                            EventCard.Run;
                        end;
                    end;
                }
                action("Create Job &Sales Invoice")
                {
                    Caption = 'Create Job &Sales Invoice';
                    Image = CreateJobSalesInvoice;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Use a batch job to help you create event sales invoices for the involved event planning lines.';

                    trigger OnAction()
                    var
                        JobCreateSalesInvoice: Report "Job Create Sales Invoice";
                        JobTask: Record "Job Task";
                    begin
                        JobTask.SetRange("Job No.", Rec."No.");
                        JobCreateSalesInvoice.SetTableView(JobTask);
                        JobCreateSalesInvoice.Run;
                    end;
                }
                action(CopyAttribute)
                {
                    Caption = 'Copy Attributes';
                    Ellipsis = true;
                    Image = Copy;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Copy attributes from one event to another.';

                    trigger OnAction()
                    var
                        EventCopy: Page "NPR Event Copy Attr./Templ.";
                    begin
                        EventCopy.SetFromEvent(Rec."No.", 0);
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
                    ToolTip = 'Creates an exchange calendar item. This can be either an appointment or a meeting request. Calendar item will be created in the senders calendar. You can use Exch. Int. E-mail Summary action to check who the sender is.';

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
                    ToolTip = 'Removes an exchange calendar created by Send to Calendar action. You''ll be prompted to select which one (if multiple) and to specify a reson for removal.';

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
                    ToolTip = 'Checks for the attendee response on the meeting request previously sent. Response from each resource is checked and status is updated in the lines.';

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
                        ToolTip = 'Sends an e-mail to the customer who is paying for the event. E-mail sent is fully customizable. Use Exch. Int. Templates action to define subject and body of the e-mail, Word Layouts action to set attachment and Exch. Int. E-mail Summary to check who the sender/receipient is before sending it.';

                        trigger OnAction()
                        begin
                            EventEmailMgt.SendEMail(Rec, 0, 0);
                            CurrPage.Update(false);
                        end;
                    }
                    action(SendEmailToTeam)
                    {
                        Caption = 'Team';
                        Ellipsis = true;
                        Image = TeamSales;
                        ApplicationArea = All;
                        ToolTip = 'Sends an e-mail to the team responsible to prepare the event. E-mail sent is fully customizable. Use Exch. Int. Templates action to define subject and body of the e-mail, Word Layouts action to set attachment and Exch. Int. E-mail Summary to check who the sender/receipient is before sending it.';

                        trigger OnAction()
                        begin
                            EventEmailMgt.SendEMail(Rec, 1, 0);
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Items per Job")
            {
                Caption = 'Items per Job';
                Image = "Report";
                Promoted = false;
                RunObject = Report "Items per Job";
                ApplicationArea = All;
                ToolTip = 'View which items are used for a specific event.';
            }
            action("Jobs per Item")
            {
                Caption = 'Jobs per Item';
                Image = "Report";
                Promoted = false;
                RunObject = Report "Jobs per Item";
                ApplicationArea = All;
                ToolTip = 'Run the Jobs per item report.';
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
                    RunObject = Report "Job WIP To G/L";
                    ApplicationArea = All;
                    ToolTip = 'View the value of work in process on the events that you select compared to the amount that has been posted in the general ledger.';
                }
            }
            group(ActionGroup23)
            {
                Caption = 'History';
                Image = "Report";
                action("Job Register")
                {
                    Caption = 'Job Register';
                    Image = "Report";
                    Promoted = false;
                    RunObject = Report "Job Register";
                    ApplicationArea = All;
                    ToolTip = 'View one or more selected job registers. By using a filter, you can select only those register entries that you want to see. If you do not set a filter, the report can be impractical because it can contain a large amount of information. On the job journal template, you can indicate that you want the report to print when you post.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."NPR Event" := true;
    end;

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventEmailMgt: Codeunit "NPR Event Email Management";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        ExtendedPriceEnabled: Boolean;
}

