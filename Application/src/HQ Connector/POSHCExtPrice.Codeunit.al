codeunit 6150910 "NPR POS HC Ext. Price"
{
    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Price Calc. Mgt.", 'OnFindItemPrice', '', true, true)]
    local procedure FindHQConnectorPrice(POSPricingProfile: Record "NPR POS Pricing Profile"; SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    var
        EndpointSetup: Record "NPR POS HC Endpoint Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TmpSalesLine: Record "Sales Line" temporary;
    begin
        if POSPricingProfile."Item Price Codeunit ID" <> GetPublisherCodeunitId() then
            exit;
        if POSPricingProfile."Item Price Function" <> GetPublisherFunction() then
            exit;
        Handled := true;

        EndpointSetup.SetRange(Active, true);
        EndpointSetup.FindFirst();

        if SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.") then;

        TmpSalesLine."Document Type" := TmpSalesLine."Document Type"::Quote;
        TmpSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TmpSalesLine."Line No." := SaleLinePOS."Line No.";
        TmpSalesLine.Type := TmpSalesLine.Type::Item;
        TmpSalesLine."No." := SaleLinePOS."No.";
        TmpSalesLine."Variant Code" := SaleLinePOS."Variant Code";
        TmpSalesLine.Quantity := SaleLinePOS.Quantity;
        TmpSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        TmpSalesLine.Insert();

        GetCustomerPrice(EndpointSetup.Code, SalePOS."Customer No.", SalePOS."Sales Ticket No.", GeneralLedgerSetup."LCY Code", TmpSalesLine);

        if not TmpSalesLine.Get(TmpSalesLine."Document Type"::Quote, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.") then
            exit;

        UpdateSaleLinePOS(TmpSalesLine, SaleLinePOS);
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
        LineType: Option;
    begin
        SoapAction := 'urn:microsoft-dynamics-schemas/codeunit/hqconnector:GetCustomerPrice';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hqc="urn:microsoft-dynamics-schemas/codeunit/hqconnector" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6150903">' +
         '   <soapenv:Header/>' +
         '   <soapenv:Body>' +
         '      <hqc:GetCustomerPrice>' +
         '         <hqc:customerPriceRequest>' +
         '            <x61:priceRequest>';

        XmlRequest += StrSubstNo('<x61:customer number="%1" externalDocumentNumber="%2" currencyCode="%3">', CustomerNo, ExternalDocumentNumber, CurrencyCode);

        TmpSaleLine.FindSet();
        repeat
            XmlRequest += StrSubstNo('<x61:line lineNumber="%1" type="%2" number="%3" variantCode="%4" quantity="%5" unitOfMeasure="%6"/>',
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
        ElementPath: Text;
        NumberText: Text[100];
        DecimalNumber: Decimal;
        IntegerNumber: Integer;
        SaleLinePOS: Record "NPR POS Sale Line";
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

    procedure WebServiceApi(EndpointSetup: Record "NPR POS HC Endpoint Setup"; SoapAction: Text; var XmlDocInText: Text; var XmlElementOut: XmlElement; var ResponseText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XMLDomManagement: Codeunit "XML DOM Management";
        Base64Convert: codeunit "Base64 Convert";
        B64Credential: Text[200];
        XmlDocOut: XmlDocument;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Request: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
    begin
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        case EndpointSetup."Credentials Type" of
            EndpointSetup."Credentials Type"::NAMED:
                begin
                    B64Credential := Base64Convert.ToBase64(StrSubstNo('%1:%2', EndpointSetup."User Account", EndpointSetup."User Password"));
                    RequestHeaders.Add('Authorization', StrSubstNo('Basic %1', B64Credential));
                end;
            else
        end;

        Request.Method('POST');
        Request.SetRequestUri(EndpointSetup."Endpoint URI");

        RequestContent.WriteFrom(XmlDocInText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', StrSubstNo('"%1"', SoapAction));
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
              '<responseStatus>' +
                '<responseCode>%1</responseCode>' +
                '<responseDescription>%2 - %3</responseDescription>' +
              '</responseStatus>',
              Response.HttpStatusCode,
              Response.ReasonPhrase,
              EndpointSetup."Endpoint URI"), XmlDocOut);

        XmlDocOut.GetRoot(XmlElementOut);

        exit(false);
    end;

    local procedure EvaluateToDecimal(NumberText: Text[30]): Decimal
    var
        DecimalValueOut: Decimal;
    begin
        if (NumberText = '') then
            NumberText := '0.0';

        Evaluate(DecimalValueOut, NumberText, 9);
        exit(DecimalValueOut);
    end;

    local procedure EvaluateToInteger(NumberText: Text[30]): Integer
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

