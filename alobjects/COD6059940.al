codeunit 6059940 "SMS Management"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.27/MHA /20161025 CASE 255580 Update Format on Option Evaluation
    // NPR5.30/THRO/20170203 CASE 263182 Added EditAndSendSMS and SelectTemplate - used for show and send a sms
    //                                   SMS Message Text shown in Send SMS page
    //                                   Added Page subscribers
    // NPR5.36/THRO/20170913 CASE 289216 Template saved on NaviDocs Entry
    // NPR5.38/THRO/20170108 CASE 301396 Added SendBatchSMS and option to send through NaviDocs
    // NPR5.40/THRO/20180314 CASE 304312 Support for Reportlink via Azure Functions, new paramter ReportID in MergeDataFields
    //                                   Added POS Entry List page subscriber
    // NPR5.40/JC  /20180320 CASE 292485 Fixed option value text
    // NPR5.48/BHR /20181115 CASE 331217 Show correct template
    // NPR5.51/SARA/20190819 CASE 363578 Sending an SMS with the turnover based on the POS Workshift Checkpoint
    // NPR5.52/SARA/20190912 CASE 368395 Move SMS profile from POS Unit to POS End of day Profile


    trigger OnRun()
    begin
    end;

    var
        NaviDocsHandlingProfileTxt: Label 'Send SMS';
        SMSFilterCaption: Label 'Filters for %1 table';
        NoRecordSelectedTxt: Label 'No record was selected. Send SMS based on blank record?';
        NoTemplateTxt: Label 'There is no %1 that match the %2 record.';
        SMSSentTxt: Label 'Message sent.';
        Error001: Label 'SMS Message and Phone No must be suplied.';
        Error002: Label 'You are not allowed to use the %1 service.';
        Error003: Label 'Multiple receipients aren''t allowed.';
        DataTypeManagement: Codeunit "Data Type Management";
        Error004: Label 'SMS wasn''t sent. The service returned:\%1';
        Error005: Label 'Can''t find %1 for %2 %3.';
        Error006: Label 'Send SMS returned: %1';
        NaviDocsNotEnabledTxt: Label 'NaviDocs isn''t enabled.';
        SetupNaviDocsTxt: Label 'Do you want to set it up now?';
        MessageChangeTxt: Label 'You have changed the Sender or Message body. NaviDocs can only send based on the info in Template. Do you want to send direct now?';
        SMSAddedToNaviDocsTxt: Label 'Message added to NaviDocs Queue.';
        NoRecordsText: Label 'No records within the combination of filteres entred and filters on Template.';
        BatchSendStatusText: Label '%1 records withing the filter:  %2';
        CaptionText: Label 'Filters - %1', Comment='%1 = Table Name';
        NaviDocsProgressDialogText: Label 'Adding Messages to NaviDocs: @1@@@@@@@@@@@@@@@@@@@@@@@';
        SendingProgressDialogText: Label 'Sending Messages: @1@@@@@@@@@@@@@@@@@@@@@@@';
        AFSetupMissingTxt: Label 'Azure Functions Messages Service isn''t set up. Go to setup page?';

    procedure SendSMS(PhoneNo: Text;Sender: Text;SMSMessage: Text)
    var
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        StringContent: DotNet npNetStringContent;
        Encoding: DotNet npNetEncoding;
        IComm: Record "I-Comm";
        ServiceCalc: Codeunit "NP Service Calculation";
        SMSHandled: Boolean;
        ForeignPhone: Boolean;
        ServiceCode: Code[20];
        Result: Text;
        ErrorHandled: Boolean;
    begin
        OnSendSMS(SMSHandled,PhoneNo,Sender,SMSMessage);
        if SMSHandled then
          exit;

        IComm.Get;
        IComm.TestField("SMS Provider");
        if IComm."SMS Provider" <> IComm."SMS Provider"::NaviPartner then
          exit;

        PhoneNo := DelChr(PhoneNo,'<=>',' ');
        if (PhoneNo = '') or (SMSMessage = '') then
          Error(Error001);

        if StrPos(PhoneNo,',') <> 0 then
          Error(Error003);

        ForeignPhone := (CopyStr(PhoneNo,1,1) = '+') and (CopyStr(PhoneNo,1,3) <> '+45');
        if ForeignPhone then
          ServiceCode := 'SMSUDLAND'
        else begin
          ServiceCode := 'ECLUBSMS';
          if CopyStr(PhoneNo,1,3) <> '+45' then
            PhoneNo := '+45' + PhoneNo;
        end;

        if Sender = '' then begin
          IComm.TestField("E-Club Sender");
          Sender := IComm."E-Club Sender";
        end;
        if ServiceCalc.useService(ServiceCode) then begin
          StringContent := StringContent.StringContent(MakeSMSBody(PhoneNo,Sender,SMSMessage),Encoding.UTF8,'text/xml');

          if CallRestWebService('http://api.linkmobility.dk/',
                                StrSubstNo('v2/message.xml?apikey=%1',GetAPIKey),
                                'POST',
                                StringContent,
                                HttpResponseMessage) then begin
            Result := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            OnSMSSendSuccess(PhoneNo,Sender,SMSMessage,Result);
          end else begin
            ErrorHandled := false;
            OnSMSSendError(ErrorHandled,PhoneNo,Sender,SMSMessage,GetLastErrorText);
            if not ErrorHandled then
              Error(StrSubstNo(Error004,GetLastErrorText));
          end;
        end else
          Error(StrSubstNo(Error002,ServiceCode));
    end;

    procedure SendTestSMS(var Template: Record "SMS Template Header")
    var
        DialogPage: Page "SMS Send Message";
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
        //-NPR5.30 [263182]
        //-NPR5.38 [301396]
        DialogPage.GetData(SendTo,RecRef,SMSBodyText,Sender,SendingOption,DelayUntil);
        //-NPR5.38 [301396]
        if Sender = '' then
          Sender := Template."Alt. Sender";
        if Sender = '' then
          Sender := GetDefaultSender;
        //+NPR5.30 [263182]
        if Template."Table No." <> 0 then
          if IsRecRefEmpty(RecRef) then
            if not Confirm(NoRecordSelectedTxt) then
              exit;
        //-NPR5.30 [263182]
        if SMSBodyText = '' then
          SMSBodyText := MakeMessage(Template,RecRef);
        //-NPR5.38 [301396]
        if SendingOption = SendingOption::NaviDocs then begin
          if Sender <> Template."Alt. Sender" then
            if Sender <> GetDefaultSender then
              Changed := true;
          if not Changed then
            if SMSBodyText <> MakeMessage(Template,RecRef) then
              Changed := true;
          if not Changed then begin
            AddSMStoNaviDocsExt(RecRef,SendTo,Template.Code,DelayUntil);
            Message(SMSAddedToNaviDocsTxt);
            exit;
          end else
            if not Confirm(MessageChangeTxt) then
              exit;
        end;
        //+NPR5.38 [301396]
        SendSMS(SendTo,Sender,SMSBodyText);
        Message(SMSSentTxt);
        //+NPR5.30 [263182]
    end;

    procedure SendBatchSMS(SMSTemplateHeader: Record "SMS Template Header")
    var
        SMSSendMessage: Page "SMS Send Message";
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
        //-NPR5.38 [301396]
        if not RunDynamicRequestPage(SMSTemplateHeader,Filters,'') then
          exit;

        if not SetFiltersOnTable(SMSTemplateHeader,Filters,RecRef) then
          exit;

        Total := RecRef.Count;

        if Total = 0 then begin
          Message(NoRecordsText);
          exit;
        end;

        SMSSendMessage.SetData('',DummyRecRef,SMSTemplateHeader."Alt. Sender",2,StrSubstNo(BatchSendStatusText,SMSTemplateHeader."Table Caption",Total));
        //-NPR5.48 [331217]
        SMSSendMessage.SetRecord(SMSTemplateHeader);
        //+NPR5.48 [331217]
        if SMSSendMessage.RunModal <> ACTION::OK then
          exit;

        SMSSendMessage.GetData(DummyTxt,DummyRecRef,DummyTxt,DummyTxt,SendOption,DelayUntil);
        Counter := 0;
        if SendOption = SendOption::NaviDocs then
          Window.Open(NaviDocsProgressDialogText)
        else
          Window.Open(SendingProgressDialogText);
        if RecRef.FindSet then
          repeat
            Counter += 1;
            Window.Update(1,Round((Counter / Total) * 10000,1));
            SendTo := MergeDataFields(SMSTemplateHeader.Recipient,RecRef,0);

            if SendOption = SendOption::NaviDocs then
              AddSMStoNaviDocsExt(RecRef,SendTo,SMSTemplateHeader.Code,DelayUntil)
            else
              SendSMS(SendTo,SMSTemplateHeader."Alt. Sender",MakeMessage(SMSTemplateHeader,RecRef));
          until RecRef.Next = 0;
        Window.Close;
        //+NPR5.38 [301396]
    end;

    local procedure RunDynamicRequestPage(SMSTemplateHeader: Record "SMS Template Header";var ReturnFilters: Text;Filters: Text): Boolean
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
        //-NPR5.38 [301396]
        SMSTemplateHeader.CalcFields("Table Caption");
        if not TableMetadata.Get(SMSTemplateHeader."Table No.") then
          exit(false);

        DynamicRequestPageField.SetRange("Table ID",SMSTemplateHeader."Table No.");
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
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder,CopyStr(SMSTemplateHeader."Table Caption",1,20),SMSTemplateHeader."Table No.") then
          exit(false);

        if Filters <> '' then
          if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
             FilterPageBuilder,Filters,CopyStr(SMSTemplateHeader."Table Caption",1,20),SMSTemplateHeader."Table No.")
          then
            exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(CaptionText,SMSTemplateHeader."Table Caption");
        if not FilterPageBuilder.RunModal then
          exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder,CopyStr(SMSTemplateHeader."Table Caption",1,20),SMSTemplateHeader."Table No.");

        exit(true);
        //+NPR5.38 [301396]
    end;

    local procedure SetFiltersOnTable(SMSTemplateHeader: Record "SMS Template Header";Filters: Text;var RecRef: RecordRef): Boolean
    var
        TempBlob: Record TempBlob temporary;
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        OutStream: OutStream;
    begin
        //-NPR5.38 [301396]
        RecRef.Open(SMSTemplateHeader."Table No.");

        if Filters = '' then
          exit(RecRef.FindSet);

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText(Filters);

        if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef,TempBlob) then
          exit(false);

        if SMSTemplateHeader."Table Filters".HasValue then begin
          RecRef.FilterGroup(56);
          SMSTemplateHeader.CalcFields("Table Filters");
          TempBlob.Init;
          TempBlob.Blob := SMSTemplateHeader."Table Filters";

          if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef,TempBlob) then
            exit(false);
          RecRef.FilterGroup(0);
        end;
        exit(true);
        //+NPR5.38 [301396]
    end;

    procedure EditAndSendSMS(RecordToSendVariant: Variant)
    var
        RecRef: RecordRef;
        SMSTemplateHeader: Record "SMS Template Header";
        DialogPage: Page "SMS Send Message";
        SendTo: Text;
        Sender: Text;
        SMSBodyText: Text;
        SendingOption: Option Direct,NaviDocs;
        DelayUntil: DateTime;
        Changed: Boolean;
    begin
        //-NPR5.30 [263182]
        if not DataTypeManagement.GetRecordRef(RecordToSendVariant,RecRef) then
          exit;
        if SelectTemplate(RecRef,SMSTemplateHeader) then begin
          Sender := SMSTemplateHeader."Alt. Sender";
          if Sender = '' then
            Sender := GetDefaultSender;
          SendTo := MergeDataFields(SMSTemplateHeader.Recipient,RecRef,0);
        //-NPR5.38 [301396]
          DialogPage.SetData(SendTo,RecRef,Sender,1,'');
        //+NPR5.38 [301396]
          DialogPage.SetRecord(SMSTemplateHeader);
          if DialogPage.RunModal <> ACTION::OK then
            exit;
        //-NPR5.38 [301396]
          DialogPage.GetData(SendTo,RecRef,SMSBodyText,Sender,SendingOption,DelayUntil);
        //-NPR5.38 [301396]

          if SMSTemplateHeader."Table No." <> 0 then
            if IsRecRefEmpty(RecRef) then
              if not Confirm(NoRecordSelectedTxt) then
                exit;
          if SMSBodyText = '' then
            SMSBodyText := MakeMessage(SMSTemplateHeader,RecRef);
        //-NPR5.38 [301396]
          if SendingOption = SendingOption::NaviDocs then begin
            if Sender <> SMSTemplateHeader."Alt. Sender" then
              if Sender <> GetDefaultSender then
                Changed := true;
            if not Changed then
              if SMSBodyText <> MakeMessage(SMSTemplateHeader,RecRef) then
                Changed := true;
            if not Changed then begin
              AddSMStoNaviDocsExt(RecRef,SendTo,SMSTemplateHeader.Code,DelayUntil);
              Message(SMSAddedToNaviDocsTxt);
              exit;
            end else
              if not Confirm(MessageChangeTxt) then
                exit;
          end;
        //+NPR5.38 [301396]
          SendSMS(SendTo,Sender,SMSBodyText);
          Message(SMSSentTxt);
        end else
          Message(NoTemplateTxt,SMSTemplateHeader.TableCaption,RecRef.Caption);
        //+NPR5.30 [263182]
    end;

    local procedure MakeSMSBody(PhoneNo: Text;Sender: Text;SMSMessage: Text): Text
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlNode: DotNet npNetXmlNode;
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XMLDOMManagement.AddRootElement(XmlDoc,'message',XmlNode);
        XMLDOMManagement.AddNode(XmlNode,'recipients',PhoneNo);
        XMLDOMManagement.AddNode(XmlNode,'sender',Sender);
        XMLDOMManagement.AddNode(XmlNode,'message',SMSMessage);
        exit(XmlDoc.InnerXml);
    end;

    [TryFunction]
    local procedure CallRestWebService(BaseURL: Text;Method: Text;RestMethod: Text;var HttpContent: DotNet npNetHttpContent;var HttpResponseMessage: DotNet npNetHttpResponseMessage)
    var
        HttpClient: DotNet npNetHttpClient;
        Uri: DotNet npNetUri;
    begin
        HttpClient := HttpClient.HttpClient;
        HttpClient.BaseAddress := Uri.Uri(BaseURL);
        case RestMethod of
          'GET':
            HttpResponseMessage := HttpClient.GetAsync(Method).Result;
          'POST':
            HttpResponseMessage := HttpClient.PostAsync(Method,HttpContent).Result;
          'PUT':
            HttpResponseMessage := HttpClient.PutAsync(Method,HttpContent).Result;
          'DELETE':
            HttpResponseMessage := HttpClient.DeleteAsync(Method).Result;
        end;
        if not HttpResponseMessage.IsSuccessStatusCode then
          Error(HttpResponseMessage.Content.ReadAsStringAsync.Result);
    end;

    local procedure GetAPIKey(): Text
    begin
        exit('37840e6e3c65e3d6677ef0d3be559d8d4ca7af3b95efbc50f71ab019df83a35b');
    end;

    local procedure "--- Template handling"()
    begin
    end;

    procedure FindTemplate(RecordVariant: Variant;var Template: Record "SMS Template Header"): Boolean
    var
        TempBlob: Record TempBlob;
        RecRef: RecordRef;
        Filters: Text;
        IsHandled: Boolean;
        TemplateFound: Boolean;
        MoreRecords: Boolean;
        CanEvaluateFilters: Boolean;
    begin
        OnBeforeFindTemplate(IsHandled,RecordVariant,Template);
        if IsHandled then
          exit(true);

        TemplateFound := false;
        CanEvaluateFilters := DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
        Template.SetRange("Table No.",RecRef.Number);
        if Template.FindSet then
          repeat
            if CanEvaluateFilters and Template."Table Filters".HasValue then begin
              Template.CalcFields("Table Filters");
              TempBlob.Init;
              TempBlob.Blob := Template."Table Filters";
              if EvaluateConditionOnTable(RecordVariant,RecRef.Number,TempBlob) then
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

        OnAfterFindTemplate(RecordVariant,Template,TemplateFound);
        exit(TemplateFound);
    end;

    local procedure SelectTemplate(RecordVariant: Variant;var Template: Record "SMS Template Header"): Boolean
    var
        PossibleTemplate: Record "SMS Template Header" temporary;
        TempBlob: Record TempBlob;
        RecRef: RecordRef;
        Filters: Text;
        IsHandled: Boolean;
        TemplateFound: Boolean;
        CanEvaluateFilters: Boolean;
    begin
        //-NPR5.30 [263182]
        OnBeforeFindTemplate(IsHandled,RecordVariant,Template);
        if IsHandled then
          exit(true);

        CanEvaluateFilters := DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
        Template.SetRange("Table No.",RecRef.Number);
        if Template.FindSet then
          repeat
            if CanEvaluateFilters and Template."Table Filters".HasValue then begin
              Template.CalcFields("Table Filters");
              TempBlob.Init;
              TempBlob.Blob := Template."Table Filters";
              if EvaluateConditionOnTable(RecordVariant,RecRef.Number,TempBlob) then begin
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
            TemplateFound := PAGE.RunModal(6059940,PossibleTemplate) = ACTION::LookupOK;

        if TemplateFound then
          Template.Get(PossibleTemplate.Code)
        else begin
          Template.Init;
          Template.Code := '';
          TemplateFound := false;
        end;

        OnAfterFindTemplate(RecordVariant,Template,TemplateFound);
        exit(TemplateFound);
        //+NPR5.30 [263182]
    end;

    local procedure EvaluateConditionOnTable(SourceRecordVariant: Variant;TableId: Integer;TempBlob: Record TempBlob): Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        TableRecRef: RecordRef;
        SourceRecRef: RecordRef;
        KeyRef: KeyRef;
        FldRef: FieldRef;
        I: Integer;
    begin
        TableRecRef.Open(TableId);
        if not RequestPageParametersHelper.ConvertParametersToFilters(TableRecRef,TempBlob) then
          exit(true);

        DataTypeManagement.GetRecordRef(SourceRecordVariant,SourceRecRef);

        TableRecRef.FilterGroup(77);
        KeyRef := TableRecRef.KeyIndex(1);
        for I := 1 to KeyRef.FieldCount do begin
          FldRef := TableRecRef.Field(KeyRef.FieldIndex(I).Number);
          FldRef.SetRange(SourceRecRef.Field(KeyRef.FieldIndex(I).Number).Value);
        end;
        TableRecRef.FilterGroup(0);

        exit(not TableRecRef.IsEmpty);
    end;

    procedure MakeMessage(Template: Record "SMS Template Header";RecordVariant: Variant) SMSMessage: Text
    var
        RecRef: RecordRef;
        TemplateLine: Record "SMS Template Line";
        MergeRecord: Boolean;
        CRLF: Text[2];
    begin
        SMSMessage := '';
        CRLF[1] := 13;
        CRLF[2] := 10;
        if DataTypeManagement.GetRecordRef(RecordVariant,RecRef) then
          MergeRecord := not IsRecRefEmpty(RecRef);

        TemplateLine.SetRange("Template Code",Template.Code);
        if TemplateLine.FindSet then
          repeat
            if MergeRecord then
              SMSMessage += MergeDataFields(TemplateLine."SMS Text",RecRef,Template."Report ID")
            else
              SMSMessage += TemplateLine."SMS Text";
            SMSMessage += CRLF;
          until TemplateLine.Next = 0;
        exit(SMSMessage);
    end;

    local procedure MergeDataFields(TextLine: Text;var RecRef: RecordRef;ReportID: Integer): Text
    var
        RegEx: DotNet npNetRegex;
        Match: DotNet npNetMatch;
        FieldPos: Integer;
        ResultText: Text;
    begin
        ResultText := '';
        repeat
          Match := RegEx.Match(TextLine,'{\d+}');
          if Match.Success then begin
            ResultText += CopyStr(TextLine,1,Match.Index);
            ResultText += ConvertToValue(Match.Value,RecRef);
            TextLine := CopyStr(TextLine,Match.Index + Match.Length + 1);
          end;
        until not Match.Success;
        //-NPR5.40 [304312]
        ResultText += TextLine;
        TextLine := ResultText;
        ResultText := '';
        repeat
          Match := RegEx.Match(TextLine,StrSubstNo(AFReportLinkTag,'.*?'));
          if Match.Success then begin
            ResultText += CopyStr(TextLine,1,Match.Index);
            ResultText += GetAFLink(RecRef,ReportID);
            TextLine := CopyStr(TextLine,Match.Index + Match.Length + 1);
          end;
        until not Match.Success;
        //-NPR5.40 [304312]
        ResultText += TextLine;
        exit(ResultText);
    end;

    local procedure ConvertToValue(FieldNoText: Text;RecRef: RecordRef): Text
    var
        FldRef: FieldRef;
        FieldNumber: Integer;
        OptionString: Text;
        OptionNo: Integer;
        AutoFormatManagement: Codeunit AutoFormatManagement;
    begin
        if not Evaluate(FieldNumber,DelChr(FieldNoText,'<>','{}')) then
          exit(FieldNoText);
        if not RecRef.FieldExist(FieldNumber) then
          exit(FieldNoText);
        FldRef := RecRef.Field(FieldNumber);
        if UpperCase(Format(FldRef.Class)) = 'FLOWFIELD' then
          FldRef.CalcField;

        if UpperCase(Format(Format(FldRef.Type))) = 'OPTION' then begin
          OptionString := Format(FldRef.OptionCaption);
          //-NPR5.27 [255580]
          //EVALUATE(OptionNo,FORMAT(FldRef.VALUE));
          Evaluate(OptionNo,Format(FldRef.Value,0,9));
          //+NPR5.27 [255580]
          //+NPR5.40 [292485]
          //EXIT(SELECTSTR(OptionNo,OptionString));
          exit(SelectStr(OptionNo+1,OptionString));
          //+NPR5.40
        end else
          exit(Format(FldRef.Value,0,AutoFormatManagement.AutoFormatTranslate(1,'')));
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
        IComm: Record "I-Comm";
    begin
        //-NPR5.30 [263182]
        IComm.Get;
        IComm.TestField("E-Club Sender");
        exit(IComm."E-Club Sender");
        //+NPR5.30 [263182]
    end;

    local procedure GetDefaultSenderTo(): Text
    var
        IComm: Record "I-Comm";
    begin
        //-NPR5.51 [363578]
        IComm.Get;
        IComm.TestField("Reg. Turnover Mobile No.");
        exit(IComm."Reg. Turnover Mobile No.");
        //-NPR5.51 [363578]
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSendSMS(var Handled: Boolean;PhoneNo: Text;Sender: Text;SMSMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSMSSendSuccess(Recepient: Text;Sender: Text;SMSMessage: Text;Result: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSMSSendError(var ThrowError: Boolean;Recepient: Text;Sender: Text;SMSMessage: Text;ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, FALSE)]
    local procedure OnBeforeFindTemplate(var IsHandled: Boolean;RecordVariant: Variant;var Template: Record "SMS Template Header")
    begin
    end;

    [IntegrationEvent(false, FALSE)]
    local procedure OnAfterFindTemplate(RecordVariant: Variant;var Template: Record "SMS Template Header";var TemplateFound: Boolean)
    begin
    end;

    local procedure "-- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page21OnAfterActionEventSendSMS(var Rec: Record Customer)
    var
        AlternativeNo: Record "Alternative No.";
    begin
        //-NPR5.30 [263182]
        EditAndSendSMS(Rec);
        //+NPR5.30 [263182]
    end;

    [EventSubscriber(ObjectType::Page, 41, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page41OnAfterActionEventSendSMS(var Rec: Record "Sales Header")
    var
        AlternativeNo: Record "Alternative No.";
    begin
        //-NPR5.30 [263182]
        EditAndSendSMS(Rec);
        //+NPR5.30 [263182]
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page42OnAfterActionEventSendSMS(var Rec: Record "Sales Header")
    var
        AlternativeNo: Record "Alternative No.";
    begin
        //-NPR5.30 [263182]
        EditAndSendSMS(Rec);
        //+NPR5.30 [263182]
    end;

    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page5050OnAfterActionEventSendSMS(var Rec: Record Contact)
    var
        AlternativeNo: Record "Alternative No.";
    begin
        //-NPR5.30 [263182]
        EditAndSendSMS(Rec);
        //+NPR5.30 [263182]
    end;

    [EventSubscriber(ObjectType::Page, 6150652, 'OnAfterActionEvent', 'SendSMS', true, true)]
    local procedure Page6150652OnAfterActionEventSendSMS(var Rec: Record "POS Entry")
    begin
        //-NPR5.40 [304312]
        EditAndSendSMS(Rec);
        //+NPR5.40 [304312]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150627, 'OnAfterEndWorkshift', '', true, true)]
    local procedure CodeUnit6150627OnAfterEndWorkshift(Mode: Option;UnitNo: Code[20];Successful: Boolean;PosEntryNo: Integer)
    var
        RecRef: RecordRef;
        SMSTemplateHeader: Record "SMS Template Header";
        POSWorkshifCheckpoint: Record "POS Workshift Checkpoint";
        POSUnit: Record "POS Unit";
        POSEndOfdayProfile: Record "POS End of Day Profile";
        SMSBodyText: Text;
        Sender: Text;
        SendTo: Text;
        SMSManagement: Codeunit "SMS Management";
    begin
        //-NPR5.51 [363578]
        if Successful then begin
          if POSUnit.Get(UnitNo) then
          //-NPR5.52 [368395]
          if POSEndOfdayProfile.Get(POSUnit."POS End of Day Profile") then begin
            // SMSTemplateHeader.GET(POSEndOfdayProfile."SMS Profile");
            if (not SMSTemplateHeader.Get(POSEndOfdayProfile."SMS Profile")) then
              exit;
          //-NPR5.52 [368395]
            POSWorkshifCheckpoint.Reset;
            POSWorkshifCheckpoint.SetRange("POS Entry No.",PosEntryNo);
            if POSWorkshifCheckpoint.FindFirst then
              RecRef.GetTable(POSWorkshifCheckpoint);
            SMSBodyText := SMSManagement.MakeMessage(SMSTemplateHeader,RecRef);

            Sender := SMSTemplateHeader."Alt. Sender";
            if Sender = '' then
              Sender := GetDefaultSender;
            SendTo := GetDefaultSenderTo;
            SendSMS(SendTo,Sender,SMSBodyText);
          end;
        end;
        //+NPR5.51 [363578]
    end;

    local procedure "-- NaviDocs functions"()
    begin
    end;

    procedure IsNaviDocsAvailable(AskUserToMakeSetup: Boolean)
    var
        NaviDocsSetup: Record "NaviDocs Setup";
        SetupOK: Boolean;
    begin
        //-NPR5.38 [301396]
        SetupOK := (NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs");
        if (not SetupOK) and AskUserToMakeSetup then
          if Confirm(StrSubstNo('%1 %2',NaviDocsNotEnabledTxt,SetupNaviDocsTxt)) then
            PAGE.RunModal(6059767,NaviDocsSetup);
        SetupOK := (NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs");
        if not SetupOK then
          Error(NaviDocsNotEnabledTxt);
        AddNaviDocsHandlingProfile;
        //+NPR5.38 [301396]
    end;

    procedure AddSMStoNaviDocs(RecordVariant: Variant;PhoneNo: Text)
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfile(RecRef,NaviDocsHandlingProfileCode,0,PhoneNo,0DT);
    end;

    procedure AddSMStoNaviDocsExt(RecordVariant: Variant;PhoneNo: Text;TemplateCode: Code[20];DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
        RecRef: RecordRef;
    begin
        //-NPR5.38 [301396]
        DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfileExt(RecRef,NaviDocsHandlingProfileCode,0,PhoneNo,TemplateCode,DelayUntil);
        //+NPR5.38 [301396]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
    begin
        NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode,NaviDocsHandlingProfileTxt,false,false,false,false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnShowTemplate', '', false, false)]
    local procedure ShowTemplateFromNaviDocs(var RequestHandled: Boolean;NaviDocsEntry: Record "NaviDocs Entry")
    var
        SMSTemplateHeader: Record "SMS Template Header";
        RecRef: RecordRef;
    begin
        if RequestHandled or (NaviDocsEntry."Document Handling Profile" <> NaviDocsHandlingProfileCode) then
          exit;
        RequestHandled := true;

        //-NPR5.36 [289216]
        if NaviDocsEntry."Template Code" <> '' then
          if SMSTemplateHeader.Get(NaviDocsEntry."Template Code") then begin
            PAGE.RunModal(PAGE::"SMS Template Card",SMSTemplateHeader);
            exit;
          end;
        //+NPR5.36 [289216]
        if not RecRef.Get(NaviDocsEntry."Record ID") then
          exit;
        if FindTemplate(RecRef,SMSTemplateHeader) then
          PAGE.RunModal(PAGE::"SMS Template Card",SMSTemplateHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnManageDocument', '', false, false)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean;ProfileCode: Code[20];var NaviDocsEntry: Record "NaviDocs Entry";ReportID: Integer;var WithSuccess: Boolean;var ErrorMessage: Text)
    var
        SMSTemplateHeader: Record "SMS Template Header";
        RecRef: RecordRef;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
          exit;
        //-NPR5.36 [289216]
        if NaviDocsEntry."Template Code" <> '' then
          SMSTemplateHeader.SetRange(Code,NaviDocsEntry."Template Code");
        //+NPR5.36 [289216]

        if RecRef.Get(NaviDocsEntry."Record ID") then;
        if not FindTemplate(RecRef,SMSTemplateHeader) then
          ErrorMessage := StrSubstNo(Error005,SMSTemplateHeader.TableCaption,NaviDocsEntry."Document Description",NaviDocsEntry."No.");
        if ErrorMessage = '' then
          if not TrySendSMSForNaviDocs(NaviDocsEntry,SMSTemplateHeader,RecRef) then
            ErrorMessage := StrSubstNo(Error006,GetLastErrorText);
        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    [TryFunction]
    local procedure TrySendSMSForNaviDocs(var NaviDocsEntry: Record "NaviDocs Entry";var SMSTemplateHeader: Record "SMS Template Header";RecRef: RecordRef)
    var
        SMSManagement: Codeunit "SMS Management";
    begin
        SMSManagement.SendSMS(NaviDocsEntry."E-mail (Recipient)",SMSTemplateHeader."Alt. Sender",MakeMessage(SMSTemplateHeader,RecRef));
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        exit('SMS');
    end;

    local procedure "---Report Links Azure Functions"()
    begin
    end;

    procedure AFReportLink(ReportId: Integer): Text
    var
        AFSetup: Record "AF Setup";
    begin
        //-NPR5.40 [304312]
        while not (AFSetup.Get and AFSetup."Msg Service - Site Created") do begin
          if not Confirm(AFSetupMissingTxt) then
            exit('');
          PAGE.RunModal(0,AFSetup);
        end;
        if ReportId = 0 then
          exit('');
        exit(AFReportLinkTag);
        //+NPR5.40 [304312]
    end;

    local procedure GetAFLink(RecRef: RecordRef;ReportID: Integer): Text
    var
        RegEx: DotNet npNetRegex;
        Match: DotNet npNetMatch;
        AFAPIMsgService: Codeunit "AF API - Msg Service";
    begin
        //-NPR5.40 [304312]
        exit(AFAPIMsgService.CreateSMSBody(RecRef.RecordId,ReportID,''));
        //+NPR5.40 [304312]
    end;

    local procedure AFReportLinkTag(): Text
    begin
        //-NPR5.40 [304312]
        exit('<<AFReportLink>>');
        //+NPR5.40 [304312]
    end;
}

