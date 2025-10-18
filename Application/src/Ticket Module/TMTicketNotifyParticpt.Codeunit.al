codeunit 6060120 "NPR TM Ticket Notify Particpt."
{
    Access = Internal;
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
        NO_SMS_TEMPLATE: Label 'Template for table %1 not found among SMS Templates.';
        StakeholderNotificationGroupType: Option SALES,SELLOUT,WAITINGLIST;

    internal procedure NotifyRecipients(var TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.")
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
        EMailMgt.AttemptSendEmail(RecordRef, TicketParticipantWks."Notification Address", ResponseMessage);
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

    internal procedure SendMailNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        NPEmail: Codeunit "NPR NP Email";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
#endif
    begin

        if (TicketNotificationEntry."Notification Address" = '') then begin
            ResponseMessage := StrSubstNo(INVALID, TicketNotificationEntry.FieldCaption("Notification Address"));
            exit(false);
        end;

        RecordRef.GetTable(TicketNotificationEntry);

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (NewEmailExpFeature.IsFeatureEnabled()) then begin
            if (not NPEmail.TrySendEmail(TicketNotificationEntry."Template Code", TicketNotificationEntry, TicketNotificationEntry."Notification Address", TicketNotificationEntry."Ticket Holder Preferred Lang")) then begin
                ResponseMessage := GetLastErrorText();
                exit(false);
            end;
        end else
#endif
            EMailMgt.AttemptSendEmail(RecordRef, TicketNotificationEntry."Notification Address", ResponseMessage);

        if (ResponseMessage <> '') then
            EmitTicketNotificationTelemetry(TicketNotificationEntry, ResponseMessage);

        exit(ResponseMessage = '');
    end;

    internal procedure SendSmsNotificationEntry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
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

        if (ResponseMessage <> '') then
            EmitTicketNotificationTelemetry(TicketNotificationEntry, ResponseMessage);

        exit(ResponseMessage = '');

    end;

    internal procedure RequireParticipantInfo(Token: Text[100]; var AdmissionCode: Code[20]; var SuggestNotificationMethod: Enum "NPR TM NotificationMethod"; var SuggestNotificationAddress: Text[100]; var SuggestTicketHolderName: Text[100]; var SuggestTicketHolderLanguage: Code[10]) RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
    var
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Member: Record "NPR MM Member";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindSet()) then
            exit(RequireParticipantInformation::NOT_REQUIRED);

        repeat
            if (TicketReservationRequest."Primary Request Line") then begin
                SuggestNotificationAddress := TicketReservationRequest."Notification Address";
                SuggestTicketHolderName := TicketReservationRequest.TicketHolderName;
                SuggestTicketHolderLanguage := TicketReservationRequest.TicketHolderPreferredLanguage;
                AdmissionCode := TicketReservationRequest."Admission Code";

                if (GetMember(Ticket."External Member Card No.", Member)) then begin
                    SuggestTicketHolderName := Member."Display Name";
                    SuggestTicketHolderLanguage := Member.PreferredLanguageCode;
                    case (Member."Notification Method") of
                        Member."Notification Method"::EMAIL:
                            begin
                                SuggestNotificationAddress := Member."E-Mail Address";
                                SuggestNotificationMethod := SuggestNotificationMethod::EMAIL;
                            end;
                        Member."Notification Method"::SMS:
                            begin
                                SuggestNotificationAddress := Member."Phone No.";
                                SuggestNotificationMethod := SuggestNotificationMethod::SMS;
                            end;
                    end;
                end;
            end;

            Admission.Get(TicketReservationRequest."Admission Code");
            if (RequireParticipantInformation < Admission."Ticketholder Notification Type") then begin
                RequireParticipantInformation := Admission."Ticketholder Notification Type";
                AdmissionCode := Admission."Admission Code";
            end;

            if (TicketAdmissionBOM.Get(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Admission Code")) then begin
                if ((TicketAdmissionBOM."Publish As eTicket") or
                    (TicketAdmissionBOM."Notification Profile Code" <> '')) then begin
                    AdmissionCode := TicketAdmissionBOM."Admission Code";
                    SuggestNotificationMethod := SuggestNotificationMethod::SMS;
                    if (SuggestNotificationAddress = '') then
                        RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
                end;

                if (TicketAdmissionBOM."Publish Ticket URL" = TicketAdmissionBOM."Publish Ticket URL"::SEND) then begin
                    AdmissionCode := TicketAdmissionBOM."Admission Code";
                    SuggestNotificationMethod := SuggestNotificationMethod::EMAIL;
                    if (SuggestNotificationAddress = '') then
                        RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
                end;

                if (TicketAdmissionBOM.NPDesignerTemplateId <> '') then begin
                    AdmissionCode := TicketAdmissionBOM."Admission Code";
                    SuggestNotificationMethod := SuggestNotificationMethod::EMAIL;
                    if (SuggestNotificationAddress = '') then
                        RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;
                end;
            end;

        until (TicketReservationRequest.Next() = 0);
    end;

    internal procedure GetTicketHolderFromNotificationAddress(NotificationAddress: Text[100]; var TicketHolder: Record "NPR TM TicketHolder")
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
    begin
        Clear(TicketHolder);
        TicketReservationReq.SetCurrentKey("Notification Address");
        TicketReservationReq.SetRange("Notification Address", NotificationAddress);
        if (TicketReservationReq.FindSet()) then
            repeat
                // Ensure we only add data once in case we have mulitple admissions/tickets on the same token.
                if (not TicketHolder.Get(TicketReservationReq."Session Token ID")) then begin
                    TicketHolder.Init();
                    TicketHolder.FromReservationRequest(TicketReservationReq);
                    TicketHolder.Insert();
                end
            until TicketReservationReq.Next() = 0;
    end;

    internal procedure SetTicketHolderInfo(var TicketHolder: Record "NPR TM TicketHolder")
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        MailManagement: Codeunit "Mail Management";
        TypeHelper: Codeunit "Type Helper";
        InvalidNotificationAddressErr: Label 'The notification address (%1) provided is not valid for the selected notification method (%2).', Comment = '%1 = notification address, %2 = notification method';
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        TicketReservationReq.LockTable();
#else
        TicketReservationReq.ReadIsolation := IsolationLevel::UpdLock;
#endif
        TicketReservationReq.SetCurrentKey("Session Token ID");

        TicketHolder.Reset();
        if (not TicketHolder.FindSet()) then
            exit;

        repeat
            case TicketHolder.NotificationMethod of
                "NPR TM NotificationMethod"::SMS:
                    if (not TypeHelper.IsPhoneNumber(TicketHolder.NotificationAddress)) then
                        Error(InvalidNotificationAddressErr, TicketHolder.NotificationAddress, TicketHolder.NotificationMethod);
                "NPR TM NotificationMethod"::EMAIL:
                    if (not MailManagement.CheckValidEmailAddress(TicketHolder.NotificationAddress)) then
                        Error(InvalidNotificationAddressErr, TicketHolder.NotificationAddress, TicketHolder.NotificationMethod);
            end;

            TicketReservationReq.SetRange("Session Token ID", TicketHolder.ReservationToken);
            TicketReservationReq.FindSet();
            repeat
                TicketReservationReq."Notification Method" := TicketHolder.NotificationMethod;
                TicketReservationReq."Notification Address" := TicketHolder.NotificationAddress;
                TicketReservationReq.TicketHolderName := TicketHolder.TicketHolderName;
                TicketReservationReq.TicketHolderPreferredLanguage := TicketHolder.TicketHolderPreferredLanguage;
                TicketReservationReq.Modify();
            until TicketReservationReq.Next() = 0;
        until TicketHolder.Next() = 0;
    end;

    internal procedure AcquireTicketParticipant(Token: Text[100]; SuggestNotificationMethod: Enum "NPR TM NotificationMethod"; SuggestNotificationAddress: Text[100]; SuggestTicketHolderName: Text[100]; SuggestTicketHolderLanguage: Code[10]): Boolean
    begin

        exit(AcquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage, false));

    end;

    internal procedure AcquireTicketParticipantForce(Token: Text[100]; SuggestNotificationMethod: Enum "NPR TM NotificationMethod"; SuggestNotificationAddress: Text[100]; SuggestTicketHolderName: Text[100]; SuggestTicketHolderLanguage: Code[10]; ForceDialog: Boolean): Boolean
    begin

        exit(AcquireTicketParticipantWorker(Token, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage, ForceDialog));

    end;

    local procedure AcquireTicketParticipantWorker(Token: Text[100]; SuggestNotificationMethod: Enum "NPR TM NotificationMethod"; SuggestNotificationAddress: Text[100]; SuggestTicketHolderName: Text[100]; SuggestTicketHolderLanguage: Code[10]; ForceDialog: Boolean): Boolean
    var
        PageAction: Action;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketParticipant: Page "NPR TM Acquire Participant";
        TicketHolderInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AttributeManagement: Codeunit "NPR Attribute Management";
        AdmissionCode: Code[20];
    begin

        if (not GuiAllowed()) then
            exit(false);

        TicketHolderInformation := RequireParticipantInfo(Token, AdmissionCode, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage);
        if (not ForceDialog) then
            if (TicketHolderInformation = TicketHolderInformation::NOT_REQUIRED) then
                exit(false);

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
        DisplayTicketParticipant.SetDefaultNotification(SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage);

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
            TicketReservationRequest.TicketHolderName := TicketReservationRequest2.TicketHolderName;
            TicketReservationRequest.TicketHolderPreferredLanguage := TicketReservationRequest2.TicketHolderPreferredLanguage;
            TicketReservationRequest.Modify();

            AttributeManagement.CopyEntryAttributeValue(Database::"NPR TM Ticket Reservation Req.", TicketReservationRequest2."Entry No.", TicketReservationRequest."Entry No.");

        until (TicketReservationRequest.Next() = 0);

        exit(PageAction = Action::LookupOK);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Management", 'OnDetailedTicketEvent', '', true, true)]
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

            ReserveTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type);
            ReserveTicketAccessEntry.SetLoadFields("Ticket Access Entry No.", Type, Quantity);
            ReserveTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', DetTicketAccessEntry."Ticket Access Entry No.");
            ReserveTicketAccessEntry.SetFilter(Type, '=%1', ReserveTicketAccessEntry.Type::RESERVATION);
            ReserveTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
            if (not ReserveTicketAccessEntry.FindFirst()) then
                exit;

            ReservationConfirmed := DetTicketAccessEntry.Get(ReserveTicketAccessEntry."Entry No.");
        end;

        AdmissionScheduleEntry.SetCurrentKey("External Schedule Entry No.");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Management", 'OnSelloutThresholdReached', '', true, true)]
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

    internal procedure CreateDiyPrintNotification(TicketNo: Code[20]) NotificationEntryNo: Integer
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
        NPDesignerSetup: Record "NPR NPDesignerSetup";
        Manifest: Codeunit "NPR NPDesignerManifestFacade";
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

        if (TicketBom."Publish Ticket URL" <> TicketBom."Publish Ticket URL"::DISABLE) then
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

        NotificationEntry.NPDesignerTemplateId := TicketBom.NPDesignerTemplateId;
        if (NotificationEntry.NPDesignerTemplateId <> '') then begin
            NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::NP_DESIGNER;
            if (NPDesignerSetup.Get('')) then
                if (NPDesignerSetup.EnableManifest) then begin
                    if (IsNullGuid(NotificationEntry.NPDesignerManifestId)) then begin
                        NotificationEntry.NPDesignerManifestId := Manifest.CreateManifest();
                        Manifest.AddAssetToManifest(NotificationEntry.NPDesignerManifestId, Database::"NPR TM Ticket Reservation Req.", TicketReservationRequest.SystemId, TicketReservationRequest."Session Token ID", NotificationEntry.NPDesignerTemplateId);
                    end;
                    Manifest.GetManifestUrl(NotificationEntry.NPDesignerManifestId, NotificationEntry."Published Ticket URL");
                end;

            if ((not NPDesignerSetup.EnableManifest) and (NPDesignerSetup.PublicOrderURL <> '')) then
                NotificationEntry."Published Ticket URL" := StrSubstNo(NPDesignerSetup.PublicOrderURL, TicketReservationRequest."Session Token ID", NotificationEntry.NPDesignerTemplateId);
        end;

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

    internal procedure CreateTicketReservationReminder(Ticket: Record "NPR TM Ticket")
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                CreateAdmissionWelcomeReminder(TicketAccessEntry, Ticket."External Member Card No.");
                CreateAdmissionReservationReminder(TicketAccessEntry, Ticket."External Member Card No.");
            until (TicketAccessEntry.Next() = 0);
        end;
    end;

    internal procedure CreateAdmissionReservationReminder(TicketAccessEntry: Record "NPR TM Ticket Access Entry"; MemberNumber: Code[20]) NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Member: Record "NPR MM Member";
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
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::RESERVE);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        NotificationEntry.ModifyAll("Notification Send Status", NotificationEntry."Notification Send Status"::CANCELED);

        GetMember(MemberNumber, Member);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine, Member);
        until (ProfileLine.Next() = 0);
    end;

    internal procedure CreateAdmissionWelcomeReminder(TicketAccessEntry: Record "NPR TM Ticket Access Entry"; MemberNumber: Code[20]) NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry, NotificationEntry2 : Record "NPR TM Ticket Notif. Entry";
        Member: Record "NPR MM Member";
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
        ProfileLine.SetFilter("Notification Trigger", '=%1', ProfileLine."Notification Trigger"::WELCOME);
        ProfileLine.SetFilter(Blocked, '=%1', false);
        if (not ProfileLine.FindSet()) then
            exit(0);

        DetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type);
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(0);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        NotificationEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        NotificationEntry.SetCurrentKey("Ticket No.", "Notification Send Status");
        NotificationEntry.SetLoadFields("Notification Send Status");
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Admission Code", '=%1', TicketAccessEntry."Admission Code");
        NotificationEntry.SetFilter("Notification Trigger", '=%1', NotificationEntry."Notification Trigger"::REMINDER);
        NotificationEntry.SetFilter("Ticket Trigger Type", '=%1', NotificationEntry."Ticket Trigger Type"::WELCOME);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::PENDING);
        if (NotificationEntry.FindSet()) then begin
            repeat
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
                NotificationEntry2.ReadIsolation := IsolationLevel::UpdLock;
