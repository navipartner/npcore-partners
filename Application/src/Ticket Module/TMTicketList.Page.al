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
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
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
                action("Create eTicket")
                {
                    ToolTip = 'Create and send ticket to wallet';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'Create eTicket';
                    Image = ElectronicNumber;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        CreateETicket();
                    end;
                }
                action("Block/Unblock Tickets")
                {
                    ToolTip = 'Prevents the tickets from being used (reversible).';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Block/Unblock Tickets';
                    Image = Change;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    scope = Repeater;
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
                    Image = RemoveLine;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    scope = Repeater;
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
                    Image = Reserve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    scope = Repeater;
                    trigger OnAction()
                    begin
                        ChangeTicketReservation();
                    end;
                }
                action(Ticketholder)
                {
                    ToolTip = 'Edit ticket holder.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Holder';
                    Image = WIPEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    scope = Repeater;
                    trigger OnAction()
                    begin
                        ChangeTicketHolder();
                    end;
                }

            }
            group(NavigationGroup)
            {
                Caption = 'Navigate';
                action("Access Entries")
                {
                    ToolTip = 'Navigate to ticket access entries.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Access Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPR TM Ticket AccessEntry List";
                    RunPageLink = "Ticket No." = FIELD("No.");
                    Scope = Repeater;
                }
                action("Ticket Request")
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
                        DIYTicketPrint.ViewOnlineSingleTicket(Rec."No.");
                    end;
                }
                action("View Ticket Notifications")
                {
                    ToolTip = 'Navigate to ticket notification entries.';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Caption = 'View Ticket Notifications';
                    Image = ElectronicNumber;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR TM Ticket Notif. Entry";
                    RunPageLink = "Ticket No." = FIELD("No.");
                }
                action(Navigate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Find Sales Transaction';
                    Image = Navigate;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Finds the web invoice or POS Sale.';
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        ShowTicketSalesTransaction(Rec);
                    end;
                }
            }
            action(TicketBom)
            {
                ToolTip = 'Navigate to ticket admission bill-of-material.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                RunObject = Page "NPR TM Ticket BOM";
                RunPageLink = "Item No." = FIELD("Item No.");
            }
            action("Print Selected Tickets")
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Report "NPR Issued Tickets";
            }
            action(Statistics)
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
            action(Forecast)
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

    local procedure ChangeTicketHolder()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
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

        TicketReservationRequest.GET(Rec."Ticket Reservation Entry No.");
        if (NOT TicketRequestManager.CreateChangeRequest(Ticket."External Ticket No.",
                  TicketReservationRequest."Authorization Code", RequestToken, ResponseMessage)) then
            ERROR(ResponseMessage);

        COMMIT();

        Rec.RESET();
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

    procedure ShowTicketSalesTransaction(Ticket: Record "NPR TM Ticket")
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
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvHeader);
                    exit;
                end;

                SalesInvHeader.Reset();
                SalesInvHeader.SetFilter("External Document No.", '%1', TicketReservationReq."External Order No.");
                if (SalesInvHeader.FindFirst()) then begin
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvHeader);
                    exit;
                end;
            end;
        end;
    end;
}

