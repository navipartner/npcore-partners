codeunit 6151587 "NPR SI Tax Communication Mgt."
{
    Access = Internal;

    var
        SIFiscalSetup: Record "NPR SI Fiscalization Setup";
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
        FuNamespaceUriLbl: Label 'http://www.fu.gov.si/', Locked = true;
        SoapEnvNamespaceUriLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        XmlDsigNamespaceUriLbl: Label 'http://www.w3.org/2000/09/xmldsig#', Locked = true;
        XmlSchemaNamespaceUriLbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;

    internal procedure CreateNormalSale(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; isSubsequent: Boolean)
    var
        BaseDocument: XmlDocument;
    begin
        if (SIPOSAuditLogAuxInfo."Sales Book Invoice No." <> '') and (SIPOSAuditLogAuxInfo."Sales Book Serial No." <> '') then
            CreatePreNumberedBookSaleDocument(SIPOSAuditLogAuxInfo, BaseDocument, isSubsequent)
        else
            CreateSaleDocument(SIPOSAuditLogAuxInfo, BaseDocument, isSubsequent);

        SignBillAndSendToTA(SIPOSAuditLogAuxInfo, BaseDocument);
    end;

    #region SI Fiscalization - XML Document Creation
    local procedure CreateSaleDocument(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var Document: XmlDocument; isSubsequent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        TimeStampLbl: Label '%1T%2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        FormattedDateTime: Text;
        IdPoruke: Text;
        Body: XmlElement;
        Envelope: XmlElement;
        Header: XmlElement;
        Invoice: XmlElement;
        InvoiceIdent: XmlElement;
        InvRequest: XmlElement;
    begin
        CompanyInformation.Get();
        SIFiscalSetup.Get();
        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        Envelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('fu', FuNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xd', XmlDsigNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XmlSchemaNamespaceUriLbl));

        Envelope.Add(CreateXmlElement('Header', SoapEnvNamespaceUriLbl, ''));

        Body := XmlElement.Create('Body', SoapEnvNamespaceUriLbl);

        InvRequest := XmlElement.Create('InvoiceRequest', FuNamespaceUriLbl);
        InvRequest.Add(XmlAttribute.Create('Id', 'data'));

        Header := XmlElement.Create('Header', FuNamespaceUriLbl);
        IdPoruke := DelChr(Format(CreateGuid()), '=', '{}').ToLower();
        Header.Add(CreateXmlElement('MessageID', FuNamespaceUriLbl, IdPoruke));
        FormattedDateTime := Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>');
        Header.Add(CreateXmlElement('DateTime', FuNamespaceUriLbl, FormattedDateTime));
        InvRequest.Add(Header);

        Invoice := XmlElement.Create('Invoice', FuNamespaceUriLbl);

        Invoice.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalSetup."Certificate Subject Ident."));
        Invoice.Add(CreateXmlElement('IssueDateTime', FuNamespaceUriLbl, StrSubstNo(TimeStampLbl, Format(SIPOSAuditLogAuxInfo."Entry Date", 10, '<Year4>-<Month,2>-<Day,2>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));
        Invoice.Add(CreateXmlElement('NumberingStructure', FuNamespaceUriLbl, 'C'));

        InvoiceIdent := XmlElement.Create('InvoiceIdentifier', FuNamespaceUriLbl);
        InvoiceIdent.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Store Code"));
        InvoiceIdent.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Unit No."));
        InvoiceIdent.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Receipt No."));
        Invoice.Add(InvoiceIdent);

        if SIPOSAuditLogAuxInfo."Customer VAT Number" <> '' then
            Invoice.Add(CreateXmlElement('CustomerVATNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Customer VAT Number"));

        Invoice.Add(CreateXmlElement('InvoiceAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount")));
        if SIPOSAuditLogAuxInfo."Returns Amount" <> 0 then
            Invoice.Add(CreateXmlElement('ReturnsAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount")));
        Invoice.Add(CreateXmlElement('PaymentAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount")));

        AddTaxSection(Invoice, SIPOSAuditLogAuxInfo);

        Invoice.Add(CreateXmlElement('OperatorTaxNumber', FuNamespaceUriLbl, Format(SIPOSAuditLogAuxInfo."Cashier ID")));
        Invoice.Add(CreateXmlElement('ProtectedID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."ZOI Code"));

        if isSubsequent then
            Invoice.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'true'))
        else
            Invoice.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'false'));

        InvRequest.Add(Invoice);
        Body.Add(InvRequest);
        Envelope.Add(Body);
        Document.Add(Envelope);

        if SIPOSAuditLogAuxInfo."Transaction Type" in [SIPOSAuditLogAuxInfo."Transaction Type"::Return] then
            AddReturnInfoSection(SIPOSAuditLogAuxInfo, Document);
    end;

    local procedure CreatePreNumberedBookSaleDocument(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var Document: XmlDocument; isSubsequent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        POSEntryTaxLines: Record "NPR POS Entry Tax Line";
        TimeStampLbl: Label '%1T%2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        FormattedDateTime: Text;
        IdPoruke: Text;
        Body: XmlElement;
        Envelope: XmlElement;
        Header: XmlElement;
        Invoice: XmlElement;
        InvoiceIdent: XmlElement;
        InvRequest: XmlElement;
        TaxAmounts: XmlElement;
        TaxesSection: XmlElement;
    begin
        CompanyInformation.Get();
        SIFiscalSetup.Get();
        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        Envelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('fu', FuNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xd', XmlDsigNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XmlSchemaNamespaceUriLbl));

        Envelope.Add(CreateXmlElement('Header', SoapEnvNamespaceUriLbl, ''));

        Body := XmlElement.Create('Body', SoapEnvNamespaceUriLbl);

        InvRequest := XmlElement.Create('InvoiceRequest', FuNamespaceUriLbl);
        InvRequest.Add(XmlAttribute.Create('Id', 'data'));

        Header := XmlElement.Create('Header', FuNamespaceUriLbl);
        IdPoruke := DelChr(Format(CreateGuid()), '=', '{}').ToLower();
        Header.Add(CreateXmlElement('MessageID', FuNamespaceUriLbl, IdPoruke));
        FormattedDateTime := Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
        Header.Add(CreateXmlElement('DateTime', FuNamespaceUriLbl, FormattedDateTime));
        InvRequest.Add(Header);

        Invoice := XmlElement.Create('SalesBookInvoice', FuNamespaceUriLbl);

        Invoice.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalSetup."Certificate Subject Ident."));
        Invoice.Add(CreateXmlElement('IssueDateTime', FuNamespaceUriLbl, StrSubstNo(TimeStampLbl, Format(SIPOSAuditLogAuxInfo."Entry Date", 10, '<Year4>-<Month,2>-<Day,2>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));

        InvoiceIdent := XmlElement.Create('SalesBookIdentifier', FuNamespaceUriLbl);
        InvoiceIdent.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Receipt No."));
        InvoiceIdent.Add(CreateXmlElement('SetNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Sales Book Invoice No."));
        InvoiceIdent.Add(CreateXmlElement('SerialNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Sales Book Serial No."));
        Invoice.Add(InvoiceIdent);

        if SIPOSAuditLogAuxInfo."Customer VAT Number" <> '' then
            Invoice.Add(CreateXmlElement('CustomerVATNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Customer VAT Number"));

        Invoice.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Store Code"));
        Invoice.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Unit No."));
        Invoice.Add(CreateXmlElement('InvoiceAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount")));
        if SIPOSAuditLogAuxInfo."Returns Amount" <> 0 then
            Invoice.Add(CreateXmlElement('ReturnsAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount")));
        Invoice.Add(CreateXmlElement('PaymentAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount")));

        TaxesSection := XmlElement.Create('TaxesPerSeller', FuNamespaceUriLbl);

        POSEntryTaxLines.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryTaxLines.FindSet() then
            repeat
                TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
                TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax %")));
                TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Base Amount")));
                TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Amount")));
                TaxesSection.Add(TaxAmounts);
            until POSEntryTaxLines.Next() = 0;

        Invoice.Add(TaxesSection);

        Invoice.Add(CreateXmlElement('OperatorTaxNumber', FuNamespaceUriLbl, Format(SIPOSAuditLogAuxInfo."Cashier ID")));
        Invoice.Add(CreateXmlElement('ProtectedID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."ZOI Code"));
        if isSubsequent then
            Invoice.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'true'))
        else
            Invoice.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'false'));

        InvRequest.Add(Invoice);

        Body.Add(InvRequest);
        Envelope.Add(Body);
        Document.Add(Envelope);

        if SIPOSAuditLogAuxInfo."Transaction Type" in [SIPOSAuditLogAuxInfo."Transaction Type"::Return] then
            AddReturnInfoSection(SIPOSAuditLogAuxInfo, Document);
    end;


    local procedure AddTaxSection(var InvoiceElement: XmlElement; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    begin
        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                AddPOSEntryTaxSection(InvoiceElement, SIPOSAuditLogAuxInfo);
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                AddSalesInvoiceTaxSection(InvoiceElement, SIPOSAuditLogAuxInfo);
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                AddSalesCrMemoTaxSection(InvoiceElement, SIPOSAuditLogAuxInfo);
        end;
    end;

    local procedure AddPOSEntryTaxSection(var InvoiceElement: XmlElement; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        POSEntryTaxLines: Record "NPR POS Entry Tax Line";
        TaxesSection: XmlElement;
        TaxAmounts: XmlElement;
    begin
        TaxesSection := XmlElement.Create('TaxesPerSeller', FuNamespaceUriLbl);

        POSEntryTaxLines.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryTaxLines.FindSet() then
            repeat
                TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
                TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax %")));
                TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Base Amount")));
                TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Amount")));
                TaxesSection.Add(TaxAmounts);
            until POSEntryTaxLines.Next() = 0;

        InvoiceElement.Add(TaxesSection);
    end;

    local procedure AddSalesInvoiceTaxSection(var InvoiceElement: XmlElement; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
        TaxesSection: XmlElement;
        TaxAmounts: XmlElement;
    begin
        SalesInvoiceLine.SetLoadFields("VAT %", "VAT Base Amount", "Amount Including VAT");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.FindSet();

        repeat
            AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
        until SalesInvoiceLine.Next() = 0;

        TaxesSection := XmlElement.Create('TaxesPerSeller', FuNamespaceUriLbl);
        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
            TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(DictKey)));
            TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(TaxableAmountDict.Get(DictKey))));
            TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(TaxAmountDict.Get(DictKey))));
            TaxesSection.Add(TaxAmounts);
        end;

        InvoiceElement.Add(TaxesSection);
    end;

    local procedure AddSalesCrMemoTaxSection(var InvoiceElement: XmlElement; SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
        TaxesSection: XmlElement;
        TaxAmounts: XmlElement;
    begin
        SalesCrMemoLine.SetLoadFields("VAT %", "VAT Base Amount", "Amount Including VAT");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.FindSet();

        repeat
            AddAmountToDecimalDict(TaxableAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount");
        until SalesCrMemoLine.Next() = 0;

        TaxesSection := XmlElement.Create('TaxesPerSeller', FuNamespaceUriLbl);
        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
            TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(DictKey)));
            TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(-TaxableAmountDict.Get(DictKey))));
            TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(-TaxAmountDict.Get(DictKey))));
            TaxesSection.Add(TaxAmounts);
        end;

        InvoiceElement.Add(TaxesSection);
    end;

    local procedure AddReturnInfoSection(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var BaseDocument: XmlDocument)
    var
    begin
        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                AddPOSEntryReturnInfo(SIPOSAuditLogAuxInfo, BaseDocument);
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                AddSalesCreditMemoReturnInfo(SIPOSAuditLogAuxInfo, BaseDocument);
        end;
    end;

    local procedure AddPOSEntryReturnInfo(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var BaseDocument: XmlDocument)
    var
        ReturnSIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        TimeStampLbl: Label '%1T%2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        XPathExcludeNamespacePattern: Label '//*[local-name()=''%1'']', Locked = true;
        ReferenceInvoice: XmlElement;
        ReferenceInvoiceID: XmlElement;
        DocumentRoot: XmlElement;
        DocumentNode: XmlNode;
        DocumentNode2: XmlNode;
        ReturnPOSAuditLogRecordNotFoundErr: Label 'Could not find a record in %1 table for %2: %3', Comment = '%1 = Table Caption, %2 = Field Caption, %3 = Return Receipt No.';
    begin
        BaseDocument.GetRoot(DocumentRoot);
        DocumentRoot.GetDescendantElements().Get(3, DocumentNode);
        DocumentNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'SubsequentSubmit'), DocumentNode2);

        ReturnSIPOSAuditLogAuxInfo.SetRange("Source Document No.", SIPOSAuditLogAuxInfo."Return Receipt No.");
        if not ReturnSIPOSAuditLogAuxInfo.FindFirst() then
            Error(ReturnPOSAuditLogRecordNotFoundErr, ReturnSIPOSAuditLogAuxInfo.TableCaption(), ReturnSIPOSAuditLogAuxInfo.FieldCaption("Return Receipt No."), SIPOSAuditLogAuxInfo."Return Receipt No.");

        ReferenceInvoice := XmlElement.Create('ReferenceInvoice', FuNamespaceUriLbl);
        ReferenceInvoiceID := XmlElement.Create('ReferenceInvoiceIdentifier', FuNamespaceUriLbl);
        ReferenceInvoiceID.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, ReturnSIPOSAuditLogAuxInfo."POS Store Code"));
        ReferenceInvoiceID.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, ReturnSIPOSAuditLogAuxInfo."POS Unit No."));
        ReferenceInvoiceID.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, Format(ReturnSIPOSAuditLogAuxInfo."Receipt No.")));

        ReferenceInvoice.Add(ReferenceInvoiceID);
        ReferenceInvoice.Add(CreateXmlElement('ReferenceInvoiceIssueDateTime', FuNamespaceUriLbl, StrSubstNo(TimeStampLbl, Format(ReturnSIPOSAuditLogAuxInfo."Entry Date", 10, '<Year4>-<Month,2>-<Day,2>'), Format(ReturnSIPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));

        DocumentNode2.AddAfterSelf(ReferenceInvoice);
    end;

    local procedure AddSalesCreditMemoReturnInfo(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var BaseDocument: XmlDocument)
    var
        ReturnSIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SIAuxSalesCrMemoHeader: Record "NPR SI Aux Sales CrMemo Header";
        TimeStampLbl: Label '%1T%2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        XPathExcludeNamespacePattern: Label '//*[local-name()=''%1'']', Locked = true;
        ReferenceInvoice: XmlElement;
        ReferenceInvoiceID: XmlElement;
        DocumentRoot: XmlElement;
        DocumentNode: XmlNode;
        DocumentNode2: XmlNode;
        ReturnPOSAuditLogRecordNotFoundErr: Label 'Could not find a record in %1 table for %2: %3', Comment = '%1 = Table Caption, %2 = Field Caption, %3 = Return Receipt No.';
    begin
        BaseDocument.GetRoot(DocumentRoot);
        DocumentRoot.GetDescendantElements().Get(3, DocumentNode);
        DocumentNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'SubsequentSubmit'), DocumentNode2);

        SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.");

        if SalesCrMemoHeader."Applies-to Doc. No." <> '' then begin
            ReturnSIPOSAuditLogAuxInfo.SetRange("Source Document No.", SIPOSAuditLogAuxInfo."Return Receipt No.");
            if not ReturnSIPOSAuditLogAuxInfo.FindFirst() then
                Error(ReturnPOSAuditLogRecordNotFoundErr, ReturnSIPOSAuditLogAuxInfo.TableCaption(), ReturnSIPOSAuditLogAuxInfo.FieldCaption("Return Receipt No."), SIPOSAuditLogAuxInfo."Return Receipt No.");
            ReferenceInvoice := XmlElement.Create('ReferenceInvoice', FuNamespaceUriLbl);
            ReferenceInvoiceID := XmlElement.Create('ReferenceInvoiceIdentifier', FuNamespaceUriLbl);
            ReferenceInvoiceID.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, ReturnSIPOSAuditLogAuxInfo."POS Store Code"));
            ReferenceInvoiceID.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, ReturnSIPOSAuditLogAuxInfo."POS Unit No."));
            ReferenceInvoiceID.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, Format(ReturnSIPOSAuditLogAuxInfo."Receipt No.")));

            ReferenceInvoice.Add(ReferenceInvoiceID);
            ReferenceInvoice.Add(CreateXmlElement('ReferenceInvoiceIssueDateTime', FuNamespaceUriLbl, StrSubstNo(TimeStampLbl, Format(ReturnSIPOSAuditLogAuxInfo."Entry Date", 10, '<Year4>-<Month,2>-<Day,2>'), Format(ReturnSIPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));
        end else begin
            SIAuxSalesCrMemoHeader.ReadSIAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
            ReferenceInvoice := XmlElement.Create('ReferenceInvoice', FuNamespaceUriLbl);
            ReferenceInvoiceID := XmlElement.Create('ReferenceInvoiceIdentifier', FuNamespaceUriLbl);
            ReferenceInvoiceID.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, SIAuxSalesCrMemoHeader."NPR SI Return Bus. Premise ID"));
            ReferenceInvoiceID.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, SIAuxSalesCrMemoHeader."NPR SI Return Cash Register ID"));
            ReferenceInvoiceID.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, Format(SIAuxSalesCrMemoHeader."NPR SI Return Receipt No.")));

            ReferenceInvoice.Add(ReferenceInvoiceID);
            ReferenceInvoice.Add(CreateXmlElement('ReferenceInvoiceIssueDateTime', FuNamespaceUriLbl, Format(SIAuxSalesCrMemoHeader."NPR SI Return Receipt DateTime", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>')));
        end;

        DocumentNode2.AddAfterSelf(ReferenceInvoice);
    end;

    local procedure CreatePOSStoreRegistrationDocument(SIPOSStoreMapping: Record "NPR SI POS Store Mapping"; var Document: XmlDocument)
    var
        POSStore: Record "NPR POS Store";
        TimeStampLbl: Label '%1T%2Z', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        FormattedDateTime: Text;
        HouseNumberAdditional: Text;
        IdPoruke: Text;
        POSStoreAddress: Text;
        Address: XmlElement;
        Body: XmlElement;
        BPIdentifier: XmlElement;
        BPremise: XmlElement;
        BPremiseRequest: XmlElement;
        Envelope: XmlElement;
        Header: XmlElement;
        PropertyID: XmlElement;
        RealEstateBP: XmlElement;
        SoftwareSupplier: XmlElement;
    begin
        SIFiscalSetup.Get();
        POSStore.SetRange(Code, SIPOSStoreMapping."POS Store Code");
        POSStore.FindFirst();

        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        Envelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('fu', FuNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xd', XmlDsigNamespaceUriLbl));

        Body := XmlElement.Create('Body', SoapEnvNamespaceUriLbl);

        BPremiseRequest := XmlElement.Create('BusinessPremiseRequest', FuNamespaceUriLbl);
        BPremiseRequest.Add(XmlAttribute.Create('Id', 'data'));

        Header := XmlElement.Create('Header', FuNamespaceUriLbl);
        IdPoruke := DelChr(Format(CreateGuid()), '=', '{}').ToLower();
        Header.Add(CreateXmlElement('MessageID', FuNamespaceUriLbl, IdPoruke));
        FormattedDateTime := StrSubstNo(TimeStampLbl, Format(WorkDate(), 10, '<Year4>-<Month,2>-<Day,2>'), Format(Time(), 8, '<Hours,2>:<Minutes,2>:<Seconds,2>'));
        Header.Add(CreateXmlElement('DateTime', FuNamespaceUriLbl, FormattedDateTime));
        BPremiseRequest.Add(Header);

        BPremise := XmlElement.Create('BusinessPremise', FuNamespaceUriLbl);
        BPremise.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalSetup."Certificate Subject Ident."));
        BPremise.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, POSStore.Code));

        BPIdentifier := XmlElement.Create('BPIdentifier', FuNamespaceUriLbl);
        RealEstateBP := XmlElement.Create('RealEstateBP', FuNamespaceUriLbl);
        PropertyID := XmlElement.Create('PropertyID', FuNamespaceUriLbl);
        PropertyID.Add(CreateXmlElement('CadastralNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Cadastral Number")));
        PropertyID.Add(CreateXmlElement('BuildingNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Building Number")));
        PropertyID.Add(CreateXmlElement('BuildingSectionNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Building Section Number")));
        RealEstateBP.Add(PropertyID);

        POSStoreAddress := POSStore.Address;

        FormatAddress(HouseNumberAdditional, POSStoreAddress);

        Address := XmlElement.Create('Address', FuNamespaceUriLbl);
        Address.Add(CreateXmlElement('Street', FuNamespaceUriLbl, DelChr(POSStoreAddress, '=', '1234567890').Trim()));
        Address.Add(CreateXmlElement('HouseNumber', FuNamespaceUriLbl, DelChr(POSStoreAddress, '=', DelChr(POSStoreAddress, '=', '1234567890').Trim())));
        if HouseNumberAdditional <> '' then
            Address.Add(CreateXmlElement('HouseNumberAdditional', FuNamespaceUriLbl, HouseNumberAdditional));
        Address.Add(CreateXmlElement('Community', FuNamespaceUriLbl, POSStore.City));
        Address.Add(CreateXmlElement('City', FuNamespaceUriLbl, POSStore.City));
        Address.Add(CreateXmlElement('PostalCode', FuNamespaceUriLbl, DelChr(POSStore."Post Code", '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')));
        RealEstateBP.Add(Address);

        BPIdentifier.Add(RealEstateBP);

        BPremise.Add(BPIdentifier);

        BPremise.Add(CreateXmlElement('ValidityDate', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Validity Date", 10, '<Year4>-<Month,2>-<Day,2>')));

        SoftwareSupplier := XmlElement.Create('SoftwareSupplier', FuNamespaceUriLbl);
        SoftwareSupplier.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, '21382191'));
        BPremise.Add(SoftwareSupplier);
        BPremiseRequest.Add(BPremise);

        Body.Add(BPremiseRequest);
        Envelope.Add(Body);
        Document.Add(Envelope);
    end;

    #endregion

    #region CRO Tax Communication - HTTP Request
    local procedure SignBillAndSendToTA(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var ReceiptDocument: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
        IsHandled: Boolean;
        BaseValue: Text;
        ResponseText: Text;
    begin
        FillRequestBaseValue(ReceiptDocument, BaseValue);
        OnBeforeSendHttpRequest(SIPOSAuditLogAuxInfo, ResponseText, IsHandled);
        if IsHandled then
            exit;
        if not SIAuditMgt.SignAndSendXML('INVOICE', BaseValue, ResponseText) then
            exit;
        GetEORCodeFromResponse(SIPOSAuditLogAuxInfo, ResponseText);
        SaveResponseToAuditLog(SIPOSAuditLogAuxInfo, ResponseText);

        ReverseBaseValueFormat(BaseValue);
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(BaseValue);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        SIPOSAuditLogAuxInfo."Receipt Content".ImportStream(IStream, SIPOSAuditLogAuxInfo.FieldCaption("Receipt Content"));
        SIPOSAuditLogAuxInfo.Modify();

        if SIPOSAuditLogAuxInfo."Receipt Fiscalized" then
            case SIPOSAuditLogAuxInfo."Audit Entry Type" of
                SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                    SetReceiptFiscalizedOnSalesInvoiceHeader(SIPOSAuditLogAuxInfo);
                SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                    SetReceiptFiscalizedOnSalesCrMemoHeader(SIPOSAuditLogAuxInfo);
            end;
    end;

    #endregion

    #region SI Fiscalization - Helper functions

    local procedure CreateXmlElement(Name: Text; NamespaceUrl: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name, NamespaceUrl);
        Element.Add(XmlText.Create(Content));
    end;

    local procedure FormatDecimalField(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'))
    end;

    local procedure FillRequestBaseValue(Document: XmlDocument; var BaseValue: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
        BaseChunk: Text;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        Document.WriteTo(OStream);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

        while not IStream.EOS do begin
            IStream.ReadText(BaseChunk);
            BaseValue += BaseChunk;
        end;
        BaseValue := BaseValue.Replace('"', '\"');
    end;

    local procedure ReverseBaseValueFormat(var BaseValue: Text)
    begin
        BaseValue := BaseValue.Replace('\"', '"');
    end;

    internal procedure GetEORCodeFromResponse(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; ResponseText: Text)
    var
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true;
        Document: XmlDocument;
        ChildNode: XmlNode;
        Node: XmlNode;
    begin
        XmlDocument.ReadFrom(ResponseText, Document);
        Document.GetChildElements().Get(1, ChildNode);
        if not ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'UniqueInvoiceID'), Node) then
            exit;

        SIPOSAuditLogAuxInfo."Receipt Fiscalized" := true;
        SIPOSAuditLogAuxInfo."EOR Code" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SIPOSAuditLogAuxInfo."EOR Code"));
        SIPOSAuditLogAuxInfo."EOR Code" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SIPOSAuditLogAuxInfo."EOR Code"));
        SIPOSAuditLogAuxInfo."Validation Code" := CalculateValidationCode(SIPOSAuditLogAuxInfo);
        SIPOSAuditLogAuxInfo.Modify();
    end;

    local procedure SaveResponseToAuditLog(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; ResponseText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        OStream: OutStream;
    begin
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(ResponseText);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        SIPOSAuditLogAuxInfo."Response Content".ImportStream(IStream, SIPOSAuditLogAuxInfo.FieldCaption("Response Content"));
        SIPOSAuditLogAuxInfo.Modify();
    end;

    local procedure SetReceiptFiscalizedOnSalesInvoiceHeader(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SIAuxSalesInvHeader: Record "NPR SI Aux Sales Inv. Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not SalesInvoiceHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then
            exit;
        SIAuxSalesInvHeader.ReadSIAuxSalesInvHeaderFields(SalesInvoiceHeader);
        SIAuxSalesInvHeader."NPR SI Document Fiscalized" := true;
        SIAuxSalesInvHeader."NPR SI Audit Entry No." := SIPOSAuditLogAuxInfo."Audit Entry No.";
        SIAuxSalesInvHeader.SaveSIAuxSalesInvHeaderFields();
    end;

    local procedure SetReceiptFiscalizedOnSalesCrMemoHeader(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SIAuxSalesCrMemoHeader: Record "NPR SI Aux Sales CrMemo Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.") then
            exit;
        SIAuxSalesCrMemoHeader.ReadSIAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        SIAuxSalesCrMemoHeader."NPR SI Document Fiscalized" := true;
        SIAuxSalesCrMemoHeader."NPR SI Audit Entry No." := SIPOSAuditLogAuxInfo."Audit Entry No.";
        SIAuxSalesCrMemoHeader.SaveSIAuxSalesCrMemoHeaderFields();
    end;

    local procedure CalculateValidationCode(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"): Text[60]
    var
        HexadecimalConvert: Codeunit "NPR Hexadecimal Convert";
        i: Integer;
        ModValue: Integer;
        ModValue2: Integer;
        ResultMod: Integer;
        BaseZoiValue: Text;
        NewValue: Text;
    begin
        BaseZoiValue := HexadecimalConvert.BigHexToText(SIPOSAuditLogAuxInfo."ZOI Code".ToUpper());
        if StrLen(BaseZoiValue) < 39 then
            BaseZoiValue := BaseZoiValue.PadLeft(39, '0');
        NewValue := BaseZoiValue + Format(SIPOSAuditLogAuxInfo."Cashier ID") + Format(SIPOSAuditLogAuxInfo."Entry Date", 6, '<Year,2><Month,2><Day,2>') + Format(SIPOSAuditLogAuxInfo."Log Timestamp", 6, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>');

        NewValue := DelChr(NewValue, '=', ' :.');
        for i := 1 to StrLen(NewValue) do begin
            Evaluate(ModValue, NewValue[i], 9);
            ModValue2 += ModValue;
        end;
        ResultMod := ModValue2 mod 10;
        exit(CopyStr(NewValue + Format(ResultMod), 1, 60));
    end;

    local procedure FormatAddress(var HouseNumberAdditional: Text; var POSStoreAddress: Text)
    var
        i: Integer;
        Words: List of [Text];
        CheckWord: Text;
        Word: Text;
    begin
        Words := POSStoreAddress.Split(' ');
        Words.Get(Words.Count(), Word);
        CheckWord := DelChr(Word, '=', '1234567890');
        if CheckWord = '' then
            exit;
        HouseNumberAdditional := Word;
        Clear(POSStoreAddress);
        for i := 1 to Words.Count() - 1 do
            if Words.Get(i, Word) then
                POSStoreAddress += Word + ' ';
        POSStoreAddress := POSStoreAddress.Trim();
    end;

    local procedure AddAmountToDecimalDict(var DecimalDict: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDict.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDict.Get(DictKey) + DictValue;
        DecimalDict.Set(DictKey, BaseAmount);
    end;

    internal procedure RegisterPOSStore(var SIPOSStoreMapping: Record "NPR SI POS Store Mapping")
    var
        IsHandled: Boolean;
        POSStoreRegisteredSuccessfulyMsg: Label 'POS Store %1 registered successfully.', Comment = '%1 = POS Store Code';
        BaseValue: Text;
        ResponseText: Text;
        Document: XmlDocument;
    begin
        if SIPOSStoreMapping.Registered then
            exit;
        CreatePOSStoreRegistrationDocument(SIPOSStoreMapping, Document);
        FillRequestBaseValue(Document, BaseValue);
        OnBeforeRegisterPOSStore(SIPOSStoreMapping, ResponseText, IsHandled);
        if IsHandled then
            exit;
        if not SIAuditMgt.SignAndSendXML('PP', BaseValue, ResponseText) then
            exit;
        Message(StrSubstNo(POSStoreRegisteredSuccessfulyMsg, SIPOSStoreMapping."POS Store Code"));
        SIPOSStoreMapping.Registered := true;
        SIPOSStoreMapping.Modify();
    end;

    #endregion

    #region SI Tax Communication - Test Procedures
    internal procedure TestGetEORCodeFromResponse(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; ResponseText: Text)
    begin
        GetEORCodeFromResponse(SIPOSAuditLogAuxInfo, ResponseText);
    end;
    #endregion

    [IntegrationEvent(true, false)]
    local procedure OnBeforeRegisterPOSStore(var SIPOSStoreMapping: Record "NPR SI POS Store Mapping"; var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequest(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var ResponseText: Text; var IsHandled: Boolean)
    begin
    end;
}