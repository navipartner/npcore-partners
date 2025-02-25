codeunit 6151587 "NPR SI Tax Communication Mgt."
{
    Access = Internal;

    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
        FuNamespaceUriLbl: Label 'http://www.fu.gov.si/', Locked = true;
        SoapEnvNamespaceUriLbl: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        XmlDsigNamespaceUriLbl: Label 'http://www.w3.org/2000/09/xmldsig#', Locked = true;
        XmlSchemaNamespaceUriLbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true;
        DateTimeFormatLbl: Label '%1T%2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';

    internal procedure CreateNormalSale(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; isSubsequent: Boolean)
    var
        BaseDocument: XmlDocument;
    begin
        if SIPOSAuditLogAuxInfo."Salesbook Entry No." <> 0 then begin
            CreatePreNumberedBookSaleDocument(SIPOSAuditLogAuxInfo, BaseDocument);
            SignBillAndSendToTA(SIPOSAuditLogAuxInfo, 'VKR', BaseDocument);
        end else begin
            CreateSaleDocument(SIPOSAuditLogAuxInfo, BaseDocument, isSubsequent);
            SignBillAndSendToTA(SIPOSAuditLogAuxInfo, 'INVOICE', BaseDocument);
        end;
    end;

    #region SI Fiscalization - XML Document Creation
    local procedure CreateSaleDocument(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var Document: XmlDocument; isSubsequent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        Body: XmlElement;
        Envelope: XmlElement;
        Header: XmlElement;
        InvoiceElement: XmlElement;
        InvoiceIdentifierElement: XmlElement;
        InvoiceRequestElement: XmlElement;
    begin
        CompanyInformation.Get();
        SIFiscalizationSetup.Get();
        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        Envelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('fu', FuNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xd', XmlDsigNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XmlSchemaNamespaceUriLbl));

        Envelope.Add(CreateXmlElement('Header', SoapEnvNamespaceUriLbl, ''));

        Body := XmlElement.Create('Body', SoapEnvNamespaceUriLbl);

        InvoiceRequestElement := XmlElement.Create('InvoiceRequest', FuNamespaceUriLbl);
        InvoiceRequestElement.Add(XmlAttribute.Create('Id', 'data'));

        Header := XmlElement.Create('Header', FuNamespaceUriLbl);
        Header.Add(CreateXmlElement('MessageID', FuNamespaceUriLbl, DelChr(Format(CreateGuid()), '=', '{}').ToLower()));
        Header.Add(CreateXmlElement('DateTime', FuNamespaceUriLbl, Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>')));
        InvoiceRequestElement.Add(Header);

        InvoiceElement := XmlElement.Create('Invoice', FuNamespaceUriLbl);

        InvoiceElement.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalizationSetup."Certificate Subject Ident."));
        InvoiceElement.Add(CreateXmlElement('IssueDateTime', FuNamespaceUriLbl, StrSubstNo(DateTimeFormatLbl, Format(SIPOSAuditLogAuxInfo."Entry Date", 10, '<Year4>-<Month,2>-<Day,2>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));
        InvoiceElement.Add(CreateXmlElement('NumberingStructure', FuNamespaceUriLbl, 'C'));

        InvoiceIdentifierElement := XmlElement.Create('InvoiceIdentifier', FuNamespaceUriLbl);
        InvoiceIdentifierElement.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Store Code"));
        InvoiceIdentifierElement.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Unit No."));
        InvoiceIdentifierElement.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Receipt No."));
        InvoiceElement.Add(InvoiceIdentifierElement);

        if SIPOSAuditLogAuxInfo."Customer VAT Number" <> '' then
            InvoiceElement.Add(CreateXmlElement('CustomerVATNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Customer VAT Number"));

        InvoiceElement.Add(CreateXmlElement('InvoiceAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount")));
        if SIPOSAuditLogAuxInfo."Returns Amount" <> 0 then
            InvoiceElement.Add(CreateXmlElement('ReturnsAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount")));
        InvoiceElement.Add(CreateXmlElement('PaymentAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount")));

        AddTaxSection(InvoiceElement, SIPOSAuditLogAuxInfo);

        InvoiceElement.Add(CreateXmlElement('OperatorTaxNumber', FuNamespaceUriLbl, Format(SIPOSAuditLogAuxInfo."Cashier ID")));
        InvoiceElement.Add(CreateXmlElement('ProtectedID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."ZOI Code"));

        if isSubsequent then
            InvoiceElement.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'true'))
        else
            InvoiceElement.Add(CreateXmlElement('SubsequentSubmit', FuNamespaceUriLbl, 'false'));

        InvoiceRequestElement.Add(InvoiceElement);
        Body.Add(InvoiceRequestElement);
        Envelope.Add(Body);
        Document.Add(Envelope);

        if SIPOSAuditLogAuxInfo."Transaction Type" in [SIPOSAuditLogAuxInfo."Transaction Type"::Return] then
            AddReturnInfoSection(SIPOSAuditLogAuxInfo, Document);
    end;

    local procedure CreatePreNumberedBookSaleDocument(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var Document: XmlDocument)
    var
        CompanyInformation: Record "Company Information";
        SISalesbookReceipt: Record "NPR SI Salesbook Receipt";
        Body: XmlElement;
        Envelope: XmlElement;
        Header: XmlElement;
        SalesBookInvoiceElement: XmlElement;
        SalesBookIdentifierElement: XmlElement;
        InvoiceRequestElement: XmlElement;
    begin
        CompanyInformation.Get();
        SIFiscalizationSetup.Get();
        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        Envelope := XmlElement.Create('Envelope', SoapEnvNamespaceUriLbl);
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('soapenv', SoapEnvNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('fu', FuNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xd', XmlDsigNamespaceUriLbl));
        Envelope.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XmlSchemaNamespaceUriLbl));

        Envelope.Add(CreateXmlElement('Header', SoapEnvNamespaceUriLbl, ''));

        Body := XmlElement.Create('Body', SoapEnvNamespaceUriLbl);

        InvoiceRequestElement := XmlElement.Create('InvoiceRequest', FuNamespaceUriLbl);
        InvoiceRequestElement.Add(XmlAttribute.Create('Id', 'data'));

        Header := XmlElement.Create('Header', FuNamespaceUriLbl);
        Header.Add(CreateXmlElement('MessageID', FuNamespaceUriLbl, DelChr(Format(CreateGuid()), '=', '{}').ToLower()));
        Header.Add(CreateXmlElement('DateTime', FuNamespaceUriLbl, Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>')));
        InvoiceRequestElement.Add(Header);

        SalesBookInvoiceElement := XmlElement.Create('SalesBookInvoice', FuNamespaceUriLbl);

        SalesBookInvoiceElement.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalizationSetup."Certificate Subject Ident."));

        SISalesbookReceipt.Get(SIPOSAuditLogAuxInfo."Salesbook Entry No.");
        SalesBookInvoiceElement.Add(CreateXmlElement('IssueDate', FuNamespaceUriLbl, Format(SISalesbookReceipt."Receipt Issue Date", 10, '<Year4>-<Month,2>-<Day,2>')));
        SalesBookIdentifierElement := XmlElement.Create('SalesBookIdentifier', FuNamespaceUriLbl);
        SalesBookIdentifierElement.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, SISalesbookReceipt."Receipt No."));
        SalesBookIdentifierElement.Add(CreateXmlElement('SetNumber', FuNamespaceUriLbl, SISalesbookReceipt."Set Number"));
        SalesBookIdentifierElement.Add(CreateXmlElement('SerialNumber', FuNamespaceUriLbl, SISalesbookReceipt."Serial Number"));
        SalesBookInvoiceElement.Add(SalesBookIdentifierElement);

        if SIPOSAuditLogAuxInfo."Customer VAT Number" <> '' then
            SalesBookInvoiceElement.Add(CreateXmlElement('CustomerVATNumber', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."Customer VAT Number"));

        SalesBookInvoiceElement.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, SIPOSAuditLogAuxInfo."POS Store Code"));
        SalesBookInvoiceElement.Add(CreateXmlElement('InvoiceAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Total Amount")));
        if SIPOSAuditLogAuxInfo."Returns Amount" <> 0 then
            SalesBookInvoiceElement.Add(CreateXmlElement('ReturnsAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Returns Amount")));
        SalesBookInvoiceElement.Add(CreateXmlElement('PaymentAmount', FuNamespaceUriLbl, FormatDecimalField(SIPOSAuditLogAuxInfo."Payment Amount")));

        AddTaxSection(SalesBookInvoiceElement, SIPOSAuditLogAuxInfo);

        InvoiceRequestElement.Add(SalesBookInvoiceElement);

        Body.Add(InvoiceRequestElement);
        Envelope.Add(Body);
        Document.Add(Envelope);
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
        ExemptedFromTaxAmount: Decimal;
    begin
        TaxesSection := XmlElement.Create('TaxesPerSeller', FuNamespaceUriLbl);

        POSEntryTaxLines.SetLoadFields("Tax %", "Tax Base Amount", "Tax Amount");
        POSEntryTaxLines.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        POSEntryTaxLines.SetFilter("Tax %", '<>%1', 0);
        if POSEntryTaxLines.FindSet() then
            repeat
                TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
                TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax %")));
                TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Base Amount")));
                TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(POSEntryTaxLines."Tax Amount")));
                TaxesSection.Add(TaxAmounts);
            until POSEntryTaxLines.Next() = 0;

        POSEntryTaxLines.SetFilter("Tax %", '=%1', 0);
        POSEntryTaxLines.CalcSums("Tax Base Amount");
        ExemptedFromTaxAmount := POSEntryTaxLines."Tax Base Amount";

        if ExemptedFromTaxAmount <> 0 then
            TaxesSection.Add(CreateXmlElement('ExemptVATTaxableAmount', FuNamespaceUriLbl, FormatDecimalField(ExemptedFromTaxAmount)));

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
        ExemptedFromTaxAmount: Decimal;
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
            if DictKey = 0 then
                ExemptedFromTaxAmount += TaxableAmountDict.Get(DictKey)
            else begin
                TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
                TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(DictKey)));
                TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(TaxableAmountDict.Get(DictKey))));
                TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(TaxAmountDict.Get(DictKey))));
                TaxesSection.Add(TaxAmounts);
            end;
        end;

        if ExemptedFromTaxAmount <> 0 then
            TaxesSection.Add(CreateXmlElement('ExemptVATTaxableAmount', FuNamespaceUriLbl, FormatDecimalField(ExemptedFromTaxAmount)));

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
        ExemptedFromTaxAmount: Decimal;
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
            if DictKey = 0 then
                ExemptedFromTaxAmount += TaxableAmountDict.Get(DictKey)
            else begin
                TaxAmounts := XmlElement.Create('VAT', FuNamespaceUriLbl);
                TaxAmounts.Add(CreateXmlElement('TaxRate', FuNamespaceUriLbl, FormatDecimalField(DictKey)));
                TaxAmounts.Add(CreateXmlElement('TaxableAmount', FuNamespaceUriLbl, FormatDecimalField(-TaxableAmountDict.Get(DictKey))));
                TaxAmounts.Add(CreateXmlElement('TaxAmount', FuNamespaceUriLbl, FormatDecimalField(-TaxAmountDict.Get(DictKey))));
                TaxesSection.Add(TaxAmounts);
            end;
        end;

        if ExemptedFromTaxAmount <> 0 then
            TaxesSection.Add(CreateXmlElement('ExemptVATTaxableAmount', FuNamespaceUriLbl, FormatDecimalField(ExemptedFromTaxAmount)));

        InvoiceElement.Add(TaxesSection);
    end;

    local procedure AddReturnInfoSection(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; var BaseDocument: XmlDocument)
    var
        ReferenceInvoice: XmlElement;
        ReferenceInvoiceID: XmlElement;
        DocumentRoot: XmlElement;
        DocumentNode: XmlNode;
        DocumentNode2: XmlNode;
        ReturnAdditionalInfoList: List of [Text];
        ReturnPOSAuditLogRecordNotFoundErr: Label 'Could not find necessary return receipt information.';
    begin
        BaseDocument.GetRoot(DocumentRoot);
        DocumentRoot.GetDescendantElements().Get(3, DocumentNode);
        DocumentNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'SubsequentSubmit'), DocumentNode2);

        if SIPOSAuditLogAuxInfo."Return Additional Info" = '' then
            Error(ReturnPOSAuditLogRecordNotFoundErr);

        ReturnAdditionalInfoList := SIPOSAuditLogAuxInfo."Return Additional Info".Split(';');
        ReferenceInvoice := XmlElement.Create('ReferenceInvoice', FuNamespaceUriLbl);
        ReferenceInvoiceID := XmlElement.Create('ReferenceInvoiceIdentifier', FuNamespaceUriLbl);
        ReferenceInvoiceID.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, ReturnAdditionalInfoList.Get(1)));
        ReferenceInvoiceID.Add(CreateXmlElement('ElectronicDeviceID', FuNamespaceUriLbl, ReturnAdditionalInfoList.Get(2)));
        ReferenceInvoiceID.Add(CreateXmlElement('InvoiceNumber', FuNamespaceUriLbl, Format(SIPOSAuditLogAuxInfo."Return Receipt No.")));

        ReferenceInvoice.Add(ReferenceInvoiceID);
        ReferenceInvoice.Add(CreateXmlElement('ReferenceInvoiceIssueDateTime', FuNamespaceUriLbl, ReturnAdditionalInfoList.Get(3)));

        DocumentNode2.AddAfterSelf(ReferenceInvoice);
    end;

    local procedure CreatePOSStoreRegistrationDocument(SIPOSStoreMapping: Record "NPR SI POS Store Mapping"; var Document: XmlDocument)
    var
        POSStore: Record "NPR POS Store";
        TimeStampLbl: Label '%1T%2Z', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        FormattedDateTime: Text;
        ParsedAddress: Text;
        ParsedHouseNumber: Text;
        ParsedHouseNumberAdditional: Text;
        IdPoruke: Text;
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
        SIPOSStoreMapping.TestField("Validity Date");

        SIFiscalizationSetup.Get();
        POSStore.Get(SIPOSStoreMapping."POS Store Code");

        POSStore.TestField(Address);
        POSStore.TestField(City);
        POSStore.TestField("Post Code");

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
        BPremise.Add(CreateXmlElement('TaxNumber', FuNamespaceUriLbl, SIFiscalizationSetup."Certificate Subject Ident."));
        BPremise.Add(CreateXmlElement('BusinessPremiseID', FuNamespaceUriLbl, POSStore.Code));

        BPIdentifier := XmlElement.Create('BPIdentifier', FuNamespaceUriLbl);
        RealEstateBP := XmlElement.Create('RealEstateBP', FuNamespaceUriLbl);
        PropertyID := XmlElement.Create('PropertyID', FuNamespaceUriLbl);
        PropertyID.Add(CreateXmlElement('CadastralNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Cadastral Number")));
        PropertyID.Add(CreateXmlElement('BuildingNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Building Number")));
        PropertyID.Add(CreateXmlElement('BuildingSectionNumber', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Building Section Number")));
        RealEstateBP.Add(PropertyID);

        FormatAddress(ParsedAddress, ParsedHouseNumber, ParsedHouseNumberAdditional, POSStore.Address);

        Address := XmlElement.Create('Address', FuNamespaceUriLbl);
        Address.Add(CreateXmlElement('Street', FuNamespaceUriLbl, ParsedAddress));
        Address.Add(CreateXmlElement('HouseNumber', FuNamespaceUriLbl, ParsedHouseNumber));
        if ParsedHouseNumberAdditional <> '' then
            Address.Add(CreateXmlElement('HouseNumberAdditional', FuNamespaceUriLbl, ParsedHouseNumberAdditional));
        Address.Add(CreateXmlElement('Community', FuNamespaceUriLbl, POSStore.City));
        Address.Add(CreateXmlElement('City', FuNamespaceUriLbl, POSStore.City));
        Address.Add(CreateXmlElement('PostalCode', FuNamespaceUriLbl, DelChr(POSStore."Post Code", '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-')));
        RealEstateBP.Add(Address);

        BPIdentifier.Add(RealEstateBP);

        BPremise.Add(BPIdentifier);

        BPremise.Add(CreateXmlElement('ValidityDate', FuNamespaceUriLbl, Format(SIPOSStoreMapping."Validity Date", 10, '<Year4>-<Month,2>-<Day,2>')));

        SoftwareSupplier := XmlElement.Create('SoftwareSupplier', FuNamespaceUriLbl);
        SoftwareSupplier.Add(CreateXmlElement('NameForeign', FuNamespaceUriLbl, SIFiscalizationSetup.GetSoftwareSupplierInfo()));
        BPremise.Add(SoftwareSupplier);
        BPremiseRequest.Add(BPremise);

        Body.Add(BPremiseRequest);
        Envelope.Add(Body);
        Document.Add(Envelope);
    end;

    #endregion

    #region SI Tax Communication - HTTP Request
    local procedure SignBillAndSendToTA(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; MethodType: Text; var ReceiptDocument: XmlDocument)
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
        if not SIAuditMgt.SignAndSendXML(MethodType, BaseValue, ResponseText) then
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
        BaseValue := BaseValue.Replace('<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>', '');
    end;

    local procedure ReverseBaseValueFormat(var BaseValue: Text)
    begin
        BaseValue := BaseValue.Replace('\"', '"');
    end;

    internal procedure GetEORCodeFromResponse(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"; ResponseText: Text)
    var
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

        if SIPOSAuditLogAuxInfo."Salesbook Entry No." = 0 then
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

        NewValue := BaseZoiValue + Format(SIFiscalizationSetup."Certificate Subject Ident.") + Format(SIPOSAuditLogAuxInfo."Entry Date", 6, '<Year,2><Month,2><Day,2>') + Format(SIPOSAuditLogAuxInfo."Log Timestamp", 6, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>');

        NewValue := DelChr(NewValue, '=', ' :.');
        for i := 1 to StrLen(NewValue) do begin
            Evaluate(ModValue, NewValue[i], 9);
            ModValue2 += ModValue;
        end;
        ResultMod := ModValue2 mod 10;
        exit(CopyStr(NewValue + Format(ResultMod), 1, 60));
    end;

    local procedure FormatAddress(var ParsedAddress: Text; var ParsedHouseNumber: Text; var ParsedHouseNumberAdditional: Text; POSStoreAddress: Text)
    var
        i: Integer;
        Words: List of [Text];
        CheckWord: Text;
        Word: Text;
    begin
        ParsedHouseNumber := DelChr(POSStoreAddress, '=', DelChr(POSStoreAddress, '=', '1234567890').Trim());
        Words := POSStoreAddress.Split(' ');
        Words.Get(Words.Count(), Word);
        CheckWord := DelChr(Word, '=', '1234567890');
        if CheckWord = '' then
            exit;
        ParsedHouseNumberAdditional := DelChr(Word, '=', '1234567890');
        for i := 1 to Words.Count() - 1 do
            if Words.Get(i, Word) then
                ParsedAddress += Word + ' ';
        ParsedAddress := ParsedAddress.Trim();
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
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
        POSStoreRegisteredSuccessfulyMsg: Label 'POS Store %1 registered successfully.', Comment = '%1 = POS Store Code';
        POSStoreAlreadyRegisteredQst: Label 'POS Store %1 is already registered. Are you sure you want to continue with registration?', Comment = '%1 = POS Store Code';
        BaseValue: Text;
        ResponseText: Text;
        Document: XmlDocument;
    begin
        if SIPOSStoreMapping.Registered then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(POSStoreAlreadyRegisteredQst, SIPOSStoreMapping."POS Store Code"), false) then
                exit;

        CreatePOSStoreRegistrationDocument(SIPOSStoreMapping, Document);
        FillRequestBaseValue(Document, BaseValue);

        OnBeforeRegisterPOSStore(SIPOSStoreMapping, ResponseText, IsHandled);
        if IsHandled then
            exit;

        if not SIAuditMgt.SignAndSendXML('PP', BaseValue, ResponseText) then
            exit;

        if not CheckIfBPRegisterResponseSuccess(ResponseText) then
            Error(ResponseText);

        Message(StrSubstNo(POSStoreRegisteredSuccessfulyMsg, SIPOSStoreMapping."POS Store Code"));
        SIPOSStoreMapping.Registered := true;
        SIPOSStoreMapping.Modify();
    end;

    local procedure CheckIfBPRegisterResponseSuccess(ResponseText: Text): Boolean
    var
        Document: XmlDocument;
        ChildNode: XmlNode;
        ErrorNode: XmlNode;
    begin
        XmlDocument.ReadFrom(ResponseText, Document);
        Document.GetChildElements().Get(1, ChildNode);
        exit(not ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'Error'), ErrorNode));
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