codeunit 6059822 "NPR Mandrill Trans. Email Mgt"
{
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseTempBlob: Codeunit "Temp Blob";
        BodyJObject: JsonObject;
        ResponseInStream: InStream;
        InvalidNpXmlDataErr: Label '%1 %2 must return a list of %3, %4 sets.', Comment = '%1 = Xml Template Table Caption, %2 = Xml Template Code, %3 = name, %4 = content';
        GeneratePreviewTxt: Label 'Generate Preview';
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';

    procedure TestConnection()
    begin
        Initialize(GetFullURL('/users/ping2.json'), 'POST');

        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        Message(ConnectionSuccessMsg);
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "NPR Trx JSON Result" temporary)
    var
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        i: Integer;
    begin
        Initialize(GetFullURL('/templates/list.json'), 'POST');
        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        i := 0;
        JToken.ReadFrom(GetWebResonseText());
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
        JObject: JsonObject;
        I: Integer;
        CodeString: Text;
        NpRegex: Codeunit "NPR RegEx";
    begin
        Initialize(GetFullURL('/templates/info.json'), 'POST');
        BodyJObject.Add('name', SmartEmail."Smart Email ID");

        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        JObject.ReadFrom(GetWebResonseText());

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
        I := SmartEmailVariable."Line No." + 10000;
        TempVariable.Reset();
        if TempVariable.FindSet() then
            repeat
                SmartEmailVariable := TempVariable;
                SmartEmailVariable."Transactional Email Code" := SmartEmail.Code;
                SmartEmailVariable."Line No." := I;
                I += 10000;
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
        if TryGetMessageDetails(EmailLog, JObject) then begin
            SaveMessageDetails(EmailLog, JObject);
            Commit();
        end;
    end;

    [TryFunction]
    local procedure TryGetMessageDetails(EmailLog: Record "NPR Trx Email Log"; var JObject: JsonObject)
    var
        MessageId: Text;
    begin
        Initialize(GetFullURL('/messages/info.json'), 'POST');
        MessageId := DelChr(EmailLog."Message ID", '<=>', '{-}');
        BodyJObject.Add('id', MessageId);
        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        JObject.ReadFrom(GetWebResonseText());
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
        Attachment: Record "NPR E-mail Attachment" temporary;
    begin
        exit(SendSmartEmailWAttachment(SmartEmail, Recipient, Cc, Bcc, RecRef, Attachment, Silent));
    end;

    procedure SendSmartEmailWAttachment(SmartEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean) ErrorMessage: Text
    var
        EmailLog: Record "NPR Trx Email Log";
        JArray: JsonArray;
        JObject: JsonObject;
        MessageJObject: JsonObject;
        JToken: JsonToken;
    begin
        SmartEmail.TestField("Smart Email ID");
        Initialize(GetFullURL('/messages/send-template.json'), 'POST');
        BodyJObject.Add('template_name', SmartEmail."Smart Email ID");
        BodyJObject.Add('template_content', '');

        AddRecepient(JArray, Recipient, 'to');
        AddRecepient(JArray, Cc, 'cc');
        AddRecepient(JArray, Bcc, 'bcc');
        MessageJObject.Add('to', JArray);

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            MessageJObject.Add('merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));
        MessageJObject.Add('track_opens', true);
        MessageJObject.Add('track_clicks', true);

        AddVariablesToJArray(JArray, SmartEmail, RecRef);
        MessageJObject.Add('global_merge_vars', JArray);

        AddAttachmentsToJArray(JArray, Attachment);
        MessageJObject.Add('attachments', JArray);

        BodyJObject.Add('message', MessageJObject);

        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        JToken.ReadFrom(GetWebResonseText());
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
        JArray: JsonArray;
        JObject: JsonObject;
        MessageJObject: JsonObject;
        JToken: JsonToken;
    begin
        Initialize(GetFullURL('/messages/send.json'), 'POST');
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

        AddAttachmentsToJArray(JArray, Attachment);
        MessageJObject.Add('attachments', JArray);

        BodyJObject.Add('message', MessageJObject);
        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        JToken.ReadFrom(GetWebResonseText());
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
        RecRef: RecordRef;
        JArray: JsonArray;
        JObject: JsonObject;
        OutStr: OutStream;
        Filename: Text;
    begin
        Initialize(GetFullURL('/templates/render.json'), 'POST');
        BodyJObject.Add('template_name', SmartEmail."Smart Email ID");
        BodyJObject.Add('template_content', '');

        if SmartEmail."Merge Language (Mailchimp)" <> 0 then
            BodyJObject.Add('merge_language', Format(SmartEmail."Merge Language (Mailchimp)"));

        if SmartEmail."Merge Table ID" <> 0 then begin
            RecRef.Open(SmartEmail."Merge Table ID");
            RecRef.FindFirst();
        end;

        AddVariablesToJArray(JArray, SmartEmail, RecRef);
        BodyJObject.Add('merge_vars', JArray);

        if not ExecuteWebServiceRequest() then
            Error(GetLastErrorText);

        JObject.ReadFrom(GetWebResonseText());
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(GetString(JObject, 'html'));
        FileManagement.BLOBExport(TempBlob, SmartEmail."Smart Email Name" + '.html', true);
    end;

    local procedure Initialize(URL: Text; Method: Text[6])
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::Mailchimp);
        TransactionalEmailSetup.TestField("API Key");

        Clear(HttpWebRequestMgt);
        HttpWebRequestMgt.Initialize(URL);
        HttpWebRequestMgt.SetMethod(Method);
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');
        BodyJObject.Add('key', TransactionalEmailSetup."API Key");
    end;

    [TryFunction]
    local procedure ExecuteWebServiceRequest()
    var
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
    begin
        If BodyJObject.Keys.Count() <> 0 then begin
            TempBlob.CreateOutStream(OStream);
            BodyJObject.WriteTo(OStream);
            HttpWebRequestMgt.AddBodyBlob(TempBlob);
        end;

        Clear(ResponseTempBlob);
        ResponseTempBlob.CreateInStream(ResponseInStream);

        if not GuiAllowed then
            HttpWebRequestMgt.DisableUI();

        if not HttpWebRequestMgt.GetResponseStream(ResponseInStream) then
            HttpWebRequestMgt.ProcessFaultXMLResponse('', '', '', '');
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

    local procedure AddVariablesToJArray(var JArray: JsonArray; SmartEmail: Record "NPR Smart Email"; RecRef: RecordRef)
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        SmartEmailVariable: Record "NPR Smart Email Variable";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        JObject: JsonObject;
        JToken: JsonToken;
        XmlDoc: XmlDocument;
        Element: XmlElement;
        XmlDocNode: XmlNode;
        FirstChildNode: XmlNode;
        LastChildNode: XmlNode;
        NodeList: XmlNodeList;
        ArrayName: Text;
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
            NodeList.Get(NodeList.Count, LastChildNode);
            if ArrayName <> LastChildNode.AsXmlElement().Name then
                Error(InvalidNpXmlDataErr, NpXmlTemplate.TableCaption, NpXmlTemplate.Code, 'name', 'content');
            JObject.SelectToken(ArrayName, JToken);
            if JToken.IsArray then
                JArray := JToken.AsArray()
            else
                JArray.Add(JToken);
        end else begin
            SmartEmailVariable.SetRange("Transactional Email Code", SmartEmail.Code);
            WriteVariables(JArray, SmartEmailVariable, RecRef);
        end;
    end;

    local procedure WriteVariables(var JArray: JsonArray; var SmartEmailVariable: Record "NPR Smart Email Variable"; RecRef: RecordRef)
    var
        FldRef: FieldRef;
        JObject: JsonObject;
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
                        FldRef := RecRef.Field(SmartEmailVariable."Field No.");
                        if Format(FldRef.Class) = 'FlowField' then
                            FldRef.CalcField();
                        JObject.Add('content', Format(FldRef.Value));
                    end else
                        JObject.Add('content', '');
                end;
                JArray.Add(JObject.Clone());
            until SmartEmailVariable.Next() = 0;
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

    local procedure AddAttachmentsToJArray(var JArray: JsonArray; var Attachment: Record "NPR E-mail Attachment")
    var
        Convert: Codeunit "Base64 Convert";
        JObject: JsonObject;
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
    end;

    local procedure GetString(JObject: JsonObject; Property: Text): Text
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if GetJToken(JObject, Property, JToken) then begin
            JValue := JToken.AsValue();
            exit(JValue.AsText());
        end;
    end;

    local procedure GetInt(JObject: JsonObject; Property: Text): Integer
    var
        Number: Integer;
    begin
        if Evaluate(Number, GetString(JObject, Property)) then
            exit(Number);
    end;

    local procedure GetDate(JObject: JsonObject; Property: Text): Date
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DT2Date(DTVar));
    end;

    local procedure GetJToken(JObject: JsonObject; Property: Text; var JToken: JsonToken): Boolean
    var
        JText: Text;
    begin
        JObject.SelectToken(Property, JToken);
        JToken.WriteTo(JText);
        exit(JText <> '');
    end;

    local procedure GetAttachmentType(FileName: Text) mimeType: Text
    var
        fileMgt: Codeunit "File Management";
        FileFormatErr: Label 'File format isn''t supported.';
    begin
        case lowercase(fileMgt.GetExtension(FileName)) of
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