codeunit 6014643 "NPR BTF GetToken" implements "NPR BTF IEndPoint"
{
    var
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        ServiceEndPointNotEnabledLbl: Label 'Service EndPoint %1 is not enabled. To be able to consume resource from this enpoint, first enable it (%2 -> %3)', Comment = '%1=ServiceEndPoint."EndPoint ID";%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        DefaultFileNameLbl: Label 'GetToken_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    begin
        ClearLastError();
        if not CheckServiceSetup(ServiceSetup, Response, ServiceEndPoint) then
            exit;
        if not CheckServiceEndPoint(ServiceEndPoint, Response) then
            exit;

        GetToken(ServiceSetup, ServiceEndPoint, Response);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    local procedure GetToken(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ResponseText: Text;
        URI: Text;
        ParameterValue: Text;
        OrdinalValue: Integer;
        Index: Integer;
    begin
        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        URI := ServiceSetup."Service URL" + ServiceEndPoint.Path;
        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');
        Headers.Add('Authorization', ServiceAPI.GetBase64Authorization(ServiceSetup));
        Headers.Add('Subscription-Key', ServiceSetup."Subscription-Key");

        OrdinalValue := ServiceSetup.Environment.AsInteger();
        Index := ServiceSetup.Environment.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceSetup.Environment.Names.Get(Index);

        Headers.Add('Environment', ParameterValue);

        OrdinalValue := ServiceEndPoint.Accept.AsInteger();
        Index := ServiceEndPoint.Accept.Ordinals.IndexOf(OrdinalValue);
        ParameterValue := ServiceEndPoint.Accept.Names.Get(Index);

        Headers.Add('Accept', ParameterValue);
        if ServiceSetup.Portal <> '' then
            Headers.Add('Portal', ServiceSetup.Portal);

        if not Client.Send(RequestMessage, ResponseMessage) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(RequestNotSentLbl, RequestMessage.GetRequestUri()), Response);
            exit;
        end;

        Content := ResponseMessage.Content();
        Content.ReadAs(ResponseText);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);
    end;

    local procedure CheckServiceSetup(ServiceSetup: Record "NPR BTF Service Setup"; var Response: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"): Boolean
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if not ServiceAPI.CheckServiceSetup(ServiceSetup) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', GetLastErrorText(), Response);
            exit;
        end;
        exit(true);
    end;

    local procedure CheckServiceEndPoint(ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        DummyServiceSetup: Record "NPR BTF Service Setup";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        if not ServiceAPI.CheckServiceEndPoint(ServiceEndPoint) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', GetLastErrorText(), Response);
        end;
        if not ServiceEndPoint.Enabled then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError(
                                'internal_business_central_error',
                                StrSubstNo(ServiceEndPointNotEnabledLbl, ServiceEndPoint."EndPoint ID", DummyServiceSetup.TableCaption(), ServiceEndPoint.TableCaption()),
                                Response);
        end;
        exit(true);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        //If token should be saved to specific table, then reimplement this method
    end;
}