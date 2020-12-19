page 6059785 "NPR TM Ticket List"
{
    Caption = 'Ticket List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket";
    SourceTableView = ORDER(Descending);
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Issued Tickets';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid To Date"; Rec."Valid To Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid To Time"; Rec."Valid To Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Blocked Date"; Rec."Blocked Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Printed Date"; Rec."Printed Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Header Type"; Rec."Sales Header Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Header No."; Rec."Sales Header No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Receipt No."; Rec."Sales Receipt No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Member Card No."; Rec."External Member Card No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("No. Of Access"; Rec."No. Of Access")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create eTicket")
            {
                ToolTip = 'Create and send ticket to wallet.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Create eTicket';
                Image = ElectronicNumber;
                Promoted = true;
                PromotedIsBig = true;


                trigger OnAction()
                begin
                    CreateETicket();
                end;
            }
            separator(Separator6014403)
            {
            }
            action("Block/Unblock Tickets")
            {
                ToolTip = 'Prevents the tickets from being used (reversible).';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Block/Unblock Tickets';
                Image = Change;


                trigger OnAction()
                begin
                    ToggleTicketBlock();
                end;
            }
            action("Revoke Ticket")
            {
                ToolTip = 'Prevents the tickets from being used (irreversible).';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Revoke Ticket';
                Ellipsis = true;
                Image = RemoveLine;


                trigger OnAction()
                begin
                    RevokeTicket();
                end;
            }
            action("Change Ticket Reservation")
            {
                Caption = 'Change Ticket Reservation';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Change the time slots that the ticket is valid for.';
                Ellipsis = true;
                Image = Reserve;
                Promoted = true;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    ChangeTicketReservation();
                end;
            }
        }
        area(navigation)
        {
            action("Access Entries")
            {
                ToolTip = 'Navigate to ticket access entries.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Access Entries';
                Ellipsis = true;
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket AccessEntry List";
                RunPageLink = "Ticket No." = FIELD("No.");

            }
            action(Ticketholder)
            {
                ToolTip = 'Edit ticket holder.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticketholder';
                Ellipsis = true;
                Image = WIPEntries;
                Promoted = true;
                PromotedCategory = Process;


                trigger OnAction()
                begin
                    ChangeTicketholder();
                end;
            }
            action("Ticket Request")
            {
                ToolTip = 'Navigate to Ticket Request.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Request';
                Ellipsis = true;
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DisplayTicketRequest(Rec."Ticket Reservation Entry No.");
                end;


            }
            separator(Separator6014406)
            {
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

                    DIYTicketPrint.ViewOnlineSingleTicket(Rec."No.");
                end;
            }
            action("View Ticket Notifications")
            {
                ToolTip = 'Navigate to ticket notification entries.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'View Ticket Notifications';
                Ellipsis = true;
                Image = ElectronicNumber;
                RunObject = Page "NPR TM Ticket Notif. Entry";
                RunPageLink = "Ticket No." = FIELD("No.");

            }
            separator(Separator6014407)
            {
            }
            action("Print Selected Tickets")
            {
                ToolTip = 'Print selected tickets.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Print Selected Tickets';
                Image = Print;
                Promoted = true;
                ShortCutKey = 'Shift+Ctrl+P';


                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    Ticket2: Record "NPR TM Ticket";
                begin

                    CurrPage.SetSelectionFilter(Ticket);
                    Ticket.FindSet();
                    repeat
                        Ticket2.Get(Ticket."No.");
                        Ticket2.SetRecFilter;
                        TicketManagement.PrintSingleTicket(Ticket2);
                    until (Ticket.Next() = 0);
                end;
            }
            action("Report Issued Tickets")
            {
                ToolTip = 'Print a report of issued tickets.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Print;
                RunObject = Report "NPR Issued Tickets";

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Blocked, '=%1', false);
    end;

    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CONFIRM_REVOKE_TICKET: Label 'Are you sure you want to revoke %1 ticket(s)?';
        ETICKET_SENT: Label 'eTicket sent.';
        CONFIRM_ETICKET: Label 'Are you sure you want to create and send %1 eTickets?';

    local procedure ChangeTicketholder()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        SuggestNotificationMethod: Option NA,EMAIL,SMS;
    begin

        TicketReservationRequest.Get(Rec."Ticket Reservation Entry No.");
        TicketNotifyParticipant.AquireTicketParticipantForce(TicketReservationRequest."Session Token ID", TicketReservationRequest."Notification Method", TicketReservationRequest."Notification Address", true);

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

            until (Ticket.Next() = 0);
        end;
    end;

    local procedure RevokeTicket()
    var
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        ResponseMessage: Text;
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
                TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", UserId, 0, AmountToReverse, QtyToReverse);
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

    local procedure ChangeTicketReservation();
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketMakeReservationPage: Page "NPR TM Ticket Make Reserv.";
        RequestToken: Text[100];
        ResponseMessage: Text;
        PageAction: Action;
    begin

        CurrPage.SETSELECTIONFILTER(Ticket);
        Ticket.FINDFIRST();

        TicketReservationRequest.GET("Ticket Reservation Entry No.");
        if (NOT TicketRequestManager.CreateChangeRequest(Ticket."External Ticket No.",
                  TicketReservationRequest."Authorization Code", RequestToken, ResponseMessage)) then
            ERROR(ResponseMessage);

        COMMIT();

        RESET();
        TicketMakeReservationPage.SetTicketItem(Ticket."Item No.", Ticket."Variant Code");
        TicketMakeReservationPage.LoadTicketRequest(RequestToken);
        TicketMakeReservationPage.LOOKUPMODE(TRUE);
        PageAction := TicketMakeReservationPage.RUNMODAL();
        if (PageAction = ACTION::LookupOK) then begin
            TicketMakeReservationPage.FinalizeChangeRequest(TRUE, ResponseMessage);
        end;

    end;

    local procedure DisplayTicketRequest(RequestEntryNo: Integer);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin

        TicketReservationRequest.GET(RequestEntryNo);
        AddRequestToTmp(TicketReservationRequest."Session Token ID", TmpTicketReservationRequest);

        TicketReservationRequest.CALCFIELDS("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.RESET();
                TicketReservationRequest.SETFILTER("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FINDFIRST();
                AddRequestToTmp(TicketReservationRequest."Session Token ID", TmpTicketReservationRequest);

                TicketReservationRequest.CALCFIELDS("Is Superseeded");
            end;
        until (NOT TicketReservationRequest."Is Superseeded");

        PAGE.RUN(PAGE::"NPR TM Ticket Request", TmpTicketReservationRequest);
    end;

    local procedure AddRequestToTmp(Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SETFILTER("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FINDSET()) then begin
            repeat
                TmpTicketReservationRequest.TRANSFERFIELDS(TicketReservationRequest, TRUE);
                TmpTicketReservationRequest.INSERT();
            until (TicketReservationRequest.NEXT() = 0);
        end;
    end;
}

