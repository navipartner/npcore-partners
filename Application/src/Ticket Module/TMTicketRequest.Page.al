page 6060103 "NPR TM Ticket Request"
{
    Extensible = False;
    Caption = 'Ticket Request';
    CardPageID = "NPR TM Ticket Res. Req. Page";
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Superseeds Entry No."; Rec."Superseeds Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Superseeds Entry No. field';
                }
                field("Session Token ID"; Rec."Session Token ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Session Token ID field';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Authorization Code field';
                }
                field("Request Status"; Rec."Request Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Request Status field';
                }
                field("Admission Created"; Rec."Admission Created")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Created field';
                }
                field(Control6014407; Rec."Revoke Ticket Request")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ShowCaption = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revoke Ticket Request field';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Created Date Time field';
                }
                field("External Item Code"; Rec."External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Item Code field';
                }
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
                field("Payment Option"; Rec."Payment Option")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Payment Option field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Ext. Line Reference No."; Rec."Ext. Line Reference No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Reference No. field';
                }
                field("External Ticket Number"; Rec."External Ticket Number")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Ticket Number field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Receipt No. field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("External Adm. Sch. Entry No."; Rec."External Adm. Sch. Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Adm. Sch. Entry No. field';
                }
                field("Scheduled Time Description"; Rec."Scheduled Time Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Time Description field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Expires Date Time"; Rec."Expires Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Expires Date Time field';
                }
                field("Request Status Date Time"; Rec."Request Status Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Request Status Date Time field';
                }
                field("Revoke Access Entry No."; Rec."Revoke Access Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Revoke Access Entry No. field';
                }
                field("External Order No."; Rec."External Order No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Order No. field';
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
            group(NavigationGroup)
            {
                Caption = 'Navigation';

                action("Issued Tickets")
                {
                    ToolTip = 'Navigate to Ticket List';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Issued Tickets';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    RunObject = Page "NPR TM Ticket List";
                    RunPageLink = "Ticket Reservation Entry No." = FIELD("Entry No.");

                }
                action(Navigate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Find Sales Transaction';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;
                    ToolTip = 'Finds the web invoice or POS Sale.';

                    trigger OnAction()
                    var
                        TicketList: Page "NPR TM Ticket List";
                        Ticket: Record "NPR TM Ticket";
                        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
                    begin
                        TicketReservationReq.SetFilter("Session Token ID", '=%1', Rec."Session Token ID");
                        TicketReservationReq.FindFirst();
                        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationReq."Entry No.");
                        if (Ticket.FindFirst()) then
                            TicketList.ShowTicketSalesTransaction(Ticket);
                    end;
                }
                action("View Online Ticket")
                {
                    ToolTip = 'Display the ticket as created on ticket server.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'View Online Ticket';
                    Image = Web;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
                    begin

                        DIYTicketPrint.ViewOnlineTicketOrder(Rec."Entry No.");
                    end;
                }
            }
            group(ProcessGroup)
            {
                Caption = 'Process';
                action("Handle Postpaid Tickets")
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
                action("Create Offline Admissions")
                {
                    ToolTip = 'Transfer tickets to offline journal to manually register admission entries.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Create Offline Admissions';
                    Image = PostApplication;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

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
                        Commit();
                        PAGE.RunModal(PAGE::"NPR TM Offline Ticket Valid.", OfflineTicketValidation);
                    end;
                }
                action("Revoke Ticket Request")
                {
                    ToolTip = 'Prevents the tickets from being used (irreversible).';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Revoke Ticket Request';
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Scope = Repeater;
                    trigger OnAction()
                    begin
                        RevokeTicketRequest();
                    end;
                }
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;

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
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RequestCount: Integer;
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToRevoke: Integer;
        Token: Text[100];
    begin

        CurrPage.SetSelectionFilter(TicketReservationRequest);
        RequestCount := TicketReservationRequest.Count();
        if (RequestCount < 1) then
            exit;

        if (RequestCount > 1) then
            if (not Confirm(CONFIRM_REVOKE_REQUEST, false, RequestCount)) then
                Error('');

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
                    TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", CopyStr(UserId(), 1, 20), 0, AmountToReverse, QtyToRevoke);
                until (Ticket.Next() = 0);
                TicketRequestManager.RevokeReservationTokenRequest(Token, false);
            end;

            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CANCELED;
            TicketReservationRequest.Modify();

        until (TicketReservationRequest.Next() = 0);

    end;
}

