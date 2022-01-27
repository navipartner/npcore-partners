codeunit 6059821 "NPR CampaignMonitor Mgt."
{
    Access = Internal;
    var
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';

    procedure CheckConnection()
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Response: Text;
    begin
        InitializeClient(Client);

        Client.Get(GetCheckConnectionURL(), ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content().ReadAs(Response);
            Error(Response);
        end;
        Message(ConnectionSuccessMsg);
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "NPR Trx JSON Result" temporary)
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        I: Integer;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        Response: Text;
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::"Campaign Monitor");

        InitializeClient(Client);
        Client.Get(GetSmartEmailListURL(TransactionalEmailSetup."Client ID", ''), ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(Response);
        JArray.ReadFrom(Response);

        for I := 0 to JArray.Count() - 1 do begin
            JArray.Get(I, JToken);
            if JToken.IsObject then begin
                JObject := JToken.AsObject();
                TransactionalJSONResult.Init();
                TransactionalJSONResult.Provider := TransactionalJSONResult.Provider::"Campaign Monitor";
                TransactionalJSONResult."Entry No" := I;
                TransactionalJSONResult.ID := GetString(JObject, 'ID');
                TransactionalJSONResult.Name := CopyStr(GetString(JObject, 'Name'), 1, MaxStrLen(TransactionalJSONResult.Name));
                TransactionalJSONResult.Created := GetDate(JObject, 'CreatedAt');
                TransactionalJSONResult.Status := GetString(JObject, 'Status');
                TransactionalJSONResult.Insert();
            end;
        end;
    end;

    procedure GetSmartEmailDetails(var SmartEmail: Record "NPR Smart Email")
    var
        SmartEmailVariable: Record "NPR Smart Email Variable";
        TempVariable: Record "NPR Smart Email Variable" temporary;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        I: Integer;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        Response: Text;
    begin
        SmartEmail.TestField("Smart Email ID");

        InitializeClient(Client);
        Client.Get(GetSmartEmailDetailsURL(SmartEmail."Smart Email ID"), ResponseMessage);

        ResponseMessage.Content().ReadAs(Response);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(Response);
        JObject.ReadFrom(Response);

        SmartEmail.Status := GetString(JObject, 'Status');
        SmartEmail."Smart Email Name" := CopyStr(GetString(JObject, 'Name'), 1, MaxStrLen(SmartEmail."Smart Email Name"));
        if GetJToken(JObject, 'Properties', JToken) then
            if JToken.IsObject then begin
                JObject := JToken.AsObject();
                SmartEmail.From := CopyStr(GetString(JObject, 'From'), 1, MaxStrLen(SmartEmail.From));
                SmartEmail."Reply To" := CopyStr(GetString(JObject, 'ReplyTo'), 1, MaxStrLen(SmartEmail."Reply To"));
                SmartEmail.Subject := CopyStr(GetString(JObject, 'Subject'), 1, MaxStrLen(SmartEmail.Subject));
                SmartEmail."Preview Url" := CopyStr(GetString(JObject, 'HtmlPreviewUrl'), 1, MaxStrLen(SmartEmail."Preview Url"));
                if GetJToken(JObject, 'Content', JToken) then
                    if GetJToken(JToken.AsObject(), 'EmailVariables', JToken) then
                        if JToken.IsArray then begin
                            JArray := JToken.AsArray();
                            for I := 0 to JArray.Count() - 1 do begin
                                TempVariable.Init();
                                TempVariable."Transactional Email Code" := SmartEmail.Code;
                                TempVariable."Line No." := I;
                                JArray.Get(I, JToken);
                                if JToken.IsValue then begin
                                    TempVariable."Variable Name" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempVariable."Variable Name"));
                                    TempVariable.Insert();
                                end;
                            end;

                        end;

            end;
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
                SmartEmailVariable."Line No." := I;
                I += 10000;
                SmartEmailVariable."Merge Table ID" := SmartEmail."Merge Table ID";
                SmartEmailVariable.Insert();
            until TempVariable.Next() = 0;
        SmartEmail.Modify();
    end;

    procedure GetMessageDetails(EmailLog: Record "NPR Trx Email Log")
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        JToken: JsonToken;
        Response: Text;
    begin
        if IsNullGuid(EmailLog."Message ID") then
            exit;

        InitializeClient(Client);
        Client.Get(GetMessageDetailsURL(EmailLog."Message ID", true), ResponseMessage);

        ResponseMessage.Content().ReadAs(Response);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(Response);

        if JObject.ReadFrom(Response) then begin
            EmailLog.Status := GetString(JObject, 'Status');
            EmailLog.Recipient := CopyStr(GetString(JObject, 'Recipient'), 1, MaxStrLen(EmailLog.Recipient));
            if Evaluate(EmailLog."Smart Email ID", GetString(JObject, 'SmartEmailID')) then;
            EmailLog."Sent At" := GetDateTime(JObject, 'SentAt');
            EmailLog."Total Opens" := GetInt(JObject, 'TotalOpens');
            EmailLog."Total Clicks" := GetInt(JObject, 'TotalClicks');
            if GetJToken(JObject, 'Message', JToken) then
                EmailLog.Subject := GetString(JToken.AsObject(), 'Subject');
            EmailLog.Modify();
        end;
    end;

    procedure SendSmartEmail(TransactionalEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; Silent: Boolean) ErrorMessage: Text
    var
        TempAttachment: Record "NPR E-mail Attachment" temporary;
    begin
        exit(SendSmartEmailWAttachment(TransactionalEmail, Recipient, Cc, Bcc, RecRef, TempAttachment, Silent));
    end;

    procedure SendSmartEmailWAttachment(TransactionalEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean) ErrorMessage: Text
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        TransactionalEmailVariable: Record "NPR Smart Email Variable";
        EmailLog: Record "NPR Trx Email Log";
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NPR NpXml Value Mgt.";
        RecRef2: RecordRef;
        XmlDoc: XmlDocument;
        XmlDocNode: XmlNode;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        I: Integer;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        Separators: List of [Text];
        ContentText: Text;
        Response: Text;

    begin
        TransactionalEmail.TestField("Smart Email ID");
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::"Campaign Monitor");

        InitMailAdrSeparators(Separators);

        JObject.Add('To', ListToArray(Recipient.Split(Separators)));
        if Cc <> '' then
            JObject.Add('CC', ListToArray(Cc.Split(Separators)));
        if Bcc <> '' then
            JObject.Add('BCC', ListToArray(Bcc.Split(Separators)));

        if not Attachment.IsEmpty() then
            JObject.Add('Attachments', AttachmentsToArray(Attachment));

        if (TransactionalEmail."NpXml Template Code" <> '') and NpXmlTemplate.Get(TransactionalEmail."NpXml Template Code") then begin
            RecRef2 := RecRef.Duplicate();
            RecRef2.SetRecFilter();
            NpXmlMgt.Initialize(NpXmlTemplate, RecRef2, NpXmlValueMgt.GetPrimaryKeyValue(RecRef2), true);
            NpXmlDomMgt.InitDoc(XmlDoc, XmlDocNode, NpXmlTemplate."Xml Root Name", NpXmlTemplate."Custom Namespace for XMLNS");
            NpXmlDomMgt.AddRootAttributes(XmlDocNode, NpXmlTemplate);

            NpXmlMgt.ParseDataToXmlDocNode(RecRef2, true, XmlDocNode);
            JObject.Add('Data', NpXmlMgt.Xml2Json(XmlDoc, NpXmlTemplate));
        end else begin
            TransactionalEmailVariable.SetRange("Transactional Email Code", TransactionalEmail.Code);
            JObject.Add('Data', GenerateVariablesObject(TransactionalEmailVariable, RecRef));
        end;

        InitializeClient(Client);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json; charset=utf-8');
        JObject.WriteTo(ContentText);
        Content.WriteFrom(ContentText);
        Client.Post(SendSmartEmailURL(TransactionalEmail."Smart Email ID"), Content, ResponseMessage);

        ResponseMessage.Content().ReadAs(Response);
        if not ResponseMessage.IsSuccessStatusCode() then
            if Silent then
                exit(Response)
            else
                Error(Response);

        if JArray.ReadFrom(Response) then begin
            for I := 0 to JArray.Count() - 1 do begin
                JArray.Get(I, JToken);
                if JToken.IsObject then begin
                    EmailLog.Init();
                    EmailLog."Entry No." := 0;
                    EmailLog.Provider := EmailLog.Provider::"Campaign Monitor";
                    EmailLog."Message ID" := GetString(JToken.AsObject(), 'MessageID');
                    EmailLog.Status := GetString(JToken.AsObject(), 'Status');
                    EmailLog.Recipient := CopyStr(GetString(JToken.AsObject(), 'Recipient'), 1, MaxStrLen(EmailLog.Recipient));
                    EmailLog.Insert(true);
                end;
            end;
        end;
        exit('');
    end;

    procedure SendClasicMail(Recipient: Text; Cc: Text; Bcc: Text; Subject: Text; BodyHtml: Text; BodyText: Text; From: Text; ReplyTo: Text; TrackOpen: Boolean; TrackClick: Boolean; Group: Text; AddRecipientsToListID: Text; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean): Text
    var
        Separators: List of [Text];

    begin
        InitMailAdrSeparators(Separators);
        exit(SendClasicMail(Recipient.Split(Separators), cc.Split(Separators), Bcc.Split(Separators), Subject, BodyHtml, BodyText, From, ReplyTo, TrackOpen, TrackClick, Group, AddRecipientsToListID, Attachment, Silent));
    end;

    procedure SendClasicMail(Recipient: List of [Text]; Cc: List of [Text]; Bcc: List of [Text]; Subject: Text; BodyHtml: Text; BodyText: Text; From: Text; ReplyTo: Text; TrackOpen: Boolean; TrackClick: Boolean; Group: Text; AddRecipientsToListID: Text; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean): Text
    var
        EmailLog: Record "NPR Trx Email Log";
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        I: Integer;
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        ContentText: Text;
        Response: Text;
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::"Campaign Monitor");

        JObject.Add('Subject', Subject);
        JObject.Add('From', From);
        if ReplyTo <> '' then
            JObject.Add('ReplyTo', ReplyTo);
        JObject.Add('To', ListToArray(Recipient));
        if Cc.Count() > 0 then
            JObject.Add('CC', ListToArray(Cc));
        if Bcc.Count() > 0 then
            JObject.Add('BCC', ListToArray(Bcc));
        if BodyHtml <> '' then
            JObject.Add('Html', BodyHtml);
        if BodyText <> '' then
            JObject.Add('Text', BodyText);
        if not Attachment.IsEmpty() then
            JObject.Add('Attachments', AttachmentsToArray(Attachment));
        if TrackOpen then
            JObject.Add('TrackOpens', true);
        if TrackClick then
            JObject.Add('TrackClicks', true);
        if Group <> '' then
            JObject.Add('Group', Group);
        if AddRecipientsToListID <> '' then
            JObject.Add('AddRecipientsToListID', AddRecipientsToListID);

        InitializeClient(Client);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json; charset=utf-8');
        JObject.WriteTo(ContentText);
        Content.WriteFrom(ContentText);

        Client.Post(SendClassicEmailURL(TransactionalEmailSetup."Client ID"), Content, ResponseMessage);

        ResponseMessage.Content().ReadAs(Response);
        if not ResponseMessage.IsSuccessStatusCode then
            if Silent then
                exit(Response)
            else
                Error(Response);

        if JArray.ReadFrom(Response) then begin
            for I := 0 to JArray.Count() - 1 do begin
                JArray.Get(I, JToken);
                if JToken.IsObject then begin
                    EmailLog.Init();
                    EmailLog."Entry No." := 0;
                    EmailLog.Provider := EmailLog.Provider::"Campaign Monitor";
                    EmailLog."Message ID" := GetString(JToken.AsObject(), 'MessageID');
                    EmailLog.Status := GetString(JToken.AsObject(), 'Status');
                    EmailLog.Recipient := CopyStr(GetString(JToken.AsObject(), 'Recipient'), 1, MaxStrLen(EmailLog.Recipient));
                    EmailLog.Insert(true);
                end;
            end;
        end;
        exit('');
    end;

    procedure PreviewSmartEmail(SmartEmail: Record "NPR Smart Email")
    begin
        if SmartEmail."Preview Url" <> '' then
            HyperLink(SmartEmail."Preview Url");
    end;

    local procedure InitializeClient(Client: HttpClient)
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        Headers: HttpHeaders;
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::"Campaign Monitor");
        TransactionalEmailSetup.TestField("Client ID");
        TransactionalEmailSetup.TestField("API Key");

        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', GetBasicAuthInfo(TransactionalEmailSetup."API Key", ''));
    end;

    local procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(Username + ':' + Password);
        TempBlob.CreateInStream(IStream);
        exit('Basic ' + Base64Convert.ToBase64(IStream));
    end;

    local procedure GetFullURL(PartialURL: Text): Text
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        TransactionalEmailSetup.Get(TransactionalEmailSetup.Provider::"Campaign Monitor");
        TransactionalEmailSetup.TestField("API URL");
        exit(TransactionalEmailSetup."API URL" + PartialURL);
    end;

    local procedure GetCheckConnectionURL(): Text
    begin
        exit(GetFullURL('/clients.json'));
    end;

    local procedure GetSmartEmailListURL(ClientID: Text; Status: Text): Text
    var
        ParameterString: Text;
    begin
        ParameterString := AddParameter('clientID', ClientID, ParameterString);
        ParameterString := AddParameter('status', Status, ParameterString);

        exit(GetFullURL('/transactional/smartEmail?' + ParameterString));
    end;

    local procedure GetSmartEmailDetailsURL(SmartEmailID: Text): Text
    begin
        exit(GetFullURL('/transactional/smartEmail/' + SmartEmailID));
    end;

    local procedure GetMessageDetailsURL(MessageID: Guid; Statistics: Boolean): Text
    begin
        if Statistics then
            exit(GetFullURL('/transactional/messages/' + GuidToText(MessageID) + '?statistics=true'))
        else
            exit(GetFullURL('/transactional/messages/' + GuidToText(MessageID)));
    end;

    local procedure SendSmartEmailURL(SmartEmailID: Text): Text
    var
        UrlLbl: Label '/transactional/smartEmail/%1/send.json', Locked = true;
    begin
        exit(GetFullURL(StrSubstNo(UrlLbl, SmartEmailID)));
    end;

    local procedure SendClassicEmailURL(ClientID: Text): Text
    var
        ParameterString: Text;
    begin
        ParameterString := AddParameter('clientID', ClientID, ParameterString);

        exit(GetFullURL('/transactional/classicEmail/send?' + ParameterString));
    end;

    local procedure AddParameter(ParameterName: Text; ParameterValue: Text; ParameterString: Text): Text
    var
        NameValuePairLbl: Label '%1=%2', Locked = true;
    begin
        if ParameterValue = '' then
            exit(ParameterString);
        if ParameterString <> '' then
            ParameterString += '&';
        ParameterString += StrSubstNo(NameValuePairLbl, ParameterName, ParameterValue);
        exit(ParameterString);
    end;

    local procedure GuidToText(Guid: Guid): Text
    var
        String: Text;
    begin
        String := Format(Guid);
        String := DelChr(String, '<>', '{');
        String := DelChr(String, '<>', '}');
        exit(String);
    end;

    local procedure DefaultAPIURL(): Text
    begin
        exit('https://api.createsend.com/api/v3.1');
    end;

    local procedure GetString(JObject: JsonObject; Property: Text): Text
    var
        JToken: JsonToken;
    begin
        if GetJToken(JObject, Property, JToken) then
            if JToken.IsValue then
                exit(JToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetInt(JObject: JsonObject; Property: Text): Integer
    var
        Number: Integer;
    begin
        if Evaluate(Number, GetString(JObject, Property)) then
            exit(Number);
    end;

    local procedure GetDateTime(JObject: JsonObject; Property: Text): DateTime
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DTVar);
    end;

    local procedure GetDate(JObject: JsonObject; Property: Text): Date
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar, GetString(JObject, Property)) then
            exit(DT2Date(DTVar));
    end;

    local procedure GetJToken(JObject: JsonObject; Property: Text; var JToken: JsonToken): Boolean
    begin
        exit(JObject.Get(Property, JToken));
    end;

    local procedure AttachmentsToArray(var Attachment: Record "NPR E-mail Attachment"): JsonArray;
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
        JArray: JsonArray;
        JObject: JsonObject;
    begin
        if Attachment.IsEmpty() then
            exit;

        if Attachment.FindSet() then
            repeat
                if Attachment."Attached File".HasValue() then begin
                    Attachment.CalcFields("Attached File");
                    Attachment."Attached File".CreateInStream(IStream);
                    Clear(JObject);
                    JObject.Add('Content', Base64Convert.ToBase64(IStream));
                    JObject.Add('Name', Attachment.Description);
                    JObject.Add('Type', GetAttachmentType(Attachment.Description));

                    JArray.Add(JObject);
                end;
            until Attachment.Next() = 0;
        exit(JArray);
    end;

    local procedure GenerateVariablesObject(var TransactionalEmailVariable: Record "NPR Smart Email Variable"; RecRef: RecordRef): JsonObject
    var
        FldRef: FieldRef;
        JObject: JsonObject;
        ValueString: Text;
    begin
        if TransactionalEmailVariable.FindSet() then begin
            repeat
                if TransactionalEmailVariable."Const Value" <> '' then
                    ValueString := TransactionalEmailVariable."Const Value"
                else begin
                    FldRef := RecRef.Field(TransactionalEmailVariable."Field No.");
                    if Format(FldRef.Class) = 'FlowField' then
                        FldRef.CalcField();
                    ValueString := Format(FldRef.Value);
                end;
                JObject.Add(TransactionalEmailVariable."Variable Name", ValueString);
            until TransactionalEmailVariable.Next() = 0;
        end;
        exit(JObject);
    end;

    local procedure GetAttachmentType(FileName: Text): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.GetFileNameMimeType(FileName));
    end;

    local procedure InitMailAdrSeparators(var MailAdrSeparators: List of [Text])
    begin
        MailAdrSeparators.Add(';');
        MailAdrSeparators.Add(',');
    end;

    local procedure ListToArray(Data: List of [Text]): JsonArray
    var
        JArray: JsonArray;
        ListElement: Text;
    begin
        foreach ListElement in Data do
            JArray.Add(ListElement);
        exit(JArray);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Trx Email Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertTransactionalEmailSetup(var Rec: Record "NPR Trx Email Setup"; RunTrigger: Boolean)
    begin
        if Rec."API URL" = '' then
            Rec."API URL" := DefaultAPIURL();
    end;

}

