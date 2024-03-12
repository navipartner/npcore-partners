codeunit 6184659 "NPR IT Printer Mgt."
{
    Access = Internal;

    var
        FieldSuccessfullyUpdatedMsg: Label '%1 field in %2 has been successfully updated.', Comment = '%1 = Field Caption, %2 = Table Caption';
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true, Comment = '%1 = Element Name';
        RequestMethod: Option checkLoginStatus,setLogo,logInPrinter,getRTType,getSerialNo,getPaymentMethods,getVATSetup,printReceipt,printZReport,printXReport,printLastReceipt,setUpVATDepartments,setUpPaymMeth,printEJReport,cashMgt;

    #region IT Printer Communication - Responses

    internal procedure ProcessFPrinterPrintReceiptRespose(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info"; ResponseToken: JsonToken)
    var
        ReceiptNumber: Text;
        ZReportNumber: Text;
        ResponseText: Text;
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, 0);

        ChildNode.WriteTo(ResponseText);
        StoreITPOSAuditResponseContent(ITPOSAuditLogAuxInfo, ResponseText);

        if not IsResponseSuccessful(ChildNode, RequestMethod::printReceipt) then
            exit;

        if not ITPOSUnitMapping.Get(ITPOSAuditLogAuxInfo."POS Unit No.") then
            exit;

        GetReceiptNumberFromNode(ChildNode, ReceiptNumber);

        GetZReportNumberFromNode(ChildNode, ZReportNumber);

        ITPOSAuditLogAuxInfo."Receipt No." := CopyStr(ReceiptNumber.PadLeft(4, '0'), 1, MaxStrLen(ITPOSAuditLogAuxInfo."Receipt No."));
        ITPOSAuditLogAuxInfo."Z Report No." := CopyStr(ZReportNumber.PadLeft(4, '0'), 1, MaxStrLen(ITPOSAuditLogAuxInfo."Z Report No."));
        ITPOSAuditLogAuxInfo."Receipt Fiscalized" := true;
        ITPOSAuditLogAuxInfo."Fiscal Printer Serial No." := CopyStr(FormatFiscalPrinterModel(ITPOSUnitMapping), 1, MaxStrLen(ITPOSAuditLogAuxInfo."Fiscal Printer Serial No."));
        ITPOSAuditLogAuxInfo.Modify();
    end;

    internal procedure ProcessFPrinterLoginResponse(ResponseToken: JsonToken)
    var
        IsPrinterLoggedIn: Boolean;
        FPLoginSuccessfullMsg: Label 'Fiscal Printer has been logged in successfully.';
        FPLoginUnsuccessfullErr: Label 'Communication for Fiscal Printer Login was not successful.';
        ResponseData: Text;
        ChildNode: XmlNode;
    begin
        IsPrinterLoggedIn := IsFPrinterLoggedInResponseCheck(ResponseToken, 0);

        if IsPrinterLoggedIn then begin
            Message(FPLoginSuccessfullMsg);
            exit;
        end;

        ChildNode := SelectResponseNode(ResponseToken, 1);
        IsResponseSuccessful(ChildNode, RequestMethod::logInPrinter);
        GetResponseDataFromNode(ChildNode, ResponseData);
        if not ((CopyStr(ResponseData, 1, 2) = '12') or (CopyStr(ResponseData, 1, 2) = '01')) then
            Error(FPLoginUnsuccessfullErr);

        Message(FPLoginSuccessfullMsg);
    end;

    internal procedure ProcessFPrinterModelResponse(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseToken: JsonToken)
    begin
        if ITPOSUnitMapping."Fiscal Printer RT Type" = '' then
            ProcessFPrinterRTTypeResponse(ITPOSUnitMapping, 0, ResponseToken);
        if ITPOSUnitMapping."Fiscal Printer Serial No." = '' then
            ProcessFPrinterSerialNoResponse(ITPOSUnitMapping, 1, ResponseToken);
    end;

    internal procedure ProcessFPrinterPrintZReportResponse(ResponseToken: JsonToken)
    var
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, 0);

        IsResponseSuccessful(ChildNode, RequestMethod::printZReport);
    end;

    internal procedure ProcessFPrinterPrintXReportResponse(ResponseToken: JsonToken)
    var
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, 0);

        IsResponseSuccessful(ChildNode, RequestMethod::printXReport);
    end;

    internal procedure ProcessFPrinterEJReportPrintResponse(ResponseToken: JsonToken)
    var
        PrintEJReportRequestUnsuccessfullErr: Label 'Printing of the Electronic Journal Report failed. Please try again.';
        ResponseData: Text;
        ResponseText: Text;
        ResponseDocument: XmlDocument;
        ChildNode: XmlNode;
    begin
        ResponseToken.WriteTo(ResponseText);
        FormatResponseString(ResponseText);
        XmlDocument.ReadFrom(ResponseText, ResponseDocument);
        ResponseDocument.GetChildElements().Get(1, ChildNode);

        IsResponseSuccessful(ChildNode, RequestMethod::printEJReport);

        GetResponseDataFromNode(ChildNode, ResponseData);

        if not (ResponseData = '01') then
            Error(PrintEJReportRequestUnsuccessfullErr);
    end;

    internal procedure ProcessFPrinterCashHandlingResponse(ResponseToken: JsonToken)
    var
        ResponseText: Text;
        ResponseDocument: XmlDocument;
        ChildNode: XmlNode;
    begin
        ResponseToken.WriteTo(ResponseText);
        FormatResponseString(ResponseText);
        XmlDocument.ReadFrom(ResponseText, ResponseDocument);
        ResponseDocument.GetChildElements().Get(1, ChildNode);

        IsResponseSuccessful(ChildNode, RequestMethod::cashMgt);
    end;

    internal procedure ProcessFPrinterPrintLastReceiptResponse(ResponseToken: JsonToken)
    var
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, 0);

        IsResponseSuccessful(ChildNode, RequestMethod::printLastReceipt);
    end;

    local procedure IsFPrinterLoggedInResponseCheck(ResponseToken: JsonToken; ResponseIndex: Integer): Boolean
    var
        ResponseData: Text;
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, ResponseIndex);

        if not IsResponseSuccessful(ChildNode, RequestMethod::checkLoginStatus) then
            exit;

        GetResponseDataFromNode(ChildNode, ResponseData);

        if (CopyStr(ResponseData, 1, 3) = '200') then
            exit(true);
        exit(false);
    end;

    local procedure ProcessFPrinterRTTypeResponse(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseIndex: Integer; ResponseToken: JsonToken)
    var
        ResponseData: Text;
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, ResponseIndex);

        if not IsResponseSuccessful(ChildNode, RequestMethod::getRTType) then
            exit;

        GetResponseDataFromNode(ChildNode, ResponseData);
        FormatPrinterRTTypeData(ResponseData);

        ITPOSUnitMapping."Fiscal Printer RT Type" := CopyStr(ResponseData, 1, MaxStrLen(ITPOSUnitMapping."Fiscal Printer RT Type"));
        ITPOSUnitMapping.Modify();

        Message(StrSubstNo(FieldSuccessfullyUpdatedMsg, ITPOSUnitMapping.FieldCaption("Fiscal Printer RT Type"), ITPOSUnitMapping.TableCaption));
    end;

    local procedure ProcessFPrinterSerialNoResponse(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseIndex: Integer; ResponseToken: JsonToken)
    var
        ResponseData: Text;
        SerialNoData: Text;
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, ResponseIndex);

        if not IsResponseSuccessful(ChildNode, RequestMethod::getSerialNo) then
            exit;

        GetResponseDataFromNode(ChildNode, ResponseData);
        FormatPrinterSerialNoData(ResponseData, SerialNoData);

        ITPOSUnitMapping."Fiscal Printer Serial No." := CopyStr(SerialNoData, 1, MaxStrLen(ITPOSUnitMapping."Fiscal Printer Serial No."));
        ITPOSUnitMapping.Modify();

        Message(StrSubstNo(FieldSuccessfullyUpdatedMsg, ITPOSUnitMapping.FieldCaption("Fiscal Printer Serial No."), ITPOSUnitMapping.TableCaption));
    end;

