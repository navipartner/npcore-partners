codeunit 6151497 "NPR CRO Tax Communication Mgt."
{
    Access = Internal;

    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";

    internal procedure CreateNormalSale(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    begin
        if not CROAuditMgt.EnsureValidCashierID(CROPOSAuditLogAuxInfo) then begin
            CROAuditMgt.ReportBillNotSentForInvalidCashierID(CROPOSAuditLogAuxInfo);
            exit;
        end;

        case CROPOSAuditLogAuxInfo."Audit Entry Type" of
            "NPR CRO Audit Entry Type"::"POS Entry":
                CreateAndFiscalizePOSSale(CROPOSAuditLogAuxInfo, Subsequent);
            "NPR CRO Audit Entry Type"::"Sales Invoice":
                CreateAndFiscalizeSalesInvSale(CROPOSAuditLogAuxInfo, Subsequent);
            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                CreateAndFiscalizeSalesCrMemoRefund(CROPOSAuditLogAuxInfo, Subsequent);
        end;
    end;

    #region CRO Tax Communication - XML Document Creation
    local procedure CreateAndFiscalizePOSSale(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary;
        Document: XmlDocument;
        Body: XmlElement;
        Content: XmlElement;
        VATSection: XmlElement;
        XmlWriteOpts: XmlWriteOptions;
    begin
        Document := XmlDocument.Create('', '');
        AddHeaderSection(CROPOSAuditLogAuxInfo, Body, Content);

        VATSection := XmlElement.Create('Pdv');

        if POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.") then begin
            POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryTaxLine.FindSet() then
                repeat
                    AggregateTaxBuffer(TempPOSEntryTaxLine, POSEntryTaxLine."Tax %", POSEntryTaxLine."Tax Base Amount", POSEntryTaxLine."Tax Amount");
                until POSEntryTaxLine.Next() = 0;

            if CROPOSAuditLogAuxInfo."Collect in Store" then
                AddCollectInStoreVATSection(POSEntry."Entry No.", TempPOSEntryTaxLine);

            AddVoucherVATSection(CROPOSAuditLogAuxInfo, TempPOSEntryTaxLine);

            EmitVATSection(VATSection, TempPOSEntryTaxLine);

            Content.Add(VATSection);

            Content.Add(CreateXmlElement('IznosUkupno', CROAuditMgt.FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount")));

            AddPaymentMethodSection(CROPOSAuditLogAuxInfo, Content);

            AddFooterSection(CROPOSAuditLogAuxInfo, Subsequent, Content);

            if CROPOSAuditLogAuxInfo."Paragon Number" <> '' then
                Content.Add(CreateXmlElement('ParagonBrRac', CROPOSAuditLogAuxInfo."Paragon Number"));
        end;

        Body.Add(Content);

        XmlWriteOpts.PreserveWhitespace(true);

        Document.Add(Body, XmlWriteOpts);

        SignBillAndSendToTA(CROPOSAuditLogAuxInfo, Document);
    end;

    local procedure CreateAndFiscalizeSalesInvSale(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    var
        SalesInvLines: Record "Sales Invoice Line";
        TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary;
        Document: XmlDocument;
        Body: XmlElement;
        Content: XmlElement;
        VATSection: XmlElement;
        XmlWriteOpts: XmlWriteOptions;
    begin
        SalesInvLines.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvLines.SetFilter(Type, '<>%1', SalesInvLines.Type::" ");
        if not SalesInvLines.FindSet() then
            exit;

        Document := XmlDocument.Create('', '');

        AddHeaderSection(CROPOSAuditLogAuxInfo, Body, Content);

        VATSection := XmlElement.Create('Pdv');
        repeat
            AggregateTaxBuffer(TempPOSEntryTaxLine,
                SalesInvLines."VAT %",
                SalesInvLines."VAT Base Amount",
                SalesInvLines."Amount Including VAT" - SalesInvLines."VAT Base Amount");
        until SalesInvLines.Next() = 0;

        AddVoucherVATSection(CROPOSAuditLogAuxInfo, TempPOSEntryTaxLine);

        EmitVATSection(VATSection, TempPOSEntryTaxLine);

        Content.Add(VATSection);

        Content.Add(CreateXmlElement('IznosUkupno', CROAuditMgt.FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount")));

        AddPaymentMethodSection(CROPOSAuditLogAuxInfo, Content);

        AddFooterSection(CROPOSAuditLogAuxInfo, Subsequent, Content);

        Body.Add(Content);

        XmlWriteOpts.PreserveWhitespace(true);

        Document.Add(Body, XmlWriteOpts);

        SignBillAndSendToTA(CROPOSAuditLogAuxInfo, Document);
    end;

    local procedure CreateAndFiscalizeSalesCrMemoRefund(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    var
        SalesCrMemoLines: Record "Sales Cr.Memo Line";
        TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary;
        Document: XmlDocument;
        Body: XmlElement;
        Content: XmlElement;
        VATSection: XmlElement;
        XmlWriteOpts: XmlWriteOptions;
    begin
        SalesCrMemoLines.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLines.SetFilter(Type, '<>%1', SalesCrMemoLines.Type::" ");
        if not SalesCrMemoLines.FindSet() then
            exit;

        Document := XmlDocument.Create('', '');

        AddHeaderSection(CROPOSAuditLogAuxInfo, Body, Content);

        VATSection := XmlElement.Create('Pdv');
        repeat
            AggregateTaxBuffer(TempPOSEntryTaxLine,
                SalesCrMemoLines."VAT %",
                -SalesCrMemoLines."VAT Base Amount",
                -(SalesCrMemoLines."Amount Including VAT" - SalesCrMemoLines."VAT Base Amount"));
        until SalesCrMemoLines.Next() = 0;

        AddVoucherVATSection(CROPOSAuditLogAuxInfo, TempPOSEntryTaxLine);

        EmitVATSection(VATSection, TempPOSEntryTaxLine);

        Content.Add(VATSection);

        Content.Add(CreateXmlElement('IznosUkupno', CROAuditMgt.FormatDecimal(-CROPOSAuditLogAuxInfo."Total Amount")));

        AddPaymentMethodSection(CROPOSAuditLogAuxInfo, Content);

        AddFooterSection(CROPOSAuditLogAuxInfo, Subsequent, Content);

        Body.Add(Content);

        XmlWriteOpts.PreserveWhitespace(true);

        Document.Add(Body, XmlWriteOpts);

        SignBillAndSendToTA(CROPOSAuditLogAuxInfo, Document);
    end;

    local procedure AddHeaderSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var Body: XmlElement; var Content: XmlElement)
    var
        CompanyInformation: Record "Company Information";
        NamespaceLbl: Label 'http://www.apis-it.hr/fin/2012/types/f73', Locked = true;
        TimeStampLbl: Label '%1T%2', Locked = true;
        IdPoruke: Text;
        BillNoSection: XmlElement;
        Header1: XmlElement;
    begin
        CompanyInformation.Get();
        CROFiscalizationSetup.Get();

        Body := XmlElement.Create('RacunZahtjev', NamespaceLbl);
        Body.Add(XmlAttribute.Create('Id', 'RacunZahtjev'));

        Header1 := XmlElement.Create('Zaglavlje');

        IdPoruke := DelChr(Format(CreateGuid()), '=', '{}').ToLower();
        Header1.Add(CreateXmlElement('IdPoruke', IdPoruke));
        Header1.Add(CreateXmlElement('DatumVrijeme', Format(CurrentDateTime(), 0, '<Day,2>.<Month,2>.<Year4>T<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>')));

        Body.Add(Header1);

        Content := XmlElement.Create('Racun');

        Content.Add(CreateXmlElement('Oib', CROFiscalizationSetup."Certificate Subject OIB"));
        if CompanyInformation."VAT Registration No." <> '' then
            Content.Add(CreateXmlElement('USustPdv', 'true'))
        else
            Content.Add(CreateXmlElement('USustPdv', 'false'));

        Content.Add(CreateXmlElement('DatVrijeme', StrSubstNo(TimeStampLbl, Format(CROPOSAuditLogAuxInfo."Entry Date", 10, '<Day,2>.<Month,2>.<Year4>'), Format(CROPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))));
        Content.Add(CreateXmlElement('OznSlijed', 'P'));

        BillNoSection := XmlElement.Create('BrRac');
        BillNoSection.Add(CreateXmlElement('BrOznRac', CROPOSAuditLogAuxInfo."Bill No."));
        BillNoSection.Add(CreateXmlElement('OznPosPr', CROPOSAuditLogAuxInfo."POS Store Code"));
        BillNoSection.Add(CreateXmlElement('OznNapUr', CROPOSAuditLogAuxInfo."POS Unit No."));

        Content.Add(BillNoSection);
    end;

    local procedure AddPaymentMethodSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var Content: XmlElement)
    begin
        case CROPOSAuditLogAuxInfo."Payment Method" of
            "NPR CRO Payment Method"::Card:
                Content.Add(CreateXmlElement('NacinPlac', 'K'));
            "NPR CRO Payment Method"::Cash:
                Content.Add(CreateXmlElement('NacinPlac', 'G'));
            "NPR CRO Payment Method"::Other:
                Content.Add(CreateXmlElement('NacinPlac', 'O'));
        end;
    end;

    local procedure AddFooterSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean; var Content: XmlElement)
    begin
        Content.Add(CreateXmlElement('OibOper', CROAuditMgt.FormatOIB(CROPOSAuditLogAuxInfo."Cashier ID")));
        Content.Add(CreateXmlElement('ZastKod', CROPOSAuditLogAuxInfo."ZKI Code"));

        if Subsequent then
            Content.Add(CreateXmlElement('NakDost', 'true'))
        else
            Content.Add(CreateXmlElement('NakDost', 'false'));
    end;

    local procedure AddCollectInStoreVATSection(POSEntryNo: Integer; var TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        PostedSalesInvoiceNo: Code[20];
        SalesOrderNo: Code[20];
        PostedSalesInvoices: List of [Code[20]];
        SalesOrders: List of [Code[20]];
    begin
        NpCsCollectMgt.FindDocumentsForDeliveredCollectInStoreDocument(POSEntryNo, PostedSalesInvoices, SalesOrders);

        foreach SalesOrderNo in SalesOrders do begin
            SalesLine.SetLoadFields("VAT %", "Amount Including VAT", "VAT Base Amount");
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", SalesOrderNo);
            SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
            if SalesLine.FindSet() then
                repeat
                    AggregateTaxBuffer(TempPOSEntryTaxLine,
                        SalesLine."VAT %",
                        SalesLine."VAT Base Amount",
                        SalesLine."Amount Including VAT" - SalesLine."VAT Base Amount");
                until SalesLine.Next() = 0
        end;

        foreach PostedSalesInvoiceNo in PostedSalesInvoices do begin
            SalesInvoiceLine.SetLoadFields("VAT %", "Amount Including VAT", "VAT Base Amount");
            SalesInvoiceLine.SetRange("Document No.", PostedSalesInvoiceNo);
            SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
            if SalesInvoiceLine.FindSet() then
                repeat
                    AggregateTaxBuffer(TempPOSEntryTaxLine,
                        SalesInvoiceLine."VAT %",
                        SalesInvoiceLine."VAT Base Amount",
                        SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
                until SalesInvoiceLine.Next() = 0;
        end;
    end;

    local procedure AddVoucherVATSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary)
    var
        NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        NpRvArchVoucherEntry2: Record "NPR NpRv Arch. Voucher Entry";
        POSEntrySalesLines: Record "NPR POS Entry Sales Line";
        SalesLinesType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
    begin
        NpRvArchVoucherEntry.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::Payment);
        NpRvArchVoucherEntry.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        if not NpRvArchVoucherEntry.FindFirst() then
            exit;
        NpRvArchVoucherEntry2.SetCurrentKey("Arch. Voucher No.");
        NpRvArchVoucherEntry2.SetRange("Arch. Voucher No.", NpRvArchVoucherEntry."Arch. Voucher No.");
        NpRvArchVoucherEntry2.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::"Issue Voucher");
        if not NpRvArchVoucherEntry2.FindFirst() then
            exit;
        POSEntrySalesLines.SetCurrentKey(Type, "No.", "Document No.");
        POSEntrySalesLines.SetRange("Document No.", NpRvArchVoucherEntry2."Document No.");
        POSEntrySalesLines.SetRange("Line No.", NpRvArchVoucherEntry2."Document Line No.");
        POSEntrySalesLines.SetRange(Type, SalesLinesType::Voucher);
        if not POSEntrySalesLines.FindFirst() then
            exit;
        repeat
            AggregateTaxBuffer(TempPOSEntryTaxLine,
                POSEntrySalesLines."VAT %",
                -POSEntrySalesLines."Amount Excl. VAT",
                -(POSEntrySalesLines."Amount Incl. VAT" - POSEntrySalesLines."Amount Excl. VAT"));
        until POSEntrySalesLines.Next() = 0;
    end;

    #endregion

    #region CRO Tax Communication - HTTP Request
    local procedure SignBillAndSendToTA(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var ReceiptDocument: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        DocumentFiscalizedSuccesfullyMsg: Label 'Sales Document %1 has been fiscalized successfully.';
        VerificationURLFormatLbl: Label 'https://porezna.gov.hr/rn?jir=%1&datv=%2_%3&izn=%4', Locked = true;
        OStream: OutStream;
        BaseValue: Text;
        ResponseText: Text;
        SignedValue: Text;
        FiscalTotalAmount: Decimal;
    begin
        FillBaseValue(ReceiptDocument, BaseValue);

        if not CROAuditMgt.SignXML(CROPOSAuditLogAuxInfo, BaseValue, SignedValue) then
            exit;

        if not SendToTA(CROPOSAuditLogAuxInfo, SignedValue, ResponseText) then
            exit;

        FiscalTotalAmount := CROPOSAuditLogAuxInfo."Total Amount";
        if CROPOSAuditLogAuxInfo."Audit Entry Type" = "NPR CRO Audit Entry Type"::"Sales Credit Memo" then
            FiscalTotalAmount := -FiscalTotalAmount;

        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(SignedValue);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        CROPOSAuditLogAuxInfo."Receipt Content".ImportStream(IStream, CROPOSAuditLogAuxInfo.FieldCaption("Receipt Content"));
        CROPOSAuditLogAuxInfo."Receipt Fiscalized" := true;
        CROPOSAuditLogAuxInfo."JIR Code" := CopyStr(GetJIRCodeFromResponse(ResponseText), 1, MaxStrLen(CROPOSAuditLogAuxInfo."JIR Code"));
        CROPOSAuditLogAuxInfo."Verification URL" := StrSubstNo(VerificationURLFormatLbl, CROPOSAuditLogAuxInfo."JIR Code", Format(CROPOSAuditLogAuxInfo."Entry Date", 8, '<Year4><Month,2><Day,2>'), Format(CROPOSAuditLogAuxInfo."Log Timestamp", 4, '<Hours24,2><Minutes,2>'), DelChr(CROAuditMgt.FormatDecimal(FiscalTotalAmount), '=', '.'));
        CROPOSAuditLogAuxInfo.Modify();

        case CROPOSAuditLogAuxInfo."Audit Entry Type" of
            "NPR CRO Audit Entry Type"::"Sales Invoice":
                begin
                    SetReceiptFiscalizedOnSalesInvoiceHeader(CROPOSAuditLogAuxInfo);
                    Message(StrSubstNo(DocumentFiscalizedSuccesfullyMsg, CROPOSAuditLogAuxInfo."Source Document No."));
                end;
            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                begin
                    SetReceiptFiscalizedOnSalesCrMemoHeader(CROPOSAuditLogAuxInfo);
                    Message(StrSubstNo(DocumentFiscalizedSuccesfullyMsg, CROPOSAuditLogAuxInfo."Source Document No."));
                end;
        end;
    end;

    local procedure SetReceiptFiscalizedOnSalesInvoiceHeader(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CROAuxSalesInvHeader: Record "NPR CRO Aux Sales Inv. Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not SalesInvoiceHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;
        CROAuxSalesInvHeader.ReadCROAuxSalesInvHeaderFields(SalesInvoiceHeader);
        CROAuxSalesInvHeader."NPR CRO Document Fiscalized" := true;
        CROAuxSalesInvHeader."NPR CRO Audit Entry No." := CROPOSAuditLogAuxInfo."Audit Entry No.";
        CROAuxSalesInvHeader.SaveCROAuxSalesInvHeaderFields();
    end;

    local procedure SetReceiptFiscalizedOnSalesCrMemoHeader(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CROAuxSalesCrMemoHeader: Record "NPR CRO Aux Sales Cr. Memo Hdr";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not SalesCrMemoHeader.Get(CROPOSAuditLogAuxInfo."Source Document No.") then
            exit;
        CROAuxSalesCrMemoHeader.ReadCROAuxSalesCrMemoHeaderFields(SalesCrMemoHeader);
        CROAuxSalesCrMemoHeader."NPR CRO Document Fiscalized" := true;
        CROAuxSalesCrMemoHeader."NPR CRO Audit Entry No." := CROPOSAuditLogAuxInfo."Audit Entry No.";
        CROAuxSalesCrMemoHeader.SaveCROAuxSalesCrMemoHeaderFields();
    end;

    local procedure SendToTA(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; XMLMessageText: Text; var ResponseText: Text): Boolean
    var
        IsHandled: Boolean;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        Url: Text;
    begin
        CROFiscalizationSetup.Get();
        Content.WriteFrom(XMLMessageText);
        Content.GetHeaders(Headers);
        CROAuditMgt.SetHeader(Headers, 'Content-Type', 'text/xml');
        Url := CROFiscalizationSetup."Environment URL";

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        OnBeforeSendHttpRequestForNormalSale(ResponseText, CROPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit(true);
        if CROAuditMgt.SendHttpRequest(RequestMessage, ResponseText, false) then
            exit(true);
    end;

    local procedure GetJIRCodeFromResponse(ResponseText: Text): Text
    var
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true;
        Document: XmlDocument;
        ChildNode: XmlNode;
        Node: XmlNode;
    begin
        XmlDocument.ReadFrom(ResponseText, Document);
        Document.GetChildElements().Get(1, ChildNode);
        ChildNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'Jir'), Node);
        exit(Node.AsXmlElement().InnerText());
    end;

    #endregion

    #region CRO Tax Communication - Helper Functions

    local procedure AggregateTaxBuffer(var TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary; TaxPercent: Decimal; TaxBaseAmount: Decimal; TaxAmount: Decimal)
    begin
        TempPOSEntryTaxLine.Reset();
        TempPOSEntryTaxLine.SetRange("Tax %", TaxPercent);
        if TempPOSEntryTaxLine.FindFirst() then begin
            TempPOSEntryTaxLine."Tax Base Amount" += TaxBaseAmount;
            TempPOSEntryTaxLine."Tax Amount" += TaxAmount;
            TempPOSEntryTaxLine.Modify();
        end else begin
            TempPOSEntryTaxLine.Init();
            TempPOSEntryTaxLine."Tax %" := TaxPercent;
            TempPOSEntryTaxLine."Tax Base Amount" := TaxBaseAmount;
            TempPOSEntryTaxLine."Tax Amount" := TaxAmount;
            TempPOSEntryTaxLine.Insert();
        end;
    end;

    local procedure EmitVATSection(var VATSection: XmlElement; var TempPOSEntryTaxLine: Record "NPR POS Entry Tax Line" temporary)
    var
        VATElements: XmlElement;
    begin
        TempPOSEntryTaxLine.Reset();
        if not TempPOSEntryTaxLine.FindSet() then
            exit;
        repeat
            VATElements := XmlElement.Create('Porez');
            VATElements.Add(CreateXmlElement('Stopa', CROAuditMgt.FormatDecimal(TempPOSEntryTaxLine."Tax %")));
            VATElements.Add(CreateXmlElement('Osnovica', CROAuditMgt.FormatDecimal(TempPOSEntryTaxLine."Tax Base Amount")));
            VATElements.Add(CreateXmlElement('Iznos', CROAuditMgt.FormatDecimal(TempPOSEntryTaxLine."Tax Amount")));
            VATSection.Add(VATElements);
        until TempPOSEntryTaxLine.Next() = 0;
    end;

    local procedure CreateXmlElement(Name: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name);
        Element.Add(XmlText.Create(Content));
    end;

    local procedure FillBaseValue(Document: XmlDocument; var BaseValue: Text)
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
        BaseValue := BaseValue.Replace('<?xml version="1.0" encoding="utf-8"?>', '');
        BaseValue := BaseValue.Replace('xmlns=""', '');
        BaseValue := BaseValue.Replace('"', '\"');
    end;
    #endregion

    #region CRO Tax Communication - Test Procedures

    internal procedure TestGetJIRCodeFromResponse(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; ResponseText: Text)
    begin
        CROPOSAuditLogAuxInfo."JIR Code" := CopyStr(GetJIRCodeFromResponse(ResponseText), 1, MaxStrLen(CROPOSAuditLogAuxInfo."JIR Code"));
        CROPOSAuditLogAuxInfo.Modify();
    end;
    #endregion

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForNormalSale(var ResponseText: Text; var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;
}