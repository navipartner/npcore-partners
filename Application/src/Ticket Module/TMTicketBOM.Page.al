page 6060121 "NPR TM Ticket BOM"
{
    Caption = 'Ticket BOM';
    PageType = List;
    SourceTable = "NPR TM Ticket Admission BOM";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'pages/viewpage.action?pageId=284917767#TicketManagement-_Toc516786672TicketAdmissionBOM';
    PromotedActionCategories = 'New,Process,Report,Create Tickets,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default field';
                }
                field("Ticket Schedule Selection"; Rec."Ticket Schedule Selection")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Schedule Selection field';
                }
                field("Sales From Date"; Rec."Sales From Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date field';
                }
                field("Sales Until Date"; Rec."Sales Until Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date field';
                }
                field("Enforce Schedule Sales Limits"; Rec."Enforce Schedule Sales Limits")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Enforce Schedule Sales Limits field';
                }
                field("Admission Entry Validation"; Rec."Admission Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Entry Validation field';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activation Method field';
                }
                field("Percentage of Adm. Capacity"; Rec."Percentage of Adm. Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Percentage of Adm. Capacity field';
                }
                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max No. Of Entries field';
                }
                field("Admission Dependency Code"; Rec."Admission Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Dependency Code field';
                }
                field("Revisit Condition (Statistics)"; Rec."Revisit Condition (Statistics)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Revisit Condition (Statistics) field';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Duration Formula field';
                }
                field("Allow Rescan Within (Sec.)"; Rec."Allow Rescan Within (Sec.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Allow Rescan Within (Sec.) field';
                }
                field("Prefered Sales Display Method"; Rec."Prefered Sales Display Method")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Prefered Sales Display Method field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Reschedule Policy"; Rec."Reschedule Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reschedule Policy field';
                }
                field("Reschedule Cut-Off (Hours)"; Rec."Reschedule Cut-Off (Hours)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reschedule Cut-Off (Hours) field';
                }
                field("Revoke Policy"; Rec."Revoke Policy")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Revoke Policy field';
                }
                field("Refund Price %"; Rec."Refund Price %")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Refund Price % field';
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
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
                        CurrPage.SaveRecord();
                        Rec.TestField("Ticket Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTemp);
                    end;
                }
                field("Publish As eTicket"; Rec."Publish As eTicket")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Publish As eTicket field';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("Publish Ticket URL"; Rec."Publish Ticket URL")
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
                RunObject = Page "NPR TM Ticket Type";
            }
            Action(NavigateItems)
            {
                ToolTip = 'Navigate to Item Card.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Item';
                Image = ItemLines;
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
                    MakeTickets(TicketPaymentType::PREPAID);
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
                    MakeTickets(TicketPaymentType::POSTPAID);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(CustomizedCalendarChangeTemp);
        CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Service;
        CustomizedCalendarChangeTemp."Source Code" := Rec."Admission Code";
        CustomizedCalendarChangeTemp."Base Calendar Code" := Rec."Ticket Base Calendar Code";
        if (not CustomizedCalendarChangeTemp.Insert()) then;
    end;

    var
        TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';
        EXPORT_TO_EXCEL: Label 'Do you want to export generated tickets to excel?';
        OFFLINE_VALIDATION: Label 'Do you want to create offline ticket validation entries to be able to create admissions.';
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";

    local procedure MakeTickets(PaymentType: Option)
    var
        Ticket: Record "NPR TM Ticket";
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        OfflineTicketValidationMgr: Codeunit "NPR TM Offline Ticket Valid.";
        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        Token: Text;
        ResponseMessage: Text;
        ImportReferenceNo: Integer;
    begin

        Token := TicketRequestManager.GetNewToken();

        if (not FinalizeReservation(CreateTicketRequest(PaymentType, Token, Rec."Item No.", Rec."Variant Code"), Rec."Item No.", Rec."Variant Code")) then begin
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
                Commit();
                Page.RunModal(Page::"NPR TM Offline Ticket Valid.", OfflineTicketValidation);
            end;
        end;

        if (ShowTicketResultList(PaymentType)) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.FindFirst();
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Commit();
            Page.Run(Page::"NPR TM Ticket List", Ticket);
        end;
    end;

    local procedure CreateTicketRequest(PaymentType: Option; Token: Text; ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
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

            TicketReservationRequest.Quantity := GetDefaultQuantity(PaymentType);

            TicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo(ItemNo, VariantCode);
            TicketReservationRequest."Item No." := ItemNo;
            TicketReservationRequest."Variant Code" := VariantCode;
            TicketReservationRequest."Admission Code" := TicketAdmissionBOM."Admission Code";
            TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
            if (TicketReservationRequest."Admission Description" = '') then
                TicketReservationRequest."Admission Description" := Admission.Description;
            TicketReservationRequest."Payment Option" := PaymentType;
            TicketReservationRequest."Created Date Time" := CurrentDateTime;
            TicketReservationRequest.Insert();
        until (TicketAdmissionBOM.Next() = 0);
        Commit();

        exit(Token);
    end;

    local procedure FinalizeReservation(Token: Text; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
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

