codeunit 6059940 "NPR SMS Management"
{
    var
        UserNotified: Boolean;
        NoRecordSelectedTxt: Label 'No record was selected. Send SMS based on blank record?';
        NoTemplateTxt: Label 'There is no %1 that match the %2 record.';
        NoRecordsText: Label 'No records within the combination of filteres entred and filters on Template.';
        BatchSendStatusText: Label '%1 records withing the filter:  %2';
        CaptionText: Label 'Filters - %1', Comment = '%1 = Table Name';
        NaviDocsProgressDialogText: Label 'Adding Messages to NaviDocs: @1@@@@@@@@@@@@@@@@@@@@@@@';
        SendingProgressDialogText: Label 'Sending Messages: @1@@@@@@@@@@@@@@@@@@@@@@@';
        PermissionErr: Label 'You do not have right permissions to set up Job Queue.';

    #region SMS functions
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)
    begin
        InsertMessageLog(PhoneNo, SenderNo, Message, 0DT);
        if not UserNotified then
            QueuedNotification();
        UserNotified := true;
    end;

    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text; DelayUntil: DateTime)
    begin
        InsertMessageLog(PhoneNo, SenderNo, Message, DelayUntil);
    end;

    procedure SendQueuedSMS(MessageLog: Record "NPR SMS Log")
    var
        Status: Enum "NPR SMS Log Status";
        MessageText: Text;
    begin
        MessageLog.GetMessage(MessageText);
        if not TrySendSMS(MessageLog."Reciepient No.", MessageLog."Sender No.", MessageText) then
            UpdateMessageLog(MessageLog, Status::Error, GetLastErrorText)
        else
            UpdateMessageLog(MessageLog, Status::Sent, '');
    end;

    [TryFunction]
    local procedure TrySendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)
    var
        SMSSetup: Record "NPR SMS Setup";
        ISendSMS: Interface "NPR Send SMS";
    begin
        SMSSetup.Get();
        ISendSMS := SMSSetup."SMS Provider";
        ISendSMS.SendSMS(PhoneNo, SenderNo, Message);
    end;

    procedure QueueMessages(PhoneNo: List of [Text]; SenderNo: Text; Message: Text; DelayUntil: DateTime)
    var
        i: Integer;
        SendTo: Text;
    begin
        for i := 1 to PhoneNo.Count do begin
            PhoneNo.Get(i, SendTo);
            SendSMS(SendTo, SenderNo, Message, DelayUntil);
        end;
    end;

    procedure SendTestSMS(var Template: Record "NPR SMS Template Header")
    var
        DialogPage: Page "NPR SMS Send Message";
        RecRef: RecordRef;
        SendTo: Text;
        Sender: Text;
        SMSBodyText: Text;
        SendingOption: Option Direct,NaviDocs;
        DelayUntil: DateTime;
        Changed: Boolean;
        SendToList: List of [Text];
        SMSRecipientType: enum "NPR SMS Recipient Type";
        SMSGroupcode: Code[10];
    begin
        DialogPage.SetRecord(Template);
        if DialogPage.RunModal <> ACTION::OK then
            exit;

        DialogPage.GetData(SMSRecipientType, SMSGroupcode, SendTo, RecRef, SMSBodyText, Sender, DelayUntil);

        if Sender = '' then
            Sender := Template."Alt. Sender";
        if Sender = '' then
            Sender := GetDefaultSender;
        if Template."Table No." <> 0 then
            if IsRecRefEmpty(RecRef) then
                if not Confirm(NoRecordSelectedTxt) then
                    exit;

        if SMSBodyText = '' then
            SMSBodyText := MakeMessage(Template, RecRef);

        PopulateSendList(SendToList, Template."Recipient Type"::Field, Template."Recipient Group", SendTo);

        QueueMessages(SendToList, Sender, SMSBodyText, DelayUntil);
        QueuedNotification();
    end;

    procedure SendBatchSMS(SMSTemplateHeader: Record "NPR SMS Template Header")
    var
        SMSSendMessage: Page "NPR SMS Send Message";
        RecRef: RecordRef;
        SendTo: Text;
        SendToList: List of [Text];
        Filters: Text;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
        Sender: Text;
        SendOption: Option Direct,NaviDocs;
        DelayUntil: DateTime;
        MessageText: Text;
        DummyTxt: Text;
        DummyRecRef: RecordRef;
        i: Integer;
        SMSRecipientType: enum "NPR SMS Recipient Type";
        SMSGroupcode: Code[10];
    begin
        if not RunDynamicRequestPage(SMSTemplateHeader, Filters, '') then
            exit;

        if not SetFiltersOnTable(SMSTemplateHeader, Filters, RecRef) then
            exit;

        Total := RecRef.Count;

        if Total = 0 then begin
            Message(NoRecordsText);
            exit;
        end;

        Sender := SMSTemplateHeader."Alt. Sender";
        if Sender = '' then
            Sender := GetDefaultSender;

        SendTo := MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0);
        SMSSendMessage.SetData(SMSTemplateHeader."Recipient Type", SMSTemplateHeader."Recipient Group", '', DummyRecRef, Sender, 2, StrSubstNo(BatchSendStatusText, SMSTemplateHeader."Table Caption", Total), false);

        SMSSendMessage.SetRecord(SMSTemplateHeader);
        if SMSSendMessage.RunModal <> ACTION::OK then
            exit;

        SMSSendMessage.GetData(SMSRecipientType, SMSGroupcode, DummyTxt, DummyRecRef, MessageText, DummyTxt, DelayUntil);

        Counter := 0;
        if SendOption = SendOption::NaviDocs then
            Window.Open(NaviDocsProgressDialogText)
        else
            Window.Open(SendingProgressDialogText);


        if RecRef.FindSet then
            repeat
                Counter += 1;
                Window.Update(1, Round((Counter / Total) * 10000, 1));
                PopulateSendList(SendToList, SMSTemplateHeader."Recipient Type", SMSTemplateHeader."Recipient Group", MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0));
                QueueMessages(SendToList, Sender, MergeDataFields(MessageText, RecRef, 0), DelayUntil);
            until RecRef.Next = 0;
        Window.Close;
        QueuedNotification();
    end;

    procedure EditAndSendSMS(RecordToSendVariant: Variant)
    var
        RecRef: RecordRef;
        SMSTemplateHeader: Record "NPR SMS Template Header";
        DialogPage: Page "NPR SMS Send Message";
        SendTo: Text;
        Sender: Text;
        SMSBodyText: Text;
        SendingOption: Option Direct,NaviDocs;
        DelayUntil: DateTime;
        SMSRecipientType: enum "NPR SMS Recipient Type";
        DataTypeManagement: Codeunit "Data Type Management";
        SMSGroupcode: Code[10];
        SMSPhoneList: List of [Text];
        i: Integer;
    begin
        if not DataTypeManagement.GetRecordRef(RecordToSendVariant, RecRef) then
            exit;
        if SelectTemplate(RecRef, SMSTemplateHeader) then begin
            Sender := SMSTemplateHeader."Alt. Sender";
            if Sender = '' then
                Sender := GetDefaultSender;
            SendTo := MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0);

            DialogPage.SetData(SMSTemplateHeader."Recipient Type", SMSTemplateHeader."Recipient Group", SendTo, RecRef, Sender, 1, '', true);

            DialogPage.SetRecord(SMSTemplateHeader);
            if DialogPage.RunModal <> ACTION::OK then
                exit;
            DialogPage.GetData(SMSRecipientType, SMSGroupcode, SendTo, RecRef, SMSBodyText, Sender, DelayUntil);

            if SMSTemplateHeader."Table No." <> 0 then
                if IsRecRefEmpty(RecRef) then
                    if not Confirm(NoRecordSelectedTxt) then
                        exit;

            if SMSBodyText = '' then
                SMSBodyText := MakeMessage(SMSTemplateHeader, RecRef);

            PopulateSendList(SMSPhoneList, SMSRecipientType, SMSGroupcode, SendTo);

            QueueMessages(SMSPhoneList, Sender, SMSBodyText, DelayUntil);
            QueuedNotification();
        end else
            Message(NoTemplateTxt, SMSTemplateHeader.TableCaption, RecRef.Caption);
    end;

    local procedure RunDynamicRequestPage(SMSTemplateHeader: Record "NPR SMS Template Header"; var ReturnFilters: Text; Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        RecRef: RecordRef;
        PrimaryKeyRef: KeyRef;
        DynamicRequestPageFieldAdded: Boolean;
        Index: Integer;
    begin
        SMSTemplateHeader.CalcFields("Table Caption");
        if not TableMetadata.Get(SMSTemplateHeader."Table No.") then
            exit(false);

        DynamicRequestPageField.SetRange("Table ID", SMSTemplateHeader."Table No.");
        if DynamicRequestPageField.IsEmpty then begin
            DynamicRequestPageField."Table ID" := SMSTemplateHeader."Table No.";
            RecRef.Open(SMSTemplateHeader."Table No.");
            PrimaryKeyRef := RecRef.KeyIndex(1);
            for Index := 1 to PrimaryKeyRef.FieldCount do begin
                DynamicRequestPageField."Field ID" := PrimaryKeyRef.FieldIndex(Index).Number;
                DynamicRequestPageField.Insert;
            end;
            DynamicRequestPageFieldAdded := true;
            Commit;
        end;
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, CopyStr(SMSTemplateHeader."Table Caption", 1, 20), SMSTemplateHeader."Table No.") then
            exit(false);

        if Filters <> '' then
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
               FilterPageBuilder, Filters, CopyStr(SMSTemplateHeader."Table Caption", 1, 20), SMSTemplateHeader."Table No.")
            then
                exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(CaptionText, SMSTemplateHeader."Table Caption");
        if not FilterPageBuilder.RunModal then
            exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, CopyStr(SMSTemplateHeader."Table Caption", 1, 20), SMSTemplateHeader."Table No.");

        exit(true);
    end;

    local procedure SetFiltersOnTable(SMSTemplateHeader: Record "NPR SMS Template Header"; Filters: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        OutStream: OutStream;
    begin
        RecRef.Open(SMSTemplateHeader."Table No.");

        if Filters = '' then
            exit(RecRef.FindSet);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Filters);

        if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
            exit(false);

        if SMSTemplateHeader."Table Filters".HasValue then begin
            RecRef.FilterGroup(56);
            SMSTemplateHeader.CalcFields("Table Filters");
            Clear(TempBlob);
            TempBlob.FromRecord(SMSTemplateHeader, SMSTemplateHeader.FieldNo("Table Filters"));

            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit(false);
            RecRef.FilterGroup(0);
        end;
        exit(true);
    end;

    local procedure PopulateSendList(var SMSPhoneList: List of [Text]; SMSRecipientType: enum "NPR SMS Recipient Type"; SMSGroupcode: Code[10]; SendTo: Text)
    var
        SMSGroupLine: Record "NPR SMS Rcpt. Group Line";
    begin
        Clear(SMSPhoneList);
        if SMSRecipientType = SMSRecipientType::Field then
            SMSPhoneList.Add(SendTo)
        else begin
            SMSGroupLine.SetRange("Group Code", SMSGroupcode);
            if SMSGroupLine.FindSet() then
                repeat
                    SMSPhoneList.Add(SMSGroupLine."Mobile Phone No.");
                until SMSGroupLine.Next() = 0;
        end;
    end;
    #endregion
    #region Message Log
    procedure InsertMessageLog(PhoneNo: Text; SenderNo: Text; Message: Text; SendDT: DateTime)
    var
        MessageLog: Record "NPR SMS Log";
    begin
        MessageLog.Init();
        MessageLog."Sender No." := SenderNo;
        MessageLog."Reciepient No." := PhoneNo;
        MessageLog.SetMessage(Message);
        if SendDT <> 0DT then
            MessageLog."Send on Date Time" := SendDT
        else
            MessageLog."Send on Date Time" := CurrentDateTime;
        MessageLog.Insert();
    end;

    procedure DiscardOldMessages(MessageLog: Record "NPR SMS Log") IsDiscarder: Boolean
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        SMSSetup.Get();
        if SMSSetup."Discard Msg. Older Than [Hrs]" = 0 then
            exit(false);
        if CurrentDateTime > (MessageLog."Send on Date Time" + SMSSetup."Discard Msg. Older Than [Hrs]" * 60 * 60 * 1000) then begin
            MessageLog.Status := MessageLog.Status::"Timeout Discard";
            exit(true);
        end;
    end;

    procedure UpdateMessageLog(MessageLog: Record "NPR SMS Log"; Status: Enum "NPR SMS Log Status"; ErrorMessage: Text)
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        MessageLog."Send Attempts" += 1;
        MessageLog."Last Send Attempt" := CurrentDateTime;
        case Status of
            Status::Error:
                begin
                    if MessageLog."Send Attempts" >= SMSSetup."Auto Send Attempts" then
                        MessageLog.Status := Status;

                    MessageLog.SetError(ErrorMessage);
                end;
            Status::Sent:
                begin
                    MessageLog.SetError('');
                    MessageLog."Date Time Sent" := CurrentDateTime;
                    MessageLog.Status := Status;
                end;
        end;
        MessageLog.Modify();
    end;

    #endregion
    #region Notification
    local procedure SetupNotification()
    var
        SMSSentNotification: Notification;
        NoSetupMsg: Label 'SMS setup is not initialized. Messages will not be sent.';
        NoCategoryMsg: Label 'There is no job category in SMS Setup. Messages will not be sent.';
        OpenSMSSetupMsg: Label 'Open SMS Setup';
        SMSSetup: Record "NPR SMS Setup";
    begin
        if not SMSSetup.Get() then begin
            SMSSentNotification.Message := NoSetupMsg;
            SMSSentNotification.Scope := NotificationScope::LocalScope;
            SMSSentNotification.AddAction(OpenSMSSetupMsg, Codeunit::"NPR SMS Management", 'OpenMessageSetup');
            SMSSentNotification.Send();
            exit;
        end;
        if SMSSetup."Job Queue Category Code" = '' then begin
            SMSSentNotification.Message := NoCategoryMsg;
            SMSSentNotification.Scope := NotificationScope::LocalScope;
            SMSSentNotification.AddAction(OpenSMSSetupMsg, Codeunit::"NPR SMS Management", 'OpenMessageSetup');
            SMSSentNotification.Send();
            exit;
        end;
    end;

    procedure QueuedNotification()
    var
        SMSSentNotification: Notification;
        QuedMsg: Label 'SMS message/s queued for sending.';
    begin
        SetupNotification();
        SMSSentNotification.Message := QuedMsg;
        SMSSentNotification.Scope := NotificationScope::LocalScope;
        SMSSentNotification.Send();
    end;

    local procedure ErrorNotification()
    var
        SMSSentNotification: Notification;
        MessageErr: Label 'There are errors in Message log.';
        OpenErrorsMsg: Label 'Open Message Log';
    begin
        SMSSentNotification.Message := MessageErr;
        SMSSentNotification.Scope := NotificationScope::LocalScope;
        SMSSentNotification.AddAction(OpenErrorsMsg, Codeunit::"NPR SMS Management", 'OpenErrorMessages');
        SMSSentNotification.Send();
    end;

    procedure OpenErrorMessages(SMSSentNotification: Notification)
    var
        MessageLog: Record "NPR SMS Log";
    begin
        MessageLog.SetRange(SystemCreatedBy, UserSecurityId());
        MessageLog.SetRange(Status, MessageLog.Status::Error);

        Page.Run(0, MessageLog);
    end;

    procedure OpenMessageSetup(SMSSentNotification: Notification)
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        Page.Run(0, SMSSetup);
    end;
    #endregion
    #region Template handling
    procedure FindTemplate(RecordVariant: Variant; var Template: Record "NPR SMS Template Header"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        Filters: Text;
        IsHandled: Boolean;
        TemplateFound: Boolean;
        MoreRecords: Boolean;
        CanEvaluateFilters: Boolean;
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        OnBeforeFindTemplate(IsHandled, RecordVariant, Template);
        if IsHandled then
            exit(true);

        TemplateFound := false;
        CanEvaluateFilters := DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        Template.SetRange("Table No.", RecRef.Number);
        if Template.FindSet then
            repeat
                if CanEvaluateFilters and Template."Table Filters".HasValue then begin
                    Template.CalcFields("Table Filters");
                    Clear(TempBlob);
                    TempBlob.FromRecord(Template, Template.FieldNo("Table Filters"));
                    if EvaluateConditionOnTable(RecordVariant, RecRef.Number, TempBlob) then
                        TemplateFound := true;
                end else
                    TemplateFound := true;
                if not TemplateFound then
                    MoreRecords := Template.Next <> 0;
            until TemplateFound or (not MoreRecords);

        if not TemplateFound then begin
            Template.Init;
            Template.Code := '';
        end;

        OnAfterFindTemplate(RecordVariant, Template, TemplateFound);
        exit(TemplateFound);
    end;

    local procedure SelectTemplate(RecordVariant: Variant; var Template: Record "NPR SMS Template Header"): Boolean
    var
        PossibleTemplate: Record "NPR SMS Template Header" temporary;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        Filters: Text;
        IsHandled: Boolean;
        TemplateFound: Boolean;
        CanEvaluateFilters: Boolean;
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        OnBeforeFindTemplate(IsHandled, RecordVariant, Template);
        if IsHandled then
            exit(true);

        CanEvaluateFilters := DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        Template.SetRange("Table No.", RecRef.Number);
        if Template.FindSet then
            repeat
                if CanEvaluateFilters and Template."Table Filters".HasValue then begin
                    Template.CalcFields("Table Filters");
                    Clear(TempBlob);
                    TempBlob.FromRecord(Template, Template.FieldNo("Table Filters"));
                    if EvaluateConditionOnTable(RecordVariant, RecRef.Number, TempBlob) then begin
                        PossibleTemplate := Template;
                        PossibleTemplate.Insert;
                    end;
                end else begin
                    PossibleTemplate := Template;
                    PossibleTemplate.Insert;
                end;
            until Template.Next = 0;

        TemplateFound := PossibleTemplate.FindFirst;

        if TemplateFound then
            if GuiAllowed and (PossibleTemplate.Count > 1) then
                TemplateFound := PAGE.RunModal(6059940, PossibleTemplate) = ACTION::LookupOK;

        if TemplateFound then
            Template.Get(PossibleTemplate.Code)
        else begin
            Template.Init;
            Template.Code := '';
            TemplateFound := false;
        end;

        OnAfterFindTemplate(RecordVariant, Template, TemplateFound);
        exit(TemplateFound);
    end;

    local procedure EvaluateConditionOnTable(SourceRecordVariant: Variant; TableId: Integer; TempBlob: Codeunit "Temp Blob"): Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        DataTypeManagement: Codeunit "Data Type Management";
        TableRecRef: RecordRef;
        SourceRecRef: RecordRef;
        KeyRef: KeyRef;
        FldRef: FieldRef;
        I: Integer;
    begin
        TableRecRef.Open(TableId);
        if not RequestPageParametersHelper.ConvertParametersToFilters(TableRecRef, TempBlob) then
            exit(true);

        DataTypeManagement.GetRecordRef(SourceRecordVariant, SourceRecRef);

        TableRecRef.FilterGroup(77);
        KeyRef := TableRecRef.KeyIndex(1);
        for I := 1 to KeyRef.FieldCount do begin
            FldRef := TableRecRef.Field(KeyRef.FieldIndex(I).Number);
            FldRef.SetRange(SourceRecRef.Field(KeyRef.FieldIndex(I).Number).Value);
        end;
        TableRecRef.FilterGroup(0);

        exit(not TableRecRef.IsEmpty);
    end;

    procedure MakeMessage(Template: Record "NPR SMS Template Header"; RecordVariant: Variant) SMSMessage: Text
    var
        RecRef: RecordRef;
        TemplateLine: Record "NPR SMS Template Line";
        DataTypeManagement: Codeunit "Data Type Management";
        MergeRecord: Boolean;
        CRLF: Text[2];
        Char13: Char;
        Char10: Char;
    begin
        SMSMessage := '';
        Char13 := 13;
        Char10 := 10;
        if DataTypeManagement.GetRecordRef(RecordVariant, RecRef) then
            MergeRecord := not IsRecRefEmpty(RecRef);

        TemplateLine.SetRange("Template Code", Template.Code);
        if TemplateLine.FindSet then
            repeat
                if SMSMessage <> '' then
                    SMSMessage += Format(Char13) + Format(Char10);
                if MergeRecord then
                    SMSMessage += MergeDataFields(TemplateLine."SMS Text", RecRef, Template."Report ID")
                else
                    SMSMessage += TemplateLine."SMS Text";

            until TemplateLine.Next = 0;
        exit(SMSMessage);
    end;

    local procedure MergeDataFields(TextLine: Text; var RecRef: RecordRef; ReportID: Integer): Text
    var
        DotNetRegEx: Codeunit DotNet_Regex;
        DotNetMatch: Codeunit DotNet_Match;
        FieldPos: Integer;
        ResultText: Text;
    begin
        ResultText := '';
        repeat
            DotNetRegEx.Regex('{\d+}');
            DotNetRegEx.Match(TextLine, DotNetMatch);
            if DotNetMatch.Success() then begin
                ResultText += CopyStr(TextLine, 1, DotNetMatch.Index());
                ResultText += ConvertToValue(DotNetMatch.Value(), RecRef);
                TextLine := CopyStr(TextLine, DotNetMatch.Index() + DotNetMatch.Length() + 1);
            end;
        until not DotNetMatch.Success();

        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        repeat
            DotNetRegEx.Regex(StrSubstNo(AFReportLinkTag, '.*?'));
            DotNetRegEx.Match(TextLine, DotNetMatch);
            if DotNetMatch.Success() then begin
                ResultText += CopyStr(TextLine, 1, DotNetMatch.Index());
                TextLine := CopyStr(TextLine, DotNetMatch.Index() + DotNetMatch.Length() + 1);
            end;
        until not DotNetMatch.Success();

        ResultText += TextLine;
        exit(ResultText);
    end;

    local procedure ConvertToValue(FieldNoText: Text; RecRef: RecordRef): Text
    var
        FldRef: FieldRef;
        FieldNumber: Integer;
        OptionString: Text;
        OptionNo: Integer;
        AutoFormat: Codeunit "Auto Format";
    begin
        if not Evaluate(FieldNumber, DelChr(FieldNoText, '<>', '{}')) then
            exit(FieldNoText);
        if not RecRef.FieldExist(FieldNumber) then
            exit(FieldNoText);
        FldRef := RecRef.Field(FieldNumber);
        if UpperCase(Format(FldRef.Class)) = 'FLOWFIELD' then
            FldRef.CalcField;

        if UpperCase(Format(Format(FldRef.Type))) = 'OPTION' then begin
            OptionString := Format(FldRef.OptionCaption);
            Evaluate(OptionNo, Format(FldRef.Value, 0, 9));
            exit(SelectStr(OptionNo + 1, OptionString));
        end else
            exit(Format(FldRef.Value, 0, AutoFormat.ResolveAutoFormat(Enum::"Auto Format".FromInteger(1), '')));
    end;

    local procedure IsRecRefEmpty(var RecRef: RecordRef): Boolean
    var
        EmptyRecRef: RecordRef;
    begin
        if RecRef.Number = 0 then
            exit(true);
        EmptyRecRef.Open(RecRef.Number);
        if RecRef.RecordId = EmptyRecRef.RecordId then
            exit(true);
        exit(RecRef.IsEmpty);
    end;

    local procedure GetDefaultSender(): Text
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        SMSSetup.Get();
        SMSSetup.TestField("Default Sender No.");
        exit(SMSSetup."Default Sender No.");
    end;
    #endregion
    #region Publishers

    [IntegrationEvent(false, FALSE)]
    local procedure OnBeforeFindTemplate(var IsHandled: Boolean; RecordVariant: Variant; var Template: Record "NPR SMS Template Header")
    begin
    end;

    [IntegrationEvent(false, FALSE)]
    local procedure OnAfterFindTemplate(RecordVariant: Variant; var Template: Record "NPR SMS Template Header"; var TemplateFound: Boolean)
    begin
    end;
    #endregion Publishers
    #region Subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', true, true)]
    local procedure OnBeforeShowNotification()
    var
        SMSSetup: Record "NPR SMS Setup";
        MessageLog: Record "NPR SMS Log";
    begin
        if not SMSSetup.ReadPermission then
            exit;
        if not SMSSetup.Get() then
            exit;
        MessageLog.SetRange(SystemCreatedBy, UserSecurityId());
        MessageLog.SetRange(Status, MessageLog.Status::Error);
        MessageLog.SetRange("User Notified", false);
        if MessageLog.IsEmpty then
            exit;

        MessageLog.ModifyAll("User Notified", true);

        Commit();

        ErrorNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workshift Checkpoint", 'OnAfterEndWorkshift', '', true, true)]
    local procedure CodeUnit6150627OnAfterEndWorkshift(Mode: Option; UnitNo: Code[20]; Successful: Boolean; PosEntryNo: Integer)
    var
        RecRef: RecordRef;
        SMSTemplateHeader: Record "NPR SMS Template Header";
        POSWorkshifCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        POSEndOfdayProfile: Record "NPR POS End of Day Profile";
        SMSBodyText: Text;
        Sender: Text;
        SendTo: Text;
        SMSManagement: Codeunit "NPR SMS Management";
        i: Integer;
        SendToList: list of [Text];
    begin
        if not Successful then
            exit;

        if not POSUnit.Get(UnitNo) then
            exit;

        if not POSEndOfdayProfile.Get(POSUnit."POS End of Day Profile") then
            exit;

        if (not SMSTemplateHeader.Get(POSEndOfdayProfile."SMS Profile")) then
            exit;

        POSWorkshifCheckpoint.Reset;
        POSWorkshifCheckpoint.SetRange("POS Entry No.", PosEntryNo);
        if POSWorkshifCheckpoint.FindFirst then
            RecRef.GetTable(POSWorkshifCheckpoint);

        SMSBodyText := SMSManagement.MakeMessage(SMSTemplateHeader, RecRef);

        Sender := SMSTemplateHeader."Alt. Sender";
        if Sender = '' then
            Sender := GetDefaultSender;

        SendTo := MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0);

        PopulateSendList(SendToList, SMSTemplateHeader."Recipient Type", SMSTemplateHeader."Recipient Group", SendTo);
        QueueMessages(SendToList, Sender, SMSBodyText, CurrentDateTime + 1000 * 60); //Delay 1 minute
    end;
    #endregion Subscribers
    #region Job functions
    procedure CreateMessageJob(JobCategory: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not (JobQueueEntry.ReadPermission and JobQueueEntry.WritePermission) then
            Error(PermissionErr);

        if JobCategory = '' then
            JobCategory := GetJobQueueCategoryCode();

        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Send SMS Job Handler");
        JobQueueEntry.SetRange("Job Queue Category Code", JobCategory);
        if not JobQueueEntry.FindFirst() then begin
            Clear(JobQueueEntry);
            JobQueueEntry.Init();
            JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
            JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := Codeunit::"NPR Send SMS Job Handler";
            JobQueueEntry."Job Queue Category Code" := JobCategory;
            JobQueueEntry."Run in User Session" := false;
            JobQueueEntry."Recurring Job" := true;
            JobQueueEntry."Run on Mondays" := true;
            JobQueueEntry."Run on Tuesdays" := true;
            JobQueueEntry."Run on Wednesdays" := true;
            JobQueueEntry."Run on Thursdays" := true;
            JobQueueEntry."Run on Fridays" := true;
            JobQueueEntry."Run on Saturdays" := true;
            JobQueueEntry."Run on Sundays" := true;
            JobQueueEntry."Maximum No. of Attempts to Run" := 10000;
            JobQueueEntry."No. of Minutes between Runs" := 1;
            JobQueueEntry.Insert(true);
            CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
        end;
        if not (JobQueueEntry.Status In [JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process"]) then begin
            JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
            JobQueueEntry.Modify();
        end;

    end;

    procedure DeleteMessageJob(JobCategory: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not (JobQueueEntry.ReadPermission and JobQueueEntry.WritePermission) then
            Error(PermissionErr);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Send SMS Job Handler");
        JobQueueEntry.Setfilter("Job Queue Category Code", '%1', JobCategory);
        JobQueueEntry.DeleteAll(true);
    end;

    local procedure GetJobQueueCategoryCode(): Code[10]
    var
        SMSSetup: Record "NPR SMS Setup";
        JobQueueCategory: Record "Job Queue Category";
        DefMessJobCatLbl: Label 'SendMessage';
    begin
        SMSSetup.Get();
        if SMSSetup."Job Queue Category Code" <> '' then
            exit(SMSSetup."Job Queue Category Code");

        JobQueueCategory.InsertRec(
            CopyStr(DefMessJobCatLbl, 1, MaxStrLen(JobQueueCategory.Code)),
            CopyStr(DefMessJobCatLbl, 1, MaxStrLen(JobQueueCategory.Description)));
        exit(JobQueueCategory.Code);
    end;
    #endregion
    #region Report Links Azure Functions
    procedure AFReportLink(ReportId: Integer): Text
    begin
        if ReportId = 0 then
            exit('');
        exit(AFReportLinkTag);
    end;

    local procedure AFReportLinkTag(): Text
    begin
        exit('<<AFReportLink>>');
    end;
    #endregion Report Links Azure Functions
}