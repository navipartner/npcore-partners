codeunit 6151185 "NPR MM Sponsorship Ticket Mgt"
{

    trigger OnRun()
    begin

        NotifyRecipients();
    end;

    var
        TICKET_NOT_CREATED: Label 'No sponsorship tickets was created, due to "On Demand" setup.';

    procedure NotifyRecipients()
    begin

        NotifyPendingRecipients();
    end;

    procedure NotifyRecipient(SponsorshipTicketEntryNo: Integer)
    begin

        DoNotifyRecipient(SponsorshipTicketEntryNo);
    end;

    local procedure MakeTickets(MembershipRole: Record "NPR MM Membership Role"; var SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup"; var ResponseMessage: Text): Boolean
    begin

        SponsorshipTicketSetup.FindSet();
        repeat

            if (not MakeTicket(MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then
                Error(ResponseMessage);

        until (SponsorshipTicketSetup.Next() = 0);

        exit(true);
    end;

    local procedure MakeTicket(MembershipRole: Record "NPR MM Membership Role"; SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup"; var ResponseMessage: Text): Boolean
    var
        Member: Record "NPR MM Member";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token: Text;
    begin

        Token := TicketRequestManager.GetNewToken();
        Member.Get(MembershipRole."Member Entry No.");

        CreateTicketRequest(Token, MembershipRole, SponsorshipTicketSetup);

        if (0 <> TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage)) then begin
            TicketRequestManager.DeleteReservationRequest(Token, true);
            exit(false);
        end;

        LogSponsorshipTickets(Token, MembershipRole, SponsorshipTicketSetup);

        exit(true);
    end;

    local procedure CreateTicketRequest(Token: Text; MembershipRole: Record "NPR MM Membership Role"; SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup")
    var
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
    begin

        MembershipRole.CalcFields("External Member No.");

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', SponsorshipTicketSetup."Item No.");
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', SponsorshipTicketSetup."Variant Code");
        TicketAdmissionBOM.FindSet();
        repeat
            Admission.Get(TicketAdmissionBOM."Admission Code");
            TicketReservationRequest."Entry No." := 0;
            TicketReservationRequest."Session Token ID" := Token;

            MemberTicketManager.PrefillTicketRequest(MembershipRole."Member Entry No.", MembershipRole."Membership Entry No.",
              TicketAdmissionBOM."Item No.", TicketAdmissionBOM."Variant Code", TicketAdmissionBOM."Admission Code", TicketReservationRequest);

            if (TicketAdmissionBOM."Admission Description" <> '') then
                TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
            TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::PREPAID;
            TicketReservationRequest.Quantity := SponsorshipTicketSetup.Quantity;

            TicketReservationRequest."External Order No." := '';
            TicketReservationRequest."Customer No." := '';

            TicketReservationRequest."Created Date Time" := CurrentDateTime;
            TicketReservationRequest.Insert();
        until (TicketAdmissionBOM.Next() = 0);
        Commit();
    end;

    local procedure FinalizeTicketReservation(MembershipRole: Record "NPR MM Membership Role"; var SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup"; var ResponseMessage: Text): Boolean
    var
        SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
        SponsorshipTicketEntryWork: Record "NPR MM Sponsors. Ticket Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Member: Record "NPR MM Member";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        SponsorshipTicketEntry.SetCurrentKey("Membership Entry No.");
        SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
        SponsorshipTicketEntry.SetFilter(Status, '=%1', SponsorshipTicketEntry.Status::REGISTERED);

        if (not SponsorshipTicketEntry.FindSet()) then
            exit(false);

        repeat
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    if (not TicketRequestManager.ConfirmReservationRequest(SponsorshipTicketEntry."Ticket Token", ResponseMessage)) then
                        Error(ResponseMessage);
                until (TicketReservationRequest.Next() = 0);
            end;

            // finalize entry
            SponsorshipTicketEntryWork.Get(SponsorshipTicketEntry."Entry No.");

            if (SponsorshipTicketSetup."Delivery Method" = SponsorshipTicketSetup."Delivery Method"::ADMIN_MEMBER) then begin
                Member.Get(MembershipRole."Member Entry No.");
                case Member."Notification Method" of
                    Member."Notification Method"::EMAIL:
                        SponsorshipTicketEntryWork."Notification Address" := Member."E-Mail Address";
                    Member."Notification Method"::SMS:
                        SponsorshipTicketEntryWork."Notification Address" := Member."Phone No.";
                end;
            end;

            MembershipManagement.GetMembershipValidDate(MembershipRole."Membership Entry No.", Today, SponsorshipTicketEntryWork."Membership Valid From", SponsorshipTicketEntryWork."Membership Valid Until");
            SponsorshipTicketEntryWork.Status := SponsorshipTicketEntryWork.Status::FINALIZED;

            SponsorshipTicketEntryWork.Modify();

        until (SponsorshipTicketEntry.Next() = 0);

        exit(true);
    end;

    local procedure LogSponsorshipTickets(Token: Text[100]; MembershipRole: Record "NPR MM Membership Role"; SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup")
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        Ticket: Record "NPR TM Ticket";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Admission Created", '=%1', true);
        if (not TicketReservationRequest.FindSet()) then
            exit;

        Member.Get(MembershipRole."Member Entry No.");
        Membership.Get(MembershipRole."Membership Entry No.");

        repeat

            Clear(SponsorshipTicketEntry);

            SponsorshipTicketEntry.Status := SponsorshipTicketEntry.Status::REGISTERED;
            SponsorshipTicketEntry."Membership Code" := Membership."Membership Code";
            case SponsorshipTicketSetup."Event Type" of
                SponsorshipTicketSetup."Event Type"::ONNEW:
                    SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONNEW;
                SponsorshipTicketSetup."Event Type"::ONRENEW:
                    SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONRENEW;
                SponsorshipTicketSetup."Event Type"::ONDEMAND:
                    SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONDEMAND;
            end;
            SponsorshipTicketEntry."Setup Line No." := SponsorshipTicketSetup."Line No.";

            SponsorshipTicketEntry."Ticket Token" := Token;

            SponsorshipTicketEntry."Membership Entry No." := MembershipRole."Membership Entry No.";
            SponsorshipTicketEntry."Created At" := CurrentDateTime();

            SponsorshipTicketEntry."External Member No." := Member."External Member No.";
            SponsorshipTicketEntry."External Membership No." := Membership."External Membership No.";

            SponsorshipTicketEntry."Phone No." := Member."Phone No.";
            SponsorshipTicketEntry."E-Mail Address" := Member."E-Mail Address";
            SponsorshipTicketEntry."First Name" := Member."First Name";
            SponsorshipTicketEntry."Middle Name" := Member."Middle Name";
            SponsorshipTicketEntry."Last Name" := Member."Last Name";
            SponsorshipTicketEntry."Display Name" := Member."Display Name";
            SponsorshipTicketEntry.Address := Member.Address;
            SponsorshipTicketEntry."Post Code Code" := Member."Post Code Code";
            SponsorshipTicketEntry.City := Member.City;
            SponsorshipTicketEntry."Country Code" := Member."Country Code";
            SponsorshipTicketEntry.Country := Member.Country;
            SponsorshipTicketEntry.Birthday := Member.Birthday;

            SponsorshipTicketEntry."Community Code" := Membership."Community Code";

            SponsorshipTicketEntry."Notification Send Status" := SponsorshipTicketEntry."Notification Send Status"::PENDING;
            if (SponsorshipTicketSetup."Delivery Method" = SponsorshipTicketSetup."Delivery Method"::PICKUP) then
                SponsorshipTicketEntry."Notification Send Status" := SponsorshipTicketEntry."Notification Send Status"::"PICK-UP";

            if (SponsorshipTicketSetup."Distribution Mode" = SponsorshipTicketSetup."Distribution Mode"::INDIVIDUAL) then begin
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                Ticket.FindSet();
                repeat
                    SponsorshipTicketEntry."Entry No." := 0;
                    SponsorshipTicketEntry."Ticket No." := Ticket."External Ticket No.";
                    SponsorshipTicketEntry.Insert();
                until (Ticket.Next() = 0);
            end else begin
                SponsorshipTicketEntry.Insert();
            end;

        until (TicketReservationRequest.Next() = 0);
    end;

    local procedure NotifyPendingRecipients()
    var
        SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
    begin

        SponsorshipTicketEntry.SetFilter("Notification Send Status", '=%1', SponsorshipTicketEntry."Notification Send Status"::PENDING);
        if (SponsorshipTicketEntry.FindSet()) then begin
            repeat

                DoNotifyRecipient(SponsorshipTicketEntry."Entry No.");

            until (SponsorshipTicketEntry.Next() = 0);
        end;
    end;

    local procedure DoNotifyRecipient(SponsorshipTicketEntryNo: Integer)
    var
        SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ResponseMessage: Text;
        SendStatus: Option;
    begin

        SponsorshipTicketEntry.Get(SponsorshipTicketEntryNo);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
        if (TicketReservationRequest.FindFirst()) then begin

            SendStatus := SponsorshipTicketEntry."Notification Send Status"::FAILED;

            if (ExportToTicketServer(SponsorshipTicketEntry, ResponseMessage)) then begin
                if (SponsorshipTicketEntry."Notification Address" = '') then
                    SponsorshipTicketEntry."Notification Address" := TicketReservationRequest."Notification Address";

                case TicketReservationRequest."Notification Method" of

                    TicketReservationRequest."Notification Method"::EMAIL:
                        begin
                            if (SendMail(SponsorshipTicketEntry, ResponseMessage)) then
                                SendStatus := SponsorshipTicketEntry."Notification Send Status"::DELIVERED;
                        end;

                    TicketReservationRequest."Notification Method"::SMS:
                        begin
                            if (SendSMS(SponsorshipTicketEntry, ResponseMessage)) then
                                SendStatus := SponsorshipTicketEntry."Notification Send Status"::DELIVERED;
                        end;
                    else begin
                            SendStatus := SponsorshipTicketEntry."Notification Send Status"::NOT_DELIVERED;
                            ResponseMessage := 'Unhandled notification method.';
                        end;
                end;
            end;
        end else begin
            SendStatus := SponsorshipTicketEntry."Notification Send Status"::FAILED;
            ResponseMessage := 'Token not found.';
        end;

        SponsorshipTicketEntry."Notification Sent At" := CurrentDateTime();
        SponsorshipTicketEntry."Notification Sent By User" := UserId;
        SponsorshipTicketEntry."Notification Send Status" := SendStatus;

        SponsorshipTicketEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(SponsorshipTicketEntry."Failed With Message"));
        SponsorshipTicketEntry.Modify();
        Commit();
    end;

    local procedure ExportToTicketServer(var SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry"; var ReasonText: Text): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketDIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin

        ReasonText := 'Invalid filter when exporting to ticket server';
        if (SponsorshipTicketEntry."Ticket Token" = '') then
            exit(false);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
        if (not TicketReservationRequest.FindFirst()) then
            exit(false);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Order URL");

        if (not TicketDIYTicketPrint.GenerateTicketPrint(TicketReservationRequest."Entry No.", true, ReasonText)) then begin
            exit(false);
        end;

        SponsorshipTicketEntry."Ticket URL" := StrSubstNo(PlaceHolderLbl, TicketSetup."Print Server Ticket URL", SponsorshipTicketEntry."Ticket No.");
        if (SponsorshipTicketEntry."Ticket No." = '') then
            SponsorshipTicketEntry."Ticket URL" := StrSubstNo(PlaceHolderLbl, TicketSetup."Print Server Order URL", SponsorshipTicketEntry."Ticket Token");

        ReasonText := '';
        exit(true);
    end;

    local procedure SendMail(SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
    begin

        RecordRef.GetTable(SponsorshipTicketEntry);

        ResponseMessage := 'E-Mail address is missing.';
        if (SponsorshipTicketEntry."Notification Address" <> '') then
            ResponseMessage := EMailMgt.SendEmail(RecordRef, SponsorshipTicketEntry."Notification Address", true);

        exit(ResponseMessage = '');
    end;

    local procedure SendSMS(SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(SponsorshipTicketEntry);

        if (SponsorshipTicketEntry."Notification Address" = '') then
            ResponseMessage := 'Phone number is missing.';

        if (SponsorshipTicketEntry."Notification Address" <> '') then begin
            Commit();
            ResponseMessage := 'Template not found.';
            if (SMSManagement.FindTemplate(RecordRef, SMSTemplateHeader)) then begin
                SmsBody := SMSManagement.MakeMessage(SMSTemplateHeader, SponsorshipTicketEntry);
                SMSManagement.SendSMS(SponsorshipTicketEntry."Notification Address", SMSTemplateHeader."Alt. Sender", SmsBody);
                ResponseMessage := '';
            end;
        end;

        exit(ResponseMessage = '');
    end;

    procedure IssueAdHocTicket(MembershipEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup";
        SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
        SponsorshipTicketEntryPage: Page "NPR MM Sponsor. Ticket Entry";
        SkipTicketCreate: Boolean;
        LastEntryNo: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        ResponseMessage := 'On Demand Sponsorship tickets not setup for this membership.';

        SponsorshipTicketSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        SponsorshipTicketSetup.SetFilter(Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
        SponsorshipTicketSetup.SetFilter("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONDEMAND);
        if (SponsorshipTicketSetup.IsEmpty()) then
            SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty()) then
            exit(false);

        SponsorshipTicketEntry.Reset();
        SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (SponsorshipTicketEntry.FindLast()) then
            LastEntryNo := SponsorshipTicketEntry."Entry No.";

        SponsorshipTicketSetup.FindSet();
        repeat
            MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
            MembershipRole.SetFilter(Blocked, '=%1', false);
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
            if (not MembershipRole.FindFirst()) then
                exit(false);

            SkipTicketCreate := false;
            if (Format(SponsorshipTicketSetup."Once Per Period (On Demand)") <> '') then begin
                SponsorshipTicketEntry.Reset();
                SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                SponsorshipTicketEntry.SetFilter("Event Type", '=%1', SponsorshipTicketEntry."Event Type"::ONDEMAND);
                SponsorshipTicketEntry.SetFilter("Setup Line No.", '=%1', SponsorshipTicketSetup."Line No.");
                if (SponsorshipTicketEntry.FindLast()) then begin
                    SkipTicketCreate := (CalcDate(SponsorshipTicketSetup."Once Per Period (On Demand)", DT2Date(SponsorshipTicketEntry."Created At")) > Today);
                    Message('Date %1 (%3) - skip %2', CalcDate(SponsorshipTicketSetup."Once Per Period (On Demand)", DT2Date(SponsorshipTicketEntry."Created At")), SkipTicketCreate, SponsorshipTicketEntry."Created At");
                end;
            end;

            ResponseMessage := '';

            if (not SkipTicketCreate) then begin
                if (not MakeTicket(MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then
                    Error(ResponseMessage);

                FinalizeTicketReservation(MembershipRole, SponsorshipTicketSetup, ResponseMessage);

                if (SponsorshipTicketSetup."Delivery Method" = SponsorshipTicketSetup."Delivery Method"::ADMIN_MEMBER) then begin
                    SponsorshipTicketEntry.Reset();
                    SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                    SponsorshipTicketEntry.SetFilter("Notification Send Status", '=%1', SponsorshipTicketEntry."Notification Send Status"::PENDING);
                    if (SponsorshipTicketEntry.FindSet()) then begin
                        repeat
                            NotifyRecipient(SponsorshipTicketEntry."Entry No.");
                        until (SponsorshipTicketEntry.Next() = 0);
                    end;
                end;
            end;

        until (SponsorshipTicketSetup.Next() = 0);

        SponsorshipTicketEntry.Reset();
        SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        SponsorshipTicketEntry.SetFilter("Notification Send Status", '<>%1', SponsorshipTicketEntry."Notification Send Status"::DELIVERED);
        if (not SponsorshipTicketEntry.IsEmpty()) then begin
            SponsorshipTicketEntryPage.SetTableView(SponsorshipTicketEntry);
            SponsorshipTicketEntryPage.Run();
        end;

        SponsorshipTicketEntry.Reset();
        SponsorshipTicketEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (SponsorshipTicketEntry.FindLast()) then begin
            if (LastEntryNo = SponsorshipTicketEntry."Entry No.") then begin
                ResponseMessage := TICKET_NOT_CREATED;
                exit(false);
            end;
        end;

        ResponseMessage := '';
        exit(true);
    end;

    procedure OnMembershipPayment(MembershipEntry: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup";
        ResponseMessage: Text;
    begin

        // When sponsorship is active for membership
        // New membership - activate created tickets
        // On Renew - create and activate tickets.
        // When first admin member is created, we check if there are sponsorship tickets to be created.
        SponsorshipTicketSetup.Reset();
        case MembershipEntry.Context of
            MembershipEntry.Context::NEW:
                SponsorshipTicketSetup.SetFilter("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONNEW);
            MembershipEntry.Context::RENEW:
                SponsorshipTicketSetup.SetFilter("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONRENEW);
            MembershipEntry.Context::AUTORENEW:
                SponsorshipTicketSetup.SetFilter("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONRENEW);
            else
                exit;
        end;

        Membership.Get(MembershipEntry."Membership Entry No.");

        SponsorshipTicketSetup.SetFilter("Membership Code", '=%1', MembershipEntry."Membership Code");
        SponsorshipTicketSetup.SetFilter(Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
        if (SponsorshipTicketSetup.IsEmpty()) then
            SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty()) then
            exit;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (not MembershipRole.FindFirst()) then
            exit;

        SponsorshipTicketSetup.FindFirst();

        case MembershipEntry.Context of
            MembershipEntry.Context::NEW:
                FinalizeTicketReservation(MembershipRole, SponsorshipTicketSetup, ResponseMessage);

            MembershipEntry.Context::RENEW,
          MembershipEntry.Context::AUTORENEW:
                if (MakeTickets(MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then
                    FinalizeTicketReservation(MembershipRole, SponsorshipTicketSetup, ResponseMessage);
        end;

    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"NPR MM Membership Events", 'OnAfterMemberCreateEvent', '', true, true)]
    local procedure OnAfterMemberCreateEvent(var Membership: Record "NPR MM Membership"; var Member: Record "NPR MM Member")
    var
        MembershipRole: Record "NPR MM Membership Role";
        SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup";
        ResponseMessage: Text;
    begin

        // When first admin member is created, we check if there are sponsorship tickets to be created.
        SponsorshipTicketSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        SponsorshipTicketSetup.SetFilter(Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
        SponsorshipTicketSetup.SetFilter("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONNEW);
        if (SponsorshipTicketSetup.IsEmpty()) then
            SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty()) then
            exit;

        // Only when adding first member
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.Count() <> 1) then
            exit;

        MembershipRole.Get(Membership."Entry No.", Member."Entry No.");
        if (MembershipRole."Member Role" <> MembershipRole."Member Role"::ADMIN) then
            exit;

        SponsorshipTicketSetup.FindSet();

        MakeTickets(MembershipRole, SponsorshipTicketSetup, ResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"NPR MM Membership Events", 'OnAfterInsertMembershipEntry', '', true, true)]
    local procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "NPR MM Membership Entry")
    begin

        OnMembershipPayment(MembershipEntry);

    end;
}