#if not (BC17 or BC18 or BC19) 
    internal procedure ProcessFPrinterSetLogoResponse(ResponseToken: JsonToken)
    var
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, 0);

        IsResponseSuccessful(ChildNode, RequestMethod::setLogo);
    end;
#endif
    #endregion

    #region IT Printer Communication - Request Messages

    internal procedure CreatePrinterCommandRequestMessage(CommandContent: XmlElement) RequestText: Text
    var
        Document: XmlDocument;
        PrinterCommand: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        PrinterCommand := XmlElement.Create('printerCommand');
        PrinterCommand.Add(CommandContent);

        SoapEnvelopeBody.Add(PrinterCommand);

        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);
    end;

    internal procedure CreateZReportPrintRequestMessage() RequestText: Text
    var
        Document: XmlDocument;
        PrintReportElement: XmlElement;
        PrintZReportElement: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        PrintReportElement := XmlElement.Create('printerFiscalReport');

        PrintZReportElement := XmlElement.Create('printZReport');
        AddAttributeToElement(PrintZReportElement, 'operator', '1');
        AddAttributeToElement(PrintZReportElement, 'timeout', '12000');

        PrintReportElement.Add(PrintZReportElement);

        SoapEnvelopeBody.Add(PrintReportElement);

        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);
    end;

    internal procedure CreateXReportPrintRequestMessage() RequestText: Text
    var
        Document: XmlDocument;
        PrintReportElement: XmlElement;
        PrintXReportElement: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        PrintReportElement := XmlElement.Create('printerFiscalReport');

        PrintXReportElement := XmlElement.Create('printXReport');
        AddAttributeToElement(PrintXReportElement, 'operator', '1');
        AddAttributeToElement(PrintXReportElement, 'timeout', '12000');

        PrintReportElement.Add(PrintXReportElement);

        SoapEnvelopeBody.Add(PrintReportElement);

        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);
    end;

    internal procedure CreateDummyFirstRequest(var Requests: JsonArray)
    var
        ITPrinterMgt: Codeunit "NPR IT Printer Mgt.";
        Request: JsonObject;
    begin
        Request.Remove('requestBody');
        Request.Remove('index');
        Request.Add('index', 0);
        Request.Add('requestBody', ITPrinterMgt.CreatePrinterCommandRequestMessage(ITPrinterMgt.CreateDirectIOCommand('4205', Format("NPR IT Printer Departments".FromInteger(1)))));
        Requests.Add(Request);
    end;

    internal procedure CreateNormalSaleRequestMessage(var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info") RequestText: Text
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
        FiscalReceiptBegin: XmlElement;
        FiscalReceiptBody: XmlElement;
        FiscalReceiptEnd: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        if not POSEntry.Get(ITPOSAuditLogAuxInfo."POS Entry No.") then
            exit;

        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Exclude from Posting", false);
        POSEntrySalesLine.SetFilter(Quantity, '>0');
        if not POSEntrySalesLine.FindSet() then
            exit;

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter(Amount, '>0');
        if not POSEntryPaymentLine.FindSet() then
            exit;

        FiscalReceiptBody := XmlElement.Create('printerFiscalReceipt');
        FiscalReceiptBegin := XmlElement.Create('beginFiscalReceipt');
        FiscalReceiptEnd := XmlElement.Create('endFiscalReceipt');
        AddAttributeToElement(FiscalReceiptBegin, 'operator', '1');
        AddAttributeToElement(FiscalReceiptEnd, 'operator', '1');
        FiscalReceiptBody.Add(FiscalReceiptBegin);

        repeat
            PrintRecItem(FiscalReceiptBody, POSEntrySalesLine);
        until POSEntrySalesLine.Next() = 0;

        PrintRecLotteryCode(FiscalReceiptBody, ITPOSAuditLogAuxInfo);

        repeat
            PrintRecTotal(FiscalReceiptBody, POSEntryPaymentLine);
        until POSEntryPaymentLine.Next() = 0;

        FiscalReceiptBody.Add(FiscalReceiptEnd);

        SoapEnvelopeBody.Add(FiscalReceiptBody);
        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);

        StoreITPOSAuditRequestContent(ITPOSAuditLogAuxInfo, RequestText);
    end;

    internal procedure CreatePrinterCashHandlingRequestMessage(Amount: Decimal; Direction: Option in,out; Form: Option cash,cheque) CashMgtElement: XmlElement
    begin
        CashMgtElement := XmlElement.Create('printRecCash');
        AddAttributeToElement(CashMgtElement, 'operator', '01');
        AddAttributeToElement(CashMgtElement, 'direction', Format(Direction));
        AddAttributeToElement(CashMgtElement, 'form', Format(Form));
        AddAttributeToElement(CashMgtElement, 'amount', Format(Amount));
    end;

    local procedure PrintRecItem(var FiscalReceiptElement: XmlElement; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook";
        ITVATDepartmentNotFoundErr: Label 'Printer IT VAT Deparment for VAT % %1 was not found. Please check your Printer''s settings or use action for initializing departments from printer directly.', Comment = '%1 = VAT %';
        ItemAdjustment: XmlElement;
        PrintItemElement: XmlElement;
    begin
        PrintItemElement := XmlElement.Create('printRecItem');
        AddAttributeToElement(PrintItemElement, 'operator', '1');
        AddAttributeToElement(PrintItemElement, 'description', POSEntrySalesLine.Description);
        AddAttributeToElement(PrintItemElement, 'quantity', Format(Abs(POSEntrySalesLine.Quantity)));
        AddAttributeToElement(PrintItemElement, 'unitPrice', FormatPriceAmount(Abs(POSEntrySalesLine."Unit Price")));

        ITVATDepartmentCodebook.SetRange("POS Unit No.", POSEntrySalesLine."POS Unit No.");
        ITVATDepartmentCodebook.SetFilter("IT Printer VAT %", Format(POSEntrySalesLine."VAT %", 0, '<Precision,2><Integer Thousand><Decimals,2><Comma,.>'));
        if POSEntrySalesLine."VAT %" = 0 then
            AddAttributeToElement(PrintItemElement, 'department', '10')
        else begin
            if not ITVATDepartmentCodebook.FindFirst() and GuiAllowed then
                Error(ITVATDepartmentNotFoundErr, POSEntrySalesLine."VAT %");
            AddAttributeToElement(PrintItemElement, 'department', Format(ITVATDepartmentCodebook."IT Printer VAT Department"));
        end;
        AddAttributeToElement(PrintItemElement, 'justification', '1');

        FiscalReceiptElement.Add(PrintItemElement);

        if POSEntrySalesLine."Line Discount %" = 0 then
            exit;
        ItemAdjustment := XmlElement.Create('printRecItemAdjustment');
        AddAttributeToElement(ItemAdjustment, 'operator', '1');
        AddAttributeToElement(ItemAdjustment, 'description', 'Line Discount');
        AddAttributeToElement(ItemAdjustment, 'adjustmentType', '0');
        AddAttributeToElement(ItemAdjustment, 'amount', FormatPriceAmount(POSEntrySalesLine."Line Discount Amount Incl. VAT"));
        AddAttributeToElement(ItemAdjustment, 'justification', '2');

        FiscalReceiptElement.Add(ItemAdjustment);
    end;

    local procedure PrintRecRefund(var FiscalReceiptElement: XmlElement; POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook";
        ITVATDepartmentNotFoundErr: Label 'Printer IT VAT Deparment for VAT % %1 was not found. Please check your Printer''s settings or use action for initializing departments from printer directly.', Comment = '%1 = VAT %';
        ItemAdjustment: XmlElement;
        PrintItemElement: XmlElement;
    begin
        PrintItemElement := XmlElement.Create('printRecRefund');
        AddAttributeToElement(PrintItemElement, 'operator', '1');
        AddAttributeToElement(PrintItemElement, 'description', POSEntrySalesLine.Description);
        AddAttributeToElement(PrintItemElement, 'quantity', Format(Abs(POSEntrySalesLine.Quantity)));
        AddAttributeToElement(PrintItemElement, 'unitPrice', FormatPriceAmount(Abs(POSEntrySalesLine."Unit Price")));

        ITVATDepartmentCodebook.SetRange("POS Unit No.", POSEntrySalesLine."POS Unit No.");
        ITVATDepartmentCodebook.SetFilter("IT Printer VAT %", Format(POSEntrySalesLine."VAT %", 0, '<Precision,2><Integer Thousand><Decimals,2><Comma,.>'));
        if POSEntrySalesLine."VAT %" = 0 then
            AddAttributeToElement(PrintItemElement, 'department', '10')
        else begin
            if not ITVATDepartmentCodebook.FindFirst() and GuiAllowed then
                Error(ITVATDepartmentNotFoundErr, POSEntrySalesLine."VAT %");
            AddAttributeToElement(PrintItemElement, 'department', Format(ITVATDepartmentCodebook."IT Printer VAT Department"));
        end;
        AddAttributeToElement(PrintItemElement, 'justification', '1');

        FiscalReceiptElement.Add(PrintItemElement);

        if POSEntrySalesLine."Line Discount %" = 0 then
            exit;
        ItemAdjustment := XmlElement.Create('printRecItemAdjustment');
        AddAttributeToElement(ItemAdjustment, 'operator', '1');
        AddAttributeToElement(ItemAdjustment, 'description', 'Line Discount');
        AddAttributeToElement(ItemAdjustment, 'adjustmentType', '0');
        AddAttributeToElement(ItemAdjustment, 'amount', FormatPriceAmount(POSEntrySalesLine."Line Discount Amount Incl. VAT"));
        AddAttributeToElement(ItemAdjustment, 'justification', '2');

        FiscalReceiptElement.Add(ItemAdjustment);
    end;


    local procedure PrintRecLotteryCode(var FiscalReceiptElement: XmlElement; ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info")
    var
        PrintRecLotteryElement: XmlElement;
    begin
        if ITPOSAuditLogAuxInfo."Customer Lottery Code" = '' then
            exit;
        PrintRecLotteryElement := XmlElement.Create('printRecLotteryID');
        AddAttributeToElement(PrintRecLotteryElement, 'operator', '1');
        AddAttributeToElement(PrintRecLotteryElement, 'code', ITPOSAuditLogAuxInfo."Customer Lottery Code");
        FiscalReceiptElement.Add(PrintRecLotteryElement);
    end;

    local procedure PrintRecTotal(var FiscalReceiptElement: XmlElement; POSEntryPaymentLine: Record "NPR POS Entry Payment Line")
    var
        ITPOSPaymentMethodMapp: Record "NPR IT POS Paym. Method Mapp.";
        ITPOSPaymentMethodMappNotFoundErr: Label 'POS Payment Method Mapping has not been found for Payment Method Code: %1. Please add the correct record to %2', Comment = '%1 = Payment Method Code, %2 = Payment Method Mapping Table';
        PrintRecTotalElement: XmlElement;
    begin
        if not IsPaymentLineVoucher(POSEntryPaymentLine) then begin
            ITPOSPaymentMethodMapp.SetRange("Payment Method Code", POSEntryPaymentLine."POS Payment Method Code");
            ITPOSPaymentMethodMapp.SetRange("POS Unit No.", POSEntryPaymentLine."POS Unit No.");
            if not ITPOSPaymentMethodMapp.FindFirst() and GuiAllowed then
                Error(ITPOSPaymentMethodMappNotFoundErr, POSEntryPaymentLine."POS Payment Method Code", ITPOSPaymentMethodMapp.TableCaption);
            PrintRecTotalElement := XmlElement.Create('printRecTotal');
            AddAttributeToElement(PrintRecTotalElement, 'operator', '1');
            AddAttributeToElement(PrintRecTotalElement, 'description', ITPOSPaymentMethodMapp."IT Payment Method Description");
            AddAttributeToElement(PrintRecTotalElement, 'payment', FormatPriceAmount(Abs(POSEntryPaymentLine.Amount)));
            AddAttributeToElement(PrintRecTotalElement, 'paymentType', Format(ITPOSPaymentMethodMapp."IT Payment Method".AsInteger()));
            AddAttributeToElement(PrintRecTotalElement, 'index', Format(ITPOSPaymentMethodMapp."IT Payment Method Index"));
        end else begin
            PrintRecTotalElement := XmlElement.Create('printRecSubtotalAdjustment');
            AddAttributeToElement(PrintRecTotalElement, 'operator', '1');
            AddAttributeToElement(PrintRecTotalElement, 'adjustmentType', '1');
            AddAttributeToElement(PrintRecTotalElement, 'description', ITPOSPaymentMethodMapp."IT Payment Method Description");
            AddAttributeToElement(PrintRecTotalElement, 'amount', FormatPriceAmount(Abs(POSEntryPaymentLine."Amount (LCY)")));
        end;
        AddAttributeToElement(PrintRecTotalElement, 'justification', '2');
        FiscalReceiptElement.Add(PrintRecTotalElement);
    end;

    internal procedure CreateNormalRefundRequestMessage(var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info") RequestText: Text
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
        FiscalReceiptBegin: XmlElement;
        FiscalReceiptBody: XmlElement;
        FiscalReceiptEnd: XmlElement;
        RefundMessage: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        if not POSEntry.Get(ITPOSAuditLogAuxInfo."POS Entry No.") then
            exit;

        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '<0');
        if not POSEntrySalesLine.FindSet() then
            exit;

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if not POSEntryPaymentLine.FindSet() then
            exit;

        FiscalReceiptBody := XmlElement.Create('printerFiscalReceipt');
        RefundMessage := XmlElement.Create('printRecMessage');
        FiscalReceiptBegin := XmlElement.Create('beginFiscalReceipt');
        FiscalReceiptEnd := XmlElement.Create('endFiscalReceipt');

        AddAttributeToElement(RefundMessage, 'operator', '1');
        AddAttributeToElement(RefundMessage, 'message', FormatRefundReceiptMessage(ITPOSAuditLogAuxInfo));
        AddAttributeToElement(RefundMessage, 'messageType', '4');

        AddAttributeToElement(FiscalReceiptBegin, 'operator', '1');
        AddAttributeToElement(FiscalReceiptEnd, 'operator', '1');

        FiscalReceiptBody.Add(RefundMessage);
        FiscalReceiptBody.Add(FiscalReceiptBegin);

        repeat
            PrintRecRefund(FiscalReceiptBody, POSEntrySalesLine);
        until POSEntrySalesLine.Next() = 0;

        repeat
            PrintRecTotal(FiscalReceiptBody, POSEntryPaymentLine);
        until POSEntryPaymentLine.Next() = 0;

        FiscalReceiptBody.Add(FiscalReceiptEnd);

        SoapEnvelopeBody.Add(FiscalReceiptBody);
        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);

        StoreITPOSAuditRequestContent(ITPOSAuditLogAuxInfo, RequestText);
    end;

    internal procedure CreatePrepaymentRefundRequestMessage(ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info") RequestText: Text
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
        FiscalReceiptBegin: XmlElement;
        FiscalReceiptBody: XmlElement;
        FiscalReceiptEnd: XmlElement;
        RefundMessage: XmlElement;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
    begin
        if not POSEntry.Get(ITPOSAuditLogAuxInfo."POS Entry No.") then
            exit;

        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Exclude from Posting", false);
        POSEntrySalesLine.SetFilter(Quantity, '>0');
        POSEntrySalesLine.SetFilter(Type, '<>%1', POSEntrySalesLine.Type::Item);
        if not POSEntrySalesLine.FindSet() then
            exit;

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if not POSEntryPaymentLine.FindSet() then
            exit;

        FiscalReceiptBody := XmlElement.Create('printerFiscalReceipt');
        RefundMessage := XmlElement.Create('printRecMessage');
        FiscalReceiptBegin := XmlElement.Create('beginFiscalReceipt');
        FiscalReceiptEnd := XmlElement.Create('endFiscalReceipt');

        AddAttributeToElement(RefundMessage, 'operator', '1');
        AddAttributeToElement(RefundMessage, 'message', FormatRefundReceiptMessage(ITPOSAuditLogAuxInfo));
        AddAttributeToElement(RefundMessage, 'messageType', '4');

        AddAttributeToElement(FiscalReceiptBegin, 'operator', '1');
        AddAttributeToElement(FiscalReceiptEnd, 'operator', '1');

        FiscalReceiptBody.Add(RefundMessage);
        FiscalReceiptBody.Add(FiscalReceiptBegin);

        repeat
            PrintRecItem(FiscalReceiptBody, POSEntrySalesLine);
        until POSEntrySalesLine.Next() = 0;

        repeat
            PrintRecTotal(FiscalReceiptBody, POSEntryPaymentLine);
        until POSEntryPaymentLine.Next() = 0;

        FiscalReceiptBody.Add(FiscalReceiptEnd);

        SoapEnvelopeBody.Add(FiscalReceiptBody);
        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);
    end;

    internal procedure CreateRequestsForPOSPaymentMethodMapping(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; var Requests: JsonArray)
    var
        RequestIndex: Integer;
        i: Integer;
    begin
        RequestIndex := 1;
        for i := 1 to 5 do begin
            AddRequestToRequestsArray(ITPOSUnitMapping, Requests, RequestIndex, CreatePrinterCommandRequestMessage(CreateDirectIOCommand('4253', Format(i).PadLeft(2, '0'))));
            RequestIndex := RequestIndex + 1;
        end;

        for i := 1 to 10 do begin
            AddRequestToRequestsArray(ITPOSUnitMapping, Requests, RequestIndex, CreatePrinterCommandRequestMessage(CreateDirectIOCommand('4207', Format(i).PadLeft(2, '0'))));
            RequestIndex := RequestIndex + 1;
        end;

        for i := 1 to 10 do begin
            AddRequestToRequestsArray(ITPOSUnitMapping, Requests, RequestIndex, CreatePrinterCommandRequestMessage(CreateDirectIOCommand('4210', Format(i).PadLeft(2, '0'))));
            RequestIndex := RequestIndex + 1;
        end;
    end;
#if not (BC17 or BC18 or BC19) 
    internal procedure CreateSetLogoRequestMessage(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping") RequestText: Text
    var
        RetailLogo: Record "NPR Retail Logo";
        Document: XmlDocument;
        SoapEnvelope: XmlElement;
        SoapEnvelopeBody: XmlElement;
        NonFiscalBody: XmlElement;
        BeginNonFiscalElement: XmlElement;
        EndNonFiscalElement: XmlElement;
        PrintNormalElement: XmlElement;
        SetLogoElement: XmlElement;
        LogoUploadedSuccessfullyLbl: Label 'Logo uploading finished successfully.';
        POSLogoNotUploadedInSetupErr: Label '%1 has not been uploaded to %2.';
    begin
        RetailLogo.SetRange("Register No.", ITPOSUnitMapping."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.Reset();
        if not RetailLogo.FindFirst() then
            Error(POSLogoNotUploadedInSetupErr, RetailLogo.FieldCaption("POS Logo"), RetailLogo.TableCaption);

        Document := XmlDocument.Create('', '');

        SoapEnvelope := CreateSoapEnvelope();
        SoapEnvelopeBody := SelectSoapEnvelopeBody(SoapEnvelope);

        NonFiscalBody := XmlElement.Create('printerNonFiscal');
        BeginNonFiscalElement := XmlElement.Create('beginNonFiscal');
        PrintNormalElement := XmlElement.Create('printNormal');
        EndNonFiscalElement := XmlElement.Create('endNonFiscal');
        SetLogoElement := XmlElement.Create('setLogo');

        AddAttributeToElement(BeginNonFiscalElement, 'operator', '1');
        AddAttributeToElement(EndNonFiscalElement, 'operator', '1');
        AddAttributeToElement(PrintNormalElement, 'operator', '1');
        AddAttributeToElement(PrintNormalElement, 'font', '1');
        AddAttributeToElement(PrintNormalElement, 'data', LogoUploadedSuccessfullyLbl);

        AddAttributeToElement(SetLogoElement, 'operator', '1');
        AddAttributeToElement(SetLogoElement, 'location', '1');
        AddAttributeToElement(SetLogoElement, 'index', '1');
        AddAttributeToElement(SetLogoElement, 'option', '0');
        AddAttributeToElement(SetLogoElement, 'graphicFormat', 'B');

        SetLogoElement.Add(ITPOSUnitMapping.ConvertLogoToBase64());

        NonFiscalBody.Add(BeginNonFiscalElement);
        NonFiscalBody.Add(SetLogoElement);
        NonFiscalBody.Add(PrintNormalElement);
        NonFiscalBody.Add(EndNonFiscalElement);
        SoapEnvelopeBody.Add(NonFiscalBody);
        Document.Add(SoapEnvelope);

        FormatXMLDocumentAsText(Document, RequestText);
    end;
#endif
    #endregion

    #region IT Printer Communication - Helper Procedures

    internal procedure CreateSoapEnvelope() SoapEnvelope: XmlElement
    var
        SoapEnvNamespaceUriLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
    begin
        SoapEnvelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        SoapEnvelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        SoapEnvelope.Add(CreateXmlElement('Body', SoapEnvNamespaceUriLbl, ''));
    end;

    internal procedure SelectSoapEnvelopeBody(SoapEnvelope: XmlElement) SoapEnvelopeBody: XmlElement
    var
        BodyNode: XmlNode;
    begin
        SoapEnvelope.GetChildElements().Get(1, BodyNode);
        SoapEnvelopeBody := BodyNode.AsXmlElement();
    end;

    internal procedure CreateDirectIOCommand(Command: Text; Data: Text) DirectIOCommand: XmlElement
    begin
        DirectIOCommand := XmlElement.Create('directIO');
        AddAttributeToElement(DirectIOCommand, 'command', Command);
        AddAttributeToElement(DirectIOCommand, 'data', Data);
    end;

    local procedure CreateXmlElement(Name: Text; NamespaceUrl: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name, NamespaceUrl);
        Element.Add(XmlText.Create(Content));
    end;

    local procedure AddAttributeToElement(var Element: XmlElement; AttrName: Text; AttrValue: Text)
    begin
        Element.Add(XmlAttribute.Create(AttrName, AttrValue));
    end;

    local procedure IsPaymentLineVoucher(POSEntryPaymentLine: Record "NPR POS Entry Payment Line"): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if not POSPaymentMethod.Get(POSEntryPaymentLine."POS Payment Method Code") then
            exit;
        if POSPaymentMethod."Processing Type" in ["NPR Payment Processing Type"::VOUCHER] then
            exit(true);
    end;

    local procedure AddRequestToRequestsArray(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; var Requests: JsonArray; Index: Integer; RequestBody: Text)
    var
        Request: JsonObject;
    begin
        Request.Remove('requestBody');
        Request.Remove('index');
        Request.Add('index', Index);
        Request.Add('url', FormatHTTPRequestUrl(ITPOSUnitMapping."Fiscal Printer IP Address"));
        Request.Add('requestBody', RequestBody);
        Requests.Add(Request);
    end;

    local procedure StoreITPOSAuditRequestContent(var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info"; RequestText: Text)
    begin
        ITPOSAuditLogAuxInfo.SetRequestContent(RequestText);
        ITPOSAuditLogAuxInfo.Modify();
    end;

    local procedure StoreITPOSAuditResponseContent(var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info"; ResponseText: Text)
    begin
        ITPOSAuditLogAuxInfo.SetResponseContent(ResponseText);
        ITPOSAuditLogAuxInfo.Modify();
    end;
    #endregion

    #region IT Printer - Storing values

    local procedure SetupFPrinterVATDepartment(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseToken: JsonToken; ResponseIndex: Integer; var VATDepartmentsChangedText: Text)
    var
        ResponseData: Text;
        ChildNode: XmlNode;
    begin
        ChildNode := SelectResponseNode(ResponseToken, ResponseIndex);

        IsResponseSuccessful(ChildNode, RequestMethod::setUpVATDepartments);

        GetResponseDataFromNode(ChildNode, ResponseData);

        StoreDataInDepartmentCodebook(ITPOSUnitMapping, ResponseIndex, ResponseData);

        FormatDepartmentsChangedMessage(VATDepartmentsChangedText, ResponseIndex);
    end;

    local procedure StoreDataInDepartmentCodebook(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; i: Integer; ResponseData: Text)
    var
        ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook";
    begin
        ITVATDepartmentCodebook.SetRange("POS Unit No.", ITPOSUnitMapping."POS Unit No.");
        ITVATDepartmentCodebook.SetRange("IT Printer VAT Department", "NPR IT Printer Departments".FromInteger(i));
        if not ITVATDepartmentCodebook.FindFirst() then
            ITVATDepartmentCodebook.InitVATDepartmentForPOSUnit(ITVATDepartmentCodebook, ITPOSUnitMapping, FormatTextToDecimalValue(ResponseData), i)
        else
            ITVATDepartmentCodebook."IT Printer VAT %" := FormatTextToDecimalValue(ResponseData);
        if not ITVATDepartmentCodebook.Insert() then
            ITVATDepartmentCodebook.Modify();
    end;

    internal procedure ProcessFPrinterVATDepartmentsResponse(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseToken: JsonToken)
    var
        ITVATDepartmentCodebook: Record "NPR IT VAT Department Codebook";
        i: Integer;
        DepartmentFieldSuccessfullyUpdatedMsg: Label 'VAT Departments: %1 have successfully been updated in %2', Comment = '%1 = Department No., %2 = Table Caption';
        VATDepartmentsChangedText: Text;
    begin
        for i := 1 to 9 do
            SetupFPrinterVATDepartment(ITPOSUnitMapping, ResponseToken, i, VATDepartmentsChangedText);
        if VATDepartmentsChangedText <> '' then
            Message(StrSubstNo(DepartmentFieldSuccessfullyUpdatedMsg, VATDepartmentsChangedText, ITVATDepartmentCodebook.TableCaption));
    end;

    internal procedure ProcessFPrinterPaymentMethodsResponse(var ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"; ResponseToken: JsonToken)
    var
        ITPOSPaymentMethodMapping: Record "NPR IT POS Paym. Method Mapp.";
        i: Integer;
        ResponseData: Text;
        ChildNode: XmlNode;
        POSPaymentMethodsSuccessfullyUpdatedMsg: Label '%1 fields %2 have successfully been updated.', Comment = '%1 = Table Caption, %2 = Field Caption';
    begin
        for i := 1 to 25 do begin
            ChildNode := SelectResponseNode(ResponseToken, i);

            IsResponseSuccessful(ChildNode, RequestMethod::setUpPaymMeth);
            GetResponseDataFromNode(ChildNode, ResponseData);

            ITPOSPaymentMethodMapping.SetRange("POS Unit No.", ITPOSUnitMapping."POS Unit No.");
            ITPOSPaymentMethodMapping.SetRange("IT Payment Method Index", FormatPaymentMethodIndexFromResponseData(ResponseData));

            case GetPrinterCommandFromNode(ChildNode) of
                '4253':
                    begin
                        ITPOSPaymentMethodMapping.SetRange("IT Payment Method", ITPOSPaymentMethodMapping."IT Payment Method"::"0");
                        if ITPOSPaymentMethodMapping.FindSet(true) then
                            repeat
                                ITPOSPaymentMethodMapping."IT Payment Method Description" := FormatPaymentMethodDescriptionFromResponse(ResponseData);
                                ITPOSPaymentMethodMapping.Modify();
                            until ITPOSPaymentMethodMapping.Next() = 0;
                    end;
                '4207':
                    begin
                        ITPOSPaymentMethodMapping.SetRange("IT Payment Method", ITPOSPaymentMethodMapping."IT Payment Method"::"2");
                        if ITPOSPaymentMethodMapping.FindSet(true) then
                            repeat
                                ITPOSPaymentMethodMapping."IT Payment Method Description" := FormatPaymentMethodDescriptionFromResponse(ResponseData);
                                ITPOSPaymentMethodMapping.Modify();
                            until ITPOSPaymentMethodMapping.Next() = 0;
                    end;
                '4210':
                    begin
                        ITPOSPaymentMethodMapping.SetRange("IT Payment Method", ITPOSPaymentMethodMapping."IT Payment Method"::"3");
                        if ITPOSPaymentMethodMapping.FindSet(true) then
                            repeat
                                ITPOSPaymentMethodMapping."IT Payment Method Description" := FormatPaymentMethodDescriptionFromResponse(ResponseData);
                                ITPOSPaymentMethodMapping.Modify();
                            until ITPOSPaymentMethodMapping.Next() = 0;
                    end;
            end;
        end;
        Message(POSPaymentMethodsSuccessfullyUpdatedMsg, ITPOSPaymentMethodMapping.TableCaption, ITPOSPaymentMethodMapping.FieldCaption("IT Payment Method Description"));
    end;

    local procedure FormatRefundReceiptMessage(ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info"): Text
    var
        RefundITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        TextBuilder: TextBuilder;
    begin
        if ITPOSAuditLogAuxInfo."Refund Source Document No." = '' then
            exit;
        RefundITPOSAuditLogAuxInfo.SetLoadFields("Source Document No.", "Fiscal Printer Serial No.", "POS Unit No.", "Z Report No.", "Receipt No.", "Entry Date");
        RefundITPOSAuditLogAuxInfo.SetRange("Source Document No.", ITPOSAuditLogAuxInfo."Refund Source Document No.");
        if not RefundITPOSAuditLogAuxInfo.FindFirst() then
            exit;

        TextBuilder.Append('REFUND');
        TextBuilder.Append(' ');
        TextBuilder.Append(Format(RefundITPOSAuditLogAuxInfo."Z Report No.").PadLeft(4, '0'));
        TextBuilder.Append(' ');
        TextBuilder.Append(Format(RefundITPOSAuditLogAuxInfo."Receipt No.").PadLeft(4, '0'));
        TextBuilder.Append(' ');
        TextBuilder.Append(Format(RefundITPOSAuditLogAuxInfo."Entry Date", 8, '<Day,2><Month,2><Year4>'));
        TextBuilder.Append(' ');
        TextBuilder.Append(RefundITPOSAuditLogAuxInfo."Fiscal Printer Serial No.");

        exit(TextBuilder.ToText());
    end;

    #endregion

    #region IT Printer - Response Handling Formatting

    local procedure IsResponseSuccessful(ChildNode: XmlNode; CommunicationMethod: Option checkLoginStatus,setLogo,logInPrinter,getRTType,getSerialNo,getPaymentMethods,getVATSetup,printReceipt,printZReport,printXReport,printLastReceipt,setUpVATDepartments,setUpPaymMeth,printEJReport,cashMgt): Boolean
    var
        ResponseUnsuccessfulErr: Label 'Response from printer is unsuccessful for request %1. Error Code: %2; Error Status: %3', Comment = '%1 = Request Caption , %2 = Error Code, %3 = Error Status';
        LoginRequestCap: Label 'Log In Fiscal Printer';
        CheckLoginStatusRequestCap: Label 'Check Log In Status';
        GetRTTypeRequestCap: Label 'Get Fiscal Printer RT Type';
        GetFPSerialNoRequestCap: Label 'Get Fiscal Printer Serial No.';
        PrintReceiptRequestCap: Label 'Print Receipt';
        PrintZReportRequestCap: Label 'Print Z Report';
        PrintXReportRequestCap: Label 'Print X Report';
        PrintLastReceiptRequestCap: Label 'Print Last Receipt';
        SetupVATDeparmentsRequestCap: Label 'Get VAT Departments from Fiscal Printer';
        SetUpPaymentMethodsRequestCap: Label 'Get Payment Method Descriptions from Fiscal Printer';
        PrintEJReportRequestCap: Label 'Print Electronic Journal Report';
        CashHandlingRequestCap: Label 'Cash Handling';
        SetLogoRequestCap: Label 'Set Fiscal Printer Logo';
        CodeAttribute: XmlAttribute;
        StatusAttribute: XmlAttribute;
        SuccessAttribute: XmlAttribute;
        Attributes: XmlAttributeCollection;
        StatusElement: XmlElement;
        Node: XmlNode;
    begin
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'response'), Node);
        StatusElement := Node.AsXmlElement();
        Attributes := StatusElement.Attributes();

        Attributes.Get('success', SuccessAttribute);
        Attributes.Get('code', CodeAttribute);
        Attributes.Get('status', StatusAttribute);
        if not (SuccessAttribute.Value = 'true') and GuiAllowed then
            case CommunicationMethod of
                CommunicationMethod::logInPrinter:
                    Error(ResponseUnsuccessfulErr, LoginRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::checkLoginStatus:
                    Error(ResponseUnsuccessfulErr, CheckLoginStatusRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::getRTType:
                    Error(ResponseUnsuccessfulErr, GetRTTypeRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::getSerialNo:
                    Error(ResponseUnsuccessfulErr, GetFPSerialNoRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::printReceipt:
                    Error(ResponseUnsuccessfulErr, PrintReceiptRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::printZReport:
                    Error(ResponseUnsuccessfulErr, PrintZReportRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::printXReport:
                    Error(ResponseUnsuccessfulErr, PrintXReportRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::printLastReceipt:
                    Error(ResponseUnsuccessfulErr, PrintLastReceiptRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::setUpPaymMeth:
                    Error(ResponseUnsuccessfulErr, SetUpPaymentMethodsRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::setUpVATDepartments:
                    Error(ResponseUnsuccessfulErr, SetupVATDeparmentsRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::printEJReport:
                    Error(ResponseUnsuccessfulErr, PrintEJReportRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::cashMgt:
                    Error(ResponseUnsuccessfulErr, CashHandlingRequestCap, CodeAttribute.Value, StatusAttribute.Value);
                CommunicationMethod::setLogo:
                    Error(ResponseUnsuccessfulErr, SetLogoRequestCap, CodeAttribute.Value, StatusAttribute.Value);
            end;
        exit(true);
    end;

    local procedure SelectResponseNode(ResponseToken: JsonToken; ResponseIndex: Integer): XmlNode
    var
        ResultToken: JsonToken;
        CommunicationNotEstablishedErr: Label 'Communication with the printer has not been established successfully.';
        SelectResultTokenLbl: Label '$..[%1].result', Locked = true, Comment = '%1 - Index';
        ResponseText: Text;
        ResponseDocument: XmlDocument;
        ChildNode: XmlNode;
    begin
        if (not ResponseToken.SelectToken(StrSubstNo(SelectResultTokenLbl, ResponseIndex), ResultToken)) and GuiAllowed then
            Error(CommunicationNotEstablishedErr);
        ResultToken.WriteTo(ResponseText);
        FormatResponseString(ResponseText);
        XmlDocument.ReadFrom(ResponseText, ResponseDocument);
        ResponseDocument.GetChildElements().Get(1, ChildNode);
        exit(ChildNode);
    end;

    local procedure GetResponseDataFromNode(ChildNode: XmlNode; var ResponseData: Text)
    var
        Node: XmlNode;
    begin
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'responseData'), Node);
        ResponseData := Node.AsXmlElement().InnerText();
    end;

    local procedure GetReceiptNumberFromNode(ChildNode: XmlNode; var ReceiptNumber: Text)
    var
        Node: XmlNode;
    begin
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'fiscalReceiptNumber'), Node);
        ReceiptNumber := Node.AsXmlElement().InnerText();
    end;

    local procedure GetZReportNumberFromNode(ChildNode: XmlNode; var ZReportNumber: Text)
    var
        Node: XmlNode;
    begin
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'zRepNumber'), Node);
        ZReportNumber := Node.AsXmlElement().InnerText();
    end;

    local procedure GetPrinterCommandFromNode(ChildNode: XmlNode) ResponseCommand: Text
    var
        Node: XmlNode;
    begin
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'responseCommand'), Node);
        ResponseCommand := Node.AsXmlElement().InnerText();
    end;

    #endregion

    #region IT Printer - Helper procedures - Formatting

    local procedure FormatTextToDecimalValue(var ResponseData: Text): Decimal
    var
        DecimalPart: Decimal;
        IntegralPart: Decimal;
        FirstPart: Text;
        SecondPart: Text;
    begin
        ResponseData := CopyStr(ResponseData, 3, StrLen(ResponseData));
        FirstPart := CopyStr(ResponseData, 1, 2);
        SecondPart := CopyStr(ResponseData, 3, StrLen(ResponseData));

        Evaluate(IntegralPart, FirstPart);
        Evaluate(DecimalPart, SecondPart);
        DecimalPart := DecimalPart / 100;
        exit(IntegralPart + DecimalPart);
    end;

    local procedure FormatDepartmentsChangedMessage(var VATDepartmentsChangedText: Text; i: Integer)
    begin
        if VATDepartmentsChangedText <> '' then
            VATDepartmentsChangedText += ', ';

        VATDepartmentsChangedText += Format("NPR IT Printer Departments".FromInteger(i));
    end;

    local procedure FormatPrinterSerialNoData(var ResponseData: Text; var SerialNoData: Text)
    begin
        ResponseData := CopyStr(ResponseData, 3, StrLen(ResponseData));
        SerialNoData := CopyStr(ResponseData, StrLen(ResponseData) - 3, StrLen(ResponseData));
        ResponseData := CopyStr(ResponseData, 1, StrLen(ResponseData) - 4);
        SerialNoData += ResponseData;
    end;

    local procedure FormatPrinterRTTypeData(var ResponseData: Text)
    begin
        ResponseData := DelChr(ResponseData, '=', '0123456789');
    end;

    local procedure FormatPriceAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2><Integer><Decimals><Comma,,>'));
    end;

    local procedure FormatXMLDocumentAsText(Document: XmlDocument; var RequestText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
        RequestTextChunk: Text;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        Document.WriteTo(OStream);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

        while not (IStream.EOS) do begin
            IStream.ReadText(RequestTextChunk);
            RequestText += RequestTextChunk;
        end;
    end;

    local procedure FormatFiscalPrinterModel(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"): Text
    var
        FirstPart: Text;
        FPrinterSerialNo: Text;
        SecondPart: Text;
        TextBuilder: TextBuilder;
    begin
        FPrinterSerialNo := ITPOSUnitMapping."Fiscal Printer Serial No.";

        SecondPart := CopyStr(FPrinterSerialNo, 1, 2);
        FPrinterSerialNo := CopyStr(FPrinterSerialNo, 3, StrLen(FPrinterSerialNo));
        FirstPart := CopyStr(FPrinterSerialNo, 1, 2);
        FPrinterSerialNo := CopyStr(FPrinterSerialNo, 3, StrLen(FPrinterSerialNo));

        TextBuilder.Append(FirstPart);
        TextBuilder.Append(ITPOSUnitMapping."Fiscal Printer RT Type");
        TextBuilder.Append(SecondPart);
        TextBuilder.Append(FPrinterSerialNo);

        exit(TextBuilder.ToText());
    end;

    local procedure FormatPaymentMethodIndexFromResponseData(ResponseData: Text) PaymentMethodIndex: Integer
    begin
        Evaluate(PaymentMethodIndex, CopyStr(ResponseData, 1, 2));
    end;

    local procedure FormatPaymentMethodDescriptionFromResponse(ResponseData: Text): Text[20]
    begin
        exit(CopyStr(ResponseData, 3, 20));
    end;

    internal procedure FormatResponseString(var ResponseText: Text)
    var
        ResponseTextList: List of [Text];
        ResponseTextLine: Text;
        TextBuilder: TextBuilder;
    begin
        ResponseText := ResponseText.Trim();
        ResponseText := ResponseText.Replace('\"', '"');
        ResponseTextList := ResponseText.Split('\n');

        foreach ResponseTextLine in ResponseTextList do
            TextBuilder.Append(ResponseTextLine);

        ResponseText := TextBuilder.ToText();
        ResponseText := ResponseText.Replace('<?xml version="1.0" encoding="utf-8"?>', '');
        ResponseText := ResponseText.Replace('\t', '');
        ResponseText := DelStr(ResponseText, 1, 1);
        ResponseText := DelStr(ResponseText, StrLen(ResponseText), StrLen(ResponseText));
    end;

    internal procedure FormatHTTPRequestUrl(PrinterIPAddress: Text[30]): Text
    var
        RequestURLFormatLbl: Label 'http://%1/cgi-bin/fpmate.cgi', Locked = true, Comment = '%1 = Printer IP Address';
    begin
        exit(StrSubstNo(RequestURLFormatLbl, PrinterIPAddress));
    end;

    internal procedure FormatLoginCommandData(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"): Text
    var
        LoginValuesFormatLbl: Label '02%1', Locked = true, Comment = '%1 = Fiscal Printer Password';
    begin
        exit(StrSubstNo(LoginValuesFormatLbl, FormatPrinterPasswordForLogin(ITPOSUnitMapping)));
    end;

    internal procedure FormatPrinterPasswordForLogin(ITPOSUnitMapping: Record "NPR IT POS Unit Mapping"): Text
    begin
        exit(Format(ITPOSUnitMapping."Fiscal Printer Password".Trim()).PadRight(100, ' '));
    end;
    #endregion;
}