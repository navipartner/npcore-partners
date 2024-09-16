codeunit 6184888 "NPR RSEI Out SalesCr.Memo Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        RSEITaxLiabilityCode: Enum "NPR RS EI Tax Liability Method";
        XsdUrlNamespaceLbl: Label 'http://www.w3.org/2001/XMLSchema', Locked = true;
        XsiUrlNamespaceLbl: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        XmlnsUrnNamespaceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2', Locked = true;
        SbtUrlNamespaceLbl: Label 'http://mfin.gov.rs/srbdt/srbdtext', Locked = true;
        JBKJSCodeLbl: Label 'JBKJS:%1', Comment = '%1 = JBKJS Code', Locked = true;
        CurrencyId: Code[10];

    internal procedure CreateRequestAndSendSalesCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        Customer: Record Customer;
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        RequestText: Text;
        ShouldSendDocumentToSEFQst: Label 'Are you sure this document should be sent to SEF?';
    begin
        Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");
        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);
        RSEIAuxSalesCrMemoHdr.ReadRSEIAuxSalesCrMemoHdrFields(SalesCrMemoHeader);
        if not ((RSEIAuxCustomer."NPR RS E-Invoice Customer") and (RSEIAuxSalesCrMemoHdr."NPR RS EI Send To SEF")) then
            exit;

        if not (ConfirmManagement.GetResponseOrDefault(ShouldSendDocumentToSEFQst, false)) then begin
            RSEIAuxSalesCrMemoHdr."NPR RS EI Send To SEF" := false;
            RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
            exit;
        end;

        RSEInvoiceMgt.CheckIsDataSetOnSalesCrMemoHeader(SalesCrMemoHeader);

        RSEInvoiceDocument.SetRange("Document No.", SalesCrMemoHeader."No.");
        if not RSEInvoiceDocument.IsEmpty() then
            exit;

        CheckIfAppliedDocumentIsApproved(SalesCrMemoHeader);

        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        CreateInvoiceXMLDocument(RequestText, SalesCrMemoHeader, Customer, RSEIAuxCustomer, RSEIAuxSalesCrMemoHdr);
        InsertInvoiceDocumentRec(RSEInvoiceDocument, SalesCrMemoHeader, RSEIAuxSalesCrMemoHdr, RequestText);
        RSEICommunicationMgt.SendSalesDocument(RSEInvoiceDocument);
        InsertDataToSalesCrMemoAuxTable(RSEIAuxSalesCrMemoHdr, RSEInvoiceDocument);
    end;

    local procedure InsertInvoiceDocumentRec(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr"; RequestText: Text)
    begin
        RSEInvoiceDocument.Init();
        RSEInvoiceDocument."Entry No." := RSEInvoiceDocument.GetLastEntryNo() + 1;
        RSEInvoiceDocument."Document Type" := RSEInvoiceDocument."Document Type"::"Sales Cr. Memo";
        RSEInvoiceDocument."Invoice Status" := RSEInvoiceDocument."Invoice Status"::DRAFT;
        RSEInvoiceDocument.Direction := RSEInvoiceDocument.Direction::Outgoing;
        RSEInvoiceDocument."Document No." := SalesCrMemoHeader."No.";
        RSEInvoiceDocument."Invoice Document No." := SalesCrMemoHeader."External Document No.";
        RSEInvoiceDocument."Creation Date" := SalesCrMemoHeader."Posting Date";
        RSEInvoiceDocument."Sending Date" := Today();
        RSEInvoiceDocument.Amount := SalesCrMemoHeader."Amount Including VAT";
#pragma warning disable AA0139
        RSEInvoiceDocument."Supplier Name" := CompanyName();
#pragma warning restore
        RSEInvoiceDocument."Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
        RSEInvoiceDocument."Customer Name" := SalesCrMemoHeader."Sell-to Customer Name";
        RSEInvoiceDocument."Created" := true;
        RSEInvoiceDocument.Posted := true;
        RSEInvoiceDocument."Invoice Type Code" := RSEInvoiceDocument."Invoice Type Code"::"381";
        RSEInvoiceDocument.SetRequestContent(RequestText);
        RSEInvoiceDocument."CIR Invoice" := RSEIAuxSalesCrMemoHdr."NPR RS EI Send To CIR";

        RSEInvoiceDocument.Insert();
    end;

    local procedure InsertDataToSalesCrMemoAuxTable(var RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr"; RSEInvoiceDocument: Record "NPR RS E-Invoice Document")
    begin
        RSEIAuxSalesCrMemoHdr."NPR RS EI Sales Invoice ID" := RSEInvoiceDocument."Sales Invoice ID";
        RSEIAuxSalesCrMemoHdr."NPR RS EI Purchase Invoice ID" := RSEInvoiceDocument."Purchase Invoice ID";
        RSEIAuxSalesCrMemoHdr."NPR RS EI Invoice Status" := RSEInvoiceDocument."Invoice Status";
        RSEIAuxSalesCrMemoHdr."NPR RS EI Request ID" := RSEInvoiceDocument."Request ID";
        RSEIAuxSalesCrMemoHdr."NPR RS EI Creation Date" := RSEInvoiceDocument."Creation Date";
        RSEIAuxSalesCrMemoHdr."NPR RS EI Sending Date" := RSEInvoiceDocument."Sending Date";
        RSEIAuxSalesCrMemoHdr."NPR RS E-Invoice Type Code" := RSEInvoiceDocument."Invoice Type Code";
        RSEIAuxSalesCrMemoHdr.SaveRSEIAuxSalesCrMemoHdrFields();
    end;

    local procedure CreateInvoiceXMLDocument(var DocumentText: Text; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; Customer: Record Customer; RSEIAuxCustomer: Record "NPR RS EI Aux Customer"; RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Document: XmlDocument;
        CreditNoteElement: XmlElement;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if not SalesCrMemoLine.FindSet() then
            exit;

        CreateXmlDocument(Document);

        CreditNoteElement := RSEInvoiceMgt.CreateXmlElement('CreditNote', XmlnsUrnNamespaceLbl, '');
        AddNamespaceDeclaration(CreditNoteElement);

        AddMainHeaderInfo(CreditNoteElement, SalesCrMemoHeader);

        AddInvoiceTypeCode(CreditNoteElement, RSEIAuxSalesCrMemoHdr);

        AddBillingReferenceInformation(CreditNoteElement, SalesCrMemoHeader);

        AddContractInformation(CreditNoteElement, SalesCrMemoHeader);

        AddCompanyInformation(CreditNoteElement);

        AddCustomerInformation(CreditNoteElement, Customer, RSEIAuxCustomer);

        AddPaymentMeansInformation(CreditNoteElement, SalesCrMemoHeader, RSEIAuxSalesCrMemoHdr);

        AddTaxInformation(CreditNoteElement, SalesCrMemoHeader);
        repeat
            AddSalesCrMemoLineInformation(CreditNoteElement, SalesCrMemoHeader, SalesCrMemoLine);
        until SalesCrMemoLine.Next() = 0;

        Document.Add(CreditNoteElement);

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

    local procedure AddMainHeaderInfo(var CreditNoteElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CustomizationIDLbl: Label 'urn:cen.eu:en16931:2017#compliant#urn:mfin.gov.rs:srbdt:2022', Locked = true;
    begin
        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('CustomizationID', RSEInvoiceMgt.GetCbcNamespace(), CustomizationIDLbl));
        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesCrMemoHeader."No."));
        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('IssueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(Today(), 10, '<Year4>-<Month,2>-<Day,2>')));
        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('CreditNoteTypeCode', RSEInvoiceMgt.GetCbcNamespace(), '381'));
        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('Note', RSEInvoiceMgt.GetCbcNamespace(), SalesCrMemoHeader.GetWorkDescription()));

        if SalesCrMemoHeader."Currency Code" <> '' then
            CurrencyId := SalesCrMemoHeader."Currency Code"
        else begin
            GeneralLedgerSetup.Get();
            CurrencyId := GeneralLedgerSetup."LCY Code";
        end;

        CreditNoteElement.Add(RSEInvoiceMgt.CreateXmlElement('DocumentCurrencyCode', RSEInvoiceMgt.GetCbcNamespace(), CurrencyId));
    end;

    local procedure AddInvoiceTypeCode(var CreditNoteElement: XmlElement; RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr")
    var
        InvoicePeriodElement: XmlElement;
    begin
        if RSEIAuxSalesCrMemoHdr."NPR RS EI Tax Liability Method" in [RSEIAuxSalesCrMemoHdr."NPR RS EI Tax Liability Method"::" "] then
            exit;

        InvoicePeriodElement := RSEInvoiceMgt.CreateXmlElement('InvoicePeriod', RSEInvoiceMgt.GetCacNamespace(), '');

        InvoicePeriodElement.Add(RSEInvoiceMgt.CreateXmlElement('DescriptionCode', RSEInvoiceMgt.GetCbcNamespace(),
          RSEITaxLiabilityCode.Names().Get(RSEITaxLiabilityCode.Ordinals().IndexOf(RSEIAuxSalesCrMemoHdr."NPR RS EI Tax Liability Method".AsInteger()))));

        CreditNoteElement.Add(InvoicePeriodElement);
    end;

    local procedure AddNamespaceDeclaration(var CreditNoteElement: XmlElement)
    begin
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('cec', RSEInvoiceMgt.GetCecNamespace()));
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('cac', RSEInvoiceMgt.GetCacNamespace()));
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('cbc', RSEInvoiceMgt.GetCbcNamespace()));
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', XsiUrlNamespaceLbl));
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('xsd', XsdUrlNamespaceLbl));
        CreditNoteElement.Add(XmlAttribute.CreateNamespaceDeclaration('sbt', SbtUrlNamespaceLbl));
    end;

    local procedure AddBillingReferenceInformation(var CreditNoteElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        BillingRefElement: XmlElement;
        InvoiceDocumentRefElement: XmlElement;
    begin
        if SalesCrMemoHeader."Prepayment Credit Memo" then begin
            SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesCrMemoHeader."Prepayment Order No.");
            if not SalesInvoiceHeader.FindFirst() then
                exit;
        end else
            SalesInvoiceHeader.Get(SalesCrMemoHeader."Applies-to Doc. No.");

        BillingRefElement := RSEInvoiceMgt.CreateXmlElement('BillingReference', RSEInvoiceMgt.GetCacNamespace(), '');
        InvoiceDocumentRefElement := RSEInvoiceMgt.CreateXmlElement('InvoiceDocumentReference', RSEInvoiceMgt.GetCacNamespace(), '');

        InvoiceDocumentRefElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesInvoiceHeader."No."));
        InvoiceDocumentRefElement.Add(RSEInvoiceMgt.CreateXmlElement('IssueDate', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesInvoiceHeader."Posting Date", 10, '<Year4>-<Month,2>-<Day,2>')));

        BillingRefElement.Add(InvoiceDocumentRefElement);
        CreditNoteElement.Add(BillingRefElement);
    end;

    local procedure AddContractInformation(var CreditNoteElement: XmlElement; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        ContractDocRefElement: XmlElement;
        ContractIDElement: XmlElement;
    begin
        ContractDocRefElement := RSEInvoiceMgt.CreateXmlElement('ContractDocumentReference', RSEInvoiceMgt.GetCacNamespace(), '');
        ContractIDElement := RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesCrMemoHeader."No.");
        ContractDocRefElement.Add(ContractIDElement);

        CreditNoteElement.Add(ContractDocRefElement);
    end;

    local procedure AddCompanyInformation(var CreditNoteElement: XmlElement)
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
        CreditNoteElement.Add(AccSupplierElement);
    end;

    local procedure AddCustomerInformation(var CreditNoteElement: XmlElement; Customer: Record Customer; RSEIAuxCustomer: Record "NPR RS EI Aux Customer")
    var
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
        CreditNoteElement.Add(AccCustomerElement);
    end;

    local procedure AddPaymentMeansInformation(var CreditNoteElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; RSEIAuxSalesCrMemoHdr: Record "NPR RSEI Aux Sales Cr.Memo Hdr")
    var
        CompanyInfo: Record "Company Information";
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        PaymentMeansElement: XmlElement;
        PayeeFinancialAccElement: XmlElement;
        RecRef: RecordRef;
        FRef: FieldRef;
    begin
        CompanyInfo.Get();

        RSEIPaymentMethodMapp.Get(SalesCrMemoHeader."Payment Method Code");

        RecRef.GetTable(RSEIPaymentMethodMapp);
        FRef := RecRef.Field(RSEIPaymentMethodMapp.FieldNo("RS EI Payment Means"));

        PaymentMeansElement := RSEInvoiceMgt.CreateXmlElement('PaymentMeans', RSEInvoiceMgt.GetCacNamespace(), '');
        PaymentMeansElement.Add(RSEInvoiceMgt.CreateXmlElement('PaymentMeansCode', RSEInvoiceMgt.GetCbcNamespace(), Format(FRef.GetEnumValueName(RSEIPaymentMethodMapp."RS EI Payment Means".AsInteger()))));

        if (RSEIAuxSalesCrMemoHdr."NPR RS EI Reference Number" <> '') then
            PaymentMeansElement.Add(RSEInvoiceMgt.CreateXmlElement('PaymentID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatPaymentReferenceNumber(RSEIAuxSalesCrMemoHdr."NPR RS EI Model", RSEIAuxSalesCrMemoHdr."NPR RS EI Reference Number")));

        PayeeFinancialAccElement := RSEInvoiceMgt.CreateXmlElement('PayeeFinancialAccount', RSEInvoiceMgt.GetCacNamespace(), '');
        PayeeFinancialAccElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), CompanyInfo."Bank Account No."));
        PaymentMeansElement.Add(PayeeFinancialAccElement);

        CreditNoteElement.Add(PaymentMeansElement);
    end;

    local procedure AddTaxInformation(var CreditNoteElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        RSEIDocTaxExemption: Record "NPR RS EI Doc. Tax Exemption";
        TaxTotalElement: XmlElement;
        TaxSubtotalElement: XmlElement;
        TaxCategoryElement: XmlElement;
        TaxCatTaxSchElement: XmlElement;
        LegalMonetaryTotalElement: XmlElement;
        TotalPrepaymentAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
        TotalTaxAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TotalTaxableAmountDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TaxPercentagesDict: Dictionary of [Enum "NPR RS EI Allowed Tax Categ.", Decimal];
        TaxCategoriesList: List of [Enum "NPR RS EI Allowed Tax Categ."];
        RSEIAllowedVATCateg: Enum "NPR RS EI Allowed Tax Categ.";
    begin
        RSEInvoiceMgt.CalculateTotalVATAmounts(TotalTaxAmountDict, TotalTaxableAmountDict, TaxPercentagesDict, SalesCrMemoHeader."No.");

        TaxCategoriesList := TotalTaxAmountDict.Keys();

        TaxTotalElement := RSEInvoiceMgt.CreateXmlElement('TaxTotal', RSEInvoiceMgt.GetCacNamespace(), '');
        SalesInvoiceLine.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group", "Amount Including VAT", "VAT Base Amount", "VAT %", "Line Discount Amount", "Unit of Measure", Type);
        SalesInvoiceLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        TaxTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount), 'currencyID', CurrencyId));

        foreach RSEIAllowedVATCateg in TaxCategoriesList do begin
            TaxSubtotalElement := RSEInvoiceMgt.CreateXmlElement('TaxSubtotal', RSEInvoiceMgt.GetCacNamespace(), '');
            TaxSubtotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxableAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(TotalTaxableAmountDict.Get(RSEIAllowedVATCateg)), 'currencyID', CurrencyId));
            TaxSubtotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(TotalTaxAmountDict.Get(RSEIAllowedVATCateg)), 'currencyID', CurrencyId));
            TaxCategoryElement := RSEInvoiceMgt.CreateXmlElement('TaxCategory', RSEInvoiceMgt.GetCacNamespace(), '');

            TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.GetAllowedTaxCategoryName(RSEIAllowedVATCateg.AsInteger())));
            TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('Percent', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(TaxPercentagesDict.Get(RSEIAllowedVATCateg))));

            if TaxPercentagesDict.Get(RSEIAllowedVATCateg) = 0 then begin
                RSEIDocTaxExemption.Get(SalesCrMemoHeader."No.", RSEIAllowedVATCateg);
                TaxCategoryElement.Add(RSEInvoiceMgt.CreateXmlElement('TaxExemptionReasonCode', RSEInvoiceMgt.GetCbcNamespace(), RSEIDocTaxExemption."Tax Exemption Reason Code"));
            end;

            TaxCatTaxSchElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
            TaxCatTaxSchElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'));
            TaxCategoryElement.Add(TaxCatTaxSchElement);
            TaxSubtotalElement.Add(TaxCategoryElement);
            TaxTotalElement.Add(TaxSubtotalElement);
        end;

        CreditNoteElement.Add(TaxTotalElement);

        LegalMonetaryTotalElement := RSEInvoiceMgt.CreateXmlElement('LegalMonetaryTotal', RSEInvoiceMgt.GetCacNamespace(), '');
        GetTotalLineDiscountAmount(TotalLineDiscountAmount, SalesCrMemoHeader);
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('LineExtensionAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesCrMemoHeader.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxExclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesCrMemoHeader.Amount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('TaxInclusiveAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesCrMemoHeader."Amount Including VAT"), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('AllowanceTotalAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(SalesCrMemoHeader."Invoice Discount Amount"), 'currencyID', CurrencyId));
        GetTotalPrepaymentAmount(TotalPrepaymentAmount, SalesCrMemoHeader);
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PrepaidAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(TotalPrepaymentAmount), 'currencyID', CurrencyId));
        LegalMonetaryTotalElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PayableAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatTwoDecimals(RSEInvoiceMgt.GetPayableAmount(SalesCrMemoHeader."Amount Including VAT", TotalPrepaymentAmount, SalesCrMemoHeader."Invoice Discount Amount")), 'currencyID', CurrencyId));
        CreditNoteElement.Add(LegalMonetaryTotalElement);
    end;

    local procedure AddSalesCrMemoLineInformation(var CreditNoteElement: XmlElement; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        UOMMapping: Record "NPR RS EI UOM Mapping";
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        CreditNoteLineElement: XmlElement;
        ItemElement: XmlElement;
        SellersItemIdElement: XmlElement;
        ClassifiedTaxCatElement: XmlElement;
        TaxSchemeElement: XmlElement;
        PriceElement: XmlElement;
    begin
        if not (SalesCrMemoLine.Type in [SalesCrMemoLine.Type::Item, SalesCrMemoLine.Type::"Charge (Item)", SalesCrMemoLine.Type::"G/L Account"]) then
            exit;

        if SalesCrMemoLine."Unit of Measure Code" <> '' then
            UOMMapping.Get(SalesCrMemoLine."Unit of Measure Code")
        else begin
            RSEInvoiceSetup.Get();
            UOMMapping.Get(RSEInvoiceSetup."Default Unit Of Measure");
        end;

        CreditNoteLineElement := RSEInvoiceMgt.CreateXmlElement('CreditNoteLine', RSEInvoiceMgt.GetCacNamespace(), '');
        CreditNoteLineElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesCrMemoLine."Line No.")));
        CreditNoteLineElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('CreditedQuantity', RSEInvoiceMgt.GetCbcNamespace(), Format(SalesCrMemoLine.Quantity), 'unitCode', UOMMapping."RS EI UOM Code"));
        CreditNoteLineElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('LineExtensionAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesCrMemoLine.GetLineAmountExclVAT()), 'currencyID', CurrencyId));

        if SalesCrMemoLine."Line Discount Amount" > 0 then
            AddDiscountSectionToInvLine(CreditNoteLineElement, SalesCrMemoHeader, SalesCrMemoLine);

        ItemElement := RSEInvoiceMgt.CreateXmlElement('Item', RSEInvoiceMgt.GetCacNamespace(), '');

        ItemElement.Add(RSEInvoiceMgt.CreateXmlElement('Name', RSEInvoiceMgt.GetCbcNamespace(), SalesCrMemoLine.Description));

        SellersItemIdElement := RSEInvoiceMgt.CreateXmlElement('SellersItemIdentification', RSEInvoiceMgt.GetCacNamespace(), '');
        SellersItemIdElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), SalesCrMemoLine."No."));
        ItemElement.Add(SellersItemIdElement);

        VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group");

        ClassifiedTaxCatElement := RSEInvoiceMgt.CreateXmlElement('ClassifiedTaxCategory', RSEInvoiceMgt.GetCacNamespace(), '');
        ClassifiedTaxCatElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), VATPostingSetup."Tax Category"));
        ClassifiedTaxCatElement.Add(RSEInvoiceMgt.CreateXmlElement('Percent', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesCrMemoLine."VAT %")));
        TaxSchemeElement := RSEInvoiceMgt.CreateXmlElement('TaxScheme', RSEInvoiceMgt.GetCacNamespace(), '');
        TaxSchemeElement.Add(RSEInvoiceMgt.CreateXmlElement('ID', RSEInvoiceMgt.GetCbcNamespace(), 'VAT'));
        ClassifiedTaxCatElement.Add(TaxSchemeElement);
        ItemElement.Add(ClassifiedTaxCatElement);

        CreditNoteLineElement.Add(ItemElement);

        PriceElement := RSEInvoiceMgt.CreateXmlElement('Price', RSEInvoiceMgt.GetCacNamespace(), '');
        PriceElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('PriceAmount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesCrMemoLine."Unit Price"), 'currencyID', CurrencyId));

        CreditNoteLineElement.Add(PriceElement);

        CreditNoteElement.Add(CreditNoteLineElement);
    end;

    local procedure AddDiscountSectionToInvLine(var CreditNoteElement: XmlElement; PosteSalesInvHdr: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        AllowanceChargeElement: XmlElement;
    begin
        AllowanceChargeElement := RSEInvoiceMgt.CreateXmlElement('AllowanceCharge', RSEInvoiceMgt.GetCacNamespace(), '');
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElement('ChargeIndicator', RSEInvoiceMgt.GetCbcNamespace(), 'false'));
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElement('MultiplierFactorNumeric', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesCrMemoLine."Line Discount %")));
        AllowanceChargeElement.Add(RSEInvoiceMgt.CreateXmlElementWAttribute('Amount', RSEInvoiceMgt.GetCbcNamespace(), RSEInvoiceMgt.FormatDecimal(SalesCrMemoLine."Line Discount Amount"), 'currencyID', PosteSalesInvHdr."Currency Code"));
        CreditNoteElement.Add(AllowanceChargeElement);
    end;

    #region RS EI - Helper procedures
    local procedure GetTotalLineDiscountAmount(var TotalLineDiscount: Decimal; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetLoadFields("Line Discount Amount", Type);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter("Line Discount Amount", '>0');
        if SalesCrMemoLine.IsEmpty() then
            exit;
        SalesCrMemoLine.FindSet();
        repeat
            if (SalesCrMemoLine.Type in [SalesCrMemoLine.Type::Item, SalesCrMemoLine.Type::"Charge (Item)", SalesCrMemoLine.Type::"G/L Account"]) then
                TotalLineDiscount += SalesCrMemoLine."Line Discount Amount";
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure GetTotalPrepaymentAmount(var Amount: Decimal; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        SalesCrMemoLine2: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.IsEmpty() then
            exit;
        SalesCrMemoHeader2.SetRange("Prepayment Order No.", SalesCrMemoHeader."No.");
        if SalesCrMemoHeader2.IsEmpty() then
            exit;
        SalesCrMemoLine.FindSet();
        repeat
            if (SalesCrMemoLine.Type in [SalesCrMemoLine.Type::Item, SalesCrMemoLine.Type::"Charge (Item)", SalesCrMemoLine.Type::"G/L Account"]) then begin
                SalesCrMemoLine.FindSet();
                repeat
                    if SalesCrMemoLine2.Get(SalesCrMemoHeader2."No.", SalesCrMemoLine."Line No.") then
                        Amount += SalesCrMemoLine2."Amount Including VAT";
                until SalesCrMemoHeader2.Next() = 0;
            end;
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure CheckIfAppliedDocumentIsApproved(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        AppliesToDocNoMustBeSentToEInvoiceErr: Label 'Sales Invoice with Document No. %1 must be sent to E-Invoice first.', Comment = '%1 - Applies-to Doc. No.';
        AppliesToDocNoMustBeApprovedToEInvoiceErr: Label 'Sales Invoice with Document No. %1 must be approved first.', Comment = '%1 - Applies-to Doc. No.';
    begin
        if SalesCrMemoHeader."Prepayment Credit Memo" then begin
            SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesCrMemoHeader."Prepayment Order No.");
            if SalesInvoiceHeader.FindFirst() then begin
                RSEInvoiceDocument.SetRange("Document No.", SalesInvoiceHeader."No.");
                if not RSEInvoiceDocument.FindFirst() then
                    Error(AppliesToDocNoMustBeSentToEInvoiceErr, SalesInvoiceHeader."No.")
                else begin
                    RSEICommunicationMgt.GetSalesDocumentStatus(RSEInvoiceDocument);
                    if not (RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::APPROVED]) then
                        Error(AppliesToDocNoMustBeApprovedToEInvoiceErr, SalesInvoiceHeader."No.");
                end;
            end
        end else begin
            RSEInvoiceDocument.SetRange("Document No.", SalesCrMemoHeader."Applies-to Doc. No.");
            if not RSEInvoiceDocument.FindFirst() then
                Error(AppliesToDocNoMustBeSentToEInvoiceErr, SalesCrMemoHeader."Applies-to Doc. No.")
            else begin
                RSEICommunicationMgt.GetSalesDocumentStatus(RSEInvoiceDocument);
                if not (RSEInvoiceDocument."Invoice Status" in [RSEInvoiceDocument."Invoice Status"::APPROVED]) then
                    Error(AppliesToDocNoMustBeApprovedToEInvoiceErr, SalesCrMemoHeader."Applies-to Doc. No.");
            end;
        end;
    end;
    #endregion
#endif
}