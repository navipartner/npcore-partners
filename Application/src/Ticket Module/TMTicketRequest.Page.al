page 6060103 "NPR TM Ticket Request"
{
    Extensible = False;
    Caption = 'Ticket Request';
    CardPageID = "NPR TM Ticket Res. Req. Page";
    Editable = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    InsertAllowed = false;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
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
                    Visible = false;
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
                field(TicketHolderName; Rec.TicketHolderName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder Name field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field(TicketHolderPreferredLanguage; Rec.TicketHolderPreferredLanguage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder Preferred Language field';
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
                field("Admission Inclusion"; Rec."Admission Inclusion")
                {
                    ToolTip = 'Specifies the value of the Admission Inclusion field.';
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

                    trigger OnAction()
                    var
                        Ticket: Record "NPR TM Ticket";
                        TempTickets: Record "NPR TM Ticket" temporary;
                        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    begin
                        TicketReservationRequest.Reset();
                        TicketReservationRequest.SetCurrentKey("Session Token ID");
                        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Rec."Session Token ID");
                        if (TicketReservationRequest.FindSet()) then
                            repeat
                                Ticket.Reset();
                                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::REVOKE) then begin
                                    Ticket.SetCurrentKey("External Ticket No.");
                                    Ticket.SetFilter("External Ticket No.", '=%1', TicketReservationRequest."External Ticket Number");
                                end else begin
                                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                                end;

                                if (Ticket.FindSet()) then
                                    repeat
                                        TempTickets.TransferFields(Ticket, true);
                                        if (not TempTickets.Insert()) then;
                                    until (Ticket.Next() = 0);
                            until (TicketReservationRequest.Next() = 0);

                        Page.Run(Page::"NPR TM Ticket List", TempTickets);
                    end;
                }
                action("Navi&gate")
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
                        SalesInvHeader: Record "Sales Invoice Header";
                        PosEntry: Record "NPR Pos Entry";

                        NotFound: Label 'No sales transaction found for ticket revoke request with token %1.';
                    begin
                        case Rec."Request Status" of
                            Rec."Request Status"::CONFIRMED:
                                begin
                                    TicketReservationReq.SetFilter("Session Token ID", '=%1', Rec."Session Token ID");
                                    TicketReservationReq.FindFirst();
                                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationReq."Entry No.");
                                    if (Ticket.FindFirst()) then
                                        TicketList.ShowTicketSalesTransaction(Ticket);
                                end;
                            Rec."Request Status"::CANCELED:
                                begin
                                    TicketReservationReq.SetFilter("Session Token ID", '=%1', Rec."Session Token ID");
                                    TicketReservationReq.FindFirst();

                                    if (TicketReservationReq."External Order No." <> '') then begin
                                        if (not SalesInvHeader.SetCurrentKey("NPR External Order No.")) then;
                                        SalesInvHeader.SetFilter("NPR External Order No.", '=%1', TicketReservationReq."External Order No.");
                                        if (SalesInvHeader.FindFirst()) then begin
                                            Page.Run(Page::"Posted Sales Invoice", SalesInvHeader);
                                            exit;
                                        end;

                                        SalesInvHeader.Reset();
                                        SalesInvHeader.SetFilter("External Document No.", '=%1', TicketReservationReq."External Order No.");
                                        if (SalesInvHeader.FindFirst()) then begin
                                            Page.Run(Page::"Posted Sales Invoice", SalesInvHeader);
                                            exit;
                                        end;
                                    end;
                                    if (TicketReservationReq."Receipt No." <> '') then begin
                                        PosEntry.SetFilter("Document No.", '=%1', TicketReservationReq."Receipt No.");
                                        if (PosEntry.FindFirst()) then begin
                                            Page.Run(Page::"NPR POS Entry Card", PosEntry);
                                            exit;
                                        end;
                                    end;

                                    Message(NotFound, Rec."Session Token ID");
                                end;
                        end;
                    end;
                }
                action(Deferral)
                {
                    Caption = 'Ticket Revenue Deferral';
                    ToolTip = 'View the deferral progress for this ticket request.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Image = Revenue;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    RunObject = page "NPR TM RevenueRecognition";
                    RunPageLink = TokenID = field("Session Token ID");
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
                action(RequestResponse)
                {
                    ToolTip = 'Display the ticket request response.';
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Response';
                    Image = Stages;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR TM RequestResponse";
                    RunPageLink = "Session Token ID" = field("Session Token ID");
                }
                action(TicketImportLog)
                {
                    ToolTip = 'Open the import ticket log list overview.';
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Imported Tickets Overview';
                    Image = ImportLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR TM ImportTicketLog";
                }
                action(TicketImportOrder)
                {
                    ToolTip = 'Open the import ticket order.';
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Imported Tickets Order';
                    Scope = Repeater;
                    Image = OrderTracking;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR TM ImportTicketsArchive";
                    RunPageLink = TicketRequestToken = field("Session Token ID");
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
                            OfflineTicketValidationMgr: Codeunit "NPR TM OfflineTicketValidBL";
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
                    TicketReservationRequest.SetFilter("Session Token ID", '=%1', Rec."Session Token ID");
                    TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
                    TicketReservationRequest.FindFirst();
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

        TicketReservationRequest.FindSet(true);
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

