codeunit 6150910 "POS HC External Price"
{
    // NPR5.38/TSA /20171130 CASE 297859 Initial Version
    // NPR5.44/MHA /20180704 CASE 321096 Added format 2 on Option field in BuildPriceRequest() to achieve Language neutrality
    // NPR5.45/MHA /20180803 CASE 3237005 Added POS Item Price subcriber function FindHQConnectorPrice


    trigger OnRun()
    begin
    end;

    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    local procedure "-- Client Side (POS)"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014453, 'OnFindItemPrice', '', true, true)]
    local procedure FindHQConnectorPrice(POSUnit: Record "POS Unit";SalePOS: Record "Sale POS";var SaleLinePOS: Record "Sale Line POS";var Handled: Boolean)
    var
        EndpointSetup: Record "POS HC Endpoint Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TmpSalesLine: Record "Sales Line" temporary;
    begin
        //-NPR5.45 [323705]
        if POSUnit."Item Price Codeunit ID" <> CODEUNIT::"POS HC External Price" then
          exit;
        if POSUnit."Item Price Function" <> 'FindHQConnectorPrice' then
          exit;
        Handled := true;

        EndpointSetup.SetRange(Active,true);
        EndpointSetup.FindFirst;

        if SalePOS.Get(SalePOS."Register No.",SalePOS."Sales Ticket No.") then;

        TmpSalesLine."Document Type" := TmpSalesLine."Document Type"::Quote;
        TmpSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TmpSalesLine."Line No." := SaleLinePOS."Line No.";
        TmpSalesLine.Type := TmpSalesLine.Type::Item;
        TmpSalesLine."No." := SaleLinePOS."No.";
        TmpSalesLine."Variant Code" := SaleLinePOS."Variant Code";
        TmpSalesLine.Quantity := SaleLinePOS.Quantity;
        TmpSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        TmpSalesLine.Insert;

        GetCustomerPrice(EndpointSetup.Code, SalePOS."Customer No.", SalePOS."Sales Ticket No.",GeneralLedgerSetup."LCY Code",TmpSalesLine);

        if not TmpSalesLine.Get(TmpSalesLine."Document Type"::Quote,SaleLinePOS."Sales Ticket No.",SaleLinePOS."Line No.") then
          exit;

        UpdateSaleLinePOS(TmpSalesLine,SaleLinePOS);
        //+NPR5.45 [323705]
    end;

    procedure UpdateSaleLinePOS(TmpSalesLine: Record "Sales Line" temporary;var SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.45 [323705]
        SaleLinePOS."Unit Price" := TmpSalesLine."Unit Price";

        if TmpSalesLine."Line Discount %" = 0 then
          exit;
        if (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual) and (SaleLinePOS."Discount Code" = '') then
          exit;

        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS."Discount Code" := 'HC';
        SaleLinePOS."Discount %" := TmpSalesLine."Line Discount %";
        SaleLinePOS."Discount Amount" := 0;
        //+NPR5.45 [323705]
    end;

    procedure GetCustomerPrice(EndpointCode: Code[10];CustomerNumber: Code[20];ExternalDocumentNumber: Code[20];CurrencyCode: Code[10];var TmpSalesLine: Record "Sales Line" temporary)
    var
        HCEndpointSetup: Record "POS HC Endpoint Setup";
        SoapAction: Text;
        RequestXmlDoc: DotNet npNetXmlDocument;
        ResponseXmlDoc: DotNet npNetXmlDocument;
        ResponseText: Text;
    begin

        HCEndpointSetup.Get (EndpointCode);

        BuildPriceRequest (CustomerNumber, ExternalDocumentNumber, CurrencyCode, TmpSalesLine, SoapAction, RequestXmlDoc);
        if (not WebServiceApi (HCEndpointSetup, SoapAction, RequestXmlDoc, ResponseXmlDoc)) then
          Error ('Error from WebService:\\%1',ResponseXmlDoc.InnerXml());

        if (not ApplyPriceResponse (TmpSalesLine, ResponseXmlDoc, ResponseText)) then
          Error (ResponseText);
    end;

    local procedure BuildPriceRequest(CustomerNo: Code[20];ExternalDocumentNumber: Code[20];CurrencyCode: Code[10];var TmpSaleLine: Record "Sales Line" temporary;var SoapAction: Text;var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        XmlRequest: Text;
        LineType: Option;
    begin

        SoapAction := 'urn:microsoft-dynamics-schemas/codeunit/hqconnector:GetCustomerPrice';
        XmlRequest :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hqc="urn:microsoft-dynamics-schemas/codeunit/hqconnector" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6150903">'+
         '   <soapenv:Header/>'+
         '   <soapenv:Body>'+
         '      <hqc:GetCustomerPrice>'+
         '         <hqc:customerPriceRequest>'+
         '            <x61:priceRequest>';

        //'               <x61:customer number="D000230" currencyCode="">'+
        XmlRequest += StrSubstNo ('<x61:customer number="%1" externalDocumentNumber="%2" currencyCode="%3">', CustomerNo, ExternalDocumentNumber, CurrencyCode);

        //'                  <!--1 or more repetitions:-->'+
        //'                  <x61:line type="ITEM" number="40001" quantity="10" unitOfMeasure="PCS"/>'+
        TmpSaleLine.FindSet();
        repeat
          XmlRequest += StrSubstNo('<x61:line lineNumber="%1" type="%2" number="%3" variantCode="%4" quantity="%5" unitOfMeasure="%6"/>',
            TmpSaleLine."Line No.",
            //-NPR5.44 [321096]
            //TmpSaleLine.Type::Item,
            Format(TmpSaleLine.Type::Item,0,2),
            //+NPR5.44 [321096]
            TmpSaleLine."No.",
            TmpSaleLine."Variant Code",
            TmpSaleLine.Quantity,
            TmpSaleLine."Unit of Measure Code");
        until (TmpSaleLine.Next() = 0);

        XmlRequest +=
         '               </x61:customer>'+
         '            </x61:priceRequest>'+
         '         </hqc:customerPriceRequest>'+
         '      </hqc:GetCustomerPrice>'+
         '   </soapenv:Body>'+
         '</soapenv:Envelope>';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml (XmlRequest);

        exit (true);
    end;

    local procedure ApplyPriceResponse(var TmpSaleLine: Record "Sales Line" temporary;var XmlDoc: DotNet npNetXmlDocument;var ResponseText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        XmlNodeElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        TextOk: Text;
        ElementPath: Text;
        NumberText: Text[100];
        DecimalNumber: Decimal;
        IntegerNumber: Integer;
        i: Integer;
        SaleLinePOS: Record "Sale Line POS";
    begin

        //  <GetCustomerPrice_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/hqconnector">
        //      <customerPriceRequest>
        //        <priceResponse xmlns="urn:microsoft-dynamics-nav/xmlports/x6150903">
        //            <responseStatus>
        //              <responseCode>OK</responseCode>
        //              <responseDescription/>
        //            </responseStatus>
        //            <customer number="D000230" externalDocumentNumber="ABC" currencyCode="EUR">
        //              <line lineNumber="1" type="2" number="40001" quantity="10" unitOfMeasure="PCS" unitPrice="100.00" lineAmount="550.00" lineDiscountPercent="45" lineDiscountAmount="450.00" vatPct="25" vatBaseAmount="440.00"/>
        //              <line lineNumber="3" type="2" number="40010" quantity="10" unitOfMeasure="" unitPrice="45.00" lineAmount="450.00" lineDiscountPercent="0" lineDiscountAmount="0.00" vatPct="25" vatBaseAmount="360.00"/>
        //            </customer>
        //        </priceResponse>

        NpXmlDomMgt.RemoveNameSpaces (XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
          ResponseText := StrSubstNo (InvalidXml, NpXmlDomMgt.PrettyPrintXml (XmlDoc.InnerXml()));
          exit (false);
        end;

        ElementPath := '//GetCustomerPrice_Result/customerPriceRequest/priceResponse/responseStatus/';
        TextOk := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'responseCode', 10, true);

        if (UpperCase (TextOk) <> 'OK') then begin
          ElementPath := '//GetCustomerPrice_Result/customerPriceRequest/priceResponse/responseStatus/';
          ResponseText := NpXmlDomMgt.GetXmlText (XmlElement, ElementPath + 'responseDescription', 1000, true);
          exit (false);
        end;

        ElementPath := 'GetCustomerPrice_Result/customerPriceRequest/priceResponse/customer/line';
        if (not NpXmlDomMgt.FindNodes (XmlElement, ElementPath, XmlNodeList)) then
          Error ('Find node [%1] failed in document \\%2', ElementPath, XmlElement.InnerXml);

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlNodeElement := XmlNodeList.ItemOf (i);

          TmpSaleLine.SetFilter ("Line No.", '=%1', EvaluateToInteger (NpXmlDomMgt.GetXmlAttributeText (XmlNodeElement, 'lineNumber', true)));
          if (TmpSaleLine.FindFirst ()) then begin
            TmpSaleLine."Unit Price" := EvaluateToDecimal (NpXmlDomMgt.GetXmlAttributeText (XmlNodeElement, 'unitPrice', true));
            TmpSaleLine."Line Discount %" := EvaluateToDecimal (NpXmlDomMgt.GetXmlAttributeText (XmlNodeElement, 'lineDiscountPercent', true));
            TmpSaleLine.Modify ();
          end;
        end;

        exit (true);
    end;

    local procedure "--WSSupport"()
    begin
    end;

    procedure WebServiceApi(EndpointSetup: Record "POS HC Endpoint Setup";SoapAction: Text;var XmlDocIn: DotNet npNetXmlDocument;var XmlDocOut: DotNet npNetXmlDocument): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        Convert: DotNet npNetConvert;
        B64Credential: Text[200];
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        WebInnerException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
    begin

        HttpWebRequest := HttpWebRequest.Create (EndpointSetup."Endpoint URI");
        HttpWebRequest.Timeout := EndpointSetup."Connection Timeout (ms)";
        HttpWebRequest.KeepAlive (false);

        case EndpointSetup."Credentials Type" of
          EndpointSetup."Credentials Type"::NAMED :
            begin
              HttpWebRequest.UseDefaultCredentials (false);
              B64Credential := ToBase64 (StrSubstNo ('%1:%2', EndpointSetup."User Account", EndpointSetup."User Password"));
              HttpWebRequest.Headers.Add ('Authorization', StrSubstNo ('Basic %1', B64Credential));
            end;
          else
            HttpWebRequest.UseDefaultCredentials (true);
        end;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add ('SOAPAction', StrSubstNo ('"%1"', SoapAction));

        NpXmlDomMgt.SetTrustedCertificateValidation (HttpWebRequest);

        if (TrySendWebRequest (XmlDocIn, HttpWebRequest, HttpWebResponse)) then begin
          TryReadResponseText (HttpWebResponse, ResponseText);
          XmlDocOut := XmlDocOut.XmlDocument;
          XmlDocOut.LoadXml (ResponseText);
          exit (true);
        end;

        Exception := GetLastErrorObject();
        if ((Format (GetDotNetType(Exception.GetBaseException ()))) <> (Format (GetDotNetType(WebException)))) then
          Error (Exception.ToString ());

        WebException := Exception.GetBaseException ();
        TryReadExceptionResponseText (WebException, StatusCode, StatusDescription, ResponseText);

        XmlDocOut := XmlDocOut.XmlDocument;
        if (StrLen (ResponseText) > 0) then
          XmlDocOut.LoadXml (ResponseText);

        if (StrLen (ResponseText) = 0) then
          XmlDocOut.LoadXml (StrSubstNo (
            '<responseStatus>'+
              '<responseCode>%1</responseCode>'+
              '<responseDescription>%2 - %3</responseDescription>'+
            '</responseStatus>',
            StatusCode,
            StatusDescription,
            EndpointSetup."Endpoint URI"));

        exit (false);
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet npNetXmlDocument;HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse;var ResponseText: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());
        ResponseText := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException;var StatusCode: Code[10];var StatusDescription: Text;var ResponseXml: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebResponse: DotNet npNetWebResponse;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals (WebExceptionStatus.Timeout)) then  begin
          StatusCodeInt := SystemConvert.ChangeType (WebExceptionStatus.Timeout, GetDotNetType (StatusCodeInt));
          StatusCode := Format (StatusCodeInt);
          StatusDescription := WebExceptionStatus.Timeout.ToString();
          exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals (WebExceptionStatus.ProtocolError)) then begin
          HttpWebResponse := WebException.Response ();
          StatusCodeInt := SystemConvert.ChangeType (HttpWebResponse.StatusCode, GetDotNetType (StatusCodeInt));
          StatusCode := Format (StatusCodeInt);
          StatusDescription := HttpWebResponse.StatusDescription;
          if (StatusCode[1] = '4') then // 4xx messages
            exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;

        StreamReader.Close;
        Clear (StreamReader);
    end;

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure EvaluateToDecimal(NumberText: Text[30]): Decimal
    var
        DecimalValueOut: Decimal;
    begin
        if (NumberText = '') then
          NumberText := '0.0';

        Evaluate (DecimalValueOut, NumberText, 9);
        exit (DecimalValueOut);
    end;

    local procedure EvaluateToInteger(NumberText: Text[30]): Integer
    var
        IntegerValueOut: Integer;
    begin

        if (NumberText = '') then
          NumberText := '0';

        Evaluate (IntegerValueOut, NumberText, 9);
        exit (IntegerValueOut);
    end;
}

