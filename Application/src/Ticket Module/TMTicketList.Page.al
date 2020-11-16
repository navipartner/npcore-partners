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
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid From Date"; "Valid From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid From Time"; "Valid From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid To Date"; "Valid To Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Valid To Time"; "Valid To Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Blocked Date"; "Blocked Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Printed Date"; "Printed Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Header Type"; "Sales Header Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Header No."; "Sales Header No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Sales Receipt No."; "Sales Receipt No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Member Card No."; "External Member Card No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("No. Of Access"; "No. Of Access")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Last Date Modified"; "Last Date Modified")
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
                    DisplayTicketRequest("Ticket Reservation Entry No.");
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
        //  ELSE begin
        //    SuggestNotificationMethod := SuggestNotificationMethod::NA;
        //    TicketReservationRequest."Notification Address" := '';
        //  end;
        // end;

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

        //-#417417 [417417]
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

        //+#417417 [417417]
    end;

    local procedure DisplayTicketRequest(RequestEntryNo: Integer);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin

        //-#417417 [417417]
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

        //-#417417 [417417]
        TicketReservationRequest.SETFILTER("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FINDSET()) then begin
            repeat
                TmpTicketReservationRequest.TRANSFERFIELDS(TicketReservationRequest, TRUE);
                TmpTicketReservationRequest.INSERT();
            until (TicketReservationRequest.NEXT() = 0);
        end;
    end;
}

