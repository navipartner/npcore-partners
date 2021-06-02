codeunit 6014651 "NPR BTF ProcessMessage" implements "NPR BTF IEndPoint"
{
    var
        EndPointKeyNotSetLbl: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetLbl: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=Service Setup Table Caption;%2=Service EndPoint Table Caption';
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        MessageIdEmptyErr: Label 'Message Id empty';
        MethodNotSupportedErr: Label 'This method is not supported for the current service endpoint';

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
    begin
        if not CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint, Response) then
            exit;
        if not CheckServiceEndPoint(ServiceSetup, ServiceEndPoint, Response) then
            exit;
        ProcessMessage(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Request, Response, StatusCode);
    end;

    local procedure ProcessMessage(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        DummyAuthRequest: Codeunit "Temp BLob";
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        InStr: InStream;
        ResponseText: Text;
        URI: Text;
        ParameterValue: Text;
        MessageId: Text;
        OrdinalValue: Integer;
        Index: Integer;
    begin
        EndPoint := ServiceEndPointForAuth."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPointForAuth, DummyAuthRequest, Response, StatusCode);
        if not ServiceAPI.IsTokenAvailable(ServiceEndPointForAuth, Response) then
            exit;

        if not Request.HasValue() then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(MessageIdEmptyErr), Response);
            exit;
        end;

        Request.CreateInStream(InStr);
        InStr.ReadText(MessageId);

        ClearLastError();
        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        URI := StrSubstNo(ServiceSetup."Service URL" + ServiceEndPoint.Path, MessageId, "NPR BTF Messages Status"::Delivered.AsInteger());
        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');
        Headers.Add('Authorization', StrSubstNo(ServiceAPI.GetBearerTokenLbl(), ServiceAPI.GetTokenFromResponse(ServiceEndPointForAuth, Response)));
        Headers.Add('Subscription-Key', ServiceSetup."Subscription-Key");
        Headers.Add('Username', ServiceSetup.Username);

        OrdinalValue := ServiceSetup.Environment.AsInteger();
        Index := ServiceSetup.Environment.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceSetup.Environment.Names.Get(Index);

        Headers.Add('Environment', ParameterValue);

        OrdinalValue := ServiceEndPoint.Accept.AsInteger();
        Index := ServiceEndPoint.Accept.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceEndPoint.Accept.Names.Get(Index);

        Headers.Add('Accept', ParameterValue);
        Headers.Add('Endpoint-Key', ServiceEndPoint."EndPoint-Key");
        if ServiceSetup.Portal <> '' then
            Headers.Add('Portal', ServiceSetup.Portal);

        Client.Timeout(5000);
        if not Client.Send(RequestMessage, ResponseMessage) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(RequestNotSentLbl, RequestMessage.GetRequestUri()), Response);
            exit;
        end;

        StatusCode := ResponseMessage.HttpStatusCode();
        Content := ResponseMessage.Content();
        Content.ReadAs(ResponseText);
        Clear(Response);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);
    end;

    local procedure CheckServiceSetup(ServiceSetup: Record "NPR BTF Service Setup"; var ServiceEndPointAuth: Record "NPR BTF Service EndPoint"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if (ServiceSetup."Authroization EndPoint ID" = '') or (not ServiceEndPointAuth.Get(ServiceSetup.Code, ServiceSetup."Authroization EndPoint ID")) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(AuthMethodIDNotSetLbl, ServiceSetup.TableCaption(), ServiceEndPointAuth.TableCaption()), Response);
            exit;
        end;
        exit(true);
    end;

    local procedure CheckServiceEndPoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if not ServiceAPI.CheckServiceEndPoint(ServiceEndPoint) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', GetLastErrorText(), Response);
        end;
        if ServiceEndPoint."EndPoint-Key" = '' then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(EndPointKeyNotSetLbl, ServiceEndPoint."EndPoint ID", ServiceSetup.TableCaption(), ServiceEndPoint.TableCaption()), Response);
            exit;
        end;
        exit(true);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"): Boolean
    begin
        //If response of processing should be saved to database, then reimplement this method
        error(MethodNotSupportedErr);
    end;

    procedure ProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        //If response of processing should be saved to database, then reimplement this method
        error(MethodNotSupportedErr);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        //If response of processing should be saved to database, then reimplement this method
        error(MethodNotSupportedErr);
    end;

    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler"
    begin
        //Not necessary for this endpoint
        Error(MethodNotSupportedErr);
    end;
}