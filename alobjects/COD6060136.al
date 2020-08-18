codeunit 6060136 "MM Member Notification"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.22/TSA /20170818 CASE 287080 Omitting Role Anonymous when navigating from MembershipRole to Member
    // MM1.24/TSA /20171101 CASE 294950 Added case statements for new option "Notification Metod"::MANUAL
    // MM1.26/TSA /20180328 CASE 309087 Blank email address cause a dialog in the E-Mail sendmail
    // MM1.29/TSA /20180504 CASE 314131 Wallet integration membercard
    // MM1.29.02/TSA /20180528 CASE 317156 Refactored Default Template
    // MM1.29.02/TSA /20180529 CASE 317156 Added SMS as notification option
    // MM1.29.02/TSA /20180531 CASE 314131 Added AddMemberWelcomeNotification(), AddMembershipRenewalNotification() (from 6060127)
    // MM1.30/TSA /20180615 CASE 319243 House cleaning - removing unused variables
    // MM1.32/TSA /20180710 CASE 318132 Wallet Touch-up, WALLET_CREATE, notification selection on card entry no.
    // MM1.34/TSA /20180913 CASE 328141 Changed the selection filter to be become more precice when selecting a specific member to send to notification to.
    // MM1.36/TSA /20181205 CASE 331590 Refresh Renew Notifications
    // MM1.36/TSA /20190109 CASE 328141 Notification with send mode manual also creates wallet (for sending by 3:rd party)
    // MM1.38/TSA /20190517 CASE 355234 Added a notification token that uniquely identifies a member
    // MM1.39/TSA /20190529 CASE 350968 Transfering of membership auto-renew settings to notification entry
    // MM1.41/TSA /20190917 CASE 368691 Refresh Notification excluded "auto-renew" entries
    // MM1.41/TSA /20191004 CASE 367471 Added invokation of sponsorship ticket notification
    // MM1.42/TSA /20191128 CASE 378212 Added SELECTLATESTVERSION
    // MM1.42/TSA /20191220 CASE 382728 Refactored usage of Member."Notification Method"
    // MM1.43/TSA /20200214 CASE 390938 Fixed notification issue with Wallet_Update
    // MM1.43/TSA /20200214 CASE 390938 Changed variable name FieldNo and Count because they are reserved words
    // MM1.44/TSA /20200416 CASE 400601 Adding support for get password directly from welcome email
    // MM1.44/TSA /20200424 CASE 401434 Added guard for overflow when assigning USERID


    trigger OnRun()
    var
        SponsorshipTicketMgmt: Codeunit "MM Sponsorship Ticket Mgmt.";
    begin

        // Invoked by Task Queue when scheduled for background notifications
        HandleBatchNotifications(Today);

        //-#367935 [367935]
        SponsorshipTicketMgmt.NotifyRecipients();
        //+#367935 [367935]
    end;

    var
        NOT_IMPLEMENTED: Label '%1 %2 not implemented.';
        BAD_REFERENCE: Label 'The field reference {:%1} in the textline "%2" does correspond to a valid field number.';
        INLINE_NOTIFICATION: Label 'Sends Inline Member Notifications on End of Sales.';
        REFRESH_NOTIFICATION: Label '@1@@@@@@@@@@@@@@@@@@';

    procedure HandleBatchNotifications(ReferenceDate: Date)
    var
        MembershipNotification: Record "MM Membership Notification";
    begin

        //-MM1.42 [378212]
        SelectLatestVersion();
        //+MM1.42 [378212]

        MembershipNotification.SetCurrentKey("Notification Status", "Date To Notify");
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Date To Notify", '<=%1', ReferenceDate);
        MembershipNotification.SetFilter(Blocked, '=%1', false);
        //-MM1.29 [314131]
        MembershipNotification.SetFilter("Processing Method", '=%1', MembershipNotification."Processing Method"::BATCH);
        //+MM1.29 [314131]

        if (MembershipNotification.FindSet()) then begin
            repeat
                HandleMembershipNotification(MembershipNotification);

                //-MM1.38 [355234]
                Commit();
            //+MM1.38 [355234]

            until (MembershipNotification.Next() = 0);
        end;
    end;

    procedure HandleMembershipNotification(MembershipNotification: Record "MM Membership Notification")
    var
        NotificationStatus: Integer;
    begin

        NotificationStatus := NotificationIsValid(MembershipNotification);

        // Not Now
        if (NotificationStatus = 0) then
            exit;

        if (NotificationStatus = 1) then begin
            CreateRecipients(MembershipNotification);
            NotifyRecipients(MembershipNotification);
            CreateNextNotification(MembershipNotification);
            MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PROCESSED;
        end;

        if (NotificationStatus = -1) then begin
            MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::CANCELED;
        end;

        MembershipNotification."Notification Processed At" := CurrentDateTime;
        //-MM1.44 [401434]
        //MembershipNotification."Notification Processed By User" := USERID;
        MembershipNotification."Notification Processed By User" := CopyStr (UserId, 1, MaxStrLen (MembershipNotification."Notification Processed By User"));
        //+MM1.44 [401434]
        MembershipNotification.Modify();
        Commit;
    end;

    local procedure NotificationIsValid(MembershipNotification: Record "MM Membership Notification"): Integer
    var
        MembershipManagement: Codeunit "MM Membership Management";
        NotificationSetup: Record "MM Member Notification Setup";
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

        if (NotificationSetup."Cancel Overdue Notif. (Days)" <> 0) then begin
            if (MembershipNotification."Date To Notify" + Abs(NotificationSetup."Cancel Overdue Notif. (Days)") < Today) then
                exit(-1);
        end;

        case MembershipNotification."Notification Trigger" of
            MembershipNotification."Notification Trigger"::RENEWAL:
                begin
                    // Notification Date is offset from subscription ends
                    StartDate := CalcDate('<+1D>', MembershipNotification."Date To Notify" + NotificationSetup."Days Before");
                    if (StartDate < Today) then
                        StartDate := Today;

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
                        StartDate := Today;

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
                        StartDate := Today;

                    if (MembershipManagement.GetMembershipValidDate(MembershipNotification."Membership Entry No.", StartDate, FromDate, UntilDate)) then
                        exit(1); // valid, send notification

                    exit(0); // Wait for the membership to become active
                end;
        end;

        exit(-1);
    end;

    local procedure CreateRecipients(MembershipNotification: Record "MM Membership Notification")
    var
        MembershipRole: Record "MM Membership Role";
        MemberNotificationEntry: Record "MM Member Notification Entry";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipSetup: Record "MM Membership Setup";
        MemberCommunity: Record "MM Member Community";
        NotificationSetup: Record "MM Member Notification Setup";
        Method: Code[10];
        Address: Text;
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
        //+MM1.34 [328141]

        if (MembershipRole.FindSet()) then begin
            repeat
                MembershipRole.CalcFields("Membership Code", "External Membership No.");
                Member.Get(MembershipRole."Member Entry No.");
                //-MM1.39 [350968]
                Membership.Get(MembershipRole."Membership Entry No.");
                //+MM1.39 [350968]

                if (not Member.Blocked) then begin
                    if (MemberNotificationEntry.Get(MembershipNotification."Entry No.", Member."Entry No.")) then begin
                        if ((not MemberNotificationEntry.Blocked) or
                            (not (MemberNotificationEntry."Notification Send Status" = MemberNotificationEntry."Notification Send Status"::SENT))) then
                            MemberNotificationEntry.Delete();
                    end;

                    MemberNotificationEntry.Init();
                    MemberNotificationEntry.TransferFields(MembershipNotification, true);

                    //-MM1.39 [350968]
                    MemberNotificationEntry."Auto-Renew" := Membership."Auto-Renew";
                    MemberNotificationEntry."Auto-Renew External Data" := Membership."Auto-Renew External Data";
                    MemberNotificationEntry."Auto-Renew Payment Method Code" := Membership."Auto-Renew Payment Method Code";
                    //+MM1.39 [350968]

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

                    //-MM1.36 [328141]
                    if (MemberNotificationEntry."Card Valid Until" = 0D) then
                        MemberNotificationEntry."Card Valid Until" := MemberNotificationEntry."Membership Valid Until";
                    //+MM1.36 [328141]

                    //-MM1.42 [382728]
                    //CASE Member."Notification Method" OF
                    //  Member."Notification Method"::EMAIL : MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::EMAIL;
                    //  Member."Notification Method"::NONE :  MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::NONE;
                    //  Member."Notification Method"::MANUAL : MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::MANUAL;
                    //  Member."Notification Method"::SMS : MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::SMS;
                    //  ELSE ERROR (NOT_IMPLEMENTED, Member.FIELDCAPTION (Member."Notification Method"), Member."Notification Method");
                    //END;

                    //-MM1.43 [390938]
                    // WITH MembershipNotification DO
                    //   CASE "Notification Trigger" OF
                    //    "Notification Trigger"::WELCOME       : MembershipManagement.GetCommunicationMethod_Welcome ("Member Entry No.", "Membership Entry No.", Method, Address);
                    //    "Notification Trigger"::RENEWAL       : MembershipManagement.GetCommunicationMethod_Renew ("Member Entry No.", "Membership Entry No.", Method, Address);
                    //    "Notification Trigger"::WALLET_CREATE : MembershipManagement.GetCommunicationMethod_MemberCard ("Member Entry No.", "Membership Entry No.", Method, Address);
                    //  END;
                    with MemberNotificationEntry do
                        case "Notification Trigger" of
                            "Notification Trigger"::WELCOME:
                                MembershipManagement.GetCommunicationMethod_Welcome("Member Entry No.", "Membership Entry No.", Method, Address);
                            "Notification Trigger"::RENEWAL:
                                MembershipManagement.GetCommunicationMethod_Renew("Member Entry No.", "Membership Entry No.", Method, Address);
                            "Notification Trigger"::WALLET_CREATE:
                                MembershipManagement.GetCommunicationMethod_MemberCard("Member Entry No.", "Membership Entry No.", Method, Address);
                            "Notification Trigger"::WALLET_UPDATE:
                                MembershipManagement.GetCommunicationMethod_MemberCard("Member Entry No.", "Membership Entry No.", Method, Address);
                        end;
                    //+MM1.43 [390938]

                    with MemberNotificationEntry do
                        case Method of
                            'SMS':
                                "Notification Method" := "Notification Method"::SMS;
                            'W-SMS':
                                "Notification Method" := "Notification Method"::SMS;
                            'EMAIL':
                                "Notification Method" := "Notification Method"::EMAIL;
                            'W-EMAIL':
                                "Notification Method" := "Notification Method"::EMAIL;
                            else
                                "Notification Method" := "Notification Method"::NONE;
                        end;
                    //+MM1.42 [382728]

                    //-MM1.36 [328141]
                    if (MembershipNotification."Notification Method Source" = MembershipNotification."Notification Method Source"::EXTERNAL) then
                        MemberNotificationEntry."Notification Method" := MemberNotificationEntry."Notification Method"::MANUAL;
                    //+MM1.36 [328141]

                    MemberNotificationEntry."Include NP Pass" := ((MembershipSetup."Enable NP Pass Integration") and (MembershipNotification."Include NP Pass"));

                    //-MM1.38 [355234]
                    MembershipRole."Notification Token" := GenerateNotificationToken();
                    MembershipRole.Modify();
                    MemberNotificationEntry."Notification Token" := MembershipRole."Notification Token";
                    //+MM1.38 [355234]

              //-MM1.44 [400601]
              MemberNotificationEntry."Magento Get Password URL" := NotificationSetup."Fallback Magento PW URL";
              if (Member."E-Mail Address" <> '') then
                MemberNotificationEntry."Magento Get Password URL" := StrSubstNo ('%1?email=%2', NotificationSetup."Fallback Magento PW URL", Member."E-Mail Address");
              if (NotificationSetup."Generate Magento PW URL") then begin
                 RequestMagentoPasswordUrl (Membership."Customer No.", MembershipRole."Contact No.", Member."E-Mail Address", MemberNotificationEntry."Magento Get Password URL", MemberNotificationEntry."Failed With Message");
              end;
              //-MM1.44 [400601]

                    if (MemberNotificationEntry.Insert()) then;
                end;
            until ((MembershipRole.Next() = 0) or (MembershipNotification."Target Member Role" = MembershipNotification."Target Member Role"::FIRST_ADMIN));
        end;
    end;

    local procedure NotifyRecipients(MembershipNotification: Record "MM Membership Notification")
    var
        MemberNotificationEntry: Record "MM Member Notification Entry";
        MemberNotificationEntry2: Record "MM Member Notification Entry";
        ResponseMessage: Text;
        SendStatus: Option;
    begin

        MemberNotificationEntry.SetFilter("Notification Entry No.", '=%1', MembershipNotification."Entry No.");
        MemberNotificationEntry.SetFilter("Notification Send Status", '=%1', MemberNotificationEntry."Notification Send Status"::PENDING);
        MemberNotificationEntry.SetFilter(Blocked, '=%1', false);

        if (MemberNotificationEntry.FindSet()) then begin
            repeat

                //-MM1.29 [314131] refactored
                SendStatus := MemberNotificationEntry2."Notification Send Status"::FAILED;

                case MemberNotificationEntry."Notification Method" of
                    MemberNotificationEntry."Notification Method"::NONE:
                        begin
                            SendStatus := MemberNotificationEntry2."Notification Send Status"::NOT_SENT;
                        end;

                    MemberNotificationEntry."Notification Method"::EMAIL:
                        begin
                            //-MM1.29 [314131]
                            //IF (SendMail (MemberNotificationEntry, ResponseMessage)) THEN
                            //  MemberNotificationEntry2."Notification Send Status" := MemberNotificationEntry2."Notification Send Status"::SENT;

                            if (MemberNotificationEntry."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry);
                                MemberNotificationEntry.Modify();
                                if (MemberNotificationEntry."Notification Trigger" = MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                            end;

                            if (MemberNotificationEntry."Notification Trigger" <> MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE) then
                                if (SendMail(MemberNotificationEntry, ResponseMessage)) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                            //+MM1.29 [314131]

                        end;

                    //-MM1.29.02 [317156]
                    MemberNotificationEntry."Notification Method"::SMS:
                        begin

                            if (MemberNotificationEntry."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry);
                                MemberNotificationEntry.Modify();
                                if (MemberNotificationEntry."Notification Trigger" = MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                            end;

                            if (MemberNotificationEntry."Notification Trigger" <> MemberNotificationEntry."Notification Trigger"::WALLET_UPDATE) then
                                if (SendSMS(MemberNotificationEntry, ResponseMessage)) then
                                    SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;

                        end;
                    //+MM1.29.02 [317156]

                    MemberNotificationEntry."Notification Method"::MANUAL:
                        begin
                            //-MM1.36 [328141]
                            if (MemberNotificationEntry."Include NP Pass") then begin
                                CreateNpPass(MemberNotificationEntry);
                                MemberNotificationEntry.Modify();
                            end;
                            //+MM1.36 [328141]

                            SendStatus := MemberNotificationEntry2."Notification Send Status"::SENT;
                        end;

                    else
                        Error(NOT_IMPLEMENTED, MemberNotificationEntry.FieldCaption("Notification Method"), MemberNotificationEntry."Notification Method");
                end;

                MemberNotificationEntry2.Get(MemberNotificationEntry."Notification Entry No.", MemberNotificationEntry."Member Entry No.");
                MemberNotificationEntry2."Notification Sent At" := CurrentDateTime();
            //-MM1.44 [401434]
            // MemberNotificationEntry2."Notification Sent By User" := USERID;
            MemberNotificationEntry2."Notification Sent By User" := CopyStr (UserId, 1, MaxStrLen (MemberNotificationEntry2."Notification Sent By User"));
            //+MM1.44 [401434]
                MemberNotificationEntry2."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(MemberNotificationEntry2."Failed With Message"));
                MemberNotificationEntry2."Notification Send Status" := SendStatus;
                MemberNotificationEntry2.Modify();
                Commit;

            until (MemberNotificationEntry.Next() = 0);
        end;
    end;

    local procedure CreateNextNotification(MembershipNotification: Record "MM Membership Notification")
    var
        MembershipNotification2: Record "MM Membership Notification";
        NotificationSetup: Record "MM Member Notification Setup";
        NotificationSetup2: Record "MM Member Notification Setup";
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

    local procedure SendMail(MemberNotificationEntry: Record "MM Member Notification Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        EMailMgt: Codeunit "E-mail Management";
    begin

        RecordRef.GetTable(MemberNotificationEntry);

        //-#309087 [309087]
        //ResponseMessage := EMailMgt.SendEmail(RecordRef, MemberNotificationEntry."E-Mail Address", TRUE);
        ResponseMessage := 'E-Mail address is missing.';
        if (MemberNotificationEntry."E-Mail Address" <> '') then
            ResponseMessage := EMailMgt.SendEmail(RecordRef, MemberNotificationEntry."E-Mail Address", true);
        //+#309087 [309087]

        exit(ResponseMessage = '');
    end;

    local procedure SendSMS(MemberNotificationEntry: Record "MM Member Notification Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "SMS Management";
        SMSTemplateHeader: Record "SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(MemberNotificationEntry);

        if (MemberNotificationEntry."Phone No." = '') then
            ResponseMessage := 'Phone number is missing.';

        if (MemberNotificationEntry."Phone No." <> '') then begin
            Commit;
            ResponseMessage := 'Template not found.';
            if (SMSManagement.FindTemplate(RecordRef, SMSTemplateHeader)) then begin
                SmsBody := SMSManagement.MakeMessage(SMSTemplateHeader, MemberNotificationEntry);
                SMSManagement.SendSMS(MemberNotificationEntry."Phone No.", SMSTemplateHeader."Alt. Sender", SmsBody);
                ResponseMessage := '';
            end;
        end;

        exit(ResponseMessage = '');
    end;

    local procedure "--Notifications"()
    begin
    end;

    procedure AddMemberWelcomeNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer) NotificationEntryNo: Integer
    var
        Membership: Record "MM Membership";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
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

        //-MM1.29 [314131]
        MembershipNotification."Processing Method" := NotificationSetup."Processing Method";
        MembershipNotification."Include NP Pass" := NotificationSetup."Include NP Pass";
        //+MM1.29 [314131]

        MembershipNotification.Insert();

        exit(MembershipNotification."Entry No.");
    end;

    procedure RefreshAllMembershipRenewalNotifications(MembershipCode: Code[20])
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSetup: Record "MM Membership Setup";
        CommunitySetup: Record "MM Member Community";
        Window: Dialog;
        CurrentCount: Integer;
        MaxCount: Integer;
    begin

        //-MM1.36 [331590]
        Membership.SetFilter("Membership Code", '=%1', MembershipCode);
        if (Membership.FindSet()) then begin
            if (GuiAllowed) then
                Window.Open(REFRESH_NOTIFICATION);

            MaxCount := Membership.Count();
            MembershipSetup.Get(MembershipCode);
            CommunitySetup.Get(MembershipSetup."Community Code");

            repeat

                MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipEntry.SetFilter(Blocked, '=%1', false);
                // NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW,FOREIGN
                //-MM1.41 [368691]
                //MembershipEntry.SETFILTER (Context, '%1..%2 ', MembershipEntry.Context::NEW, MembershipEntry.Context::EXTEND);
                MembershipEntry.SetFilter(Context, '%1..%2|%3', MembershipEntry.Context::NEW, MembershipEntry.Context::EXTEND, MembershipEntry.Context::AUTORENEW);
                //+MM1.41 [368691]
                if (MembershipEntry.FindLast()) then
                    if (MembershipEntry."Valid Until Date" > Today) then
                        AddMembershipRenewalNotificationWorker(MembershipEntry, MembershipSetup, CommunitySetup);

                if (GuiAllowed) then
                    Window.Update(1, Round(CurrentCount / MaxCount * 10000, 1));

                CurrentCount += 1;

            until (Membership.Next() = 0);

            if (GuiAllowed) then
                Window.Close();
        end;
        //+MM1.36 [331590]
    end;

    procedure AddMembershipRenewalNotification(MembershipLedgerEntry: Record "MM Membership Entry")
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        CommunitySetup: Record "MM Member Community";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
        DaysToRenewal: Integer;
    begin

        Membership.Get(MembershipLedgerEntry."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");
        CommunitySetup.Get(MembershipSetup."Community Code");

        //-MM1.36 [331590] refactored, code moved local worker
        AddMembershipRenewalNotificationWorker(MembershipLedgerEntry, MembershipSetup, CommunitySetup);
        //+MM1.36 [331590]
    end;

    local procedure AddMembershipRenewalNotificationWorker(MembershipLedgerEntry: Record "MM Membership Entry"; MembershipSetup: Record "MM Membership Setup"; CommunitySetup: Record "MM Member Community")
    var
        Membership: Record "MM Membership";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
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
            //-MM1.44 [401434]
            // MembershipNotification."Notification Processed By User" := USERID;
            MembershipNotification."Notification Processed By User" := CopyStr (UserId, 1, MaxStrLen (MembershipNotification."Notification Processed By User"));
            //+MM1.44 [401434]
                MembershipNotification.Modify();
            until (MembershipNotification.Next() = 0);
        end;

        if (not ((MembershipSetup."Create Renewal Notifications") or (CommunitySetup."Create Renewal Notifications"))) then
            exit;

        DaysToRenewal := MembershipLedgerEntry."Valid Until Date" - Today;

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

    procedure GenerateNotificationToken() Token: Text[64]
    var
        n: Integer;
        t: Char;
    begin

        //-MM1.38 [355234]
        Randomize;
        Token := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

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
        //+MM1.38 [355234]
    end;

    local procedure "-------Wallet"()
    begin
    end;

    local procedure CreateNpPass(var MemberNotificationEntry: Record "MM Member Notification Entry")
    var
        PassData: Text;
        RecRef: RecordRef;
        MemberNotificationSetup: Record "MM Member Notification Setup";
        instream: InStream;
        templateText: Text;
    begin

        MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code");
        if (not MemberNotificationSetup."Include NP Pass") then
            exit;

        RecRef.GetTable(MemberNotificationEntry);

        MemberNotificationSetup.CalcFields("PUT Passes Template");
        if (MemberNotificationSetup."PUT Passes Template".HasValue()) then begin
            MemberNotificationSetup."PUT Passes Template".CreateInStream(instream);
            while (not instream.EOS()) do begin
                instream.ReadText(templateText);
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;
        end else begin
            templateText := GetDefaultTemplate();
            PassData += AssignDataToPassTemplate(RecRef, templateText);
        end;

        //JObject := JObject.Parse (PassData);
        //MESSAGE ('image type %1', GetStringValue (JObject, 'data.images[:1].type'));
        //ERROR ('Pass Data %1', COPYSTR (PassData, 1, 2048));

        if (CreatePass(MemberNotificationEntry, PassData)) then
            SetPassUrl(MemberNotificationEntry);
    end;

    local procedure CreatePass(var MemberNotificationEntry: Record "MM Member Notification Entry"; PassData: Text): Boolean
    var
        MemberNotificationSetup: Record "MM Member Notification Setup";
        MembershipRole: Record "MM Membership Role";
        JSONResult: Text;
        FailReason: Text;
    begin

        MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code");
        MembershipRole.Get(MemberNotificationEntry."Membership Entry No.", MemberNotificationEntry."Member Entry No.");

        if (MembershipRole."Wallet Pass Id" = '') then begin
            MembershipRole."Wallet Pass Id" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
            MembershipRole.Modify();
        end;

        MemberNotificationEntry."Wallet Pass Id" := MembershipRole."Wallet Pass Id";

        exit(NPPassServerInvokeApi('PUT', MemberNotificationSetup, MemberNotificationEntry."Wallet Pass Id", FailReason, PassData, JSONResult));
    end;

    local procedure SetPassUrl(var MemberNotificationEntry: Record "MM Member Notification Entry"): Boolean
    var
        MemberNotificationSetup: Record "MM Member Notification Setup";
        JSONResult: Text;
        FailReason: Text;
        JObject: DotNet JObject;
    begin

        if (not MemberNotificationSetup.Get(MemberNotificationEntry."Notification Code")) then
            exit(false);

        if not (NPPassServerInvokeApi('GET', MemberNotificationSetup, MemberNotificationEntry."Wallet Pass Id", FailReason, '', JSONResult)) then
            exit(false);

        if (JSONResult = '') then
            exit(false);

        JObject := JObject.Parse(JSONResult);
        MemberNotificationEntry."Wallet Pass Default URL" := GetStringValue(JObject, 'public_url.default');
        MemberNotificationEntry."Wallet Pass Andriod URL" := GetStringValue(JObject, 'public_url.android');
        MemberNotificationEntry."Wallet Pass Landing URL" := GetStringValue(JObject, 'public_url.landing'); //-+MM1.29.02 [317156]

        exit(true);
    end;

    local procedure GetStringValue(JObject: DotNet JObject; "Key": Text): Text
    var
        JToken: DotNet JToken;
    begin

        JToken := JObject.SelectToken(Key, false);
        if (IsNull(JToken)) then
            exit('');

        exit(JToken.ToString());
    end;

    procedure AssignDataToPassTemplate(var RecRef: RecordRef; Line: Text) NewLine: Text
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
        MemberNotificationEntry: Record "MM Member Notification Entry";
        MemberEntryNo: Integer;
        MembershipManagement: Codeunit "MM Membership Management";
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
                if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                    FieldRef.CalcField;

                NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);

                if (UpperCase(Format(Format(FieldRef.Type)))) = 'OPTION' then begin
                    OptionCaption := Format(FieldRef.OptionString);
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

    procedure GetDefaultTemplate() template: Text
    var
        CRLF: Text[2];
    begin

        //-MM1.29.02 [317156]
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
        //+MM1.29.02 [317156]

        exit(template);
    end;

    local procedure "---Magento"()
    begin
    end;

    local procedure RequestMagentoPasswordUrl(CustomerNo: Code[20];ContactNo: Code[20];EmailAddress: Text[200];var ResponseUrl: Text[200];var ReasonText: Text): Boolean
    var
        Customer: Record Customer;
        Contact: Record Contact;
        MessageText: Text;
        Body: DotNet npNetJToken;
        Response: DotNet npNetJToken;
        StartPos: Integer;
        EndPos: Integer;
        ResponseText: Text;
    begin
        //-MM1.44 [400601]

        if (not Customer.Get (CustomerNo)) then
          exit;

        if (not Contact.Get (ContactNo)) then
          exit;

        if (not Contact."Magento Contact") then
          exit;

        MessageText := StrSubstNo ('{"id":"%1","storecode":"%2"}', ContactNo, Customer."Magento Store Code");
        Body := Body.Parse (StrSubstNo ('{"account": {"email":"%1", "accounts":[%2]}}', EmailAddress, MessageText));

        if (not MagentoApiPost ('password-reset-link', Body, Response)) then begin
          ReasonText := CopyStr (GetLastErrorText,1, MaxStrLen (ReasonText));
          exit;
        end;

        if (not GetMagentoMessageUrl (Response, ResponseText)) then begin
          ReasonText := CopyStr (GetLastErrorText,1, MaxStrLen (ReasonText));
          exit;
        end;

        ResponseUrl := ResponseText;

        exit (true);
        //+MM1.44 [400601]
    end;

    [TryFunction]
    local procedure GetMagentoMessageUrl(Json: DotNet npNetJToken;var Url: Text)
    begin

        //-MM1.44 [400601]
        Url := Json.Item('messages').Item('success').Item(0).Item('message').ToString();
        //+MM1.44 [400601]
    end;

    [TryFunction]
    procedure MagentoApiPost(Method: Text;var Body: DotNet npNetJToken;var Result: DotNet npNetJToken)
    var
        MagentoSetup: Record "Magento Setup";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        StreamReader: DotNet npNetStreamReader;
        Response: Text;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
    begin

        //-MM1.44 [400601]
        Clear(Response);
        if Method = '' then
          exit;

        MagentoSetup.Get;
        MagentoSetup.TestField("Api Url");
        if MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/' then
          MagentoSetup."Api Url" += '/';

        if (CopyStr (MagentoSetup."Api Url", StrLen (MagentoSetup."Api Url" ) - (StrLen ('naviconnect/')) + 1) = 'naviconnect/') then
          MagentoSetup."Api Url" := CopyStr (MagentoSetup."Api Url", 1, StrLen (MagentoSetup."Api Url" ) - (StrLen ('naviconnect/'))) + 'b2b_customer/';

        HttpWebRequest := HttpWebRequest.Create(MagentoSetup."Api Url"+ Method);
        HttpWebRequest.Timeout := 1000 * 60;

        HttpWebRequest.Method := 'POST';
        MagentoSetup.Get;
        if MagentoSetup."Api Authorization" <> '' then
          HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization")
        else
          HttpWebRequest.Headers.Add('Authorization','Basic ' + MagentoSetup.GetBasicAuthInfo());

        HttpWebRequest.ContentType ('naviconnect/json');

        ReqStream := HttpWebRequest.GetRequestStream;
        ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
        ReqStreamWriter.Write (Body.ToString());
        ReqStreamWriter.Flush;
        ReqStreamWriter.Close;
        Clear (ReqStreamWriter);
        Clear (ReqStream);

        HttpWebResponse := HttpWebRequest.GetResponse();

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream);
        Response := StreamReader.ReadToEnd;
        Result := Result.Parse(Response);
    end;

    local procedure "---Inline Notifications"()
    begin
    end;

    procedure CreateUpdateWalletNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer) EntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
        MembershipRole: Record "MM Membership Role";
        NotificationTriggerType: Integer;
    begin

        //-MM1.36 [328141]
        //EXIT (CreateWalletNotification (MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_UPDATE));
        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_UPDATE, MembershipNotification."Notification Method Source"::MEMBER));
        //+MM1.36 [328141]
    end;

    procedure CreateWalletSendNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer) EntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
    begin

        //-MM1.36 [328141]
        //EXIT (CreateWalletNotification (MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_CREATE));
        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationSetup.Type::WALLET_CREATE, MembershipNotification."Notification Method Source"::MEMBER));
        //+MM1.36 [328141]
    end;

    procedure CreateWalletWithoutSendingNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer) EntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
        MembershipRole: Record "MM Membership Role";
        NotificationTriggerType: Option;
    begin

        //-MM1.36 [328141]

        NotificationTriggerType := NotificationSetup.Type::WALLET_CREATE;

        if (MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then
            if (MembershipRole."Wallet Pass Id" <> '') then
                NotificationTriggerType := NotificationSetup.Type::WALLET_UPDATE;

        exit(CreateWalletNotification(MembershipEntryNo, MemberEntryNo, MemberCardEntryNo, NotificationTriggerType, MembershipNotification."Notification Method Source"::EXTERNAL));
        //+MM1.36 [328141]
    end;

    local procedure CreateWalletNotification(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; NotificationTriggerType: Option; NotificationSource: Option) EntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        NotificationSetup: Record "MM Member Notification Setup";
        MembershipNotification: Record "MM Membership Notification";
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

        MembershipNotification.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipNotification.SetFilter("Member Card Entry No.", '=%1', MemberCardEntryNo);
        MembershipNotification.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipNotification.SetFilter("Notification Code", '=%1', NotificationSetup.Code);
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Date To Notify", '=%1', Today);
        MembershipNotification.SetFilter("Notification Trigger", '=%1', NotificationTriggerType);
        if (MembershipNotification.FindFirst()) then
            exit(MembershipNotification."Entry No.");

        MembershipNotification."Membership Entry No." := MembershipEntryNo;
        MembershipNotification."Member Card Entry No." := MemberCardEntryNo;
        MembershipNotification."Member Entry No." := MemberEntryNo;
        MembershipNotification."Notification Code" := NotificationSetup.Code;
        MembershipNotification."Date To Notify" := Today;
        MembershipNotification."Notification Status" := MembershipNotification."Notification Status"::PENDING;
        MembershipNotification."Notification Trigger" := NotificationTriggerType;
        MembershipNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
        MembershipNotification."Target Member Role" := NotificationSetup."Target Member Role";
        MembershipNotification."Processing Method" := NotificationSetup."Processing Method";
        MembershipNotification."Include NP Pass" := true;

        //-MM1.36 [328141]
        MembershipNotification."Notification Method Source" := NotificationSource;
        //+MM1.36 [328141]

        MembershipNotification.Insert();

        exit(MembershipNotification."Entry No.");
    end;

    procedure SendInlineNotifications()
    var
        MembershipNotification: Record "MM Membership Notification";
        MemberNotification: Codeunit "MM Member Notification";
        SponsorshipTicketMgmt: Codeunit "MM Sponsorship Ticket Mgmt.";
    begin

        // inline notifications are for DEMO purpose only
        Sleep(2000); // posting is occurring in a other thread.
        // I want posting to be done before sending out the notification

        //-MM1.42 [378212]
        SelectLatestVersion();
        //+MM1.42 [378212]

        MembershipNotification.Reset();
        MembershipNotification.SetFilter("Notification Status", '=%1', MembershipNotification."Notification Status"::PENDING);
        MembershipNotification.SetFilter("Processing Method", '=%1', MembershipNotification."Processing Method"::INLINE);
        MembershipNotification.SetFilter("Date To Notify", '=%1', Today);
        MembershipNotification.SetFilter(Blocked, '=%1', false);

        if (MembershipNotification.FindSet()) then begin
            repeat
                MemberNotification.HandleMembershipNotification(MembershipNotification);
            until (MembershipNotification.Next() = 0);
        end;

        //-#367935 [367935]
        SponsorshipTicketMgmt.NotifyRecipients();
        //+#367935 [367935]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'SendMemberNotificationOnSales' then
            exit;

        Rec.Description := INLINE_NOTIFICATION;
        Rec."Sequence No." := 101;
        Rec.Enabled := false;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"MM Member Notification");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure SendMemberNotificationOnSales(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SalePOS: Record "Sale POS")
    begin


        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'SendMemberNotificationOnSales' then
            exit;

        SendInlineNotifications();
    end;

    local procedure "-------"()
    begin
    end;

    procedure NPPassServerInvokeApi(Method: Code[10]; MemberNotificationSetup: Record "MM Member Notification Setup"; PassID: Text; var ReasonText: Text; JSONIn: Text; var JSONOut: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Url: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        ReasonText := '';
        Url := StrSubstNo('%1%2?sync=%3', MemberNotificationSetup."NP Pass Server Base URL",
                                           StrSubstNo(MemberNotificationSetup."Passes API", MemberNotificationSetup."Pass Type Code", PassID),
                                           Format(MemberNotificationSetup."Pass Notification Method", 0, 9));

        HttpWebRequest := HttpWebRequest.Create(Url);
        HttpWebRequest.Timeout := 10000;
        HttpWebRequest.KeepAlive(true);

        HttpWebRequest.Method := Method;
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.Accept := 'application/json';
        HttpWebRequest.UseDefaultCredentials(false);
        HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Bearer %1', MemberNotificationSetup."Pass Token"));

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(JSONIn, HttpWebRequest, HttpWebResponse)) then begin
            TryReadResponseText(HttpWebResponse, ResponseText);
            JSONOut := ResponseText;
            exit(true);
        end;

        ReasonText := StrSubstNo('Error from API %1\\%2', GetLastErrorText, Url);

        Exception := GetLastErrorObject();
        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then
            Error(Exception.ToString());

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        if (StrLen(ResponseText) > 0) then
            Error(ResponseText);

        if (StrLen(ResponseText) = 0) then
            Error(StrSubstNo(
              '<Fault>' +
                '<faultstatus>%1</faultstatus>' +
                '<faultstring>%2 - %3</faultstring>' +
              '</Fault>',
              StatusCode,
              StatusDescription,
              Url));

        exit(false);
    end;

    [TryFunction]
    local procedure TrySendWebRequest(JSON: Text; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStreamOut: DotNet npNetMemoryStream;
        MemoryStreamIn: DotNet npNetMemoryStream;
        Encoding: DotNet npNetEncoding;
    begin

        if (StrLen(JSON) > 0) then begin
            MemoryStreamIn := MemoryStreamIn.MemoryStream(Encoding.UTF8.GetBytes(JSON));
            MemoryStreamOut := HttpWebRequest.GetRequestStream();

            MemoryStreamIn.WriteTo(MemoryStreamOut);

            MemoryStreamOut.Flush;
            MemoryStreamOut.Close;
            Clear(MemoryStreamOut);

            MemoryStreamIn.Close();
            Clear(MemoryStreamIn);
        end;
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text)
    var
        StreamReader: DotNet npNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());

        //ResponseText := HttpWebResponse.Headers().ToString();
        ResponseText := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        StreamReader: DotNet npNetStreamReader;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet npNetType;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals(WebExceptionStatus.Timeout)) then begin
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(WebExceptionStatus.Timeout, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := WebExceptionStatus.Timeout.ToString();
            exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals(WebExceptionStatus.ProtocolError)) then begin
            HttpWebResponse := WebException.Response();
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(HttpWebResponse.StatusCode, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := HttpWebResponse.StatusDescription;
            if (StatusCode[1] = '4') then // 4xx messages
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryGetWebExceptionResponse(var WebException: DotNet npNetWebException; var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin

        HttpWebResponse := WebException.Response;
    end;

    [TryFunction]
    local procedure TryGetInnerWebException(var WebException: DotNet npNetWebException; var InnerWebException: DotNet npNetWebException)
    begin

        InnerWebException := WebException.InnerException;
    end;

    procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    procedure XmlSafe(InText: Text): Text
    begin

        exit(DelChr(InText, '<=>', DelChr(InText, '<=>', '1234567890 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-+*')));
    end;
}

