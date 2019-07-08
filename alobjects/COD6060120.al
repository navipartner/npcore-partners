codeunit 6060120 "TM Ticket Notify Participant"
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016
    // TM1.17/TSA/20160916  CASE 251883 Added SMS Option
    // TM1.17/TSA/20160930  CASE 254019 Fixed pressing cancel in ticket holder dialog.
    // TM1.23/TSA /20170725 CASE 284752 Copy Attributes to all reservation lines
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018


    trigger OnRun()
    begin
    end;

    var
        SEND_DIALOG: Label 'Sending: @1@@@@@@@@@@@@@@@@@@';
        NOT_IMPLEMENTED: Label 'Case %1 %2 is not implemented.';
        CONFIRM_SEND_NOTIFICATION: Label 'Do you want to send %1 pending notifications?';
        INVALID: Label 'Invalid %1';
        NO_SMS_TEMPLATE: Label 'Template for table %1 not found amoung SMS Templates.';

    procedure NotifyRecipients(var TicketParticipantWks: Record "TM Ticket Participant Wks.")
    var
        TicketParticipantWks3: Record "TM Ticket Participant Wks.";
        TicketParticipantWks2: Record "TM Ticket Participant Wks.";
        Success: Boolean;
        ResponseMessage: Text;
        MaxCount: Integer;
        Current: Integer;
        Window: Dialog;
    begin

        TicketParticipantWks.SetFilter ("Notification Send Status", '=%1', TicketParticipantWks."Notification Send Status"::PENDING);
        TicketParticipantWks.SetFilter (Blocked, '=%1', false);

        if  (TicketParticipantWks.FindSet ()) then begin
          MaxCount := TicketParticipantWks.Count ();

          if (not Confirm (CONFIRM_SEND_NOTIFICATION, true, MaxCount)) then
            exit;

          Current := 0;
          if (GuiAllowed) then
            Window.Open (SEND_DIALOG);

          repeat

            TicketParticipantWks2.Get (TicketParticipantWks."Entry No.");
            TicketParticipantWks2."Notification Send Status" := TicketParticipantWks2."Notification Send Status"::FAILED;

            case TicketParticipantWks."Notification Method" of
              TicketParticipantWks."Notification Method"::NA  :
                begin
                  TicketParticipantWks2."Notification Send Status" := TicketParticipantWks2."Notification Send Status"::NOT_SENT;
                  ResponseMessage := StrSubstNo (INVALID, TicketParticipantWks.FieldCaption ("Notification Method"));
                end;

              TicketParticipantWks."Notification Method"::EMAIL :
                begin
                  if (SendMail (TicketParticipantWks, ResponseMessage)) then
                    TicketParticipantWks2."Notification Send Status" := TicketParticipantWks."Notification Send Status"::SENT;
                end;

              TicketParticipantWks."Notification Method"::SMS :
                begin
                  if (SendSms (TicketParticipantWks, ResponseMessage)) then
                    TicketParticipantWks2."Notification Send Status" := TicketParticipantWks."Notification Send Status"::SENT;
                end;


              else Error (NOT_IMPLEMENTED, TicketParticipantWks.FieldCaption ("Notification Method"), TicketParticipantWks."Notification Method");
            end;

            TicketParticipantWks2."Notification Sent At" := CurrentDateTime ();
            TicketParticipantWks2."Notification Sent By User" := UserId;
            TicketParticipantWks2."Failed With Message" := CopyStr (ResponseMessage, 1, MaxStrLen (TicketParticipantWks2."Failed With Message"));
            TicketParticipantWks2.Modify ();
            Commit;

            if (GuiAllowed) then
              Window.Update (1, Round (Current/MaxCount*10000,1));
            Current += 1;

          until (TicketParticipantWks.Next () = 0);

          if (GuiAllowed) then
            Window.Close ();

        end;
    end;

    local procedure SendMail(TicketParticipantWks: Record "TM Ticket Participant Wks.";var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "E-mail Management";
    begin

        if (TicketParticipantWks."Notification Address" = '') then begin
          ResponseMessage := StrSubstNo (INVALID, TicketParticipantWks.FieldCaption ("Notification Address"));
          exit (false);
        end;

        RecordRef.GetTable (TicketParticipantWks);
        ResponseMessage := EMailMgt.SendEmail(RecordRef, TicketParticipantWks."Notification Address", true);
        exit (ResponseMessage = '');
    end;

    local procedure SendSms(TicketParticipantWks: Record "TM Ticket Participant Wks.";var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "SMS Management";
        SMSTemplateHeader: Record "SMS Template Header";
        SMSMessage: Text;
    begin

        ResponseMessage := '';

        if (TicketParticipantWks."Notification Address" = '') then begin
          ResponseMessage := StrSubstNo (INVALID, TicketParticipantWks.FieldCaption ("Notification Address"));
          exit (false);
        end;

        if SMSManagement.FindTemplate (TicketParticipantWks, SMSTemplateHeader) then begin
          SMSMessage := SMSManagement.MakeMessage (SMSTemplateHeader, TicketParticipantWks);
          SMSManagement.SendSMS (TicketParticipantWks."Notification Address", SMSTemplateHeader.Description, SMSMessage);
        end else
          ResponseMessage := StrSubstNo (NO_SMS_TEMPLATE, TicketParticipantWks.TableCaption);

        exit (ResponseMessage = '');
    end;

    local procedure "--"()
    begin
    end;

    procedure AquireTicketParticipant(Token: Text[100];SuggestNotificationMethod: Option NA,EMAIL,SMS;SuggestNotificationAddress: Text[100]): Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketReservationRequest2: Record "TM Ticket Reservation Request";
        DisplayTicketParticipant: Page "TM Ticket Aquire Participant";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketNo: Code[20];
        Ticket: Record "TM Ticket";
        TicketAccessEntry: Record "TM Ticket Access Entry";
        Admission: Record "TM Admission";
        TicketAdmissionBOM: Record "TM Ticket Admission BOM";
        RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AdmissionCode: Code[20];
        AttributeManagement: Codeunit "NPR Attribute Management";
    begin

        if (not (TicketRequestManager.GetTokenTicket (Token, TicketNo))) then
          exit (false);

        if (not Ticket.Get (TicketNo)) then
          exit (false);

        TicketAccessEntry.SetFilter ("Ticket No.", '=%1', Ticket."No.");
        if (not TicketAccessEntry.FindSet ()) then
          exit (false);

        RequireParticipantInformation := RequireParticipantInformation::NOT_REQUIRED;
        repeat
          Admission.Get (TicketAccessEntry."Admission Code");
          if (RequireParticipantInformation < Admission."Ticketholder Notification Type") then begin
            RequireParticipantInformation := Admission."Ticketholder Notification Type";
            AdmissionCode := Admission."Admission Code";
          end;
        until (TicketAccessEntry.Next () = 0);

        //-TM1.38 [332109]
        // Check if eTicket
        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then begin
          TicketAdmissionBOM.SetFilter ("Item No.", '=%1', Ticket."Item No.");
          TicketAdmissionBOM.SetFilter ("Variant Code", '=%1', Ticket."Variant Code");
          TicketAdmissionBOM.SetFilter ("Publish As eTicket", '=%1', true);
          if (TicketAdmissionBOM.FindFirst ()) then begin
            AdmissionCode := TicketAdmissionBOM."Admission Code";
            SuggestNotificationMethod := SuggestNotificationMethod::SMS;
            if (SuggestNotificationAddress = '') then
              RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
          end;
        end;
        //+TM1.38 [332109]

        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
          exit (false);

        TicketReservationRequest.Reset ();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset ();
        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);
        TicketReservationRequest.FindSet ();

        DisplayTicketParticipant.SetTableView (TicketReservationRequest);
        DisplayTicketParticipant.LookupMode(true);
        DisplayTicketParticipant.Editable(true);

        DisplayTicketParticipant.SetAdmissionCode (AdmissionCode);
        DisplayTicketParticipant.SetDefaultNotification (SuggestNotificationMethod, SuggestNotificationAddress);

        // 2 contains the original
        TicketReservationRequest2.Get (TicketReservationRequest."Entry No.");
        PageAction := DisplayTicketParticipant.RunModal ();

        // Pick up the change
        if (PageAction = ACTION::LookupOK) then
          TicketReservationRequest2.Get (TicketReservationRequest."Entry No.");

        TicketReservationRequest.FindSet ();
        repeat
          TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
          TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
          TicketReservationRequest.Modify ();

          //-TM1.23 [284752]
          AttributeManagement.CopyEntryAttributeValue (DATABASE::"TM Ticket Reservation Request", TicketReservationRequest2."Entry No.", TicketReservationRequest."Entry No.");
          //+TM1.23 [284752]

        until (TicketReservationRequest.Next () = 0);

        exit (PageAction = ACTION::LookupOK);
    end;
}

