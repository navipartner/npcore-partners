codeunit 6014426 "NPR NaviPartner Send SMS" implements "NPR Send SMS"
{
    Access = Internal;
    //Test customer No 70220322
    var
        NoPhoneMessageErr: Label 'SMS Message and Phone No. must be suplied.';
        NotValidPhoneErr: Label '%1 is not a valid phone number.';
        NotAllowedServiceErr: Label 'You are not allowed to use the %1 service.';
        ErrorSendSMS: Label 'SMS wasn''t sent. The service returned:\%1';

    [NonDebuggable]
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)
    var
        SMSSetup: Record "NPR SMS Setup";
        ServiceCalc: Codeunit "NPR Service Calculation";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpCont: HttpContent;
        HttpResp: HttpResponseMessage;
        ForeignPhone: Boolean;
        ServiceCode: Code[20];
    begin
        SMSSetup.Get();

        PhoneNo := DelChr(PhoneNo, '<=>', ' ');

        if (PhoneNo = '') or (Message = '') then
            Error(NoPhoneMessageErr);

        if not ValidatePhone(PhoneNo) then
            Error(NotValidPhoneErr, PhoneNo);

        ForeignPhone := IsForeignNumber(PhoneNo);
        if ForeignPhone then
            ServiceCode := 'SMSUDLAND'
        else
            ServiceCode := 'ECLUBSMS';

        if SenderNo = '' then begin
            SMSSetup.TestField("Default Sender No.");
            SenderNo := SMSSetup."Default Sender No."
        end;

        if ServiceCalc.useService(ServiceCode) then begin
            CreateHttpContent(HttpCont, SenderNo, PhoneNo, Message);
            if not SendHttpRequest(HttpResp, HttpCont, AzureKeyVaultMgt.GetAzureKeyVaultSecret('SMSMgtHTTPRequestUrl'), 'POST') then
                Error(ErrorSendSMS, GetLastErrorText);
        end else
            Error(NotAllowedServiceErr, ServiceCode);
    end;

    local procedure IsForeignNumber(var PhoneNo: Text): Boolean
    var
        SMSSetup: Record "NPR SMS Setup";
    begin
        SMSSetup.Get();
        if SMSSetup."Domestic Phone Prefix" = '' then
            SMSSetup."Domestic Phone Prefix" := '+45';

        if SMSSetup."Domestic Phone Prefix"[1] = '0' then
            SMSSetup."Domestic Phone Prefix"[1] := '+';

        if not (CopyStr(PhoneNo, 1, 1) = '+') and (CopyStr(PhoneNo, 1, 3) <> SMSSetup."Domestic Phone Prefix") then
            if CopyStr(PhoneNo, 1, 3) <> SMSSetup."Domestic Phone Prefix" then
                PhoneNo := SMSSetup."Domestic Phone Prefix" + PhoneNo;

        exit((CopyStr(PhoneNo, 1, 1) = '+') and (CopyStr(PhoneNo, 1, 3) <> SMSSetup."Domestic Phone Prefix"));
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure SendHttpRequest(var HttpRespMessage: HttpResponseMessage; HttpCont: HttpContent; Uri: Text; Method: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpClnt: HttpClient;
        RequestHeaders: HttpHeaders;
        HttpReqMessage: HttpRequestMessage;
        Content: Text;
    begin
        HttpReqMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Basic ' + GetBasicAuthInfo(AzureKeyVaultMgt.GetAzureKeyVaultSecret('SMSMgtUsername'), AzureKeyVaultMgt.GetAzureKeyVaultSecret('SMSMgtPassword')));
        HttpReqMessage.Method(Method);
        HttpCont.ReadAs(Content);
        if Content <> '' then
            HttpReqMessage.Content := HttpCont;
        HttpClnt.SetBaseAddress(Uri);
        HttpClnt.Send(HttpReqMessage, HttpRespMessage);

        if not HttpRespMessage.IsSuccessStatusCode then
            Error('%1 - %2',
                HttpRespMessage.HttpStatusCode, HttpRespMessage.ReasonPhrase);

    end;

    [NonDebuggable]
    local procedure CreateHttpContent(var HttpCont: HttpContent; Sender: Text; Destination: Text; SMSMessage: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ContentHeaders: HttpHeaders;
        JsonObj: JsonObject;
        JsonMsg: Text;
    begin
        JsonObj.Add('source', Sender);
        JsonObj.Add('destination', Destination);
        JsonObj.Add('userData', SMSMessage);
        JsonObj.Add('platformId', 'COOL');
        JsonObj.Add('platformPartnerId', AzureKeyVaultMgt.GetAzureKeyVaultSecret('SMSMgtPlatformPartnerId'));
        JsonObj.Add('useDeliveryReport', 'false');
        JsonObj.WriteTo(JsonMsg);

        HttpCont.WriteFrom(JsonMsg);
        HttpCont.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json;charset=utf-8');
    end;

    [NonDebuggable]
    local procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        UserPassLbl: Label '%1:%2', Locked = true;
    begin
        exit(Base64Convert.ToBase64(StrSubstNo(UserPassLbl, Username, Password)))
    end;

    local procedure ValidatePhone(PhoneNo: Text): Boolean;
    begin
        exit(DelChr(PhoneNo, '<=>', '+1234567890 ') = '');
    end;


}
