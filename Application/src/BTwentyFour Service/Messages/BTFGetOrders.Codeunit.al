﻿codeunit 6014644 "NPR BTF GetOrders" implements "NPR BTF IEndPoint", "NPR Nc Import List IUpdate"
{
    Access = Internal;

    var
        EndPointKeyNotSetLbl: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetLbl: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=Service Setup Table Caption;%2=Service EndPoint Table Caption';
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        DefaultFileNameLbl: Label 'GetOrders_%1', Comment = '%1=Current Date and Time';
        OrderNotFoundInContentLbl: Label 'Order or it''s lines not found in the content';
        ErrorLogInfoLbl: Label 'Error encountered. Check out error log for more details.';
        NextEndPointNotFoundLbl: Label 'Next Service EndPoint has not been connected to %1 or it is but it''s not enabled.', Comment = '%1=ServiceEndPoint."EndPoint ID"';

#IF BC17
    [Obsolete('Task Queue module removed from NP Retail. We are now using Job Queue instead.', 'NPR23.0')]
    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    begin
    end;
#ENDIF

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        EndPointIDFilter: Text;
    begin
        ServiceAPI.GetJobQueueParameters(JobQueueEntry, ImportType, EndPointIDFilter);
        ServiceAPI.SendWebRequests(ImportType, JobQueueEntry.RecordId(), EndPointIDFilter);
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.ShowEndPoint(ImportType.Code);
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.ShowErrorLogEntries('', ImportType.Code);
    end;

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup";
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        Request: Codeunit "Temp Blob";

    var
        Response: Codeunit "Temp Blob";

    var
        StatusCode: Integer)
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
    begin
        if not CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint, Response) then
            exit;
        if not CheckServiceEndPoint(ServiceSetup, ServiceEndPoint, Response) then
            exit;
        GetOrders(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Request, Response, StatusCode);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    local procedure GetOrders(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; DummyRequest: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
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
        EndPoint.SendRequest(ServiceSetup, ServiceEndPointForAuth, DummyRequest, Response, StatusCode);
        if not ServiceAPI.IsTokenAvailable(ServiceEndPointForAuth, Response) then
            exit;

        ClearLastError();
        RequestMessage.Method := ServiceEndPoint.GetServiceMethodValueName();
        URI := ServiceApi.GetServiceUrlWithEndpoint(ServiceSetup, ServiceEndPoint, "NPR BTF Messages Class"::order.AsInteger());
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
            StatusCode := 400;
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
    var
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        NextServiceEndPoint: Record "NPR BTF Service EndPoint";
        ServiceSetup: Record "NPR BTF Service Setup";
        NextEndPointRequest: Codeunit "Temp Blob";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        StatusCode: Integer;
        Handled: Boolean;
    begin
        FormatResponse := ServiceEndPoint.Accept;
        if not FormatResponse.GetOrder(Content, TempSalesHeader, TempSalesLine) then
            exit;

        OnProcessImportedContent(Content, ServiceEndPoint, TempSalesHeader, TempSalesLine, NextEndPointRequest, Handled);
        if not Handled then
            exit;

        ServiceSetup.Code := ServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);

        NextServiceEndPoint."Service Code" := ServiceEndPoint."Service Code";
        NextServiceEndPoint."EndPoint ID" := ServiceEndPoint."Next EndPoint ID";
        if (not NextServiceEndPoint.Find()) or (not NextServiceEndPoint.Enabled) then begin
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(NextEndPointNotFoundLbl, ServiceEndPoint."EndPoint ID"), Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), TempSalesHeader.RecordId());
            exit;
        end;

        ServiceAPI.SendWebRequest(ServiceSetup, NextServiceEndPoint, NextEndPointRequest, Response, StatusCode);
        FormatResponse := NextServiceEndPoint.Accept;
        if FormatResponse.FoundErrorInResponse(Response, StatusCode) then begin
            ServiceAPI.LogEndPointError(ServiceSetup, NextServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), TempSalesHeader.RecordId());
            exit;
        end;
        exit(true);
    end;

    procedure ProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        SalesHeader: Record "Sales Header";
        TempSalesLine: Record "Sales Line" temporary;
        ServiceSetup: Record "NPR BTF Service Setup";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        NewSystemId: Guid;
        Handled: Boolean;
    begin
        ServiceSetup.Code := ServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);

        FormatResponse := ServiceEndPoint.Accept;
        FormatResponse.GetOrder(Content, TempSalesHeader, TempSalesLine);

        if (not TempSalesHeader.Find()) or TempSalesLine.IsEmpty() then begin
            FormatResponse.FormatInternalError('internal_business_central_error', OrderNotFoundInContentLbl, Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), SalesHeader.RecordId());
            Message(ErrorLogInfoLbl);
            exit;
        end;

        OnProcessImportedContentOffline(Content, ServiceEndPoint, TempSalesHeader, TempSalesLine, NewSystemId, Handled);
        if not Handled then
            exit;

        SalesHeader.GetBySystemId(NewSystemId);
        SalesHeader.SetRecFilter();
        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    procedure OpenOrder(DocNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := CopyStr(DocNotification.GetData('DocNo'), 1, MaxStrLen(SalesHeader."No."));
        SalesHeader.SetRecFilter();
        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    procedure OpenPostedInvoice(DocNotification: Notification)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader."No." := CopyStr(DocNotification.GetData('DocNo'), 1, MaxStrLen(SalesInvoiceHeader."No."));
        SalesInvoiceHeader.SetRecFilter();
        Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
    end;

    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler"
    begin
        exit("NPR Nc IL Update Handler"::B24GetOrder);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NextEndPointRequest: Codeunit "Temp Blob"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NewSystemId: Guid; var Handled: Boolean)
    begin
    end;
}