#endif
                NotificationEntry.SetLoadFields("Notification Send Status");
                NotificationEntry2.Get(NotificationEntry."Entry No.");
                NotificationEntry2."Notification Send Status" := NotificationEntry2."Notification Send Status"::CANCELED;
                NotificationEntry2.Modify();
            until (NotificationEntry.Next() = 0);
        end;

        GetMember(MemberNumber, Member);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine, Member);
        until (ProfileLine.Next() = 0);
    end;

    internal procedure CreateOnAdmissionNotification(TicketAccessEntry: Record "NPR TM Ticket Access Entry"; DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; FirstAdmission: Boolean) NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        Member: Record "NPR MM Member";
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
        ProfileLine.SetFilter("Notification Trigger", '=%1', ProfileLine."Notification Trigger"::ON_EACH_ADMISSION);
        if (FirstAdmission) then
            ProfileLine.SetFilter("Notification Trigger", '=%1|=%2', ProfileLine."Notification Trigger"::FIRST_ADMISSION, ProfileLine."Notification Trigger"::ON_EACH_ADMISSION);

        ProfileLine.SetFilter(Blocked, '=%1', false);
        if (not ProfileLine.FindSet()) then
            exit(0);

        GetMember(Ticket."External Member Card No.", Member);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine, Member);
        until (ProfileLine.Next() = 0);
    end;

    internal procedure CreateRevokeNotification(TicketAccessEntry: Record "NPR TM Ticket Access Entry") NotificationEntryNo: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NotificationProfile: Record "NPR TM Notification Profile";
        ProfileLine: Record "NPR TM Notif. Profile Line";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Member: Record "NPR MM Member";
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

        GetMember(Ticket."External Member Card No.", Member);

        repeat
            NotificationEntryNo := CreateReminderNotification(DetTicketAccessEntry, ProfileLine, Member);
        until (ProfileLine.Next() = 0);
    end;

    local procedure CreateReminderNotification(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; TicketNotProfileLine: Record "NPR TM Notif. Profile Line"; Member: Record "NPR MM Member"): Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Item: Record Item;
        NpDesignerSetup: Record "NPR NPDesignerSetup";
        Manifest: Codeunit "NPR NPDesignerManifestFacade";
    begin
