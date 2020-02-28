codeunit 6151220 "PrintNode API Mgt."
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created


    trigger OnRun()
    begin
        SendPrintJob('69233945', 0, 'https://app.printnode.com/testpdfs/a4_portrait.pdf', 'Testprint form NAV', 'DEV_Latest', '', '');
    end;

    var
        Text001: Label 'Property "%1" does not exist in JSON object.\\%2.';
        ConnectOKTxt: Label 'Service Returned %1\%2';
        RegistreredEmailTxt: Label 'Account registered to email %1';
        TitleDefaultTxt: Label 'NPRetail - Printjob';
        SourceDefaultTxt: Label 'NPRetail';

    procedure TestConnection(ShowMessage: Boolean): Boolean
    var
        HttpStatusCode: DotNet npNetHttpStatusCode;
        ResponseHeaders: DotNet npNetNameValueCollection;
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseInStream: InStream;
        ResponseText: Text;
    begin
        HttpWebRequestMgt.Initialize(BaseUrl + 'whoami');
        HttpWebRequestMgt.AddHeader('Authorization', GetBasicAuthInfo());
        HttpWebRequestMgt.SetMethod('GET');
        HttpWebRequestMgt.SetContentType('application/json');

        Clear(TempBlob);
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);
        if not HttpWebRequestMgt.GetResponse(ResponseInStream, HttpStatusCode, ResponseHeaders) then begin
            if ShowMessage then
                ErrorHandler();
            exit(false);
        end;
        if ShowMessage then begin
            ResponseInStream.ReadText(ResponseText);
            JObject := JObject.Parse(ResponseText);
            if GetJToken(JObject, JToken, 'email', false) then
                Message(StrSubstNo(ConnectOKTxt, HttpStatusCode, StrSubstNo(RegistreredEmailTxt, JToken.ToString)))
            else
                Message(StrSubstNo(ConnectOKTxt, HttpStatusCode));
        end;
        exit(true);
    end;

    procedure GetPrinters(var PrintNodePrinter: Record "PrintNode Printer"): Boolean
    var
        HttpStatusCode: DotNet npNetHttpStatusCode;
        ResponseHeaders: DotNet npNetNameValueCollection;
        JArray: DotNet npNetJArray;
        JToken: DotNet npNetJToken;
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseInStream: InStream;
        ResponseText: Text;
        I: Integer;
        PrinterId: Text;
    begin
        HttpWebRequestMgt.Initialize(BaseUrl + 'printers');
        HttpWebRequestMgt.AddHeader('Authorization', GetBasicAuthInfo());
        HttpWebRequestMgt.SetMethod('GET');
        HttpWebRequestMgt.SetContentType('application/json');

        Clear(TempBlob);
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);
        if not HttpWebRequestMgt.GetResponse(ResponseInStream, HttpStatusCode, ResponseHeaders) then begin
            HttpWebRequestMgt.ProcessFaultXMLResponse('', '', '', '');
            exit(false);
        end;

        ResponseInStream.ReadText(ResponseText);
        JArray := JArray.Parse(ResponseText);
        while I < JArray.Count do begin
            JToken := JArray.Item(I);
            PrintNodePrinter.Init;
            PrinterId := GetString(JToken, 'id', true);
            if not PrintNodePrinter.Get(PrinterId) then begin
                PrintNodePrinter.Init;
                PrintNodePrinter.Id := PrinterId;
                PrintNodePrinter.Name := CopyStr(GetString(JToken, 'name', false), 1, MaxStrLen(PrintNodePrinter.Name));
                PrintNodePrinter.Description := CopyStr(GetString(JToken, 'description', false), 1, MaxStrLen(PrintNodePrinter.Description));
                PrintNodePrinter.Insert(true);
            end else begin
                PrintNodePrinter.Name := CopyStr(GetString(JToken, 'name', false), 1, MaxStrLen(PrintNodePrinter.Name));
                PrintNodePrinter.Description := CopyStr(GetString(JToken, 'description', false), 1, MaxStrLen(PrintNodePrinter.Description));
                PrintNodePrinter.Modify(true);
            end;
            I += 1;
        end;

        exit(true);
    end;

    procedure SendPrintJob(PrinterId: Code[20]; ContentType: Option pdf_uri,pdf_base64,raw_uri,raw_base64; Content: Text; Title: Text; SourceDescription: Text; Options: Text; Authentication: Text) PrintJobId: Integer
    var
        HttpStatusCode: DotNet npNetHttpStatusCode;
        ResponseHeaders: DotNet npNetNameValueCollection;
        JObject: DotNet npNetJObject;
        TempBlob: Record TempBlob temporary;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ResponseInStream: InStream;
        BodyStream: OutStream;
        ResponseText: Text;
    begin
        HttpWebRequestMgt.Initialize(BaseUrl + 'printjobs');
        HttpWebRequestMgt.AddHeader('Authorization', GetBasicAuthInfo());
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.SetContentType('application/json');

        if Title = '' then
            Title := TitleDefaultTxt;
        if SourceDescription = '' then
            SourceDescription := SourceDefaultTxt;
        JObject := JObject.JObject();
        AddJPropertyToJObject(JObject, 'printerId', PrinterId);
        AddJPropertyToJObject(JObject, 'title', Title);
        AddJPropertyToJObject(JObject, 'contentType', Format(ContentType));
        AddJPropertyToJObject(JObject, 'content', Content);
        AddJPropertyToJObject(JObject, 'source', SourceDescription);
        if Options <> '' then
            AddJPropertyToJObject(JObject, 'options', Options);
        if Authentication <> '' then
            AddJPropertyToJObject(JObject, 'authentication', Authentication);

        TempBlob.Init;
        TempBlob.Blob.CreateOutStream(BodyStream);
        BodyStream.WriteText(JObject.ToString());
        HttpWebRequestMgt.AddBodyBlob(TempBlob);

        Clear(TempBlob);
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseInStream);
        if not HttpWebRequestMgt.GetResponse(ResponseInStream, HttpStatusCode, ResponseHeaders) then begin
            ErrorHandler();
            HttpWebRequestMgt.ProcessFaultXMLResponse('', '', '', '');
            exit(0);
        end;

        ResponseInStream.ReadText(ResponseText);
        if Evaluate(PrintJobId, ResponseText) then;
        exit(PrintJobId);
    end;

    procedure SendPDFStream(PrinterId: Code[20]; var PdfStream: DotNet npNetMemoryStream; Title: Text; SourceDescription: Text; Options: Text)
    begin
        SendPrintJob(PrinterId, 1, StreamToBase64Text(PdfStream), Title, SourceDescription, Options, '');
    end;

    procedure SendRawText(PrinterId: Code[20]; PrintBytes: Text; TargetEncoding: Text; Title: Text; SourceDescription: Text; Options: Text)
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        Base64: Text;
    begin
        Encoding := Encoding.GetEncoding(TargetEncoding);
        Base64 := Convert.ToBase64String(Encoding.GetBytes(PrintBytes));

        SendPrintJob(PrinterId, 3, Base64, Title, SourceDescription, Options, '');
    end;

    local procedure GetJToken(var JObject: DotNet npNetJObject; var JToken: DotNet npNetJToken; Property: Text; WithError: Boolean): Boolean
    var
        JTokenTemp: DotNet npNetJToken;
    begin

        JTokenTemp := JObject.Item(Property);
        if IsNull(JTokenTemp) then begin
            if WithError then
                Error(StrSubstNo(Text001, Property, JObject.ToString()));
            exit(false);
        end else
            JToken := JTokenTemp;

        exit(true);
    end;

    local procedure GetString(var JObject: DotNet npNetJObject; Property: Text; WithError: Boolean): Text
    var
        JToken: DotNet npNetJToken;
    begin
        if GetJToken(JObject, JToken, Property, WithError) then
            exit(JToken.ToString());
        exit('');
    end;

    local procedure BaseUrl(): Text
    begin
        exit('https://api.printnode.com/');
    end;

    local procedure GetBasicAuthInfo(): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        PrintNodeSetup: Record "PrintNode Setup";
    begin
        PrintNodeSetup.Get;
        PrintNodeSetup.TestField("API Key");
        exit('Basic ' + Convert.ToBase64String(Encoding.UTF8.GetBytes(PrintNodeSetup."API Key" + ':')));
    end;

    procedure AddJPropertyToJObject(var JObject: DotNet npNetJObject; propertyName: Text; value: Variant)
    var
        JObject2: DotNet npNetJObject;
        JProperty: DotNet npNetJProperty;
        ValueText: Text;
    begin
        case true of
            value.IsDotNet:
                begin
                    JObject2 := value;
                    JObject.Add(propertyName, JObject2);
                end;
            value.IsInteger,
            value.IsDecimal,
            value.IsBoolean:
                begin
                    JProperty := JProperty.JProperty(propertyName, value);
                    JObject.Add(JProperty);
                end;
            else begin
                    ValueText := Format(value, 0, 9);
                    JProperty := JProperty.JProperty(propertyName, ValueText);
                    JObject.Add(JProperty);
                end;
        end;
    end;

    local procedure StreamToBase64Text(var Stream: DotNet npNetMemoryStream): Text
    var
        Convert: DotNet npNetConvert;
    begin
        exit(Convert.ToBase64String(Stream.ToArray()));
    end;

    local procedure ErrorHandler()
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        WebException: DotNet npNetWebException;
        ResponseInputStream: InStream;
        ErrorText: Text;
        ErrorPart: Text;
        ServiceURL: Text;
    begin
        ErrorText := WebRequestHelper.GetWebResponseError(WebException, ServiceURL);
        if not IsNull(WebException.Response) then begin
            ResponseInputStream := WebException.Response.GetResponseStream;
            while not ResponseInputStream.EOS do begin
                ResponseInputStream.ReadText(ErrorPart);
                ErrorText += '\' + ErrorPart;
            end;
        end;
        Error(ErrorText);
    end;
}

