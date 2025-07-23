codeunit 6184793 "NPR RS EI Out Sales Inv. Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        RSEITaxLiabilityCode: Enum "NPR RS EI Tax Liability Method";
        XsdUrlNamespaceLbl: Label 'http://www.w3.org/2001/XMLSchema', Locked = true;
        XsiUrlNamespaceLbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        XmlnsUrnNamespaceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
        SbtUrlNamespaceLbl: Label 'http://mfin.gov.rs/srbdt/srbdtext', Locked = true;
        JBKJSCodeLbl: Label 'JBKJS:%1', Comment = '%1 = JBKJS Code', Locked = true;
        CurrencyId: Code[10];

    internal procedure CreateRequestAndSendSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        RequestText: Text;
    begin
        RSEIAuxSalesInvHdr.ReadRSEIAuxSalesInvHdrFields(SalesInvoiceHeader);

        if not RSEInvoiceMgt.CheckIfDocumentShouldBeSent(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."No.", RSEIAuxSalesInvHdr."NPR RS EI Send To SEF") then begin
            RSEIAuxSalesInvHdr.SetRSEIAuxSalesInvHdrSendToSEF(false);
            exit;
        end;

        RSEInvoiceMgt.CheckIsDataSetOnSalesInvHeader(SalesInvoiceHeader);

        if RSEInvoiceDocumentExists(SalesInvoiceHeader."No.") then
            exit;

        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        if SalesInvoiceHeader."Prepayment Invoice" then
            CreatePrepaymentInvoiceXMLDocument(RequestText, SalesInvoiceHeader, RSEIAuxSalesInvHdr)
        else
            CreateSalesInvoiceXMLDocument(RequestText, SalesInvoiceHeader, RSEIAuxSalesInvHdr);
        InsertInvoiceDocumentRec(RSEInvoiceDocument, SalesInvoiceHeader, RSEIAuxSalesInvHdr, RequestText);
        RSEICommunicationMgt.SendSalesDocument(RSEInvoiceDocument);
        InsertDataToSalesInvAuxTable(RSEIAuxSalesInvHdr, RSEInvoiceDocument);
    end;

    local procedure InsertInvoiceDocumentRec(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; SalesInvoiceHeader: Record "Sales Invoice Header"; RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr."; RequestText: Text)
    begin
        RSEInvoiceDocument.Init();
        RSEInvoiceDocument."Entry No." := RSEInvoiceDocument.GetLastEntryNo() + 1;
        RSEInvoiceDocument."Document Type" := RSEInvoiceDocument."Document Type"::"Sales Invoice";
        RSEInvoiceDocument."Invoice Status" := RSEInvoiceDocument."Invoice Status"::DRAFT;
        RSEInvoiceDocument.Direction := RSEInvoiceDocument.Direction::Outgoing;
        RSEInvoiceDocument."Invoice Document No." := SalesInvoiceHeader."External Document No.";
        RSEInvoiceDocument."Document No." := SalesInvoiceHeader."No.";
        RSEInvoiceDocument."Creation Date" := SalesInvoiceHeader."Posting Date";
        RSEInvoiceDocument."Sending Date" := Today();
        RSEInvoiceDocument.Amount := SalesInvoiceHeader."Amount Including VAT";
        RSEInvoiceDocument."Supplier Name" := CopyStr(CompanyName(), 1, MaxStrLen(RSEInvoiceDocument."Supplier Name"));
        RSEInvoiceDocument."Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        RSEInvoiceDocument."Customer Name" := SalesInvoiceHeader."Sell-to Customer Name";
        RSEInvoiceDocument."Created" := true;
        RSEInvoiceDocument.Posted := true;
        RSEInvoiceDocument.SetRequestContent(RequestText);
        RSEInvoiceDocument."CIR Invoice" := RSEIAuxSalesInvHdr."NPR RS EI Send To CIR";

        if SalesInvoiceHeader."Prepayment Invoice" then
            RSEInvoiceDocument."Invoice Type Code" := RSEInvoiceDocument."Invoice Type Code"::"386"
        else
            RSEInvoiceDocument."Invoice Type Code" := RSEInvoiceDocument."Invoice Type Code"::"380";

        RSEInvoiceDocument.Insert();
    end;

    local procedure InsertDataToSalesInvAuxTable(var RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr."; RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    begin
        RSEIAuxSalesInvHdr."NPR RS EI Sales Invoice ID" := RSEInvoiceDocument."Sales Invoice ID";
        RSEIAuxSalesInvHdr."NPR RS EI Purchase Invoice ID" := RSEInvoiceDocument."Purchase Invoice ID";
        RSEIAuxSalesInvHdr."NPR RS EI Invoice Status" := RSEInvoiceDocument."Invoice Status";
        RSEIAuxSalesInvHdr."NPR RS EI Request ID" := RSEInvoiceDocument."Request ID";
        RSEIAuxSalesInvHdr."NPR RS EI Creation Date" := RSEInvoiceDocument."Creation Date";
        RSEIAuxSalesInvHdr."NPR RS EI Sending Date" := RSEInvoiceDocument."Sending Date";
        RSEIAuxSalesInvHdr."NPR RS Invoice Type Code" := RSEInvoiceDocument."Invoice Type Code";
        RSEIAuxSalesInvHdr.SaveRSEIAuxSalesInvHdrFields();
    end;

    local procedure CreateSalesInvoiceXMLDocument(var DocumentText: Text; SalesInvoiceHeader: Record "Sales Invoice Header"; RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        PrepaymentSalesInvHdr: Record "Sales Invoice Header";
        PrepaymentInvoiceFound: Boolean;
        Document: XmlDocument;
        InvoiceElement: XmlElement;
    begin
        SalesInvoiceLine.SetLoadFields(Type, "Line No.", Description, "Unit of Measure", "Line Discount Amount", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "Unit Price", "Line Discount %", "Line Discount Amount");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '<>%1|<>%2|<>%3', SalesInvoiceLine.Type::" ", SalesInvoiceLine.Type::"Allocation Account", SalesInvoiceLine.Type::"G/L Account");
        if SalesInvoiceLine.IsEmpty() then
            exit;

        SetCurrencyId(SalesInvoiceHeader."Currency Code");

        CreateXmlDocument(Document);

        InvoiceElement := RSEInvoiceMgt.CreateXmlElement('Invoice', XmlnsUrnNamespaceLbl, '');
        AddNamespaceDeclaration(InvoiceElement);

        PrepaymentInvoiceFound := FindPrepaymentInvoice(PrepaymentSalesInvHdr, SalesInvoiceHeader);
        if PrepaymentInvoiceFound then
            AddPrepaymentDocInfo(InvoiceElement, SalesInvoiceHeader, PrepaymentSalesInvHdr);

        AddMainHeaderSalesInvoiceInfo(InvoiceElement, SalesInvoiceHeader);

        AddInvoicePeriodInformation(InvoiceElement, RSEIAuxSalesInvHdr);

        if PrepaymentInvoiceFound then
            AddBillingReferenceInformation(InvoiceElement, PrepaymentSalesInvHdr);

        AddContractInformation(InvoiceElement, SalesInvoiceHeader);

        AddCompanyInformation(InvoiceElement);

        AddCustomerInformation(InvoiceElement, SalesInvoiceHeader);

        AddDeliveryInformation(InvoiceElement);

        AddPaymentMeansInformation(InvoiceElement, SalesInvoiceHeader, RSEIAuxSalesInvHdr);

        AddAllowanceChargeInformation(InvoiceElement, SalesInvoiceHeader);

        SalesInvoiceCalculateAndAddTaxSubtotals(InvoiceElement, SalesInvoiceHeader);
        AddTaxTotals(InvoiceElement, SalesInvoiceHeader);

        SalesInvoiceLine.FindSet();
        repeat
            AddSalesInvoiceLineInformation(InvoiceElement, SalesInvoiceLine);
        until SalesInvoiceLine.Next() = 0;

        Document.Add(InvoiceElement);

        Document.WriteTo(DocumentText);
    end;

    local procedure CreatePrepaymentInvoiceXMLDocument(var DocumentText: Text; SalesInvoiceHeader: Record "Sales Invoice Header"; RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        Document: XmlDocument;
        InvoiceElement: XmlElement;
    begin
        SalesInvoiceLine.SetLoadFields(Type, "Line No.", Description, "Unit of Measure", "Line Discount Amount", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT %", "Unit Price", "Line Discount %", "Line Discount Amount");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.IsEmpty() then
            exit;

        SetCurrencyId(SalesInvoiceHeader."Currency Code");

        CreateXmlDocument(Document);

        InvoiceElement := RSEInvoiceMgt.CreateXmlElement('Invoice', XmlnsUrnNamespaceLbl, '');
        AddNamespaceDeclaration(InvoiceElement);

        AddMainHeaderPrepaymentInvoiceInfo(InvoiceElement, SalesInvoiceHeader);

        AddInvoicePeriodInformation(InvoiceElement, RSEIAuxSalesInvHdr);

        AddContractInformation(InvoiceElement, SalesInvoiceHeader);

        AddCompanyInformation(InvoiceElement);

        AddCustomerInformation(InvoiceElement, SalesInvoiceHeader);

        AddPaymentMeansInformation(InvoiceElement, SalesInvoiceHeader, RSEIAuxSalesInvHdr);

        AddAllowanceChargeInformation(InvoiceElement, SalesInvoiceHeader);

        PrepaymentInvoiceCalculateAndAddTaxSubtotals(InvoiceElement, SalesInvoiceHeader);
        AddTaxTotals(InvoiceElement, SalesInvoiceHeader);

        SalesInvoiceLine.FindSet();
        repeat
            AddSalesInvoiceLineInformation(InvoiceElement, SalesInvoiceLine);
        until SalesInvoiceLine.Next() = 0;

        Document.Add(InvoiceElement);

        Document.WriteTo(DocumentText);
    end;

    local procedure CreateXmlDocument(var Document: XmlDocument)
    var
        XMLDec: XmlDeclaration;
    begin
        Document := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        Document.SetDeclaration(XMLDec);
    end;

    local procedure AddNamespaceDeclaration(var InvoiceElement: XmlElement)
    begin
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('cec', RSEInvoiceMgt.GetCecNamespace()));
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('cac', RSEInvoiceMgt.GetCacNamespace()));
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('cbc', RSEInvoiceMgt.GetCbcNamespace()));
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XsiUrlNamespaceLbl));
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('xsd', XsdUrlNamespaceLbl));
        InvoiceElement.Add(XmlAttribute.CreateNamespaceDeclaration('sbt', SbtUrlNamespaceLbl));
    end;

    local procedure AddPrepaymentDocInfo(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; PrepaymentSalesInvHdr: Record "Sales Invoice Header")
    var
        UBLExtensionsElement: XmlElement;
        UBLExtensionElement: XmlElement;
        ExtensionContentElement: XmlElement;
        SbtElement: XmlElement;
        InvoicedPrepaymentAmtElement: XmlElement;
        ReducedTotalsElement: XmlElement;
    begin
        UBLExtensionsElement := RSEInvoiceMgt.CreateXmlElement('UBLExtensions', RSEInvoiceMgt.GetCecNamespace(), '');
        UBLExtensionElement := RSEInvoiceMgt.CreateXmlElement('UBLExtension', RSEInvoiceMgt.GetCecNamespace(), '');
        ExtensionContentElement := RSEInvoiceMgt.CreateXmlElement('ExtensionContent', RSEInvoiceMgt.GetCecNamespace(), '');
        SbtElement := RSEInvoiceMgt.CreateXmlElement('SrbDtExt', SbtUrlNamespaceLbl, '');
        InvoicedPrepaymentAmtElement := RSEInvoiceMgt.CreateXmlElement('InvoicedPrepaymentAmount', XsdUrlNamespaceLbl, '');
        InvoicedPrepaymentAmtElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), PrepaymentSalesInvHdr."No."));
        PrepaymentInvoiceCalculateAndAddTaxSubtotals(InvoicedPrepaymentAmtElement, PrepaymentSalesInvHdr);
        SbtElement.Add(InvoicedPrepaymentAmtElement);

        ReducedTotalsElement := RSEInvoiceMgt.CreateXmlElement('ReducedTotals', XsdUrlNamespaceLbl, '');
        AddReducedTaxTotalsInformation(ReducedTotalsElement, SalesInvoiceHeader, PrepaymentSalesInvHdr);
        SbtElement.Add(ReducedTotalsElement);

        ExtensionContentElement.Add(SbtElement);
        UBLExtensionElement.Add(ExtensionContentElement);
        UBLExtensionsElement.Add(UBLExtensionElement);
        InvoiceElement.Add(UBLExtensionsElement);
    end;

    local procedure AddReducedTaxTotalsInformation(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; PrepaymentSalesInvHdr: Record "Sales Invoice Header")
    var
        SalesInvoiceTotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        SalesInvoiceTotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        SalesInvoiceTaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        SalesInvoiceTaxCategoriesList: List of [Enum "NPR RS EI Allowed Tax Categ."];
        PrepaymentSalesInvTotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        PrepaymentSalesInvTotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        PrepaymentSalesInvTaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        ReducedTotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        ReducedTotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        ReducedTaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        RSEIAllowedVATCateg: Enum "NPR RS EI Allowed Tax Categ.";
        TotalTaxAmount: Decimal;
    begin
        RSEInvoiceMgt.CalculateTotalVATAmounts(SalesInvoiceTotalTaxAmountDict, SalesInvoiceTotalTaxableAmountDict, SalesInvoiceTaxPercentagesDict, SalesInvoiceHeader."No.");
        RSEInvoiceMgt.CalculateTotalVATAmounts(PrepaymentSalesInvTotalTaxAmountDict, PrepaymentSalesInvTotalTaxableAmountDict, PrepaymentSalesInvTaxPercentagesDict, PrepaymentSalesInvHdr."No.");

        SalesInvoiceTaxCategoriesList := SalesInvoiceTotalTaxAmountDict.Keys();
        foreach RSEIAllowedVATCateg in SalesInvoiceTaxCategoriesList do begin
            if not ReducedTotalTaxAmountDict.Add(RSEIAllowedVATCateg, Abs(SalesInvoiceTotalTaxAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxAmountDict.Get(RSEIAllowedVATCateg))) then begin
                ReducedTotalTaxAmountDict.Set(RSEIAllowedVATCateg, Abs(ReducedTotalTaxAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxAmountDict.Get(RSEIAllowedVATCateg)));
                TotalTaxAmount += Abs(ReducedTotalTaxAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxAmountDict.Get(RSEIAllowedVATCateg));
            end else
                TotalTaxAmount += Abs(SalesInvoiceTotalTaxAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxAmountDict.Get(RSEIAllowedVATCateg));
            if not ReducedTotalTaxableAmountDict.Add(RSEIAllowedVATCateg, Abs(SalesInvoiceTotalTaxableAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxableAmountDict.Get(RSEIAllowedVATCateg))) then
                ReducedTotalTaxableAmountDict.Set(RSEIAllowedVATCateg, Abs(ReducedTotalTaxableAmountDict.Get(RSEIAllowedVATCateg)) - Abs(PrepaymentSalesInvTotalTaxableAmountDict.Get(RSEIAllowedVATCateg)));
            if ReducedTaxPercentagesDict.Add(RSEIAllowedVATCateg, SalesInvoiceTaxPercentagesDict.Get(RSEIAllowedVATCateg)) then;
        end;

        AddTaxSubtotals(InvoiceElement, TotalTaxAmount, PrepaymentSalesInvHdr."Prepayment Order No.", ReducedTotalTaxAmountDict, ReducedTotalTaxableAmountDict, ReducedTaxPercentagesDict);
        AddReducedTaxTotals(InvoiceElement, SalesInvoiceHeader, PrepaymentSalesInvHdr);
    end;

    local procedure AddReducedTaxTotals(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; PrepaymentSalesInvHdr: Record "Sales Invoice Header")
    var
        LegalMonetaryTotalElement: XmlElement;
    begin
        LegalMonetaryTotalElement := RSEInvoiceMgt.CreateXmlElement('LegalMonetaryTotal', RSEInvoiceMgt.GetCacNamespace(), '');
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('LineExtensionAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader.Amount - PrepaymentSalesInvHdr.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxExclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader.Amount - PrepaymentSalesInvHdr.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxInclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader."Amount Including VAT" - PrepaymentSalesInvHdr."Amount Including VAT"), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PayableAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader."Amount Including VAT" - PrepaymentSalesInvHdr."Amount Including VAT"), 'currencyID', CurrencyId));
        InvoiceElement.Add(LegalMonetaryTotalElement);
    end;

    local procedure AddMainHeaderSalesInvoiceInfo(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CustomizationIDLbl: Label 'urn:cen.eu:en16931:2017#compliant#urn:mfin.gov.rs:srbdt:2022', Locked = true;
    begin
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('CustomizationID', RSEInvoiceMgt.GetCbcNamespace(), CustomizationIDLbl));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceHeader."No."));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('IssueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(Today(), 10, '<Year4>-<Month,2>-<Day,2>')));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('DueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesInvoiceHeader."Due Date", 10, '<Year4>-<Month,2>-<Day,2>')));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('InvoiceTypeCode', RSEInvoiceMgt.GetCbcNamespace(), '380'));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('DocumentCurrencyCode', RSEInvoiceMgt.GetCbcNamespace(), CurrencyId));
    end;

    local procedure AddMainHeaderPrepaymentInvoiceInfo(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PrepaidSalesHeader: Record "Sales Header";
        CustomizationIDLbl: Label 'urn:cen.eu:en16931:2017#compliant#urn:mfin.gov.rs:srbdt:2022', Locked = true;
    begin
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('CustomizationID', RSEInvoiceMgt.GetCbcNamespace(), CustomizationIDLbl));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceHeader."No."));
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('IssueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(Today(), 10, '<Year4>-<Month,2>-<Day,2>')));

        PrepaidSalesHeader.Get(PrepaidSalesHeader."Document Type"::Order, SalesInvoiceHeader."Prepayment Order No.");
        if not AddDateOfPaymentForPrepaymentInvoice(InvoiceElement, PrepaidSalesHeader) then
            InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('DueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesInvoiceHeader."Due Date", 10, '<Year4>-<Month,2>-<Day,2>')));

        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('InvoiceTypeCode', RSEInvoiceMgt.GetCbcNamespace(), '386'));
        SetCurrencyId(PrepaidSalesHeader."Currency Code");
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('DocumentCurrencyCode', RSEInvoiceMgt.GetCbcNamespace(), CurrencyId));
    end;

    local procedure AddInvoicePeriodInformation(var InvoiceElement: XmlElement; RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.")
    var
        DescriptionCodeElement: XmlElement;
        InvoicePeriodElement: XmlElement;
    begin
        if RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method" in [RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method"::" "] then
            exit;

        InvoicePeriodElement := RSEInvoiceMgt.CreateXmlElement('InvoicePeriod', RSEInvoiceMgt.GetCacNamespace(), '');
        DescriptionCodeElement := RSEInvoiceMgt.CreateXmlElement('DescriptionCode', RSEInvoiceMgt.GetCbcNamespace(),
        RSEITaxLiabilityCode.Names().Get(RSEITaxLiabilityCode.Ordinals().IndexOf(RSEIAuxSalesInvHdr."NPR RS EI Tax Liability Method".AsInteger())));
        InvoicePeriodElement.Add(DescriptionCodeElement);
        InvoiceElement.Add(InvoicePeriodElement);
    end;

    local procedure AddBillingReferenceInformation(var InvoiceElement: XmlElement; PrepaymentSalesInvHdr: Record "Sales Invoice Header")
    var
        BillingRefElement: XmlElement;
        InvoiceDocumentRefElement: XmlElement;
    begin
        BillingRefElement := RSEInvoiceMgt.CreateXmlElement('BillingReference', RSEInvoiceMgt.GetCacNamespace(), '');
        InvoiceDocumentRefElement := RSEInvoiceMgt.CreateXmlElement('InvoiceDocumentReference', RSEInvoiceMgt.GetCacNamespace(), '');
        InvoiceDocumentRefElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), PrepaymentSalesInvHdr."No."));
        InvoiceDocumentRefElement.Add(RSEInvoiceMgt.CreateXmlElement('IssueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(FindRSEInvoiceDocumentSendingDate(PrepaymentSalesInvHdr."No."), 10, '<Year4>-<Month,2>-<Day,2>')));
        BillingRefElement.Add(InvoiceDocumentRefElement);
        InvoiceElement.Add(BillingRefElement);
    end;

    local procedure FindRSEInvoiceDocumentSendingDate(DocumentNo: Code[20]): Date
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        RSEInvoiceDocument.FindFirst();
        exit(RSEInvoiceDocument."Sending Date");
    end;

    local procedure AddContractInformation(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        ContractDocRefElement: XmlElement;
        ContractIDElement: XmlElement;
    begin
        ContractDocRefElement := RSEInvoiceMgt.CreateXmlElement('ContractDocumentReference', RSEInvoiceMgt.GetCacNamespace(), '');
        ContractIDElement := RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceHeader."No.");
        ContractDocRefElement.Add(ContractIDElement);

        InvoiceElement.Add(ContractDocRefElement);
    end;

    local procedure AddCompanyInformation(var InvoiceElement: XmlElement)
    var
        CompanyInfo: Record "Company Information";
        RSEIAuxCompanyInfo: Record "NPR RS EI Aux Company Info";
        AccSupplierElement: XmlElement;
        PartyElement: XmlElement;
        PartyIdentificationElement: XmlElement;
        PartyNameElement: XmlElement;
        PostalAddressElement: XmlElement;
        CountryElement: XmlElement;
        PartyTaxSchElement: XmlElement;
        TaxSchemeElement: XmlElement;
        PartyLegalEntElement: XmlElement;
        ContactElement: XmlElement;
    begin
        CompanyInfo.Get();

        AccSupplierElement := RSEInvoiceMgt.CreateXmlElement('AccountingSupplierParty', RSEInvoiceMgt.GetCacNamespace(), '');

        PartyElement := RSEInvoiceMgt.CreateXmlElement('Party', RSEInvoiceMgt.GetCacNamespace(), '');

        PartyElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('EndpointID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatVATRegistrationNoWithoutPrefix(CompanyInfo."VAT Registration No."), 'schemeID', '9948'));

        RSEIAuxCompanyInfo.ReadRSEIAuxCompanyInfoFields(CompanyInfo);

        if RSEIAuxCompanyInfo."NPR RS EI JBKJS Code" <> '' then begin
            PartyIdentificationElement := RSEInvoiceMgt.CreateXmlElement('PartyIdentification', RSEInvoiceMgt.GetCacNamespace(), '');
            PartyIdentificationElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), StrSubstNo(JBKJSCodeLbl, RSEIAuxCompanyInfo."NPR RS EI JBKJS Code")));
            PartyElement.Add(PartyIdentificationElement);
        end;

        PartyNameElement := RSEInvoiceMgt.CreateXmlElement('PartyName', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyNameElement.Add(RSEInvoiceMgt.CreateXmlElement('Name', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo.Name));

        PostalAddressElement := RSEInvoiceMgt.CreateXmlElement('PostalAddress', RSEInvoiceMgt.GetCacNamespace(), '');
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('StreetName', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo.Address));
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('CityName', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo.City));
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('PostalZone', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."Post Code"));
        CountryElement := RSEInvoiceMgt.CreateXmlElement('Country', RSEInvoiceMgt.GetCacNamespace(), '');
        CountryElement.Add(RSEInvoiceMgt.CreateXmlElement('IdentificationCode', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."Country/Region Code"));
        PostalAddressElement.Add(CountryElement);

        PartyTaxSchElement := RSEInvoiceMgt.CreateXmlElement('PartyTaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyTaxSchElement.Add(RSEInvoiceMgt.CreateXmlElement('CompanyID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatVATRegistrationNoWithPrefix(CompanyInfo."VAT Registration No.")));
        TaxSchemeElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        if CompanyInfo."VAT Registration No." <> '' then
            TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'))
        else
            TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'NO-VAT'));

        PartyTaxSchElement.Add(TaxSchemeElement);

        PartyLegalEntElement := RSEInvoiceMgt.CreateXmlElement('PartyLegalEntity', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyLegalEntElement.Add(RSEInvoiceMgt.CreateXmlElement('RegistrationName', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo.Name));
        PartyLegalEntElement.Add(RSEInvoiceMgt.CreateXmlElement('CompanyID', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."Registration No."));

        PartyElement.Add(PartyNameElement);
        PartyElement.Add(PostalAddressElement);
        PartyElement.Add(PartyTaxSchElement);
        PartyElement.Add(PartyLegalEntElement);

        if CompanyInfo."E-Mail" <> '' then begin
            ContactElement := RSEInvoiceMgt.CreateXmlElement('Contact', RSEInvoiceMgt.GetCacNamespace(), '');
            ContactElement.Add(RSEInvoiceMgt.CreateXmlElement('ElectronicMail', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."E-Mail"));
            PartyElement.Add(ContactElement);
        end;

        AccSupplierElement.Add(PartyElement);
        InvoiceElement.Add(AccSupplierElement);
    end;

    local procedure AddCustomerInformation(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
        AccCustomerElement: XmlElement;
        PartyElement: XmlElement;
        PartyIdentificationElement: XmlElement;
        PartyNameElement: XmlElement;
        PostalAddressElement: XmlElement;
        CountryElement: XmlElement;
        PartyTaxSchElement: XmlElement;
        TaxSchemeElement: XmlElement;
        PartyLegalEntElement: XmlElement;
        ContactElement: XmlElement;
    begin
        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);

        AccCustomerElement := RSEInvoiceMgt.CreateXmlElement('AccountingCustomerParty', RSEInvoiceMgt.GetCacNamespace(), '');

        PartyElement := RSEInvoiceMgt.CreateXmlElement('Party', RSEInvoiceMgt.GetCacNamespace(), '');

        if RSEIAuxCustomer."NPR RS EI JMBG" <> '' then
            PartyElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('EndpointID', RSEInvoiceMgt.GetCbcNamespace(), Format(RSEIAuxCustomer."NPR RS EI JMBG"), 'schemeID', '9948'))
        else
            PartyElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('EndpointID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatVATRegistrationNoWithoutPrefix(Customer."VAT Registration No."), 'schemeID', '9948'));

        if RSEIAuxCustomer."NPR RS EI JBKJS Code" <> '' then begin
            PartyIdentificationElement := RSEInvoiceMgt.CreateXmlElement('PartyIdentification', RSEInvoiceMgt.GetCacNamespace(), '');
            PartyIdentificationElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), StrSubstNo(JBKJSCodeLbl, RSEIAuxCustomer."NPR RS EI JBKJS Code")));
            PartyElement.Add(PartyIdentificationElement);
        end;

        PartyNameElement := RSEInvoiceMgt.CreateXmlElement('PartyName', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyNameElement.Add(RSEInvoiceMgt.CreateXmlElement('Name', RSEInvoiceMgt.GetCbcNamespace(), Customer.Name));

        PostalAddressElement := RSEInvoiceMgt.CreateXmlElement('PostalAddress', RSEInvoiceMgt.GetCacNamespace(), '');
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('StreetName', RSEInvoiceMgt.GetCbcNamespace(), Customer.Address));
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('CityName', RSEInvoiceMgt.GetCbcNamespace(), Customer.City));
        PostalAddressElement.Add(RSEInvoiceMgt.CreateXmlElement('PostalZone', RSEInvoiceMgt.GetCbcNamespace(), Customer."Post Code"));
        CountryElement := RSEInvoiceMgt.CreateXmlElement('Country', RSEInvoiceMgt.GetCacNamespace(), '');
        CountryElement.Add(RSEInvoiceMgt.CreateXmlElement('IdentificationCode', RSEInvoiceMgt.GetCbcNamespace(), Customer."Country/Region Code"));
        PostalAddressElement.Add(CountryElement);

        PartyTaxSchElement := RSEInvoiceMgt.CreateXmlElement('PartyTaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyTaxSchElement.Add(RSEInvoiceMgt.CreateXmlElement('CompanyID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatVATRegistrationNoWithPrefix(Customer."VAT Registration No.")));
        TaxSchemeElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        if Customer."VAT Registration No." <> '' then
            TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'))
        else
            TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'NO-VAT'));

        PartyTaxSchElement.Add(TaxSchemeElement);

        PartyLegalEntElement := RSEInvoiceMgt.CreateXmlElement('PartyLegalEntity', RSEInvoiceMgt.GetCacNamespace(), '');
        PartyLegalEntElement.Add(RSEInvoiceMgt.CreateXmlElement('RegistrationName', RSEInvoiceMgt.GetCbcNamespace(), Customer.Name));

        if RSEIAuxCustomer."NPR RS EI JMBG" <> '' then
            PartyLegalEntElement.Add(RSEInvoiceMgt.CreateXmlElement('CompanyID', RSEInvoiceMgt.GetCbcNamespace(), Format(RSEIAuxCustomer."NPR RS EI JMBG")))
        else
            PartyLegalEntElement.Add(RSEInvoiceMgt.CreateXmlElement('CompanyID', RSEInvoiceMgt.GetCbcNamespace(), Customer."Registration Number"));

        PartyElement.Add(PartyNameElement);
        PartyElement.Add(PostalAddressElement);
        PartyElement.Add(PartyTaxSchElement);
        PartyElement.Add(PartyLegalEntElement);

        if Customer."E-Mail" <> '' then begin
            ContactElement := RSEInvoiceMgt.CreateXmlElement('Contact', RSEInvoiceMgt.GetCacNamespace(), '');
            ContactElement.Add(RSEInvoiceMgt.CreateXmlElement('ElectronicMail', RSEInvoiceMgt.GetCbcNamespace(), Customer."E-Mail"));
            PartyElement.Add(ContactElement);
        end;

        AccCustomerElement.Add(PartyElement);
        InvoiceElement.Add(AccCustomerElement);
    end;

    local procedure AddDeliveryInformation(var InvoiceElement: XmlElement)
    var
        DeliveryElement: XmlElement;
        ActDeliveryDateElement: XmlElement;
    begin
        DeliveryElement := RSEInvoiceMgt.CreateXmlElement('Delivery', RSEInvoiceMgt.GetCacNamespace(), '');
        ActDeliveryDateElement := RSEInvoiceMgt.CreateXmlElement('ActualDeliveryDate', RSEInvoiceMgt.GetCbcNamespace(), Format(Today(), 10, '<Year4>-<Month,2>-<Day,2>'));
        DeliveryElement.Add(ActDeliveryDateElement);

        InvoiceElement.Add(DeliveryElement);
    end;

    local procedure AddPaymentMeansInformation(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header"; RSEIAuxSalesInvHdr: Record "NPR RS EI Aux Sales Inv. Hdr.")
    var
        CompanyInfo: Record "Company Information";
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        PaymentMeansElement: XmlElement;
        PayeeFinancialAccElement: XmlElement;
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        CompanyInfo.Get();

        RSEIPaymentMethodMapp.Get(SalesInvoiceHeader."Payment Method Code");

        RecRef.GetTable(RSEIPaymentMethodMapp);
        FRef := RecRef.Field(RSEIPaymentMethodMapp.FieldNo("RS EI Payment Means"));

        PaymentMeansElement := RSEInvoiceMgt.CreateXmlElement('PaymentMeans', RSEInvoiceMgt.GetCacNamespace(), '');
        PaymentMeansElement.Add(RSEInvoiceMgt.CreateXmlElement('PaymentMeansCode', RSEInvoiceMgt.GetCbcNamespace(), Format(FRef.GetEnumValueName(RSEIPaymentMethodMapp."RS EI Payment Means".AsInteger()))));

        if (RSEIAuxSalesInvHdr."NPR RS EI Reference Number" <> '') then
            PaymentMeansElement.Add(RSEInvoiceMgt.CreateXmlElement('PaymentID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatPaymentReferenceNumber(RSEIAuxSalesInvHdr."NPR RS EI Model", RSEIAuxSalesInvHdr."NPR RS EI Reference Number")));

        PayeeFinancialAccElement := RSEInvoiceMgt.CreateXmlElement('PayeeFinancialAccount', RSEInvoiceMgt.GetCacNamespace(), '');
        PayeeFinancialAccElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."Bank Account No."));
        PaymentMeansElement.Add(PayeeFinancialAccElement);

        InvoiceElement.Add(PaymentMeansElement);
    end;

    local procedure AddAllowanceChargeInformation(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DiscAmtPerCategoryDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        VatPercentagesPerCategoryDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TaxCategoriesList: List of [Enum "NPR RS EI Allowed Tax Categ."];
        RSEIAllowedVATCateg: Enum "NPR RS EI Allowed Tax Categ.";
        AllowanceChargeElement: XmlElement;
        AllowanceTaxCategoryElement: XmlElement;
        AllowanceTaxSchemeElement: XmlElement;
    begin
        if SalesInvoiceHeader."Invoice Discount Amount" = 0 then
            exit;
        RSEInvoiceMgt.CalculateVATCategoriesOfDiscountLines(DiscAmtPerCategoryDict, VatPercentagesPerCategoryDict, SalesInvoiceHeader."No.");

        TaxCategoriesList := DiscAmtPerCategoryDict.Keys();

        foreach RSEIAllowedVATCateg in TaxCategoriesList do begin
            AllowanceChargeElement := RSEInvoiceMgt.CreateXmlElement('AllowanceCharge', RSEInvoiceMgt.GetCacNamespace(), '');
            AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElement('ChargeIndicator', RSEInvoiceMgt.GetCbcNamespace(), 'false'));
            AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('Amount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(DiscAmtPerCategoryDict.Get(RSEIAllowedVATCateg)), 'currencyID', CurrencyId));

            AllowanceTaxCategoryElement := RSEInvoiceMgt.CreateXmlElement('TaxCategory', RSEInvoiceMgt.GetCacNamespace(), '');
            AllowanceTaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.GetAllowedTaxCategoryName(RSEIAllowedVATCateg.AsInteger())));
            AllowanceTaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('Percent', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(VatPercentagesPerCategoryDict.Get(RSEIAllowedVATCateg))));
            AllowanceTaxSchemeElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
            AllowanceTaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'));
            AllowanceTaxCategoryElement.Add(AllowanceTaxSchemeElement);

            AllowanceChargeElement.Add(AllowanceTaxCategoryElement);
            InvoiceElement.Add(AllowanceChargeElement);
        end;
    end;

    local procedure SalesInvoiceCalculateAndAddTaxSubtotals(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        TotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
    begin
        RSEInvoiceMgt.CalculateTotalVATAmounts(TotalTaxAmountDict, TotalTaxableAmountDict, TaxPercentagesDict, SalesInvoiceHeader."No.");
        AddTaxSubtotals(InvoiceElement, SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, SalesInvoiceHeader."Order No.", TotalTaxAmountDict, TotalTaxableAmountDict, TaxPercentagesDict);
    end;

    local procedure PrepaymentInvoiceCalculateAndAddTaxSubtotals(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        TotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
    begin
        RSEInvoiceMgt.CalculateTotalVATAmounts(TotalTaxAmountDict, TotalTaxableAmountDict, TaxPercentagesDict, SalesInvoiceHeader."No.");
        AddTaxSubtotals(InvoiceElement, SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount, SalesInvoiceHeader."Prepayment Order No.", TotalTaxAmountDict, TotalTaxableAmountDict, TaxPercentagesDict);
    end;

    local procedure AddTaxSubtotals(var InvoiceElement: XmlElement; TotalTaxAmount: Decimal; OrderNo: Code[20];
                                    TotalTax: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; TotalTaxable: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal]; TaxPercentage: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal])
    var
        TaxTotalElement: XmlElement;
        TaxSubtotalElement: XmlElement;
        TaxCategoryElement: XmlElement;
        TaxCatTaxSchElement: XmlElement;
        TaxCategoriesList: List of [Enum "NPR RS EI Allowed Tax Categ."];
        RSEIAllowedVATCateg: Enum "NPR RS EI Allowed Tax Categ.";
    begin
        TaxCategoriesList := TotalTax.Keys();

        TaxTotalElement := RSEInvoiceMgt.CreateXmlElement('TaxTotal', RSEInvoiceMgt.GetCacNamespace(), '');
        TaxTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(TotalTaxAmount), 'currencyID', CurrencyId));

        foreach RSEIAllowedVATCateg in TaxCategoriesList do begin
            TaxSubtotalElement := RSEInvoiceMgt.CreateXmlElement('TaxSubtotal', RSEInvoiceMgt.GetCacNamespace(), '');
            TaxSubtotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxableAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(Abs(TotalTaxable.Get(RSEIAllowedVATCateg))), 'currencyID', CurrencyId));
            TaxSubtotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(Abs(TotalTax.Get(RSEIAllowedVATCateg))), 'currencyID', CurrencyId));
            TaxCategoryElement := RSEInvoiceMgt.CreateXmlElement('TaxCategory', RSEInvoiceMgt.GetCacNamespace(), '');

            TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.GetAllowedTaxCategoryName(RSEIAllowedVATCateg.AsInteger())));
            TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('Percent', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(TaxPercentage.Get(RSEIAllowedVATCateg))));

            if TaxPercentage.Get(RSEIAllowedVATCateg) = 0 then
                TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('TaxExemptionReasonCode', RSEInvoiceMgt.GetCbcNamespace(), GetTaxExemptionReasonCode(OrderNo, RSEIAllowedVATCateg)));

            TaxCatTaxSchElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
            TaxCatTaxSchElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'));
            TaxCategoryElement.Add(TaxCatTaxSchElement);
            TaxSubtotalElement.Add(TaxCategoryElement);
            TaxTotalElement.Add(TaxSubtotalElement);
        end;

        InvoiceElement.Add(TaxTotalElement);
    end;

    local procedure AddTaxTotals(var InvoiceElement: XmlElement; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        LegalMonetaryTotalElement: XmlElement;
        TotalPrepaymentAmount: Decimal;
    begin
        LegalMonetaryTotalElement := RSEInvoiceMgt.CreateXmlElement('LegalMonetaryTotal', RSEInvoiceMgt.GetCacNamespace(), '');
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('LineExtensionAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxExclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxInclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader."Amount Including VAT"), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('AllowanceTotalAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceHeader."Invoice Discount Amount"), 'currencyID', CurrencyId));
        TotalPrepaymentAmount := GetTotalPrepaymentAmount(SalesInvoiceHeader);
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PrepaidAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(TotalPrepaymentAmount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PayableAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(RSEInvoiceMgt.GetPayableAmount(SalesInvoiceHeader."Amount Including VAT", TotalPrepaymentAmount, SalesInvoiceHeader."Invoice Discount Amount")), 'currencyID', CurrencyId));
        InvoiceElement.Add(LegalMonetaryTotalElement);
    end;

    local procedure AddSalesInvoiceLineInformation(var InvoiceElement: XmlElement; SalesInvoiceLine: Record "Sales Invoice Line")
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        UOMMapping: Record "NPR RS EI UOM Mapping";
        InvoiceLineElement: XmlElement;
        ItemElement: XmlElement;
        SellersItemIdElement: XmlElement;
        ClassifiedTaxCatElement: XmlElement;
        TaxSchemeElement: XmlElement;
        PriceElement: XmlElement;
    begin
        if SalesInvoiceLine."Unit of Measure Code" <> '' then
            UOMMapping.Get(SalesInvoiceLine."Unit of Measure Code")
        else begin
            RSEInvoiceSetup.Get();
            UOMMapping.Get(RSEInvoiceSetup."Default Unit Of Measure");
        end;

        InvoiceLineElement := RSEInvoiceMgt.CreateXmlElement('InvoiceLine', RSEInvoiceMgt.GetCacNamespace(), '');
        InvoiceLineElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesInvoiceLine."Line No.")));
        InvoiceLineElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('InvoicedQuantity', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesInvoiceLine.Quantity), 'unitCode', UOMMapping."RS EI UOM Code"));
        InvoiceLineElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('LineExtensionAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceLine.GetLineAmountExclVAT()), 'currencyID', CurrencyId));

        if SalesInvoiceLine."Line Discount Amount" > 0 then
            AddDiscountSectionToInvLine(InvoiceLineElement, SalesInvoiceLine);

        ItemElement := RSEInvoiceMgt.CreateXmlElement('Item', RSEInvoiceMgt.GetCacNamespace(), '');
        ItemElement.Add(RSEInvoiceMgt.CreateXmlElement('Name', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceLine.Description));

        SellersItemIdElement := RSEInvoiceMgt.CreateXmlElement('SellersItemIdentification', RSEInvoiceMgt.GetCacNamespace(), '');
        SellersItemIdElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceLine."No."));
        ItemElement.Add(SellersItemIdElement);

        RSEIVATPostSetupMap.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");

        ClassifiedTaxCatElement := RSEInvoiceMgt.CreateXmlElement('ClassifiedTaxCategory', RSEInvoiceMgt.GetCacNamespace(), '');
        ClassifiedTaxCatElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.GetAllowedTaxCategoryName(RSEIVATPostSetupMap."NPR RS EI Tax Category".AsInteger())));
        ClassifiedTaxCatElement.Add(RSEInvoiceMgt.CreateXmlElement('Percent', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesInvoiceLine."VAT %")));
        TaxSchemeElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'));
        ClassifiedTaxCatElement.Add(TaxSchemeElement);
        ItemElement.Add(ClassifiedTaxCatElement);

        InvoiceLineElement.Add(ItemElement);

        PriceElement := RSEInvoiceMgt.CreateXmlElement('Price', RSEInvoiceMgt.GetCacNamespace(), '');
        PriceElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PriceAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesInvoiceLine."Unit Price"), 'currencyID', CurrencyId));

        InvoiceLineElement.Add(PriceElement);

        InvoiceElement.Add(InvoiceLineElement);
    end;

    local procedure AddDiscountSectionToInvLine(var InvoiceLineElement: XmlElement; SalesInvoiceLine: Record "Sales Invoice Line")
    var
        AllowanceChargeElement: XmlElement;
    begin
        AllowanceChargeElement := RSEInvoiceMgt.CreateXmlElement('AllowanceCharge', RSEInvoiceMgt.GetCacNamespace(), '');
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElement('ChargeIndicator', RSEInvoiceMgt.GetCbcNamespace(), 'false'));
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElement('MultiplierFactorNumeric', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesInvoiceLine."Line Discount %")));
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('Amount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesInvoiceLine."Line Discount Amount"), 'currencyID', CurrencyId));
        InvoiceLineElement.Add(AllowanceChargeElement);
    end;

    local procedure AddDateOfPaymentForPrepaymentInvoice(var InvoiceElement: XmlElement; SalesHeader: Record "Sales Header"): Boolean
    var
        RSSalesHeader: Record "NPR RS Sales Header";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        RSSalesHeader.Read(SalesHeader.SystemId);
        if Format(RSSalesHeader."Applies-to Bank Entry") = '' then
            exit(false);

        BankAccountLedgerEntry.Get(RSSalesHeader."Applies-to Bank Entry");
        InvoiceElement.Add(RSEInvoiceMgt.CreateXmlElement('DueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(BankAccountLedgerEntry."Posting Date", 10, '<Year4>-<Month,2>-<Day,2>')));
        exit(true);
    end;

    #region RS EI - Helper procedures

    local procedure RSEInvoiceDocumentExists(DocumentNo: Code[20]): Boolean
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        exit(not RSEInvoiceDocument.IsEmpty());
    end;

    local procedure SetCurrencyId(CurrencyCode: Code[10])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode <> '' then
            CurrencyId := CurrencyCode
        else begin
            GLSetup.Get();
            GLSetup.TestField("LCY Code");
            CurrencyId := GLSetup."LCY Code";
        end;
    end;

    local procedure GetTaxExemptionReasonCode(OrderNo: Code[20]; RSEIAllowedVATCateg: Enum "NPR RS EI Allowed Tax Categ."): Code[20]
    var
        RSEIDocTaxExemption: Record "NPR RS EI Doc. Tax Exemption";
    begin
        RSEIDocTaxExemption.Get(OrderNo, RSEIAllowedVATCateg);
        exit(RSEIDocTaxExemption."Tax Exemption Reason Code");
    end;

    local procedure GetTotalPrepaymentAmount(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    var
        PrepaymentSalesInvHdr: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader."Order No." = '' then
            exit;
        PrepaymentSalesInvHdr.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        if not PrepaymentSalesInvHdr.FindFirst() then
            exit;
        PrepaymentSalesInvHdr.CalcFields("Amount Including VAT");
        exit(PrepaymentSalesInvHdr."Amount Including VAT");
    end;

    local procedure FindPrepaymentInvoice(var PrepaymentSalesInvHdr: Record "Sales Invoice Header"; SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        PrepaymentSalesInvHdr.SetRange("Prepayment Invoice", true);
        PrepaymentSalesInvHdr.SetRange("Prepayment Order No.", SalesInvoiceHeader."Order No.");
        if PrepaymentSalesInvHdr.FindFirst() then begin
            exit(PrepaymentSalesInvHdr.CalcFields(Amount, "Amount Including VAT"))
        end else
            exit(false);
    end;
    #endregion
#endif
}