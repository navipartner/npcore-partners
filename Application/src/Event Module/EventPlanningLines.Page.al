page 6014549 "NPR Event Planning Lines"
{
    AutoSplitKey = true;
    Caption = 'Event Planning Lines';
    DataCaptionExpression = Rec.Caption();
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Job Planning Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Job Task No."; Rec."Job Task No.")
                {

                    Visible = "Job Task No.Visible";
                    ToolTip = 'Specifies the value of the Job Task No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EventTaskLines: Page "NPR Event Task Lines";
                        JobTask: Record "Job Task";
                    begin
                        JobTask.SetRange("Job No.", Rec."Job No.");
                        if Rec."Job Task No." <> '' then
                            JobTask.Get(Rec."Job No.", Rec."Job Task No.");
                        EventTaskLines.LookupMode := true;
                        EventTaskLines.SetTableView(JobTask);
                        if EventTaskLines.RunModal() = ACTION::LookupOK then begin
                            EventTaskLines.GetRecord(JobTask);
                            Rec.Validate("Job Task No.", JobTask."Job Task No.");
                        end;
                    end;
                }
                field("Line Type"; Rec."Line Type")
                {

                    ToolTip = 'Specifies the value of the Line Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Usage Link"; Rec."Usage Link")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Usage Link field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UsageLinkOnAfterValidate();
                    end;
                }
                field("Planning Date"; Rec."Planning Date")
                {

                    Editable = "Planning DateEditable";
                    ToolTip = 'Specifies the value of the Planning Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        PlanningDateOnAfterValidate();
                    end;
                }
                field("Starting Time"; Rec."NPR Starting Time")
                {

                    ToolTip = 'Specifies the value of the NPR Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."NPR Ending Time")
                {

                    ToolTip = 'Specifies the value of the NPR Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Meeting Req. Exists"; Rec."NPR Calendar Item ID" <> '')
                {

                    Caption = 'Meeting Req. Exists';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Meeting Req. Exists field';
                    ApplicationArea = NPRRetail;
                }
                field("Calendar Item Status"; Rec."NPR Calendar Item Status")
                {

                    ToolTip = 'Specifies the value of the NPR Calendar Item Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Meeting Request Response"; Rec."NPR Meeting Request Response")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Meeting Request Response field';
                    ApplicationArea = NPRRetail;
                }
                field("Mail Item Status"; Rec."NPR Mail Item Status")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Mail Item Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Planned Delivery Date"; Rec."Planned Delivery Date")
                {

                    ToolTip = 'Specifies the value of the Planned Delivery Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Date"; Rec."Currency Date")
                {

                    Editable = "Currency DateEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    Editable = "Document No.Editable";
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Editable = TypeEditable;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate();
                    end;
                }
                field("No."; Rec."No.")
                {

                    Editable = "No.Editable";
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate();
                    end;
                }
                field(Description; Rec.Description)
                {

                    Editable = DescriptionEditable;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Resource E-Mail"; Rec."NPR Resource E-Mail")
                {

                    ToolTip = 'Specifies the value of the NPR Resource E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Status"; Rec."NPR Ticket Status")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Ticket Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Collect Status"; Rec."NPR Ticket Collect Status")
                {

                    ToolTip = 'Specifies the value of the NPR Ticket Collect Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Editable = "Variant CodeEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        VariantCodeOnAfterValidate();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {

                    Editable = "Location CodeEditable";
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate();
                    end;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {

                    Editable = "Work Type CodeEditable";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Work Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    Editable = "Unit of Measure CodeEditable";
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida();
                    end;
                }
                field(Control5; Rec.Reserve)
                {

                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserve field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ReserveOnAfterValidate();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate();
                    end;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {

                    ToolTip = 'Specifies the value of the Reserved Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Qty."; Rec."Remaining Qty.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Unit Cost (LCY)"; Rec."Direct Unit Cost (LCY)")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Direct Unit Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {

                    Editable = "Unit CostEditable";
                    ToolTip = 'Specifies the value of the Unit Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {

                    ToolTip = 'Specifies the value of the Unit Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Cost"; Rec."Total Cost")
                {

                    ToolTip = 'Specifies the value of the Total Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Total Cost"; Rec."Remaining Total Cost")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Total Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Cost (LCY)"; Rec."Total Cost (LCY)")
                {

                    ToolTip = 'Specifies the value of the Total Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Total Cost (LCY)"; Rec."Remaining Total Cost (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Total Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    Editable = "Unit PriceEditable";
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Price (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Amount"; Rec."Line Amount")
                {

                    Editable = "Line AmountEditable";
                    ToolTip = 'Specifies the value of the Line Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Line Amount"; Rec."Remaining Line Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Line Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Line Amount (LCY)"; Rec."Remaining Line Amount (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Line Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {

                    Editable = "Line Discount AmountEditable";
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {

                    Editable = "Line Discount %Editable";
                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Price"; Rec."Total Price")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Price (LCY)"; Rec."Total Price (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Price (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Posted"; Rec."Qty. Posted")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Qty. Posted field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. to Transfer to Journal"; Rec."Qty. to Transfer to Journal")
                {

                    ToolTip = 'Specifies the value of the Qty. to Transfer to Journal field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Total Cost"; Rec."Posted Total Cost")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Total Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Total Cost (LCY)"; Rec."Posted Total Cost (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Total Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Line Amount"; Rec."Posted Line Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Line Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Posted Line Amount (LCY)"; Rec."Posted Line Amount (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Posted Line Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Transferred to Invoice"; Rec."Qty. Transferred to Invoice")
                {

                    ToolTip = 'Specifies the value of the Qty. Transferred to Invoice field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownJobInvoices();
                    end;
                }
                field("Qty. to Transfer to Invoice"; Rec."Qty. to Transfer to Invoice")
                {

                    ToolTip = 'Specifies the value of the Qty. to Transfer to Invoice field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Invoiced"; Rec."Qty. Invoiced")
                {

                    ToolTip = 'Specifies the value of the Qty. Invoiced field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownJobInvoices();
                    end;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {

                    ToolTip = 'Specifies the value of the Qty. to Invoice field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoiced Amount (LCY)"; Rec."Invoiced Amount (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Invoiced Amount (LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownJobInvoices();
                    end;
                }
                field("Invoiced Cost Amount (LCY)"; Rec."Invoiced Cost Amount (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Invoiced Cost Amount (LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownJobInvoices();
                    end;
                }
                field("User ID"; Rec."User ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Serial No."; Rec."Serial No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Lot No."; Rec."Lot No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Contract Entry No."; Rec."Job Contract Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Job Contract Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Ledger Entry Type"; Rec."Ledger Entry Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Ledger Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Ledger Entry No."; Rec."Ledger Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Ledger Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("System-Created Entry"; Rec."System-Created Entry")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the System-Created Entry field';
                    ApplicationArea = NPRRetail;
                }
                field(Overdue; Rec.Overdue())
                {

                    Caption = 'Overdue';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Overdue field';
                    ApplicationArea = NPRRetail;
                }
                field("Est. Unit Price Incl. VAT"; Rec."NPR Est. Unit Price Incl. VAT")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Est. Unit Price Incl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Est. Line Amount Incl. VAT"; Rec."NPR Est. Line Amount Incl. VAT")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the NPR Est. Line Amount Incl. VAT field';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR Event Task Lines";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'Shift+Ctrl+T';

                    ToolTip = 'Executes the Event &Task Lines action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6014408)
                {
                }
                action("Linked Job Ledger E&ntries")
                {
                    Caption = 'Linked Job Ledger E&ntries';
                    Image = JobLedger;
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Linked Job Ledger E&ntries action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        JobLedgerEntry: Record "Job Ledger Entry";
                        JobUsageLink: Record "Job Usage Link";
                    begin
                        JobUsageLink.SetRange("Job No.", Rec."Job No.");
                        JobUsageLink.SetRange("Job Task No.", Rec."Job Task No.");
                        JobUsageLink.SetRange("Line No.", Rec."Line No.");

                        if JobUsageLink.FindSet() then
                            repeat
                                JobLedgerEntry.Get(JobUsageLink."Entry No.");
                                JobLedgerEntry.Mark := true;
                            until JobUsageLink.Next() = 0;

                        JobLedgerEntry.MarkedOnly(true);
                        PAGE.Run(PAGE::"Job Ledger Entries", JobLedgerEntry);
                    end;
                }
                action("&Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    Caption = '&Reservation Entries';
                    Image = ReservationLedger;

                    ToolTip = 'Executes the &Reservation Entries action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowReservationEntries(true);
                    end;
                }
                separator(Separator6014401)
                {
                }
                action(OrderPromising)
                {
                    Caption = 'Order &Promising';
                    Image = OrderPromising;

                    ToolTip = 'Executes the Order &Promising action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowOrderPromisingLine();
                    end;
                }
                group(Calendar)
                {
                    Caption = 'Calendar';
                    action(Send)
                    {
                        Caption = 'Send';
                        Image = Calendar;

                        ToolTip = 'Executes the Send action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Remove action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Get Attendee Response action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            EventCalendarMgt.GetCalendarAttendeeResponse(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                }
                action(SendEMail)
                {
                    Caption = 'Send E-Mail';
                    Image = SendMail;

                    ToolTip = 'Executes the Send E-Mail action';
                    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Edit Reservation and Issue action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            EventTicketMgt.EditTicketReservationWithLog(Rec);
                            CurrPage.Update(false);
                        end;
                    }
                    action(Holder)
                    {
                        Caption = 'Edit Holder';
                        Ellipsis = true;
                        Image = EditCustomer;

                        ToolTip = 'Executes the Edit Holder action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Register action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Revoke action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Issue action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Confirm action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Collect Ticket action';
                        ApplicationArea = NPRRetail;

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

                        ToolTip = 'Executes the Show Ticket Printout action';
                        ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Create Job &Journal Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        JobJnlLine: Record "Job Journal Line";
                        JobTransferLine: Codeunit "Job Transfer Line";
                        JobTransferJobPlanningLine: Page "Job Transfer Job Planning Line";
                    begin
                        if JobTransferJobPlanningLine.RunModal() = ACTION::OK then begin
                            JobPlanningLine.Copy(Rec);
                            CurrPage.SetSelectionFilter(JobPlanningLine);

                            if JobPlanningLine.FindSet() then
                                repeat
                                    JobTransferLine.FromPlanningLineToJnlLine(
                                      JobPlanningLine, JobTransferJobPlanningLine.GetPostingDate(), JobTransferJobPlanningLine.GetJobJournalTemplateName(),
                                      JobTransferJobPlanningLine.GetJobJournalBatchName(), JobJnlLine);
                                until JobPlanningLine.Next() = 0;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Job Journal";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");

                    ToolTip = 'Executes the &Open Job Journal action';
                    ApplicationArea = NPRRetail;
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Create &Sales Invoice action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Executes the Create Sales &Credit Memo action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Executes the Sales &Documents action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventMgt.GetJobPlanningLineInvoices(Rec);
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

                    ToolTip = 'Executes the &Reservation action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowReservation();
                    end;
                }
                action("Order &Tracking")
                {
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;

                    ToolTip = 'Executes the Order &Tracking action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowTracking();
                    end;
                }
                separator(Separator130)
                {
                }
                action(DemandOverview)
                {
                    Caption = '&Demand Overview';
                    Image = Forecast;

                    ToolTip = 'Executes the &Demand Overview action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        DemandOverview: Page "Demand Overview";
                    begin
                        DemandOverview.SetCalculationParameter(true);

                        DemandOverview.Initialize(0D, 3, Rec."Job No.", '', '');
                        DemandOverview.RunModal();
                    end;
                }
                action("Insert Ext. Texts")
                {
                    AccessByPermission = TableData "Extended Text Header" = R;
                    Caption = 'Insert &Ext. Texts';
                    Image = Text;

                    ToolTip = 'Executes the Insert &Ext. Texts action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        InsertExtendedText(true);
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

                    ToolTip = 'Executes the Issued Tickets action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EventTicketMgt.ShowIssuedTickets(Rec);
                    end;
                }
                action(ActivityLog)
                {
                    Caption = 'Activity Log';
                    Image = Log;

                    ToolTip = 'Executes the Activity Log action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ActivityLog: Record "Activity Log";
                    begin
                        ActivityLog.ShowEntries(Rec.RecordId);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable(Rec."Qty. Transferred to Invoice" = 0);
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
        if Rec."System-Created Entry" then begin
            if Confirm(Text001, false) then
                Rec."System-Created Entry" := false
            else
                Error('');
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Job: Record Job;
    begin
        Rec.SetUpNewLine(xRec);

        if Job.Get(Rec."Job No.") and (Job."Starting Date" <> 0D) then
            Rec.Validate("Planning Date", Job."Starting Date");
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
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventEmailMgt: Codeunit "NPR Event Email Management";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        EventMgt: Codeunit "NPR Event Management";

    local procedure CreateSalesInvoice(CrMemo: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
        JobCreateInvoice: Codeunit "Job Create-Invoice";
    begin
        Rec.TestField("Line No.");
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

    procedure SetJobNo(No: Code[20])
    begin
        JobNo := No;
    end;

    procedure SetJobTaskNoVisible(JobTaskNoVisible: Boolean)
    begin
        "Job Task No.Visible" := JobTaskNoVisible;
    end;

    local procedure PerformAutoReserve()
    begin
        if (Rec.Reserve = Rec.Reserve::Always) and
           (Rec."Remaining Qty. (Base)" <> 0)
        then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    local procedure UsageLinkOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    local procedure PlanningDateOnAfterValidate()
    begin
        if Rec."Planning Date" <> xRec."Planning Date" then
            PerformAutoReserve();
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        if Rec."No." <> xRec."No." then
            PerformAutoReserve();
    end;

    local procedure VariantCodeOnAfterValidate()
    begin
        if Rec."Variant Code" <> xRec."Variant Code" then
            PerformAutoReserve();
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        if Rec."Location Code" <> xRec."Location Code" then
            PerformAutoReserve();
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        PerformAutoReserve();
    end;

    local procedure ReserveOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    local procedure QuantityOnAfterValidate()
    begin
        PerformAutoReserve();
        if (Rec.Type = Rec.Type::Item) and (Rec.Quantity <> xRec.Quantity) then
            CurrPage.Update(true);
    end;

    local procedure InsertExtendedText(Unconditionally: Boolean)
    var
        EventTransferExtText: Codeunit "NPR Event Transf.Ext.Text Mgt.";
    begin
        if EventTransferExtText.EventCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            Commit();
            EventTransferExtText.InsertEventExtText(Rec);
        end;
        if EventTransferExtText.MakeUpdate() then
            CurrPage.Update(true);
    end;
}

