page 6060121 "NPR TM Ticket BOM"
{
    Extensible = False;
    Caption = 'Ticket BOM';
    PageType = List;
    SourceTable = "NPR TM Ticket Admission BOM";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    PromotedActionCategories = 'New,Process,Report,Create Tickets,Navigate,History';
    CardPageId = "NPR TM Ticket BOM Card";
    Editable = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the item No. used to create this specific ticket configuration. The same Item No. can be added multiple times with different Ticket Admissions or if variants are applied.';
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the variant code that can be added to the Item No. This is optional, and only used if the Item is configured with variants';
                    Visible = false;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the specific Ticket admission that the ticket can be used for. Multiple Ticket admissions can be applied to the same Ticket Item configuration.';
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the default admission when multiple admissions are created for the ticket. This is relevant if POS is configured to admit Default Admission upon sale.';
                }
                field(DeferRevenue; Rec.DeferRevenue)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the revenue should be deferred until this admission is admitted or ticket has expired.';
                }
                field("Ticket Schedule Selection"; Rec."Ticket Schedule Selection")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the default POS schedule selection behavior. It is possible to select something different than was previously specified in Admission Setup. This option is useful if different behavior is requested on the POS sale, as opposed to Web sales.';
                }
                field("Sales From Date"; Rec."Sales From Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies date from which the ticket can be purchased.';
                }
                field("Sales Until Date"; Rec."Sales Until Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the date until which the ticket can be purchased.';
                }
                field("Enforce Schedule Sales Limits"; Rec."Enforce Schedule Sales Limits")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Determines if the values in the Sales From Date/Sales Until Date columns are enforced.';
                }
                field("Admission Entry Validation"; Rec."Admission Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Determines how the ticket can be validated: Single - allows for a single admission of the ticket.; Same Day - the ticket can be validated throughout the same day as the first admission; Multiple -the ticket can be validated a number of times as stated in Max No. Of Entries. Using this can allow the ticket to be validated over the course of several days.';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Determines how the ticket should be admitted: On Scan - the ticket will be admitted upon scanning; On Sale - the ticket will be admitted during its sale, often in the context of the POS sale; Always - similar to On-Sale, except it allows for the ticket to be re-admitted later; Per Unit - reacts based on the setup in Default admission per a POS Unit.';
                }
                field("Percentage of Adm. Capacity"; Rec."Percentage of Adm. Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Determines a percentage of the maximum admission capacity for the provided Item No. This is a useful option when several types of tickets are sold for the same admission. One ticket needs to be at 100% in order to be able to sell full capacity.';
                }
                field("POS Sale May Exceed Capacity"; Rec."POS Sale May Exceed Capacity")
                {
                    ToolTip = 'Specifies whether the capacity may be exceed when ticket is sold in POS.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }

                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Determines the maximum number of entries for an admission that can be made before the ticket becomes invalid. This requires the Admission Entry Validation to be set to Multiple.';
                }
                field("Admission Dependency Code"; Rec."Admission Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Determines if some location / events are exclusive of each other, or if there are locations / events managed by the ticket that needs to be visited in a specific order.';
                }
                field("Revisit Condition (Statistics)"; Rec."Revisit Condition (Statistics)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies how to define a unique visitor when a ticket is used more than once: Never - every ticket scan is considered unique; Non-initial - only the first scan is considered unique; Daily Non-Initial - only the first daily scan is considered unique, and if no setup is applied, it will act as Non-Initial.';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Determines the period during which the ticket is valid. This occurs if the setting on Ticket Type is set to Ticket BOM.';
                }
                field(DurationGroupCode; Rec.DurationGroupCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Duration Group Code';
                    ToolTip = 'Determines whether the admission is limited by duration rather than the scheduled end time.';
                }
                field("Allow Rescan Within (Sec.)"; Rec."Allow Rescan Within (Sec.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the number of seconds after the scan during which the ticket can be rescanned, even though it only permits a single admission. If no value is stated, the ticket cannot be rescanned (assuming single entry is allowed). This option is useful for speed gates, if a person fails to enter, and immediately retries the entry.';
                }
                field("Prefered Sales Display Method"; Rec."Prefered Sales Display Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the preferred sales display method. This setting is only relevant in a Magento web shop.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the quantity of admissions related to this ticket. If set to 5, selling 1 ticket item, will result in 5 admissions.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies useful information about the ticket, that can be included on the printed ticket. This can be different from the Item Description.';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies useful information about the admission that can be included on a printed ticket. This can be different from the Admission Description.';
                }
                field("Reschedule Policy"; Rec."Reschedule Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it''s possible to change the ticket reservation time: Not Allowed - it''s not possible to change the reservation; Always (Until Used) - it''s possible to change the reservation up until the ticket admittance; Cut-Off (Hours) - it''s possible to change the reservation up until the time stated in Reschedule Cut-Off. A reservation can only be changed within the boundaries of the ticket valid from, and valid to dates.';
                }
                field("Reschedule Cut-Off (Hours)"; Rec."Reschedule Cut-Off (Hours)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies after how many hours it is possible to reschedule if Cut-Off (Hours) is selected in the Reschedule Policy column. The value 24 allows rescheduling up until 24 hours remain before the event ends.';
                }
                field("Revoke Policy"; Rec."Revoke Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it is possible to receive a refund for a ticket: Unused Admission - the refund is allowed if there have been no admissions; Never Allow - refund ticket is never allowed; Always Allow - always allows the ticket refund, even if an admission has been registered.';
                }
                field("Notification Profile Code"; Rec."Notification Profile Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the Notification profile associated with this ticket. Events trigger notifications to be sent to the ticketholder based on the specific Notification Profile configuration. This option is useful for CRM purposes.';
                }
                field("Refund Price %"; Rec."Refund Price %")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the percentage of the ticket price that is refunded to customers (if refunds are performed).';
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the code of a base calendar. The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                }
                field("Ticket Customized Calendar"; _CalendarManager.CustomizedChangesExist(Rec))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column that applies to this ticket specifically.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Ticket Base Calendar Code");
                        _CalendarManager.ShowCustomizedCalendar(Rec);
                    end;
                }
                field("Publish As eTicket"; Rec."Publish As eTicket")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies that this ticket should be published to the pass server. This is required for the ticket to be used on Apple Wallet, or Google Passes.';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the ticket design options used for displaying the ticket in Apple Wallet, or Google Passes.';
                }
                field("Publish Ticket URL"; Rec."Publish Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the URL to the digital tickets from the Ticket server should be published on the Ticket. This is required if a Notification is to be sent to the customer, containing a link to the online Ticket.';
                }
                field("Admission Inclusion"; Rec."Admission Inclusion")
                {
                    ToolTip = 'Specifies the value of the Admission Inclusion field.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            Action(NavigateTicketSetup)
            {
                ToolTip = 'Navigate to ticket setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Ticket Setup";
            }
            Action(NavigateIssuedTickets)
            {
                ToolTip = 'Navigate to Issued Tickets';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "Item No." = field("Item No.");
            }
            Action(NavigateDefaultAdmission)
            {
                ToolTip = 'Navigate to Default Admission per POS Unit';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Default Admission per POS Unit';
                Image = Default;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM POS Default Admission";
                RunPageLink = "Item No." = field("Item No."), "Variant Code" = field("Variant Code");
            }
            Action(NavigateAdmissions)
            {
                ToolTip = 'Navigate to Admission Setup';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission';
                Image = WorkCenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Ticket Admissions";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
            Action(NavigateAdmissionsSchedules)
            {
                ToolTip = 'Navigate to Admission Schedules';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
            Action(NavigateAdmissionsSchedulesEntries)
            {
                ToolTip = 'Navigate to Admission Schedule Entries';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Schedule Entries';
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Admis. Schedule Entry";
                RunPageLink = "Admission Code" = field("Admission Code");
            }
            Action(NavigateTicketType)
            {
                ToolTip = 'Navigate to Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Types';
                Image = Category;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Ticket Type";
            }
            Action(NavigateItems)
            {
                ToolTip = 'Navigate to Item Card.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Item';
                Image = ItemLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field("Item No.");
            }
        }
        area(Creation)
        {
            Action("Create Prepaid Tickets")
            {
                ToolTip = 'Create a set of tickets for which payment has already been handled. (F.ex. free tickets.) ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Prepaid Tickets';
                Image = PrepaymentInvoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    MakeTickets(TicketPaymentType::PREPAID, Rec."Item No.", Rec."Variant Code");
                end;
            }
            Action("Create Postpaid Tickets")
            {
                ToolTip = 'Create a set of tickets that can be invoiced after ticket has been used.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Postpaid Tickets';
                Image = Invoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    MakeTickets(TicketPaymentType::POSTPAID, Rec."Item No.", Rec."Variant Code");
                end;
            }
            Action("Create Tour Ticket")
            {
                ToolTip = 'Create a tour ticket.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Tour Ticket';
                Image = CustomerGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    MakeTourTicket(Rec."Item No.", Rec."Variant Code");
                end;
            }
        }
        area(Processing)
        {
            Action("Handle Postpaid Tickets")
            {
                ToolTip = 'Create invoices for tickets with post-payment as payment method.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Handle Postpaid Tickets';
                Image = Invoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin

                    TicketManagement.HandlePostpaidTickets(false);
                end;
            }
        }
    }

    var
        TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';
        EXPORT_TO_EXCEL: Label 'Do you want to export generated tickets to excel?';
        OFFLINE_VALIDATION: Label 'Do you want to create offline ticket validation entries to be able to create admissions.';
        _CalendarManager: Codeunit "Calendar Management";

    procedure MakeTourTicket(ItemNo: Code[20]; VariantCode: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Item: Record "Item";
        TicketType: Record "NPR TM Ticket Type";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token: Text[100];
        ResponseMessage: Text;
    begin
        Item.Get(ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType.TestField("Admission Registration", TicketType."Admission Registration"::GROUP);

        Token := TicketRequestManager.GetNewToken();

        if (not FinalizeReservation(CreateTicketRequest(TicketReservationRequest."Payment Option"::UNPAID, Token, ItemNo, VariantCode), ItemNo, VariantCode)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, true);
            exit;
        end;

        if (not TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, true);
            Error(ResponseMessage);
        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindFirst();

        // "Initial Entry" flow field (on Admission Schedule Entry page) lists only closed entries (ie paid entries)
        // A tour ticket is unpaid but should be listed anyway.
        DetTicketAccessEntry.SetCurrentKey("Ticket No.");
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (DetTicketAccessEntry.FindSet(true)) then begin
            repeat
                DetTicketAccessEntry.Open := false;
                DetTicketAccessEntry.Modify();
            until (DetTicketAccessEntry.Next() = 0);
        end;

        Commit();
        Page.Run(Page::"NPR TM Ticket List", Ticket);

    end;


    procedure MakeTickets(PaymentType: Option; ItemNo: Code[20]; VariantCode: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        OfflineTicketValidationMgr: Codeunit "NPR TM OfflineTicketValidBL";
        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        Token: Text[100];
        ResponseMessage: Text;
        ImportReferenceNo: Integer;
    begin

        Token := TicketRequestManager.GetNewToken();

        if (not FinalizeReservation(CreateTicketRequest(PaymentType, Token, ItemNo, VariantCode), ItemNo, VariantCode)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, true);
            exit;
        end;

        if (not TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, true);
            Error(ResponseMessage);
        end;

        if (ExportToTicketServer(PaymentType)) then begin
            if (DIYTicketPrint.ValidateSetup()) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Admission Created", '=%1', true);
                if (TicketReservationRequest.FindFirst()) then
                    if (not DIYTicketPrint.GenerateTicketPrint(TicketReservationRequest."Entry No.", false, ResponseMessage)) then
                        Error(ResponseMessage);
            end;
        end;

        if (ShowExcelExportPrompt(PaymentType)) then begin
            if (Confirm(EXPORT_TO_EXCEL, true)) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
                TicketReservationRequest.FindFirst();
                TicketRequestManager.ExportTicketRequestListToClientExcel(TicketReservationRequest);
            end;
        end;

        if (ShowOfflineValidationPrompt(PaymentType)) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.FindFirst();
            if (Confirm(OFFLINE_VALIDATION)) then begin
                ImportReferenceNo := OfflineTicketValidationMgr.AddRequestToOfflineValidation(TicketReservationRequest);
                OfflineTicketValidation.SetFilter("Import Reference No.", '=%1', ImportReferenceNo);
                Commit();
                Page.RunModal(Page::"NPR TM Offline Ticket Valid.", OfflineTicketValidation);
            end;
        end;

        if (ShowTicketResultList(PaymentType)) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
            TicketReservationRequest.FindFirst();
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Commit();
            Page.Run(Page::"NPR TM Ticket List", Ticket);
        end;

    end;

    local procedure CreateTicketRequest(PaymentType: Option; Token: Text[100]; ItemNo: Code[20]; VariantCode: Code[10]): Text[100]
    var
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', VariantCode);
        TicketAdmissionBOM.SetFilter("Admission Inclusion", '=%1', TicketAdmissionBOM."Admission Inclusion"::REQUIRED);
        MakeTicketReservation(PaymentType, Token, ItemNo, VariantCode, TicketAdmissionBOM);

        TicketAdmissionBOM.SetFilter("Admission Inclusion", '<>%1', TicketAdmissionBOM."Admission Inclusion"::REQUIRED);
        MakeTicketReservation(PaymentType, Token, ItemNo, VariantCode, TicketAdmissionBOM);

        Commit();
        exit(Token);
    end;

    local procedure MakeTicketReservation(PaymentType: Option; Token: Text[100]; ItemNo: Code[20]; VariantCode: Code[10]; var TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
    begin
        if (not TicketAdmissionBOM.FindSet()) then
            exit;

        repeat
            Admission.Get(TicketAdmissionBOM."Admission Code");
            TicketReservationRequest."Entry No." := 0;
            TicketReservationRequest."Session Token ID" := Token;

            TicketReservationRequest.Quantity := 0;
            if (TicketAdmissionBOM."Admission Inclusion" in [TicketAdmissionBOM."Admission Inclusion"::REQUIRED, TicketAdmissionBOM."Admission Inclusion"::SELECTED]) then
                TicketReservationRequest.Quantity := GetDefaultQuantity(PaymentType);

            TicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo(ItemNo, VariantCode);
            TicketReservationRequest."Item No." := ItemNo;
            TicketReservationRequest."Variant Code" := VariantCode;
            TicketReservationRequest."Admission Code" := TicketAdmissionBOM."Admission Code";
            TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
            if (TicketReservationRequest."Admission Description" = '') then
                TicketReservationRequest."Admission Description" := Admission.Description;
            TicketReservationRequest."Admission Inclusion" := TicketAdmissionBOM."Admission Inclusion";
            TicketReservationRequest."Payment Option" := PaymentType;
            TicketReservationRequest."Created Date Time" := CurrentDateTime;
            TicketReservationRequest.Insert();
        until (TicketAdmissionBOM.Next() = 0);
    end;

    local procedure FinalizeReservation(Token: Text[100]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        DisplayTicketReservationRequest: Page "NPR TM Ticket Make Reserv.";
        ResponseMessage: Text;
        PageAction: Action;
    begin

        repeat
            Clear(DisplayTicketReservationRequest);
            DisplayTicketReservationRequest.LoadTicketRequest(Token);
            DisplayTicketReservationRequest.SetTicketItem(ItemNo, VariantCode);
            DisplayTicketReservationRequest.SetIgnoreScheduleSelectionFilter(true);
            DisplayTicketReservationRequest.SetAllowCustomizableTicketQtyChange(true);

            DisplayTicketReservationRequest.AllowQuantityChange(true);
            DisplayTicketReservationRequest.LookupMode(true);
            DisplayTicketReservationRequest.Editable(true);

            if (ResponseMessage <> '') then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketReservationRequest.RunModal();
            if (PageAction <> Action::LookupOK) then
                exit(false);

        until (DisplayTicketReservationRequest.FinalizeReservationRequest(false, ResponseMessage) = 0);

        exit(true);
    end;

    local procedure ShowExcelExportPrompt(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not TicketSetup.Get()) then;

        if (PaymentType = TicketPaymentType::PREPAID) then
            case TicketSetup."Prepaid Excel Export Prompt" of
                TicketSetup."Prepaid Excel Export Prompt"::SHOW:
                    ShowPrompt := true;
                TicketSetup."Prepaid Excel Export Prompt"::HIDE:
                    ShowPrompt := false;
                else
                    ShowPrompt := true;
            end;

        if (PaymentType = TicketPaymentType::POSTPAID) then
            case TicketSetup."Postpaid Excel Export Prompt" of
                TicketSetup."Postpaid Excel Export Prompt"::SHOW:
                    ShowPrompt := true;
                TicketSetup."Postpaid Excel Export Prompt"::HIDE:
                    ShowPrompt := false;
                else
                    ShowPrompt := true;
            end;

    end;

    local procedure ShowOfflineValidationPrompt(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then;

        if (PaymentType = TicketPaymentType::PREPAID) then
            case TicketSetup."Prepaid Offline Valid. Prompt" of
                TicketSetup."Prepaid Offline Valid. Prompt"::SHOW:
                    ShowPrompt := true;
                TicketSetup."Prepaid Offline Valid. Prompt"::HIDE:
                    ShowPrompt := false;
                else
                    ShowPrompt := true;
            end;

        if (PaymentType = TicketPaymentType::POSTPAID) then
            ShowPrompt := false;

    end;

    local procedure ShowTicketResultList(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then;

        if (PaymentType = TicketPaymentType::PREPAID) then
            case TicketSetup."Prepaid Ticket Result List" of
                TicketSetup."Prepaid Ticket Result List"::SHOW:
                    ShowPrompt := true;
                TicketSetup."Prepaid Ticket Result List"::HIDE:
                    ShowPrompt := false;
                else
                    ShowPrompt := true;
            end;

        if (PaymentType = TicketPaymentType::POSTPAID) then
            case TicketSetup."Postpaid Ticket Result List" of
                TicketSetup."Postpaid Ticket Result List"::SHOW:
                    ShowPrompt := true;
                TicketSetup."Postpaid Ticket Result List"::HIDE:
                    ShowPrompt := false;
                else
                    ShowPrompt := true;
            end;

    end;

    local procedure ExportToTicketServer(PaymentType: Option) DoExport: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then;

        if (PaymentType = TicketPaymentType::PREPAID) then
            case TicketSetup."Prepaid Ticket Server Export" of
                TicketSetup."Prepaid Ticket Server Export"::YES:
                    DoExport := true;
                TicketSetup."Prepaid Ticket Server Export"::NO:
                    DoExport := false;
                else
                    DoExport := true;
            end;

        if (PaymentType = TicketPaymentType::POSTPAID) then
            case TicketSetup."Postpaid Ticket Server Export" of
                TicketSetup."Postpaid Ticket Server Export"::YES:
                    DoExport := true;
                TicketSetup."Postpaid Ticket Server Export"::NO:
                    DoExport := false;
                else
                    DoExport := true;
            end;

    end;

    local procedure GetDefaultQuantity(PaymentType: Option): Integer
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then
            exit(1);

        case PaymentType of
            TicketPaymentType::PREPAID:
                exit(TicketSetup."Prepaid Default Quantity");
            TicketPaymentType::POSTPAID:
                exit(TicketSetup."Postpaid Default Quantity");
        end;

        exit(1);
    end;


}

