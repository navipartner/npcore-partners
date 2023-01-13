codeunit 6059993 "NPR HL Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        HLSetup: Record "NPR HL Integration Setup";
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";

    //#if Debug
    trigger OnRun()
    begin
        InvokeGetHLMemberListRequest();
    end;

    procedure InvokeGetHLMemberListRequest()
    var
        NcTask: Record "NPR Nc Task";
        ResponseText: Text;
    begin
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'GET', StrSubstNo('%1/%2', GetHLMembersUrl(), 'c7d9d1e0-4de5-423b-9a3e-6f983a28f542'));
        Message(ResponseText);
    end;
    //#endif

    [TryFunction]
    procedure InvokeGetMemberListInfo(var ResponseJToken: JsonToken)
    begin
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', GetHLMemberListUrl()));
    end;

    [TryFunction]
    procedure InvokeGetHLMemberByID(HeyLoyaltyID: Text; var ResponseJToken: JsonToken)
    begin
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', StrSubstNo('%1/%2', GetHLMembersUrl(), HeyLoyaltyID)));
    end;

    [TryFunction]
    procedure InvokeGetHLMemberByEmail(HLMember: Record "NPR HL HeyLoyalty Member"; var ResponseJToken: JsonToken)
    var
        TypeHelper: Codeunit "Type Helper";
        EmailAddress: Text;
        UrlPlaceholderLbl: Label '%1?filter[email][eq][]=%2', Locked = true;
    begin
        HLMember.TestField("E-mail Address");
        EmailAddress := HLMember."E-Mail Address";
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', StrSubstNo(UrlPlaceholderLbl, GetHLMembersUrl(), TypeHelper.UrlEncode(EmailAddress))));
    end;

    [TryFunction]
    procedure InvokeMemberCreateRequest(var NcTask: Record "NPR Nc Task"; UrlQueryString: Text; var HeyLoyaltyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1', UrlQueryString);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'POST', Url);
        HeyLoyaltyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure InvokeMemberUpdateRequest(var NcTask: Record "NPR Nc Task"; HeyLoyaltyMemberID: Text[50]; UrlQueryString: Text; var HeyLoyaltyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1%2', HeyLoyaltyMemberID, UrlQueryString);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'PATCH', Url);
        HeyLoyaltyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure InvokeMemberDeleteRequest(var NcTask: Record "NPR Nc Task"; HeyLoyaltyMemberID: Text[50])
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1', HeyLoyaltyMemberID);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'DELETE', Url);
    end;

    local procedure SendHeyLoyaltyRequest(RestMethod: text; Url: Text) ResponseText: Text
    var
        NcTask: Record "NPR Nc Task";
    begin
        Clear(NcTask);
        ResponseText := SendHeyLoyaltyRequest(NcTask, RestMethod, Url);
    end;

    local procedure SendHeyLoyaltyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text) ResponseText: Text
    begin
        if not TrySendHeyLoyaltyRequest(NcTask, RestMethod, Url, ResponseText) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TrySendHeyLoyaltyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        DateString: Text;
        EmptyResponseTxt: Label '{}', Locked = true;
    begin
        ClearLastError();

        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method(RestMethod);
        RequestMsg.GetHeaders(Headers);
        Headers.Add('Authorization', 'Basic ' + GetAuthSignature(DateString));
        Headers.Add('X-Request-Timestamp', DateString);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');

        if not Client.Send(RequestMsg, ResponseMsg) then
            Error(GetLastErrorText);

        SaveResponse(NcTask, ResponseMsg);

        if not ResponseMsg.Content.ReadAs(ResponseText) then
            ResponseText := '';

        if not ResponseMsg.IsSuccessStatusCode() then
            Error('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase, ResponseText);

        if ResponseText = '' then
            ResponseText := EmptyResponseTxt;
    end;

    procedure GetAuthSignature(var DateString: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        TextEnc: TextEncoding;
        AuthSignature: Text;
        Hash: Text;
    begin
        HLSetup.GetRecordOnce(false);
        DateString := Format(CurrentDateTime, 0, 9);

        Hash := CryptoMgt.GenerateHash(DateString, HLSetup."HeyLoyalty Api Secret", HashAlgorithmType::SHA256);
        Hash := Base64Convert.ToBase64(LowerCase(DelChr(Hash, '=', '-')), TextEnc::UTF8);
        AuthSignature := Base64Convert.ToBase64(StrSubstNo('%1:%2', HLSetup."HeyLoyalty Api Key", Hash), TextEnc::UTF8);
        exit(AuthSignature);
    end;

    local procedure SaveResponse(var NcTask: Record "NPR Nc Task"; var ResponseMsg: HttpResponseMessage)
    var
        Content: HttpContent;
        InStr: InStream;
        OutStr: OutStream;
    begin
        Content := ResponseMsg.Content();

        clear(NcTask.Response);
        NcTask.Response.CreateInStream(InStr);
        Content.ReadAs(InStr);

        NcTask.Response.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    local procedure GetHLMemberListUrl(): Text
    begin
        HLSetup.GetRecordOnce(false);
        HLSetup.TestField("HeyLoyalty Api Url");
        HLSetup.TestField("HeyLoyalty Member List Id");
        exit(HLSetup."HeyLoyalty Api Url" + '/lists/' + HLSetup."HeyLoyalty Member List Id");
    end;

    local procedure GetHLMembersUrl(): Text
    begin
        exit(GetHLMemberListUrl() + '/members');
    end;

    procedure RegisterWebhookListeners()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
        ServiceNameTok: Label 'heyloyalty_services', Locked = true, MaxLength = 240;
    begin
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR HL HeyLoyalty Webservice", ServiceNameTok, true);
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR HL Integration Area"): Boolean
    var
        AreaIsEnabled: Boolean;
        Handled: Boolean;
    begin
        HLIntegrationEvents.OnCheckIfIntegrationAreaIsEnabled(IntegrationArea, AreaIsEnabled, Handled);
        if Handled then
            exit(AreaIsEnabled);

        HLSetup.GetRecordOnce(false);
        case IntegrationArea of
            IntegrationArea::" ":
                exit(HLSetup."Enable Integration");
            IntegrationArea::Members:
                exit(HLSetup."Member Integration");
        end;
    end;

    procedure IsIntegratedTable(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer): Boolean
    var
        Handled: Boolean;
        TableIsIntegrated: Boolean;
    begin
        HLIntegrationEvents.OnCheckIfIsIntegratedTable(IntegrationArea, TableId, TableIsIntegrated, Handled);
        if Handled then
            exit(TableIsIntegrated);

        case IntegrationArea of
            IntegrationArea::Members:
                TableIsIntegrated :=
                    TableId in
                        [Database::"NPR MM Member",
                         Database::"NPR MM Membership",
                         Database::"NPR MM Membership Role",
                         Database::"NPR GDPR Consent Log"];
            else
                TableIsIntegrated := false;
        end;

        exit(TableIsIntegrated);
    end;

    procedure IsInstantTaskEnqueue(): Boolean
    begin
        HLSetup.GetRecordOnce(false);
        exit(HLSetup."Instant Task Enqueue");
    end;

    procedure ConfirmInstantTaskEnqueue(): Boolean
    var
        AllowedOnlyInTestEnvMsg: Label 'This mode is not only recommended on live environments, as it may lead to incorrect data being sent to HeyLoyalty.\Are you sure you want to enable it?';
    begin
        exit(Confirm(AllowedOnlyInTestEnvMsg, false));
    end;

    procedure HeyLoyaltyCode(): Code[10]
    var
        HeyLoyaltyTaskProcessorCode: Label 'HEYLOY', Locked = true, MaxLength = 10;
    begin
        exit(HeyLoyaltyTaskProcessorCode);
    end;

    procedure NonTempParameterError()
    var
        ErroMsgWithCallStackLbl: Label '%1\Call stack:\%2', Comment = '%1 - error message, %2 - error call stack';
    begin
        ClearLastError();
        RaiseNonTempParameterError();
        Error(ErroMsgWithCallStackLbl, GetLastErrorText(), GetLastErrorCallStack);
    end;

    [TryFunction]
    local procedure RaiseNonTempParameterError()
    var
        NotTempErr: Label 'Function call on a non-temporary record variable. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        Error(NotTempErr);
    end;

    procedure FormatAsHLDateTime(DateIn: Date): Text
    begin
        if DateIn = 0D then
            exit('');
        exit(FormatAsHLDateTime(CreateDateTime(DateIn, 0T)));
    end;

    procedure FormatAsHLDateTime(DateTimeIn: DateTime): Text
    begin
        if DateTimeIn = 0DT then
            exit('');
        exit(Format(DateTimeIn, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;

    procedure HLMembershipCodeFieldID(): Text[50]
    begin
        HLSetup.GetRecordOnce(false);
        exit(HLSetup."Membership HL Field ID");
    end;
}