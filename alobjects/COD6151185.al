codeunit 6151185 "MM Sponsorship Ticket Mgmt."
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version
    // MM1.42/TSA/20200122  CASE 382728 Transport MM1.43 - 22 January 2020


    trigger OnRun()
    begin

        NotifyRecipients ();
    end;

    var
        TICKET_NOT_CREATED: Label 'No sponsorship tickets was created, due to "On Demand" setup.';

    procedure NotifyRecipients()
    begin

        NotifyPendingRecipients ();
    end;

    procedure NotifyRecipient(SponsorshipTicketEntryNo: Integer)
    begin

        DoNotifyRecipient (SponsorshipTicketEntryNo);
    end;

    local procedure MakeTickets(FailWithError: Boolean;MembershipRole: Record "MM Membership Role";var SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";var ResponseMessage: Text): Boolean
    begin

        SponsorshipTicketSetup.FindSet ();
        repeat

          if (not MakeTicket (MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then begin
            if (FailWithError) then
              Error (ResponseMessage);

            asserterror Error (ResponseMessage);
            exit (false);
          end;
        until (SponsorshipTicketSetup.Next () = 0);

        exit (true);
    end;

    local procedure MakeTicket(MembershipRole: Record "MM Membership Role";SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";var ResponseMessage: Text): Boolean
    var
        Ticket: Record "TM Ticket";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Member: Record "MM Member";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        Token: Text;
    begin

        Token := TicketRequestManager.GetNewToken ();
        Member.Get (MembershipRole."Member Entry No.");

        //-MM1.42 [382728]
        //CreateTicketRequest (Token, Member, SponsorshipTicketSetup);
        CreateTicketRequest (Token, MembershipRole, SponsorshipTicketSetup);
        //+MM1.42 [382728]

        if (0 <> TicketRequestManager.IssueTicketFromReservationToken (Token, false, ResponseMessage)) then begin
          TicketRequestManager.DeleteReservationRequest (Token, true);
          exit (false);
        end;

        LogSponsorshipTickets (Token, MembershipRole, SponsorshipTicketSetup);

        exit (true);
    end;

    local procedure CreateTicketRequest(Token: Text;MembershipRole: Record "MM Membership Role";SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup")
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        MembershipManagement: Codeunit "MM Membership Management";
        MemberTicketManager: Codeunit "MM Member Ticket Manager";
        TicketSetup: Record "TM Ticket Setup";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        Method: Code[10];
        Address: Text[200];
    begin

        MembershipRole.CalcFields ("External Member No.");

        TicketAdmissionBOM.SetFilter ("Item No.", '=%1', SponsorshipTicketSetup."Item No.");
        TicketAdmissionBOM.SetFilter ("Variant Code", '=%1', SponsorshipTicketSetup."Variant Code");
        TicketAdmissionBOM.FindSet ();
        repeat
          Admission.Get (TicketAdmissionBOM."Admission Code");
          TicketReservationRequest."Entry No." := 0;
          TicketReservationRequest."Session Token ID" := Token;

          //-MM1.42 [382728]
          //  TicketReservationRequest.Quantity := SponsorshipTicketSetup.Quantity;
          //
          //  TicketReservationRequest."External Item Code" := TicketRequestManager.GetExternalNo (SponsorshipTicketSetup."Item No.", SponsorshipTicketSetup."Variant Code");
          //  TicketReservationRequest."Item No." := SponsorshipTicketSetup."Item No.";
          //  TicketReservationRequest."Variant Code" := SponsorshipTicketSetup."Variant Code";
          //
          //  TicketReservationRequest."Admission Code" := TicketAdmissionBOM."Admission Code";
          //  TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
          //  IF (TicketReservationRequest."Admission Description" = '') THEN
          //    TicketReservationRequest."Admission Description" := Admission.Description;
          //  TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::PREPAID;
          //
          //  CASE Member."Notification Method" OF
          //    Member."Notification Method"::EMAIL :
          //      BEGIN
          //        TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL;
          //        TicketReservationRequest."Notification Address" := Member."E-Mail Address";
          //      END;
          //    Member."Notification Method"::SMS :
          //      BEGIN
          //        TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;
          //        TicketReservationRequest."Notification Address" := Member."Phone No.";
          //      END;
          //    ELSE BEGIN
          //      TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::NA;
          //      TicketReservationRequest."Notification Address" := '';
          //    END;
          //  END;
          //  TicketReservationRequest."External Member No." := Member."External Member No.";

          MemberTicketManager.PrefillTicketRequest (MembershipRole."Member Entry No.", MembershipRole."Membership Entry No.",
            TicketAdmissionBOM."Item No.", TicketAdmissionBOM."Variant Code", TicketAdmissionBOM."Admission Code", TicketReservationRequest);

          if (TicketAdmissionBOM."Admission Description" <> '') then
            TicketReservationRequest."Admission Description" := TicketAdmissionBOM."Admission Description";
          TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::PREPAID;
          TicketReservationRequest.Quantity := SponsorshipTicketSetup.Quantity;
          //+MM1.42 [382728]

          TicketReservationRequest."External Order No." := '';
          TicketReservationRequest."Customer No." := '';

          TicketReservationRequest."Created Date Time" := CurrentDateTime;
          TicketReservationRequest.Insert ();
        until (TicketAdmissionBOM.Next () = 0);
        Commit;
    end;

    local procedure FinalizeTicketReservation(FailWithError: Boolean;MembershipRole: Record "MM Membership Role";var SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";var ResponseMessage: Text): Boolean
    var
        SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";
        SponsorshipTicketEntryWork: Record "MM Sponsorship Ticket Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
        Member: Record "MM Member";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        MembershipManagement: Codeunit "MM Membership Management";
        FromDate: Date;
        UntilDate: Date;
    begin

        SponsorshipTicketEntry.SetCurrentKey ("Membership Entry No.");
        SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
        SponsorshipTicketEntry.SetFilter (Status, '=%1', SponsorshipTicketEntry.Status::REGISTERED);

        if (not SponsorshipTicketEntry.FindSet ()) then
          exit (false);

        repeat
          TicketReservationRequest.SetCurrentKey ("Session Token ID");
          TicketReservationRequest.SetFilter ("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
          TicketReservationRequest.SetFilter ("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
          if (TicketReservationRequest.FindSet ()) then begin
            repeat
              if (not TicketRequestManager.ConfirmReservationRequest (SponsorshipTicketEntry."Ticket Token", ResponseMessage)) then begin
                if (FailWithError) then
                  Error (ResponseMessage);

                asserterror Error ('');
                exit (false);
              end;
            until (TicketReservationRequest.Next () = 0);
          end;

          // finalize entry
          SponsorshipTicketEntryWork.Get (SponsorshipTicketEntry."Entry No.");

          if (SponsorshipTicketSetup."Delivery Method" = SponsorshipTicketSetup."Delivery Method"::ADMIN_MEMBER) then begin
            Member.Get (MembershipRole."Member Entry No.");
            case Member."Notification Method" of
              Member."Notification Method"::EMAIL : SponsorshipTicketEntryWork."Notification Address" := Member."E-Mail Address";
              Member."Notification Method"::SMS   : SponsorshipTicketEntryWork."Notification Address" := Member."Phone No.";
            end;
          end;

          MembershipManagement.GetMembershipValidDate (MembershipRole."Membership Entry No.", Today, SponsorshipTicketEntryWork."Membership Valid From", SponsorshipTicketEntryWork."Membership Valid Until");
          SponsorshipTicketEntryWork.Status := SponsorshipTicketEntryWork.Status::FINALIZED;

          SponsorshipTicketEntryWork.Modify ();

        until (SponsorshipTicketEntry.Next () = 0);

        exit (true);
    end;

    local procedure LogSponsorshipTickets(Token: Text[100];MembershipRole: Record "MM Membership Role";SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup")
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        Ticket: Record "TM Ticket";
    begin

        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter ("Admission Created", '=%1', true);
        if (not TicketReservationRequest.FindSet ()) then
          exit;

        Member.Get (MembershipRole."Member Entry No.");
        Membership.Get (MembershipRole."Membership Entry No.");

        repeat

          Clear (SponsorshipTicketEntry);

          SponsorshipTicketEntry.Status := SponsorshipTicketEntry.Status::REGISTERED;
          SponsorshipTicketEntry."Membership Code" := Membership."Membership Code";
          case SponsorshipTicketSetup."Event Type" of
            SponsorshipTicketSetup."Event Type"::ONNEW    : SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONNEW;
            SponsorshipTicketSetup."Event Type"::ONRENEW  : SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONRENEW;
            SponsorshipTicketSetup."Event Type"::ONDEMAND : SponsorshipTicketEntry."Event Type" := SponsorshipTicketEntry."Event Type"::ONDEMAND;
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
            Ticket.SetCurrentKey ("Ticket Reservation Entry No.");
            Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Ticket.FindSet ();
            repeat
              SponsorshipTicketEntry."Entry No." := 0;
              SponsorshipTicketEntry."Ticket No." := Ticket."External Ticket No.";
              SponsorshipTicketEntry.Insert ();
            until (Ticket.Next () = 0);
          end else begin
            SponsorshipTicketEntry.Insert ();
          end;

        until (TicketReservationRequest.Next () = 0);
    end;

    local procedure NotifyPendingRecipients()
    var
        SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";
    begin

        SponsorshipTicketEntry.SetFilter ("Notification Send Status", '=%1', SponsorshipTicketEntry."Notification Send Status"::PENDING);
        if (SponsorshipTicketEntry.FindSet ()) then begin
          repeat

            DoNotifyRecipient (SponsorshipTicketEntry."Entry No.");

          until (SponsorshipTicketEntry.Next () = 0);
        end;
    end;

    local procedure DoNotifyRecipient(SponsorshipTicketEntryNo: Integer)
    var
        SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        ResponseMessage: Text;
        SendStatus: Option;
    begin

        SponsorshipTicketEntry.Get (SponsorshipTicketEntryNo);

        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
        if (TicketReservationRequest.FindFirst ()) then begin

          SendStatus := SponsorshipTicketEntry."Notification Send Status"::FAILED;

          if (ExportToTicketServer (SponsorshipTicketEntry, ResponseMessage)) then begin
            if (SponsorshipTicketEntry."Notification Address" = '') then
              SponsorshipTicketEntry."Notification Address" := TicketReservationRequest."Notification Address";

            case TicketReservationRequest."Notification Method" of

              TicketReservationRequest."Notification Method"::EMAIL :
                begin
                  if (SendMail (SponsorshipTicketEntry, ResponseMessage)) then
                    SendStatus := SponsorshipTicketEntry."Notification Send Status"::DELIVERED;
                end;

              TicketReservationRequest."Notification Method"::SMS :
                begin
                  if (SendSMS (SponsorshipTicketEntry, ResponseMessage)) then
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

        SponsorshipTicketEntry."Notification Sent At" := CurrentDateTime ();
        SponsorshipTicketEntry."Notification Sent By User" := UserId;
        SponsorshipTicketEntry."Notification Send Status" := SendStatus;

        SponsorshipTicketEntry."Failed With Message" := CopyStr (ResponseMessage, 1, MaxStrLen (SponsorshipTicketEntry."Failed With Message"));
        SponsorshipTicketEntry.Modify ();
        Commit;
    end;

    local procedure ExportToTicketServer(var SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";var ReasonText: Text): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketSetup: Record "TM Ticket Setup";
        TicketDIYTicketPrint: Codeunit "TM Ticket DIY Ticket Print";
    begin

        ReasonText := 'Invalid filter when exporting to ticket server';
        if (SponsorshipTicketEntry."Ticket Token" = '') then
          exit (false);

        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', SponsorshipTicketEntry."Ticket Token");
        if (not TicketReservationRequest.FindFirst ()) then
          exit (false);

        TicketSetup.Get ();
        TicketSetup.TestField ("Print Server Order URL");

        if (not TicketDIYTicketPrint.GenerateTicketPrint (TicketReservationRequest."Entry No.", true, ReasonText)) then begin
          exit (false);
        end;

        SponsorshipTicketEntry."Ticket URL" := StrSubstNo ('%1%2', TicketSetup."Print Server Ticket URL", SponsorshipTicketEntry."Ticket No.");
        if (SponsorshipTicketEntry."Ticket No." = '') then
          SponsorshipTicketEntry."Ticket URL" := StrSubstNo ('%1%2', TicketSetup."Print Server Order URL", SponsorshipTicketEntry."Ticket Token");

        ReasonText := '';
        exit (true);
    end;

    local procedure SendMail(SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "E-mail Management";
    begin

        RecordRef.GetTable(SponsorshipTicketEntry);

        ResponseMessage := 'E-Mail address is missing.';
        if (SponsorshipTicketEntry."Notification Address" <> '') then
          ResponseMessage := EMailMgt.SendEmail(RecordRef, SponsorshipTicketEntry."Notification Address", true);

        exit (ResponseMessage = '');
    end;

    local procedure SendSMS(SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "SMS Management";
        SMSTemplateHeader: Record "SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(SponsorshipTicketEntry);

        if (SponsorshipTicketEntry."Notification Address" = '') then
          ResponseMessage := 'Phone number is missing.';

        if (SponsorshipTicketEntry."Notification Address" <> '') then begin
          Commit;
          ResponseMessage := 'Template not found.';
          if (SMSManagement.FindTemplate (RecordRef, SMSTemplateHeader)) then begin
            SmsBody := SMSManagement.MakeMessage (SMSTemplateHeader, SponsorshipTicketEntry);
            SMSManagement.SendSMS (SponsorshipTicketEntry."Notification Address", SMSTemplateHeader."Alt. Sender", SmsBody);
            ResponseMessage := '';
          end;
        end;

        exit (ResponseMessage = '');
    end;

    procedure IssueAdHocTicket(MembershipEntryNo: Integer;var ResponseMessage: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";
        SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry";
        SponsorshipTicketEntryPage: Page "MM Sponsorship Ticket Entry";
        SkipTicketCreate: Boolean;
        LastEntryNo: Integer;
    begin

        Membership.Get (MembershipEntryNo);
        ResponseMessage := 'On Demand Sponsorship tickets not setup for this membership.';

        SponsorshipTicketSetup.SetFilter ("Membership Code", '=%1', Membership."Membership Code");
        SponsorshipTicketSetup.SetFilter (Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', Membership."External Membership No.");
        SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONDEMAND);
        if (SponsorshipTicketSetup.IsEmpty ()) then
          SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty ()) then
          exit (false);

        SponsorshipTicketEntry.Reset ();
        SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (SponsorshipTicketEntry.FindLast ()) then
          LastEntryNo := SponsorshipTicketEntry."Entry No.";

        SponsorshipTicketSetup.FindSet ();
        repeat
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
          MembershipRole.SetFilter (Blocked, '=%1', false);
          MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
          if (not MembershipRole.FindFirst ()) then
            exit (false);

          SkipTicketCreate := false;
          if (Format (SponsorshipTicketSetup."Once Per Period (On Demand)") <> '') then begin
            SponsorshipTicketEntry.Reset ();
            SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
            SponsorshipTicketEntry.SetFilter ("Event Type", '=%1', SponsorshipTicketEntry."Event Type"::ONDEMAND);
            SponsorshipTicketEntry.SetFilter ("Setup Line No.", '=%1', SponsorshipTicketSetup."Line No.");
            if (SponsorshipTicketEntry.FindLast ()) then begin
              SkipTicketCreate := (CalcDate (SponsorshipTicketSetup."Once Per Period (On Demand)", DT2Date (SponsorshipTicketEntry."Created At")) > Today);
              Message ('Date %1 (%3) - skip %2', CalcDate (SponsorshipTicketSetup."Once Per Period (On Demand)", DT2Date (SponsorshipTicketEntry."Created At")), SkipTicketCreate, SponsorshipTicketEntry."Created At");
            end;
          end;

          ResponseMessage := '';

          if (not SkipTicketCreate) then begin
            if (not MakeTicket (MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then
              Error (ResponseMessage);

            FinalizeTicketReservation (true, MembershipRole, SponsorshipTicketSetup, ResponseMessage);

            if (SponsorshipTicketSetup."Delivery Method" = SponsorshipTicketSetup."Delivery Method"::ADMIN_MEMBER) then begin
              SponsorshipTicketEntry.Reset ();
              SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
              SponsorshipTicketEntry.SetFilter ("Notification Send Status", '=%1', SponsorshipTicketEntry."Notification Send Status"::PENDING);
              if (SponsorshipTicketEntry.FindSet ()) then begin
                repeat
                  NotifyRecipient (SponsorshipTicketEntry."Entry No.");
                until (SponsorshipTicketEntry.Next () = 0);
              end;
            end;
          end;

        until (SponsorshipTicketSetup.Next () = 0);

        SponsorshipTicketEntry.Reset ();
        SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        SponsorshipTicketEntry.SetFilter ("Notification Send Status", '<>%1', SponsorshipTicketEntry."Notification Send Status"::DELIVERED);
        if (not SponsorshipTicketEntry.IsEmpty ()) then begin
          SponsorshipTicketEntryPage.SetTableView (SponsorshipTicketEntry);
          SponsorshipTicketEntryPage.Run ();
        end;

        SponsorshipTicketEntry.Reset ();
        SponsorshipTicketEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (SponsorshipTicketEntry.FindLast ()) then begin
          if (LastEntryNo = SponsorshipTicketEntry."Entry No.") then begin
            ResponseMessage := TICKET_NOT_CREATED;
            exit (false);
          end;
        end;


        ResponseMessage := '';
        exit (true);
    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060127, 'OnAfterMemberCreateEvent', '', true, true)]
    local procedure OnAfterMemberCreateEvent(var Membership: Record "MM Membership";var Member: Record "MM Member")
    var
        MembershipRole: Record "MM Membership Role";
        SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";
        ResponseMessage: Text;
    begin

        // When first admin member is created, we check if there are sponsorship tickets to be created.
        SponsorshipTicketSetup.SetFilter ("Membership Code", '=%1', Membership."Membership Code");
        SponsorshipTicketSetup.SetFilter (Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', Membership."External Membership No.");
        SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONNEW);
        if (SponsorshipTicketSetup.IsEmpty ()) then
          SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty ()) then
          exit;

        // Only when adding first member
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.Count <> 1) then
          exit;

        MembershipRole.Get (Membership."Entry No.", Member."Entry No.");
        if (MembershipRole."Member Role" <> MembershipRole."Member Role"::ADMIN) then
          exit;

        SponsorshipTicketSetup.FindSet ();

        MakeTickets (true, MembershipRole, SponsorshipTicketSetup, ResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060127, 'OnAfterInsertMembershipEntry', '', true, true)]
    local procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "MM Membership Entry")
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";
        ResponseMessage: Text;
    begin


        // When sponsorship is active for membership
        // New membership - activate created tickets
        // On Renew - create and activate tickets.
        // When first admin member is created, we check if there are sponsorship tickets to be created.
        SponsorshipTicketSetup.Reset ();
        case MembershipEntry.Context of
          MembershipEntry.Context::NEW :       SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONNEW);
          MembershipEntry.Context::RENEW :     SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONRENEW);
          MembershipEntry.Context::AUTORENEW : SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', SponsorshipTicketSetup."Event Type"::ONRENEW);
          else
            exit;
        end;

        Membership.Get (MembershipEntry."Membership Entry No.");

        SponsorshipTicketSetup.SetFilter ("Membership Code", '=%1', MembershipEntry."Membership Code");
        SponsorshipTicketSetup.SetFilter (Blocked, '=%1', false);
        SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', Membership."External Membership No.");
        if (SponsorshipTicketSetup.IsEmpty ()) then
          SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', '');

        if (SponsorshipTicketSetup.IsEmpty ()) then
          exit;

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (not MembershipRole.FindFirst ()) then
          exit;

        SponsorshipTicketSetup.FindFirst ();

        case MembershipEntry.Context of
          MembershipEntry.Context::NEW :
            FinalizeTicketReservation (true, MembershipRole, SponsorshipTicketSetup, ResponseMessage);

          MembershipEntry.Context::RENEW,
          MembershipEntry.Context::AUTORENEW :
            if (MakeTickets (true, MembershipRole, SponsorshipTicketSetup, ResponseMessage)) then
              FinalizeTicketReservation (true, MembershipRole, SponsorshipTicketSetup, ResponseMessage);
        end;
    end;
}

