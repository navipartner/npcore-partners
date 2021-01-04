page 6060151 "NPR Event Plan. Lines Sub."
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DataCaptionExpression = Caption;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "Job Planning Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                    Visible = "Job Task No.Visible";
                    ToolTip = 'Specifies the value of the Job Task No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EventTaskLines: Page "NPR Event Task Lines";
                        JobTask: Record "Job Task";
                    begin
                        //-NPR5.49 [331208]
                        JobTask.SetRange("Job No.", Rec."Job No.");
                        if "Job Task No." <> '' then
                            JobTask.Get("Job No.", "Job Task No.");
                        EventTaskLines.LookupMode := true;
                        EventTaskLines.SetTableView(JobTask);
                        if EventTaskLines.RunModal = ACTION::LookupOK then begin
                            EventTaskLines.GetRecord(JobTask);
                            Validate("Job Task No.", JobTask."Job Task No.");
                        end;
                        //+NPR5.49 [331208]
                    end;
                }
                field("Line Type"; "Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Type field';
                }
                field("Usage Link"; "Usage Link")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Usage Link field';

                    trigger OnValidate()
                    begin
                        UsageLinkOnAfterValidate;
                    end;
                }
                field("Planning Date"; "Planning Date")
                {
                    ApplicationArea = All;
                    Editable = "Planning DateEditable";
                    ToolTip = 'Specifies the value of the Planning Date field';

                    trigger OnValidate()
                    begin
                        PlanningDateOnAfterValidate;
                    end;
                }
                field("Starting Time"; "NPR Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Starting Time field';
                }
                field("Ending Time"; "NPR Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ending Time field';
                }
                field("""Calendar Item ID"" <> ''"; "NPR Calendar Item ID" <> '')
                {
                    ApplicationArea = All;
                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Meeting Req. Exists field';
                }
                field("Calendar Item Status"; "NPR Calendar Item Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Calendar Item Status field';
                }
                field("Meeting Request Response"; "NPR Meeting Request Response")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Meeting Request Response field';
                }
                field("Mail Item Status"; "NPR Mail Item Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Mail Item Status field';
                }
                field("Planned Delivery Date"; "Planned Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Planned Delivery Date field';
                }
                field("Currency Date"; "Currency Date")
                {
                    ApplicationArea = All;
                    Editable = "Currency DateEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Date field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Editable = "Document No.Editable";
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = TypeEditable;
                    ToolTip = 'Specifies the value of the Type field';

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate;
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = "No.Editable";
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = DescriptionEditable;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Resource E-Mail"; "NPR Resource E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Resource E-Mail field';
                }
                field("Ticket Status"; "NPR Ticket Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Ticket Status field';
                }
                field("Ticket Collect Status"; "NPR Ticket Collect Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ticket Collect Status field';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = "Variant CodeEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';

                    trigger OnValidate()
                    begin
                        VariantCodeOnAfterValidate;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    Editable = "Location CodeEditable";
                    ToolTip = 'Specifies the value of the Location Code field';

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate;
                    end;
                }
                field("Work Type Code"; "Work Type Code")
                {
                    ApplicationArea = All;
                    Editable = "Work Type CodeEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Work Type Code field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = "Unit of Measure CodeEditable";
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida;
                    end;
                }
                field(Control5; Reserve)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserve field';

                    trigger OnValidate()
                    begin
                        ReserveOnAfterValidate;
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reserved Quantity field';
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                }
                field("Remaining Qty."; "Remaining Qty.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Qty. field';
                }
                field("Direct Unit Cost (LCY)"; "Direct Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost (LCY) field';
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = "Unit CostEditable";
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost (LCY) field';
                }
                field("Total Cost"; "Total Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Cost field';
                }
                field("Remaining Total Cost"; "Remaining Total Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Total Cost field';
                }
                field("Total Cost (LCY)"; "Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Cost (LCY) field';
                }
                field("Remaining Total Cost (LCY)"; "Remaining Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Total Cost (LCY) field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = "Unit PriceEditable";
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Price (LCY) field';
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    Editable = "Line AmountEditable";
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field("Remaining Line Amount"; "Remaining Line Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Line Amount field';
                }
                field("Line Amount (LCY)"; "Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount (LCY) field';
                }
                field("Remaining Line Amount (LCY)"; "Remaining Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Line Amount (LCY) field';
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = "Line Discount AmountEditable";
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    Editable = "Line Discount %Editable";
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Total Price"; "Total Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Price field';
                }
                field("Total Price (LCY)"; "Total Price (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Price (LCY) field';
                }
                field("Qty. Posted"; "Qty. Posted")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Posted field';
                }
                field("Qty. to Transfer to Journal"; "Qty. to Transfer to Journal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Transfer to Journal field';
                }
                field("Posted Total Cost"; "Posted Total Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Total Cost field';
                }
                field("Posted Total Cost (LCY)"; "Posted Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Total Cost (LCY) field';
                }
                field("Posted Line Amount"; "Posted Line Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Line Amount field';
                }
                field("Posted Line Amount (LCY)"; "Posted Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Line Amount (LCY) field';
                }
                field("Qty. Transferred to Invoice"; "Qty. Transferred to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. Transferred to Invoice field';

                    trigger OnDrillDown()
                    begin
                        DrillDownJobInvoices;
                    end;
                }
                field("Qty. to Transfer to Invoice"; "Qty. to Transfer to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Transfer to Invoice field';
                }
                field("Qty. Invoiced"; "Qty. Invoiced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. Invoiced field';

                    trigger OnDrillDown()
                    begin
                        DrillDownJobInvoices;
                    end;
                }
                field("Qty. to Invoice"; "Qty. to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Invoice field';
                }
                field("Invoiced Amount (LCY)"; "Invoiced Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Invoiced Amount (LCY) field';

                    trigger OnDrillDown()
                    begin
                        DrillDownJobInvoices;
                    end;
                }
                field("Invoiced Cost Amount (LCY)"; "Invoiced Cost Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Invoiced Cost Amount (LCY) field';

                    trigger OnDrillDown()
                    begin
                        DrillDownJobInvoices;
                    end;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';
                }
                field("Job Contract Entry No."; "Job Contract Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Job Contract Entry No. field';
                }
                field("Ledger Entry Type"; "Ledger Entry Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Ledger Entry Type field';
                }
                field("Ledger Entry No."; "Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Ledger Entry No. field';
                }
                field("System-Created Entry"; "System-Created Entry")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the System-Created Entry field';
                }
                field(Overdue; Overdue)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Overdue field';
                }
                field("Est. Unit Price Incl. VAT"; "NPR Est. Unit Price Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Est. Unit Price Incl. VAT field';
                }
                field("Est. Line Amount Incl. VAT"; "NPR Est. Line Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Est. Line Amount Incl. VAT field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Job Planning &Line")
            {
                Caption = 'Job Planning &Line';
                Image = Line;
                action("Event &Task Lines")
                {
                    Caption = 'Event &Task Lines';
                    Image = TaskList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Task Lines";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'Shift+Ctrl+T';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Event &Task Lines action';
                }
                separator(Separator6014408)
                {
                }
                action("Linked Job Ledger E&ntries")
                {
                    Caption = 'Linked Job Ledger E&ntries';
                    Image = JobLedger;
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Linked Job Ledger E&ntries action';

                    trigger OnAction()
                    var
                        JobLedgerEntry: Record "Job Ledger Entry";
                        JobUsageLink: Record "Job Usage Link";
                    begin
                        JobUsageLink.SetRange("Job No.", "Job No.");
                        JobUsageLink.SetRange("Job Task No.", "Job Task No.");
                        JobUsageLink.SetRange("Line No.", "Line No.");

                        if JobUsageLink.FindSet then
                            repeat
                                JobLedgerEntry.Get(JobUsageLink."Entry No.");
                                JobLedgerEntry.Mark := true;
                            until JobUsageLink.Next = 0;

                        JobLedgerEntry.MarkedOnly(true);
                        PAGE.Run(PAGE::"Job Ledger Entries", JobLedgerEntry);
                    end;
                }
                action("&Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    Caption = '&Reservation Entries';
                    Image = ReservationLedger;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Reservation Entries action';

                    trigger OnAction()
                    begin
                        ShowReservationEntries(true);
                    end;
                }
                separator(Separator6014401)
                {
                }
                action(OrderPromising)
                {
                    Caption = 'Order &Promising';
                    Image = OrderPromising;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Order &Promising action';

                    trigger OnAction()
                    begin
                        ShowOrderPromisingLine;
                    end;
                }
                group(Calendar)
                {
                    Caption = 'Calendar';
                    action(Send)
                    {
                        Caption = 'Send';
                        Image = Calendar;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Send action';

                        trigger OnAction()
                        begin
                            EventCalendarMgt.SendLineToCalendarAction(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                    action(Remove)
                    {
                        Caption = 'Remove';
                        Image = RemoveContacts;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Remove action';

                        trigger OnAction()
                        begin
                            EventCalendarMgt.RemoveLineFromCalendarAction(Rec, true);
                            CurrPage.Update(false);
                        end;
                    }
                    action(GetResponse)
                    {
                        Caption = 'Get Attendee Response';
                        Image = Answers;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Get Attendee Response action';

                        trigger OnAction()
                        begin
                            EventCalendarMgt.GetCalendarAttendeeResponseAction(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                }
                action(SendEMail)
                {
                    Caption = 'Send E-Mail';
                    Image = SendMail;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send E-Mail action';

                    trigger OnAction()
                    begin
                        EventEmailMgt.SendEmailFromLine(Rec);
                        CurrPage.Update(false);
                    end;
                }
                group(Ticket)
                {
                    Caption = 'Ticket';
                    action(EditReservationAndIssue)
                    {
                        Caption = 'Edit Reservation and Issue';
                        Ellipsis = true;
                        Image = Edit;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Edit Reservation and Issue action';

                        trigger OnAction()
                        begin
                            //-NPR5.45 [323386]
                            //EventTicketMgt.EditTicketReservation(Rec);
                            EventTicketMgt.EditTicketReservationWithLog(Rec);
                            //+NPR5.45 [323386]
                            CurrPage.Update(false);
                        end;
                    }
                    action(Holder)
                    {
                        Caption = 'Edit Holder';
                        Ellipsis = true;
                        Image = EditCustomer;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Edit Holder action';

                        trigger OnAction()
                        begin
                            EventTicketMgt.EditTicketHolder(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                    separator(Separator6014426)
                    {
                    }
                    action(Register)
                    {
                        Caption = 'Register';
                        Ellipsis = true;
                        Image = CreateDocument;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Register action';

                        trigger OnAction()
                        var
                            ConfirmRegister: Label 'You''re about to register a ticket. Do you want to continue?';
                        begin
                            if not Confirm(ConfirmRegister) then
                                exit;
                            EventTicketMgt.CreateTicketReservRequest(Rec, true, true);
                            CurrPage.Update(false);
                        end;
                    }
                    action(Revoke)
                    {
                        Caption = 'Revoke';
                        Ellipsis = true;
                        Image = CancelLine;
                        Visible = false;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Revoke action';

                        trigger OnAction()
                        var
                            ConfirmRevoke: Label 'You''re about to revoke a ticket. Do you want to continue?';
                        begin
                            if not Confirm(ConfirmRevoke) then
                                exit;
                            EventTicketMgt.RevokeTicketWithLog(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                    action(Issue)
                    {
                        Caption = 'Issue';
                        Ellipsis = true;
                        Image = PostDocument;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Issue action';

                        trigger OnAction()
                        var
                            ConfirmIssue: Label 'You''re about to issue a ticket. Do you want to continue?';
                        begin
                            if not Confirm(ConfirmIssue) then
                                exit;
                            EventTicketMgt.IssueTicketWithLog(Rec, true);
                            CurrPage.Update(false);
                        end;
                    }
                    action("Confirm")
                    {
                        Caption = 'Confirm';
                        Ellipsis = true;
                        Image = ContractPayment;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Confirm action';

                        trigger OnAction()
                        var
                            ConfirmConfirm: Label 'You''re about to confirm a ticket. Do you want to continue?';
                        begin
                            if not Confirm(ConfirmConfirm) then
                                exit;
                            EventTicketMgt.ConfirmTicketWithLog(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                    separator(Separator6014435)
                    {
                    }
                    action(CollectTicket)
                    {
                        Caption = 'Collect Ticket';
                        Image = GetSourceDoc;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Collect Ticket action';

                        trigger OnAction()
                        begin
                            EventTicketMgt.CollectSingleTicket(Rec, true);
                            CurrPage.Update(false);
                        end;
                    }
                    action(ShowTicketPrintout)
                    {
                        Caption = 'Show Ticket Printout';
                        Image = PreviewChecks;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Show Ticket Printout action';

                        trigger OnAction()
                        begin
                            EventTicketMgt.ShowTicketPrintout(Rec);
                        end;
                    }
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CreateJobJournalLines)
                {
                    Caption = 'Create Job &Journal Lines';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Job &Journal Lines action';

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        JobJnlLine: Record "Job Journal Line";
                        JobTransferLine: Codeunit "Job Transfer Line";
                        JobTransferJobPlanningLine: Page "Job Transfer Job Planning Line";
                    begin
                        if JobTransferJobPlanningLine.RunModal = ACTION::OK then begin
                            JobPlanningLine.Copy(Rec);
                            CurrPage.SetSelectionFilter(JobPlanningLine);

                            if JobPlanningLine.FindSet then
                                repeat
                                    JobTransferLine.FromPlanningLineToJnlLine(
                                      JobPlanningLine, JobTransferJobPlanningLine.GetPostingDate, JobTransferJobPlanningLine.GetJobJournalTemplateName,
                                      JobTransferJobPlanningLine.GetJobJournalBatchName, JobJnlLine);
                                until JobPlanningLine.Next = 0;

                            CurrPage.Update(false);
                            Message(Text002, JobPlanningLine.TableCaption, JobJnlLine.TableCaption);
                        end;
                    end;
                }
                action("&Open Job Journal")
                {
                    Caption = '&Open Job Journal';
                    Image = Journals;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Job Journal";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Open Job Journal action';
                }
                separator(Separator16)
                {
                }
                action("Create &Sales Invoice")
                {
                    Caption = 'Create &Sales Invoice';
                    Ellipsis = true;
                    Image = Invoice;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create &Sales Invoice action';

                    trigger OnAction()
                    begin
                        CreateSalesInvoice(false);
                    end;
                }
                action("Create Sales &Credit Memo")
                {
                    Caption = 'Create Sales &Credit Memo';
                    Ellipsis = true;
                    Image = CreditMemo;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Sales &Credit Memo action';

                    trigger OnAction()
                    begin
                        CreateSalesInvoice(true);
                    end;
                }
                action("Sales &Documents")
                {
                    Caption = 'Sales &Documents';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales &Documents action';

                    trigger OnAction()
                    begin
                        //-NPR5.49 [331208]
                        //JobCreateInvoice.GetJobPlanningLineInvoices(Rec);
                        EventMgt.GetJobPlanningLineInvoices(Rec);
                        //+NPR5.49 [331208]
                    end;
                }
                separator(Separator123)
                {
                }
                action(Reserve)
                {
                    Caption = '&Reservation';
                    Ellipsis = true;
                    Image = Reserve;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Reservation action';

                    trigger OnAction()
                    begin
                        ShowReservation;
                    end;
                }
                action("Order &Tracking")
                {
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Order &Tracking action';

                    trigger OnAction()
                    begin
                        ShowTracking;
                    end;
                }
                separator(Separator130)
                {
                }
                action(DemandOverview)
                {
                    Caption = '&Demand Overview';
                    Image = Forecast;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Demand Overview action';

                    trigger OnAction()
                    var
                        DemandOverview: Page "Demand Overview";
                    begin
                        DemandOverview.SetCalculationParameter(true);

                        DemandOverview.Initialize(0D, 3, "Job No.", '', '');
                        DemandOverview.RunModal;
                    end;
                }
                action("Insert Ext. Texts")
                {
                    AccessByPermission = TableData "Extended Text Header" = R;
                    Caption = 'Insert &Ext. Texts';
                    Image = Text;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Insert &Ext. Texts action';

                    trigger OnAction()
                    begin
                        //-NPR5.49 [345047]
                        InsertExtendedText(true);
                        //+NPR5.49 [345047]
                    end;
                }
                action(DistributeAcrossPeriodAction)
                {
                    Caption = 'Distribute Across Period';
                    Image = Period;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Distribute Across Period action';

                    trigger OnAction()
                    begin
                        //-NPR5.55 [397741]
                        EventPlanLineGroupMgt.DistributeAccrossPeriod(Rec);
                        //+NPR5.55 [397741]
                    end;
                }
            }
            group(Navigate)
            {
                Caption = 'Navigate';
                action(IssuedTickets)
                {
                    Caption = 'Issued Tickets';
                    Image = ViewPostedOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Issued Tickets action';

                    trigger OnAction()
                    begin
                        //-NPR5.48 [335824]
                        EventTicketMgt.ShowIssuedTickets(Rec);
                        //+NPR5.48 [335824]
                    end;
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Activity Log action';

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(RecordId);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable("Qty. Transferred to Invoice" = 0);
    end;

    trigger OnAfterGetRecord()
    begin
        //-NPR5.55 [397741]
        ApplyStyle := Rec."NPR Group Line" and (Rec."NPR Group Source Line No." = 0);
        //+NPR5.55 [397741]
    end;

    trigger OnInit()
    begin
        "Unit CostEditable" := true;
        "Line AmountEditable" := true;
        "Line Discount %Editable" := true;
        "Line Discount AmountEditable" := true;
        "Unit PriceEditable" := true;
        "Work Type CodeEditable" := true;
        "Location CodeEditable" := true;
        "Variant CodeEditable" := true;
        "Unit of Measure CodeEditable" := true;
        DescriptionEditable := true;
        "No.Editable" := true;
        TypeEditable := true;
        "Document No.Editable" := true;
        "Currency DateEditable" := true;
        "Planning DateEditable" := true;

        "Job Task No.Visible" := true;
        "Job No.Visible" := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if "System-Created Entry" then begin
            if Confirm(Text001, false) then
                "System-Created Entry" := false
            else
                Error('');
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Job: Record Job;
    begin
        SetUpNewLine(xRec);

        //-NPR5.31 [269162]
        //-NPR5.32 [278090]
        //Job.GET(Rec."Job No.");
        //IF Job."Starting Date" <> 0D THEN
        if Job.Get(Rec."Job No.") and (Job."Starting Date" <> 0D) then
            //+NPR5.32 [278090]
            Validate("Planning Date", Job."Starting Date");
        //+NPR5.31 [269162]
    end;

    trigger OnOpenPage()
    var
        Job: Record Job;
    begin
        if Job.Get(JobNo) then
            CurrPage.Editable(not (Job.Blocked = Job.Blocked::All));

        if ActiveField = 1 then;
        if ActiveField = 2 then;
        if ActiveField = 3 then;
        if ActiveField = 4 then;
    end;

    var
        JobCreateInvoice: Codeunit "Job Create-Invoice";
        ActiveField: Option " ",Cost,CostLCY,PriceLCY,Price;
        Text001: Label 'This job planning line was automatically generated. Do you want to continue?';
        JobNo: Code[20];
        [InDataSet]
        "Job No.Visible": Boolean;
        [InDataSet]
        "Job Task No.Visible": Boolean;
        [InDataSet]
        "Planning DateEditable": Boolean;
        [InDataSet]
        "Currency DateEditable": Boolean;
        [InDataSet]
        "Document No.Editable": Boolean;
        [InDataSet]
        TypeEditable: Boolean;
        [InDataSet]
        "No.Editable": Boolean;
        [InDataSet]
        DescriptionEditable: Boolean;
        [InDataSet]
        "Unit of Measure CodeEditable": Boolean;
        [InDataSet]
        "Variant CodeEditable": Boolean;
        [InDataSet]
        "Location CodeEditable": Boolean;
        [InDataSet]
        "Work Type CodeEditable": Boolean;
        [InDataSet]
        "Unit PriceEditable": Boolean;
        [InDataSet]
        "Line Discount AmountEditable": Boolean;
        [InDataSet]
        "Line Discount %Editable": Boolean;
        [InDataSet]
        "Line AmountEditable": Boolean;
        [InDataSet]
        "Unit CostEditable": Boolean;
        Text002: Label 'The %1 was successfully transferred to a %2.';
        ApplyStyle: Boolean;
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventEmailMgt: Codeunit "NPR Event Email Management";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        EventMgt: Codeunit "NPR Event Management";
        EventPlanLineGroupMgt: Codeunit "NPR Event Plan.Line Group. Mgt";

    local procedure CreateSalesInvoice(CrMemo: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
    begin
        TestField("Line No.");
        JobPlanningLine.Copy(Rec);
        CurrPage.SetSelectionFilter(JobPlanningLine);
        JobCreateInvoice.CreateSalesInvoice(JobPlanningLine, CrMemo)
    end;

    local procedure SetEditable(Edit: Boolean)
    begin
        "Planning DateEditable" := Edit;
        "Currency DateEditable" := Edit;
        "Document No.Editable" := Edit;
        TypeEditable := Edit;
        "No.Editable" := Edit;
        DescriptionEditable := Edit;
        "Unit of Measure CodeEditable" := Edit;
        "Variant CodeEditable" := Edit;
        "Location CodeEditable" := Edit;
        "Work Type CodeEditable" := Edit;
        "Unit PriceEditable" := Edit;
        "Line Discount AmountEditable" := Edit;
        "Line Discount %Editable" := Edit;
        "Line AmountEditable" := Edit;
        "Unit CostEditable" := Edit;
    end;

    procedure SetActiveField(ActiveField2: Integer)
    begin
        ActiveField := ActiveField2;
    end;

    procedure SetJobNo(No: Code[20])
    begin
        JobNo := No;
    end;

    procedure SetJobNoVisible(JobNoVisible: Boolean)
    begin
        "Job No.Visible" := JobNoVisible;
    end;

    procedure SetJobTaskNoVisible(JobTaskNoVisible: Boolean)
    begin
        "Job Task No.Visible" := JobTaskNoVisible;
    end;

    local procedure PerformAutoReserve()
    begin
        if (Reserve = Reserve::Always) and
           ("Remaining Qty. (Base)" <> 0)
        then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;

    local procedure UsageLinkOnAfterValidate()
    begin
        PerformAutoReserve;
    end;

    local procedure PlanningDateOnAfterValidate()
    begin
        if "Planning Date" <> xRec."Planning Date" then
            PerformAutoReserve;
    end;

    local procedure NoOnAfterValidate()
    begin
        //-NPR5.49 [345047]
        InsertExtendedText(false);
        //+NPR5.49 [345047]
        if "No." <> xRec."No." then
            PerformAutoReserve;
    end;

    local procedure VariantCodeOnAfterValidate()
    begin
        if "Variant Code" <> xRec."Variant Code" then
            PerformAutoReserve;
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        if "Location Code" <> xRec."Location Code" then
            PerformAutoReserve;
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        PerformAutoReserve;
    end;

    local procedure ReserveOnAfterValidate()
    begin
        PerformAutoReserve;
    end;

    local procedure QuantityOnAfterValidate()
    begin
        PerformAutoReserve;
        if (Type = Type::Item) and (Quantity <> xRec.Quantity) then
            CurrPage.Update(true);
    end;

    local procedure InsertExtendedText(Unconditionally: Boolean)
    var
        EventTransferExtText: Codeunit "NPR Event Transf.Ext.Text Mgt.";
    begin
        //-NPR5.49 [345047]
        if EventTransferExtText.EventCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            Commit;
            EventTransferExtText.InsertEventExtText(Rec);
        end;
        if EventTransferExtText.MakeUpdate then
            CurrPage.Update(true);
        //+NPR5.49 [345047]
    end;

    procedure DistributeAcrossPeriod()
    begin
        //-NPR5.55 [397741]
        EventPlanLineGroupMgt.DistributeAccrossPeriod(Rec);
        //+NPR5.55 [397741]
    end;
}

