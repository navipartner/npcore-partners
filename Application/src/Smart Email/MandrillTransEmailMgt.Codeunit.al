codeunit 6059822 "NPR Mandrill Trans. Email Mgt"
{
    trigger OnRun()
    begin
    end;

    var
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        ResponseTempBlob: Codeunit "Temp Blob";
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseInStream: InStream;
        BodyJObject: DotNet NPRNetJObject;
        GeneratePreviewTxt: Label 'Generate Preview';
        InvalidNpXmlDataErr: Label '%1 %2 must return a list of %3, %4 sets.';

    procedure TestConnection()
    begin
        Initialize(GetFullURL('/users/ping2.json'), 'POST');

        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);

        Message(ConnectionSuccessMsg);
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "NPR Trx JSON Result" temporary)
    var
        JObject: DotNet NPRNetJObject;
        JArray: DotNet NPRNetJArray;
        I: Integer;
    begin
        Initialize(GetFullURL('/templates/list.json'), 'POST');
        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);

        JArray := JArray.Parse(GetWebResonseText);
        for I := 0 to JArray.Count - 1 do begin
            JObject := JArray.Item(I);
            if not IsNull(JObject) then begin
                TransactionalJSONResult.Init;
                TransactionalJSONResult.Provider := TransactionalJSONResult.Provider::Mailchimp;
                TransactionalJSONResult."Entry No" := I;
                TransactionalJSONResult.ID := GetString(JObject, 'slug');
                TransactionalJSONResult.Name := GetString(JObject, 'name');
                TransactionalJSONResult.Created := GetDate(JObject, 'created_at');
                TransactionalJSONResult.Insert;
            end;
        end;
    end;

    procedure GetSmartEmailDetails(var SmartEmail: Record "NPR Smart Email")
    var
        SmartEmailVariable: Record "NPR Smart Email Variable";
        TempVariable: Record "NPR Smart Email Variable" temporary;
        JObject: DotNet NPRNetJObject;
        CodeString: Text;
        I: Integer;
    begin
        Initialize(GetFullURL('/templates/info.json'), 'POST');
        AddPropertyToJObject(BodyJObject, 'name', SmartEmail."Smart Email ID");

        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);

        JObject := JObject.Parse(GetWebResonseText);

        SmartEmail."Smart Email Name" := CopyStr(GetString(JObject, 'name'), 1, MaxStrLen(SmartEmail."Smart Email Name"));
        SmartEmail.From := CopyStr(GetString(JObject, 'from_name'), 1, MaxStrLen(SmartEmail.From));
        SmartEmail."Reply To" := CopyStr(GetString(JObject, 'from_email'), 1, MaxStrLen(SmartEmail."Reply To"));
        SmartEmail.Subject := CopyStr(GetString(JObject, 'subject'), 1, MaxStrLen(SmartEmail.Subject));
        SmartEmail."Preview Url" := GeneratePreviewTxt;
        CodeString := GetString(JObject, 'publish_code');
        if CodeString = '' then
            CodeString := GetString(JObject, 'code');
        FindVariables(TempVariable, CodeString);

        SmartEmailVariable.SetRange("Transactional Email Code", SmartEmail.Code);
        if SmartEmailVariable.FindSet then
            repeat
                TempVariable.SetRange("Variable Name", SmartEmailVariable."Variable Name");
                if TempVariable.FindSet then
                    TempVariable.DeleteAll
                else
                    SmartEmailVariable.Delete;
            until SmartEmailVariable.Next = 0;
        I := SmartEmailVariable."Line No." + 10000;
        TempVariable.Reset;
        if TempVariable.FindSet then
            repeat
                SmartEmailVariable := TempVariable;
                SmartEmailVariable."Transactional Email Code" := SmartEmail.Code;
                SmartEmailVariable."Line No." := I;
                I += 10000;
                SmartEmailVariable."Merge Table ID" := SmartEmail."Merge Table ID";
                SmartEmailVariable.Insert;
            until TempVariable.Next = 0;
        SmartEmail.Modify;
    end;

    procedure GetMessageDetails(EmailLog: Record "NPR Trx Email Log")
    var
        JObject: DotNet NPRNetJObject;
    begin
        ClearLastError;
        if TryGetMessageDetails(EmailLog, JObject) then begin
            SaveMessageDetails(EmailLog, JObject);
            Commit();
        end;
    end;

    [TryFunction]
    local procedure TryGetMessageDetails(EmailLog: Record "NPR Trx Email Log"; var JObject: DotNet NPRNetJObject)
    var
        MessageId: Text;
    begin
        Initialize(GetFullURL('/messages/info.json'), 'POST');
        MessageId := DelChr(EmailLog."Message ID", '<=>', '{-}');
        AddPropertyToJObject(BodyJObject, 'id', MessageId);
        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);

        JObject := JObject.Parse(GetWebResonseText);
    end;

    local procedure SaveMessageDetails(EmailLog: Record "NPR Trx Email Log"; var JObject: DotNet NPRNetJObject)
    begin
        if IsNull(JObject) then
            exit;
        EmailLog.Status := GetString(JObject, 'state');
        EmailLog.Recipient := CopyStr(GetString(JObject, 'email'), 1, MaxStrLen(EmailLog.Recipient));
        if Evaluate(EmailLog."Smart Email ID", GetString(JObject, 'template')) then;
        EmailLog."Total Opens" := GetInt(JObject, 'opens');
        EmailLog."Total Clicks" := GetInt(JObject, 'clicks');
        EmailLog.Subject := GetString(JObject, 'subject');
        EmailLog.Modify;
    end;

    procedure SendSmartEmail(SmartEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; Silent: Boolean) ErrorMessage: Text
    var
        Attachment: Record "NPR E-mail Attachment" temporary;
    begin
        exit(SendSmartEmailWAttachment(SmartEmail, Recipient, Cc, Bcc, RecRef, Attachment, Silent));
    end;

    procedure SendSmartEmailWAttachment(SmartEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean) ErrorMessage: Text
    var
        MessageJObject: DotNet NPRNetJObject;
        JObject: DotNet NPRNetJObject;
        JArray: DotNet NPRNetJArray;
        EmailLog: Record "NPR Trx Email Log";
        I: Integer;
    begin
        SmartEmail.TestField("Smart Email ID");
        Initialize(GetFullURL('/messages/send-template.json'), 'POST');
        AddPropertyToJObject(BodyJObject, 'template_name', SmartEmail."Smart Email ID");
        AddPropertyToJObject(BodyJObject, 'template_content', '');

        MessageJObject := MessageJObject.JObject();
        JArray := JArray.JArray();
        AddRecepient(JArray, Recipient, 'to');
        AddRecepient(JArray, Cc, 'cc');
        AddRecepient(JArray, Bcc, 'bcc');
        AddPropertyToJObject(MessageJObject, 'to', JArray);

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            AddPropertyToJObject(MessageJObject, 'merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));
        AddPropertyToJObject(MessageJObject, 'track_opens', true);
        AddPropertyToJObject(MessageJObject, 'track_clicks', true);

        AddVariablesToJArray(JArray, SmartEmail, RecRef);
        AddPropertyToJObject(MessageJObject, 'global_merge_vars', JArray);

        AddAttachmentsToJArray(JArray, Attachment);
        AddPropertyToJObject(MessageJObject, 'attachments', JArray);

        AddPropertyToJObject(BodyJObject, 'message', MessageJObject);

        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);
        JArray := JArray.Parse(GetWebResonseText);
        for I := 0 to JArray.Count - 1 do begin
            JObject := JArray.Item(I);
            if not IsNull(JObject) then begin
                EmailLog.Init;
                EmailLog."Entry No." := 0;
                EmailLog.Provider := EmailLog.Provider::Mailchimp;
                EmailLog."Message ID" := GetString(JObject, '_id');
                EmailLog.Status := GetString(JObject, 'status');
                EmailLog."Status Message" := CopyStr(GetString(JObject, 'reject_reason'), 1, MaxStrLen(EmailLog."Status Message"));
                EmailLog.Recipient := CopyStr(GetString(JObject, 'email'), 1, MaxStrLen(EmailLog.Recipient));
                EmailLog.Insert(true);
            end;
        end;
        exit('');
    end;

    procedure SendClassicMail(Recipient: Text; Cc: Text; Bcc: Text; Subject: Text; BodyHtml: Text; BodyText: Text; FromEmail: Text; FromName: Text; ReplyTo: Text; TrackOpen: Boolean; TrackClick: Boolean; Tags: Text; AddRecipientsToListID: Text; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean): Text
    var
        MessageJObject: DotNet NPRNetJObject;
        JObject: DotNet NPRNetJObject;
        JArray: DotNet NPRNetJArray;
        EmailLog: Record "NPR Trx Email Log";
        I: Integer;
    begin
        Initialize(GetFullURL('/messages/send.json'), 'POST');
        MessageJObject := MessageJObject.JObject();
        AddPropertyToJObject(MessageJObject, 'from_email', FromEmail);
        AddPropertyToJObject(MessageJObject, 'from_name', FromName);
        AddPropertyToJObject(MessageJObject, 'subject', Subject);

        JArray := JArray.JArray();
        AddRecepient(JArray, Recipient, 'to');
        AddRecepient(JArray, Cc, 'cc');
        AddRecepient(JArray, Bcc, 'bcc');
        AddPropertyToJObject(MessageJObject, 'to', JArray);

        if BodyHtml <> '' then
            AddPropertyToJObject(MessageJObject, 'html', BodyHtml);
        if BodyText <> '' then
            AddPropertyToJObject(MessageJObject, 'text', BodyText);
        if ReplyTo <> '' then begin
            JObject := JObject.JObject();
            AddPropertyToJObject(JObject, 'Reply-To', ReplyTo);
            AddPropertyToJObject(MessageJObject, 'headers', JObject);
        end;
        AddTags(MessageJObject, Tags);
        AddPropertyToJObject(MessageJObject, 'track_opens', TrackOpen);
        AddPropertyToJObject(MessageJObject, 'track_clicks', TrackClick);

        AddAttachmentsToJArray(JArray, Attachment);
        AddPropertyToJObject(MessageJObject, 'attachments', JArray);

        AddPropertyToJObject(BodyJObject, 'message', MessageJObject);
        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);
        JArray := JArray.Parse(GetWebResonseText);
        for I := 0 to JArray.Count - 1 do begin
            JObject := JArray.Item(I);
            if not IsNull(JObject) then begin
                EmailLog.Init;
                EmailLog."Entry No." := 0;
                EmailLog.Provider := EmailLog.Provider::Mailchimp;
                EmailLog."Message ID" := GetString(JObject, '_id');
                EmailLog.Status := GetString(JObject, 'status');
                EmailLog."Status Message" := CopyStr(GetString(JObject, 'reject_reason'), 1, MaxStrLen(EmailLog."Status Message"));
                EmailLog.Recipient := CopyStr(GetString(JObject, 'email'), 1, MaxStrLen(EmailLog.Recipient));
                EmailLog.Insert(true);
            end;
        end;
        exit('');
    end;

    procedure PreviewSmartEmail(SmartEmail: Record "NPR Smart Email")
    var
        JObject: DotNet NPRNetJObject;
        JArray: DotNet NPRNetJArray;
        FileManagement: Codeunit "File Management";
        RecRef: RecordRef;
        OutputFile: File;
        OStream: OutStream;
        ServerFilename: Text;
        ClientFilename: Text;
    begin
        Initialize(GetFullURL('/templates/render.json'), 'POST');
        AddPropertyToJObject(BodyJObject, 'template_name', SmartEmail."Smart Email ID");
        AddPropertyToJObject(BodyJObject, 'template_content', '');

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            AddPropertyToJObject(BodyJObject, 'merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));

        if SmartEmail."Merge Table ID" <> 0 then begin
            RecRef.Open(SmartEmail."Merge Table ID");
            RecRef.FindFirst;
        end;

        AddVariablesToJArray(JArray, SmartEmail, RecRef);
        AddPropertyToJObject(BodyJObject, 'merge_vars', JArray);

        if not ExecuteWebServiceRequest then
            Error(GetLastErrorText);

        JObject := JObject.Parse(GetWebResonseText);
        ServerFilename := FileManagement.ServerTempFileName('html');
        OutputFile.Create(ServerFilename);
        OutputFile.CreateOutStream(OStream);
        OStream.Write(GetString(JObject, 'html'));
        OutputFile.Close();
        ClientFilename := SmartEmail."Smart Email Name" + '.html';
        Download(ServerFilename, '', '', '', ClientFilename);
    end;

    local procedure Initialize(URL: Text; Method: Text[6])
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        Jtoken: Integer;
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::Mailchimp);
        TransactionalEmailSetup.TestField("API Key");

        Clear(HttpWebRequestMgt);
        HttpWebRequestMgt.Initialize(URL);
        HttpWebRequestMgt.SetMethod(Method);
        //HttpWebRequestMgt.AddHeader('Authorization','Basic ' + GetBasicAuthInfo(TransactionalEmailSetup."Client ID", TransactionalEmailSetup."API Key"));
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');
        BodyJObject := BodyJObject.JObject();
        AddPropertyToJObject(BodyJObject, 'key', TransactionalEmailSetup."API Key");
    end;

    [TryFunction]
    local procedure ExecuteWebServiceRequest()
    var
        HttpStatusCode: DotNet NPRNetHttpStatusCode;
        ResponseHeaders: DotNet NPRNetNameValueCollection;
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
    begin
        if not IsNull(BodyJObject) then begin
            TempBlob.CreateOutStream(OStream);
            OStream.WriteText(BodyJObject.ToString());
            HttpWebRequestMgt.AddBodyBlob(TempBlob);
        end;

        Clear(ResponseTempBlob);
        ResponseTempBlob.CreateInStream(ResponseInStream);

        if not GuiAllowed then
            HttpWebRequestMgt.DisableUI;

        if not HttpWebRequestMgt.GetResponse(ResponseInStream, HttpStatusCode, ResponseHeaders) then
            HttpWebRequestMgt.ProcessFaultXMLResponse('', '', '', '');
    end;

    local procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        exit(Convert.ToBase64String(Encoding.UTF8.GetBytes(Username + ':' + Password)));
    end;

    local procedure GetFullURL(PartialURL: Text): Text
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::Mailchimp);
        TransactionalEmailSetup.TestField("API URL");
        exit(TransactionalEmailSetup."API URL" + PartialURL);
    end;

    local procedure GetWebResonseText() ResponseText: Text
    var
        PartText: Text;
    begin
        ResponseText := '';
        while not ResponseInStream.EOS do begin
            ResponseInStream.ReadText(PartText);
            ResponseText += PartText;
        end;
    end;

    local procedure AddVariablesToJArray(var JArray: DotNet NPRNetJArray; SmartEmail: Record "NPR Smart Email"; RecRef: RecordRef)
    var
        JObject: DotNet NPRNetJObject;
        JTokenType: DotNet NPRNetJTokenType;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlDocNode: DotNet NPRNetXmlNode;
        NpXmlTemplate: Record "NPR NpXml Template";
        SmartEmailVariable: Record "NPR Smart Email Variable";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        ArrayName: Text;
    begin
        if (SmartEmail."NpXml Template Code" <> '') and NpXmlTemplate.Get(SmartEmail."NpXml Template Code") then begin
            RecRef.SetRecFilter;
            NpXmlMgt.Initialize(NpXmlTemplate, RecRef, NpXmlValueMgt.GetPrimaryKeyValue(RecRef), true);
            NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate."Xml Root Name");
            NpXmlMgt.ParseDataToXmlDocNode(RecRef, true, XmlDocNode);
            JObject := JObject.Parse(NpXmlMgt.Xml2Json(XmlDoc, NpXmlTemplate));
            ArrayName := XmlDoc.DocumentElement.FirstChild.Name;
            if ArrayName <> XmlDoc.DocumentElement.LastChild.Name then
                Error(InvalidNpXmlDataErr, NpXmlTemplate.TableCaption, NpXmlTemplate.Code, 'name', 'content');
            if JObject.Item(ArrayName).Type.Equals(JTokenType.Array) then
                JArray := JObject.Item(ArrayName)
            else begin
                JArray := JArray.JArray();
                JArray.Add(JObject.Item(ArrayName));
            end;
        end else begin
            SmartEmailVariable.SetRange("Transactional Email Code", SmartEmail.Code);
            JArray := JArray.JArray();
            WriteVariables(JArray, SmartEmailVariable, RecRef);
        end;
    end;

    local procedure WriteVariables(var JArray: DotNet NPRNetJArray; var SmartEmailVariable: Record "NPR Smart Email Variable"; RecRef: RecordRef)
    var
        JObject: DotNet NPRNetJObject;
        FldRef: FieldRef;
    begin
        if SmartEmailVariable.FindSet then
            repeat
                JObject := JObject.JObject();
                if SmartEmailVariable."Const Value" <> '' then begin
                    AddPropertyToJObject(JObject, 'name', SmartEmailVariable."Variable Name");
                    AddPropertyToJObject(JObject, 'content', SmartEmailVariable."Const Value");
                end else begin
                    AddPropertyToJObject(JObject, 'name', SmartEmailVariable."Variable Name");
                    if (RecRef.Number <> 0) and (SmartEmailVariable."Field No." <> 0) then begin
                        FldRef := RecRef.Field(SmartEmailVariable."Field No.");
                        if Format(FldRef.Class) = 'FlowField' then
                            FldRef.CalcField;
                        AddPropertyToJObject(JObject, 'content', Format(FldRef.Value));
                    end else
                        AddPropertyToJObject(JObject, 'content', '');
                end;
                JArray.Add(JObject.DeepClone);
            until SmartEmailVariable.Next = 0;
    end;

    local procedure AddRecepient(var JArray: DotNet NPRNetJArray; Recipients: Text; Type: Text)
    var
        JObject: DotNet NPRNetJObject;
        email: Text;
        Pos: Integer;
    begin
        if Recipients = '' then
            exit;
        Pos := StrPos(Recipients, ';');
        if Pos > 0 then
            repeat
                email := CopyStr(Recipients, 1, Pos - 1);
                if email <> '' then begin
                    JObject := JObject.JObject();
                    AddPropertyToJObject(JObject, 'email', email);
                    AddPropertyToJObject(JObject, 'type', Type);
                    JArray.Add(JObject.DeepClone);
                end;
                Recipients := CopyStr(Recipients, Pos + 1);
                Pos := StrPos(Recipients, ';');
            until Pos = 0;
        if Recipients <> '' then begin
            JObject := JObject.JObject();
            AddPropertyToJObject(JObject, 'email', Recipients);
            AddPropertyToJObject(JObject, 'type', Type);
            JArray.Add(JObject.DeepClone);
        end;
    end;

    local procedure AddTags(var MessageJObject: DotNet NPRNetJObject; TagString: Text)
    var
        JArray: DotNet NPRNetJArray;
        Tag: Text;
        Pos: Integer;
    begin
        if TagString = '' then
            exit;
        JArray := JArray.JArray();
        Pos := StrPos(TagString, ';');
        if Pos > 0 then
            repeat
                Tag := CopyStr(TagString, 1, Pos - 1);
                if Tag <> '' then
                    JArray.Add(Tag);
                TagString := CopyStr(TagString, Pos + 1);
                Pos := StrPos(TagString, ';');
            until Pos = 0;
        if TagString <> '' then
            JArray.Add(TagString);
        AddPropertyToJObject(MessageJObject, 'tags', JArray);
    end;

    local procedure AddAttachmentsToJArray(var JArray: DotNet NPRNetJArray; var Attachment: Record "NPR E-mail Attachment")
    var
        JObject: DotNet NPRNetJObject;
        MemoryStream: DotNet NPRNetMemoryStream;
        Bytes: DotNet NPRNetArray;
        Convert: DotNet NPRNetConvert;
        IStream: InStream;
    begin
        JArray := JArray.JArray();
        if Attachment.IsEmpty then
            exit;
        if Attachment.FindSet then
            repeat
                if Attachment."Attached File".HasValue then begin
                    Attachment.CalcFields("Attached File");
                    Attachment."Attached File".CreateInStream(IStream);
                    MemoryStream := MemoryStream.MemoryStream();
                    CopyStream(MemoryStream, IStream);
                    Bytes := MemoryStream.GetBuffer();
                    JObject := JObject.JObject();
                    AddPropertyToJObject(JObject, 'content', Convert.ToBase64String(Bytes));
                    AddPropertyToJObject(JObject, 'name', Attachment.Description);
                    AddPropertyToJObject(JObject, 'type', GetAttachmentType(Attachment.Description));
                    JArray.Add(JObject.DeepClone);
                end;
            until Attachment.Next = 0;
    end;

    local procedure AddPropertyToJObject(var JObject: DotNet NPRNetJObject; PropertyName: Text; Value: Variant)
    var
        JObject2: DotNet NPRNetJObject;
        JProperty: DotNet NPRNetJProperty;
        ValueText: Text;
    begin
        case true of
            Value.IsDotNet:
                begin
                    JObject2 := Value;
                    JObject.Add(PropertyName, JObject2);
                end;
            Value.IsInteger,
            Value.IsDecimal,
            Value.IsBoolean:
                begin
                    JProperty := JProperty.JProperty(PropertyName, Value);
                    JObject.Add(JProperty);
                end;
            else begin
                    ValueText := Format(Value, 0, 9);
                    JProperty := JProperty.JProperty(PropertyName, ValueText);
                    JObject.Add(JProperty);
                end;
        end;
    end;

    local procedure FindVariables(var TempVariable: Record "NPR Smart Email Variable" temporary; CodeString: Text)
    var
        RegEx: DotNet NPRNetRegex;
        MatchCollection: DotNet NPRNetMatchCollection;
        I: Integer;
        OffSet: Integer;
    begin
        if CodeString = '' then
            exit;
        MatchCollection := RegEx.Matches(CodeString, '(\*\|)(.*?)(\|\*)');
        for I := 0 to MatchCollection.Count - 1 do begin
            TempVariable.Init;
            TempVariable."Line No." := I;
            TempVariable."Variable Name" := MatchCollection.Item(I).Value;
            TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
            TempVariable."Variable Type" := TempVariable."Variable Type"::Mailchimp;
            TempVariable.Insert;
        end;
        OffSet := I + 1;
        MatchCollection := RegEx.Matches(CodeString, '({{)(.*?)(}})');
        for I := 0 to MatchCollection.Count - 1 do begin
            TempVariable.Init;
            TempVariable."Line No." := I + OffSet;
            TempVariable."Variable Name" := MatchCollection.Item(I).Value;
            TempVariable."Variable Name" := CopyStr(TempVariable."Variable Name", 3, StrLen(TempVariable."Variable Name") - 4);
            TempVariable."Variable Type" := TempVariable."Variable Type"::Handlebars;
            TempVariable.Insert;
        end;
    end;

    local procedure GetString(JObject: DotNet NPRNetJObject; Property: Text): Text
    var
        JToken: DotNet NPRNetJToken;
    begin
        if GetJToken(JObject, Property, JToken) then
            exit(JToken.ToString());
    end;

    local procedure GetInt(JObject: DotNet NPRNetJObject; Property: Text): Integer
    var
        Number: Integer;
    begin
        if Evaluate(Number, GetString(JObject, Property)) then
            exit(Number);
    end;

    local procedure GetDateTime(JObject: DotNet NPRNetJObject; Property: Text): DateTime
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DTVar);
    end;

    local procedure GetDate(JObject: DotNet NPRNetJObject; Property: Text): Date
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DT2Date(DTVar));
    end;

    local procedure GetJToken(JObject: DotNet NPRNetJObject; Property: Text; var JToken: DotNet NPRNetJToken): Boolean
    begin
        JToken := JObject.Item(Property);
        exit(not IsNull(JToken));
    end;

    local procedure GetAttachmentType(FileName: Text): Text
    var
        MimeMapping: DotNet NPRNetMimeMapping;
    begin
        exit(MimeMapping.GetMimeMapping(FileName));
    end;
}