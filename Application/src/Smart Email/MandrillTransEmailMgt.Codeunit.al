codeunit 6059822 "NPR Mandrill Trans. Email Mgt"
{
    var
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        GeneratePreviewTxt: Label 'Generate Preview';
        InvalidNpXmlDataErr: Label '%1 %2 must return a list of %3, %4 sets.', Comment = '%1 = Xml Template Table Caption, %2 = Xml Template Code, %3 = name, %4 = content';

    procedure TestConnection()
    begin
        ExecuteWebServiceRequest('/users/ping2.json');
        Message(ConnectionSuccessMsg);
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "NPR Trx JSON Result" temporary)
    var
        JObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        i: Integer;
    begin
        i := 0;
        JToken.ReadFrom(ExecuteWebServiceRequest('/templates/list.json'));
        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            if JObject.Keys.Count() <> 0 then begin
                TransactionalJSONResult.Init();
                TransactionalJSONResult.Provider := TransactionalJSONResult.Provider::Mailchimp;
                TransactionalJSONResult."Entry No" := i;
                TransactionalJSONResult.ID := GetString(JObject, 'slug');
                TransactionalJSONResult.Name := GetString(JObject, 'name');
                TransactionalJSONResult.Created := GetDate(JObject, 'created_at');
                TransactionalJSONResult.Insert();
                i += 1;
            end;
        end;
    end;

    procedure GetSmartEmailDetails(var SmartEmail: Record "NPR Smart Email")
    var
        SmartEmailVariable: Record "NPR Smart Email Variable";
        TempVariable: Record "NPR Smart Email Variable" temporary;
        NpRegex: Codeunit "NPR RegEx";
        Body: JsonObject;
        JObject: JsonObject;
        NewLineNo: Integer;
        CodeString: Text;
    begin
        Body := InitializeBody();
        Body.Add('name', SmartEmail."Smart Email ID");

        JObject.ReadFrom(ExecuteWebServiceRequest('/templates/info.json', Body));

        SmartEmail."Smart Email Name" := CopyStr(GetString(JObject, 'name'), 1, MaxStrLen(SmartEmail."Smart Email Name"));
        SmartEmail.From := CopyStr(GetString(JObject, 'from_name'), 1, MaxStrLen(SmartEmail.From));
        SmartEmail."Reply To" := CopyStr(GetString(JObject, 'from_email'), 1, MaxStrLen(SmartEmail."Reply To"));
        SmartEmail.Subject := CopyStr(GetString(JObject, 'subject'), 1, MaxStrLen(SmartEmail.Subject));
        SmartEmail."Preview Url" := GeneratePreviewTxt;
        CodeString := GetString(JObject, 'publish_code');
        if CodeString = '' then
            CodeString := GetString(JObject, 'code');
        NpRegex.FindVariables(TempVariable, CodeString);

        SmartEmailVariable.SetRange("Transactional Email Code", SmartEmail.Code);
        if SmartEmailVariable.FindSet() then
            repeat
                TempVariable.SetRange("Variable Name", SmartEmailVariable."Variable Name");
                if TempVariable.FindSet() then
                    TempVariable.DeleteAll()
                else
                    SmartEmailVariable.Delete();
            until SmartEmailVariable.Next() = 0;
        NewLineNo := SmartEmailVariable."Line No." + 10000;
        TempVariable.Reset();
        if TempVariable.FindSet() then
            repeat
                SmartEmailVariable := TempVariable;
                SmartEmailVariable."Transactional Email Code" := SmartEmail.Code;
                SmartEmailVariable."Line No." := NewLineNo;
                NewLineNo += 10000;
                SmartEmailVariable."Merge Table ID" := SmartEmail."Merge Table ID";
                SmartEmailVariable.Insert();
            until TempVariable.Next() = 0;
        SmartEmail.Modify();
    end;

    procedure GetMessageDetails(EmailLog: Record "NPR Trx Email Log")
    var
        JObject: JsonObject;
    begin
        ClearLastError();
        if DownloadMessageDetails(EmailLog, JObject) then begin
            SaveMessageDetails(EmailLog, JObject);
            Commit();
        end;
    end;

    local procedure DownloadMessageDetails(EmailLog: Record "NPR Trx Email Log"; var JObject: JsonObject): Boolean
    var
        Body: JsonObject;
        MessageId: Text;
    begin
        Body := InitializeBody();
        MessageId := DelChr(EmailLog."Message ID", '<=>', '{-}');
        Body.Add('id', MessageId);
        exit(JObject.ReadFrom(ExecuteWebServiceRequest('/messages/info.json', Body)));
    end;

    local procedure SaveMessageDetails(EmailLog: Record "NPR Trx Email Log"; var JObject: JsonObject)
    begin
        if JObject.Keys.Count() = 0 then
            exit;
        EmailLog.Status := GetString(JObject, 'state');
        EmailLog.Recipient := CopyStr(GetString(JObject, 'email'), 1, MaxStrLen(EmailLog.Recipient));
        if Evaluate(EmailLog."Smart Email ID", GetString(JObject, 'template')) then;
        EmailLog."Total Opens" := GetInt(JObject, 'opens');
        EmailLog."Total Clicks" := GetInt(JObject, 'clicks');
        EmailLog.Subject := GetString(JObject, 'subject');
        EmailLog.Modify();
    end;

    procedure SendSmartEmail(SmartEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; Silent: Boolean) ErrorMessage: Text
    var
        TempAttachment: Record "NPR E-mail Attachment" temporary;
    begin
        exit(SendSmartEmailWAttachment(SmartEmail, Recipient, Cc, Bcc, RecRef, TempAttachment, Silent));
    end;

    procedure SendSmartEmailWAttachment(SmartEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean) ErrorMessage: Text
    var
        EmailLog: Record "NPR Trx Email Log";
        Body: JsonObject;
        JObject: JsonObject;
        MessageJObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        SmartEmail.TestField("Smart Email ID");
        Body := InitializeBody();

        Body.Add('template_name', SmartEmail."Smart Email ID");
        Body.Add('template_content', '');

        AddRecepient(JArray, Recipient, 'to');
        AddRecepient(JArray, Cc, 'cc');
        AddRecepient(JArray, Bcc, 'bcc');
        MessageJObject.Add('to', JArray);

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            MessageJObject.Add('merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));
        MessageJObject.Add('track_opens', true);
        MessageJObject.Add('track_clicks', true);
        MessageJObject.Add('global_merge_vars', GetVariablesAsArray(SmartEmail, RecRef));
        MessageJObject.Add('attachments', GetAttachmentsAsArray(Attachment));

        Body.Add('message', MessageJObject);

        JToken.ReadFrom(ExecuteWebServiceRequest('/messages/send-template.json', Body));

        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            if JObject.Keys.Count() <> 0 then begin
                EmailLog.Init();
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
        EmailLog: Record "NPR Trx Email Log";
        Body: JsonObject;
        JObject: JsonObject;
        MessageJObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        Body := InitializeBody();

        MessageJObject.Add('from_email', FromEmail);
        MessageJObject.Add('from_name', FromName);
        MessageJObject.Add('subject', Subject);

        AddRecepient(JArray, Recipient, 'to');
        AddRecepient(JArray, Cc, 'cc');
        AddRecepient(JArray, Bcc, 'bcc');
        MessageJObject.Add('to', JArray);

        if BodyHtml <> '' then
            MessageJObject.Add('html', BodyHtml);
        if BodyText <> '' then
            MessageJObject.Add('text', BodyText);
        if ReplyTo <> '' then begin
            JObject.Add('Reply-To', ReplyTo);
            MessageJObject.Add('headers', JObject);
        end;
        AddTags(MessageJObject, Tags);
        MessageJObject.Add('track_opens', TrackOpen);
        MessageJObject.Add('track_clicks', TrackClick);

        JArray := GetAttachmentsAsArray(Attachment);
        MessageJObject.Add('attachments', JArray);

        Body.Add('message', MessageJObject);

        JToken.ReadFrom(ExecuteWebServiceRequest('/messages/send.json', Body));
        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();
            if JObject.Keys.Count() <> 0 then begin
                EmailLog.Init();
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
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        Body: JsonObject;
        JObject: JsonObject;
        JArray: JsonArray;
        RecRef: RecordRef;
        OutStr: OutStream;
    begin
        Body := InitializeBody();
        Body.Add('template_name', SmartEmail."Smart Email ID");
        Body.Add('template_content', '');

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            Body.Add('merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));
        if SmartEmail."Merge Table ID" <> 0 then begin
            RecRef.Open(SmartEmail."Merge Table ID");
            RecRef.FindFirst();
        end;

        JArray := GetVariablesAsArray(SmartEmail, RecRef);
        Body.Add('merge_vars', JArray);

        JObject.ReadFrom(ExecuteWebServiceRequest('/templates/render.json', Body));

        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(GetString(JObject, 'html'));
        FileManagement.BLOBExport(TempBlob, SmartEmail."Smart Email Name" + '.html', true);
    end;

    local procedure InitializeContent(var Content: HttpContent)
    var
        Headers: HttpHeaders;
    begin
        Content.GetHeaders(Headers);

        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
    end;

    local procedure InitializeBody(): JsonObject
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        Body: JsonObject;
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::Mailchimp);
        TransactionalEmailSetup.TestField("API Key");
        Body.Add('key', TransactionalEmailSetup."API Key");
        exit(Body);
    end;

    local procedure ExecuteWebServiceRequest(Path: Text) ResponseText: Text
    begin
        ResponseText := ExecuteWebServiceRequest(Path, InitializeBody());
    end;

    local procedure ExecuteWebServiceRequest(Path: Text; Body: JsonObject) ResponseText: Text
    var
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        ContentText: Text;
    begin
        InitializeContent(Content);
        Body.WriteTo(ContentText);
        Content.WriteFrom(ContentText);

        if not Client.Post(GetFullURL(Path), Content, ResponseMessage) then
            Error(GetLastErrorText());
        ResponseMessage.Content().ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            Error(ResponseText);

        exit(ResponseText);
    end;

    local procedure GetFullURL(PartialURL: Text): Text
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::Mailchimp);
        TransactionalEmailSetup.TestField("API URL");
        exit(TransactionalEmailSetup."API URL" + PartialURL);
    end;

    local procedure GetVariablesAsArray(SmartEmail: Record "NPR Smart Email"; RecRef: RecordRef): JsonArray
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        SmartEmailVariable: Record "NPR Smart Email Variable";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        JObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        Element: XmlElement;
        XmlDoc: XmlDocument;
        ArrayName: Text;
        FirstChildNode: XmlNode;
        LastChildNode: XmlNode;
        NodeList: XmlNodeList;
        XmlDocNode: XmlNode;
    begin
        if (SmartEmail."NpXml Template Code" <> '') and NpXmlTemplate.Get(SmartEmail."NpXml Template Code") then begin
            RecRef.SetRecFilter();
            NpXmlMgt.Initialize(NpXmlTemplate, RecRef, NpXmlValueMgt.GetPrimaryKeyValue(RecRef), true);
            NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate."Xml Root Name", NpXmlTemplate."Custom Namespace for XMLNS");
            NpXmlDomMgt.AddRootAttributes(XmlDocNode, NpXmlTemplate);
            NpXmlMgt.ParseDataToXmlDocNode(RecRef, true, XmlDocNode);
            JObject.ReadFrom(NpXmlMgt.Xml2Json(XmlDoc, NpXmlTemplate));

            XmlDoc.GetRoot(Element);
            //get first child
            NodeList := Element.GetChildElements();
            NodeList.Get(1, FirstChildNode);
            ArrayName := FirstChildNode.AsXmlElement().Name;
            //get last child
            NodeList.Get(NodeList.Count(), LastChildNode);
            if ArrayName <> LastChildNode.AsXmlElement().Name then
                Error(InvalidNpXmlDataErr, NpXmlTemplate.TableCaption(), NpXmlTemplate.Code, 'name', 'content');
            JObject.SelectToken(ArrayName, JToken);
            if JToken.IsArray then
                JArray := JToken.AsArray()
            else
                JArray.Add(JToken);
        end else begin
            SmartEmailVariable.SetRange("Transactional Email Code", SmartEmail.Code);
            JArray := WriteVariables(SmartEmailVariable, RecRef);
        end;
        exit(JArray);
    end;

    local procedure WriteVariables(var SmartEmailVariable: Record "NPR Smart Email Variable"; RecRef: RecordRef): JsonArray
    var
        JObject: JsonObject;
        JArray: JsonArray;
        FldRef: FieldRef;
    begin
        if SmartEmailVariable.FindSet() then
            repeat
                Clear(JObject);
                if SmartEmailVariable."Const Value" <> '' then begin
                    JObject.Add('name', SmartEmailVariable."Variable Name");
                    JObject.Add('content', SmartEmailVariable."Const Value");
                end else begin
                    JObject.Add('name', SmartEmailVariable."Variable Name");
                    if (RecRef.Number <> 0) and (SmartEmailVariable."Field No." <> 0) then begin
                        FldRef := RecRef.field(SmartEmailVariable."Field No.");
                        if Format(FldRef.Class) = 'FlowField' then
                            FldRef.CalcField();
                        JObject.Add('content', Format(FldRef.Value));
                    end else
                        JObject.Add('content', '');
                end;
                JArray.Add(JObject.Clone());
            until SmartEmailVariable.Next() = 0;
        exit(JArray);
    end;

    local procedure AddRecepient(var JArray: JsonArray; Recipients: Text; Type: Text)
    var
        JObject: JsonObject;
        Pos: Integer;
        email: Text;
    begin
        if Recipients = '' then
            exit;
        Pos := StrPos(Recipients, ';');
        if Pos > 0 then
            repeat
                Clear(JObject);
                email := CopyStr(Recipients, 1, Pos - 1);
                if email <> '' then begin
                    JObject.Add('email', email);
                    JObject.Add('type', Type);
                    JArray.Add(JObject.Clone());
                end;
                Recipients := CopyStr(Recipients, Pos + 1);
                Pos := StrPos(Recipients, ';');
            until Pos = 0;
        if Recipients <> '' then begin
            Clear(JObject);
            JObject.Add('email', Recipients);
            JObject.Add('type', Type);
            JArray.Add(JObject.Clone());
        end;
    end;

    local procedure AddTags(var MessageJObject: JsonObject; TagString: Text)
    var
        JArray: JsonArray;
        Pos: Integer;
        Tag: Text;
    begin
        if TagString = '' then
            exit;
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
        MessageJObject.Add('tags', JArray);
    end;

    local procedure GetAttachmentsAsArray(var Attachment: Record "NPR E-mail Attachment"): JsonArray;
    var
        Convert: Codeunit "Base64 Convert";
        JObject: JsonObject;
        JArray: JsonArray;
        IStream: InStream;
    begin
        if Attachment.IsEmpty() then
            exit;
        if Attachment.FindSet() then
            repeat
                if Attachment."Attached File".HasValue() then begin
                    Attachment.CalcFields("Attached File");
                    Attachment."Attached File".CreateInStream(IStream);
                    JObject.Add('content', Convert.ToBase64(IStream));
                    JObject.Add('name', Attachment.Description);
                    JObject.Add('type', GetAttachmentType(Attachment.Description));
                    JArray.Add(JObject.Clone());
                end;
            until Attachment.Next() = 0;
        exit(JArray);
    end;

    local procedure GetString(JObject: JsonObject; Property: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Property, JToken) then
            if JToken.IsValue then
                if not JToken.AsValue().IsNull then
                    exit(JToken.AsValue().AsText());

    end;

    local procedure GetInt(JObject: JsonObject; Property: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObject.SelectToken(Property, JToken) then
            if JToken.IsValue then
                if not JToken.AsValue().IsNull then
                    exit(JToken.AsValue().AsInteger());
    end;

    local procedure GetDate(JObject: JsonObject; Property: Text): Date
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DT2Date(DTVar));
    end;

    local procedure GetAttachmentType(FileName: Text) mimeType: Text
    var
        fileMgt: Codeunit "File Management";
        FileFormatErr: Label 'File format isn''t supported.';
    begin
        case LowerCase(fileMgt.GetExtension(FileName)) of
            'pdf':
                mimeType := 'data:application/pdf';
            'txt':
                mimeType := 'data:text/plain';
            'png':
                mimeType := 'data:image/png';
            'bmp':
                mimeType := 'data:image/bmp';
            'jpeg', 'jpg', 'jpe':
                mimeType := 'data:image/jpeg';
            'gif':
                mimeType := 'data:image/gif';
            'doc':
                mimeType := 'data:application/msword';
            'json':
                mimeType := 'data:application/octet-stream';
            'docx':
                mimeType := 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            'xls':
                mimeType := 'data:application/vnd.ms-excel';
            'xml':
                mimeType := 'data:application/xml';
            'htm', 'html':
                mimeType := 'data:text/html';
            'xlsx':
                mimeType := 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            else
                Error(FileFormatErr);
        end;
        exit(mimeType);
    end;

}