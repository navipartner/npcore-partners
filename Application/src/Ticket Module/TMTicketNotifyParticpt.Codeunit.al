codeunit 6060120 "NPR TM Ticket Notify Particpt."
{
    trigger OnRun()
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        TicketNotificationEntry.Reset();
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::STAKEHOLDER);
        TicketNotificationEntry.SetFilter("Notification Process Method", '=%1', TicketNotificationEntry."Notification Process Method"::BATCH);
        SendGeneralNotification(TicketNotificationEntry);

        TicketNotificationEntry.Reset();
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::WAITINGLIST);
        TicketNotificationEntry.SetFilter("Notification Process Method", '=%1', TicketNotificationEntry."Notification Process Method"::BATCH);
        SendGeneralNotification(TicketNotificationEntry);

        TicketNotificationEntry.Reset();
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::REMINDER);
        TicketNotificationEntry.SetFilter("Notification Process Method", '=%1', TicketNotificationEntry."Notification Process Method"::BATCH);
        TicketNotificationEntry.SetFilter("Date To Notify", '=%1', Today());
        TicketNotificationEntry.SetFilter("Time To Notify", '<=%1', Time());
        SendGeneralNotification(TicketNotificationEntry);

        // this will catch those reminders that are scheduled closer to midnight than the frequency of the schedular
        if (Time < 010000T) then begin
            TicketNotificationEntry.SetFilter("Date To Notify", '=%1', CalcDate('<-1D>', TODAY));
            TicketNotificationEntry.SetFilter("Time To Notify", '>%1', 230000T);
            SendGeneralNotification(TicketNotificationEntry);
        end;
    end;

    var
        SEND_DIALOG: Label 'Sending: @1@@@@@@@@@@@@@@@@@@';
        NOT_IMPLEMENTED: Label 'Case %1 %2 is not implemented.';
        CONFIRM_SEND_NOTIFICATION: Label 'Do you want to send %1 pending notifications?';
        INVALID: Label 'Invalid %1';
        NO_SMS_TEMPLATE: Label 'Template for table %1 not found amoung SMS Templates.';
        StakeholderNotificationGroupType: Option SALES,SELLOUT,WAITINGLIST;

    procedure NotifyRecipients(var TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.")
    var
        TicketParticipantWks2: Record "NPR TM Ticket Particpt. Wks.";
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
            if (GuiAllowed()) then
                Window.Open(SEND_DIALOG);

            repeat

                TicketParticipantWks2.Get(TicketParticipantWks."Entry No.");
                TicketParticipantWks2."Notification Send Status" := TicketParticipantWks2."Notification Send Status"::FAILED;
                TicketParticipantWks2."Notification Sent At" := CurrentDateTime();
                TicketParticipantWks2."Notification Sent By User" := CopyStr(UserId, 1, MaxStrLen(TicketParticipantWks2."Notification Sent By User"));
                TicketParticipantWks2."Failed With Message" := 'Failed during processing of send message. (Preemptive message.)';
                TicketParticipantWks2.Modify();
                Commit();



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

                TicketParticipantWks2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketParticipantWks2."Failed With Message"));
                TicketParticipantWks2.Modify();
                Commit();

                if (GuiAllowed()) then
                    Window.Update(1, Round(Current / MaxCount * 10000, 1));
                Current += 1;

            until (TicketParticipantWks.Next() = 0);

            if (GuiAllowed()) then
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
            ResponseMessage := StrSubstNo(NO_SMS_TEMPLATE, TicketParticipantWks.TableCaption());

        exit(ResponseMessage = '');
    end;

    local procedure SendMailNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
    begin

        if (TicketNotificationEntry."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry.FieldCaption("Notification Address"));
            exit(false);
        end;

        RecordRef.GetTable(TicketNotificationEntry);
        ResponseMessage := EMailMgt.SendEmail(RecordRef, TicketNotificationEntry."Notification Address", true);
        exit(ResponseMessage = '');
    end;

    local procedure SendSmsNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSMessage: Text;
    begin

        ResponseMessage := '';

        if (TicketNotificationEntry."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry.FieldCaption("Notification Address"));
            exit(false);
        end;

        if SMSManagement.FindTemplate(TicketNotificationEntry, SMSTemplateHeader) then begin
            SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, TicketNotificationEntry);
            SMSManagement.SendSMS(TicketNotificationEntry."Notification Address", SMSTemplateHeader.Description, SMSMessage);
        end else
            ResponseMessage := StrSubstNo(NO_SMS_TEMPLATE, TicketNotificationEntry.TableCaption());

        exit(ResponseMessage = '');

    end;

    procedure AquireTicketParticipant(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]): Boolean
    begin

        exit(AcquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, false));

    end;

    procedure AcquireTicketParticipantForce(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]; ForceDialog: Boolean): Boolean
    begin

        exit(AcquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, ForceDialog));

    end;

    local procedure AcquireTicketParticipantWorker(Token: Text[100]; SuggestNotificationMethod: Option NA,EMAIL,SMS; SuggestNotificationAddress: Text[100]; ForceDialog: Boolean): Boolean
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
        end;

        // check if notify participant 
        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then begin
            TicketAdmissionBOM.Reset();
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketAdmissionBOM.SetFilter("Notification Profile Code", '<>%1', '');
            if (TicketAdmissionBOM.FindFirst()) then begin
                AdmissionCode := TicketAdmissionBOM."Admission Code";
                SuggestNotificationMethod := SuggestNotificationMethod::SMS;
                if (SuggestNotificationAddress = '') then
                    RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
            end;
        end;

        if (not ForceDialog) then
            if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
                exit(false);

        if (AdmissionCode = '') then
            AdmissionCode := Admission."Admission Code";

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
        if (PageAction = Action::LookupOK) then
            TicketReservationRequest2.Get(TicketReservationRequest."Entry No.");

        TicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest."Notification Method" := TicketReservationRequest2."Notification Method";
            TicketReservationRequest."Notification Address" := TicketReservationRequest2."Notification Address";
            TicketReservationRequest.Modify();

            AttributeManagement.CopyEntryAttributeValue(Database::"NPR TM Ticket Reservation Req.", TicketReservationRequest2."Entry No.", TicketReservationRequest."Entry No.");

        until (TicketReservationRequest.Next() = 0);

        exit(PageAction = Action::LookupOK);
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

        if (DetTicketAccessEntry."External Adm. Sch. Entry No." <= 0) then begin

            if (not (DetTicketAccessEntry.Type in [DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID])) then
                exit;

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
                if (Schedule."Notify Stakeholder" in [Schedule."Notify Stakeholder"::ADMIT, Schedule."Notify Stakeholder"::ADMIT_DEPART, Schedule."Notify Stakeholder"::ALL]) then
                    CreateStakeholderNotification(Admission, AdmissionScheduleEntry, DetTicketAccessEntry);

            DetTicketAccessEntry.Type::DEPARTED:
                if (Schedule."Notify Stakeholder" in [Schedule."Notify Stakeholder"::ADMIT_DEPART, Schedule."Notify Stakeholder"::ALL]) then
                    CreateStakeholderNotification(Admission, AdmissionScheduleEntry, DetTicketAccessEntry);

            DetTicketAccessEntry.Type::RESERVATION:
                begin
                    if (DetTicketAccessEntry.Quantity > 0) and (ReservationConfirmed) then
                        if (Schedule."Notify Stakeholder" in [Schedule."Notify Stakeholder"::RESERVE, Schedule."Notify Stakeholder"::RESERVE_CANCEL, Schedule."Notify Stakeholder"::ALL]) then
                            CreateStakeholderNotification(Admission, AdmissionScheduleEntry, DetTicketAccessEntry);

                    if (DetTicketAccessEntry.Quantity < 0) then
                        if (Schedule."Notify Stakeholder" in [Schedule."Notify Stakeholder"::RESERVE_CANCEL, Schedule."Notify Stakeholder"::ALL]) then
                            CreateStakeholderNotification(Admission, AdmissionScheduleEntry, DetTicketAccessEntry);
                end;

            DetTicketAccessEntry.Type::CANCELED_ADMISSION:
                ; // Stakeholder notifications are for reservations only.

            else
                Message('Type %1 is not handled in stakeholder notification.', DetTicketAccessEntry.Type);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6059784, 'OnSelloutThresholdReached', '', true, true)]
    local procedure OnSellOutReached(SellOutEventType: Option NA,TICKET,WAITINGLIST; Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; AdmittedCount: Integer; MaxCapacity: Integer);
    var
        Schedule: Record "NPR TM Admis. Schedule";
    begin

        if (SellOutEventType = 0) then
            exit;

        Schedule.Get(AdmissionScheduleEntry."Schedule Code");

        if (SellOutEventType = 1) then
            if (Schedule."Notify Stakeholder On Sell-Out" in [Schedule."Notify Stakeholder On Sell-Out"::TICKET, Schedule."Notify Stakeholder On Sell-Out"::BOTH]) then
                CreateStakeholderSellOutNotification(StakeholderNotificationGroupType::SELLOUT, Ticket, AdmissionScheduleEntry, AdmittedCount);

        if (SellOutEventType = 2) then
            if (Schedule."Notify Stakeholder On Sell-Out" in [Schedule."Notify Stakeholder On Sell-Out"::WAITINGLIST, Schedule."Notify Stakeholder On Sell-Out"::BOTH]) then
                CreateStakeholderSellOutNotification(StakeholderNotificationGroupType::WAITINGLIST, Ticket, AdmissionScheduleEntry, AdmittedCount);
    end;

    local procedure CreateStakeholderNotification(Admission: Record "NPR TM Admission"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        NotificationEntry."Entry No." := 0;
        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::STAKEHOLDER;
        NotificationEntry."Notification Address" := Admission."Stakeholder (E-Mail/Phone No.)";
        NotificationEntry."Date To Notify" := Today();

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";

        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        case DetTicketAccessEntry.Type of
            DetTicketAccessEntry.Type::ADMITTED:
                NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADMIT;
            DetTicketAccessEntry.Type::DEPARTED:
                NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::DEPART;
            DetTicketAccessEntry.Type::RESERVATION:
                begin
                    if (DetTicketAccessEntry.Quantity > 0) then
                        NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::RESERVE;
                    if (DetTicketAccessEntry.Quantity < 0) then
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
        NotificationEntry."External Order No." := TicketReservationRequest."External Order No.";

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

    end;

    local procedure CreateStakeholderSellOutNotification(Type: Option; Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ReachedQuantity: Integer);
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        Admission.Get(AdmissionScheduleEntry."Admission Code");
        if (Admission."Stakeholder (E-Mail/Phone No.)" = '') then
            exit;

        Schedule.Get(AdmissionScheduleEntry."Schedule Code");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        NotificationEntry."Entry No." := 0;
        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::STAKEHOLDER;

        if (Type = StakeholderNotificationGroupType::SELLOUT) then
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::SELLOUT;

        if (Type = StakeholderNotificationGroupType::WAITINGLIST) then
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::CAPACITY_TO_WL;

        NotificationEntry."Notification Address" := Admission."Stakeholder (E-Mail/Phone No.)";
        NotificationEntry."Date To Notify" := Today();

        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";
        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Quantity To Admit" := ReachedQuantity;
        NotificationEntry."Ticket External Item No." := TicketReservationRequest."External Item Code";

        NotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmissionScheduleEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");

        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;
        if (STRPOS(Admission."Stakeholder (E-Mail/Phone No.)", '@') > 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

        if (StrLen(DELCHR(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
            NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::BATCH;
        NotificationEntry.Insert();

    end;

    procedure CreateDiyPrintNotification(TicketNo: Code[20]) NotificationEntryNo: Integer
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketSetup: Record "NPR TM Ticket Setup";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        UrlLbl: Label '%1%2', Locked = true;
    begin

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
        NotificationEntry."Date To Notify" := Today();

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
        NotificationEntry."Published Ticket URL" := StrSubstNo(UrlLbl, TicketSetup."Print Server Order URL", TicketReservationRequest."Session Token ID");

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";

        NotificationEntry."Ticket Item No." := Ticket."Item No.";
        NotificationEntry."Ticket Variant Code" := Ticket."Variant Code";
        NotificationEntry."Ticket External Item No." := TicketReservationRequest."External Item Code";
        NotificationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
        NotificationEntry."Authorization Code" := TicketReservationRequest."Authorization Code";

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

    end;

    procedure CreateTicketReservationReminder(Ticket: Record "NPR TM Ticket")
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                CreateAdmissionReservationReminder(TicketAccessEntry);
            until (TicketAccessEntry.Next() = 0);
        end;
    end;

    procedure CreateAdmissionReservationReminder(TicketAccessEntry: Record "NPR TM Ticket Access Entry") NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        if (not Ticket.Get(TicketAccessEntry."Ticket No.")) then
            exit(0);

        if (not TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then
            exit(0);

        if (TicketBOM."Notification Profile Code" = '') then
            exit(0);

        if (not NotificationProfile.Get(TicketBOM."Notification Profile Code")) then
            exit(0);

        if (NotificationProfile.Blocked) then
            exit(0);

        ProfileLine.SetFilter("Profile Code", '=%1', TicketBOM."Notification Profile Code");
        ProfileLine.SetFilter("Notification Trigger", '=%1', ProfileLine."Notification Trigger"::RESERVATION);
        ProfileLine.SetFilter(Blocked, '=%1', false);
        if (not ProfileLine.FindSet()) then
            exit(0);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(0);

        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Admission Code", '=%1', TicketAccessEntry."Admission Code");
        NotificationEntry.SetFilter("Notification Trigger", '=%1', NotificationEntry."Notification Trigger"::REMINDER);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        NotificationEntry.ModifyAll("Notification Send Status", NotificationEntry."Notification Send Status"::CANCELED);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine);
        until (ProfileLine.Next() = 0);
    end;

    procedure CreateFirstAdmissionNotification(TicketAccessEntry: Record "NPR TM Ticket Access Entry") NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        if (not Ticket.Get(TicketAccessEntry."Ticket No.")) then
            exit(0);

        if (not TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then
            exit(0);

        if (TicketBOM."Notification Profile Code" = '') then
            exit(0);

        if (not NotificationProfile.Get(TicketBOM."Notification Profile Code")) then
            exit(0);

        if (NotificationProfile.Blocked) then
            exit(0);

        ProfileLine.SetFilter("Profile Code", '=%1', TicketBOM."Notification Profile Code");
        ProfileLine.SetFilter("Notification Trigger", '=%1', ProfileLine."Notification Trigger"::FIRST_ADMISSION);
        ProfileLine.SetFilter(Blocked, '=%1', false);
        if (not ProfileLine.FindSet()) then
            exit(0);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(0);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine);
        until (ProfileLine.Next() = 0);
    end;

    procedure CreateRevokeNotification(TicketAccessEntry: Record "NPR TM Ticket Access Entry") NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        NotificationEntry.SetFilter("Ticket No.", '=%1', TicketAccessEntry."Ticket No.");
        NotificationEntry.SetFilter("Admission Code", '=%1', TicketAccessEntry."Admission Code");
        NotificationEntry.SetFilter("Notification Trigger", '=%1', NotificationEntry."Notification Trigger"::REMINDER);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        NotificationEntry.ModifyAll("Notification Send Status", NotificationEntry."Notification Send Status"::CANCELED);

        if (not Ticket.Get(TicketAccessEntry."Ticket No.")) then
            exit(0);

        if (not TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then
            exit(0);

        if (TicketBOM."Notification Profile Code" = '') then
            exit(0);

        if (not NotificationProfile.Get(TicketBOM."Notification Profile Code")) then
            exit(0);

        if (NotificationProfile.Blocked) then
            exit(0);

        ProfileLine.SetFilter("Profile Code", '=%1', TicketBOM."Notification Profile Code");
        ProfileLine.SetFilter("Notification Trigger", '=%1', ProfileLine."Notification Trigger"::REVOKE);
        ProfileLine.SetFilter(Blocked, '=%1', false);
        if (not ProfileLine.FindSet()) then
            exit(0);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (not DetTicketAccessEntry.FindFirst()) then begin
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            if (not DetTicketAccessEntry.FindFirst()) then
                exit(0);
        end;

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine);
        until (ProfileLine.Next() = 0);
    end;

    local procedure CreateReminderNotification(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; TicketNotProfileLine: Record "NPR TM Notif. Profile Line"): Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        CalcReminderTime: DateTime;
    begin
#pragma warning disable AA0217
        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        AdmSchEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmSchEntry.SetFilter(Cancelled, '=%1', false);
        AdmSchEntry.FindLast();

        Admission.Get(AdmSchEntry."Admission Code");

        NotificationEntry."Entry No." := 0;
        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::REMINDER;
        NotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";
        if (NotificationEntry."Notification Address" = '') then
            exit(0);

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::RESERVATION) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::RESERVE;
            // Schedule ahead of admission start
            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::DAYS) then begin
                NotificationEntry."Date To Notify" := CalcDate(StrSubstNo('<-%1D>', ABS(TicketNotProfileLine.Units)), AdmSchEntry."Admission Start Date");
                NotificationEntry."Time To Notify" := AdmSchEntry."Admission Start Time";
            end;

            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::HOURS) then begin
                CalcReminderTime := CreateDateTime(AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
                CalcReminderTime -= ABS(TicketNotProfileLine.Units) * 3600 * 1000;
                NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
                NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
            end;
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::FIRST_ADMISSION) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADMIT;
            // Schedule after admission end
            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::DAYS) then begin
                NotificationEntry."Date To Notify" := CalcDate(StrSubstNo('<%1D>', ABS(TicketNotProfileLine.Units)), AdmSchEntry."Admission End Date");
                NotificationEntry."Time To Notify" := AdmSchEntry."Admission End Time";
            end;

            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::HOURS) then begin
                CalcReminderTime := CreateDateTime(AdmSchEntry."Admission End Date", AdmSchEntry."Admission End Time");
                CalcReminderTime += ABS(TicketNotProfileLine.Units) * 3600 * 1000;
                NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
                NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
            end;
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::REVOKE) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE;
            // Schedule after NOW
            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::DAYS) then begin
                NotificationEntry."Date To Notify" := CalcDate(StrSubstNo('<%1D>', ABS(TicketNotProfileLine.Units)), TODAY);
                NotificationEntry."Time To Notify" := Time();
            end;

            if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::HOURS) then begin
                CalcReminderTime := CreateDateTime(TODAY, Time());
                CalcReminderTime += ABS(TicketNotProfileLine.Units) * 3600 * 1000;
                NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
                NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
            end;
        end;

        if (NotificationEntry."Date To Notify" < Today()) then
            exit(0);

        NotificationEntry."Template Code" := TicketNotProfileLine."Template Code";
        NotificationEntry."Extra Text" := TicketNotProfileLine."Notification Extra Text";

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmSchEntry."Entry No.";

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";
        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Quantity To Admit" := TicketReservationRequest.Quantity;

        NotificationEntry."Ticket Holder E-Mail" := TicketReservationRequest."Notification Address";
        NotificationEntry."External Order No." := TicketReservationRequest."External Order No.";

        NotificationEntry."Relevant Date" := AdmSchEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmSchEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");

        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;
        if (NotificationEntry."Notification Address" <> '') then begin
            if (STRPOS(NotificationEntry."Notification Address", '@') > 0) then
                NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

            if (StrLen(DelChr(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
                NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;
        end;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::BATCH;
        NotificationEntry.Insert();

        exit(NotificationEntry."Entry No.");
#pragma warning restore
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

        if (not (TicketNotificationEntryFilters.HasFilter())) then
            exit;

        TicketNotificationEntry.CopyFilters(TicketNotificationEntryFilters);
        TicketNotificationEntry.SetFilter("Notification Send Status", '=%1', TicketNotificationEntry."Notification Send Status"::PENDING);

        if (TicketNotificationEntry.FindSet()) then begin
            MaxCount := TicketNotificationEntry.Count();

            Current := 0;
            if (GuiAllowed()) then
                Window.Open(SEND_DIALOG);

            repeat

                TicketNotificationEntry2.Get(TicketNotificationEntry."Entry No.");
                TicketNotificationEntry2."Notification Sent At" := CurrentDateTime();
                TicketNotificationEntry2."Notification Sent By User" := CopyStr(UserId, 1, MaxStrLen(TicketNotificationEntry2."Notification Sent By User"));
                TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry2."Notification Send Status"::FAILED;
                TicketNotificationEntry2."Failed With Message" := 'Failed during processing of send message. (Preemptive message.)';
                TicketNotificationEntry2.Modify();
                Commit();

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

                TicketNotificationEntry2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry2."Failed With Message"));
                TicketNotificationEntry2.Modify();
                Commit();

                if (GuiAllowed()) then
                    Window.Update(1, Round(Current / MaxCount * 10000, 1));
                Current += 1;

            until (TicketNotificationEntry.Next() = 0);

            if (GuiAllowed()) then
                Window.Close();

        end;
    end;
}

