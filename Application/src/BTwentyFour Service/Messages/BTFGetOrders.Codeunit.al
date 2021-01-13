codeunit 6014644 "NPR BTF GetOrders" implements "NPR BTF IEndPoint"
{
    var
        EndPointKeyNotSetLbl: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetLbl: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=Service Setup Table Caption;%2=Service EndPoint Table Caption';
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        DefaultFileNameLbl: Label 'GetOrders_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
    begin
        if not CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint, Response) then
            exit;
        if not CheckServiceEndPoint(ServiceSetup, ServiceEndPoint, Response) then
            exit;
        GetOrders(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Response);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    local procedure GetOrders(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        EndPoint: Interface "NPR BTF IEndPoint";
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
        EndPoint := ServiceEndPointForAuth."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPointForAuth, Response);
        if not ServiceAPI.IsTokenAvailable(ServiceEndPointForAuth, Response) then
            exit;

        ClearLastError();
        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        URI := StrSubstNo(ServiceSetup."Service URL" + ServiceEndPoint.Path + '/?classid=%1', "NPR BTF Messages Class"::order.AsInteger());
        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');
        Headers.Add('Authorization', StrSubstNo('bearer %1', ServiceAPI.GetTokenFromResponse(ServiceEndPointForAuth, Response)));
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

        if not Client.Send(RequestMessage, ResponseMessage) then begin
            FormatResponse := ServiceEndPoint.Accept;
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(RequestNotSentLbl, RequestMessage.GetRequestUri()), Response);
            exit;
        end;

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

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
        ServiceSetup: Record "NPR BTF Service Setup";
        TempSalesHeader: Record "Sales Header" temporary;
        SalesHeader: Record "Sales Header";
        TempSalesLine: Record "Sales Line" temporary;
        GetMessageBody: codeunit "NPR BTF GetMessage Body";
        Response: Codeunit "Temp Blob";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        ResourcesUri: List of [Text];
        ResourceUri: Text;
    begin
        GetMessageBody.GetResourcesUri(Content, ServiceEndPoint, ResourcesUri, ServiceSetup, ServiceEndPointForAuth, FormatResponse);
        foreach ResourceUri in ResourcesUri do begin
            GetMessageBody.GetMessageBody(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Response, ResourceUri);
            if FormatResponse.FoundErrorInResponse(Response) then begin
                error(FormatResponse.GetErrorDescription(Response), ServiceEndPoint.RecordId());
            end else begin
                if FormatResponse.GetDocument(Content, TempSalesHeader, TempSalesLine) then begin
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                    GetMessageBody.ValidateDocument(SalesHeader, TempSalesHeader, TempSalesLine);
                end;
            end;
        end;
    end;
}