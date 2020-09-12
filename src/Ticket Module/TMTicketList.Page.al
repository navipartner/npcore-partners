page 6059785 "NPR TM Ticket List"
{
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016
    // TM1.17/TSA/20160913  CASE 251883 Added SMS as Notification Method
    // TM1.17/JLK/20161024  CASE 251883 Added Issued Ticket Print button
    // TM1.18/TSA/20161220  CASE 261564 Added related information page ticket request, put visible false on some more fields
    // TM1.19/TSA/20170220  CASE 266768 Added default filter to not show blocked entries
    // TM1.20/TSA/20170222  CASE 266835 Removed the redundant print button and fixed the "Print Selected Tickets" to print the selected tickets
    // TM1.21/TSA/20170504  CASE 274843 Added ToggleBlockUnblock() function
    // TM1.21/TSA/20170525  CASE 278049 Fixing issues report by OMA
    // TM1.26/TSA /20171103 CASE 285601 Added action View Ticket
    // TM1.26/TSA /20171120 CASE 296731 Added function RevokeTicket() and the button to go with it
    // NPR5.43/TS  20180626 CASE 317161 Promoted Action Print Selected Tickets
    // TM1.38/TSA /20181023 CASE 332109 Added eTicket support
    // TM1.39/NPKNAV/20190125  CASE 310057 Transport TM1.39 - 25 January 2019
    // TM90.1.46/TSA /20200129 CASE 387138 Refactored ChangeTicketholder();

    Caption = 'Ticket List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket";
    SourceTableView = ORDER(Descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = All;
                }
                field("Valid From Date"; "Valid From Date")
                {
                    ApplicationArea = All;
                }
                field("Valid From Time"; "Valid From Time")
                {
                    ApplicationArea = All;
                }
                field("Valid To Date"; "Valid To Date")
                {
                    ApplicationArea = All;
                }
                field("Valid To Time"; "Valid To Time")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked Date"; "Blocked Date")
                {
                    ApplicationArea = All;
                }
                field("Printed Date"; "Printed Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sales Header Type"; "Sales Header Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sales Header No."; "Sales Header No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sales Receipt No."; "Sales Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("External Member Card No."; "External Member Card No.")
                {
                    ApplicationArea = All;
                }
                field("No. Of Access"; "No. Of Access")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
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
                Caption = 'Create eTicket';
                Image = ElectronicNumber;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                Caption = 'Block/Unblock Tickets';
                Image = Change;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ToggleTicketBlock();
                end;
            }
            action("Revoke Ticket")
            {
                Caption = 'Revoke Ticket';
                Ellipsis = true;
                Image = RemoveLine;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    RevokeTicket();
                end;
            }
        }
        area(navigation)
        {
            action("Access Entries")
            {
                Caption = 'Access Entries';
                Ellipsis = true;
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket AccessEntry List";
                RunPageLink = "Ticket No." = FIELD("No.");
                ApplicationArea = All;
            }
            action(Ticketholder)
            {
                Caption = 'Ticketholder';
                Ellipsis = true;
                Image = WIPEntries;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ChangeTicketholder();
                end;
            }
            action("Ticket Request")
            {
                Caption = 'Ticket Request';
                Ellipsis = true;
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Request";
                RunPageLink = "Entry No." = FIELD("Ticket Reservation Entry No.");
                ApplicationArea = All;
            }
            separator(Separator6014406)
            {
            }
            action("View Online Ticket")
            {
                Caption = 'View Online Ticket';
                Image = Web;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    DIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
                begin

                    DIYTicketPrint.ViewOnlineSingleTicket(Rec."No.");
                end;
            }
            action("View Ticket Notifications")
            {
                Caption = 'View Ticket Notifications';
                Ellipsis = true;
                Image = ElectronicNumber;
                RunObject = Page "NPR TM Ticket Notif. Entry";
                RunPageLink = "Ticket No." = FIELD("No.");
                ApplicationArea = All;
            }
            separator(Separator6014407)
            {
            }
            action("Print Selected Tickets")
            {
                Caption = 'Print Selected Tickets';
                Image = Print;
                Promoted = true;
                ShortCutKey = 'Shift+Ctrl+P';
                ApplicationArea = All;

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
                Caption = 'Issued Tickets';
                Image = Print;
                RunObject = Report "NPR Issued Tickets";
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-+TM1.19 [266768]
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

        TicketReservationRequest.Get("Ticket Reservation Entry No.");


        //-TM90.1.46 [387138]
        // CASE TicketReservationRequest."Notification Method" OF
        //  TicketReservationRequest."Notification Method"::EMAIL : SuggestNotificationMethod := SuggestNotificationMethod::EMAIL;
        //  TicketReservationRequest."Notification Method"::SMS : SuggestNotificationMethod := SuggestNotificationMethod::SMS;
        //  ELSE BEGIN
        //    SuggestNotificationMethod := SuggestNotificationMethod::NA;
        //    TicketReservationRequest."Notification Address" := '';
        //  END;
        // END;

        //TicketNotifyParticipant.AquireTicketParticipant (TicketReservationRequest."Session Token ID", TicketReservationRequest."Notification Method", TicketReservationRequest."Notification Address");
        TicketNotifyParticipant.AquireTicketParticipantForce(TicketReservationRequest."Session Token ID", TicketReservationRequest."Notification Method", TicketReservationRequest."Notification Address", true);
        //+TM90.1.46 [387138]
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

                //-TM1.38 [332109]
                if (Ticket2.Blocked) then
                    TicketRequestManager.OnAfterBlockTicketPublisher(Ticket."No.");
                if (not Ticket2.Blocked) then
                    TicketRequestManager.OnAfterUnblockTicketPublisher(Ticket."No.");
            //+TM1.38 [332109]

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

        //-TM1.26 [296731]
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
            TicketRequestManager.RevokeReservationTokenRequest(Token, false, true, ResponseMessage);
        end;
        //+TM1.26 [296731]
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
}

