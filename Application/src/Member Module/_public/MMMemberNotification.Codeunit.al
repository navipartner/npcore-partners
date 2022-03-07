codeunit 6060136 "NPR MM Member Notification"
{

    trigger OnRun()
    var
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
    begin

        // Invoked by Task Queue when scheduled for background notifications
        HandleBatchNotifications(Today);

        SponsorshipTicketMgmt.NotifyRecipients();

    end;

    var
        NOT_IMPLEMENTED: Label '%1 %2 not implemented.';
        BAD_REFERENCE: Label 'The field reference {:%1} in the textline "%2" does correspond to a valid field number.';
        INLINE_NOTIFICATION: Label 'Sends Inline Member Notifications on End of Sales.';
        REFRESH_NOTIFICATION: Label '';

    internal procedure HandleBatchNotifications(ReferenceDate: Date)
    var
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin

        SelectLatestVersion();

        MembershipNotification.SetCurrentKey("Notification Status", "Date To Notify");
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Date To Notify", '<=%1', ReferenceDate);
        MembershipNotification.SetFilter(Blocked, '=%1', false);

        MembershipNotification.SetFilter("Processing Method", '=%1', MembershipNotification."Processing Method"::BATCH);

        if (MembershipNotification.FindSet()) then begin
            repeat
                HandleMembershipNotification(MembershipNotification);

                Commit();

            until (MembershipNotification.Next() = 0);
        end;
    end;

    internal procedure HandleMembershipNotification(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        NotificationStatus: Integer;
    begin

        NotificationStatus := NotificationIsValid(MembershipNotification);
        if (NotificationStatus = 1) then begin
            CreateRecipients(MembershipNotification);
            NotifyRecipients(MembershipNotification);
            CreateNextNotification(MembershipNotification);
            MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PROCESSED;
        end;

        if (NotificationStatus = -1) then begin
            MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::CANCELED;
        end;

        if (NotificationStatus <> 0) then begin
            MembershipNotification."Notification Processed At" := CurrentDateTime;
            MembershipNotification."Notification Processed By User" := CopyStr(UserId, 1, MaxStrLen(MembershipNotification."Notification Processed By User"));
            MembershipNotification.Modify();
        end;

        Commit();
    end;

    local procedure NotificationIsValid(MembershipNotification: Record "NPR MM Membership Notific."): Integer
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        Coupon: Record "NPR NpDc Coupon";
        FromDate: Date;
        UntilDate: Date;
        StartDate: Date;
    begin

        if (MembershipNotification.Blocked) then
            exit(0);

        if (MembershipNotification."Notification Status" <> MembershipNotification."Notification Status"::PENDING) then
            exit(0);

        if (not NotificationSetup.Get(MembershipNotification."Notification Code")) then
            exit(0);

        if (NotificationSetup."Cancel Overdue Notif. (Days)" = 0) then
            NotificationSetup."Cancel Overdue Notif. (Days)" := 7; // notification older than 7 days will be cancelled unless setup sets a different value

        if (MembershipNotification."Date To Notify" + Abs(NotificationSetup."Cancel Overdue Notif. (Days)") < Today) then
            exit(-1);

        case MembershipNotification."Notification Trigger" of
            MembershipNotification."Notification Trigger"::RENEWAL:
                begin
                    // Notification Date is offset from subscription ends
                    StartDate := CalcDate('<+1D>', MembershipNotification."Date To Notify" + NotificationSetup."Days Before");
                    if (StartDate < Today) then
                        StartDate := Today();

                    if (MembershipManagement.GetMembershipValidDate(MembershipNotification."Membership Entry No.", StartDate, FromDate, UntilDate)) then
                        exit(-1); // membership is valid, cancel notification

                    if (FromDate > Today) then
                        exit(-1); // Valid in the future, but not on startdate, cancel notification

                    exit(1); // Send notification
                end;

            MembershipNotification."Notification Trigger"::WELCOME:
                begin
                    // Notification Date is offset from subscription starts
                    StartDate := MembershipNotification."Date To Notify";
                    if (StartDate < Today) then
                        StartDate := Today();

                    if (MembershipManagement.GetMembershipValidDate(MembershipNotification."Membership Entry No.", StartDate, FromDate, UntilDate)) then
                        exit(1); // valid, send notification

                    if (FromDate > Today) then
                        exit(0); //wait until membership becomes active

                    if (FromDate = 0D) then
                        exit(0); //wait until membership becomes active, not yet activated

                    exit(-1); // Cancel welcome notification
                end;
            MembershipNotification."Notification Trigger"::WALLET_CREATE,
            MembershipNotification."Notification Trigger"::WALLET_UPDATE:
                begin
                    // Notification Date is offset from subscription starts
                    StartDate := MembershipNotification."Date To Notify";
                    if (StartDate < Today) then
                        StartDate := Today();

                    if (MembershipManagement.GetMembershipValidDate(MembershipNotification."Membership Entry No.", StartDate, FromDate, UntilDate)) then
                        exit(1); // valid, send notification

                    exit(0); // Wait for the membership to become active
                end;
            MembershipNotification."Notification Trigger"::COUPON:
                begin
                    if (not Coupon.Get(MembershipNotification."Coupon No.")) then
                        exit(0); // Coupon not created yet or not valid

                    if ((Coupon."Ending Date" > CreateDateTime(0D, 0T)) and (Coupon."Ending Date" < CurrentDateTime())) then
                        exit(-1); // Coupon has expired - cancel notification

                    exit(1); // Send
                end;
        end;

        exit(-1);
    end;

    local procedure CreateRecipients(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MembershipRole: Record "NPR MM Membership Role";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        Coupon: Record "NPR NpDc Coupon";
        Method: Code[10];
        EMailLbl: Label '%1?email=%2', Locked = true;
    begin

        NotificationSetup.Get(MembershipNotification."Notification Code");

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipNotification."Membership Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        if (MembershipNotification."Member Entry No." <> 0) then begin
            MembershipRole.SetFilter("Member Entry No.", '=%1', MembershipNotification."Member Entry No.");
        end else begin
            if (MembershipNotification."Target Member Role" <> MembershipNotification."Target Member Role"::ALL_MEMBERS) then
                MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        end;

        if (MembershipRole.FindSet()) then begin
            repeat
                MembershipRole.CalcFields("Membership Code", "External Membership No.");
                Member.Get(MembershipRole."Member Entry No.");

                Membership.Get(MembershipRole."Membership Entry No.");

                if (not Member.Blocked) then begin
                    if (MemberNotificationEntry.Get(MembershipNotification."Entry No.", Member."Entry No.")) then begin
                        if ((not MemberNotificationEntry.Blocked) or
                            (not (MemberNotificationEntry."Notification Send Status" = MemberNotificationEntry."Notification Send Status"::SENT))) then
                            MemberNotificationEntry.Delete();
                    end;

                    MemberNotificationEntry.Init();
                    MemberNotificationEntry.TransferFields(MembershipNotification, true);

                    MemberNotificationEntry."Auto-Renew" := Membership."Auto-Renew";
                    MemberNotificationEntry."Auto-Renew External Data" := Membership."Auto-Renew External Data";
                    MemberNotificationEntry."Auto-Renew Payment Method Code" := Membership."Auto-Renew Payment Method Code";
                    MemberNotificationEntry."Customer No." := Membership."Customer No.";

                    MemberNotificationEntry."Member Entry No." := Member."Entry No.";
                    MemberNotificationEntry."External Member No." := Member."External Member No.";
                    MemberNotificationEntry."E-Mail Address" := Member."E-Mail Address";
                    MemberNotificationEntry."First Name" := Member."First Name";
                    MemberNotificationEntry."Middle Name" := Member."Middle Name";
                    MemberNotificationEntry."Last Name" := Member."Last Name";
                    MemberNotificationEntry."Display Name" := Member."Display Name";
                    MemberNotificationEntry.Address := Member.Address;
                    MemberNotificationEntry."Post Code Code" := Member."Post Code Code";
                    MemberNotificationEntry.City := Member.City;
                    MemberNotificationEntry."Country Code" := Member."Country Code";
                    MemberNotificationEntry.Country := Member.Country;
                    MemberNotificationEntry.Birthday := Member.Birthday;
                    MemberNotificationEntry."Phone No." := Member."Phone No.";

                    MemberNotificationEntry."Contact No." := MembershipRole."Contact No.";
                    MemberNotificationEntry."Community Code" := MembershipRole."Community Code";
                    MemberNotificationEntry."Membership Code" := MembershipRole."Membership Code";
                    MemberNotificationEntry."External Membership No." := MembershipRole."External Membership No.";

                    if (MemberCommunity.Get(MemberNotificationEntry."Community Code")) then
                        MemberNotificationEntry."Community Description" := MemberCommunity.Description;

                    if (MembershipSetup.Get(MemberNotificationEntry."Membership Code")) then
                        MemberNotificationEntry."Membership Description" := MembershipSetup.Description;

                    if (MembershipNotification."Member Card Entry No." = 0) then begin
                        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
                        MemberCard.SetFilter("Member Entry No.", '=%1', MembershipRole."Member Entry No.");
                        MemberCard.SetFilter(Blocked, '=%1', false);
                    end else begin
                        MemberCard.SetFilter("Entry No.", '=%1', MembershipNotification."Member Card Entry No.");
                    end;

                    if (MemberCard.FindLast()) then begin
                        MemberNotificationEntry."External Member Card No." := MemberCard."External Card No.";
                        MemberNotificationEntry."Pin Code" := MemberCard."Pin Code";
                        MemberNotificationEntry."Card Valid Until" := MemberCard."Valid Until";
                    end;

                    MembershipManagement.GetMembershipValidDate(MembershipNotification."Membership Entry No.", MembershipNotification."Date To Notify",
                      MemberNotificationEntry."Membership Valid From",
                      MemberNotificationEntry."Membership Valid Until");

                    MembershipManagement.GetConsecutiveTimeFrame(MembershipNotification."Membership Entry No.", MembershipNotification."Date To Notify",
                      MemberNotificationEntry."Membership Consecutive From",
                      MemberNotificationEntry."Membership Consecutive Until");

                    MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                    MembershipEntry.SetFilter(Blocked, '=%1', false);
                    MembershipEntry.SetFilter("Valid From Date", '=%1', MemberNotificationEntry."Membership Valid From");
                    MembershipEntry.SetFilter("Valid Until Date", '=%1', MemberNotificationEntry."Membership Valid Until");
                    if (not MembershipEntry.FindLast()) then
                        MembershipEntry.Init();
                    MemberNotificationEntry."Item No." := MembershipEntry."Item No.";

                    if (MemberNotificationEntry."Card Valid Until" = 0D) then
                        MemberNotificationEntry."Card Valid Until" := MemberNotificationEntry."Membership Valid Until";

                    case MemberNotificationEntry."Notification Trigger" of
                        MemberNotificationEntry."Notification Trigger"::WELCOME:
                            MembershipManagement.GetCommunicationMethod_Welcome(MemberNotificationEntry."Member Entry No.", MemberNotificationEntry."Membership Entry No.", Method, MemberNotificationEntry.Address, MemberNotificationEntry."Notification Engine");
                        MemberNotificationEntry."Notification Trigger"::RENEWAL:
                            MembershipManagement.GetCommunicationMethod_Renew(MemberNotificationEntry."Member Entry No.", MemberNotificationEntry."Membership Entry No.", Method, MemberNotificationEntry.Address, MemberNotificationEntry."Notification Engine");
                        MemberNotificationEntry."Notification Trigger"::WALLET_CREATE:
                            MembershipManagement.GetCommunicationMethod_MemberCard(MemberNotificationEntry."Member Entry No.", MemberNotificationEntry."Membership Entry No.", Method, MemberNotificationEntry.Address, MemberNotificationEntry."Notification Engine");
                        MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE:
                            MembershipManagement.GetCommunicationMethod_MemberCard(MemberNotificationEntry."Member Entry No.", MemberNotificationEntry."Membership Entry No.", Method, MemberNotificationEntry.Address, MemberNotificationEntry."Notification Engine");
                        MemberNotificationEntry."Notification Trigger"::COUPON:
                            MembershipManagement.GetCommunicationMethod_Coupon(MemberNotificationEntry."Member Entry No.", MemberNotificationEntry."Membership Entry No.", Method, MemberNotificationEntry.Address, MemberNotificationEntry."Notification Engine");
                    end;

                    case Method of
                        'SMS':
                            MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::SMS;
                        'W-SMS':
                            MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::SMS;
                        'EMAIL':
                            MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::EMAIL;
                        'W-EMAIL':
                            MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::EMAIL;
                        else
                            MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::NONE;
                    end;

                    if (MembershipNotification."Notification Method Source" = MembershipNotification."Notification Method Source"::EXTERNAL) then
                        MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::MANUAL;

                    MemberNotificationEntry."Include NP Pass" := ((MembershipSetup."Enable NP Pass Integration") and (MembershipNotification."Include NP Pass"));

                    MembershipRole."Notification Token" := GenerateNotificationToken();
                    MembershipRole.Modify();
                    MemberNotificationEntry."Notification Token" := MembershipRole."Notification Token";

                    MemberNotificationEntry."Magento Get Password URL" := NotificationSetup."Fallback Magento PW URL";
                    if (Member."E-Mail Address" <> '') then
                        MemberNotificationEntry."Magento Get Password URL" := StrSubstNo(EMailLbl, NotificationSetup."Fallback Magento PW URL", Member."E-Mail Address");

                    if (NotificationSetup."Generate Magento PW URL") then
                        RequestMagentoPasswordUrl(Membership."Customer No.", MembershipRole."Contact No.", Member."E-Mail Address", MemberNotificationEntry."Magento Get Password URL", MemberNotificationEntry."Failed With Message");

                    if (MembershipNotification."Notification Trigger" = MembershipNotification."Notification Trigger"::COUPON) then begin
                        if (not Coupon.Get(MembershipNotification."Coupon No.")) then
                            Coupon.Init();
                        MemberNotificationEntry."Coupon Reference No." := Coupon."Reference No.";
                        MemberNotificationEntry."Coupon Description" := Coupon.Description;
                        MemberNotificationEntry."Coupon Discount %" := Coupon."Discount %";
                        MemberNotificationEntry."Coupon Discount Amount" := Coupon."Discount Amount";
                        MemberNotificationEntry."Coupon Discount Type" := Coupon."Discount Type";
                        MemberNotificationEntry."Coupon Ending Date" := Coupon."Ending Date";
                        MemberNotificationEntry."Coupon Starting Date" := Coupon."Starting Date";
                    end;

                    if (MemberNotificationEntry.Insert()) then;
                end;
            until ((MembershipRole.Next() = 0) or (MembershipNotification."Target Member Role" = MembershipNotification."Target Member Role"::FIRST_ADMIN));
        end;
    end;

    local procedure NotifyRecipients(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberNotificationEntry2: Record "NPR MM Member Notific. Entry";
        ResponseMessage: Text;
        SendStatus: Option;
    begin

        MemberNotificationEntry.SetFilter("Notification Entry No.", '=%1', MembershipNotification."Entry No.");
        MemberNotificationEntry.SetFilter("Notification Send Status", '=%1', MemberNotificationEntry."Notification Send Status"::PENDING);
        MemberNotificationEntry.SetFilter(Blocked, '=%1', false);

        if (MemberNotificationEntry.FindSet()) then begin
            Commit();
            repeat

                MemberNotificationEntry2.Get(MemberNotificationEntry."Notification Entry No.", MemberNotificationEntry."Member Entry No.");

                SendStatus := MemberNotificationEntry2."Notification Send Status"::FAILED;
                MemberNotificationEntry2."Notification Send Status" := SendStatus;
                MemberNotificationEntry2."Notification Sent At" := CurrentDateTime();
                MemberNotificationEntry2."Notification Sent By User" := CopyStr(UserId, 1, MaxStrLen(MemberNotificationEntry2."Notification Sent By User"));
                MemberNotificationEntry2."Failed With Message" := 'Failed during processing of send message. (Preemptive message.)';
                MemberNotificationEntry2.Modify();
                Commit();

                case MemberNotificationEntry2."Notification Method" of
                    MemberNotificationEntry2."Notification Method"::NONE:
                        begin
                            SendStatus := MemberNotificationEntry2."Notification Send Status"::NOT_SENT;
                        end;

                    MemberNotificationEntry2."Notification Method"::EMAIL:
                        begin
                            if (MemberNotificationEntry2."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry2);
                                MemberNotificationEntry2.Modify();
                                if (MemberNotificationEntry2."Notification Trigger" = MemberNotificationEntry2."Notification Trigger"::WALLET_UPDATE) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                            end;

                            if (MemberNotificationEntry2."Notification Trigger" <> MemberNotificationEntry2."Notification Trigger"::WALLET_UPDATE) then
                                if (SendMail(MemberNotificationEntry2, ResponseMessage)) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    MemberNotificationEntry2."Notification Method"::SMS:
                        begin
                            if (MemberNotificationEntry2."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry2);
                                MemberNotificationEntry2.Modify();
                                if (MemberNotificationEntry2."Notification Trigger" = MemberNotificationEntry2."Notification Trigger"::WALLET_UPDATE) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                            end;

                            if (MemberNotificationEntry2."Notification Trigger" <> MemberNotificationEntry2."Notification Trigger"::WALLET_UPDATE) then
                                if (SendSMS(MemberNotificationEntry2, ResponseMessage)) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    MemberNotificationEntry2."Notification Method"::MANUAL:
                        begin
                            if (MemberNotificationEntry2."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry2);
                                MemberNotificationEntry2.Modify();
                            end;

                            SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    else
                        Error(NOT_IMPLEMENTED, MemberNotificationEntry2.FieldCaption("Notification Method"), MemberNotificationEntry2."Notification Method");
                end;

                MemberNotificationEntry2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(MemberNotificationEntry2."Failed With Message"));
                MemberNotificationEntry2."Notification Send Status" := SendStatus;
                MemberNotificationEntry2.Modify();
                Commit();

            until (MemberNotificationEntry.Next() = 0);
        end;
    end;

    local procedure CreateNextNotification(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MembershipNotification2: Record "NPR MM Membership Notific.";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        NotificationSetup2: Record "NPR MM Member Notific. Setup";
    begin

        NotificationSetup.Get(MembershipNotification."Notification Code");

        if (NotificationSetup."Next Notification Code" = '') then
            exit;

        if (not NotificationSetup2.Get(NotificationSetup."Next Notification Code")) then
            exit;

        MembershipNotification2.Init();
        MembershipNotification2."Entry No." := 0;
        MembershipNotification2."Membership Entry No." := MembershipNotification."Membership Entry No.";
        MembershipNotification2."Notification Code" := NotificationSetup2.Code;
        MembershipNotification2."Notification Trigger" := MembershipNotification."Notification Trigger";

        case MembershipNotification."Notification Trigger" of
            MembershipNotification."Notification Trigger"::RENEWAL:
                MembershipNotification2."Date To Notify" := MembershipNotification."Date To Notify" + NotificationSetup."Days Before" - NotificationSetup2."Days Before";

            MembershipNotification."Notification Trigger"::WELCOME:
                MembershipNotification2."Date To Notify" := MembershipNotification."Date To Notify" - NotificationSetup."Days Past" + NotificationSetup2."Days Past";

            else
                Error(NOT_IMPLEMENTED, MembershipNotification.FieldCaption("Notification Trigger"), MembershipNotification."Notification Trigger");
        end;

        MembershipNotification2."Template Filter Value" := NotificationSetup2."Template Filter Value";
        MembershipNotification2."Target Member Role" := NotificationSetup2."Target Member Role";
        MembershipNotification2.Insert();
    end;

    local procedure SendMail(MemberNotificationEntry: Record "NPR MM Member Notific. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "NPR E-mail Management";
    begin

        RecordRef.GetTable(MemberNotificationEntry);

        ResponseMessage := 'E-Mail address is missing.';
        if (MemberNotificationEntry."E-Mail Address" <> '') then begin
            case MemberNotificationEntry."Notification Engine" OF
                MemberNotificationEntry."Notification Engine"::M2_EMAILER:
                    ResponseMessage := SendEmailUsingM2Engine(MemberNotificationEntry);
                MemberNotificationEntry."Notification Engine"::NATIVE:
                    ResponseMessage := EMailMgt.SendEmail(RecordRef, MemberNotificationEntry."E-Mail Address", true);
            end;
        end;

        exit(ResponseMessage = '');
    end;

    local procedure SendSMS(MemberNotificationEntry: Record "NPR MM Member Notific. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(MemberNotificationEntry);

        if (MemberNotificationEntry."Phone No." = '') then
            ResponseMessage := 'Phone number is missing.';

        if (DelChr(MemberNotificationEntry."Phone No.", '<=>', '+1234567890 ') <> '') then begin
            ResponseMessage := 'Phone number is not valid.';
            exit(false);
        end;

        if (MemberNotificationEntry."Phone No." <> '') then begin
            Commit();
            ResponseMessage := 'Template not found.';
            if (SMSManagement.FindTemplate(RecordRef, SMSTemplateHeader)) then begin
                SmsBody := SMSManagement.MakeMessage(SMSTemplateHeader, MemberNotificationEntry);
                SMSManagement.SendSMS(MemberNotificationEntry."Phone No.", SMSTemplateHeader."Alt. Sender", SmsBody);
                ResponseMessage := '';
            end;
        end;

        exit(ResponseMessage = '');
    end;

    internal procedure AddMemberWelcomeNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer) NotificationEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin

        Membership.Get(MembershipEntryNo);

        NotificationSetup.SetCurrentKey(Type, "Community Code", "Membership Code", "Days Past");
        NotificationSetup.SetFilter(Type, '=%1', NotificationSetup.Type::WELCOME);
        NotificationSetup.SetFilter("Community Code", '=%1', Membership."Community Code");
        NotificationSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        NotificationSetup.SetFilter("Days Past", '0..');
        if (not NotificationSetup.FindFirst()) then begin
            NotificationSetup.SetFilter("Membership Code", '=%1', '');
            if (not NotificationSetup.FindFirst()) then begin
                NotificationSetup.SetFilter("Community Code", '=%1', '');
                if (not NotificationSetup.FindFirst()) then
                    exit(0);
            end;
        end;

        MembershipNotification.Reset();
        MembershipNotification.Init();
        MembershipNotification."Membership Entry No." := MembershipEntryNo;
        MembershipNotification."Member Entry No." := MemberEntryNo;

        MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PENDING;
        MembershipNotification."Notification Code" := NotificationSetup.Code;
        MembershipNotification."Date To Notify" := Today + NotificationSetup."Days Past";
        MembershipNotification."Notification Trigger" := MembershipNotification."Notification Trigger"::WELCOME;
        MembershipNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
        MembershipNotification."Target Member Role" := NotificationSetup."Target Member Role";

        MembershipNotification."Processing Method" := NotificationSetup."Processing Method";
        MembershipNotification."Include NP Pass" := NotificationSetup."Include NP Pass";

        MembershipNotification.Insert();

        exit(MembershipNotification."Entry No.");
    end;

    internal procedure RefreshAllMembershipRenewalNotifications(MembershipCode: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        CommunitySetup: Record "NPR MM Member Community";
        Window: Dialog;
        CurrentCount: Integer;
        MaxCount: Integer;
    begin

        Membership.SetFilter("Membership Code", '=%1', MembershipCode);
        if (Membership.FindSet()) then begin
            if (GuiAllowed()) then
                Window.Open(REFRESH_NOTIFICATION);

            MaxCount := Membership.Count();
            MembershipSetup.Get(MembershipCode);
            CommunitySetup.Get(MembershipSetup."Community Code");

            repeat

                MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipEntry.SetFilter(Blocked, '=%1', false);
                MembershipEntry.SetFilter(Context, '%1..%2|%3', MembershipEntry.Context::NEW, MembershipEntry.Context::EXTEND, MembershipEntry.Context::AUTORENEW);

                if (MembershipEntry.FindLast()) then
                    if (MembershipEntry."Valid Until Date" > Today) then
                        AddMembershipRenewalNotificationWorker(MembershipEntry, MembershipSetup, CommunitySetup);

                if (GuiAllowed()) then
                    Window.Update(1, Round(CurrentCount / MaxCount * 10000, 1));

                CurrentCount += 1;

            until (Membership.Next() = 0);

            if (GuiAllowed()) then
                Window.Close();
        end;

    end;

    procedure AddMembershipRenewalNotification(MembershipLedgerEntry: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        CommunitySetup: Record "NPR MM Member Community";
    begin

        Membership.Get(MembershipLedgerEntry."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");
        CommunitySetup.Get(MembershipSetup."Community Code");

        AddMembershipRenewalNotificationWorker(MembershipLedgerEntry, MembershipSetup, CommunitySetup);

    end;

    local procedure AddMembershipRenewalNotificationWorker(MembershipLedgerEntry: Record "NPR MM Membership Entry"; MembershipSetup: Record "NPR MM Membership Setup"; CommunitySetup: Record "NPR MM Member Community")
    var
        Membership: Record "NPR MM Membership";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
        DaysToRenewal: Integer;
    begin

        Membership.Get(MembershipLedgerEntry."Membership Entry No.");

        MembershipNotification.SetCurrentKey("Membership Entry No.");
        MembershipNotification.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipNotification.SetFilter("Notification Trigger", '=%1', MembershipNotification."Notification Trigger"::RENEWAL);
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        if (MembershipNotification.FindSet(true, true)) then begin
            repeat
                MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::CANCELED;
                MembershipNotification."Notification Processed At" := CurrentDateTime();
                MembershipNotification."Notification Processed By User" := CopyStr(UserId, 1, MaxStrLen(MembershipNotification."Notification Processed By User"));
                MembershipNotification.Modify();
            until (MembershipNotification.Next() = 0);
        end;

        if (not ((MembershipSetup."Create Renewal Notifications") or (CommunitySetup."Create Renewal Notifications"))) then
            exit;

        DaysToRenewal := MembershipLedgerEntry."Valid Until Date" - Today();

        NotificationSetup.SetCurrentKey(Type, "Community Code", "Membership Code", "Days Before");
        NotificationSetup.SetFilter(Type, '=%1', NotificationSetup.Type::RENEWAL);
        NotificationSetup.SetFilter("Community Code", '=%1', Membership."Community Code");
        NotificationSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        NotificationSetup.SetFilter("Days Before", '1..%1', DaysToRenewal);
        if (not NotificationSetup.FindLast()) then begin
            NotificationSetup.SetFilter("Membership Code", '=%1', '');
            if (not NotificationSetup.FindLast()) then begin
                NotificationSetup.SetFilter("Community Code", '=%1', '');
                if (not NotificationSetup.FindLast()) then
                    exit;
            end;
        end;

        MembershipNotification.Reset();
        MembershipNotification.Init();
        MembershipNotification."Entry No." := 0;
        MembershipNotification."Membership Entry No." := MembershipLedgerEntry."Membership Entry No.";
        MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PENDING;
        MembershipNotification."Notification Code" := NotificationSetup.Code;
        MembershipNotification."Date To Notify" := MembershipLedgerEntry."Valid Until Date" - NotificationSetup."Days Before";
        MembershipNotification."Notification Trigger" := MembershipNotification."Notification Trigger"::RENEWAL;
        MembershipNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
        MembershipNotification."Target Member Role" := NotificationSetup."Target Member Role";

        MembershipNotification.Insert();
    end;

    internal procedure GenerateNotificationToken() Token: Text[64]
    var
        n: Integer;
    begin

        Randomize();
#pragma warning disable AA0139
        Token := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
#pragma warning restore
        for n := StrLen(Token) to MaxStrLen(Token) do begin
            case Random(3) of
                1:
                    Token[n] := 3 * 16 + Random(10) - 1; // 3*16 = 48    -> '0'
                2:
                    Token[n] := 4 * 16 + Random(25);     // 4*16 = 64 +1 -> 'A'
                3:
                    Token[n] := 6 * 16 + Random(25);     // 6*16 = 96 +1 -> 'a'
            end;
        end;

    end;

    local procedure SendEmailUsingM2Engine(MemberNotificationEntry: Record "NPR MM Member Notific. Entry") ResponseMessage: Text;
    var
        MemberCommunicationSetup: Record "NPR MM Member Comm. Setup";
        TemplateData: Text;
        TemplateText: Text;
        IStream: InStream;
        RecRef: RecordRef;
        MessageBody: JsonToken;
        MessageResponse: JsonToken;
        TemplateNotDefinedLbl: Label 'The template for Notification Engine %1 has not been defined for %2 %3.';
        PlaceHolderLbl: Label '%1 - %2', Locked = true;
    begin

        case MemberNotificationEntry."Notification Trigger" OF
            MemberNotificationEntry."Notification Trigger"::RENEWAL:
                MemberCommunicationSetup.Get(MemberNotificationEntry."Membership Code", MemberCommunicationSetup."Message Type"::RENEW);
            MemberNotificationEntry."Notification Trigger"::WELCOME:
                MemberCommunicationSetup.Get(MemberNotificationEntry."Membership Code", MemberCommunicationSetup."Message Type"::WELCOME);
            MemberNotificationEntry."Notification Trigger"::WALLET_CREATE:
                MemberCommunicationSetup.Get(MemberNotificationEntry."Membership Code", MemberCommunicationSetup."Message Type"::MEMBERCARD);
            MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE:
                MemberCommunicationSetup.Get(MemberNotificationEntry."Membership Code", MemberCommunicationSetup."Message Type"::MEMBERCARD);
            else
                MemberCommunicationSetup.Get(MemberNotificationEntry."Membership Code", MemberCommunicationSetup."Message Type"::WELCOME);
        end;

        MemberCommunicationSetup.CalcFields("Sender Template");
        if (not MemberCommunicationSetup."Sender Template".HasValue()) then
            exit(StrSubstNo(TemplateNotDefinedLbl, MemberCommunicationSetup."Notification Engine", MemberCommunicationSetup."Membership Code", MemberCommunicationSetup."Message Type"));

        RecRef.GetTable(MemberNotificationEntry);
        MemberCommunicationSetup."Sender Template".CreateInStream(IStream);
        while (not IStream.EOS()) do begin
            IStream.ReadText(TemplateText);
            TemplateData += AssignDataToPassTemplate(RecRef, TemplateText);
        end;

        MessageBody.ReadFrom(TemplateData);
        if (not MagentoApiPost_Membership('welcome-email', MessageBody, MessageResponse)) then begin
            ResponseMessage := CopyStr(StrSubstNo(PlaceHolderLbl, GetLastErrorText(), MessageBody), 1, MaxStrLen(ResponseMessage));
            exit(ResponseMessage);
        end;

        exit('');

    end;

    local procedure CreateNpPass(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry")
    var
        PassData: Text;
        RecRef: RecordRef;
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        IStream: InStream;
        templateText: Text;
    begin

        MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code");
        if (not MemberNotificationSetup."Include NP Pass") then
            exit;

        RecRef.GetTable(MemberNotificationEntry);

        MemberNotificationSetup.CalcFields("PUT Passes Template");
        if (MemberNotificationSetup."PUT Passes Template".HasValue()) then begin
            MemberNotificationSetup."PUT Passes Template".CreateInStream(IStream);
            while (not IStream.EOS()) do begin
                IStream.ReadText(templateText);
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;
        end else begin
            templateText := GetDefaultWalletTemplate();
            PassData += AssignDataToPassTemplate(RecRef, templateText);
        end;

        if (CreatePass(MemberNotificationEntry, PassData)) then
            SetPassUrl(MemberNotificationEntry);
    end;

    local procedure CreatePass(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry"; PassData: Text): Boolean
    var
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipRole: Record "NPR MM Membership Role";
        JSONResult: Text;
        FailReason: Text;
    begin

        MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code");
        MembershipRole.Get(MemberNotificationEntry."Membership Entry No.", MemberNotificationEntry."Member Entry No.");

        if (MembershipRole."Wallet Pass Id" = '') then begin
#pragma warning disable AA0139
            MembershipRole."Wallet Pass Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
#pragma warning restore
            MembershipRole.Modify();
        end;

        MemberNotificationEntry."Wallet Pass Id" := MembershipRole."Wallet Pass Id";

        exit(NPPassServerInvokeApi('PUT', MemberNotificationSetup, MemberNotificationEntry."Wallet Pass Id", FailReason, PassData, JSONResult));
    end;

    local procedure SetPassUrl(var MemberNotificationEntry: Record "NPR MM Member Notific. Entry"): Boolean
    var
        MemberNotificationSetup: Record "NPR MM Member Notific. Setup";
        JSONResult: Text;
        FailReason: Text;
        JObject: JsonObject;
    begin

        if (not MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code")) then
            exit(false);

        if (not (NPPassServerInvokeApi('GET', MemberNotificationSetup, MemberNotificationEntry."Wallet Pass Id", FailReason, '', JSONResult))) then
            exit(false);

        if (JSONResult = '') then
            exit(false);

        JObject.ReadFrom(JSONResult);
        MemberNotificationEntry."Wallet Pass Default URL" := CopyStr(GetStringValue(JObject, 'public_url.default'), 1, MaxStrLen(MemberNotificationEntry."Wallet Pass Default URL"));
        MemberNotificationEntry."Wallet Pass Andriod URL" := CopyStr(GetStringValue(JObject, 'public_url.android'), 1, MaxStrLen(MemberNotificationEntry."Wallet Pass Andriod URL"));
        MemberNotificationEntry."Wallet Pass Landing URL" := CopyStr(GetStringValue(JObject, 'public_url.landing'), 1, MaxStrLen(MemberNotificationEntry."Wallet Pass Landing URL"));

        exit(true);
    end;

    local procedure GetStringValue(JObject: JsonObject; "Key": Text): Text
    var
        JToken: JsonToken;
        TokenStringValue: Text;
    begin
        if (not JObject.SelectToken(Key, JToken)) then
            exit('');

        TokenStringValue := JToken.AsValue().AsText();
        exit(TokenStringValue);
    end;

    internal procedure AssignDataToPassTemplate(var RecRef: RecordRef; Line: Text) NewLine: Text
    var
        FieldRef: FieldRef;
        EndPos: Integer;
        FieldNumber: Integer;
        i: Integer;
        OptionInt: Integer;
        StartPos: Integer;
        OptionCaption: Text[1024];
        StartSeparator: Text[10];
        EndSeparator: Text[10];
        SeparatorLength: Integer;
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MemberEntryNo: Integer;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        B64Image: Text;
    begin
        StartSeparator := '{[';
        EndSeparator := ']}';
        SeparatorLength := StrLen(StartSeparator);

        NewLine := Line;
        while (StrPos(NewLine, StartSeparator) > 0) do begin
            StartPos := StrPos(NewLine, StartSeparator);
            EndPos := StrPos(NewLine, EndSeparator);

            Evaluate(FieldNumber, CopyStr(NewLine, StartPos + SeparatorLength, EndPos - StartPos - SeparatorLength));
            if (RecRef.FieldExist(FieldNumber)) then begin

                FieldRef := RecRef.Field(FieldNumber);
                if (UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD') then
                    FieldRef.CalcField();

                NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);

                if (UpperCase(Format(Format(FieldRef.Type)))) = 'OPTION' then begin
                    OptionCaption := Format(FieldRef.OptionMembers);
                    Evaluate(OptionInt, Format(FieldRef.Value));
                    for i := 1 to OptionInt do
                        OptionCaption := DelStr(OptionCaption, 1, StrPos(OptionCaption, ','));
                    if (StrPos(OptionCaption, ',') <> 0) then
                        OptionCaption := DelStr(OptionCaption, StrPos(OptionCaption, ','));
                    NewLine := InsStr(NewLine, OptionCaption, StartPos);
                end else begin
                    NewLine := InsStr(NewLine, DelChr(Format(FieldRef.Value, 0, 9), '<=>', '"'), StartPos);
                end;
            end else
                case FieldNumber of
                    -100: // thumbnail
                        begin
                            FieldRef := RecRef.Field(MemberNotificationEntry.FieldNo("Member Entry No."));
                            MemberEntryNo := FieldRef.Value;

                            NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);
                            if (not MembershipManagement.GetMemberImage(MemberEntryNo, B64Image)) then
                                B64Image := '';
                            NewLine := InsStr(NewLine, B64Image, StartPos);
                        end;
                    else
                        Error(BAD_REFERENCE, FieldNumber, Line);
                end;
            Line := NewLine;
        end;

        exit(NewLine);
    end;

    internal procedure GetDefaultWalletTemplate() template: Text
    var
        CRLF: Text[2];
    begin

        // template := '{"data":{"expiration_date": "{[161]}","member": {"name": "{[123]}","email": "{[110]}"},"membership": {"type": "{[156]}","valid_from": "{[153]}","valid_to": "{[154]}","barcode": {"alt_text": "{[160]}","value": "{[160]}"}}}}';
        CRLF[1] := 13;
        CRLF[2] := 10;
        template :=
        '{"data":{' + CRLF +
            '"expiration_date": "{[161]}T23:59:59+01:00",' + CRLF +
            '"member": {' + CRLF +
            '    "name": "{[123]}",' + CRLF +
            '    "email": "{[110]}"' + CRLF +
            '},' + CRLF +
            '"membership": {' + CRLF +
            '    "type": "{[156]}",' + CRLF +
            '    "valid_from": "{[153]}",' + CRLF +
            '    "valid_to": "{[154]}",' + CRLF +
            '    "points": "{[170]}",' + CRLF +
            '    "barcode": {' + CRLF +
            '        "alt_text": "{[160]}",' + CRLF +
            '        "value": "{[160]}"' + CRLF +
            '    }' + CRLF +
            '},' + CRLF +
            '"images": [' + CRLF +
            '    {' + CRLF +
            '        "type": "thumbnail",' + CRLF +
            '        "content": "{[-100]}"' + CRLF +
            '    }' + CRLF +
            ']' + CRLF +
            '}}';

        exit(template);
    end;

    local procedure RequestMagentoPasswordUrl(CustomerNo: Code[20]; ContactNo: Code[20]; EmailAddress: Text[200]; var ResponseUrl: Text[200]; var ReasonText: Text[250]): Boolean
    var
        Customer: Record Customer;
        Contact: Record Contact;
        MessageText: Text;
        Body: JsonToken;
        Response: JsonToken;
        ResponseText: Text;
        Request1Lbl: Label '{"id":"%1","storecode":"%2"}', Locked = true;
        Request2Lbl: Label '{"account": {"email":"%1", "accounts":[%2]}}', Locked = true;
    begin

        if (not Customer.Get(CustomerNo)) then
            exit;

        if (not Contact.Get(ContactNo)) then
            exit;

        if (not Contact."NPR Magento Contact") then
            exit;

        MessageText := StrSubstNo(Request1Lbl, ContactNo, Customer."NPR Magento Store Code");
        Body.ReadFrom(StrSubstNo(Request2Lbl, EmailAddress, MessageText));

        if (not MagentoApiPost_b2b_customer('password-reset-link', Body, Response)) then begin
            ReasonText := CopyStr(GetLastErrorText, 1, MaxStrLen(ReasonText));
            exit;
        end;

        if (not GetMagentoMessageUrl(Response, ResponseText)) then begin
            ReasonText := CopyStr(GetLastErrorText, 1, MaxStrLen(ReasonText));
            exit;
        end;

        ResponseUrl := CopyStr(ResponseText, 1, MaxStrLen(ResponseUrl));
        exit(true);
    end;

    [TryFunction]
    local procedure GetMagentoMessageUrl(Json: JsonToken; var Url: Text)
    var
        JToken: JsonToken;
    begin

        Url := '';
        if Json.SelectToken('messages.success[0].message', JToken) then
            Url := JToken.AsValue().AsText();
    end;

    internal procedure MagentoApiPost(ApiUrl: Text; Method: Text; var Body: JsonToken; var Result: JsonToken)
    var
        MagentoSetup: Record "NPR Magento Setup";
        WebClient: HttpClient;
        HttpRequestHeader: HttpHeaders;
        HttpContentHeader: HttpHeaders;
        Content: HttpContent;
        WebResponse: HttpResponseMessage;
        ResponseText: Text;
        BodyText: Text;
        ContentTypeLabel: Label 'Content-Type', Locked = true;
        ContentTypeValueLabel: Label 'naviconnect/json', Locked = true;
        AuthorizationLabel: Label 'Authorization', Locked = true;
        BasicAuthLbl: Label 'Basic %1', Locked = true;
    begin
        if (Method = '') then
            exit;
        MagentoSetup.Get();
        ResponseText := '{}';

        Body.WriteTo(BodyText);
        Content.WriteFrom(BodyText);
        Content.GetHeaders(HttpContentHeader);
        SetHttpHeaderValue(HttpContentHeader, ContentTypeLabel, ContentTypeValueLabel);

        HttpRequestHeader := WebClient.DefaultRequestHeaders();
        if (MagentoSetup."Api Authorization" <> '') then
            SetHttpHeaderValue(HttpRequestHeader, AuthorizationLabel, MagentoSetup."Api Authorization");

        if (MagentoSetup."Api Authorization" = '') then
            SetHttpHeaderValue(HttpRequestHeader, AuthorizationLabel, StrSubstNo(BasicAuthLbl, MagentoSetup.GetBasicAuthInfo()));

        WebClient.Timeout := 1000 * 60;
        WebClient.Post(ApiUrl + Method, Content, WebResponse);
        if (WebResponse.IsSuccessStatusCode()) then begin
            if WebResponse.Content.ReadAs(ResponseText) then
                Result.ReadFrom(ResponseText);
            exit;
        end;

        Error('%1 - %2', WebResponse.HttpStatusCode, WebResponse.ReasonPhrase);
    end;

    local procedure SetHttpHeaderValue(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text);
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

    [TryFunction]
    internal procedure MagentoApiPost_b2b_customer(Method: Text; var Body: JsonToken; var Result: JsonToken)
    var
        MagentoSetup: Record "NPR Magento Setup";
        ApiUrl: Text;
    begin

        MagentoSetup.Get();
        MagentoSetup.TestField("Api Url");
        if (MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/') then
            MagentoSetup."Api Url" += '/';

        if (CopyStr(MagentoSetup."Api Url", StrLen(MagentoSetup."Api Url") - (StrLen('naviconnect/')) + 1) = 'naviconnect/') then
            ApiUrl := CopyStr(MagentoSetup."Api Url", 1, StrLen(MagentoSetup."Api Url") - (StrLen('naviconnect/'))) + 'b2b_customer/';

        MagentoApiPost(ApiUrl, Method, Body, Result)

    end;

    [TryFunction]
    internal procedure MagentoApiPost_Membership(Method: Text; var Body: JsonToken; var Result: JsonToken)
    var
        MagentoSetup: Record "NPR Magento Setup";
        ApiUrl: Text;
        ApiLbl: Label '%1membership/', Locked = true;
    begin

        MagentoSetup.Get();
        MagentoSetup.TestField("Api Url");
        if (MagentoSetup."Api Url"[STRLEN(MagentoSetup."Api Url")] <> '/') then
            MagentoSetup."Api Url" += '/';

        ApiUrl := StrSubstNo(ApiLbl, MagentoSetup."Api Url");

        MagentoApiPost(ApiUrl, Method, Body, Result)

    end;

    internal procedure GetDefaultM2WelcomeEmailTemplate() Template: Text;
    var
        CRLF: Text[2];
    begin

        CRLF[1] := 13;
        CRLF[2] := 10;
        Template :=
        '{' + CRLF +
          ' "membership": {' + CRLF +
          '   "information: "FieldNumbers are based on table 6060139 - NPR MM Member Notification Entry.",' + CRLF +
          '   "membership_number": "{[101]}",' + CRLF +
          '   "member_number": "{[100]}",' + CRLF +
          '   "contact_number": "{[106]}",' + CRLF +
          '   "email": "{[110]}",' + CRLF +
          '   "store_code": "default",' + CRLF +
          '   "item_number": "{[152]}"' + CRLF +
          ' }' + CRLF +
        '}';

    end;

    internal procedure CreateUpdateWalletNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; DateToSendNotification: Date) EntryNo: Integer
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin
        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_UPDATE, MembershipNotification."Notification Method Source"::MEMBER, DateToSendNotification));
    end;

    internal procedure CreateWalletSendNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; DateToSendNotification: Date) EntryNo: Integer
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin
        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_CREATE, MembershipNotification."Notification Method Source"::MEMBER, DateToSendNotification));
    end;

    internal procedure CreateWalletWithoutSendingNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; DateToSendNotification: Date) EntryNo: Integer
    var
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipNotification: Record "NPR MM Membership Notific.";
        NotificationTriggerType: Option;
    begin

        NotificationTriggerType := NotificationSetup.Type::WALLET_CREATE;

        if (MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then
            if (MembershipRole."Wallet Pass Id" <> '') then
                NotificationTriggerType := NotificationSetup.Type::WALLET_UPDATE;

        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationTriggerType, MembershipNotification."Notification Method Source"::EXTERNAL, DateToSendNotification));

    end;

    local procedure CreateWalletNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; NotificationTriggerType: Option; NotificationSource: Option; DateToSendNotification: Date): Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MembershipNotification: Record "NPR MM Membership Notific.";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit(0);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(0);

        if (not MembershipSetup."Enable NP Pass Integration") then
            exit(0);

        NotificationSetup.SetFilter(Type, '=%1', NotificationTriggerType);
        if (NotificationSetup.IsEmpty()) then
            exit(0);

        NotificationSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
        if (NotificationSetup.IsEmpty()) then begin
            NotificationSetup.Reset();
            NotificationSetup.SetFilter(Type, '=%1', NotificationTriggerType);
            NotificationSetup.SetFilter("Community Code", '=%1', Membership."Community Code");
            if (NotificationSetup.IsEmpty()) then
                exit(0);
        end;

        NotificationSetup.FindFirst();

        if (DateToSendNotification = 0D) then
            DateToSendNotification := Today();

        MembershipNotification.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipNotification.SetFilter("Member Card Entry No.", '=%1', MemberCardEntryNo);
        MembershipNotification.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipNotification.SetFilter("Notification Code", '=%1', NotificationSetup.Code);
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Date To Notify", '=%1', Today);
        MembershipNotification.SetFilter("Notification Trigger", '=%1', NotificationTriggerType);
        MembershipNotification.SetFilter("Date To Notify", '=%1', DateToSendNotification);
        if (MembershipNotification.FindFirst()) then
            exit(MembershipNotification."Entry No.");

        MembershipNotification."Membership Entry No." := MembershipEntryNo;
        MembershipNotification."Member Card Entry No." := MemberCardEntryNo;
        MembershipNotification."Member Entry No." := MemberEntryNo;
        MembershipNotification."Notification Code" := NotificationSetup.Code;
        MembershipNotification."Date To Notify" := DateToSendNotification;
        MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PENDING;
        MembershipNotification."Notification Trigger" := NotificationTriggerType;
        MembershipNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
        MembershipNotification."Target Member Role" := NotificationSetup."Target Member Role";
        MembershipNotification."Processing Method" := NotificationSetup."Processing Method";
        MembershipNotification."Include NP Pass" := true;

        MembershipNotification."Notification Method Source" := NotificationSource;

        MembershipNotification.Insert();

        exit(MembershipNotification."Entry No.");
    end;

    internal procedure SendInlineNotifications()
    var
        MembershipNotification: Record "NPR MM Membership Notific.";
        SessionId: Integer;
    begin

        SelectLatestVersion();

        MembershipNotification.Reset();
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Processing Method", '=%1', MembershipNotification."Processing Method"::INLINE);
        MembershipNotification.SetFilter("Date To Notify", '=%1', Today);
        MembershipNotification.SetFilter(Blocked, '=%1', false);

        if (not MembershipNotification.IsEmpty()) then
            if (not Session.StartSession(SessionId, Codeunit::"NPR MM Process Inline Notif", CompanyName(), MembershipNotification)) then
                Error(GetLastErrorText());

        if (not Session.StartSession(SessionId, Codeunit::"NPR MM Sponsorship Ticket Mgt")) then
            Error(GetLastErrorText());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;
        if (Rec."Subscriber Function" <> 'SendMemberNotificationOnSales') then
            exit;

        Rec.Description := INLINE_NOTIFICATION;
        Rec."Sequence No." := 101;
        Rec.Enabled := false;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR MM Member Notification");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure SendMemberNotificationOnSales(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin

        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;
        if (POSSalesWorkflowStep."Subscriber Function" <> 'SendMemberNotificationOnSales') then
            exit;

        SendInlineNotifications();
    end;

    [TryFunction]
    internal procedure NPPassServerInvokeApi(RequestMethod: Code[10]; MemberNotificationSetup: Record "NPR MM Member Notific. Setup"; PassID: Text; var ReasonText: Text; JSONIn: Text; var JSONOut: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        AcceptTok: Label 'Accept', Locked = true;
        ContentTypeTxt: Label 'application/json', Locked = true;
        AuthorizationTok: Label 'Authorization', Locked = true;
        ContentTypeTok: Label 'Content-Type', Locked = true;
        UserAgentTxt: Label 'NP Dynamics Retail / Dynamics 365 Business Central', Locked = true;
        ConnectErrorTxt: Label 'NP Pass Service connection error. (HTTP Reason Code: %1)';
        UserAgentTok: Label 'User-Agent', Locked = true;
        RequestOk: Boolean;
        Url: Text;
        UrlLbl: Label '%1%2?sync=%3', Locked = true;
        BearerLbl: Label 'Bearer %1', Locked = true;
    begin

        ReasonText := '';
        JSONOut := '';
        ClearLastError();

        Url := StrSubstNo(UrlLbl, MemberNotificationSetup."NP Pass Server Base URL",
                                           StrSubstNo(MemberNotificationSetup."Passes API", MemberNotificationSetup."Pass Type Code", PassID),
                                           Format(MemberNotificationSetup."Pass Notification Method", 0, 9));

        Content.WriteFrom(JSONIn);
        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains(ContentTypeTok)) then
            ContentHeaders.Remove(ContentTypeTok);
        ContentHeaders.Add(ContentTypeTok, ContentTypeTxt);

        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Clear();
        RequestHeaders.Add(UserAgentTok, UserAgentTxt);
        RequestHeaders.Add(AcceptTok, ContentTypeTxt);
        RequestHeaders.Add(AuthorizationTok, StrSubstNo(BearerLbl, MemberNotificationSetup."Pass Token"));

        Client.Timeout := 10000;
        if (RequestMethod = 'PUT') then
            RequestOk := Client.Put(Url, Content, Response);

        if (RequestMethod = 'GET') then
            RequestOk := Client.Get(Url, Response);

        if (RequestOk) then begin
            if (Response.IsSuccessStatusCode()) then begin
                Response.Content.ReadAs(JSONOut);
                exit;
            end;

            if (Response.Content.ReadAs(ReasonText)) then
                Error(ReasonText);

            ReasonText := StrSubstNo(ConnectErrorTxt, Response.HttpStatusCode());
            Error(ReasonText);
        end;

        ReasonText := GetLastErrorText();
        Error(ReasonText);
    end;

}

