page 6060121 "NPR TM Ticket BOM"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA/20160125  CASE 232495 Added field Default for auto selection for admission code
    // TM1.11/TSA/20160404  CASE 232250 Added new field Prefered Sales Display Method
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160816  CASE 245455 Transport TM1.16 - 19 July 2016
    // TM1.18/TSA/20170103  CASE 262095 Added field Revoke Policy
    // TM1.20/TSA/20170323  CASE 269171 Added field Refund Price %
    // TM1.22/TSA/20170526   CASE 278142 Added Create Prepaid/Postpaid Tickets buttons
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20180115 CASE 301459 Improving error handling
    // TM1.28/TSA /20180221 CASE 305707 Added support for ticket base calendar
    // TM1.29/TSA /20180314 CASE 308129 Support pre/post tickets with variant codes
    // TM1.36/TSA /20180801 CASE 316463 Added "Allow Rescan Within (Sec.)" field
    // TM1.38/TSA /20181012 CASE 332109 Added eTicket
    // TM1.38/TSA /20181026 CASE 308962 Adding setup to manage prepaid / postpaid tickets
    // TM1.42/TSA /20190411 CASE 351050 Added "Revisit Condition (Statistics)"
    // TM1.43/TSA /20190910 CASE 368043 Refactored usage of External Item Code
    // TM1.45/TSA /20191120 CASE 378212 Added "Sales Start Date", "Sales Until Date",
    // TM1.45/TSA /20191127 CASE 379766 Delegates ticket activation method to Ticket BOM, added activation method to page
    // TM1.46/TSA /20200123 CASE 386850 Set ignore schedule filter
    // TM1.46/TSA /20200127 CASE 387138 Added "Publish Ticket URL"
    // TM1.48/TSA/20200730  CASE 411704 Transport TM1.48 - 30 July 2020

    Caption = 'Ticket BOM';
    PageType = List;
    SourceTable = "NPR TM Ticket Admission BOM";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Default; Default)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales From Date"; "Sales From Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Sales Until Date"; "Sales Until Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Enforce Schedule Sales Limits"; "Enforce Schedule Sales Limits")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Admission Entry Validation"; "Admission Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Activation Method"; "Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Percentage of Adm. Capacity"; "Percentage of Adm. Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Max No. Of Entries"; "Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Revisit Condition (Statistics)"; "Revisit Condition (Statistics)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Duration Formula"; "Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Allow Rescan Within (Sec.)"; "Allow Rescan Within (Sec.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Prefered Sales Display Method"; "Prefered Sales Display Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Revoke Policy"; "Revoke Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Refund Price %"; "Refund Price %")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Base Calendar Code"; "Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Ticket Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;

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
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Publish Ticket URL"; "Publish Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
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

