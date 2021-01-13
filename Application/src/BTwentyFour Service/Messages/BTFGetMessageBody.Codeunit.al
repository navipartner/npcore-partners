codeunit 6014650 "NPR BTF GetMessage Body"
{
    var
        EndPointKeyNotSetErr: Label 'Endpoint-Key is not set for endpoint %1 (%2 -> %3)', Comment = '%1=Service EndPoint ID;%2=ServiceSetup.TableCaption();%3=ServiceEndPoint.TableCaption()';
        AuthMethodIDNotSetErr: Label 'Authorization Method ID is not set in %1 or it''s not found in related table %2', Comment = '%1=ServiceSetup.TableCaption();%2=ServiceEndPoint.TableCaption()';
        RequestNotSentErr: Label 'Failed to send request to %1', Comment = '%1=Request URI';
        TokenNotFoundErr: Label 'Access token not found for %1.', Comment = '%1="Service EndPoint for Authroization"."EndPoint ID"';

    procedure GetMessageBody(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"; ResourceUri: Text)
    var
        ServiceAPI: Codeunit "NPR BTF Service API";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ResponseText: Text;
        ParameterValue: Text;
        OrdinalValue: Integer;
        Index: Integer;
    begin
        ClearLastError();

        RequestMessage.Method := Format(ServiceEndPoint."Service Method Name");
        RequestMessage.SetRequestUri(ResourceUri);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');
        Headers.Add('Authorization', StrSubstNo('bearer %1', ServiceAPI.GetTokenFromResponse(ServiceEndPointForAuth, Response)));
        Headers.Add('Subscription-Key', ServiceSetup."Subscription-Key");

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
            error(RequestNotSentErr, RequestMessage.GetRequestUri());
        end;

        Content := ResponseMessage.Content();
        Content.ReadAs(ResponseText);
        Clear(Response);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);
    end;

    procedure CheckServiceSetup(ServiceSetup: Record "NPR BTF Service Setup"; var ServiceEndPointAuth: Record "NPR BTF Service EndPoint"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        if (ServiceSetup."Authroization EndPoint ID" = '') or (not ServiceEndPointAuth.Get(ServiceSetup.Code, ServiceSetup."Authroization EndPoint ID")) then begin
            Error(StrSubstNo(AuthMethodIDNotSetErr, ServiceSetup.TableCaption(), ServiceEndPointAuth.TableCaption()));
        end;
    end;

    procedure CheckServiceEndPoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        if ServiceEndPoint."EndPoint-Key" = '' then begin
            error(StrSubstNo(EndPointKeyNotSetErr, ServiceEndPoint."EndPoint ID", ServiceSetup.TableCaption(), ServiceEndPoint.TableCaption()));
        end;
    end;

    procedure GetResourcesUri(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var ResourcesUri: List of [Text]; var ServiceSetup: Record "NPR BTF Service Setup"; var ServiceEndPointForAuth: Record "NPR BTF Service EndPoint"; var FormatResponse: Interface "NPR BTF IFormatResponse")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
        Response: Codeunit "Temp Blob";
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceSetup.Get(ServiceEndPoint."Service Code");
        CheckServiceSetup(ServiceSetup, ServiceEndPointForAuth, ServiceEndPoint);
        CheckServiceEndPoint(ServiceSetup, ServiceEndPoint);

        EndPoint := ServiceEndPointForAuth."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPointForAuth, Response);
        if not ServiceAPI.IsTokenAvailable(ServiceEndPointForAuth, Response) then
            error(TokenNotFoundErr);

        FormatResponse := ServiceEndPOint.Accept;
        FormatResponse.GetResourcesUri(Content, ResourcesUri);
    end;

    procedure ValidateDocument(var SalesHeader: Record "Sales Header"; var TempSalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line")
    var
        SalesHeader2: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        NoSeriesMgt: codeunit NoSeriesManagement;
    begin
        if NoSeriesMgt.ManualNoAllowed(SalesHeader.GetNoSeriesCode()) then begin
            SalesHeader."No." := TempSalesHeader."No.";
            if SalesHeader.Find() then
                exit;
            SalesHeader.validate("No.", TempSalesHeader."No.");
        end else begin
            SalesHeader2.SetRange("Document Type", Salesheader."Document Type");
            SalesHeader2.SetRange("External Document No.", TempSalesHeader."External Document No.");
            if not SalesHeader2.IsEmpty() then
                exit;

            SalesInvoiceHeader.SetRange("External Document No.", TempSalesHeader."External Document No.");
            if not SalesInvoiceHeader.isempty() then
                exit;

            SalesHeader."No." := '';
        end;
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", TempSalesHeader."Sell-to Customer No.");
        SalesHeader.validate("External Document No.", TempSalesHeader."External Document No.");
        SalesHeader.Modify();
        if TempSalesLine.FindSet() then
            repeat
                SalesLine."Document Type" := SalesHeader."Document Type"::Invoice;
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." += 10000;
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Insert(true);
                SalesLine.Validate("No.", TempSalesLine."No.");
                SalesLine.validate("Unit of Measure Code", TempSalesLine."Unit of Measure Code");
                SalesLine.Validate(Quantity, TempSalesLine.Quantity);
                SalesLine.Validate("Item Reference No.", TempSalesLine."Item Reference No.");
                SalesLine.Validate("Unit Price", TempSalesLine."Unit Price");
                SalesLine.Modify();
            until TempSalesLine.next() = 0;
    end;
}