#pragma warning disable AA0217
        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        if (not Item.Get(Ticket."Item No.")) then
            Item.Init();

        AdmSchEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
        AdmSchEntry.SetFilter(Cancelled, '=%1', false);
        AdmSchEntry.FindLast();

        Admission.Get(AdmSchEntry."Admission Code");

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter(NPDesignerTemplateId, '<>%1', '');
        TicketBom.SetFilter(Default, '=%1', true);
        if (TicketBom.FindFirst()) then
            NpDesignerSetup.Get();


        NotificationEntry."Entry No." := 0;
        NotificationEntry."Notification Trigger" := NotificationEntry."Notification Trigger"::REMINDER;
        NotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";
        NotificationEntry."Ticket Holder Preferred Lang" := TicketReservationRequest.TicketHolderPreferredLanguage;
        if (NotificationEntry."Notification Address" = '') then
            exit(0);

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::WELCOME) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::WELCOME;
            // Schedule based on today
            AddUsingProfileTimeOffset(TicketNotProfileLine, NotificationEntry, Today(), Time());
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::RESERVATION) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::RESERVE;
            // Schedule ahead of admission start
            SubtractUsingProfileTimeOffset(TicketNotProfileLine, NotificationEntry, AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::FIRST_ADMISSION) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADMIT;
            // Schedule after admission end
            AddUsingProfileTimeOffset(TicketNotProfileLine, NotificationEntry, AdmSchEntry."Admission End Date", AdmSchEntry."Admission End Time");
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::ON_EACH_ADMISSION) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::ADMIT;
            // Schedule after admission occurred
            AddUsingProfileTimeOffset(TicketNotProfileLine, NotificationEntry, DT2Date(DetTicketAccessEntry."Created Datetime"), DT2Time(DetTicketAccessEntry."Created Datetime"));
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::REVOKE) then begin
            NotificationEntry."Ticket Trigger Type" := NotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE;
            // Schedule after NOW
            AddUsingProfileTimeOffset(TicketNotProfileLine, NotificationEntry, Today(), Time());
        end;

        if (TicketNotProfileLine."Notification Trigger" = TicketNotProfileLine."Notification Trigger"::RESERVATION) then
            if (CreateDateTime(NotificationEntry."Date To Notify", NotificationEntry."Time To Notify") < CurrentDateTime()) then
                if (CreateDateTime(AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time") > CurrentDateTime()) then begin
                    NotificationEntry."Date To Notify" := Today();
                    NotificationEntry."Time To Notify" := Time();
                end;

        if (NotificationEntry."Date To Notify" < Today()) then
            exit(0);

        if (not TicketNotProfileLine."Shared Detention Queue") then
            NotificationEntry."Notification Profile Code" := TicketNotProfileLine."Profile Code";
        NotificationEntry."Detention Time Seconds" := TicketNotProfileLine."Detention Time Seconds";
        NotificationEntry."Template Code" := TicketNotProfileLine."Template Code";
        NotificationEntry."Extra Text" := TicketNotProfileLine."Notification Extra Text";

        NotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
        NotificationEntry."Admission Schedule Entry No." := AdmSchEntry."Entry No.";

        NotificationEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        NotificationEntry."Ticket No." := Ticket."No.";
        NotificationEntry."Ticket Item No." := Ticket."Item No.";
        NotificationEntry."Ticket Variant Code" := Ticket."Variant Code";
        NotificationEntry."External Ticket No." := Ticket."External Ticket No.";
        NotificationEntry."Ticket No. for Printing" := Ticket."External Ticket No.";
        NotificationEntry."Admission Code" := Admission."Admission Code";
        NotificationEntry."Adm. Event Description" := Admission.Description;
        NotificationEntry."Adm. Location Description" := Admission.Description;

        NotificationEntry."Quantity To Admit" := TicketReservationRequest.Quantity;
        NotificationEntry."Ticket Holder E-Mail" := TicketReservationRequest."Notification Address";
        NotificationEntry."External Order No." := TicketReservationRequest."External Order No.";
        NotificationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
        NotificationEntry."Authorization Code" := TicketReservationRequest."Authorization Code";

        NotificationEntry."Relevant Date" := AdmSchEntry."Admission Start Date";
        NotificationEntry."Relevant Time" := AdmSchEntry."Admission Start Time";
        NotificationEntry."Relevant Datetime" := CreateDateTime(NotificationEntry."Relevant Date", NotificationEntry."Relevant Time");

        NotificationEntry.NPDesignerTemplateId := TicketBom.NPDesignerTemplateId;
        if (NotificationEntry.NPDesignerTemplateId <> '') then begin
            if (NPDesignerSetup.EnableManifest) then begin
                if (IsNullGuid(NotificationEntry.NPDesignerManifestId)) then begin
                    NotificationEntry.NPDesignerManifestId := Manifest.CreateManifest();
                    Manifest.AddAssetToManifest(NotificationEntry.NPDesignerManifestId, Database::"NPR TM Ticket", Ticket.SystemId, Ticket."External Ticket No.", NotificationEntry.NPDesignerTemplateId);
                end;
                Manifest.GetManifestUrl(NotificationEntry.NPDesignerManifestId, NotificationEntry."Published Ticket URL");
            end;

            if (not NPDesignerSetup.EnableManifest and (NpDesignerSetup.PublicTicketURL <> '')) then
                NotificationEntry."Published Ticket URL" := StrSubstNo(NpDesignerSetup.PublicTicketURL, Format(Ticket.SystemId, 0, 4).ToLower(), NotificationEntry.NPDesignerTemplateId);
        end;

        NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::NA;
        if (NotificationEntry."Notification Address" <> '') then begin
            if (STRPOS(NotificationEntry."Notification Address", '@') > 0) then
                NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::EMAIL;

            if (StrLen(DelChr(NotificationEntry."Notification Address", '<=>', '+0123456789 ')) = 0) then
                NotificationEntry."Notification Method" := NotificationEntry."Notification Method"::SMS;
        end;

        NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::BATCH;
        NotificationEntry."Notification Engine" := TicketNotProfileLine."Notification Engine";
        if (TicketNotProfileLine."Notification Engine" = TicketNotProfileLine."Notification Engine"::NPR_EXTERNAL) then
            NotificationEntry."Notification Process Method" := NotificationEntry."Notification Process Method"::EXTERNAL;

        if (Member."Entry No." > 0) then
            NotificationEntry."Ticket Holder Name" := Member."Display Name";

        NotificationEntry.Insert();

        exit(NotificationEntry."Entry No.");
#pragma warning restore
    end;

    local procedure AddUsingProfileTimeOffset(TicketNotProfileLine: Record "NPR TM Notif. Profile Line"; var NotificationEntry: Record "NPR TM Ticket Notif. Entry"; DateBase: Date; TimeBase: Time)
    var
        CalcReminderTime: DateTime;
    begin
        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::DAYS) then begin
            NotificationEntry."Date To Notify" := CalcDate(StrSubstNo('<%1D>', Abs(TicketNotProfileLine.Units)), DateBase);
            NotificationEntry."Time To Notify" := TimeBase;
        end;

        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::HOURS) then begin
            CalcReminderTime := CreateDateTime(DateBase, TimeBase);
            CalcReminderTime += Abs(TicketNotProfileLine.Units) * 3600 * 1000;
            NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
            NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
        end;

        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::MINUTES) then begin
            CalcReminderTime := CreateDateTime(DateBase, TimeBase);
            CalcReminderTime += Abs(TicketNotProfileLine.Units) * 60 * 1000;
            NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
            NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
        end;
    end;

    local procedure SubtractUsingProfileTimeOffset(TicketNotProfileLine: Record "NPR TM Notif. Profile Line"; var NotificationEntry: Record "NPR TM Ticket Notif. Entry"; DateBase: Date; TimeBase: Time)
    var
        CalcReminderTime: DateTime;
    begin
        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::DAYS) then begin
            NotificationEntry."Date To Notify" := CalcDate(StrSubstNo('<-%1D>', Abs(TicketNotProfileLine.Units)), DateBase);
            NotificationEntry."Time To Notify" := TimeBase;
        end;

        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::HOURS) then begin
            CalcReminderTime := CreateDateTime(DateBase, TimeBase);
            CalcReminderTime -= Abs(TicketNotProfileLine.Units) * 3600 * 1000;
            NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
            NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
        end;

        if (TicketNotProfileLine."Unit of Measure" = TicketNotProfileLine."Unit of Measure"::MINUTES) then begin
            CalcReminderTime := CreateDateTime(DateBase, TimeBase);
            CalcReminderTime -= Abs(TicketNotProfileLine.Units) * 60 * 1000;
            NotificationEntry."Date To Notify" := DT2Date(CalcReminderTime);
            NotificationEntry."Time To Notify" := DT2Time(CalcReminderTime);
        end;
    end;

    local procedure SetNotificationDetention(var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; ResponseMessage: Text): Boolean
    var
        DetainNotification: Record "NPR TM Detained Notification";
    begin
        if (TicketNotificationEntry."Detention Time Seconds" <= 0) then
            exit(false); // No detention

        DetainNotification.SetFilter("Notification Address", '=%1', TicketNotificationEntry."Notification Address");
        DetainNotification.SetFilter("Notification Trigger Type", '=%1', TicketNotificationEntry."Ticket Trigger Type");
        DetainNotification.SetFilter("Notification Profile Code", '=%1', TicketNotificationEntry."Notification Profile Code");
        if (not DetainNotification.FindFirst()) then begin
            DetainNotification."Entry No." := 0;
            DetainNotification."Notification Address" := TicketNotificationEntry."Notification Address";
            DetainNotification."Notification Trigger Type" := TicketNotificationEntry."Ticket Trigger Type";
            DetainNotification."Notification Profile Code" := TicketNotificationEntry."Notification Profile Code";
            DetainNotification."Detain Until" := CurrentDateTime() + TicketNotificationEntry."Detention Time Seconds" * 1000;
            if (not DetainNotification.Insert()) then;
            exit(false); // No detention
        end;

        if (DetainNotification."Detain Until" < CurrentDateTime()) then begin
            DetainNotification."Detain Until" := CurrentDateTime() + TicketNotificationEntry."Detention Time Seconds" * 1000;
            DetainNotification.Modify();
            exit(false); // No detention
        end;

        ResponseMessage := 'Notification is detained to minimize spam.';
        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::DETAINED;
        exit(true);
    end;

    local procedure GetMember(MemberNumber: Code[20]; var Member: Record "NPR MM Member"): Boolean
    begin
        Clear(Member);
        if (MemberNumber = '') then
            exit(false);

        Member.SetCurrentKey("External Member No.");
        Member.SetFilter("External Member No.", '=%1', MemberNumber);
        Member.SetFilter(Blocked, '=%1', false);
        if (not Member.FindFirst()) then
            Clear(Member);

        exit(Member."Entry No." > 0);
    end;


    internal procedure SendGeneralNotification(var TicketNotificationEntryFilters: Record "NPR TM Ticket Notif. Entry")
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketNotificationEntry2: Record "NPR TM Ticket Notif. Entry";
        HLHeybookingSendTicket: Codeunit "NPR HL Heybooking Send Ticket";
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

                if (TicketNotificationEntry2."Notification Trigger" = TicketNotificationEntry2."Notification Trigger"::REMINDER) then
                    SetNotificationDetention(TicketNotificationEntry2, ResponseMessage);

                if (TicketNotificationEntry2."Notification Send Status" <> TicketNotificationEntry2."Notification Send Status"::DETAINED) then begin
                    if TicketNotificationEntry2."Notification Engine" = TicketNotificationEntry2."Notification Engine"::NPR_HEYLOYALTY then
                        HLHeybookingSendTicket.Touch(TicketNotificationEntry2)
                    else
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
                end;

                if TicketNotificationEntry2."Notification Engine" <> TicketNotificationEntry2."Notification Engine"::NPR_HEYLOYALTY then begin
                    TicketNotificationEntry2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry2."Failed With Message"));
                    TicketNotificationEntry2.Modify();
                    Commit();
                end;

                if (GuiAllowed()) then
                    Window.Update(1, Round(Current / MaxCount * 10000, 1));
                Current += 1;

            until (TicketNotificationEntry.Next() = 0);

            HLHeybookingSendTicket.SendTouched();  //Has a commit

            if (GuiAllowed()) then
                Window.Close();

        end;
    end;

    internal procedure EmitTicketNotificationTelemetry(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; FailReason: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());

        CustomDimensions.Add('NPR_EntryNumber', Format(TicketNotificationEntry."Entry No.", 0, 9));
        CustomDimensions.Add('NPR_WalletPassId', TicketNotificationEntry."eTicket Pass Id");
        CustomDimensions.Add('NPR_Method', Format(TicketNotificationEntry."Notification Method", 0, 9));

        CustomDimensions.Add('NPR_Token', TicketNotificationEntry."Ticket Token");

        Session.LogMessage('NPR_MemberNotification', FailReason, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure ExportNotifications(var Notification: Record "NPR TM Ticket Notif. Entry")
    var
        Notifications: JsonArray;
        Envelope: JsonObject;
    begin
        if (not Notification.FindSet()) then
            exit;

        repeat
            Notifications.Add(SerializeNotificationEntry(Notification));
        until (Notification.Next() = 0);

        Envelope.Add('exportedBy', UserId);
        Envelope.Add('exportedAt', CurrentDateTime());
        Envelope.Add('companyName', CompanyName());
        Envelope.Add('version', '1.0');
        Envelope.Add('filter', Notification.GetFilters());
        Envelope.Add('count', Notifications.Count());
        Envelope.Add('notifications', Notifications);

        ExportJsonToFile('Notifications', Envelope);
    end;

    local procedure SerializeNotificationEntry(Notification: Record "NPR TM Ticket Notif. Entry") Entry: JsonObject
    begin
        Entry.Add('systemId', Notification.SystemId);
        Entry.Add('entryNo', Notification."Entry No.");
        Entry.Add('dateToNotify', Notification."Date To Notify");
        Entry.Add('timeToNotify', Notification."Time To Notify");
        Entry.Add('admissionCode', Notification."Admission Code");
        Entry.Add('admEventDescription', Notification."Adm. Event Description");
        Entry.Add('admLocationDescription', Notification."Adm. Location Description");
        Entry.Add('admissionScheduleEntryNo', Notification."Admission Schedule Entry No.");
        Entry.Add('authorizationCode', Notification."Authorization Code");
        Entry.Add('detTicketAccessEntryNo', Notification."Det. Ticket Access Entry No.");
        Entry.Add('eventStartDate', Notification."Event Start Date");
        Entry.Add('eventStartTime', Notification."Event Start Time");
        Entry.Add('expireDate', Notification."Expire Date");
        Entry.Add('expireDatetime', Notification."Expire Datetime");
        Entry.Add('expireTime', Notification."Expire Time");
        Entry.Add('externalOrderNo', Notification."External Order No.");
        Entry.Add('externalTicketNo', Notification."External Ticket No.");
        Entry.Add('extraText', Notification."Extra Text");
        Entry.Add('failedWithMessage', Notification."Failed With Message");
        Entry.Add('notificationAddress', Notification."Notification Address");
        Entry.Add('notificationGroupId', Notification."Notification Group Id");
        Entry.Add('notificationMethod', Notification."Notification Method".AsInteger());
        Entry.Add('notificationProcessMethod', Notification."Notification Process Method".AsInteger());
        Entry.Add('notificationSendStatus', Notification."Notification Send Status".AsInteger());
        Entry.Add('notificationSentAt', Notification."Notification Sent At");
        Entry.Add('notificationSentByUser', Notification."Notification Sent By User");
        Entry.Add('notificationTrigger', Notification."Notification Trigger".AsInteger());
        Entry.Add('publishedTicketURL', Notification."Published Ticket URL");
        Entry.Add('quantityToAdmit', Notification."Quantity To Admit");
        Entry.Add('relevantDate', Notification."Relevant Date");
        Entry.Add('relevantDatetime', Notification."Relevant Datetime");
        Entry.Add('relevantTime', Notification."Relevant Time");
        Entry.Add('row', Notification.Row);
        Entry.Add('seat', Notification.Seat);
        Entry.Add('section', Notification.Section);
        Entry.Add('systemCreatedAt', Notification.SystemCreatedAt);
        Entry.Add('systemCreatedBy', Notification.SystemCreatedBy);
        Entry.Add('systemModifiedAt', Notification.SystemModifiedAt);
        Entry.Add('systemModifiedBy', Notification.SystemModifiedBy);
        Entry.Add('templateCode', Notification."Template Code");
        Entry.Add('ticketBOMAdmDescription', Notification."Ticket BOM Adm. Description");
        Entry.Add('ticketBOMDescription', Notification."Ticket BOM Description");
        Entry.Add('ticketExternalItemNo', Notification."Ticket External Item No.");
        Entry.Add('ticketHolderEMail', Notification."Ticket Holder E-Mail");
        Entry.Add('ticketHolderName', Notification."Ticket Holder Name");
        Entry.Add('ticketItemNo', Notification."Ticket Item No.");
        Entry.Add('ticketListPrice', Notification."Ticket List Price");
        Entry.Add('ticketNo', Notification."Ticket No.");
        Entry.Add('ticketNoForPrinting', Notification."Ticket No. for Printing");
        Entry.Add('ticketToken', Notification."Ticket Token");
        Entry.Add('ticketTriggerType', Notification."Ticket Trigger Type".AsInteger());
        Entry.Add('ticketTypeCode', Notification."Ticket Type Code");
        Entry.Add('ticketVariantCode', Notification."Ticket Variant Code");
        Entry.Add('voided', Notification.Voided);
        Entry.Add('waitingListReferenceCode', Notification."Waiting List Reference Code");
        Entry.Add('eTicketPassAndriodURL', Notification."eTicket Pass Andriod URL");
        Entry.Add('eTicketPassDefaultURL', Notification."eTicket Pass Default URL");
        Entry.Add('eTicketPassId', Notification."eTicket Pass Id");
        Entry.Add('eTicketPassLandingURL', Notification."eTicket Pass Landing URL");
        Entry.Add('eTicketTypeCode', Notification."eTicket Type Code");
        Entry.Add('NPDesignerTemplateId', Notification.NPDesignerTemplateId);
    end;


    local procedure ExportJsonToFile(Name: Text; JsonData: JsonObject)
    var
        IStream: InStream;
        OStream: OutStream;
        FileName: Text;
        JsonText: Text;
        TempBlob: Codeunit "Temp Blob";
        FileNameLbl: Label '%1.json', Locked = true;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        JsonData.WriteTo(JsonText);
        OStream.WriteText(JsonText);

        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        CopyStream(OStream, IStream);

        FileName := StrSubstNo(FileNameLbl, Name);
        DownloadFromStream(IStream, '', '', 'JSON File (*.json)|*.json', FileName);
    end;

}

