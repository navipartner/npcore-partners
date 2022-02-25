codeunit 6014445 "NPR DE Fiskaly Communication"
{
    Access = Internal;
    [TryFunction]
    procedure SendDocument(var DeAuditAuxPar: Record "NPR DE POS Audit Log Aux. Info"; DocumentJsonObject: JsonObject; var ResponseJsonObject: JsonObject; var DEAuditSetupPar: Record "NPR DE Audit Setup")
    var
        POSEntry: Record "NPR POS Entry";
        StrOut: OutStream;
    begin
        POSEntry.Get(DeAuditAuxPar."POS Entry No.");
        PosUnitAuxDE.Get(POSEntry."POS Unit No.");
        GetContext();
        TransactionID := Format(DeAuditAuxPar."Transaction ID", 0, 4);
        if DeAuditAuxPar."Fiscalization Status" = DeAuditAuxPar."Fiscalization Status"::"Not Fiscalized" then begin
            StartTransaction();
            DeAuditAuxPar."Fiscalization Status" := DeAuditAuxPar."Fiscalization Status"::"Transaction Started";
            DeAuditAuxPar."Last Revision" := LastRevision;
        end;

        DEAuditSetupPar."Last Fiskaly Context".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(LastContext);

        if LastRevision = '' then
            LastRevision := DeAuditAuxPar."Last Revision";

        ResponseJsonObject := EndTransaction(DocumentJsonObject);
        DeAuditAuxPar."Last Revision" := LastRevision;
        Clear(StrOut);
        DEAuditSetupPar."Last Fiskaly Context".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(LastContext);
    end;

    [NonDebuggable]
    local procedure GetContext()
    var
        ParamsJson: JsonObject;
        ResponseObject: JsonObject;
        StreamIn: InStream;
    begin
        DEAuditSetup.Get();
        DEAuditSetup.CalcFields("Last Fiskaly Context");
        if DEAuditSetup."Last Fiskaly Context".HasValue then begin
            DEAuditSetup."Last Fiskaly Context".CreateInStream(StreamIn, TextEncoding::UTF8);
            StreamIn.ReadText(LastContext);
            exit;
        end;

        ParamsJson.Add('api_key', DEAuditSetup.GetApiKey());
        ParamsJson.Add('api_secret', DEAuditSetup.GetApiSecret());
        ParamsJson.Add('base_url', DEAuditSetup."Api URL");

        SendRequest(CreateRequestBody(ParamsJson, 'create-context'), ResponseObject);
    end;

    local procedure StartTransaction()
    var
        RequestObject: JsonObject;
        HeadersObject: JsonObject;
        RequestBody: JsonObject;
        ResponseJson: JsonObject;
        ParamsJson: JsonObject;
        BodyToken: JsonToken;
        Base64Body: Text;
        BodyTxt: Text;
    begin
        RequestBody.Add('state', 'ACTIVE');
        RequestBody.Add('client_id', Format(PosUnitAuxDE."Client ID", 0, 4));
        RequestBody.WriteTo(BodyTxt);
        Base64Body := Base64Convert.ToBase64(BodyTxt, TextEncoding::UTF8);

        HeadersObject.Add('Content-Type', 'application/json');

        RequestObject.Add('method', 'PUT');
        RequestObject.Add('path', '/tss/' + Format(PosUnitAuxDE."TSS ID", 0, 4) + '/tx/' + TransactionID);
        RequestObject.Add('headers', HeadersObject);
        RequestObject.Add('body', Base64Body);

        ParamsJson.Add('request', RequestObject);
        ParamsJson.Add('context', LastContext);

        SendRequest(CreateRequestBody(ParamsJson, 'request'), ResponseJson);
        ResponseJson.SelectToken('$.result.response.body', BodyToken);
        BodyTxt := Base64Convert.FromBase64(BodyToken.AsValue().AsText());
        ResponseJson.ReadFrom(BodyTxt);

        ResponseJson.SelectToken('latest_revision', LastRevisionToken);
        LastRevision := CopyStr(LastRevisionToken.AsValue().AsText(), 1, MaxStrLen(LastRevision));
    end;

    local procedure EndTransaction(DocumentJsonObjectPar: JsonObject) ResponseJson: JsonObject
    var
        RequestObject: JsonObject;
        HeadersObject: JsonObject;
        ParamsJson: JsonObject;
        QueryObject: JsonObject;
        BodyToken: JsonToken;
        Base64Body: Text;
        BodyTxt: Text;
    begin
        DocumentJsonObjectPar.WriteTo(BodyTxt);
        Base64Body := Base64Convert.ToBase64(BodyTxt, TextEncoding::UTF8);

        QueryObject.Add('last_revision', LastRevision);
        HeadersObject.Add('Content-Type', 'application/json');

        RequestObject.Add('method', 'PUT');
        RequestObject.Add('path', '/tss/' + Format(PosUnitAuxDE."TSS ID", 0, 4) + '/tx/' + TransactionID);
        RequestObject.Add('query', QueryObject);
        RequestObject.Add('headers', HeadersObject);
        RequestObject.Add('body', Base64Body);

        ParamsJson.Add('request', RequestObject);
        ParamsJson.Add('context', LastContext);

        SendRequest(CreateRequestBody(ParamsJson, 'request'), ResponseJson);
        ResponseJson.SelectToken('$.result.response.body', BodyToken);
        BodyTxt := Base64Convert.FromBase64(BodyToken.AsValue().AsText());
        ResponseJson.ReadFrom(BodyTxt);

        ResponseJson.SelectToken('latest_revision', LastRevisionToken);
        LastRevision := CopyStr(LastRevisionToken.AsValue().AsText(), 1, MaxStrLen(LastRevision));
    end;

    procedure CreateTSSClient(PosUnitAuxDEPar: Record "NPR DE POS Unit Aux. Info")
    var
        StrOut: OutStream;
    begin
        PosUnitAuxDE := PosUnitAuxDEPar;
        GetContext();

        CreateTSS();
        CreateClient();

        Clear(DEAuditSetup."Last Fiskaly Context");
        DEAuditSetup."Last Fiskaly Context".CreateOutStream(StrOut, TextEncoding::UTF8);
        StrOut.Write(LastContext);
        DEAuditSetup.Modify();
    end;

    local procedure CreateTSS()
    var
        RequestObject: JsonObject;
        HeadersObject: JsonObject;
        RequestBody: JsonObject;
        ResponseJson: JsonObject;
        ParamsJson: JsonObject;
        Base64Body: Text;
        BodyTxt: Text;
    begin
        PosUnitAuxDE."TSS ID" := CreateGuid();

        RequestBody.Add('description', 'TSS created for Company: ' + CompanyName + ', and POS Unit No.: ' + PosUnitAuxDE."POS Unit No.");
        RequestBody.Add('state', 'INITIALIZED');
        RequestBody.WriteTo(BodyTxt);
        Base64Body := Base64Convert.ToBase64(BodyTxt, TextEncoding::UTF8);

        HeadersObject.Add('Content-Type', 'application/json');

        RequestObject.Add('method', 'PUT');
        RequestObject.Add('path', '/tss/' + Format(PosUnitAuxDE."TSS ID", 0, 4));
        RequestObject.Add('headers', HeadersObject);
        RequestObject.Add('body', Base64Body);

        ParamsJson.Add('request', RequestObject);
        ParamsJson.Add('context', LastContext);

        SendRequest(CreateRequestBody(ParamsJson, 'request'), ResponseJson);
        PosUnitAuxDE.Modify();
    end;

    local procedure CreateClient()
    var
        RequestObject: JsonObject;
        HeadersObject: JsonObject;
        RequestBody: JsonObject;
        ResponseJson: JsonObject;
        ParamsJson: JsonObject;
        Base64Body: Text;
        BodyTxt: Text;
    begin
        PosUnitAuxDE."Client ID" := CreateGuid();


        RequestBody.Add('serial_number', PosUnitAuxDE."Serial Number");
        RequestBody.WriteTo(BodyTxt);
        Base64Body := Base64Convert.ToBase64(BodyTxt, TextEncoding::UTF8);

        HeadersObject.Add('Content-Type', 'application/json');

        RequestObject.Add('method', 'PUT');
        RequestObject.Add('path', '/tss/' + Format(PosUnitAuxDE."TSS ID", 0, 4) + '/client/' + Format(PosUnitAuxDE."Client ID", 0, 4));
        RequestObject.Add('headers', HeadersObject);
        RequestObject.Add('body', Base64Body);

        ParamsJson.Add('request', RequestObject);
        ParamsJson.Add('context', LastContext);

        SendRequest(CreateRequestBody(ParamsJson, 'request'), ResponseJson);
        PosUnitAuxDE.Modify();
    end;

    procedure GetTransaction(TssId: Text; TxId: Text): JsonObject
    var
        RequestObject: JsonObject;
        ResponseJson: JsonObject;
        ParamsJson: JsonObject;
        BodyToken: JsonToken;
        BodyTxt: Text;
    begin
        GetContext();
        DEAuditSetup.GET();

        RequestObject.Add('method', 'GET');
        RequestObject.Add('path', '/tss/' + TssId + '/tx/' + TxId);

        ParamsJson.Add('request', RequestObject);
        ParamsJson.Add('context', LastContext);

        SendRequest(CreateRequestBody(ParamsJson, 'request'), ResponseJson);
        ResponseJson.SelectToken('$.result.response.body', BodyToken);
        BodyTxt := Base64Convert.FromBase64(BodyToken.AsValue().AsText());
        ResponseJson.ReadFrom(BodyTxt);
        EXIT(ResponseJson);
    end;

    [NonDebuggable]
    local procedure SendRequest(RequestBodyPar: JsonObject; ResponseJsonPar: JsonObject)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ContextToken: JsonToken;
        RequestBodyTxt: Text;
        Response: Text;
    begin
        RequestBodyPar.WriteTo(RequestBodyTxt);
        Content.WriteFrom(RequestBodyTxt);

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpFiskalyAPIURL'));
        HttpWebRequest.Method := 'POST';

        Client.Send(HttpWebRequest, HttpWebResponse);

        HttpWebResponse.Content.ReadAs(Response);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        ResponseJsonPar.ReadFrom(Response);
        CheckForErrors(ResponseJsonPar, RequestBodyTxt);
        ResponseJsonPar.SelectToken('$.result.context', ContextToken);
        LastContext := ContextToken.AsValue().AsText();
    end;

    local procedure CreateRequestBody(ParamsJson: JsonObject; MethodPar: Text) RequestBody: JsonObject
    var
        IdInt: BigInteger;
    begin
        Evaluate(IdInt, Format(CurrentDateTime, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'));
        RequestBody.Add('jsonrpc', '2.0');
        RequestBody.Add('method', MethodPar);
        RequestBody.Add('params', ParamsJson);
        RequestBody.Add('id', IdInt);
    end;

    local procedure CheckForErrors(ResponseJsonPar: JsonObject; RequestJsonPar: Text)
    var
        ErrorToken: JsonToken;
        FiskalyCodeToken: JsonToken;
        FiskalyMessageToken: JsonToken;
        HTTPCodeToken: JsonToken;
        HTTPMessageToken: JsonToken;
        ErrorMessage: Text;
        FiskalyErrorCodeLbl: Label 'Fiskaly Error Code: ';
        FiskalyErrorMessageLbl: Label 'Fiskaly Error Message: ';
        HTTPErrorCodeLbl: Label 'HTTP Error Code: ';
        HTTPErrorMessageLbl: Label 'HTTP Error Message: ';
        RequestJsonLbl: Label 'Request Json:';
    begin
        if not ResponseJsonPar.SelectToken('error', ErrorToken) then
            exit;

        if ErrorToken.SelectToken('code', FiskalyCodeToken) then
            ErrorMessage := FiskalyErrorCodeLbl + Format(FiskalyCodeToken.AsValue().AsInteger());
        if ErrorToken.SelectToken('message', FiskalyMessageToken) then
            ErrorMessage += '; ' + FiskalyErrorMessageLbl + FiskalyMessageToken.AsValue().AsText();
        if ErrorToken.SelectToken('$.data.response.status', HTTPCodeToken) then
            ErrorMessage += '; ' + HTTPErrorCodeLbl + Format(HTTPCodeToken.AsValue().AsInteger());
        if ErrorToken.SelectToken('$.data.response.body', HTTPMessageToken) then
            ErrorMessage += '; ' + HTTPErrorMessageLbl + Base64Convert.FromBase64(HTTPMessageToken.AsValue().AsText());

        ErrorMessage += '\' + RequestJsonLbl + '\';
        Error('%1\%2', ErrorMessage, RequestJsonPar);
    end;

    [TryFunction]
    internal procedure SendDSFINVK(DSFINVKJson: JsonObject; var ResponseJsonPar: JsonObject; DEAuditSetupPar: Record "NPR DE Audit Setup"; Method: Text; URLFunction: Text; AccessToken: Text)
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestBodyTxt: Text;
        Response: Text;
    begin
        if Method <> 'GET' then begin
            DSFINVKJson.WriteTo(RequestBodyTxt);
            Content.WriteFrom(RequestBodyTxt);

            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            HttpWebRequest.Content(Content);
        end;
        HttpWebRequest.SetRequestUri(DEAuditSetupPar."DSFINVK Api URL" + URLFunction);
        HttpWebRequest.Method := Method;

        if AccessToken <> '' then begin
            HttpWebRequest.GetHeaders(Headers);
            Headers.Add('Authorization', StrSubstNo(BearerToken, AccessToken));
        end;

        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        ResponseJsonPar.ReadFrom(Response);
    end;



    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info";
        Base64Convert: Codeunit "Base64 Convert";
        LastRevisionToken: JsonToken;
        TransactionID: Text;
        LastContext: Text;
        LastRevision: Text[5];
        BearerToken: Label 'Bearer %1', Locked = true;
}
