codeunit 6060120 "NPR TM Ticket Notify Particpt."
{
    // TM1.16/TSA/20160816  CASE 245004 Transport TM1.16 - 19 July 2016
    // TM1.17/TSA/20160916  CASE 251883 Added SMS Option
    // TM1.17/TSA/20160930  CASE 254019 Fixed pressing cancel in ticket holder dialog.
    // TM1.23/TSA /20170725 CASE 284752 Copy Attributes to all reservation lines
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018
    // TM1.45/TSA /20191101 CASE 374620 Added OnNotifyStakeholder()
    // TM1.45/TSA /20191202 CASE 374620 SendGeneralNotification()
    // TM90.1.46/TSA /20200127 CASE 387138 CreateDiyPrintNotification()
    // TM90.1.46/TSA /20200331 CASE 390657 Added PrePaid and PostPaid as confirmed payment for stakeholder notifications


    trigger OnRun()
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin

        //-TM1.45 [374620]
        TicketNotificationEntry.Reset();
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::STAKEHOLDER);
        TicketNotificationEntry.SetFilter("Notification Process Method", '=%1', TicketNotificationEntry."Notification Process Method"::BATCH);
        SendGeneralNotification(TicketNotificationEntry);
        //+TM1.45 [374620]

        //-#380754 [380754]
        TicketNotificationEntry.Reset();
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::WAITINGLIST);
        TicketNotificationEntry.SetFilter("Notification Process Method", '=%1', TicketNotificationEntry."Notification Process Method"::BATCH);
        SendGeneralNotification(TicketNotificationEntry);
        //+#380754 [380754]
    end;

    var
        SEND_DIALOG: Label 'Sending: @1@@@@@@@@@@@@@@@@@@';
        NOT_IMPLEMENTED: Label 'Case %1 %2 is not implemented.';
        CONFIRM_SEND_NOTIFICATION: Label 'Do you want to send %1 pending notifications?';
        INVALID: Label 'Invalid %1';
        NO_SMS_TEMPLATE: Label 'Template for table %1 not found amoung SMS Templates.';

    procedure NotifyRecipients(var TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.")
    var
        TicketParticipantWks3: Record "NPR TM Ticket Particpt. Wks.";
        TicketParticipantWks2: Record "NPR TM Ticket Particpt. Wks.";
        Success: Boolean;
        ResponseMessage: Text;
        MaxCount: Integer;
        Current: Integer;
        Window: Dialog;
    begin

        TicketParticipantWks.SetFilter("Notification Send Status", '=%1', TicketParticipantWks."Notification Send Status"::PENDING);
        TicketParticipantWks.SetFilter(Blocked, '=%1', false);

        if (TicketParticipantWks.FindSet()) then begin
            MaxCount := TicketParticipantWks.Count();

            if (not Confirm(CONFIRM_SEND_NOTIFICATION, true, MaxCount)) then
                exit;

            Current := 0;
            if (GuiAllowed) then
                Window.Open(SEND_DIALOG);

            repeat

                TicketParticipantWks2.Get(TicketParticipantWks."Entry No.");
                TicketParticipantWks2."Notification Send Status" := TicketParticipantWks2."Notification Send Status"::FAILED;

                case TicketParticipantWks."Notification Method" of
                    TicketParticipantWks."Notification Method"::NA:
                        begin
                            TicketParticipantWks2."Notification Send Status" := TicketParticipantWks2."Notification Send Status"::NOT_SENT;
                            ResponseMessage := StrSubstNo(INVALID, TicketParticipantWks.FieldCaption("Notification Method"));
                        end;

                    TicketParticipantWks."Notification Method"::EMAIL:
                        begin
                            if (SendMail(TicketParticipantWks, ResponseMessage)) then
                                TicketParticipantWks2."Notification Send Status" := TicketParticipantWks."Notification Send Status"::SENT;
                        end;

                    TicketParticipantWks."Notification Method"::SMS:
                        begin
                            if (SendSms(TicketParticipantWks, ResponseMessage)) then
                                TicketParticipantWks2."Notification Send Status" := TicketParticipantWks."Notification Send Status"::SENT;
                        end;


                    else
                        Error(NOT_IMPLEMENTED, TicketParticipantWks.FieldCaption("Notification Method"), TicketParticipantWks."Notification Method");
                end;

                TicketParticipantWks2."Notification Sent At" := CurrentDateTime();
                TicketParticipantWks2."Notification Sent By User" := UserId;
                TicketParticipantWks2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketParticipantWks2."Failed With Message"));
                TicketParticipantWks2.Modify();
                Commit;

                if (GuiAllowed) then
                    Window.Update(1, Round(Current / MaxCount * 10000, 1));
                Current += 1;

            until (TicketParticipantWks.Next() = 0);

            if (GuiAllowed) then
                Window.Close();

        end;
    end;

    local procedure SendMail(TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks."; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
    begin

        if (TicketParticipantWks."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketParticipantWks.FieldCaption("Notification Address"));
            exit(false);
        end;

        RecordRef.GetTable(TicketParticipantWks);
        ResponseMessage := EMailMgt.SendEmail(RecordRef, TicketParticipantWks."Notification Address", true);
        exit(ResponseMessage = '');
    end;

    local procedure SendSms(TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks."; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSMessage: Text;
    begin

        ResponseMessage := '';

        if (TicketParticipantWks."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketParticipantWks.FieldCaption("Notification Address"));
            exit(false);
        end;

        if SMSManagement.FindTemplate(TicketParticipantWks, SMSTemplateHeader) then begin
            SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, TicketParticipantWks);
            SMSManagement.SendSMS(TicketParticipantWks."Notification Address", SMSTemplateHeader.Description, SMSMessage);
        end else
            ResponseMessage := StrSubstNo(NO_SMS_TEMPLATE, TicketParticipantWks.TableCaption);

        exit(ResponseMessage = '');
    end;

    local procedure SendMailNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
    begin

        //-TM1.45 [374620]
        if (TicketNotificationEntry."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry.FieldCaption("Notification Address"));
            exit(false);
        end;

        RecordRef.GetTable(TicketNotificationEntry);
        ResponseMessage := EMailMgt.SendEmail(RecordRef, TicketNotificationEntry."Notification Address", true);
        exit(ResponseMessage = '');
        //+TM1.45 [374620]
    end;

    local procedure SendSmsNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSMessage: Text;
    begin

        //-TM1.45 [374620]
        ResponseMessage := '';

        if (TicketNotificationEntry."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry.FieldCaption("Notification Address"));
            exit(false);
        end;

        if SMSManagement.FindTemplate(TicketNotificationEntry, SMSTemplateHeader) then begin
            SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, TicketNotificationEntry);
            SMSManagement.SendSMS(TicketNotificationEntry."Notification Address", SMSTemplateHeader.Description, SMSMessage);
        end else
            ResponseMessage := StrSubstNo(NO_SMS_TEMPLATE, TicketNotificationEntry.TableCaption);

        exit(ResponseMessage = '');
        //+TM1.45 [374620]
    end;

    local procedure "--"()
    begin
    end;

    procedure AquireTicketParticipant(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]): Boolean
    begin

        //-TM90.1.46 [387138] refactored, moved code to local worker
        exit(AquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, false));
        //+TM90.1.46 [387138]
    end;

    procedure AquireTicketParticipantForce(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]; ForceDialog: Boolean): Boolean
    begin

        //-TM90.1.46 [387138]
        exit(AquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, ForceDialog));
        //+TM90.1.46 [387138]
    end;

    local procedure AquireTicketParticipantWorker(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]; ForceDialog: Boolean): Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketParticipant: Page "NPR TM Ticket Aquire Particip.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketNo: Code[20];
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Admission: Record "NPR TM Admission";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AdmissionCode: Code[20];
        AttributeManagement: Codeunit "NPR Attribute Management";
    begin

        //-TM90.1.46 [387138]
        if (not (TicketRequestManager.GetTokenTicket(Token, TicketNo))) then
            exit(false);

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (not TicketAccessEntry.FindSet()) then
            exit(false);

        RequireParticipantInformation := RequireParticipantInformation::NOT_REQUIRED;
        repeat
            Admission.Get(TicketAccessEntry."Admission Code");
            if (RequireParticipantInformation < Admission."Ticketholder Notification Type") then begin
                RequireParticipantInformation := Admission."Ticketholder Notification Type";
                AdmissionCode := Admission."Admission Code";
            end;
        until (TicketAccessEntry.Next() = 0);

        //-TM1.38 [332109]
        // Check if eTicket
        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then begin
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketAdmissionBOM.SetFilter("Publish As eTicket", '=%1', true);
            if (TicketAdmissionBOM.FindFirst()) then begin
                AdmissionCode := TicketAdmissionBOM."Admission Code";
                SuggestNotificationMethod := SuggestNotificationMethod::SMS;
                if (SuggestNotificationAddress = '') then
                    RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
            end;

            //-TM90.1.46 [387138]
            TicketAdmissionBOM.Reset();
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketAdmissionBOM.SetFilter("Publish Ticket URL", '=%1', TicketAdmissionBOM."Publish Ticket URL"::SEND);
            if (TicketAdmissionBOM.FindFirst()) then begin
                AdmissionCode := TicketAdmissionBOM."Admission Code";
                SuggestNotificationMethod := SuggestNotificationMethod::EMAIL;
                if (SuggestNotificationAddress = '') then
                    RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
            end;
            //+TM90.1.46 [387138]

        end;
        //+TM1.38 [332109]

        //-TM90.1.46 [387138]
        //IF (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) THEN
        //  EXIT (FALSE);
        if (not ForceDialog) then
            if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
                exit(false);

        if (AdmissionCode = '') then
            AdmissionCode := Admission."Admission Code";
        //+TM90.1.46 [387138]

        TicketReservationRequest.Reset();
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FilterGroup(0);
        TicketReservationRequest.FindSet();

        DisplayTicketParticipant.SetTableView(TicketReservationRequest);
        DisplayTicketParticipant.LookupMode(true);
        DisplayTicketParticipant.Editable(true);

        DisplayTicketParticipant.SetAdmissionCode(AdmissionCode);
        DisplayTicketParticipant.SetDefaultNotification(SuggestNotificationMethod, SuggestNotificationAddress);

        // 2 contains the original
        TicketReservationRequest2.Get(TicketReservationRequest."Entry No.");
        PageAction := DisplayTicketParticipant.RunModal();

        // Pick up the change
        if (PageAction = ACTION::LookupOK) then
            TicketReservationRequest2.Get(TicketReservationRequest."Entry No.");

        TicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
            TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
            TicketReservationRequest.Modify();

            //-TM1.23 [284752]
            AttributeManagement.CopyEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", TicketReservationRequest2."Entry No.", TicketReservationRequest."Entry No.");
        //+TM1.23 [284752]

        until (TicketReservationRequest.Next() = 0);

        exit(PageAction = ACTION::LookupOK);
        //+TM90.1.46 [387138]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059784, 'OnDetailedTicketEvent', '', true, true)]
    local procedure OnNotifyStakeholder(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        ReserveTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        ReservationConfirmed: Boolean;
    begin

        //-TM1.45 [374620]
        if (DetTicketAccessEntry."External Adm. Sch. Entry No." <= 0) then begin

            //-TM90.1.46 [390657]
            //IF (DetTicketAccessEntry.Type <> DetTicketAccessEntry.Type::PAYMENT) THEN
            //   EXIT;
            if (not (DetTicketAccessEntry.Type in [DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID])) then
                exit;
            //+TM90.1.46 [390657]

            ReserveTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', DetTicketAccessEntry."Ticket Access Entry No.");
            ReserveTicketAccessEntry.SetFilter(Type, '=%1', ReserveTicketAccessEntry.Type::RESERVATION);
            ReserveTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
            if (not ReserveTicketAccessEntry.FindFirst()) then
                exit;

            ReservationConfirmed := DetTicketAccessEntry.Get(ReserveTicketAccessEntry."Entry No.");
        end;

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            exit;

        if (Admission."Stakeholder (E-Mail/Phone No.)" = '') then
            exit;

        if (not Schedule.Get(AdmissionScheduleEntry."Schedule Code")) then
            exit;

        if (Schedule."Notify Stakeholder" = Schedule."Notify Stakeholder"::NA) then
            exit;

        case DetTicketAccessEntry.Type of
            DetTicketAccessEntry.Type::ADMITTED:
                with Schedule do
                    if ("Notify Stakeholder" in ["Notify Stakeholder"::ADMIT, "Notify Stakeholder"::ADMIT_DEPART, "Notify Stakeholder"::ALL]) then
                        CreateStakeholderNotification(Admission, Schedule, AdmissionScheduleEntry, DetTicketAccessEntry);

            DetTicketAccessEntry.Type::DEPARTED:
                with Schedule do
                    if ("Notify Stakeholder" in ["Notify Stakeholder"::ADMIT_DEPART, "Notify Stakeholder"::ALL]) then
                        CreateStakeholderNotification(Admission, Schedule, AdmissionScheduleEntry, DetTicketAccessEntry);

            DetTicketAccessEntry.Type::RESERVATION:
                begin
                    if (DetTicketAccessEntry.Quantity > 0) and (ReservationConfirmed) then
                        with Schedule do
                            if ("Notify Stakeholder" in ["Notify Stakeholder"::RESERVE, "Notify Stakeholder"::RESERVE_CANCEL, "Notify Stakeholder"::ALL]) then
                                CreateStakeholderNotification(Admission, Schedule, AdmissionScheduleEntry, DetTicketAccessEntry);

                    if (DetTicketAccessEntry.Quantity < 0) then
                        with Schedule do // Cancelled reservations are negative
                            if ("Notify Stakeholder" in ["Notify Stakeholder"::RESERVE_CANCEL, "Notify Stakeholder"::ALL]) then
                                CreateStakeholderNotification(Admission, Schedule, AdmissionScheduleEntry, DetTicketAccessEntry);
                end;

            DetTicketAccessEntry.Type::CANCELED:
                ; // Stakeholder notifications are for reservtions only.

            else
                Message('Type %1 is not handled in stakeholder notification.', DetTicketAccessEntry.Type);
        end;

        //+TM1.45 [374620]
    end;

    local procedure CreateStakeholderNotification(Admission: Record "NPR TM Admission"; Schedule: Record "NPR TM Admis. Schedule"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        //-TM1.45 [374620]
        NotificationEntry."Entry No." := 0;
        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::STAKEHOLDER;
        NotificationEntry."Notification Address" := Admission."Stakeholder (E-Mail/Phone No.)";
        NotificationEntry."Date To Notify" := Today;

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";

        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        with DetTicketAccessEntry do
            case Type of
                Type::ADMITTED:
                    NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADMIT;
                Type::DEPARTED:
                    NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::DEPART;
                Type::RESERVATION:
                    begin
                        if (Quantity > 0) then
                            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::RESERVE;
                        if (Quantity < 0) then
                            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE;
                    end;
            end;

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";
        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Quantity To Admit" := TicketReservationRequest.Quantity;

        NotificationEntry."Ticket Holder E-Mail" := TicketReservationRequest."Notification Address";
        NotificationEntry."External Order No." := TicketReservationRequest."External Order No."; //-+#TM1.46 [387138]

        NotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmissionScheduleEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");

        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;
        if (StrPos(Admission."Stakeholder (E-Mail/Phone No.)", '@') > 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

        if (StrLen(DelChr(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::BATCH;
        NotificationEntry.Insert();
        //+TM1.45 [374620]
    end;

    procedure CreateDiyPrintNotification(TicketNo: Code[20]) NotificationEntryNo: Integer
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketSetup: Record "NPR TM Ticket Setup";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin

        //-TM90.1.46 [387138]
        if (not TicketSetup.Get()) then
            exit;

        Ticket.Get(TicketNo);
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter(Default, '=%1', true);
        if (TicketBom.IsEmpty()) then
            TicketBom.SetFilter(Default, '=%1', false);

        if not (TicketBom.FindFirst()) then
            exit;

        if (not Admission.Get(TicketBom."Admission Code")) then
            exit;

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
        if (not TicketAccessEntry.FindFirst()) then
            exit;

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (DetTicketAccessEntry.IsEmpty()) then
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit;

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit;

        NotificationEntry."Entry No." := 0;

        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::TICKETSERVER;
        NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::SALES;
        NotificationEntry."Date To Notify" := Today;

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
        NotificationEntry."Published Ticket URL" := StrSubstNo('%1%2', TicketSetup."Print Server Order URL", TicketReservationRequest."Session Token ID");

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";

        NotificationEntry."Ticket Item No." := Ticket."Item No.";
        NotificationEntry."Ticket Variant Code" := Ticket."Variant Code";
        NotificationEntry."Ticket External Item No." := TicketReservationRequest."External Item Code";
        NotificationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";

        NotificationEntry."Ticket BOM Description" := TicketBom.Description;
        NotificationEntry."Ticket BOM Adm. Description" := TicketBom."Admission Description";
        NotificationEntry."Adm. Location Description" := Admission.Description;
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Quantity To Admit" := TicketReservationRequest.Quantity;

        NotificationEntry."Ticket Holder E-Mail" := TicketReservationRequest."Notification Address";

        NotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmissionScheduleEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");
        NotificationEntry."Event Start Date" := AdmissionScheduleEntry."Admission Start Date";
        NotificationEntry."Event Start Time" := AdmissionScheduleEntry."Admission Start Time";

        NotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";
        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;

        if (StrPos(TicketReservationRequest."Notification Address", '@') > 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

        if (StrLen(DelChr(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::INLINE;
        NotificationEntry.Insert();

        exit(NotificationEntry."Entry No.");
        //+TM90.1.46 [387138]
    end;

    procedure SendGeneralNotification(var TicketNotificationEntryFilters: Record "NPR TM Ticket Notif. Entry")
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketNotificationEntry2: Record "NPR TM Ticket Notif. Entry";
        Window: Dialog;
        ResponseMessage: Text;
        MaxCount: Integer;
        Current: Integer;
    begin

        //-TM1.45 [374620]
        TicketNotificationEntry.CopyFilters(TicketNotificationEntryFilters);
        TicketNotificationEntry.SetFilter("Notification Send Status", '=%1', TicketNotificationEntry."Notification Send Status"::PENDING);

        if (TicketNotificationEntry.FindSet()) then begin
            MaxCount := TicketNotificationEntry.Count();

            Current := 0;
            if (GuiAllowed) then
                Window.Open(SEND_DIALOG);

            repeat

                TicketNotificationEntry2.Get(TicketNotificationEntry."Entry No.");
                TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry2."Notification Send Status"::FAILED;

                case TicketNotificationEntry2."Notification Method" of
                    TicketNotificationEntry2."Notification Method"::NA:
                        begin
                            TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry2."Notification Send Status"::NOT_SENT;
                            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry2.FieldCaption("Notification Method"));
                        end;

                    TicketNotificationEntry2."Notification Method"::EMAIL:
                        begin
                            if (SendMailNotificationEntry(TicketNotificationEntry2, ResponseMessage)) then
                                TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    TicketNotificationEntry2."Notification Method"::SMS:
                        begin
                            if (SendSmsNotificationEntry(TicketNotificationEntry2, ResponseMessage)) then
                                TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    else
                        Error(NOT_IMPLEMENTED, TicketNotificationEntry2.FieldCaption("Notification Method"), TicketNotificationEntry2."Notification Method");
                end;

                TicketNotificationEntry2."Notification Sent At" := CurrentDateTime();
                TicketNotificationEntry2."Notification Sent By User" := UserId;
                TicketNotificationEntry2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry2."Failed With Message"));
                TicketNotificationEntry2.Modify();
                Commit;

                if (GuiAllowed) then
                    Window.Update(1, Round(Current / MaxCount * 10000, 1));
                Current += 1;

            until (TicketNotificationEntry.Next() = 0);

            if (GuiAllowed) then
                Window.Close();

        end;
        //+TM1.45 [374620]
    end;
}

