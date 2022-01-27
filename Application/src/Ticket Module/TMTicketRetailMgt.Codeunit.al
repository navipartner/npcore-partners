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
                AquireTicketParticipant(Token, ExternalMemberNo);

                Commit();
                exit(true); // nothing to confirm;
            end;
        end;

        Commit();
        ResponseCode := -1;
        ResponseMessage := ABORTED;
        if (AquireTicketAdmissionSchedule(Token, SaleLinePOS, UpdateSalesLine, ResponseMessage)) then begin
            ResponseMessage := '';
            ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
        end;

        if (ResponseCode = 0) then begin

            Commit();
            AquireTicketParticipant(Token, ExternalMemberNo);

            Commit();
            exit(true);
        end;

        exit(false);
    end;

    procedure AquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "NPR POS Sale Line"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketeservationRequest: Page "NPR TM Ticket Make Reserv.";
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
                AdmissionScheduleMgt.CreateAdmissionSchedule(TicketReservationRequest."Admission Code", false, Today());
        until (TicketReservationRequest.Next() = 0);
        Commit();

        if (not HaveSalesLine) then begin
            // Get the ticket item from token line instead
            if (TicketReservationRequest.FindFirst()) then
                TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", SaleLinePOS."No.", SaleLinePOS."Variant Code", ResolvedByTable);
        end;

        ResultCode := 0;
        repeat
            Clear(DisplayTicketeservationRequest);
            DisplayTicketeservationRequest.LoadTicketRequest(Token);
            DisplayTicketeservationRequest.SetTicketItem(SaleLinePOS."No.", SaleLinePOS."Variant Code");
            DisplayTicketeservationRequest.AllowQuantityChange(HaveSalesLine);
            DisplayTicketeservationRequest.LookupMode(true);
            DisplayTicketeservationRequest.Editable(true);

            if (ResultCode <> 0) then
                if (not Confirm(SCHEDULE_ERROR, true, ResponseMessage)) then
                    exit(false);

            PageAction := DisplayTicketeservationRequest.RunModal();
            if (PageAction <> Action::LookupOK) then begin
                ResponseMessage := ABORTED;
                exit(false);
            end;

            ResultCode := DisplayTicketeservationRequest.FinalizeReservationRequest(false, ResponseMessage);
            if (ResultCode = 11) then begin
                ResponseMessage := ''; // Silent error downstream
                exit(false);
            end;

        until (ResultCode = 0);

        if (HaveSalesLine) then begin
            DisplayTicketeservationRequest.GetChangedTicketQuantity(NewQuantity);
            SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
            SaleLinePOS.Validate(Quantity, NewQuantity);
            SaleLinePOS.Modify();
            Commit();
        end;

        exit(true);
    end;

    procedure AquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
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
}

