page 6060121 "NPR TM Ticket BOM"
{

    Caption = 'Ticket BOM';
    PageType = List;
    SourceTable = "NPR TM Ticket Admission BOM";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'pages/viewpage.action?pageId=284917767#TicketManagement-_Toc516786672TicketAdmissionBOM';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Default; Default)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default field';
                }
                field("Sales From Date"; "Sales From Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date field';
                }
                field("Sales Until Date"; "Sales Until Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date field';
                }
                field("Enforce Schedule Sales Limits"; "Enforce Schedule Sales Limits")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Enforce Schedule Sales Limits field';
                }
                field("Admission Entry Validation"; "Admission Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Entry Validation field';
                }
                field("Activation Method"; "Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Activation Method field';
                }
                field("Percentage of Adm. Capacity"; "Percentage of Adm. Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Percentage of Adm. Capacity field';
                }
                field("Max No. Of Entries"; "Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max No. Of Entries field';
                }
                field("Admission Dependency Code"; "Admission Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Dependency Code field';
                }
                field("Revisit Condition (Statistics)"; "Revisit Condition (Statistics)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Revisit Condition (Statistics) field';
                }
                field("Duration Formula"; "Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Duration Formula field';
                }
                field("Allow Rescan Within (Sec.)"; "Allow Rescan Within (Sec.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Allow Rescan Within (Sec.) field';
                }
                field("Prefered Sales Display Method"; "Prefered Sales Display Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prefered Sales Display Method field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Reschedule Policy"; "Reschedule Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reschedule Policy field';
                }
                field("Reschedule Cut-Off (Hours)"; "Reschedule Cut-Off (Hours)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reschedule Cut-Off (Hours) field';
                }
                field("Revoke Policy"; "Revoke Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Revoke Policy field';
                }
                field("Refund Price %"; "Refund Price %")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Refund Price % field';
                }
                field("Ticket Base Calendar Code"; "Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Base Calendar Code field';
                }
                field("Ticket Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customized Calendar field';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Ticket Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTemp);
                    end;
                }
                field("Publish As eTicket"; "Publish As eTicket")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Publish As eTicket field';
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("Publish Ticket URL"; "Publish Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Publish Ticket URL field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Admissions)
            {
                ToolTip = 'Navigate to Admissions Setup';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admissions';
                Image = WorkCenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Admissions";

            }
            action("Ticket Setup")
            {
                ToolTip = 'Navigate to ticket setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Setup";

            }
        }
        area(processing)
        {
            action("Create Prepaid Tickets")
            {
                ToolTip = 'Create a set of tickets for which payment has already been handled. (F.ex. free tickets.) ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Prepaid Tickets';
                Image = PrepaymentInvoice;


                trigger OnAction()
                begin
                    MakeTickets(TicketPaymentType::PREPAID);
                end;
            }
            action("Create Postpaid Tickets")
            {
                ToolTip = 'Create a set of tickets that can be invoiced after ticket has been used.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Postpaid Tickets';
                Image = Invoice;


                trigger OnAction()
                begin
                    MakeTickets(TicketPaymentType::POSTPAID);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(CustomizedCalendarChangeTemp);
        CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Service;
        CustomizedCalendarChangeTemp."Source Code" := "Admission Code";
        CustomizedCalendarChangeTemp."Base Calendar Code" := "Ticket Base Calendar Code";
        if (not CustomizedCalendarChangeTemp.Insert()) then;
    end;

    var
        TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';
        EXPORT_TO_EXCEL: Label 'Do you want to export generated tickets to excel?';
        OFFLINE_VALIDATION: Label 'Do you want to create offline ticket validation entries to be able to create admissions.';
        CustomizedCalEntry: Record "Customized Calendar Entry";
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";

    local procedure MakeTickets(PaymentType: Option)
    var
        Ticket: Record "NPR TM Ticket";
        TicketSetup: Record "NPR TM Ticket Setup";
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        OfflineTicketValidationMgr: Codeunit "NPR TM Offline Ticket Valid.";
        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        Token: Text;
        ResponseMessage: Text;
        ImportReferenceNo: Integer;
        ShowPrompt: Boolean;
    begin

        //-#308962 [308962] Refactored

        Token := TicketRequestManager.GetNewToken();

        if (not FinalizeReservation(CreateTicketRequest(PaymentType, Token, "Item No.", "Variant Code"), "Item No.", "Variant Code")) then begin
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
                Commit;
                PAGE.RunModal(PAGE::"NPR TM Offline Ticket Valid.", OfflineTicketValidation);
            end;
        end;

        if (ShowTicketResultList(PaymentType)) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.FindFirst();
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Commit;
            PAGE.Run(PAGE::"NPR TM Ticket List", Ticket);
        end;

        //+#308962 [308962] end refactor
    end;

    local procedure CreateTicketRequest(PaymentType: Option; Token: Text; ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
    begin

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', VariantCode);
        TicketAdmissionBOM.FindSet();
        repeat
            Admission.Get(TicketAdmissionBOM."Admission Code");
            TicketReservationRequest."Entry No." := 0;
            TicketReservationRequest."Session Token ID" := Token;

            //-#308962 [308962]
            // TicketReservationRequest.Quantity := 1;
            TicketReservationRequest.Quantity := GetDefaultQuantity(PaymentType);
            //+#308962 [308962]

            TicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo(ItemNo, VariantCode);
            //-TM1.43 [368043]
            TicketReservationRequest."Item No." := ItemNo;
            TicketReservationRequest."Variant Code" := VariantCode;
            //+TM1.43 [368043]

            TicketReservationRequest."Admission Code" := TicketAdmissionBOM."Admission Code";
            TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
            if (TicketReservationRequest."Admission Description" = '') then
                TicketReservationRequest."Admission Description" := Admission.Description;
            TicketReservationRequest."Payment Option" := PaymentType;
            TicketReservationRequest."Created Date Time" := CurrentDateTime;
            TicketReservationRequest.Insert();
        until (TicketAdmissionBOM.Next() = 0);
        Commit;

        exit(Token);
    end;

    local procedure FinalizeReservation(Token: Text; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        DisplayTicketeservationRequest: Page "NPR TM Ticket Make Reserv.";
        ResponseMessage: Text;
        PageAction: Action;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        repeat
            Clear(DisplayTicketeservationRequest);
            DisplayTicketeservationRequest.LoadTicketRequest(Token);
            DisplayTicketeservationRequest.SetTicketItem(ItemNo, VariantCode);
            //-TM90.1.46 [386850]
            DisplayTicketeservationRequest.SetIgnoreScheduleSelectionFilter(true);
            //+TM90.1.46 [386850]

            DisplayTicketeservationRequest.AllowQuantityChange(true);
            DisplayTicketeservationRequest.LookupMode(true);
            DisplayTicketeservationRequest.Editable(true);

            if (ResponseMessage <> '') then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketeservationRequest.RunModal();
            if (PageAction <> ACTION::LookupOK) then
                exit(false);

        until (DisplayTicketeservationRequest.FinalizeReservationRequest(false, ResponseMessage) = 0);

        exit(true);
    end;

    local procedure ShowExcelExportPrompt(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        //-#308962 [308962]
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

        //+#308962 [308962]
    end;

    local procedure ShowOfflineValidationPrompt(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        //-#308962 [308962]
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

        //+#308962 [308962]
    end;

    local procedure ShowTicketResultList(PaymentType: Option) ShowPrompt: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        //-#308962 [308962]
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

        //+#308962 [308962]
    end;

    local procedure ExportToTicketServer(PaymentType: Option) DoExport: Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        //-#308962 [308962]
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

        //+#308962 [308962]
    end;

    local procedure GetDefaultQuantity(PaymentType: Option): Integer
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        //-#308962 [308962]
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

