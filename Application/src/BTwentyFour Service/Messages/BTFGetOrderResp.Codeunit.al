codeunit 6014650 "NPR BTF GetOrderResp" implements "NPR BTF IEndPoint", "NPR Nc Import List IUpdate"
{
    var
        EndPointKeyNotSetLbl: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetLbl: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=Service Setup Table Caption;%2=Service EndPoint Table Caption';
        RequestNotSentLbl: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        DefaultFileNameLbl: Label 'GetOrderResp_%1', Comment = '%1=Current Date and Time';
        OrderResponseNotFoundInContentLbl: Label 'Order Response or it''s lines not found in the content';
        ErrorLogInfoLbl: Label 'Error encountered. Check out error log for more details.';
        OrderResponseNotDeliveredLbl: Label 'Order Response %1 has been imported successfully. However, due to offline import, this order response is still available in a B24 queue under the messageId %2 and has to be set as a delivered.', Comment = '%1=Order No;%2=Message ID';
        MessageIdNotFoundLbl: Label 'Message Id not found in Sales Order %1 under the %2.', Comment = '%1="Sales Header".No.;%2="Sales Header".FieldName("Your Reference")';
        DocAlreadyCreatedLbl: Label 'Document that you are trying to import has been already created.';
        DocAlreadyPostedLbl: Label 'Document that you are trying to import has been already posted.';
        DocCreatedInLiveEnvLbl: Label 'Since this is live environment, this document has to be removed from B24 queue by sending message id of this document to B24 portal. Message ID could be found under the %1 or under the property messageId in the original content downloaded from B24.', Comment = '%1="Sales Header".FieldName("Your Reference")';
        OpenCardLbl: Label 'Open';

    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.SendWebRequests(ImportType, TaskLine.RecordID(), '');
    end;

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

    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        ServiceEndPointForAuth: Record "NPR BTF Service EndPoint";
    begin
        if not CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint, Response) then
            exit;
        if not CheckServiceEndPoint(ServiceSetup, ServiceEndPoint, Response) then
            exit;
        GetOrderResponse(ServiceSetup, ServiceEndPoint, ServiceEndPointForAuth, Request, Response, StatusCode);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    local procedure GetOrderResponse(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; DummyRequest: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
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
        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        URI := StrSubstNo(ServiceSetup."Service URL" + ServiceEndPoint.Path + '?classid=%1', "NPR BTF Messages Class"::orderresponse.AsInteger());
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
        SalesHeader: Record "Sales Header";
        TempSalesLine: Record "Sales Line" temporary;
        NextServiceEndPoint: Record "NPR BTF Service EndPoint";
        ServiceSetup: Record "NPR BTF Service Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Request: Codeunit "Temp Blob";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        OutStr: OutStream;
        StatusCode: Integer;
        MessageId: Text;
    begin
        FormatResponse := ServiceEndPoint.Accept;
        FormatResponse.GetOrderResp(Content, TempSalesHeader, TempSalesLine);

        if (not TempSalesHeader.Find()) or TempSalesLine.IsEmpty() then begin
            FormatResponse.FormatInternalError('internal_business_central_error', OrderResponseNotFoundInContentLbl, Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), SalesHeader.RecordId());
            exit;
        end;

        if InvoicePosted(SalesInvoiceHeader, TempSalesHeader) then
            exit;

        if not DocumentCreated(SalesHeader, TempSalesHeader) then
            CreateDocument(SalesHeader, TempSalesHeader, TempSalesLine);

        MessageId := SalesHeader."Your Reference";

        if MessageId = '' then begin
            FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(MessageIdNotFoundLbl, SalesHeader."No.", SalesHeader.FieldName("Your Reference")), Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), SalesHeader.RecordId());
            SalesHeader.Delete(true);
            exit;
        end;

        NextServiceEndPoint."Service Code" := ServiceEndPoint."Service Code";
        NextServiceEndPoint."EndPoint ID" := ServiceEndPoint."Next EndPoint ID";
        NextServiceEndPoint.Find();
        NextServiceEndPoint.TestField(Enabled);

        ServiceSetup.Code := NextServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);
        Request.CreateOutStream(OutStr);
        OutStr.WriteText(TempSalesHeader."Your Reference"); //as messageId

        ServiceAPI.SendWebRequest(ServiceSetup, NextServiceEndPoint, Request, Response, StatusCode);
        FormatResponse := NextServiceEndPoint.Accept;
        if FormatResponse.FoundErrorInResponse(Response, StatusCode) then begin
            ServiceAPI.LogEndPointError(ServiceSetup, NextServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), SalesHeader.RecordId());
            SalesHeader.Delete(true);
            exit;
        end;
        exit(true);
    end;

    procedure ProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesLine: Record "Sales Line" temporary;
        ServiceSetup: Record "NPR BTF Service Setup";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        ServiceSetup.Code := ServiceEndPoint."Service Code";
        ServiceSetup.Find();
        ServiceSetup.TestField(Enabled);

        FormatResponse := ServiceEndPoint.Accept;
        FormatResponse.GetOrderResp(Content, TempSalesHeader, TempSalesLine);

        if (not TempSalesHeader.Find()) or TempSalesLine.IsEmpty() then begin
            FormatResponse.FormatInternalError('internal_business_central_error', OrderResponseNotFoundInContentLbl, Response);
            ServiceAPI.LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), SalesHeader.RecordId());
            Message(ErrorLogInfoLbl);
            exit;
        end;

        if DocumentCreated(SalesHeader, TempSalesHeader) then begin
            if ServiceSetup.Environment = ServiceSetup.Environment::production then begin
                FormatResponse.FormatInternalError('internal_business_central_error', StrSubstNo(OrderResponseNotDeliveredLbl, TempSalesHeader."External Document No.", TempSalesHeader."Your Reference"), Content);
                SalesHeader.SetRecFilter();
                Page.Run(Page::"Sales Order", SalesHeader);
                SendDocumentNotification(GetDocumentCreatedInLiveEnvNotificationId(), DocAlreadyCreatedLbl + ' ' + DocCreatedInLiveEnvLbl, SalesHeader."No.", 'OpenOrder');
            end else begin
                SalesHeader.SetRecFilter();
                Page.Run(Page::"Sales Order", SalesHeader);
                SendDocumentNotification(GetDocumentAlreadyCreatedNotificationId(), DocAlreadyCreatedLbl, SalesHeader."No.", 'OpenOrder');
            end;
            exit;
        end else begin
            if InvoicePosted(SalesInvoiceHeader, TempSalesHeader) then begin
                SalesInvoiceHeader.SetRecFilter();
                Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                SendDocumentNotification(GetDocumentAlreadyPostedNotificationId(), DocAlreadyPostedLbl, SalesInvoiceHeader."No.", 'OpenPostedInvoice');
                exit;
            end;
        end;

        CreateDocument(SalesHeader, TempSalesHeader, TempSalesLine);

        SalesHeader.SetRecFilter();
        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    local procedure CreateDocument(var SalesHeader: Record "Sales Header"; var TempSalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
        NoSeriesMgt: codeunit NoSeriesManagement;
    begin
        SalesHeader."Document Type" := TempSalesHeader."Document Type";
        if NoSeriesMgt.ManualNoAllowed(SalesHeader.GetNoSeriesCode()) then begin
            SalesHeader.validate("No.", TempSalesHeader."No.");
        end else begin
            SalesHeader."No." := '';
        end;
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", TempSalesHeader."Sell-to Customer No.");
        if TempSalesHeader."Posting Date" <> 0D then
            SalesHeader.Validate("Posting Date", TempSalesHeader."Posting Date");
        SalesHeader.Validate("Currency Code", TempSalesHeader."Currency Code");
        SalesHeader.validate("External Document No.", TempSalesHeader."External Document No.");
        SalesHeader."Your Reference" := TempSalesHeader."Your Reference";
        SalesHeader.Modify();
        if TempSalesLine.FindSet() then
            repeat
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := TempSalesLine."Line No.";
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Insert(true);
                SalesLine.Validate("No.", TempSalesLine."No.");
                SalesLine.validate("Unit of Measure Code", TempSalesLine."Unit of Measure Code");
                SalesLine.Validate(Quantity, TempSalesLine.Quantity);
                SalesLine.Validate("Item Reference Type", TempSalesLine."Item Reference Type");
                SalesLine.Validate("Item Reference No.", TempSalesLine."Item Reference No.");
                SalesLine.Validate("Unit Price", TempSalesLine."Unit Price");
                SalesLine.Validate("Line Discount %", TempSalesLine."Line Discount %");
                SalesLine.Modify();
            until TempSalesLine.next() = 0;
        CODEUNIT.Run(CODEUNIT::"Release Sales Document", SalesHeader);
    end;

    local procedure DocumentCreated(var SalesHeader: Record "Sales Header"; TempSalesHeader: Record "Sales Header"): Boolean
    var
        NoSeriesMgt: codeunit NoSeriesManagement;
    begin
        Clear(SalesHeader);
        SalesHeader."Document Type" := TempSalesHeader."Document Type";
        if NoSeriesMgt.ManualNoAllowed(SalesHeader.GetNoSeriesCode()) then begin
            SalesHeader."No." := TempSalesHeader."No.";
            exit(SalesHeader.Find());
        end else begin
            SalesHeader.SetRange("Document Type", TempSalesHeader."Document Type");
            SalesHeader.SetRange("External Document No.", TempSalesHeader."External Document No.");
            exit(SalesHeader.FindFirst());
        end;
    end;

    local procedure InvoicePosted(var SalesInvoiceHeader: Record "Sales Invoice Header"; TempSalesHeader: Record "Sales Header"): Boolean
    begin
        SalesInvoiceHeader.SetRange("External Document No.", TempSalesHeader."External Document No.");
        exit(SalesInvoiceHeader.FindFirst());
    end;

    procedure OpenOrder(DocNotification: Notification)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := DocNotification.GetData('DocNo');
        SalesHeader.SetRecFilter();
        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    procedure OpenPostedInvoice(DocNotification: Notification)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader."No." := DocNotification.GetData('DocNo');
        SalesInvoiceHeader.SetRecFilter();
        Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
    end;

    local procedure SendDocumentNotification(DocNotificationId: Guid; Msg: Text; DocNo: Text; ActionName: Text)
    var
        DocNotification: Notification;
    begin
        DocNotification.Id := DocNotificationId;
        DocNotification.Recall();
        DocNotification.Message(Msg);
        DocNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        DocNotification.SetData('DocNo', DocNo);
        DocNotification.AddAction(OpenCardLbl, Codeunit::"NPR BTF GetOrderResp", ActionName);
        DocNotification.Send();
    end;

    local procedure GetDocumentAlreadyCreatedNotificationId(): Guid
    begin
        exit('d8546594-8d51-4291-867a-53b0d133a0bc');
    end;

    local procedure GetDocumentAlreadyPostedNotificationId(): Guid
    begin
        exit('dc539e17-55c5-4b2a-a340-ea58439440f7');
    end;

    local procedure GetDocumentCreatedInLiveEnvNotificationId(): Guid
    begin
        exit('4fa44f8a-c37b-4259-ad8e-9b17b3fcf61b');
    end;

    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler"
    begin
        exit("NPR Nc IL Update Handler"::B24GetOrderResp);
    end;
}