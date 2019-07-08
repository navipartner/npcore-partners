codeunit 6059821 "CampaignMonitor Mgt."
{
    // NPR5.38/THRO/20180108 CASE 286713 Object created
    // NPR5.44/THRO/20180723 CASE 310042 Use NpXml to generate data to Campaign Monitor data


    trigger OnRun()
    begin
    end;

    var
        ConnectionSuccessMsg: Label 'The connection test was successful. The settings are valid.';
        ResponseTempBlob: Record TempBlob;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseInStream: InStream;
        HttpStatusCode: DotNet npNetHttpStatusCode;
        ResponseHeaders: DotNet npNetNameValueCollection;

    procedure CheckConnection()
    begin
        Initialize(GetCheckConnectionURL,'GET');

        if not ExecuteWebServiceRequest then
          Error(GetLastErrorText);

        Message(ConnectionSuccessMsg);
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "Transactional JSON Result" temporary)
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
        JObject: DotNet npNetJObject;
        JArray: DotNet npNetJArray;
        I: Integer;
    begin
        TransactionalEmailSetup.Get;
        Initialize(GetSmartEmailListURL(TransactionalEmailSetup."Client ID",''),'GET');

        if not ExecuteWebServiceRequest then
          Error(GetLastErrorText);

        JArray := JArray.Parse(GetWebResonseText);

        for I := 0 to JArray.Count -1 do begin
          JObject := JArray.Item(I);
          if not IsNull(JObject) then begin
            TransactionalJSONResult.Init;
            TransactionalJSONResult."Entry No" := I;
            TransactionalJSONResult.ID := GetString(JObject,'ID');
            TransactionalJSONResult.Name := CopyStr(GetString(JObject,'Name'),1,MaxStrLen(TransactionalJSONResult.Name));
            TransactionalJSONResult.Created := GetDate(JObject,'CreatedAt');
            TransactionalJSONResult.Status := GetString(JObject,'Status');
            TransactionalJSONResult.Insert;
          end;
        end;
    end;

    procedure GetSmartEmailDetails(var TransactionalEmail: Record "Smart Email")
    var
        TransactionalEmailVariable: Record "Smart Email Variable";
        TempVariable: Record "Smart Email Variable" temporary;
        JObject: DotNet npNetJObject;
        JArray: DotNet npNetJArray;
        I: Integer;
    begin
        TransactionalEmail.TestField("Smart Email ID");

        Initialize(GetSmartEmailDetailsURL(TransactionalEmail."Smart Email ID"),'GET');

        if not ExecuteWebServiceRequest then
          Error(GetLastErrorText);

        JObject := JObject.Parse(GetWebResonseText);

        TransactionalEmail.Status := GetString(JObject,'Status');
        TransactionalEmail."Smart Email Name" := CopyStr(GetString(JObject,'Name'),1,MaxStrLen(TransactionalEmail."Smart Email Name"));
        if GetJToken(JObject,'Properties',JObject) then begin
          TransactionalEmail.From := CopyStr(GetString(JObject,'From'),1,MaxStrLen(TransactionalEmail.From));
          TransactionalEmail."Reply To" := CopyStr(GetString(JObject,'ReplyTo'),1,MaxStrLen(TransactionalEmail."Reply To"));
          TransactionalEmail.Subject := CopyStr(GetString(JObject,'Subject'),1,MaxStrLen(TransactionalEmail.Subject));
          TransactionalEmail."Preview Url" := CopyStr(GetString(JObject,'HtmlPreviewUrl'),1,MaxStrLen(TransactionalEmail."Preview Url"));
          if GetJToken(JObject,'Content',JObject) then
            if GetJToken(JObject,'EmailVariables',JArray) then
              for I := 0 to JArray.Count() - 1 do begin
                TempVariable.Init;
                TempVariable."Transactional Email Code" := TransactionalEmail.Code;
                TempVariable."Line No." := I;
                TempVariable."Variable Name" := JArray.Item(I).ToString();
                TempVariable.Insert;
              end;
        end;
        TransactionalEmailVariable.SetRange("Transactional Email Code",TransactionalEmail.Code);
        if TransactionalEmailVariable.FindSet then
          repeat
            TempVariable.SetRange("Variable Name",TransactionalEmailVariable."Variable Name");
            if TempVariable.FindSet then
              TempVariable.DeleteAll
            else
              TransactionalEmailVariable.Delete;
          until TransactionalEmailVariable.Next = 0;
        I := TransactionalEmailVariable."Line No." + 10000;
        TempVariable.Reset;
        if TempVariable.FindSet then
          repeat
            TransactionalEmailVariable := TempVariable;
            TransactionalEmailVariable."Line No." := I;
            I += 10000;
            TransactionalEmailVariable."Merge Table ID" := TransactionalEmail."Merge Table ID";
            TransactionalEmailVariable.Insert;
          until TempVariable.Next = 0;
        TransactionalEmail.Modify;
    end;

    procedure GetMessageDetails(EmailLog: Record "Transactional Email Log")
    var
        JObject: DotNet npNetJObject;
    begin
        if IsNullGuid(EmailLog."Message ID") then
          exit;

        Initialize(GetMessageDetailsURL(EmailLog."Message ID",true),'GET');

        if not ExecuteWebServiceRequest then
          Error(GetLastErrorText);

        JObject := JObject.Parse(GetWebResonseText);
        if not IsNull(JObject) then begin
          EmailLog.Status := GetString(JObject,'Status');
          EmailLog.Recipient := CopyStr(GetString(JObject,'Recipient'),1,MaxStrLen(EmailLog.Recipient));
          if Evaluate(EmailLog."Smart Email ID",GetString(JObject,'SmartEmailID')) then;
          EmailLog."Sent At" := GetDateTime(JObject,'SentAt');
          EmailLog."Total Opens" := GetInt(JObject,'TotalOpens');
          EmailLog."Total Clicks" := GetInt(JObject,'TotalClicks');
          if GetJToken(JObject,'Message',JObject) then
            EmailLog.Subject := GetString(JObject,'Subject');
        EmailLog.Modify;
        end;
    end;

    procedure SendSmartEmail(TransactionalEmail: Record "Smart Email";Recipient: Text;Cc: Text;Bcc: Text;RecRef: RecordRef;Silent: Boolean) ErrorMessage: Text
    var
        Attachment: Record "E-mail Attachment" temporary;
    begin
        SendSmartEmailWAttachment(TransactionalEmail,Recipient,Cc,Bcc,RecRef,Attachment,Silent);
    end;

    procedure SendSmartEmailWAttachment(TransactionalEmail: Record "Smart Email";Recipient: Text;Cc: Text;Bcc: Text;RecRef: RecordRef;var Attachment: Record "E-mail Attachment";Silent: Boolean) ErrorMessage: Text
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
        TransactionalEmailVariable: Record "Smart Email Variable";
        TempBlob: Record TempBlob temporary;
        EmailLog: Record "Transactional Email Log";
        NpXmlTemplate: Record "NpXml Template";
        StringBuilder: DotNet npNetStringBuilder;
        StringWriter: DotNet npNetStringWriter;
        Encoding: DotNet npNetEncoding;
        JTextWriter: DotNet npNetJsonTextWriter;
        Formatting: DotNet npNetFormatting;
        JObject: DotNet npNetJObject;
        JArray: DotNet npNetJArray;
        NpXmlMgt: Codeunit "NpXml Mgt.";
        NpXmlValueMgt: Codeunit "NpXml Value Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        OStream: OutStream;
        I: Integer;
        RecRef2: RecordRef;
        FileManagement: Codeunit "File Management";
        XmlDocNode: DotNet npNetXmlNode;
        XmlDoc: DotNet npNetXmlDocument;
    begin
        TransactionalEmail.TestField("Smart Email ID");
        TransactionalEmailSetup.Get;

        Clear(HttpWebRequestMgt);
        HttpWebRequestMgt.Initialize(SendSmartEmailURL(TransactionalEmail."Smart Email ID"));
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.AddHeader('Authorization','Basic ' + GetBasicAuthInfo(TransactionalEmailSetup."API Key",''));
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');

        StringBuilder := StringBuilder.StringBuilder();
        StringWriter := StringWriter.StringWriter(StringBuilder);
        JTextWriter := JTextWriter.JsonTextWriter(StringWriter);
        JTextWriter.Formatting := Formatting.Indented;

        JTextWriter.WriteStartObject;
        WriteRecipients(JTextWriter,Recipient,Cc,Bcc);
        WriteAttachments(JTextWriter,Attachment);
        //-NPR5.44 [310042]
        if (TransactionalEmail."NpXml Template Code" <> '') and NpXmlTemplate.Get(TransactionalEmail."NpXml Template Code") then begin
          RecRef2 := RecRef.Duplicate;
          RecRef2.SetRecFilter;
          NpXmlMgt.Initialize(NpXmlTemplate,RecRef2,NpXmlValueMgt.GetPrimaryKeyValue(RecRef2),true);
          NpXmlDomMgt.InitDoc(XmlDoc,XmlDocNode,NpXmlTemplate."Xml Root Name");

          NpXmlMgt.ParseDataToXmlDocNode(RecRef2,true,XmlDocNode);

          JTextWriter.WritePropertyName('Data');
          JTextWriter.WriteRawValue(NpXmlMgt.Xml2Json(XmlDoc,NpXmlTemplate));
        end else begin
          TransactionalEmailVariable.SetRange("Transactional Email Code",TransactionalEmail.Code);
          WriteVariables(JTextWriter,TransactionalEmailVariable,RecRef);
        end;
        //+NPR5.44 [310042]
        JTextWriter.WriteEndObject;

        TempBlob.Init;
        TempBlob.Insert;
        TempBlob.Blob.CreateOutStream(OStream,TEXTENCODING::UTF8);
        OStream.WriteText(StringBuilder.ToString);
        TempBlob.Modify;
        HttpWebRequestMgt.AddBodyBlob(TempBlob);

        if not ExecuteWebServiceRequest then begin
          if Silent then
            exit(GetLastErrorText)
          else
            Error(GetLastErrorText);
        end;

        JArray := JArray.Parse(GetWebResonseText);

        for I := 0 to JArray.Count -1 do begin
          JObject := JArray.Item(I);
          if not IsNull(JObject) then begin
            EmailLog.Init;
            EmailLog."Entry No." := 0;
            EmailLog."Message ID" := GetString(JObject,'MessageID');
            EmailLog.Status := GetString(JObject,'Status');
            EmailLog.Recipient := CopyStr(GetString(JObject,'Recipient'),1,MaxStrLen(EmailLog.Recipient));
            EmailLog.Insert(true);
          end;
        end;
        exit('');
    end;

    procedure SendClasicMail(Recipient: Text;Cc: Text;Bcc: Text;Subject: Text;BodyHtml: Text;BodyText: Text;From: Text;ReplyTo: Text;TrackOpen: Boolean;TrackClick: Boolean;Group: Text;AddRecipientsToListID: Text;var Attachment: Record "E-mail Attachment";Silent: Boolean): Text
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
        TempBlob: Record TempBlob temporary;
        EmailLog: Record "Transactional Email Log";
        StringBuilder: DotNet npNetStringBuilder;
        StringWriter: DotNet npNetStringWriter;
        Encoding: DotNet npNetEncoding;
        JTextWriter: DotNet npNetJsonTextWriter;
        Formatting: DotNet npNetFormatting;
        JObject: DotNet npNetJObject;
        JArray: DotNet npNetJArray;
        OStream: OutStream;
        I: Integer;
    begin
        TransactionalEmailSetup.Get;

        Clear(HttpWebRequestMgt);
        HttpWebRequestMgt.Initialize(SendClassicEmailURL(TransactionalEmailSetup."Client ID"));
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.AddHeader('Authorization','Basic ' + GetBasicAuthInfo(TransactionalEmailSetup."API Key",''));
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');

        StringBuilder := StringBuilder.StringBuilder();
        StringWriter := StringWriter.StringWriter(StringBuilder);
        JTextWriter := JTextWriter.JsonTextWriter(StringWriter);
        JTextWriter.Formatting := Formatting.Indented;

        JTextWriter.WriteStartObject;
        WriteNameValuePair(JTextWriter,'Subject',Subject);
        WriteNameValuePair(JTextWriter,'From',From);
        if ReplyTo <> '' then
          WriteNameValuePair(JTextWriter,'ReplyTo',ReplyTo);
        WriteRecipients(JTextWriter,Recipient,Cc,Bcc);
        if BodyHtml <> '' then
          WriteNameValuePair(JTextWriter,'Html',BodyHtml);
        if BodyText <> '' then
          WriteNameValuePair(JTextWriter,'Text',BodyText);
        WriteAttachments(JTextWriter,Attachment);
        if TrackOpen then
          WriteNameValuePair(JTextWriter,'TrackOpens','true');
        if TrackClick then
          WriteNameValuePair(JTextWriter,'TrackClicks','true');
        if Group <> '' then
          WriteNameValuePair(JTextWriter,'Group',Group);
        if AddRecipientsToListID <> '' then
          WriteNameValuePair(JTextWriter,'AddRecipientsToListID',AddRecipientsToListID);
        JTextWriter.WriteEndObject;

        TempBlob.Init;
        TempBlob.Insert;
        TempBlob.Blob.CreateOutStream(OStream,TEXTENCODING::UTF8);
        OStream.WriteText(StringBuilder.ToString);
        TempBlob.Modify;
        HttpWebRequestMgt.AddBodyBlob(TempBlob);

        if not ExecuteWebServiceRequest then begin
          if Silent then
            exit(GetLastErrorText)
          else
            Error(GetLastErrorText);
        end;

        JArray := JArray.Parse(GetWebResonseText);

        for I := 0 to JArray.Count -1 do begin
          JObject := JArray.Item(I);
          if not IsNull(JObject) then begin
            EmailLog.Init;
            EmailLog."Entry No." := 0;
            EmailLog."Message ID" := GetString(JObject,'MessageID');
            EmailLog.Status := GetString(JObject,'Status');
            EmailLog.Recipient := CopyStr(GetString(JObject,'Recipient'),1,MaxStrLen(EmailLog.Recipient));
            EmailLog.Insert(true);
          end;
        end;
        exit('');
    end;

    local procedure Initialize(URL: Text;Method: Text[6])
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
    begin
        TransactionalEmailSetup.Get;
        TransactionalEmailSetup.TestField("Client ID");
        TransactionalEmailSetup.TestField("API Key");

        Clear(HttpWebRequestMgt);
        HttpWebRequestMgt.Initialize(URL);
        HttpWebRequestMgt.SetMethod(Method);
        HttpWebRequestMgt.AddHeader('Authorization','Basic ' + GetBasicAuthInfo(TransactionalEmailSetup."API Key",''));
        HttpWebRequestMgt.SetContentType('application/json');
        HttpWebRequestMgt.SetReturnType('application/json');
    end;

    [TryFunction]
    local procedure ExecuteWebServiceRequest()
    begin
        Clear(ResponseTempBlob);
        ResponseTempBlob.Init;
        ResponseTempBlob.Blob.CreateInStream(ResponseInStream);

        if not GuiAllowed then
          HttpWebRequestMgt.DisableUI;

        if not HttpWebRequestMgt.GetResponse(ResponseInStream,HttpStatusCode,ResponseHeaders) then
          HttpWebRequestMgt.ProcessFaultXMLResponse('','','','');
    end;

    local procedure CheckCredentials()
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
    begin
        TransactionalEmailSetup.Get;
        TransactionalEmailSetup.TestField("Client ID");
        TransactionalEmailSetup.TestField("API Key");
    end;

    local procedure GetBasicAuthInfo(Username: Text;Password: Text): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        exit(Convert.ToBase64String(Encoding.UTF8.GetBytes(Username + ':' + Password)));
    end;

    local procedure GetFullURL(PartialURL: Text): Text
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
    begin
        TransactionalEmailSetup.Get;
        TransactionalEmailSetup.TestField("API URL");
        exit(TransactionalEmailSetup."API URL" + PartialURL);
    end;

    local procedure GetCheckConnectionURL(): Text
    begin
        exit(GetFullURL('/clients.json'));
    end;

    local procedure GetSmartEmailListURL(ClientID: Text;Status: Text): Text
    var
        ParameterString: Text;
    begin
        ParameterString := AddParameter('clientID',ClientID,ParameterString);
        ParameterString := AddParameter('status',Status,ParameterString);

        exit(GetFullURL('/transactional/smartEmail?'+ParameterString));
    end;

    local procedure GetSmartEmailDetailsURL(SmartEmailID: Text): Text
    begin
        exit(GetFullURL('/transactional/smartEmail/'+SmartEmailID));
    end;

    local procedure GetMessageDetailsURL(MessageID: Guid;Statistics: Boolean): Text
    begin
        if Statistics then
          exit(GetFullURL('/transactional/messages/'+GuidToText(MessageID)+'?statistics=true'))
        else
          exit(GetFullURL('/transactional/messages/'+GuidToText(MessageID)));
    end;

    local procedure SendSmartEmailURL(SmartEmailID: Text): Text
    begin
        exit(GetFullURL(StrSubstNo('/transactional/smartEmail/%1/send.json',SmartEmailID)));
    end;

    local procedure SendClassicEmailURL(ClientID: Text): Text
    var
        ParameterString: Text;
    begin
        ParameterString := AddParameter('clientID',ClientID,ParameterString);

        exit(GetFullURL('/transactional/classicEmail/send?'+ParameterString));
    end;

    local procedure AddParameter(ParameterName: Text;ParameterValue: Text;ParameterString: Text): Text
    begin
        if ParameterValue = '' then
          exit(ParameterString);
        if ParameterString <> '' then
          ParameterString += '&';
        ParameterString += StrSubstNo('%1=%2',ParameterName,ParameterValue);
        exit(ParameterString);
    end;

    local procedure GuidToText(Guid: Guid): Text
    var
        String: Text;
    begin
        String := Format(Guid);
        String := DelChr(String,'<>','{');
        String := DelChr(String,'<>','}');
        exit(String);
    end;

    procedure DefaultAPIURL(): Text
    begin
        exit('https://api.createsend.com/api/v3.1');
    end;

    local procedure "---"()
    begin
    end;

    local procedure GetString(JObject: DotNet npNetJObject;Property: Text): Text
    var
        JToken: DotNet npNetJToken;
    begin
        if GetJToken(JObject,Property,JToken) then
          exit(JToken.ToString());
    end;

    local procedure GetInt(JObject: DotNet npNetJObject;Property: Text): Integer
    var
        Number: Integer;
    begin
        if Evaluate(Number,GetString(JObject,Property)) then
          exit(Number);
    end;

    local procedure GetDateTime(JObject: DotNet npNetJObject;Property: Text): DateTime
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar,GetString(JObject,Property)) then
          exit(DTVar);
    end;

    local procedure GetDate(JObject: DotNet npNetJObject;Property: Text): Date
    var
        DTVar: DateTime;
    begin
        if Evaluate(DTVar,GetString(JObject,Property)) then
          exit(DT2Date(DTVar));
    end;

    local procedure GetJToken(JObject: DotNet npNetJObject;Property: Text;var JToken: DotNet npNetJToken): Boolean
    begin
        JToken := JObject.Item(Property);
        exit(not IsNull(JToken));
    end;

    local procedure WriteRecipients(var JTextWriter: DotNet npNetJsonTextWriter;Recipient: Text;Cc: Text;Bcc: Text)
    begin
        if Recipient <> '' then
          WriteReceiver(JTextWriter,'To',Recipient);

        if Cc <> '' then
          WriteReceiver(JTextWriter,'CC',Cc);

        if Bcc <> '' then
          WriteReceiver(JTextWriter,'BCC',Bcc);
    end;

    local procedure WriteReceiver(var JTextWriter: DotNet npNetJsonTextWriter;Type: Text;MailAdresses: Text)
    var
        Pos: Integer;
        "Part": Text;
    begin
        JTextWriter.WritePropertyName(Type);
        JTextWriter.WriteStartArray;
        Pos := StrPos(MailAdresses,';');
        if Pos > 0 then
          repeat
            Part := CopyStr(MailAdresses,1,Pos-1);
            if Part <> '' then
              JTextWriter.WriteValue(Part);
            MailAdresses := CopyStr(MailAdresses,Pos+1);
            Pos := StrPos(MailAdresses,';');
          until Pos = 0;
        if MailAdresses <> '' then
          JTextWriter.WriteValue(MailAdresses);
        JTextWriter.WriteEndArray;
    end;

    local procedure WriteAttachments(var JTextWriter: DotNet npNetJsonTextWriter;var Attachment: Record "E-mail Attachment")
    var
        MemoryStream: DotNet npNetMemoryStream;
        Bytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        IStream: InStream;
        AttachmentText: Text;
    begin
        if Attachment.IsEmpty then
          exit;
        JTextWriter.WritePropertyName('Attachments');
        JTextWriter.WriteStartArray;

        if Attachment.FindSet then
          repeat
            if Attachment."Attached File".HasValue then begin
              Attachment.CalcFields("Attached File");
              Attachment."Attached File".CreateInStream(IStream);
              MemoryStream := MemoryStream.MemoryStream();
              CopyStream(MemoryStream,IStream);
              Bytes := MemoryStream.GetBuffer();
              JTextWriter.WriteStartObject;
              JTextWriter.WritePropertyName('Content');
              JTextWriter.WriteValue(Convert.ToBase64String(Bytes));
              WriteNameValuePair(JTextWriter,'Name',Attachment.Description);
              WriteNameValuePair(JTextWriter,'Type',GetAttachmentType(Attachment.Description));
              JTextWriter.WriteEndObject;
            end;
          until Attachment.Next = 0;
        JTextWriter.WriteEndArray;
    end;

    local procedure WriteVariables(var JTextWriter: DotNet npNetJsonTextWriter;var TransactionalEmailVariable: Record "Smart Email Variable";RecRef: RecordRef)
    var
        FldRef: FieldRef;
    begin
        if TransactionalEmailVariable.FindSet then begin
          JTextWriter.WritePropertyName('Data');
          JTextWriter.WriteStartObject;
          repeat
            JTextWriter.WritePropertyName(TransactionalEmailVariable."Variable Name");
            if TransactionalEmailVariable."Const Value" <> '' then
              JTextWriter.WriteValue(TransactionalEmailVariable."Const Value")
            else begin
              FldRef := RecRef.Field(TransactionalEmailVariable."Field No.");
              if Format(FldRef.Class) = 'FlowField' then
                FldRef.CalcField;
              JTextWriter.WriteValue(Format(FldRef.Value));
            end;
          until TransactionalEmailVariable.Next = 0;
          JTextWriter.WriteEndObject;
        end;
    end;

    local procedure WriteNameValuePair(var JTextWriter: DotNet npNetJsonTextWriter;PropertyName: Text;Value: Text)
    begin
        JTextWriter.WritePropertyName(PropertyName);
        JTextWriter.WriteValue(Value);
    end;

    local procedure GetChar(CharInt: Integer): Text[1]
    var
        Char: Char;
    begin
        Char := CharInt;
        exit(Format(Char));
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

    local procedure GetAttachmentType(FileName: Text): Text
    var
        MimeMapping: DotNet npNetMimeMapping;
    begin
        exit(MimeMapping.GetMimeMapping(FileName));
    end;
}

