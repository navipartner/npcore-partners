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
        TimeSlotDescription: Text[30];
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
            TimeSlotDescription := DisplayTicketReservationRequestPhone.GetDefaultAdmissionScheduleDescription();

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
            TimeSlotDescription := DisplayTicketReservationRequest.GetDefaultAdmissionScheduleDescription();
        end;

        if (HaveSalesLine) then begin
            SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
            SaleLinePOS."Description 2" := TimeSlotDescription;
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
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketUnitPrice: Decimal;
        AddonPrice: Decimal;
        POSSaleLineRec: Record "NPR POS Sale Line";
        LineNo: Integer;
        ExternalLineNumber: Integer;
        ListOfLines: List of [Integer];
        NewUnitPrice: Decimal;
    begin
        POSSession.GetSaleLine(POSSaleLine);

        TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
        TicketReservationReq.SetFilter("Request Status", '=%1', TicketReservationReq."Request Status"::REGISTERED);
        if (TicketReservationReq.IsEmpty()) then
            exit;


        POSSaleLine.SetUsePresetLineNo(true);

        // Find the different orders in the request - will have different line numbers
        TicketReservationReq.Reset();
        TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
        if (TicketReservationReq.FindSet()) then begin
            repeat
                if (not ListOfLines.Contains(TicketReservationReq."Ext. Line Reference No.")) then
                    ListOfLines.Add(TicketReservationReq."Ext. Line Reference No.");
            until (TicketReservationReq.Next() = 0);
        end;


        foreach ExternalLineNumber in ListOfLines do begin
            // Find the main ticket item line
            TicketReservationReq.Reset();
            TicketReservationReq.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
            TicketReservationReq.SetFilter("Session Token ID", '=%1', CopyStr(TicketToken, 1, MaxStrLen(TicketReservationReq."Session Token ID")));
            TicketReservationReq.SetFilter("Ext. Line Reference No.", '=%1', ExternalLineNumber);
            TicketReservationReq.SetFilter("Request Status", '=%1', TicketReservationReq."Request Status"::REGISTERED);
            TicketReservationReq.SetFilter("Primary Request Line", '=%1', true);
            TicketReservationReq.SetFilter("Admission Inclusion", '=%1', TicketReservationReq."Admission Inclusion"::REQUIRED);
            TicketReservationReq.FindFirst();

            TicketReservationReq.TestField("Admission Created");
            POSSaleLine.GetNewSaleLine(POSSaleLineRec);
            LineNo += 10000;

            POSSaleLineRec."Line Type" := POSSaleLineRec."Line Type"::Item;
            POSSaleLineRec."No." := TicketReservationReq."Item No.";
            POSSaleLineRec."Variant Code" := TicketReservationReq."Variant Code";
            POSSaleLineRec.Quantity := TicketReservationReq.Quantity;
            POSSaleLineRec."Description 2" := TicketReservationReq."Scheduled Time Description";
            POSSaleLineRec."Line No." := LineNo;

            TicketReservationReq."Line No." := LineNo;
            TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
            TicketReservationReq.Modify();

            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationReq."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    Ticket."Sales Receipt No." := POSSaleLineRec."Sales Ticket No.";
                    Ticket."Line No." := LineNo;
                    Ticket.Modify();
                until (Ticket.Next() = 0);
            end;

            POSSaleLine.InsertLine(POSSaleLineRec);

            // Update the remaining non-primary required admissions with same receipt number
            TicketReservationReq.SetFilter("Primary Request Line", '=%1', false);
            TicketReservationReq.FindSet();
            repeat
                TicketReservationReq."Line No." := LineNo;
                TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
                TicketReservationReq.Modify();
            until TicketReservationReq.Next() = 0;

            // Each additional experience will have its own sales lines as they are charged on-top of the required experiences
            TicketReservationReq.SetFilter("Admission Inclusion", '=%1', TicketReservationReq."Admission Inclusion"::SELECTED);
            if (TicketReservationReq.FindSet()) then begin
                repeat
                    TicketReservationReq.TestField("Admission Created");

                    POSSaleLine.GetNewSaleLine(POSSaleLineRec);
                    LineNo += 10000;

                    Admission.Get(TicketReservationReq."Admission Code");
                    POSSaleLineRec."Line Type" := POSSaleLineRec."Line Type"::Item;
                    POSSaleLineRec."No." := Admission."Additional Experience Item No.";
                    POSSaleLineRec."Variant Code" := '';
                    POSSaleLineRec.Quantity := TicketReservationReq.Quantity;
                    POSSaleLineRec."Line No." := LineNo;
                    POSSaleLineRec."Description 2" := TicketReservationReq."Scheduled Time Description";
                    POSSaleLine.InsertLine(POSSaleLineRec);

                    if (TicketPrice.CalculateScheduleEntryPrice(POSSaleLineRec."No.", '', TicketReservationReq."Admission Code", TicketReservationReq."External Adm. Sch. Entry No.", POSSaleLineRec."Unit Price", POSSaleLineRec."Price Includes VAT", POSSaleLineRec."VAT %", Today(), Time(), TicketUnitPrice, AddonPrice)) then begin
                        if (TicketUnitPrice <> 0) then
                            NewUnitPrice := TicketUnitPrice + AddonPrice;
                        if (TicketUnitPrice = 0) then
                            NewUnitPrice := POSSaleLineRec."Unit Price" + AddonPrice;
                        if (NewUnitPrice < 0) then
                            NewUnitPrice := 0;
                        POSSaleLineRec.Validate("Unit Price", NewUnitPrice);
                        POSSaleLineRec.UpdateAmounts(POSSaleLineRec);
                        POSSaleLineRec."Eksp. Salgspris" := false;
                        POSSaleLineRec."Custom Price" := false;
                        POSSaleLineRec.Modify();
                    end;

                    TicketReservationReq."Line No." := LineNo;
                    TicketReservationReq."Receipt No." := POSSaleLineRec."Sales Ticket No.";
                    TicketReservationReq.Modify();

                until TicketReservationReq.Next() = 0;
            end;
        end;
    end;

}

