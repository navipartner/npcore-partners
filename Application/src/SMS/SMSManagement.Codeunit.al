codeunit 6059940 "NPR SMS Management"
{
    var
        DataTypeManagement: Codeunit "Data Type Management";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        NaviDocsHandlingProfileTxt: Label 'Send SMS';
        SMSFilterCaption: Label 'Filters for %1 table';
        NoRecordSelectedTxt: Label 'No record was selected. Send SMS based on blank record?';
        NoTemplateTxt: Label 'There is no %1 that match the %2 record.';
        SMSSentTxt: Label 'Message sent.';
        Error001: Label 'SMS Message and Phone No must be suplied.';
        Error002: Label 'You are not allowed to use the %1 service.';
        Error003: Label 'Multiple receipients aren''t allowed.';
        Error004: Label 'SMS wasn''t sent. The service returned:\%1';
        Error005: Label 'Can''t find %1 for %2 %3.';
        Error006: Label 'Send SMS returned: %1';
        NaviDocsNotEnabledTxt: Label 'NaviDocs isn''t enabled.';
        SetupNaviDocsTxt: Label 'Do you want to set it up now?';
        MessageChangeTxt: Label 'You have changed the Sender or Message body. NaviDocs can only send based on the info in Template. Do you want to send direct now?';
        SMSAddedToNaviDocsTxt: Label 'Message added to NaviDocs Queue.';
        NoRecordsText: Label 'No records within the combination of filteres entred and filters on Template.';
        BatchSendStatusText: Label '%1 records withing the filter:  %2';
        CaptionText: Label 'Filters - %1', Comment = '%1 = Table Name';
        NaviDocsProgressDialogText: Label 'Adding Messages to NaviDocs: @1@@@@@@@@@@@@@@@@@@@@@@@';
        SendingProgressDialogText: Label 'Sending Messages: @1@@@@@@@@@@@@@@@@@@@@@@@';
        AFSetupMissingTxt: Label 'Azure Functions Messages Service isn''t set up. Go to setup page?';

    procedure SendSMS(PhoneNo: Text; Sender: Text; SMSMessage: Text)
    var
        IComm: Record "NPR I-Comm";
        ServiceCalc: Codeunit "NPR Service Calculation";
        SMSHandled: Boolean;
        ForeignPhone: Boolean;
        ServiceCode: Code[20];
        Result: Text;
        ErrorHandled: Boolean;
        ResponseString: Text;
    begin
        OnSendSMS(SMSHandled, PhoneNo, Sender, SMSMessage);
        if SMSHandled then
            exit;

        IComm.Get;
        IComm.TestField("SMS Provider");
        if IComm."SMS Provider" <> IComm."SMS Provider"::NaviPartner then
            exit;

        PhoneNo := DelChr(PhoneNo, '<=>', ' ');
        if (PhoneNo = '') or (SMSMessage = '') then
            Error(Error001);

        if StrPos(PhoneNo, ',') <> 0 then
            Error(Error003);

        ForeignPhone := (CopyStr(PhoneNo, 1, 1) = '+') and (CopyStr(PhoneNo, 1, 3) <> '+45');
        if ForeignPhone then
            ServiceCode := 'SMSUDLAND'
        else begin
            ServiceCode := 'ECLUBSMS';
            if CopyStr(PhoneNo, 1, 3) <> '+45' then
                PhoneNo := '+45' + PhoneNo;
        end;

        if Sender = '' then begin
            IComm.TestField("E-Club Sender");
            Sender := IComm."E-Club Sender";
        end;

        if ServiceCalc.useService(ServiceCode) then begin
            if CallRestWebServiceNew(AzureKeyVaultMgt.GetSecret('SMSMgtHTTPRequestUrl'), Sender, PhoneNo, SMSMessage, ResponseString) then begin
                OnSMSSendSuccess(PhoneNo, Sender, SMSMessage, Result);
            end else begin
                ErrorHandled := false;
                OnSMSSendError(ErrorHandled, PhoneNo, Sender, SMSMessage, GetLastErrorText);
                if not ErrorHandled then
                    Error(StrSubstNo(Error004, GetLastErrorText));
            end;
        end else
            Error(StrSubstNo(Error002, ServiceCode));
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
    begin
        DialogPage.SetRecord(Template);
        if DialogPage.RunModal <> ACTION::OK then
            exit;

        DialogPage.GetData(SendTo, RecRef, SMSBodyText, Sender, SendingOption, DelayUntil);

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
        if SendingOption = SendingOption::NaviDocs then begin
            if Sender <> Template."Alt. Sender" then
                if Sender <> GetDefaultSender then
                    Changed := true;
            if not Changed then
                if SMSBodyText <> MakeMessage(Template, RecRef) then
                    Changed := true;
            if not Changed then begin
                AddSMStoNaviDocsExt(RecRef, SendTo, Template.Code, DelayUntil);
                Message(SMSAddedToNaviDocsTxt);
                exit;
            end else
                if not Confirm(MessageChangeTxt) then
                    exit;
        end;
        SendSMS(SendTo, Sender, SMSBodyText);
        Message(SMSSentTxt);
    end;

    procedure SendBatchSMS(SMSTemplateHeader: Record "NPR SMS Template Header")
    var
        SMSSendMessage: Page "NPR SMS Send Message";
        RecRef: RecordRef;
        SendTo: Text;
        Filters: Text;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
        SendOption: Option Direct,NaviDocs;
        DelayUntil: DateTime;
        DummyTxt: Text;
        DummyRecRef: RecordRef;
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

        SMSSendMessage.SetData('', DummyRecRef, SMSTemplateHeader."Alt. Sender", 2, StrSubstNo(BatchSendStatusText, SMSTemplateHeader."Table Caption", Total));
        SMSSendMessage.SetRecord(SMSTemplateHeader);
        if SMSSendMessage.RunModal <> ACTION::OK then
            exit;

        SMSSendMessage.GetData(DummyTxt, DummyRecRef, DummyTxt, DummyTxt, SendOption, DelayUntil);
        Counter := 0;
        if SendOption = SendOption::NaviDocs then
            Window.Open(NaviDocsProgressDialogText)
        else
            Window.Open(SendingProgressDialogText);
        if RecRef.FindSet then
            repeat
                Counter += 1;
                Window.Update(1, Round((Counter / Total) * 10000, 1));
                SendTo := MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0);

                if SendOption = SendOption::NaviDocs then
                    AddSMStoNaviDocsExt(RecRef, SendTo, SMSTemplateHeader.Code, DelayUntil)
                else
                    SendSMS(SendTo, SMSTemplateHeader."Alt. Sender", MakeMessage(SMSTemplateHeader, RecRef));
            until RecRef.Next = 0;
        Window.Close;
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
        Changed: Boolean;
    begin
        if not DataTypeManagement.GetRecordRef(RecordToSendVariant, RecRef) then
            exit;
        if SelectTemplate(RecRef, SMSTemplateHeader) then begin
            Sender := SMSTemplateHeader."Alt. Sender";
            if Sender = '' then
                Sender := GetDefaultSender;
            SendTo := MergeDataFields(SMSTemplateHeader.Recipient, RecRef, 0);

            DialogPage.SetData(SendTo, RecRef, Sender, 1, '');

            DialogPage.SetRecord(SMSTemplateHeader);
            if DialogPage.RunModal <> ACTION::OK then
                exit;
            DialogPage.GetData(SendTo, RecRef, SMSBodyText, Sender, SendingOption, DelayUntil);

            if SMSTemplateHeader."Table No." <> 0 then
                if IsRecRefEmpty(RecRef) then
                    if not Confirm(NoRecordSelectedTxt) then
                        exit;
            if SMSBodyText = '' then
                SMSBodyText := MakeMessage(SMSTemplateHeader, RecRef);
            if SendingOption = SendingOption::NaviDocs then begin
                if Sender <> SMSTemplateHeader."Alt. Sender" then
                    if Sender <> GetDefaultSender then
                        Changed := true;
                if not Changed then
                    if SMSBodyText <> MakeMessage(SMSTemplateHeader, RecRef) then
                        Changed := true;
                if not Changed then begin
                    AddSMStoNaviDocsExt(RecRef, SendTo, SMSTemplateHeader.Code, DelayUntil);
                    Message(SMSAddedToNaviDocsTxt);
                    exit;
                end else
                    if not Confirm(MessageChangeTxt) then
                        exit;
            end;
            SendSMS(SendTo, Sender, SMSBodyText);
            Message(SMSSentTxt);
        end else
            Message(NoTemplateTxt, SMSTemplateHeader.TableCaption, RecRef.Caption);
    end;

    local procedure MakeSMSBody(PhoneNo: Text; Sender: Text; SMSMessage: Text): Text
    var
        XmlDoc: XmlDocument;
        Root: XmlElement;
        Xml: Text;
    begin
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><message />', XmlDoc);
        XmlDoc.GetRoot(Root);
        Root.Add(XmlElement.Create('recipients', '', PhoneNo));
        Root.Add(XmlElement.Create('sender', '', Sender));
        Root.Add(XmlElement.Create('message', '', SMSMessage));
        XmlDoc.WriteTo(Xml);
        exit(Xml);
    end;

    [TryFunction]
    local procedure CallRestWebService(BaseURL: Text; Method: Text; RestMethod: Text;
        var Content: HttpContent; var ResponseMessage: HttpResponseMessage)
    var
        WebClient: HttpClient;
        ResponseText: Text;
    begin
        case RestMethod of
            'GET':
                WebClient.Get(BaseURL, ResponseMessage);
            'POST':
                WebClient.Post(BaseURL, Content, ResponseMessage);
            'PUT':
                WebClient.Put(BaseURL, Content, ResponseMessage);
            'DELETE':
                WebClient.Delete(BaseURL, ResponseMessage);
        end;
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            Error(ResponseText);
        end;
    end;

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
        MergeRecord: Boolean;
        CRLF: Text[2];
        NewLine: Text;
    begin
        SMSMessage := '';
        NewLine := '\n';
        if DataTypeManagement.GetRecordRef(RecordVariant, RecRef) then
            MergeRecord := not IsRecRefEmpty(RecRef);

        TemplateLine.SetRange("Template Code", Template.Code);
        if TemplateLine.FindSet then
            repeat
                if MergeRecord then
                    SMSMessage += MergeDataFields(TemplateLine."SMS Text", RecRef, Template."Report ID")
                else
                    SMSMessage += TemplateLine."SMS Text";
                SMSMessage += NewLine;
            until TemplateLine.Next = 0;
        exit(SMSMessage);
    end;

    local procedure MergeDataFields(TextLine: Text; var RecRef: RecordRef; ReportID: Integer): Text
    var
        RegEx: DotNet NPRNetRegex;
        Match: DotNet NPRNetMatch;
        FieldPos: Integer;
        ResultText: Text;
    begin
        ResultText := '';
        repeat
            Match := RegEx.Match(TextLine, '{\d+}');
            if Match.Success then begin
                ResultText += CopyStr(TextLine, 1, Match.Index);
                ResultText += ConvertToValue(Match.Value, RecRef);
                TextLine := CopyStr(TextLine, Match.Index + Match.Length + 1);
            end;
        until not Match.Success;

        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        repeat
            Match := RegEx.Match(TextLine, StrSubstNo(AFReportLinkTag, '.*?'));
            if Match.Success then begin
                ResultText += CopyStr(TextLine, 1, Match.Index);
                ResultText += GetAFLink(RecRef, ReportID);
                TextLine := CopyStr(TextLine, Match.Index + Match.Length + 1);
            end;
        until not Match.Success;

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
        IComm: Record "NPR I-Comm";
    begin
        IComm.Get;
        IComm.TestField("E-Club Sender");
        exit(IComm."E-Club Sender");
    end;

    local procedure GetDefaultSenderTo(i: Integer): Text
    var
        IComm: Record "NPR I-Comm";
    begin
        IComm.Get;
        case i of
            1: //Default
                begin
                    IComm.TestField("Reg. Turnover Mobile No.");
                    exit(IComm."Reg. Turnover Mobile No.");
                end;
            2:
                exit(IComm."Register Turnover Mobile 2"); //Option 2
            3:
                exit(IComm."Register Turnover Mobile 3"); //Option 3
        end;
    end;
    #endregion

    #region Publishers
    [IntegrationEvent(false, false)]
    local procedure OnSendSMS(var Handled: Boolean; PhoneNo: Text; Sender: Text; SMSMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSMSSendSuccess(Recepient: Text; Sender: Text; SMSMessage: Text; Result: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSMSSendError(var ThrowError: Boolean; Recepient: Text; Sender: Text; SMSMessage: Text; ErrorMessage: Text)
    begin
    end;

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
    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR SendSMS', true, true)]
    local procedure Page21OnAfterActionEventSendSMS(var Rec: Record Customer)
    var
        AlternativeNo: Record "NPR Alternative No.";
    begin
        EditAndSendSMS(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 41, 'OnAfterActionEvent', 'NPR SendSMS', true, true)]
    local procedure Page41OnAfterActionEventSendSMS(var Rec: Record "Sales Header")
    var
        AlternativeNo: Record "NPR Alternative No.";
    begin
        EditAndSendSMS(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR SendSMS', true, true)]
    local procedure Page42OnAfterActionEventSendSMS(var Rec: Record "Sales Header")
    var
        AlternativeNo: Record "NPR Alternative No.";
    begin
        EditAndSendSMS(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterActionEvent', 'NPR SendSMS', true, true)]
    local procedure Page5050OnAfterActionEventSendSMS(var Rec: Record Contact)
    var
        AlternativeNo: Record "NPR Alternative No.";
    begin
        EditAndSendSMS(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page6150652OnAfterActionEventSendSMS(var Rec: Record "NPR POS Entry")
    begin
        EditAndSendSMS(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150627, 'OnAfterEndWorkshift', '', true, true)]
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
    begin
        if Successful then begin
            if POSUnit.Get(UnitNo) then
                if POSEndOfdayProfile.Get(POSUnit."POS End of Day Profile") then begin
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

                    for i := 1 to 3 do begin
                        SendTo := GetDefaultSenderTo(i);
                        if SendTo <> '' then
                            SendSMS(SendTo, Sender, SMSBodyText);
                    end;
                end;
        end;
    end;
    #endregion Subscribers

    #region NaviDocs functions
    procedure IsNaviDocsAvailable(AskUserToMakeSetup: Boolean)
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        SetupOK: Boolean;
    begin
        SetupOK := (NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs");
        if (not SetupOK) and AskUserToMakeSetup then
            if Confirm(StrSubstNo('%1 %2', NaviDocsNotEnabledTxt, SetupNaviDocsTxt)) then
                PAGE.RunModal(6059767, NaviDocsSetup);
        SetupOK := (NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs");
        if not SetupOK then
            Error(NaviDocsNotEnabledTxt);
        AddNaviDocsHandlingProfile;
    end;

    procedure AddSMStoNaviDocs(RecordVariant: Variant; PhoneNo: Text)
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfile(RecRef, NaviDocsHandlingProfileCode, 0, PhoneNo, 0DT);
    end;

    procedure AddSMStoNaviDocsExt(RecordVariant: Variant; PhoneNo: Text; TemplateCode: Code[20]; DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfileExt(RecRef, NaviDocsHandlingProfileCode, 0, PhoneNo, TemplateCode, DelayUntil);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode, NaviDocsHandlingProfileTxt, false, false, false, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnShowTemplate', '', false, false)]
    local procedure ShowTemplateFromNaviDocs(var RequestHandled: Boolean; NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        SMSTemplateHeader: Record "NPR SMS Template Header";
        RecRef: RecordRef;
    begin
        if RequestHandled or (NaviDocsEntry."Document Handling Profile" <> NaviDocsHandlingProfileCode) then
            exit;
        RequestHandled := true;

        if NaviDocsEntry."Template Code" <> '' then
            if SMSTemplateHeader.Get(NaviDocsEntry."Template Code") then begin
                PAGE.RunModal(PAGE::"NPR SMS Template Card", SMSTemplateHeader);
                exit;
            end;

        if not RecRef.Get(NaviDocsEntry."Record ID") then
            exit;
        if FindTemplate(RecRef, SMSTemplateHeader) then
            PAGE.RunModal(PAGE::"NPR SMS Template Card", SMSTemplateHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnManageDocument', '', false, false)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    var
        SMSTemplateHeader: Record "NPR SMS Template Header";
        RecRef: RecordRef;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
            exit;
        if NaviDocsEntry."Template Code" <> '' then
            SMSTemplateHeader.SetRange(Code, NaviDocsEntry."Template Code");

        if RecRef.Get(NaviDocsEntry."Record ID") then;
        if not FindTemplate(RecRef, SMSTemplateHeader) then
            ErrorMessage := StrSubstNo(Error005, SMSTemplateHeader.TableCaption, NaviDocsEntry."Document Description", NaviDocsEntry."No.");
        if ErrorMessage = '' then
            if not TrySendSMSForNaviDocs(NaviDocsEntry, SMSTemplateHeader, RecRef) then
                ErrorMessage := StrSubstNo(Error006, GetLastErrorText);
        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    [TryFunction]
    local procedure TrySendSMSForNaviDocs(var NaviDocsEntry: Record "NPR NaviDocs Entry"; var SMSTemplateHeader: Record "NPR SMS Template Header"; RecRef: RecordRef)
    var
        SMSManagement: Codeunit "NPR SMS Management";
    begin
        SMSManagement.SendSMS(NaviDocsEntry."E-mail (Recipient)", SMSTemplateHeader."Alt. Sender", MakeMessage(SMSTemplateHeader, RecRef));
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        exit('SMS');
    end;
    #endregion NaviDocs functions

    #region Report Links Azure Functions
    procedure AFReportLink(ReportId: Integer): Text
    var
        AFSetup: Record "NPR AF Setup";
    begin
        while not (AFSetup.Get and AFSetup."Msg Service - Site Created") do begin
            if not Confirm(AFSetupMissingTxt) then
                exit('');
            PAGE.RunModal(0, AFSetup);
        end;
        if ReportId = 0 then
            exit('');
        exit(AFReportLinkTag);
    end;

    local procedure GetAFLink(RecRef: RecordRef; ReportID: Integer): Text
    var
        RegEx: DotNet NPRNetRegex;
        Match: DotNet NPRNetMatch;
        AFAPIMsgService: Codeunit "NPR AF API - Msg Service";
    begin
        exit(AFAPIMsgService.CreateSMSBody(RecRef.RecordId, ReportID, ''));
    end;

    local procedure AFReportLinkTag(): Text
    begin
        exit('<<AFReportLink>>');
    end;
    #endregion Report Links Azure Functions

    [TryFunction]
    local procedure CallRestWebServiceNew(RequestURL: Text; Sender: Text; Destination: Text; SMSMessage: Text; var ResponseString: Text)
    var
        RequestString: Text;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        WebClient: HttpClient;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        RequestString := '{';
        RequestString += '"source":"' + Sender + '",';
        RequestString += '"destination": "' + Destination + '",';
        RequestString += '"userData": "' + SMSMessage + '",';
        RequestString += '"platformId": "COOL",';
        RequestString += '"platformPartnerId": "' + AzureKeyVaultMgt.GetSecret('SMSMgtPlatformPartnerId') + '",';
        RequestString += '"useDeliveryReport": false}';

        RequestMessage.SetRequestUri(RequestURL);
        RequestMessage.Method := 'POST';
        RequestMessage.GetHeaders(Headers);
        if Headers.Contains('Authorization') then
            Headers.Remove('Authorization');
        Headers.Add('Authorization', 'Basic ' + GetBasicAuthInfo(AzureKeyVaultMgt.GetSecret('SMSMgtUsername'), AzureKeyVaultMgt.GetSecret('SMSMgtPassword')));

        RequestMessage.Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json;charset=utf-8');

        RequestMessage.Content.WriteFrom(RequestString);

        WebClient.Send(RequestMessage, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseString);
        if not ResponseMessage.IsSuccessStatusCode then
            Error('%1 - %2 - %3',
                ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ResponseString);
    end;

    procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(StrSubstNo('%1:%2', Username, Password)))
    end;
}