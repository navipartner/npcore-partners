codeunit 6060117 "NPR TM Ticket Retail Mgt."
{
    Access = Internal;

    var
        ABORTED: Label 'Aborted.';
        SCHEDULE_ERROR: Label 'There was an error changing the reservation \\%1\\Do you want to try again?';

    procedure IssueTicket(Token: Text[100]; ExternalMemberNo: Code[20]; ResponseCode: Integer; ResponseMessage: Text; SaleLinePOS: Record "NPR POS Sale Line"; UpdateSalesLine: Boolean) Success: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
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

                Commit();
                AcquireTicketParticipant(Token, ExternalMemberNo);

                Commit();
                exit(true); // nothing to confirm;
            end;
        end;

        Commit();
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AcquireTicketAdmissionSchedule(Token, SaleLinePOS, UpdateSalesLine, ResponseMessage)) then begin
            ResponseMessage := '';
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
        end;

        if (ResponseCode = 0) then begin

            Commit();
            AcquireTicketParticipant(Token, ExternalMemberNo);

            Commit();
            exit(true);
        end;

        exit(false);
    end;

    procedure AcquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "NPR POS Sale Line"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketReservationRequest: Page "NPR TM Ticket Make Reserv.";
        DisplayTicketReservationRequestPhone: Page "NPR TM TicketMakeReservePhone";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        AdmissionScheduleMgt: Codeunit "NPR TM Admission Sch. Mgt.";
        NewQuantity: Integer;
        ResolvedByTable: Integer;
        ResultCode: Integer;
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);

        TicketReservationRequest.FindSet();
        repeat
            if (TicketReservationRequest."Admission Code" <> '') then
                AdmissionScheduleMgt.CreateAdmissionSchedule(TicketReservationRequest."Admission Code", false, Today(), 'NPRTMTicketRetailMgt.AcquireTicketAdmissionSchedule()');
        until (TicketReservationRequest.Next() = 0);
        Commit();

        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;

        ResultCode := 0;


        if (Session.CurrentClientType = Session.CurrentClientType::Phone) then begin
            repeat
                Clear(DisplayTicketReservationRequestPhone);
                DisplayTicketReservationRequestPhone.LoadTicketRequest(Token);
                DisplayTicketReservationRequestPhone.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
                DisplayTicketReservationRequestPhone.AllowQuantityChange(HaveSalesLine);
                DisplayTicketReservationRequestPhone.SetAllowCustomizableTicketQtyChange(true);
                DisplayTicketReservationRequestPhone.LookupMode(false);
                DisplayTicketReservationRequestPhone.Editable(true);

                if (ResultCode <> 0) then
                    if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                        exit(false);

                PageAction := DisplayTicketReservationRequestPhone.RunModal();
                if (PageAction <> Action::OK) then begin
                    ResponseMessage := ABORTED;
                    exit(false);
                end;

                ResultCode := DisplayTicketReservationRequestPhone.FinalizeReservationRequest(false, ResponseMessage);
                if (ResultCode = 11) then begin
                    ResponseMessage := ''; // Silent error downstream
                    exit(false);
                end;

            until (ResultCode = 0);
            DisplayTicketReservationRequestPhone.GetChangedTicketQuantity(NewQuantity);

        end else begin
            repeat
                Clear(DisplayTicketReservationRequest);
                DisplayTicketReservationRequest.LoadTicketRequest(Token);
                DisplayTicketReservationRequest.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
                DisplayTicketReservationRequest.AllowQuantityChange(HaveSalesLine);
                DisplayTicketReservationRequest.SetAllowCustomizableTicketQtyChange(true);
                DisplayTicketReservationRequest.LookupMode(true);
                DisplayTicketReservationRequest.Editable(true);

                if (ResultCode <> 0) then
                    if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                        exit(false);

                PageAction := DisplayTicketReservationRequest.RunModal();
                if (PageAction <> Action::LookupOK) then begin
                    ResponseMessage := ABORTED;
                    exit(false);
                end;

                ResultCode := DisplayTicketReservationRequest.FinalizeReservationRequest(false, ResponseMessage);
                if (ResultCode = 11) then begin
                    ResponseMessage := ''; // Silent error downstream
                    exit(false);
                end;

            until (ResultCode = 0);
            DisplayTicketReservationRequest.GetChangedTicketQuantity(NewQuantity);
        end;

        if (HaveSalesLine) then begin
            SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
            SaleLinePOS.Validate(Quantity, NewQuantity);
            SaleLinePOS.Modify();
            Commit();
        end;

        exit(true);
    end;

    procedure AcquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        Member: Record "NPR MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
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

        exit(TicketNotifyParticipant.AcquireTicketParticipant(Token, SuggestMethod, SuggestAddress));
    end;

    procedure AssignSameSchedule(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                if (TicketReservationRequest."Receipt No." <> '') then begin
                    TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                end else begin
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                end;

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
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Notification Address", '=%1', '');
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest2.Reset();
                if (TicketReservationRequest."Receipt No." <> '') then begin
                    TicketReservationRequest2.SetFilter("Receipt No.", '=%1', TicketReservationRequest."Receipt No.");
                end else begin
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                end;

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

    procedure AcquireAdditionalExperiences(Ticket: Record "NPR TM Ticket"; POSSession: Codeunit "NPR POS Session"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketReservationRequest: Page "NPR TM Ticket Make Reserv.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResolvedByTable: Integer;
        ResultCode: Integer;
        Token: Text[100];
    begin

        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
        if (not TicketRequestManager.CreateChangeRequestDynamicTicket(Ticket."External Ticket No.",
                  TicketReservationRequest."Authorization Code", Token, ResponseMessage)) then
            Error(ResponseMessage);
        Commit();

        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;

        ResultCode := 0;
        repeat
            Clear(DisplayTicketReservationRequest);
            DisplayTicketReservationRequest.LoadTicketRequest(Token);
            DisplayTicketReservationRequest.SetTicketItem(Ticket."Item No.", Ticket."Variant Code");
            DisplayTicketReservationRequest.AllowQuantityChange(true);
            DisplayTicketReservationRequest.SetAllowCustomizableTicketQtyChange(true);
            DisplayTicketReservationRequest.LookupMode(true);
            DisplayTicketReservationRequest.Editable(true);

            if (ResultCode <> 0) then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketReservationRequest.RunModal();
            if (PageAction <> Action::LookupOK) then begin
                ResponseMessage := ABORTED;
                TicketRequestManager.DeleteReservationRequest(Token, true);
                exit(false);
            end;


            ResultCode := DisplayTicketReservationRequest.FinalizeChangeRequestDynamicTicket(Ticket."No.", POSSession, true, ResponseMessage); //finalize should happen after the POS transaction is finished
            if (ResultCode = 11) then begin
                ResponseMessage := ''; // Silent error downstream
                exit(false);
            end;

        until (ResultCode = 0);

        //fetch correct quantity

        Commit();

        exit(true);
    end;

    procedure CreatePOSLinesForReservationRequest(TicketToken: Text; POSSale: Record "NPR POS Sale")
    var
        TMTicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleLineRec: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);

        TMTicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TMTicketReservationReq.SetRange("Session Token ID", TicketToken);
        TMTicketReservationReq.FindSet(true);

        POSSaleLine.SetUsePresetLineNo(true);

        repeat
            POSSaleLine.GetNewSaleLine(POSSaleLineRec);
            LineNo += 10000;

            POSSaleLineRec."Line Type" := POSSaleLineRec."Line Type"::Item;
            POSSaleLineRec."No." := TMTicketReservationReq."Item No.";
            POSSaleLineRec."Variant Code" := TMTicketReservationReq."Variant Code";
            POSSaleLineRec.Quantity := TMTicketReservationReq.Quantity;
            POSSaleLineRec."Line No." := LineNo;

            TMTicketReservationReq."Line No." := LineNo;
            TMTicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
            TMTicketReservationReq.Modify();
            POSSaleLine.InsertLine(POSSaleLineRec);
        until TMTicketReservationReq.Next() = 0;
    end;

    procedure IsFullyLinkedToTicket(TicketToken: Text; POSSale: Record "NPR POS Sale"): Boolean
    var
        TMTicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);

        TMTicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TMTicketReservationReq.SetRange("Session Token ID", TicketToken);
        TMTicketReservationReq.FindSet();

        repeat
            if not POSSaleLine.Get(POSSale."Register No.", POSSale."Sales Ticket No.", POSSale.Date, POSSaleLine."Sale Type", TMTicketReservationReq."Line No.") then
                exit(false);
            if POSSaleLine."Sales Ticket No." <> TMTicketReservationReq."Receipt No." then
                exit(false);
            if POSSaleLine."Line Type" <> POSSaleLine."Line Type"::Item then
                exit(false);
            if POSSaleLine."No." <> TMTicketReservationReq."Item No." then
                exit(false);
            if POSSaleLine.Quantity <> TMTicketReservationReq.Quantity then
                exit(false);
        until TMTicketReservationReq.Next() = 0;

        exit(true);
    end;
}

