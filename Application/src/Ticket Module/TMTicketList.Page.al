page 6059785 "NPR TM Ticket List"
{
    Extensible = False;
    Caption = 'Ticket List';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    CardPageId = "NPR TM Ticket Card";
    SourceTable = "NPR TM Ticket";
    SourceTableView = ORDER(Descending);
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Issued Tickets';
    PromotedActionCategories = 'New,Process,Report,Navigate';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {

        area(content)
        {
            field(Search; _TurboSearch)
            {
                Editable = true;
                Caption = 'Fast Search';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'This search is optimized to search relevant columns only.';
                trigger OnValidate()
                var
                    Ticket: Record "NPR TM Ticket";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);
                    if (_TurboSearch = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    Ticket.FilterGroup := -1;
                    Ticket.SetFilter("No.", '%1', _TurboSearch);
                    Ticket.SetFilter("External Ticket No.", '%1', _TurboSearch);
                    Ticket.SetFilter("Sales Receipt No.", '%1', _TurboSearch);
                    Ticket.SetFilter("Item No.", '%1', _TurboSearch);
                    Ticket.SetFilter("External Member Card No.", '%1', _TurboSearch);
                    Ticket.FilterGroup := 0;

                    Ticket.SetLoadFields("No.");
                    if (Ticket.FindSet()) then
                        repeat
                            Ticket.Mark(true);
                        until (Ticket.Next() = 0);

                    Rec.Copy(Ticket);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }

            repeater(Group)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket No. field';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid From Time field';
                }
                field("Valid To Date"; Rec."Valid To Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid To Date field';
                }
                field("Valid To Time"; Rec."Valid To Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid To Time field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked Date"; Rec."Blocked Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked Date field';
                }
                field("Printed Date"; Rec."Printed Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Printed Date field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Sales Header Type"; Rec."Sales Header Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Header Type field';
                }
                field("Sales Header No."; Rec."Sales Header No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Header No. field';
                }
                field("Sales Receipt No."; Rec."Sales Receipt No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Reciept No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("External Member Card No."; Rec."External Member Card No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Member Card No. field';
                }
                field(AmountInclVat; Rec.AmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Incl. Vat field';
                }
                field(AmountExclVat; Rec.AmountExclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Excl. Vat field';
                    Visible = false;
                }
                field("No. Of Access"; Rec."No. Of Access")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Of Access field';
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
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
                field("Ticket Reservation Entry No."; Rec."Ticket Reservation Entry No.")
                {
                    ToolTip = 'Specifies the value of the Ticket Reservation Entry No. field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
        area(navigation)
        {
            group(Manage)
            {
                Caption = 'Manage';
                Action("Create eTicket")
                {
                    ToolTip = 'Create and send ticket to wallet';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'Create eTicket';
                    Image = ElectronicNumber;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        CreateETicket();
                    end;
                }
                Action("Block/Unblock Tickets")
                {
                    ToolTip = 'Prevents the tickets from being used (reversible).';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Block/Unblock Tickets';
                    Image = Change;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ToggleTicketBlock();
                    end;
                }
                Action("Revoke Ticket")
                {
                    ToolTip = 'Prevents the tickets from being used (irreversible).';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Revoke Ticket';
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        RevokeTicket();
                    end;
                }
                Action("Change Ticket Reservation")
                {
                    Caption = 'Change Ticket Reservation';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Change the time slots that the ticket is valid for.';
                    Image = Reserve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ChangeTicketReservation(Rec);
                    end;
                }

                Action(Ticketholder)
                {
                    ToolTip = 'Edit ticket holder.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Holder';
                    Image = WIPEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ChangeTicketHolder();
                    end;
                }

            }
            group(NavigationGroup)
            {
                Caption = 'Navigate';
                Action("Access Entries")
                {
                    ToolTip = 'Navigate to ticket access entries.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Access Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Scope = Repeater;

                    RunObject = Page "NPR TM Ticket AccessEntry List";
                    RunPageLink = "Ticket No." = field("No.");
                }
                Action("Ticket Request")
                {
                    ToolTip = 'Navigate to Ticket Request.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Request';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        DisplayTicketRequest(Rec."Ticket Reservation Entry No.");
                    end;
                }
                Action(SpeedGateEntryLog)
                {
                    ToolTip = 'Navigate to Speed Gate Entry Log.';
                    ApplicationArea = NPRRetail;
                    Caption = 'Speed Gate Entry Log';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        EntryLog: Record "NPR SGEntryLog";
                        TempEntryLog: Record "NPR SGEntryLog" temporary;
                    begin
                        EntryLog.SetCurrentKey(ReferenceNo);
                        EntryLog.SetFilter(ReferenceNo, '=%1', Rec."External Ticket No.");
                        if (EntryLog.FindSet()) then
                            repeat
                                TempEntryLog.TransferFields(EntryLog, true);
                                if (not TempEntryLog.Insert()) then;
                            until (EntryLog.Next() = 0);
                        Page.Run(Page::"NPR SG EntryLogList", TempEntryLog);
                    end;

                }
                Action("View Online Ticket")
                {
                    ToolTip = 'Display the ticket as created on ticket server.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'View Online Ticket';
                    Image = Web;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
                    begin
                        DIYTicketPrint.ViewOnlineSingleTicket(Rec."No.");
                    end;
                }
                Action("View Ticket Notifications")
                {
                    ToolTip = 'Navigate to ticket notification entries.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'View Ticket Notifications';
                    Image = ElectronicNumber;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    RunObject = Page "NPR TM Ticket Notif. Entry";
                    RunPageLink = "Ticket No." = field("No.");
                }
                Action("ViewTicketCoupons")
                {
                    ToolTip = 'Navigate to ticket related coupons.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'View Ticket Coupons';
                    Image = Voucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    RunObject = Page "NPR TM TicketCoupons";
                    RunPageLink = TicketNo = field("No.");
                }
                Action(Navigate)
                {
                    ToolTip = 'Finds the web invoice or POS Sale.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Find Sales Transaction';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ShowTicketSalesTransaction(Rec);
                    end;
                }
            }
            Action(TicketBom)
            {
                ToolTip = 'Navigate to ticket admission bill-of-material.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                RunObject = Page "NPR TM Ticket BOM";
                RunPageLink = "Item No." = field("Item No.");
            }
            Action("Print Selected Tickets")
            {
                ToolTip = 'Print selected tickets.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Print Selected Tickets';
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    Ticket2: Record "NPR TM Ticket";
                begin
                    CurrPage.SetSelectionFilter(Ticket);
                    Ticket.FindSet();
                    repeat
                        Ticket2.Get(Ticket."No.");
                        Ticket2.SetRecFilter();
                        if (TicketManagement.PrintSingleTicket(Ticket2)) then begin
                            Ticket2."Printed Date" := Today();
                            Ticket2.Modify();
                            Commit();
                        end
                    until (Ticket.Next() = 0);
                end;
            }

            Action("Report Issued Tickets")
            {
                ToolTip = 'Print a report of issued tickets.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                RunObject = Report "NPR Issued Tickets";
            }
            Action(Statistics)
            {
                ToolTip = 'Navigate to Ticket Statistics';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Statistics';
                Image = Statistics;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
            }
            Action(Forecast)
            {
                ToolTip = 'Navigate to Admission Forecast.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Forecast';
                Image = Forecast;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                RunObject = Page "NPR TM Admis. Forecast Matrix";
            }
            Action(TicketAccessInformation)
            {
                ToolTip = 'This tool will show access information on the specific ticket, this helps to understand under what circumstances, and when the ticket will be valid for admission. This is only information; no admission data will be stored.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Access Information';
                Image = Calendar;

                trigger OnAction()
                begin
                    TicketManagement.ShowTicketAccess(Rec);
                end;
            }
            action("Check Ticket")
            {
                ToolTip = 'This tool allows for a simulation of admission, on a specified date and time, giving a response as if the ticket was validated by ticket holder. With this you can make sure a ticket works as expected when the guest arrives in the future.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission Simulation';
                Image = CalcWorkCenterCalendar;

                trigger OnAction()
                begin
                    TicketManagement.TicketAdmissionSimulation(Rec);
                end;
            }

        }
    }
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CONFIRM_REVOKE_TICKET: Label 'Are you sure you want to revoke %1 ticket(s)?';
        ETICKET_SENT: Label 'eTicket sent.';
        CONFIRM_ETICKET: Label 'Are you sure you want to create and send %1 eTickets?';
        _TurboSearch: Code[100];

    local procedure ChangeTicketHolder()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin

        TicketReservationRequest.Get(Rec."Ticket Reservation Entry No.");
        TicketNotifyParticipant.AcquireTicketParticipantForce(TicketReservationRequest."Session Token ID", TicketReservationRequest."Notification Method", TicketReservationRequest."Notification Address", TicketReservationRequest.TicketHolderName, true);

    end;

    local procedure ToggleTicketBlock()
    var
        Ticket: Record "NPR TM Ticket";
        Ticket2: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        CurrPage.SetSelectionFilter(Ticket);
        if (Ticket.FindSet()) then begin
            repeat
                Ticket2.Get(Ticket."No.");

                Ticket2.Blocked := (not Ticket.Blocked);
                if (Ticket2.Blocked) then
                    Ticket2."Blocked Date" := Today
                else
                    Ticket2."Blocked Date" := 0D;

                Ticket2.Modify();

                if (Ticket2.Blocked) then
                    TicketRequestManager.OnAfterBlockTicketPublisher(Ticket."No.");
                if (not Ticket2.Blocked) then
                    TicketRequestManager.OnAfterUnblockTicketPublisher(Ticket."No.");

                if (Rec.IsTemporary()) then begin
                    Rec.Get(Ticket2."No.");
                    Rec.Copy(Ticket2);
                    Rec.Modify();
                end;

            until (Ticket.Next() = 0);
        end;

    end;

    local procedure RevokeTicket()
    var
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        Token: Text[100];
    begin

        CurrPage.SetSelectionFilter(Ticket);
        TicketCount := Ticket.Count();

        if (not Confirm(CONFIRM_REVOKE_TICKET, false, TicketCount)) then
            Error('');

        if (Ticket.FindSet()) then begin
            Token := TicketRequestManager.GetNewToken();
            repeat
                AmountToReverse := 0;
                QtyToReverse := 0;
                TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", CopyStr(UserId(), 1, 20), 0, AmountToReverse, QtyToReverse);
            until (Ticket.Next() = 0);
            TicketRequestManager.RevokeReservationTokenRequest(Token, false);
        end;
    end;

    local procedure CreateETicket()
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Ticket: Record "NPR TM Ticket";
        ReasonText: Text;
        TicketCount: Integer;
    begin

        CurrPage.SetSelectionFilter(Ticket);
        TicketCount := Ticket.Count();

        if (TicketCount > 1) then
            if (not (Confirm(CONFIRM_ETICKET, true, TicketCount))) then
                Error('');

        if (Ticket.FindSet()) then begin
            repeat
                if (not TicketRequestManager.CreateAndSendETicket(Rec."No.", ReasonText)) then
                    Error(ReasonText);
            until (Ticket.Next() = 0);
        end;

        Message(ETICKET_SENT);
    end;

    local procedure ChangeTicketReservation(Ticket: Record "NPR TM Ticket");
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketMakeReservationPage: Page "NPR TM Ticket Make Reserv.";
        RequestToken: Text[100];
        ResponseMessage: Text;
        PageAction: Action;
    begin

        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
        if (not TicketRequestManager.CreateChangeRequest(Ticket."External Ticket No.",
                  TicketReservationRequest."Authorization Code", RequestToken, ResponseMessage)) then
            Error(ResponseMessage);

        Commit();

        TicketMakeReservationPage.SetTicketItem(Ticket."Item No.", Ticket."Variant Code");
        TicketMakeReservationPage.AllowQuantityChange(IsUnpaidTourTicket(Ticket));
        TicketMakeReservationPage.SetAllowCustomizableTicketQtyChange(true);
        TicketMakeReservationPage.SetIgnoreScheduleSelectionFilter(true);
        TicketMakeReservationPage.LoadTicketRequest(RequestToken);
        TicketMakeReservationPage.LookupMode(true);
        PageAction := TicketMakeReservationPage.RunModal();
        if (PageAction = Action::LookupOK) then begin
            TicketMakeReservationPage.FinalizeChangeRequest(true, ResponseMessage);
        end;

    end;

    local procedure IsUnpaidTourTicket(Ticket: Record "NPR TM Ticket"): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketType.Get(Ticket."Ticket Type Code");
        if (TicketType."Admission Registration" <> TicketType."Admission Registration"::GROUP) then
            exit(false);

        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::POSTPAID, DetTicketAccessEntry.Type::PREPAID);
        exit(DetTicketAccessEntry.IsEmpty());
    end;

    local procedure DisplayTicketRequest(RequestEntryNo: Integer);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin

        TicketReservationRequest.Get(RequestEntryNo);
        AddRequestToTmp(TicketReservationRequest."Session Token ID", TempTicketReservationRequest);

        TicketReservationRequest.CalcFields("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FindFirst();
                AddRequestToTmp(TicketReservationRequest."Session Token ID", TempTicketReservationRequest);

                TicketReservationRequest.CalcFields("Is Superseeded");
            end;
        until (not TicketReservationRequest."Is Superseeded");

        Page.Run(Page::"NPR TM Ticket Request", TempTicketReservationRequest);
    end;

    local procedure AddRequestToTmp(Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TmpTicketReservationRequest.TRANSFERFIELDS(TicketReservationRequest, true);
                TmpTicketReservationRequest.Insert();
            until (TicketReservationRequest.Next() = 0);
        end;
    end;



    internal procedure ShowTicketSalesTransaction(Ticket: Record "NPR TM Ticket")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        PosEntry: Record "NPR Pos Entry";
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
    begin
        if (Ticket."Sales Receipt No." <> '') then begin
            PosEntry.SetFilter("Document No.", '=%1', Ticket."Sales Receipt No.");
            if (PosEntry.FindFirst()) then begin
                Page.Run(Page::"NPR POS Entry Card", PosEntry);
                exit;
            end;
        end;

        if (TicketReservationReq.Get(Ticket."Ticket Reservation Entry No.")) then begin
            if (TicketReservationReq."External Order No." <> '') then begin
                if (not SalesInvHeader.SetCurrentKey("NPR External Order No.")) then;
                SalesInvHeader.SetFilter("NPR External Order No.", '%1', TicketReservationReq."External Order No.");
                if (SalesInvHeader.FindFirst()) then begin
                    Page.Run(Page::"Posted Sales Invoice", SalesInvHeader);
                    exit;
                end;

                SalesInvHeader.Reset();
                SalesInvHeader.SetFilter("External Document No.", '%1', TicketReservationReq."External Order No.");
                if (SalesInvHeader.FindFirst()) then begin
                    Page.Run(Page::"Posted Sales Invoice", SalesInvHeader);
                    exit;
                end;
            end;
        end;
    end;


}

