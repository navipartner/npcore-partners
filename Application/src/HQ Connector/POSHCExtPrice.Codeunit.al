codeunit 6150910 "NPR POS HC Ext. Price"
{
    Access = Internal;
    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Price Calc. Mgt.", 'OnFindItemPrice', '', true, true)]
    local procedure FindHQConnectorPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    var
        EndpointSetup: Record "NPR POS HC Endpoint Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempSalesLine: Record "Sales Line" temporary;
    begin
        if POSPricingProfile."Item Price Codeunit ID" <> GetPublisherCodeunitId() then
            exit;
        if POSPricingProfile."Item Price Function" <> GetPublisherFunction() then
            exit;
        Handled := true;

        EndpointSetup.SetRange(Active, true);
        EndpointSetup.FindFirst();

        if SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.") then;

        TempSalesLine."Document Type" := TempSalesLine."Document Type"::Quote;
        TempSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TempSalesLine."Line No." := SaleLinePOS."Line No.";
        TempSalesLine.Type := TempSalesLine.Type::Item;
        TempSalesLine."No." := SaleLinePOS."No.";
        TempSalesLine."Variant Code" := SaleLinePOS."Variant Code";
        TempSalesLine.Quantity := SaleLinePOS.Quantity;
        TempSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        TempSalesLine.Insert();

        GetCustomerPrice(EndpointSetup.Code, SalePOS."Customer No.", SalePOS."Sales Ticket No.", GeneralLedgerSetup."LCY Code", TempSalesLine);

        if not TempSalesLine.Get(TempSalesLine."Document Type"::Quote, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.") then
            exit;

        UpdateSaleLinePOS(TempSalesLine, SaleLinePOS);
    end;

    procedure UpdateSaleLinePOS(TmpSalesLine: Record "Sales Line" temporary; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS."Unit Price" := TmpSalesLine."Unit Price";

        if TmpSalesLine."Line Discount %" = 0 then
            exit;
        if (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual) and (SaleLinePOS."Discount Code" = '') then
            exit;

        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS."Discount Code" := 'HC';
        SaleLinePOS."Discount %" := TmpSalesLine."Line Discount %";
        SaleLinePOS."Discount Amount" := 0;
    end;

    procedure GetCustomerPrice(EndpointCode: Code[10]; CustomerNumber: Code[20]; ExternalDocumentNumber: Code[20]; CurrencyCode: Code[10]; var TmpSalesLine: Record "Sales Line" temporary)
    var
        HCEndpointSetup: Record "NPR POS HC Endpoint Setup";
        SoapAction: Text;
        RequestXmlDocText: Text;
        ResponseXmlElement: XmlElement;
        ResponseText: Text;
        ResponseXmlText: Text;
    begin
        HCEndpointSetup.Get(EndpointCode);

        BuildPriceRequest(CustomerNumber, ExternalDocumentNumber, CurrencyCode, TmpSalesLine, SoapAction, RequestXmlDocText);
        if (not WebServiceApi(HCEndpointSetup, SoapAction, RequestXmlDocText, ResponseXmlElement, ResponseXmlText)) then
            Error('Error from WebService:\\%1', ResponseXmlElement.InnerXml());

        if (not ApplyPriceResponse(TmpSalesLine, ResponseXmlElement, ResponseText, ResponseXmlText)) then
            Error(ResponseText);
    end;

    local procedure BuildPriceRequest(CustomerNo: Code[20]; ExternalDocumentNumber: Code[20]; CurrencyCode: Code[10]; var TmpSaleLine: Record "Sales Line" temporary; var SoapAction: Text; XmlRequest: Text): Boolean
    var
        XmlReqHeaderLbl: Label '<x61:customer number="%1" externalDocumentNumber="%2" currencyCode="%3">', Locked = true;
        XmlReqLineLbl: Label '<x61:line lineNumber="%1" type="%2" number="%3" variantCode="%4" quantity="%5" unitOfMeasure="%6"/>', Locked = true;
    begin
        SoapAction := 'urn:microsoft-dynamics-schemas/codeunit/hqconnector:GetCustomerPrice';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hqc="urn:microsoft-dynamics-schemas/codeunit/hqconnector" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6150903">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <hqc:GetCustomerPrice>' +
         '         <hqc:customerPriceRequest>' +
         '            <x61:priceRequest>';

        XmlRequest += StrSubstNo(XmlReqHeaderLbl, CustomerNo, ExternalDocumentNumber, CurrencyCode);

        TmpSaleLine.FindSet();
        repeat
            XmlRequest += StrSubstNo(XmlReqLineLbl,
              TmpSaleLine."Line No.",
              Format(TmpSaleLine.Type::Item, 0, 2),
              TmpSaleLine."No.",
              TmpSaleLine."Variant Code",
              TmpSaleLine.Quantity,
              TmpSaleLine."Unit of Measure Code");
        until (TmpSaleLine.Next() = 0);

        XmlRequest +=
         '               </x61:customer>' +
         '            </x61:priceRequest>' +
         '         </hqc:customerPriceRequest>' +
         '      </hqc:GetCustomerPrice>' +
         '   </soapenv:Body>' +
         '</soapenv:Envelope>';

        exit(true);
    end;

    local procedure ApplyPriceResponse(var TmpSaleLine: Record "Sales Line" temporary; var Element: XmlElement; var ResponseText: Text; ResponseXmlText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NodeList: XmlNodeList;
        Node: XmlNode;
        TextOk: Text;
        ElementPath: Text[250];
    begin

        if Element.IsEmpty then begin
            ResponseText := StrSubstNo(InvalidXml, NpXmlDomMgt.PrettyPrintXml(ResponseXmlText));
            exit(false);
        end;

        ElementPath := '//GetCustomerPrice_Result/customerPriceRequest/priceResponse/responseStatus/';
        TextOk := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responseCode', 10, true);

        if (UpperCase(TextOk) <> 'OK') then begin
            ElementPath := '//GetCustomerPrice_Result/customerPriceRequest/priceResponse/responseStatus/';
            ResponseText := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'responseDescription', 1000, true);
            exit(false);
        end;

        ElementPath := 'GetCustomerPrice_Result/customerPriceRequest/priceResponse/customer/line';
        if (not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), ElementPath, NodeList)) then
            Error('Find node [%1] failed in document \\%2', ElementPath, Element.InnerXml);

        foreach Node in NodeList do begin
            TmpSaleLine.SetFilter("Line No.", '=%1', EvaluateToInteger(NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'lineNumber', true)));
            if (TmpSaleLine.FindFirst()) then begin
                TmpSaleLine."Unit Price" := EvaluateToDecimal(NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'unitPrice', true));
                TmpSaleLine."Line Discount %" := EvaluateToDecimal(NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'lineDiscountPercent', true));
                TmpSaleLine.Modify();
            end;
        end;

        exit(true);
    end;

    procedure WebServiceApi(EndpointSetup: Record "NPR POS HC Endpoint Setup"; SoapAction: Text; XmlDocInText: Text; var XmlElementOut: XmlElement; var ResponseText: Text): Boolean
    var
        XMLDomManagement: Codeunit "XML DOM Management";
        XmlDocOut: XmlDocument;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Request: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        SoapActionLbl: Label '"%1"', Locked = true;
        ResponseLbl: Label '<responseStatus><responseCode>%1</responseCode><responseDescription>%2 - %3</responseDescription></responseStatus>', Locked = true;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        EndpointSetup.SetRequestHeadersAuthorization(RequestHeaders);

        Request.Method('POST');
        Request.SetRequestUri(EndpointSetup."Endpoint URI");

        RequestContent.WriteFrom(XmlDocInText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', StrSubstNo(SoapActionLbl, SoapAction));
        ContentHeader := Client.DefaultRequestHeaders();

        Request.Content(RequestContent);
        Client.Timeout(EndpointSetup."Connection Timeout (ms)");
        Client.Send(Request, Response);

        if Response.IsSuccessStatusCode then begin
            Response.Content.ReadAs(ResponseText);
            ResponseText := XMLDomManagement.RemoveNamespaces(ResponseText);
            XmlDocument.ReadFrom(ResponseText, XmlDocOut);
            XmlDocOut.GetRoot(XmlElementOut);
            exit(true);
        end;

        ResponseText := Response.ReasonPhrase;
        if (StrLen(ResponseText) > 0) then
            XmlDocument.ReadFrom(ResponseText, XmlDocOut)
        else
            XmlDocument.ReadFrom(StrSubstNo(
              ResponseLbl,
              Response.HttpStatusCode,
              Response.ReasonPhrase,
              EndpointSetup."Endpoint URI"), XmlDocOut);

        XmlDocOut.GetRoot(XmlElementOut);

        exit(false);
    end;

    local procedure EvaluateToDecimal(NumberText: Text): Decimal
    var
        DecimalValueOut: Decimal;
    begin
        if (NumberText = '') then
            NumberText := '0.0';

        Evaluate(DecimalValueOut, NumberText, 9);
        exit(DecimalValueOut);
    end;

    local procedure EvaluateToInteger(NumberText: Text): Integer
    var
        IntegerValueOut: Integer;
    begin

        if (NumberText = '') then
            NumberText := '0';

        Evaluate(IntegerValueOut, NumberText, 9);
        exit(IntegerValueOut);
    end;

    local procedure GetPublisherCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS HC Ext. Price");
    end;

    local procedure GetPublisherFunction(): Text
    begin
        exit('FindHQConnectorPrice');
    end;
}

