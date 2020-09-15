page 6060103 "NPR TM Ticket Request"
{
    // TM1.18/TSA/20161220  CASE 261564 Show ticket request
    // TM1.21/NPKNAV/20170525  CASE 278049 Transport T0006 - 25 May 2017
    // TM1.22/TSA/20170526   CASE 278142 Added fields Payment Option, Customer No
    // TM1.23/TSA/20170706  CASE 283007 Reinstated External Order No. field that disappeared.
    // TM1.26/TSA /20171120 CASE 296731 Added function RevokeTicketRequest() and the button to go with it
    // TM1.38/TSA /20181023 CASE 332109 Added eTicket button
    // NPR5.48/TSA /20181109 CASE 332109 removed eTicket button
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Actions
    // TM1.39/NPKNAV/20190125  CASE 310057 Transport TM1.39 - 25 January 2019
    // TM1.43/TSA /20190910 CASE 368043 Refactored usage of "External Item Code"

    Caption = 'Ticket Request';
    CardPageID = "NPR TM Ticket Res. Req. Page";
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Session Token ID"; "Session Token ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Request Status"; "Request Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Created"; "Admission Created")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Control6014407; "Revoke Ticket Request")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ShowCaption = false;
                    Visible = false;
                }
                field("Created Date Time"; "Created Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Item Code"; "External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Payment Option"; "Payment Option")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ext. Line Reference No."; "Ext. Line Reference No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("External Ticket Number"; "External Ticket Number")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Receipt No."; "Receipt No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Adm. Sch. Entry No."; "External Adm. Sch. Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Scheduled Time Description"; "Scheduled Time Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Expires Date Time"; "Expires Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Request Status Date Time"; "Request Status Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Revoke Access Entry No."; "Revoke Access Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("External Order No."; "External Order No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(Attributes; "NPR TM Ticket Req. Factbox")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Attributes';
                SubPageLink = "Entry No." = FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Issued Tickets")
            {
                ToolTip = 'Navigate to Ticket List';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "Ticket Reservation Entry No." = FIELD("Entry No.");

            }
            action("View Online Ticket")
            {
                ToolTip = 'Display the ticket as created on ticket server.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'View Online Ticket';
                Image = Web;
                Promoted = true;
                PromotedCategory = Process;


                trigger OnAction()
                var
                    DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
                begin

                    DIYTicketPrint.ViewOnlineTicketOrder("Entry No.");
                end;
            }
        }
        area(processing)
        {
            action("Handle Postpaid Tickets")
            {
                ToolTip = 'Create invoices for tickets with post-payment as payment method.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Handle Postpaid Tickets';
                Image = Invoice;


                trigger OnAction()
                var
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin

                    TicketManagement.HandlePostpaidTickets(false);
                end;
            }
            action("Create Offline Admissions")
            {
                ToolTip = 'Transfer tickets to offline journal to manually register admission entries.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Offline Admissions';
                Ellipsis = true;
                Image = PostApplication;
                Promoted = true;
                PromotedIsBig = true;


                trigger OnAction()
                var
                    TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    OfflineTicketValidationMgr: Codeunit "NPR TM Offline Ticket Valid.";
                    OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
                    ImportReferenceNo: Integer;
                begin

                    CurrPage.SetSelectionFilter(TicketReservationRequest);
                    ImportReferenceNo := OfflineTicketValidationMgr.AddRequestToOfflineValidation(TicketReservationRequest);

                    OfflineTicketValidation.SetFilter("Import Reference No.", '=%1', ImportReferenceNo);
                    Commit;
                    PAGE.RunModal(PAGE::"NPR TM Offline Ticket Valid.", OfflineTicketValidation);
                end;
            }
            action("Revoke Ticket Request")
            {
                ToolTip = 'Prevents the tickets from being used (irreversible).';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Revoke Ticket Request';
                Ellipsis = true;
                Image = RemoveLine;


                trigger OnAction()
                begin
                    RevokeTicketRequest();
                end;
            }
        }
        area(reporting)
        {
            action("Export Ticket Batch List")
            {
                ToolTip = 'Export tickets to Excel.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Export Ticket Batch List';
                Image = ExportToExcel;


                trigger OnAction()
                var
                    TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                begin

                    CurrPage.SetSelectionFilter(TicketReservationRequest);
                    TicketRequestManager.ExportTicketRequestListToClientExcel(TicketReservationRequest);
                end;
            }
        }
    }

    var
        CONFIRM_REVOKE_REQUEST: Label 'Are you sure you want to revoke %1 ticket request(s)?';
        CONFIRM_REVOKE_TICKET: Label 'Are you sure you want to revoke %1 ticket(s)?';

    local procedure RevokeTicketRequest()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        RevokeRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RequestCount: Integer;
        TicketCount: Integer;
        RequestDateTime: DateTime;
        ResponseMessage: Text;
        AmountToReverse: Decimal;
        QtyToRevoke: Integer;
        Token: Text[100];
    begin

        //-TM1.26 [296731]
        CurrPage.SetSelectionFilter(TicketReservationRequest);
        RequestCount := TicketReservationRequest.Count();
        if (RequestCount < 1) then
            exit;

        if (RequestCount > 1) then
            if (not Confirm(CONFIRM_REVOKE_REQUEST, false, RequestCount)) then
                Error('');

        RequestDateTime := CurrentDateTime();
        TicketReservationRequest.FindSet(true, true);
        repeat
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");

            if (RequestCount = 1) then begin
                TicketCount := Ticket.Count();
                if (not Confirm(CONFIRM_REVOKE_TICKET, false, TicketCount)) then
                    Error('');
            end;

            if (Ticket.FindSet()) then begin
                Token := TicketRequestManager.GetNewToken();
                repeat
                    AmountToReverse := 0;
                    QtyToRevoke := 0;
                    TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", UserId, 0, AmountToReverse, QtyToRevoke);
                until (Ticket.Next() = 0);
                TicketRequestManager.RevokeReservationTokenRequest(Token, false, true, ResponseMessage);
            end;

            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CANCELED;
            TicketReservationRequest.Modify();

        until (TicketReservationRequest.Next() = 0);
        //+TM1.26 [296731]
    end;
}

