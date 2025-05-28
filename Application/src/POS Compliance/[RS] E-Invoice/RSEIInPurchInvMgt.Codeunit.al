codeunit 6184883 "NPR RS EI In Purch. Inv. Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)

    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true, Comment = '%1 = Element Name';

    internal procedure ProcessGetPurchaseInvoiceDocumentResponse(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; ResponseText: Text; PurchaseInvoiceId: Integer)
    var
        HelperText: Text;
        Document: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        InvoiceElement: XmlElement;
    begin
        SetupDocumentAndNamespaceMgr(Document, NamespaceManager, ResponseText);
        SelectMainInvoiceElement(InvoiceElement, Document);

        TempRSEInvoiceDocument.Init();
        TempRSEInvoiceDocument."Purchase Invoice ID" := PurchaseInvoiceId;
        TempRSEInvoiceDocument."Document Type" := TempRSEInvoiceDocument."Document Type"::" ";

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:ID', NamespaceManager);
#pragma warning disable AA0139
        TempRSEInvoiceDocument."Invoice Document No." := HelperText;
#pragma warning restore
        TempRSEInvoiceDocument."Entry No." := TempRSEInvoiceDocument.GetLastEntryNo() + 1;
        TempRSEInvoiceDocument.Direction := TempRSEInvoiceDocument.Direction::Incoming;
        TempRSEInvoiceDocument."Invoice Status" := TempRSEInvoiceDocument."Invoice Status"::NEW;

        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:CreditNoteTypeCode', NamespaceManager) then
            TempRSEInvoiceDocument."Invoice Type Code" := RSEInvoiceMgt.GetInvoiceTypeCodeFromText(HelperText);

        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:InvoiceTypeCode', NamespaceManager) then
            TempRSEInvoiceDocument."Invoice Type Code" := RSEInvoiceMgt.GetInvoiceTypeCodeFromText(HelperText);

        case TempRSEInvoiceDocument."Invoice Type Code" of
            TempRSEInvoiceDocument."Invoice Type Code"::"381":
                begin
                    if not CheckIfOriginalPurchaseInvImported(InvoiceElement, NamespaceManager) then
                        exit;
                    SetPurchaseCrMemoDocumentType(TempRSEInvoiceDocument, InvoiceElement, NamespaceManager);
                end;
            TempRSEInvoiceDocument."Invoice Type Code"::"386":
                SetPrepaymentPurchaseInvDocumentType(TempRSEInvoiceDocument);
        end;

        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name', NamespaceManager) then
            TempRSEInvoiceDocument."Supplier Name" := CopyStr(HelperText, 1, MaxStrLen(TempRSEInvoiceDocument."Supplier Name"));

        TempRSEInvoiceDocument."Customer Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempRSEInvoiceDocument."Customer Name"));

        RSEInvoiceMgt.GetDecimalValue(TempRSEInvoiceDocument.Amount, InvoiceElement, 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', NamespaceManager);

        SetDocumentHeaderInfoOnRSEInvoiceDocument(TempRSEInvoiceDocument, Document);
        TempRSEInvoiceDocument.SetResponseContent(ResponseText);

        TempRSEInvoiceDocument.Insert();

        Commit();
    end;

    internal procedure InsertPurchaseDocument(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        Document: XmlDocument;
        InvoiceElement: XmlElement;
        NamespaceManager: XmlNamespaceManager;
        VendorNotFoundAndOrderNotCreatedErr: Label 'Vendor has not been found or created. Purchase Document has not been created.';
    begin
        SetupDocumentAndNamespaceMgr(Document, NamespaceManager, TempRSEInvoiceDocument.GetResponseContent());
        SelectMainInvoiceElement(InvoiceElement, Document);

        PurchaseHeader.Init();

        if TempRSEInvoiceDocument.Prepayment then
            if not ValidatePrepaymentDocumentData(TempRSEInvoiceDocument, PurchaseHeader, InvoiceElement, NamespaceManager) then
                exit;

        case TempRSEInvoiceDocument."Document Type" of
            TempRSEInvoiceDocument."Document Type"::"Purchase Invoice":
                InitializeDocTypeOnPurhcHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, InvoiceElement, NamespaceManager);
            TempRSEInvoiceDocument."Document Type"::"Purchase Order":
                InitializeDocTypeOnPurhcHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoiceElement, NamespaceManager);
            TempRSEInvoiceDocument."Document Type"::"Purchase Cr. Memo":
                InitializeDocTypeOnPurhcHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", InvoiceElement, NamespaceManager);
        end;

        InitializePurchaseHeaderDates(PurchaseHeader, InvoiceElement, NamespaceManager);

        if not FindVendorFromRegistrationNumber(Vendor, InvoiceElement, NamespaceManager) then
            Error(VendorNotFoundAndOrderNotCreatedErr);

        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");

        AddPaymentMethodInfo(PurchaseHeader, InvoiceElement, NamespaceManager);

        PurchaseHeader.Insert();
        OnAfterInsertPurchaseHeaderOnInsertPurchaseDocument(PurchaseHeader);

        AddRSEIPurchHeaderAuxInfo(PurchaseHeader, TempRSEInvoiceDocument, InvoiceElement, NamespaceManager);

        CreateRSEInvoiceDocumentEntryFromPurchase(TempRSEInvoiceDocument, PurchaseHeader, Vendor);
    end;

    local procedure SetDocumentHeaderInfoOnRSEInvoiceDocument(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document"; Document: XmlDocument)
    var
        DocumentHeaderNode: XmlNode;
        HelperDocHeaderNode: XmlNode;
    begin
        Document.GetChildElements().Get(1, DocumentHeaderNode);

        DocumentHeaderNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'SalesInvoiceId'), HelperDocHeaderNode);
        Evaluate(TempRSEInvoiceDocument."Sales Invoice ID", HelperDocHeaderNode.AsXmlElement().InnerText());

        DocumentHeaderNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'PurchaseInvoiceId'), HelperDocHeaderNode);
        Evaluate(TempRSEInvoiceDocument."Purchase Invoice ID", HelperDocHeaderNode.AsXmlElement().InnerText());

        DocumentHeaderNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'CreationDate'), HelperDocHeaderNode);
        Evaluate(TempRSEInvoiceDocument."Creation Date", HelperDocHeaderNode.AsXmlElement().InnerText());

        DocumentHeaderNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'SendingDate'), HelperDocHeaderNode);
        Evaluate(TempRSEInvoiceDocument."Sending Date", HelperDocHeaderNode.AsXmlElement().InnerText());
    end;

    local procedure InitializePurchaseHeaderDates(var PurchaseHeader: Record "Purchase Header"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        HelperText: Text;
    begin
        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:IssueDate', NamespaceManager) then begin
            Evaluate(PurchaseHeader."Order Date", HelperText);
            Evaluate(PurchaseHeader."Posting Date", HelperText);
            Evaluate(PurchaseHeader."Document Date", HelperText);
        end;
        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:DueDate', NamespaceManager) then
            Evaluate(PurchaseHeader."Due Date", HelperText);
        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:DocumentCurrencyCode', NamespaceManager) then
            Evaluate(PurchaseHeader."Currency Code", HelperText);

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:InvoicePeriod/cbc:DescriptionCode', NamespaceManager);
        case HelperText of
            '35':
                if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:Delivery/cbc:ActualDeliveryDate', NamespaceManager) then
                    Evaluate(PurchaseHeader."VAT Reporting Date", HelperText);
            '432':
                PurchaseHeader."VAT Reporting Date" := PurchaseHeader."Due Date";
            '3':
                PurchaseHeader."VAT Reporting Date" := PurchaseHeader."Order Date";
        end;
    end;

#if BC24
    local procedure InitializeDocTypeOnPurhcHeader(var PurchaseHeader: Record "Purchase Header"; PurchaseDocumentType: Enum "Purchase Document Type"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeries: Codeunit "No. Series";
        HelperText: Text;
    begin
        PurchasesPayablesSetup.Get();
        PurchaseHeader."Document Type" := PurchaseDocumentType;
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:ID', NamespaceManager);
        case PurchaseDocumentType of
            PurchaseDocumentType::Order:
                begin
                    PurchaseHeader."No." := NoSeries.GetNextNo(PurchasesPayablesSetup."Order Nos.");
                    PurchaseHeader.Validate("Vendor Invoice No.", HelperText);
                end;
            PurchaseDocumentType::Invoice:
                begin
                    PurchaseHeader."No." := NoSeries.GetNextNo(PurchasesPayablesSetup."Invoice Nos.");
                    PurchaseHeader.Validate("Vendor Invoice No.", HelperText);
                end;
            PurchaseDocumentType::"Credit Memo":
                begin
                    PurchaseHeader."No." := NoSeries.GetNextNo(PurchasesPayablesSetup."Credit Memo Nos.");
                    PurchaseHeader.Validate("Vendor Cr. Memo No.", HelperText)
                end;
        end;
    end;
#else
    local procedure InitializeDocTypeOnPurhcHeader(var PurchaseHeader: Record "Purchase Header"; PurchaseDocumentType: Enum "Purchase Document Type"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        HelperText: Text;
    begin
        PurchasesPayablesSetup.Get();
        PurchaseHeader."Document Type" := PurchaseDocumentType;
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cbc:ID', NamespaceManager);
        case PurchaseDocumentType of
            PurchaseDocumentType::Order:
                begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Order Nos.", Today(), false);
#ELSE
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Order Nos.", Today(), true);
#ENDIF
                    PurchaseHeader.Validate("Vendor Invoice No.", HelperText);
                end;
            PurchaseDocumentType::Invoice:
                begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Invoice Nos.", Today(), false);
#ELSE
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Invoice Nos.", Today(), true);
#ENDIF
                    PurchaseHeader.Validate("Vendor Invoice No.", HelperText);
                end;
            PurchaseDocumentType::"Credit Memo":
                begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Credit Memo Nos.", Today(), false);
#ELSE
                    PurchaseHeader."No." := NoSeriesManagement.GetNextNo(PurchasesPayablesSetup."Credit Memo Nos.", Today(), true);
#ENDIF
                    PurchaseHeader.Validate("Vendor Cr. Memo No.", HelperText)
                end;
        end;
    end;
#endif

    local procedure CreateRSEInvoiceDocumentEntryFromPurchase(TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
    begin
        RSEInvoiceDocument.Init();
        RSEInvoiceDocument.Copy(TempRSEInvoiceDocument);
        RSEInvoiceDocument."Entry No." := RSEInvoiceDocument.GetLastEntryNo() + 1;
        RSEInvoiceDocument."Invoice Status" := RSEInvoiceDocument."Invoice Status"::SEEN;
        RSEInvoiceDocument."Supplier No." := Vendor."No.";
        RSEInvoiceDocument."Supplier Name" := Vendor.Name;
        RSEInvoiceDocument."Document No." := PurchaseHeader."No.";
#pragma warning disable AA0139
        RSEInvoiceDocument."Customer Name" := CompanyName();
#pragma warning restore
        RSEInvoiceDocument."Created" := true;

        RSEInvoiceDocument.Insert();
    end;

    #region RS E-Invoice Processing Procedures

    local procedure FindVendorFromRegistrationNumber(var Vendor: Record Vendor; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        ConfirmManagement: Codeunit "Confirm Management";
        VendorCard: Page "Vendor Card";
        RegistrationNumberText: Text;
        VATRegNoText: Text;
        VendorName: Text;
        HelperText: Text;
        ConfirmVendorCreationLbl: Label 'Vendor with vendor name %1, VAT Registration No. %2 and Registration Number %3 has not been found. Do you want to create it?', Comment = '%1 = Vendor name, %2 = VAT Reg. No., %3 = Registration No.';
    begin
        RSEInvoiceMgt.GetTextValue(RegistrationNumberText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID', NamespaceManager);
        RSEInvoiceMgt.GetTextValue(VendorName, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name', NamespaceManager);
        RSEInvoiceMgt.GetTextValue(VATRegNoText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID', NamespaceManager);

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        Vendor.SetRange("Registration Number", RegistrationNumberText);
#else
        Vendor.SetRange("VAT Registration No.", VATRegNoText);
#endif
        if Vendor.FindFirst() then
            exit(true);

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmVendorCreationLbl, VendorName, VATRegNoText, RegistrationNumberText), false) then
            exit(false);

        PurchSetup.Get();
        Vendor.Init();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        Vendor."No." := NoSeriesManagement.GetNextNo(PurchSetup."Vendor Nos.", 0D, false);
#ELSE
        Vendor."No." := NoSeriesManagement.GetNextNo(PurchSetup."Vendor Nos.", 0D, true);
#ENDIF
        Vendor.Name := CopyStr(VendorName, 1, MaxStrLen(Vendor.Name));
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        Vendor."Registration Number" := CopyStr(RegistrationNumberText, 1, MaxStrLen(Vendor."Registration Number"));
#endif
        Vendor."VAT Registration No." := CopyStr(VATRegNoText, 1, MaxStrLen(Vendor."VAT Registration No."));

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName', NamespaceManager);
        Vendor.Address := CopyStr(HelperText, 1, MaxStrLen(Vendor.Address));

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName', NamespaceManager);
        Vendor.City := CopyStr(HelperText, 1, MaxStrLen(Vendor.City));

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone', NamespaceManager);
        Vendor."Post Code" := CopyStr(HelperText, 1, MaxStrLen(Vendor."Post Code"));

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode', NamespaceManager);
        Vendor."Country/Region Code" := CopyStr(HelperText, 1, MaxStrLen(Vendor."Country/Region Code"));

        Vendor.Insert();
        Commit();
        VendorCard.SetRecord(Vendor);
        if VendorCard.RunModal() = Action::OK then begin
            VendorCard.GetRecord(Vendor);
            exit(true)
        end;
    end;

    local procedure AddPaymentMethodInfo(var PurhcaseHeader: Record "Purchase Header"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        RSEIPaymentMeans: Enum "NPR RS EI Payment Means";
        HelperText: Text;
    begin
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:PaymentMeans/cbc:PaymentMeansCode', NamespaceManager);
        if not RSEIPaymentMeans.Names().Contains(HelperText) then
            exit;
        RSEIPaymentMethodMapp.SetRange("RS EI Payment Means", Enum::"NPR RS EI Payment Means".FromInteger(RSEIPaymentMeans.Ordinals.Get(RSEIPaymentMeans.Names.IndexOf(HelperText))));
        if not RSEIPaymentMethodMapp.FindFirst() then
            exit;
        PurhcaseHeader.Validate("Payment Method Code", RSEIPaymentMethodMapp."Payment Method Code");
    end;

    local procedure AddRSEIPurchHeaderAuxInfo(PurchaseHeader: Record "Purchase Header"; TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        HelperText: Text;
    begin
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchaseHeader);

        RSEIAuxPurchHeader."NPR RS E-Invoice" := true;
        RSEIAuxPurchHeader."NPR RS EI Prepayment" := TempRSEInvoiceDocument.Prepayment;

        if TempRSEInvoiceDocument.Prepayment then
            RSEInvoiceMgt.GetDecimalValue(RSEIAuxPurchHeader."NPR RS EI Total Amount", InvoiceElement, 'cac:TaxTotal/cbc:TaxAmount', NamespaceManager)
        else
            RSEInvoiceMgt.GetDecimalValue(RSEIAuxPurchHeader."NPR RS EI Total Amount", InvoiceElement, 'cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', NamespaceManager);

        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:PaymentMeans/cbc:PaymentID', NamespaceManager) then begin
            GetModelFromPaymentId(RSEIAuxPurchHeader."NPR RS EI Model", HelperText);
            GetReferenceNoFromPaymentId(RSEIAuxPurchHeader."NPR RS EI Reference Number", HelperText);
        end;

        if RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:InvoicePeriod/cbc:DescriptionCode', NamespaceManager) then
            RSEIAuxPurchHeader."NPR RS EI Tax Liability Method" := Enum::"NPR RS EI Tax Liability Method".FromInteger(Enum::"NPR RS EI Tax Liability Method".Ordinals().Get(Enum::"NPR RS EI Tax Liability Method".Names().IndexOf(HelperText)));

        RSEIAuxPurchHeader."NPR RS EI Creation Date" := TempRSEInvoiceDocument."Creation Date";
        RSEIAuxPurchHeader."NPR RS EI Sending Date" := TempRSEInvoiceDocument."Sending Date";
        RSEIAuxPurchHeader."NPR RS EI Sales Invoice ID" := TempRSEInvoiceDocument."Sales Invoice ID";
        RSEIAuxPurchHeader."NPR RS EI Purchase Invoice ID" := TempRSEInvoiceDocument."Purchase Invoice ID";
        RSEIAuxPurchHeader."NPR RS EI Invoice Status" := TempRSEInvoiceDocument."Invoice Status";
        RSEIAuxPurchHeader."NPR RS E-Invoice Type Code" := TempRSEInvoiceDocument."Invoice Type Code";

        RSEIAuxPurchHeader.SaveRSEIAuxPurchaseHeaderFields();
    end;

    #endregion RS E-Invoice Processing Procedures

    #region RS E-Invoice Helper Procedures

    local procedure SetupDocumentAndNamespaceMgr(var Document: XmlDocument; var NamespaceManager: XmlNamespaceManager; DocumentText: Text)
    begin
        XmlDocument.ReadFrom(DocumentText, Document);
        NamespaceManager.NameTable(Document.NameTable());
        NamespaceManager.AddNamespace('cac', RSEInvoiceMgt.GetCacNamespace());
        NamespaceManager.AddNamespace('cec', RSEInvoiceMgt.GetCecNamespace());
        NamespaceManager.AddNamespace('cbc', RSEInvoiceMgt.GetCbcNamespace());
    end;

    local procedure SelectMainInvoiceElement(var InvoiceElement: XmlElement; Document: XmlDocument)
    var
        DocumentBodyNode: XmlNode;
    begin
        Document.GetChildElements().Get(1, DocumentBodyNode);
        if not DocumentBodyNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'Invoice'), DocumentBodyNode) then
            DocumentBodyNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'CreditNote'), DocumentBodyNode);
        InvoiceElement := DocumentBodyNode.AsXmlElement();
    end;

    local procedure GetModelFromPaymentId(var Model: Text[3]; FullText: Text)
    begin
        if not FullText.Contains('mod') then
            exit;
        FullText := CopyStr(FullText, FullText.IndexOf('('), FullText.IndexOf(')'));
        Model := CopyStr(DelChr(FullText, '=', DelChr(FullText, '=', '0123456789')), 1, MaxStrLen(Model));
    end;

    local procedure GetReferenceNoFromPaymentId(var ReferenceNo: Text[23]; FullText: Text)
    begin
        if FullText.Contains('mod') then
            FullText := CopyStr(FullText, FullText.IndexOf(') ') + 1, StrLen(FullText)).Trim();
        ReferenceNo := CopyStr(FullText, 1, MaxStrLen(ReferenceNo));
    end;

    local procedure ValidatePrepaymentDocumentData(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; var PurchaseHeader: Record "Purchase Header"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager): Boolean
    begin
        if not CheckRSLocalizationForPrepayment(TempRSEInvoiceDocument."Invoice Document No.") then
            exit(false);
        case TempRSEInvoiceDocument."Invoice Type Code" of
            TempRSEInvoiceDocument."Invoice Type Code"::"386":
                exit(ValidatePrepaymentInvoiceData(PurchaseHeader));
            TempRSEInvoiceDocument."Invoice Type Code"::"381":
                exit(ValidatePrepaymentCrMemoData(TempRSEInvoiceDocument, PurchaseHeader, InvoiceElement, NamespaceManager));
            else
                exit(true);
        end;
    end;

    local procedure CheckRSLocalizationForPrepayment(InvoiceDocumentNo: Code[35]): Boolean
    var
        RSLocalizationNotEnabledMsg: Label 'RS Localization is not enabled and Prepayment Invoice %1 cannot be imported.', Comment = '%1 = Document No.';
    begin
        if RSEInvoiceMgt.IsRSLocalizationEnabled() then
            exit(true);

        Message(RSLocalizationNotEnabledMsg, InvoiceDocumentNo);
    end;

    local procedure SetPurchaseCrMemoDocumentType(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    begin
        TempRSEInvoiceDocument."Document Type" := TempRSEInvoiceDocument."Document Type"::"Purchase Cr. Memo";
        CheckIsPrepaymentCreditMemo(TempRSEInvoiceDocument, InvoiceElement, NamespaceManager);
    end;

    local procedure SetPrepaymentPurchaseInvDocumentType(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary)
    begin
        TempRSEInvoiceDocument."Document Type" := TempRSEInvoiceDocument."Document Type"::"Purchase Invoice";
        TempRSEInvoiceDocument.Prepayment := true;
    end;

    local procedure ValidatePrepaymentInvoiceData(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        RSEInvoiceMgt.SetLocalizationPrepaymentPurchaseHeader(PurchaseHeader);
        PurchasesPayablesSetup.Get();
        PurchaseHeader."Prepayment No. Series" := PurchasesPayablesSetup."Posted Prepmt. Inv. Nos.";
        exit(true);
    end;

    local procedure ValidatePrepaymentCrMemoData(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; var PurchaseHeader: Record "Purchase Header"; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager): Boolean
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        HelperText: Text;
    begin
        if not GetReferencedEInvoiceDocument(RSEInvoiceDocument, TempRSEInvoiceDocument, InvoiceElement, NamespaceManager) then
            exit(false);

        RSEInvoiceMgt.SetLocalizationPrepaymentPurchaseHeader(PurchaseHeader);

        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID', NamespaceManager);
        PurchaseHeader."Applies-to Doc. Type" := PurchaseHeader."Applies-to Doc. Type"::Invoice;
        PurchaseHeader."Applies-to Doc. No." := RSEInvoiceDocument."Document No.";
        PurchasesPayablesSetup.Get();
        PurchaseHeader."Prepmt. Cr. Memo No. Series" := PurchasesPayablesSetup."Posted Prepmt. Cr. Memo Nos.";
        exit(true);
    end;

    local procedure GetReferencedEInvoiceDocument(var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager): Boolean
    var
        HelperText: Text;
        CannotImportCrMemoDocumentIfOriginalNotImportedMsg: Label 'You cannot import Purchase Credit Memo: %1, if the related document %2 was not imported.', Comment = '%1 = Purch. Cr. Memo Document No, %2 = Referenced Document No.';
        CannotImportCrMemoDocumentIfOriginalNotPostedMsg: Label 'You cannot import Purchase Credit Memo: %1, if the related document %2 was not posted.', Comment = '%1 = Purch. Cr. Memo Document No, %2 = Referenced Document No.';
    begin
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID', NamespaceManager);
        RSEInvoiceDocument.SetRange("Invoice Document No.", HelperText);
        if not RSEInvoiceDocument.FindFirst() then begin
            Message(CannotImportCrMemoDocumentIfOriginalNotImportedMsg, TempRSEInvoiceDocument."Invoice Document No.", HelperText);
            exit(false);
        end;
        if not RSEInvoiceDocument.Posted then begin
            Message(CannotImportCrMemoDocumentIfOriginalNotPostedMsg, TempRSEInvoiceDocument."Invoice Document No.", HelperText);
            exit(false);
        end;
        exit(true);
    end;

    local procedure CheckIsPrepaymentCreditMemo(var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary; InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        HelperText: Text;
    begin
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID', NamespaceManager);
        RSEInvoiceDocument.SetRange("Invoice Document No.", HelperText);
        if RSEInvoiceDocument.FindFirst() then
            TempRSEInvoiceDocument.Prepayment := RSEInvoiceDocument.Prepayment;
    end;

    local procedure CheckIfOriginalPurchaseInvImported(InvoiceElement: XmlElement; NamespaceManager: XmlNamespaceManager): Boolean
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        HelperText: Text;
    begin
        RSEInvoiceMgt.GetTextValue(HelperText, InvoiceElement, 'cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID', NamespaceManager);
        RSEInvoiceDocument.SetRange("Invoice Document No.", HelperText);
        exit(not RSEInvoiceDocument.IsEmpty());
    end;

    #endregion RS E-Invoice Helper Procedures

    #region Automated Test Helpers

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertPurchaseHeaderOnInsertPurchaseDocument(PurchaseHeader: Record "Purchase Header")
    begin
    end;

    #endregion Automated Test Helpers
#endif
}