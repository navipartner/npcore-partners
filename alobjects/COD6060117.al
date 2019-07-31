codeunit 6060117 "TM Ticket Retail Management"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160223  CASE 232952 Refactor or PUSH button implementation
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160512  CASE 240863 POS Quick Statistics
    // TM1.15/TSA/20160512  CASE 240864 Cancel Ticket
    // TM1.16/TSA/20160714  CASE 245004 Handling of ticket notification
    // TM1.17/TSA/20130913  CASE 252053 Update schedules when the "more info" dialog is displayed
    // TM1.17/TSA/20160913  CASE 251883 Added SMS as Notification Method
    // TM1.17/TSA/20160930  CASE 253951 Missing the * between qty and itemnumber in RevokeTicketReservation!, Menuline must be declared VAR in prepush functions
    // TM1.17/TSA/20160930  CASE 254019 GetRequestToken returns wrong token when receipt is blank,
    // TM1.17/TSA/20160930  CASE 254019 Make ticket functions work on no sales line - query for ticket number.
    // TM1.19/TSA/20170217  CASE 266372 Made function IssueTicket from inlined code
    // TM1.20/TSA/20170323  CASE 269171 POS_CreateRevokeRequest signature change
    // TM1.21/TSA/20170503  CASE 267611 Allowing quantity change in page AquireTicketAdmissionSchedule
    // NPR5.32.10/TSA/20170616  CASE 250631 Changed Signature of POS_CreateRevokeRequest
    // TM1.23/TSA /20170727 CASE 285079 Added LockResources() to RegisterArrival() and NewTicketSalesAdmissionCapture()
    // TM1.28/TSA /20170727 CASE 284248 PickupPreConfirmedTicket() and 'PICKUP_RESERVATION' switch
    // TM1.28/TSA /20180220 CASE 305707 Setting ticket item number to ticket request page
    // TM1.30/TSA /20180420 CASE 310947 When there is no sale line available, item is selected from ticket request instead
    // TM1.39/TSA /20181109 CASE 335653 Signature change on POS_CreateRevokeRequest
    // TM1.41/TSA /20190509 CASE 353981 Dynamic ticket schedule price


    var
        ABORTED: Label 'Aborted.';
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';

    procedure IssueTicket(Token: Text[100]; ExternalMemberNo: Code[20]; FailWithError: Boolean; ResponseCode: Integer; ResponseMessage: Text; SaleLinePOS: Record "Sale Line POS"; UpdateSalesLine: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin

        //-TM1.19 [266372]
        AssignSameSchedule(Token);
        AssignSameNotificationAddress(Token);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.IsEmpty()) then begin
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
            if (ResponseCode = 0) then begin

                Commit;
                AquireTicketParticipant(Token, ExternalMemberNo);

                Commit;
                exit(true); // nothing to confirm;
            end;
        end;

        Commit;
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AquireTicketAdmissionSchedule(Token, SaleLinePOS, UpdateSalesLine)) then begin
            ResponseMessage := '';
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
        end;

        if (ResponseCode = 0) then begin

            Commit;
            AquireTicketParticipant(Token, ExternalMemberNo);

            Commit;
            exit(true);
        end;

        exit(false);
        //-TM1.19 [266372]
    end;

    procedure AquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "Sale Line POS"; HaveSalesLine: Boolean) LookupOK: Boolean
    var
        PageAction: Action;
        Item: Record Item;
        i: Integer;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        DisplayTicketeservationRequest: Page "TM Ticket Make Reservation";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        NewQuantity: Integer;
        ResolvedByTable: Integer;
    begin
        //-NPR5.32.10

        TicketReservationRequest.Reset();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);

        //-TM1.17 - update / refresh the schedule entries
        TicketReservationRequest.FindSet();
        repeat
            if (TicketReservationRequest."Admission Code" <> '') then
                TicketManagement.GetCurrentScheduleEntry(TicketReservationRequest."Admission Code", true);
        until (TicketReservationRequest.Next() = 0);
        Commit;

        //-#310947 [310947]
        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;
        //+#310947 [310947]

        //-TM1.21
        repeat
            Clear(DisplayTicketeservationRequest);
            DisplayTicketeservationRequest.LoadTicketRequest(Token);
            //-TM1.28 [305707]
            DisplayTicketeservationRequest.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
            //+TM1.28 [305707]
            DisplayTicketeservationRequest.AllowQuantityChange(HaveSalesLine);
            DisplayTicketeservationRequest.LookupMode(true);
            DisplayTicketeservationRequest.Editable(true);

            if (ResponseMessage <> '') then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketeservationRequest.RunModal();
            if (PageAction <> ACTION::LookupOK) then
                exit(false);

        until (DisplayTicketeservationRequest.FinalizeReservationRequest(false, ResponseMessage) = 0);

        if (HaveSalesLine) then begin
            //-TM1.41 [353981]
            //  IF (DisplayTicketeservationRequest.GetChangedTicketQuantity (NewQuantity)) THEN BEGIN
            //    SaleLinePOS.VALIDATE (Quantity, NewQuantity);
            //    SaleLinePOS.MODIFY ();
            //    COMMIT;
            //  END;
            DisplayTicketeservationRequest.GetChangedTicketQuantity(NewQuantity);
            SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
            SaleLinePOS.Validate(Quantity, NewQuantity);
            SaleLinePOS.Modify();
            Commit;
            //+TM1.41 [353981]

        end;

        exit(true);
        //+TM1.21
    end;

    procedure AquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
        MemberManagement: Codeunit "MM Membership Management";
        Member: Record "MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        if (Token = '') then
            exit(false);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then begin
            SuggestAddress := TicketReservationRequest."Notification Address";
            case TicketReservationRequest."Notification Method" of
                TicketReservationRequest."Notification Method"::EMAIL:
                    SuggestMethod := SuggestMethod::EMAIL;
                TicketReservationRequest."Notification Method"::SMS:
                    SuggestMethod := SuggestMethod::SMS;
                else
                    SuggestMethod := SuggestMethod::NA;
            end;
        end;

        if (ExternalMemberNo <> '') then begin
            if (Member.Get(MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo))) then begin
                case Member."Notification Method" of
                    Member."Notification Method"::EMAIL:
                        begin
                            SuggestMethod := SuggestMethod::EMAIL;
                            SuggestAddress := Member."E-Mail Address";
                        end;
                end;
            end;
        end;

        exit(TicketNotifyParticipant.AquireTicketParticipant(Token, SuggestMethod, SuggestAddress));
    end;

    procedure AssignSameSchedule(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same schedule to same admission objects
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                TicketReservationRequest2.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                TicketReservationRequest2.SetFilter("External Adm. Sch. Entry No.", '>%1', 0);
                if (TicketReservationRequest2.FindLast()) then begin
                    TicketReservationRequest."External Adm. Sch. Entry No." := TicketReservationRequest2."External Adm. Sch. Entry No.";
                    TicketReservationRequest."Scheduled Time Description" := TicketReservationRequest2."Scheduled Time Description";
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    procedure AssignSameNotificationAddress(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
    begin

        // assign same notification address
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Notification Address", '=%1', '');
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                TicketReservationRequest2.SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                TicketReservationRequest2.SetFilter("Notification Address", '<>%1', '');
                if (TicketReservationRequest2.FindLast()) then begin
                    TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
                    TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;
}

