codeunit 6151220 "NPR PrintNode API Mgt."
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created


    trigger OnRun()
    begin
    end;

    var
        TitleDefaultTxt: Label 'NPRetail - Printjob';
        SourceDefaultTxt: Label 'NPRetail';
        ServiceResultTxt: Label 'Service Returned %1 %2\%3';

    procedure TestConnection(ShowMessage: Boolean): Boolean
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        JSONManagement: Codeunit "JSON Management";
        ResponseText: Text;
        RegisteredEmail: Variant;
        RegistreredEmailTxt: Label 'Account registered to email %1';

    begin
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', GetBasicAuthInfo());
        Client.Get(BaseUrl() + 'whoami', ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            if ShowMessage then begin
                ResponseMessage.Content().ReadAs(ResponseText);
                Message(StrSubstNo(ServiceResultTxt, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ResponseText));
            end;
            exit(false);
        end;

        if ShowMessage then begin
            ResponseMessage.Content().ReadAs(ResponseText);
            if JSONManagement.InitializeFromString(ResponseText) then
                JSONManagement.GetPropertyValueByName('email', RegisteredEmail);

            if Format(RegisteredEmail) <> '' then
                Message(StrSubstNo(ServiceResultTxt, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, StrSubstNo(RegistreredEmailTxt, RegisteredEmail)))
            else
                Message(StrSubstNo(ServiceResultTxt, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ''));
        end;
        exit(true);
    end;

    procedure GetPrinters(var JArray: JsonArray): Boolean
    begin
        exit(TryGetPrinters('', JArray));
    end;

    procedure GetPrinterInfo(PrinterId: Text; var JArray: JsonArray): Boolean
    begin
        exit(TryGetPrinters(PrinterId, JArray));
    end;

    [TryFunction]
    local procedure TryGetPrinters(PrinterId: Text; var JArray: JsonArray)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', GetBasicAuthInfo());
        if PrinterId <> '' then
            Client.Get(BaseUrl() + 'printers/' + PrinterId, ResponseMessage)
        else
            Client.Get(BaseUrl() + 'printers', ResponseMessage);

        ResponseMessage.Content().ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode then
            Error(StrSubstNo(ServiceResultTxt, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ResponseText));

        JArray.ReadFrom(ResponseText);
    end;

    procedure SendPrintJob(PrinterId: Code[20]; ContentType: Option pdf_uri,pdf_base64,raw_uri,raw_base64; DataContent: Text; Title: Text; SourceDescription: Text; Options: Text; Authentication: Text) PrintJobId: Integer
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Object: JsonObject;
        OptionsObject: JsonObject;
        JsonString: Text;
        ResponseText: Text;
    begin

        if Title = '' then
            Title := TitleDefaultTxt;
        if SourceDescription = '' then
            SourceDescription := SourceDefaultTxt;

        Object.Add('printerId', PrinterId);
        Object.Add('title', Title);
        Object.Add('contentType', Format(ContentType));
        Object.Add('content', DataContent);
        Object.Add('source', SourceDescription);
        if Options <> '' then
            if OptionsObject.ReadFrom(Options) then
                Object.Add('options', OptionsObject)
            else
                Object.Add('options', Options);
        if Authentication <> '' then
            Object.Add('authentication', Authentication);
        Object.WriteTo(JsonString);

        Content.WriteFrom(JsonString);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Headers := Client.DefaultRequestHeaders();
        Headers.Add('Authorization', GetBasicAuthInfo());

        Client.Post(BaseUrl() + 'printjobs', Content, ResponseMessage);

        ResponseMessage.Content().ReadAs(ResponseText);

        if not ResponseMessage.IsSuccessStatusCode then begin
            Message(StrSubstNo(ServiceResultTxt, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase, ResponseText));
            exit(0);
        end;
        if Evaluate(PrintJobId, ResponseText) then;
        exit(PrintJobId);
    end;

    procedure SendPDFStream(PrinterId: Code[20]; var TempBlob: Codeunit "Temp Blob"; Title: Text; SourceDescription: Text; Options: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
        PrintBytes: Text;
    begin
        TempBlob.CreateInStream(IStream);
        PrintBytes := Base64Convert.ToBase64(IStream);
        SendPrintJob(PrinterId, 1, PrintBytes, Title, SourceDescription, Options, '');
    end;

    procedure SendRawText(PrinterId: Code[20]; PrintBytes: Text; TargetCodePage: Integer; Title: Text; SourceDescription: Text; Options: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        PrintBytes := Base64Convert.ToBase64(PrintBytes, TextEncoding::Windows, TargetCodePage);
        SendPrintJob(PrinterId, 3, PrintBytes, Title, SourceDescription, Options, '');
    end;

    local procedure BaseUrl(): Text
    begin
        exit('https://api.printnode.com/');
    end;

    local procedure GetBasicAuthInfo(): Text
    var
        PrintNodeSetup: Record "NPR PrintNode Setup";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
    begin
        PrintNodeSetup.Get;
        PrintNodeSetup.TestField("API Key");
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(PrintNodeSetup."API Key" + ':');
        TempBlob.CreateInStream(IStream);
        exit('Basic ' + Base64Convert.ToBase64(IStream));
    end;
}

