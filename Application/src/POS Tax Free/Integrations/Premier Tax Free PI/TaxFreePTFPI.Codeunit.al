codeunit 6014611 "NPR Tax Free PTF PI"
{
    var
        Error_Ineligible: Label 'Sale is not eligible.';
        Error_PrintFail: Label 'Printing of tax free voucher %1 failed with error "%2".\NOTE: The voucher is correctly issued and active. Please recreate the tax free voucher if the problem persists.';
        Error_MissingParameters: Label 'Missing parameters for handler %1 on tax free unit %2';
        MerchantID: Text;
        VATNumber: Text;
        CountryCode: Integer;
        POSUnitNo: Code[10];
        Error_RequestFailed: Label 'Webservice request failed';
        Error_InvalidResponse: Label 'Invalid webservice XML response';
        Error_PrintData: Label 'Invalid print data returned from service';
        Error_MissingPrintSetup: Label 'Missing object output setup';
        Error_WrongIINDecision: Label 'The tax free service responded but it returned invalid data. Please double check the setup.';
        MinimumAmountLimit: Decimal;
        Error_NotSupported: Label 'Operation is not supported by tax free handler: %1';
        Error_MissingPrint: Label 'The voucher cannot be reprinted. Please void and create a new one.';

    local procedure HandlerID(): Text
    begin
        exit('PREMIER_PI')
    end;

    local procedure ServicePROD(): Text
    begin
        exit('https://pi.fintrax.com/pi_public_v2/service.asmx');
    end;

    local procedure ServiceTEST(): Text
    begin
        exit('https://pipreprod.fintrax.com/pi_public_V2/service.asmx');
    end;

    [TryFunction]
    local procedure InitializeHandler(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
        tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary;
        Variant: Variant;
    begin
        TaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");

        if not TaxFreeUnit."Handler Parameters".HasValue then
            Error(Error_MissingParameters, TaxFreeUnit."Handler ID", TaxFreeUnit."POS Unit No.");

        AddParameters(tmpHandlerParameters);
        tmpHandlerParameters.DeserializeParameterBLOB(TaxFreeUnit);

        if tmpHandlerParameters.TryGetParameterValue('Merchant ID', Variant) then
            MerchantID := Variant;

        if tmpHandlerParameters.TryGetParameterValue('VAT Number', Variant) then
            VATNumber := Variant;

        if tmpHandlerParameters.TryGetParameterValue('Country Code', Variant) then
            CountryCode := Variant;

        if tmpHandlerParameters.TryGetParameterValue('Minimum Amount Limit', Variant) then
            MinimumAmountLimit := Variant;

        POSUnitNo := TaxFreeUnit."POS Unit No.";

        if (StrLen(MerchantID) = 0) or (StrLen(VATNumber) = 0) or (CountryCode = 0) then
            Error(Error_MissingParameters, TaxFreeUnit."Handler ID", TaxFreeUnit."POS Unit No.");
    end;

    local procedure AddParameters(var tmpHandlerParameters: Record "NPR Tax Free Handler Param.")
    begin
        tmpHandlerParameters.AddParameter('Merchant ID', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('VAT Number', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('Country Code', tmpHandlerParameters."Data Type"::Integer);
        tmpHandlerParameters.AddParameter('Minimum Amount Limit', tmpHandlerParameters."Data Type"::Decimal);
    end;

    local procedure "// Commands"()
    begin
    end;

    local procedure VoucherIssue(var TaxFreeRequest: Record "NPR Tax Free Request"; var RecRef: RecordRef)
    var
        VoucherNo: Text;
        VoucherBarcode: Text;
        PrintXML: Text;
        VoucherTotalAmount: Text;
        VoucherRefundAmount: Text;
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        ErrorDescription: Text;
        Number: Code[20];
        Type: Integer;
    begin
        RecRef.FindSet;

        //This is done with 2 external calls, so requesttype is set before each to make sure the log is specific in case of error.

        TaxFreeRequest."Request Type" := 'INSERT_INVOICE';
        InsertInvoice(TaxFreeRequest, RecRef);

        TaxFreeRequest."Request Type" := 'CREATE_VOUCHER';
        CreateVoucher(TaxFreeRequest, RecRef);
    end;

    local procedure VoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; ExternalVoucherNo: Text)
    var
        ErrorText: Text;
        ErrorNo: Text;
        XMLDoc: DotNet "NPRNetXmlDocument";
    begin
        VoidVoucherRequest(TaxFreeRequest, ExternalVoucherNo);
        HandleResponse(TaxFreeRequest, 'VoidVoucherResult', XMLDoc);

        ErrorNo := GetFirstNodeContent(XMLDoc, 'error', false);
        if UpperCase(ErrorNo) <> '0' then begin
            ErrorText := GetFirstNodeContent(XMLDoc, 'error_text', false);
            Error(ErrorText);
        end;
    end;

    [TryFunction]
    local procedure TryPrintVoucher(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        InStream: InStream;
        XML: Text;
        Buffer: Text;
    begin
        case TaxFreeRequest."Print Type" of
            TaxFreeRequest."Print Type"::PDF:
                PrintPDF(TaxFreeRequest);
            TaxFreeRequest."Print Type"::Thermal:
                PrintThermalReceipt(TaxFreeRequest);
        end;
    end;

    local procedure IsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text) Valid: Boolean
    var
        ResponseMessage: Text;
        Value: Text;
        Eligible: Text;
        XMLDoc: DotNet "NPRNetXmlDocument";
        IIN: Text;
        ErrorNo: Text;
    begin
        IIN := PadStr(CopyStr(MaskedCardNo, 1, 6), StrLen(MaskedCardNo), 'X'); //The service requires some masked character to be present even though only the first 6 are relevant.

        BRTSearchRequest(TaxFreeRequest, IIN);
        HandleResponse(TaxFreeRequest, 'PerformBRTSearchResult', XMLDoc);

        if TryGetFirstNodeContent(XMLDoc, 'VATRefundEligible', false, Eligible) then
            Valid := (UpperCase(Eligible) = 'TRUE')
        else begin
            if TryGetFirstNodeContent(XMLDoc, 'error', false, ErrorNo) then
                TaxFreeRequest."Error Code" := ErrorNo;
            Error(GetFirstNodeContent(XMLDoc, 'error_text', false));
        end;
    end;

    local procedure "// Aux functions"()
    begin
    end;

    local procedure InsertInvoice(var TaxFreeRequest: Record "NPR Tax Free Request"; var RecRef: RecordRef): Boolean
    var
        ResponseMessage: Text;
        ErrorNo: Text;
        XMLDoc: DotNet "NPRNetXmlDocument";
    begin
        InsertInvoiceRequest(TaxFreeRequest, RecRef);
        HandleResponse(TaxFreeRequest, 'InsertInvoiceResult', XMLDoc);

        ErrorNo := GetFirstNodeContent(XMLDoc, 'error', false);
        if not (UpperCase(ErrorNo) = '0') then begin //0 = Success
            TaxFreeRequest."Error Code" := ErrorNo;
            Error(GetFirstNodeContent(XMLDoc, 'error_text', false));
        end;
    end;

    local procedure CreateVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; var RecRef: RecordRef)
    var
        ResponseMessage: Text;
        ErrorNo: Text;
        VoucherNo: Text;
        VoucherBarcode: Text;
        VoucherTotalAmount: Text;
        VoucherRefundAmount: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        XMLDoc: DotNet "NPRNetXmlDocument";
        Decimal: Decimal;
        PrintXML: Text;
    begin
        CreateVoucherRequest(TaxFreeRequest, RecRef);
        HandleResponse(TaxFreeRequest, 'CreateVoucherResult', XMLDoc);

        if TryGetFirstNodeContent(XMLDoc, 'voucher_number', false, VoucherNo) then;

        if not TryGetFirstNodeContent(XMLDoc, 'voucher_lines', true, PrintXML) then //Thermal print data
            if TryGetFirstNodeContent(XMLDoc, 'VoucherForm', true, PrintXML) then //PDF print data
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;

        if not GetBarcodeFromPrintXML(PrintXML, VoucherBarcode) then
            if TryGetFirstNodeContent(XMLDoc, 'Barcode', true, VoucherBarcode) then;

        if TryGetFirstNodeContent(XMLDoc, 'price_incl_vat', false, VoucherTotalAmount) then;

        if TryGetFirstNodeContent(XMLDoc, 'refund_amount', false, VoucherRefundAmount) then;

        if (StrLen(VoucherNo) > 0) and (StrLen(VoucherBarcode) > 0) and (StrLen(PrintXML) > 0) and (StrLen(VoucherTotalAmount) > 0) and (StrLen(VoucherRefundAmount) > 0) then begin
            TaxFreeRequest."External Voucher No." := VoucherNo;
            TaxFreeRequest."External Voucher Barcode" := VoucherBarcode;
            Evaluate(TaxFreeRequest."Total Amount Incl. VAT", VoucherTotalAmount, 9);
            Evaluate(TaxFreeRequest."Refund Amount", VoucherRefundAmount, 9);
            TaxFreeRequest.Print.CreateOutStream(OutStream, TEXTENCODING::UTF8);
            OutStream.Write(PrintXML);
        end else begin
            if TryGetFirstNodeContent(XMLDoc, 'error', false, ErrorNo) then
                TaxFreeRequest."Error Code" := ErrorNo;

            Error(GetFirstNodeContent(XMLDoc, 'error_text', false));
        end;
    end;

    local procedure GetCDataXML(XMLDoc: DotNet "NPRNetXmlDocument"; CDATATagName: Text)
    var
        XMLNode: DotNet NPRNetXmlNode;
        XMLNodeList: DotNet NPRNetXmlNodeList;
        HtmlDecoder: DotNet NPRNetHttpUtility;
    begin
        XMLNodeList := XMLDoc.GetElementsByTagName(CDATATagName);
        XMLNode := XMLNodeList.ItemOf(0);
        HtmlDecoder := HtmlDecoder.HttpUtility;
        XMLDoc.LoadXml(HtmlDecoder.HtmlDecode(XMLNode.InnerXml));
    end;

    local procedure GetFirstNodeContent(XMLDoc: DotNet "NPRNetXmlDocument"; ElementName: Text; XMLInContent: Boolean): Text
    var
        XMLNode: DotNet NPRNetXmlNode;
        XMLNodeList: DotNet NPRNetXmlNodeList;
    begin
        XMLNodeList := XMLDoc.GetElementsByTagName(ElementName);
        XMLNode := XMLNodeList.ItemOf(0);
        if XMLInContent then
            exit(XMLNode.OuterXml)
        else
            exit(XMLNode.InnerText);
    end;

    [TryFunction]
    local procedure GetBarcodeFromPrintXML(PrintXML: Text; var Barcode: Text)
    var
        XMLNode: DotNet NPRNetXmlNode;
        PrintLines: DotNet NPRNetXmlNodeList;
        i: Integer;
        Line: Text;
        XMLDoc: DotNet "NPRNetXmlDocument";
    begin
        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.LoadXml(PrintXML);
        PrintLines := XMLDoc.GetElementsByTagName('print_line');
        if PrintLines.Count < 1 then
            Error(Error_PrintData);

        i := 0;
        Barcode := '';
        repeat
            XMLNode := PrintLines.ItemOf(i);
            Line := XMLNode.InnerText;
            if CopyStr(Line, 1, 2) = '11' then
                Barcode := CopyStr(Line, 3);
            i += 1;
        until (i >= (PrintLines.Count - 1)) or (Barcode <> '');

        if Barcode = '' then
            Error(Error_PrintData);
    end;

    local procedure GetSaleInfo(RecRef: RecordRef; Parameter: Text): Text
    var
        AuditRoll: Record "NPR Audit Roll";
        SalePOS: Record "NPR Sale POS";
        SalesHeader: Record "Sales Header";
        Quantity: Decimal;
        DateTime: DateTime;
    begin
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                RecRef.SetTable(AuditRoll);
            DATABASE::"NPR Sale POS":
                RecRef.SetTable(SalePOS);
            DATABASE::"Sales Header":
                RecRef.SetTable(SalesHeader);
        end;

        case Parameter of
            'operator_id':
                case RecRef.Number of
                    DATABASE::"NPR Audit Roll":
                        exit(ReplaceSpecialChars(AuditRoll."Salesperson Code"))
                end;
            'transaction_type':
                exit('1');
            'transaction_date':
                case RecRef.Number of
                    DATABASE::"NPR Audit Roll":
                        exit(Format(AuditRoll."Sale Date", 0, 9));
                end;
            'transaction_time':
                case RecRef.Number of
                    DATABASE::"NPR Audit Roll":
                        exit(Format(AuditRoll."Closing Time"));
                end;
            'invoice_number',
          'barcode_data':
                case RecRef.Number of
                    DATABASE::"NPR Audit Roll":
                        exit(ReplaceSpecialChars(AuditRoll."Sales Ticket No."))
                end;
            'number_of_items':
                case RecRef.Number of
                    DATABASE::"NPR Audit Roll":
                        begin
                            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
                            AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                            exit(Format(AuditRoll.Count));
                        end;
                end;
            'invoice_line_items':
                exit(GetSaleItemInfo(RecRef));
            'transaction_totals':
                exit(GetSaleTotals(RecRef));
            'payment_method_details':
                exit(GetSalePaymentInfo(RecRef));
            'iso_country_of_origin':
                exit('');
        end;
    end;

    local procedure GetSaleItemInfo(var RecRef: RecordRef): Text
    var
        AuditRoll: Record "NPR Audit Roll";
        SalePOS: Record "NPR Sale POS";
        SalesHeader: Record "Sales Header";
        "---": Integer;
        ItemNo: Integer;
        ItemDesc: Text;
        ItemVATRate: Text;
        ItemNetAmount: Text;
        ItemGrossAmount: Text;
        ItemVATAmount: Text;
        ItemUnitPrice: Text;
        ItemDepartmentID: Text;
        ItemQuantity: Text;
        ItemXML: Text;
    begin
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                begin
                    RecRef.SetTable(AuditRoll);
                    AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
                    AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                    AuditRoll.SetFilter(Quantity, '>0');
                    if AuditRoll.FindSet then
                        repeat

                            ItemNo += 1;

                            ItemDesc := ReplaceSpecialChars(AuditRoll.Description);
                            ItemVATRate := Format(AuditRoll."VAT %", 0, '<Precision,2:2><Standard Format,2>');
                            ItemGrossAmount := Format(AuditRoll."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>');
                            ItemNetAmount := Format(AuditRoll.Amount, 0, '<Precision,2:2><Standard Format,2>');
                            ItemVATAmount := Format(AuditRoll."Amount Including VAT" - AuditRoll.Amount, 0, '<Precision,2:2><Standard Format,2>');
                            ItemUnitPrice := Format(AuditRoll."Unit Price", 0, '<Precision,2:2><Standard Format,2>');
                            ItemDepartmentID := ReplaceSpecialChars(AuditRoll."No.");
                            ItemQuantity := Format(Round(AuditRoll.Quantity, 1, '>')); //Round up - They only accept integer quantity

                            ItemXML += '<line_item>' +
                                       '  <item_number>' + Format(ItemNo) + '</item_number>' +
                                       '  <item_description>' + ItemDesc + '</item_description>' +
                                       '  <item_vat_rate>' + ItemVATRate + '</item_vat_rate>' +
                                       '  <item_net_amount>' + ItemNetAmount + '</item_net_amount>' +
                                       '  <item_gross_amount>' + ItemGrossAmount + '</item_gross_amount>' +
                                       '  <item_vat_amount>' + ItemVATAmount + '</item_vat_amount>' +
                                       '  <individual_item_value>' + ItemUnitPrice + '</individual_item_value>' +
                                       '  <department_id>' + ItemDepartmentID + '</department_id>' +
                                       '  <item_quantity>' + ItemQuantity + '</item_quantity>' +
                                       '</line_item>';

                        until AuditRoll.Next = 0;
                end;
            DATABASE::"NPR Sale POS":
                begin
                    RecRef.SetTable(SalePOS);
                end;
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                end;
        end;

        exit(ItemXML);
    end;

    local procedure GetSalePaymentInfo(var RecRef: RecordRef): Text
    var
        AuditRoll: Record "NPR Audit Roll";
        SalePOS: Record "NPR Sale POS";
        SalesHeader: Record "Sales Header";
        "--": Integer;
        PaymentMethod: Text;
        PaymentAmount: Text;
        CardType: Text;
        MaskedCardNo: Text;
        PaymentsXML: Text;
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //See page 51 of doc. for payment methods

        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                begin
                    RecRef.SetTable(AuditRoll);
                    AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);

                    if AuditRoll.FindSet then
                        repeat
                            if PaymentTypePOS.Get(AuditRoll."No.") then begin
                                case PaymentTypePOS."Processing Type" of
                                    PaymentTypePOS."Processing Type"::Cash:
                                        PaymentMethod := '1';
                                    PaymentTypePOS."Processing Type"::"Foreign Currency":
                                        PaymentMethod := '2';

                                    PaymentTypePOS."Processing Type"::"Other Credit Cards",
                                  PaymentTypePOS."Processing Type"::"Terminal Card":
                                        PaymentMethod := '4';

                                    PaymentTypePOS."Processing Type"::"Manual Card":
                                        PaymentMethod := '11';
                                    else
                                        PaymentMethod := '13';
                                end;
                                PaymentAmount := Format(AuditRoll."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>');

                                PaymentsXML += '<payment_method_detail>' +
                                                '<payment_method>' + PaymentMethod + '</payment_method>' +
                                                '<amount>' + PaymentAmount + '</amount>' +
                                              '</payment_method_detail>';
                            end;
                        until AuditRoll.Next = 0;
                end;
            DATABASE::"NPR Sale POS":
                RecRef.SetTable(SalePOS);
            DATABASE::"Sales Header":
                RecRef.SetTable(SalesHeader);
        end;

        exit(PaymentsXML);
    end;

    local procedure GetSaleTotals(var RecRef: RecordRef): Text
    var
        AuditRoll: Record "NPR Audit Roll";
        SalePOS: Record "NPR Sale POS";
        SalesHeader: Record "Sales Header";
        "--": Integer;
        TotalNetAmount: Decimal;
        TotalGrossAmount: Decimal;
        TotalVATAmount: Decimal;
        TotalsXML: Text;
    begin
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                begin
                    RecRef.SetTable(AuditRoll);
                    AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
                    AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                    AuditRoll.SetFilter(Quantity, '>0');
                    if AuditRoll.FindSet then
                        repeat
                            TotalGrossAmount += AuditRoll."Amount Including VAT";
                            TotalNetAmount += AuditRoll.Amount;
                            TotalVATAmount += (AuditRoll."Amount Including VAT" - AuditRoll.Amount);
                        until AuditRoll.Next = 0;

                    TotalsXML := '<transaction_net_amount>' + Format(TotalNetAmount, 0, '<Precision,2:2><Standard Format,2>') + '</transaction_net_amount>' +
                                 '<transaction_gross_amount>' + Format(TotalGrossAmount, 0, '<Precision,2:2><Standard Format,2>') + '</transaction_gross_amount>' +
                                 '<transaction_vat_amount>' + Format(TotalVATAmount, 0, '<Precision,2:2><Standard Format,2>') + '</transaction_vat_amount>';
                end;
            DATABASE::"NPR Sale POS":
                RecRef.SetTable(SalePOS);
            DATABASE::"Sales Header":
                RecRef.SetTable(SalesHeader);
        end;

        exit(TotalsXML);
    end;

    [TryFunction]
    local procedure TryGetFirstNodeContent(XMLDoc: DotNet "NPRNetXmlDocument"; ElementName: Text; XMLInContent: Boolean; var Value: Text)
    begin
        Value := GetFirstNodeContent(XMLDoc, ElementName, XMLInContent);
    end;

    local procedure ReplaceSpecialChars(Text: Text): Text
    var
        CALText: Text;
        String: DotNet NPRNetString;
    begin
        String := Text;
        String := String.Replace('&', '&amp;');
        String := String.Replace('"', '&quot;');
        String := String.Replace('''', '&apos;');
        String := String.Replace('<', '&lt;');
        String := String.Replace('>', '&qt;');
        CALText := String;
        exit(CALText);
    end;

    local procedure IsStoredSaleEligible(SalesTicketNo: Text): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetFilter(Quantity, '>0');
        AuditRoll.SetFilter("VAT %", '>0');
        AuditRoll.CalcSums("Amount Including VAT");

        exit(AuditRoll."Amount Including VAT" >= MinimumAmountLimit);
    end;

    local procedure IsActiveSaleEligible(SalesTicketNo: Text): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetFilter(Quantity, '>0');
        SaleLinePOS.SetFilter("VAT %", '>0');
        SaleLinePOS.CalcSums("Amount Including VAT");

        exit(SaleLinePOS."Amount Including VAT" >= MinimumAmountLimit);
    end;

    local procedure "// Print functions"()
    begin
    end;

    local procedure PrintThermalReceipt(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        XMLNode: DotNet NPRNetXmlNode;
        i: Integer;
        Line: Text;
        LineBuffer: Text;
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        Output: Text;
        OutputType: Integer;
        XMLDoc: DotNet "NPRNetXmlDocument";
        InStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
        PrintLines: DotNet NPRNetXmlNodeList;
    begin
        //See page 55 of doc. for print line prefix explanations.
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        TaxFreeRequest.Print.CreateInStream(InStream, TEXTENCODING::UTF8);
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        MemoryStream.Position := 0;

        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.Load(MemoryStream);
        PrintLines := XMLDoc.GetElementsByTagName('print_line'); //Thermal Receipt Data
        if PrintLines.Count < 1 then
            Error(Error_PrintData);

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);

        for i := 0 to (PrintLines.Count - 1) do begin
            XMLNode := PrintLines.ItemOf(i);
            Line := XMLNode.InnerText;

            case CopyStr(Line, 1, 2) of
                '01':
                    PrintThermalLine(Printer, 'm', 'Control', false, 'LEFT', true, false); //Tax free logo bitmap
                '02':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', true, 'LEFT', true, false);
                '03':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', false, 'LEFT', true, true);
                '04':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, true);
                '05':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false);
                '06':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', true, 'LEFT', true, false);
                '07':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false); //Wide font?
                '08':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'RIGHT', true, false);
                '09':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'CENTER', true, false);
                '10':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', true, 'CENTER', true, false);
                '11':
                    if StrLen(CopyStr(Line, 3)) < 30 then
                        PrintThermalLine(Printer, CopyStr(Line, 3), 'BARCODE6', false, 'LEFT', true, false) //Barcode type: Interleaved 2-of-5
                    else
                        PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false);
                '12':
                    PrintThermalLine(Printer, ' ', 'A11', false, 'LEFT', true, false);
                '13':
                    PrintThermalLine(Printer, 'P', 'Control', false, 'LEFT', true, false);
                '14':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', false, false);
                '50':
                    ; //Load another voucher
                '51':
                    PrintThermalLine(Printer, 'COPY', 'A11', false, 'LEFT', true, false); //Print Copy?
                '61':
                    ; //remaining print is base64 encoded
                '70':
                    begin //Store logo bitmap
                        PrintThermalLine(Printer, 'h', 'Control', false, 'LEFT', true, false);
                        PrintThermalLine(Printer, 'G', 'Control', false, 'LEFT', true, false);
                    end;
                '71':
                    ; //Store signature bitmap
                '72':
                    ; //Customer signature?
                '73':
                    ; //Country specific digital signature
            end;
        end;

        Printer.ProcessBufferForCodeunit(CODEUNIT::"NPR Tax Free Receipt", ''); //Use the object output selection of old object so no new setup is needed.
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
    begin
        if Font in ['A11', 'B21', 'Control'] then begin
            Printer.SetFont(Font);
            Printer.SetBold(Bold);
            Printer.SetUnderLine(Underline);

            case Alignment of
                'LEFT':
                    Printer.AddTextField(1, 0, Value);
                'CENTER':
                    Printer.AddTextField(2, 1, Value);
                'RIGHT':
                    Printer.AddTextField(3, 2, Value);
            end;
        end;

        if Font = 'BARCODE6' then
            Printer.AddBarcode(Font, Value, 2);

        if CR then
            Printer.NewLine;
    end;

    local procedure PrintPDF(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        XMLNode: DotNet NPRNetXmlNode;
        base64: Text;
        ObjectOutputSelection: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        MemoryStream: DotNet NPRNetMemoryStream;
        ErrorText: Text;
        Convert: DotNet NPRNetConvert;
        Output: Text;
        OutputType: Integer;
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        PrintLines: DotNet NPRNetXmlNodeList;
        XMLDoc: DotNet "NPRNetXmlDocument";
        InStream: InStream;
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        TaxFreeRequest.Print.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        MemoryStream.Position := 0;

        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.Load(MemoryStream);

        PrintLines := XMLDoc.GetElementsByTagName('FormData'); //Base64 pdf data
        if PrintLines.Count <> 1 then
            Error(Error_PrintData);

        XMLNode := PrintLines.ItemOf(0);
        base64 := XMLNode.InnerText;
        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(base64));

        case OutputType of
            ObjectOutputSelection."Output Type"::"E-mail":
                PrintMethodMgt.PrintViaEmail(Output, MemoryStream);
            ObjectOutputSelection."Output Type"::"Printer Name":
                PrintMethodMgt.PrintFileLocal(Output, MemoryStream, 'pdf');
        end;
    end;

    #region Web Service Request functions"

    local procedure BRTSearchRequest(var TaxFreeRequest: Record "NPR Tax Free Request"; IIN: Text)
    var
        RequestBody: Text;
    begin
        RequestBody :=
        '<v2:PerformBRTSearch xmlns:v2="http://yes.fintrax.com/piserver/v2/">' +
          '<v2:XMLString><![CDATA[<?xml version="1.0" encoding="utf-8"?>' +
            '<BRTSearchRequest>' +
              '<xml_message_type>CS perform BRT search</xml_message_type>' +
              '<version>' +
                '<xml_version>2.0</xml_version>' +
                '<pos_application_version>NP Retail</pos_application_version>' +
              '</version>' +
              '<terminal>' +
                '<terminal_id>' + POSUnitNo + '</terminal_id>' +
                '<training_mode>0</training_mode>' +
                '<merchant_id>' + MerchantID + '</merchant_id>' +
                '<merchant_vat_number>' + VATNumber + '</merchant_vat_number>' +
                '<merchant_country_code>' + Format(CountryCode) + '</merchant_country_code>' +
              '</terminal>' +
              '<operator_info>' +
                '<operator_id>' + ReplaceSpecialChars(TaxFreeRequest."Salesperson Code") + '</operator_id>' +
              '</operator_info>' +
              '<card_number>' + IIN + '</card_number>' +
              '<respond_in_language>' + Format(CountryCode) + '</respond_in_language>' +
            '</BRTSearchRequest>]]>' +
          '</v2:XMLString>' +
        '</v2:PerformBRTSearch>';

        RequestBody := WrapSOAPEnvelope(RequestBody);
        InvokeService(RequestBody, TaxFreeRequest);
    end;

    local procedure InsertInvoiceRequest(var TaxFreeRequest: Record "NPR Tax Free Request"; var RecRef: RecordRef)
    var
        RequestBody: Text;
    begin
        RequestBody :=
        '<v2:InsertInvoice xmlns:v2="http://yes.fintrax.com/piserver/v2/">' +
        '  <v2:strInvoiceXML><![CDATA[<?xml version="1.0" encoding="utf-8"?>' +
        '    <taxfree_transaction_data>' +
        '      <version>' +
        '        <xml_version>2.0</xml_version>' +
        '        <pos_application_version>NP Retail</pos_application_version>' +
        '      </version>' +
        '      <merchant_data>' +
        '        <merchant_vat_number>' + VATNumber + '</merchant_vat_number>' +
        '        <merchant_country_code>' + Format(CountryCode) + '</merchant_country_code>' +
        '        <merchant_id>' + MerchantID + '</merchant_id>' +
        '      </merchant_data>' +
        '      <terminal>' +
        '        <terminal_id>' + POSUnitNo + '</terminal_id>' +
        '        <training_mode>0</training_mode>' +
        '      </terminal>' +
        '      <operator_info>' +
        '        <operator_id>' + GetSaleInfo(RecRef, 'operator_id') + '</operator_id>' +
        '      </operator_info>' +
        '      <transaction_header>' +
        '        <transaction_type>' + GetSaleInfo(RecRef, 'transaction_type') + '</transaction_type>' +
        '        <transaction_date>' + GetSaleInfo(RecRef, 'transaction_date') + '</transaction_date>' +
        '        <transaction_time>' + GetSaleInfo(RecRef, 'transaction_time') + '</transaction_time>' +
        '        <invoice_number>' + GetSaleInfo(RecRef, 'invoice_number') + '</invoice_number>' +
        '        <barcode_data>' + GetSaleInfo(RecRef, 'barcode_data') + '</barcode_data>' +
        '        <number_of_items>' + GetSaleInfo(RecRef, 'number_of_items') + '</number_of_items>' +
        '      </transaction_header>' +
        '      <original_invoice />' +
        '      <invoice_line_items>' +
                 GetSaleInfo(RecRef, 'invoice_line_items') +
        '      </invoice_line_items>' +
        '      <transaction_totals>' +
                 GetSaleInfo(RecRef, 'transaction_totals') +
        '      </transaction_totals>' +
        '      <payment_method_details>' +
                   GetSaleInfo(RecRef, 'payment_method_details') +
        '      </payment_method_details>' +
        '      <customer_data>' +
        '      </customer_data>' +
        '      <loyality>' +
        '        <customer_loyalty_number />' +
        '      </loyality>' +
        '    </taxfree_transaction_data>]]>' +
        '  </v2:strInvoiceXML>' +
        '</v2:InsertInvoice>';

        RequestBody := WrapSOAPEnvelope(RequestBody);
        InvokeService(RequestBody, TaxFreeRequest);
    end;

    local procedure CreateVoucherRequest(var TaxFreeRequest: Record "NPR Tax Free Request"; var RecRef: RecordRef)
    var
        RequestBody: Text;
    begin
        RequestBody :=
        '<v2:CreateVoucher xmlns:v2="http://yes.fintrax.com/piserver/v2/">' +
        '  <v2:sXML><![CDATA[<?xml version="1.0" encoding="utf-8"?>' +
        '    <create_voucher>' +
        '      <xml_message_type>CS create voucher</xml_message_type>' +
        '      <version>' +
        '        <xml_version>2.0</xml_version>' +
        '        <pos_application_version>NP Retail</pos_application_version>' +
        '      </version>' +
        '      <terminal>' +
        '        <terminal_id>' + POSUnitNo + '</terminal_id>' +
        '        <merchant_id>' + MerchantID + '</merchant_id>' +
        '        <merchant_vat_number>' + VATNumber + '</merchant_vat_number>' +
        '        <training_mode>0</training_mode>' +
        '        <merchant_country_code>' + Format(CountryCode) + '</merchant_country_code>' +
        '      </terminal>' +
        '      <operator_info>' +
        '        <operator_id>' + GetSaleInfo(RecRef, 'operator_id') + '</operator_id>' +
        '      </operator_info>' +
        '      <number_of_invoices>1</number_of_invoices>' +
        '      <voucher_info>' +
        '        <barcodes>' +
        '          <barcode_data>' + GetSaleInfo(RecRef, 'barcode_data') + '</barcode_data>' +
        '        </barcodes>' +
        '        <voucher_formula>' +
        '        </voucher_formula>' +
        '        <voucher_design>1</voucher_design>' +
        '      </voucher_info>' +
        '      <customer_data>' +
        '      </customer_data>' +
        '    </create_voucher>]]>' +
        '  </v2:sXML>' +
        '</v2:CreateVoucher>';

        RequestBody := WrapSOAPEnvelope(RequestBody);
        InvokeService(RequestBody, TaxFreeRequest);
    end;

    local procedure VoidVoucherRequest(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text)
    var
        RequestBody: Text;
    begin
        RequestBody :=
        '<v2:VoidVoucher xmlns:v2="http://yes.fintrax.com/piserver/v2/">' +
        '  <v2:voidVoucherXML><![CDATA[<?xml version="1.0" encoding="utf-8"?>' +
        '    <void_voucher>' +
        '      <xml_message_type>CS void voucher</xml_message_type>' +
        '      <version>' +
        '        <xml_version>2.0</xml_version>' +
        '        <pos_application_version>NP Retail</pos_application_version>' +
        '      </version>' +
        '      <terminal>' +
        '        <terminal_id>' + POSUnitNo + '</terminal_id>' +
        '        <merchant_id>' + MerchantID + '</merchant_id>' +
        '        <merchant_vat_number>' + VATNumber + '</merchant_vat_number>' +
        '        <training_mode>0</training_mode>' +
        '        <merchant_country_code>' + Format(CountryCode) + '</merchant_country_code>' +
        '      </terminal>' +
        '      <operator_info>' +
        '        <operator_id></operator_id>' +
        '      </operator_info>' +
        '      <voucher_number>' + VoucherNo + '</voucher_number>' +
        '    </void_voucher>]]>' +
        '  </v2:voidVoucherXML>' +
        '</v2:VoidVoucher>';

        RequestBody := WrapSOAPEnvelope(RequestBody);
        InvokeService(RequestBody, TaxFreeRequest);
    end;

    local procedure WrapSOAPEnvelope(RequestBody: Text): Text
    begin
        exit('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">' +
             '  <soap:Body>' +
                  RequestBody +
             '  </soap:Body>' +
             '</soap:Envelope>');
    end;

    local procedure InvokeService(RequestMessage: Text; var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        BaseAddress: Text;
        HttpClient: DotNet NPRNetHttpClient;
        Uri: DotNet NPRNetUri;
        TimeSpan: DotNet NPRNetTimeSpan;
        StringContent: DotNet NPRNetStringContent;
        Encoding: DotNet NPRNetEncoding;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        OutStream: OutStream;
        Result: Text;
    begin
        Clear(TaxFreeRequest.Request);
        Clear(TaxFreeRequest.Response);

        TaxFreeRequest.Request.CreateOutStream(OutStream);
        OutStream.Write(RequestMessage);

        HttpClient := HttpClient.HttpClient();
        HttpClient.DefaultRequestHeaders.Clear();

        if TaxFreeRequest.Mode = TaxFreeRequest.Mode::PROD then
            HttpClient.BaseAddress := Uri.Uri(ServicePROD)
        else
            HttpClient.BaseAddress := Uri.Uri(ServiceTEST);

        if TaxFreeRequest."Timeout (ms)" > 0 then
            HttpClient.Timeout := TimeSpan.TimeSpan(0, 0, 0, TaxFreeRequest."Timeout (ms)")
        else
            HttpClient.Timeout := TimeSpan.TimeSpan(0, 0, 10);

        StringContent := StringContent.StringContent(RequestMessage, Encoding.UTF8, 'application/soap+xml');
        HttpResponseMessage := HttpClient.PostAsync('', StringContent).Result();

        TaxFreeRequest.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        Result := HttpResponseMessage.Content.ReadAsStringAsync().Result();
        OutStream.Write(Result);
    end;

    local procedure HandleResponse(var TaxFreeRequest: Record "NPR Tax Free Request"; ResponseTagName: Text; var XMLDoc: DotNet "NPRNetXmlDocument")
    var
        InStream: InStream;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        TaxFreeRequest.Response.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        MemoryStream.Position := 0;

        XMLDoc := XMLDoc.XmlDocument;
        XMLDoc.Load(MemoryStream);
        GetCDataXML(XMLDoc, ResponseTagName);
    end;

    #endregion

    #region Event subscribers

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandler', '', false, false)]
    local procedure OnLookupHandler(var HashSet: DotNet NPRNetHashSet_Of_T)
    begin
        HashSet.Add(HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandlerParameters', '', false, false)]
    local procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        AddParameters(tmpHandlerParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnSetUnitParameters', '', false, false)]
    local procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
    var
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        TaxFreeMgt.SetGenericHandlerParameters(TaxFreeUnit); //Use the built-in support for storing parameters in the unit BLOB instead of externally.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitAutoConfigure', '', false, false)]
    local procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitTestConnection', '', false, false)]
    local procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request"; var Handled: Boolean)
    var
        Valid: Boolean;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;

        InitializeHandler(TaxFreeRequest);
        //498692 is a random IIN number from some japanese card type. Here we use it to test that the service works as expected by verifying that the response for validity is TRUE.
        Valid := IsValidTerminalIIN(TaxFreeRequest, '498692XXXXXXXXXX');

        if not Valid then
            Error(Error_WrongIINDecision);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherIssueFromPOSSale', '', false, false)]
    local procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var Handled: Boolean; var SkipRecordHandling: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        RecRef: RecordRef;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);

        if not IsStoredSaleEligible(SalesReceiptNo) then
            Error(Error_Ineligible);

        AuditRoll.SetRange("Sales Ticket No.", SalesReceiptNo);
        AuditRoll.FindSet;
        RecRef.GetTable(AuditRoll);

        VoucherIssue(TaxFreeRequest, RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherVoid', '', false, false)]
    local procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        VoucherVoid(TaxFreeRequest, TaxFreeVoucher."External Voucher No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherReissue', '', false, false)]
    local procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherLookup', '', false, false)]
    local procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, TaxFreeRequest."Handler ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherPrint', '', false, false)]
    local procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;

        if not IsRecentVoucher then
            if not TaxFreeVoucher.Print.HasValue then
                Error(Error_MissingPrint);

        ClearLastError;
        if not TryPrintVoucher(TaxFreeRequest) then
            Error(Error_PrintFail, TaxFreeVoucher."External Voucher No.", GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherConsolidate', '', false, false)]
    local procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsValidTerminalIIN', '', false, false)]
    local procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        IsForeignIIN := IsValidTerminalIIN(TaxFreeRequest, MaskedCardNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsActiveSaleEligible', '', false, false)]
    local procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsActiveSaleEligible(SalesTicketNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsStoredSaleEligible', '', false, false)]
    local procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsStoredSaleEligible(SalesTicketNo);
    end;

    #endregion
}
