codeunit 6151497 "NPR CRO Tax Communication Mgt."
{
    Access = Internal;

    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";

    internal procedure CreateNormalSale(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    begin
        CreateXMLFiscalMessage(CROPOSAuditLogAuxInfo, Subsequent);
    end;

    #region CRO Tax Communication - XML Document Creation

    local procedure CreateXMLFiscalMessage(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Subsequent: Boolean)
    var
        CompanyInformation: Record "Company Information";
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
        POSEntry: Record "NPR POS Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        SalespersonPurch: Record "Salesperson/Purchaser";
        NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        NamespaceLbl: Label 'http://www.apis-it.hr/fin/2012/types/f73', Locked = true;
        TimeStampLbl: Label '%1T%2', Locked = true;
        IdPoruke: Text;
        Document: XmlDocument;
        BillNoSection: XmlElement;
        Body: XmlElement;
        Content: XmlElement;
        Header1: XmlElement;
        VATElements: XmlElement;
        VATSection: XmlElement;
        XmlWriteOpts: XmlWriteOptions;
        HasArchVoucherEntry: Boolean;
    begin
        CompanyInformation.Get();
        CROFiscalizationSetup.Get();

        Document := XmlDocument.Create('', '');

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
        Content.Add(CreateXmlElement('OznSlijed', 'N'));

        BillNoSection := XmlElement.Create('BrRac');
        BillNoSection.Add(CreateXmlElement('BrOznRac', CROPOSAuditLogAuxInfo."Bill No."));
        BillNoSection.Add(CreateXmlElement('OznPosPr', CROPOSAuditLogAuxInfo."POS Store Code"));
        BillNoSection.Add(CreateXmlElement('OznNapUr', CROPOSAuditLogAuxInfo."POS Unit No."));

        Content.Add(BillNoSection);

        NpRvArchVoucherEntry.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::Payment);
        NpRvArchVoucherEntry.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        HasArchVoucherEntry := NpRvArchVoucherEntry.FindFirst();

        VATSection := XmlElement.Create('Pdv');

        if POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.") then begin
            POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSEntryTaxLine.FindSet() then
                repeat
                    VATElements := XmlElement.Create('Porez');
                    VATElements.Add(CreateXmlElement('Stopa', CROAuditMgt.FormatDecimal(POSEntryTaxLine."Tax %")));
                    VATElements.Add(CreateXmlElement('Osnovica', CROAuditMgt.FormatDecimal(POSEntryTaxLine."Tax Base Amount")));
                    VATElements.Add(CreateXmlElement('Iznos', CROAuditMgt.FormatDecimal(POSEntryTaxLine."Tax Amount")));
                    VATSection.Add(VATElements);
                until POSEntryTaxLine.Next() = 0;

            if HasArchVoucherEntry then
                AddVoucherVATSection(NpRvArchVoucherEntry, VATElements, VATSection);

            Content.Add(VATSection);

            Content.Add(CreateXmlElement('IznosUkupno', CROAuditMgt.FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount")));

            case CROPOSAuditLogAuxInfo."CRO Payment Method" of
                "NPR CRO POS Payment Method"::Card:
                    Content.Add(CreateXmlElement('NacinPlac', 'K'));
                "NPR CRO POS Payment Method"::Cash:
                    Content.Add(CreateXmlElement('NacinPlac', 'G'));
                "NPR CRO POS Payment Method"::Check:
                    Content.Add(CreateXmlElement('NacinPlac', 'C'));
                "NPR CRO POS Payment Method"::Other:
                    Content.Add(CreateXmlElement('NacinPlac', 'O'));
            end;

            SalespersonPurch.Get(POSEntry."Salesperson Code");
            CROAuxSalespersonPurch.Get(SalespersonPurch.SystemId);

            Content.Add(CreateXmlElement('OibOper', Format(CROAuxSalespersonPurch."NPR CRO Salesperson OIB")));
            Content.Add(CreateXmlElement('ZastKod', CROPOSAuditLogAuxInfo."ZKI Code"));

            if Subsequent then
                Content.Add(CreateXmlElement('NakDost', 'true'))
            else
                Content.Add(CreateXmlElement('NakDost', 'false'));

            if CROPOSAuditLogAuxInfo."Paragon Number" <> '' then
                Content.Add(CreateXmlElement('ParagonBrRac', CROPOSAuditLogAuxInfo."Paragon Number"));
        end;

        Body.Add(Content);

        XmlWriteOpts.PreserveWhitespace(true);

        Document.Add(Body, XmlWriteOpts);

        SignBillAndSendToTA(CROPOSAuditLogAuxInfo, Document);
    end;

    #endregion

    local procedure AddVoucherVATSection(NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry"; var VATElements: XmlElement; var VATSection: XmlElement)
    var
        NpRvArchVoucherEntry2: Record "NPR NpRv Arch. Voucher Entry";
        POSEntrySalesLines: Record "NPR POS Entry Sales Line";
        SalesLinesType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
    begin
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
            VATElements := XmlElement.Create('Porez');
            VATElements.Add(CreateXmlElement('Stopa', CROAuditMgt.FormatDecimal(POSEntrySalesLines."VAT %")));
            VATElements.Add(CreateXmlElement('Osnovica', CROAuditMgt.FormatDecimal(-POSEntrySalesLines."Amount Excl. VAT")));
            VATElements.Add(CreateXmlElement('Iznos', CROAuditMgt.FormatDecimal(-(POSEntrySalesLines."Amount Incl. VAT" - POSEntrySalesLines."Amount Excl. VAT"))));
            VATSection.Add(VATElements);
        until POSEntrySalesLines.Next() = 0;
    end;

    #region CRO Tax Communication - HTTP Request
    local procedure SignBillAndSendToTA(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; var ReceiptDocument: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        VerificationURLFormatLbl: Label 'https://porezna.gov.hr/rn?jir=%1&datv=%2_%3&izn=%4', Locked = true;
        OStream: OutStream;
        BaseValue: Text;
        ResponseText: Text;
        SignedValue: Text;
    begin
        FillBaseValue(ReceiptDocument, BaseValue);

        if not CROAuditMgt.SignXML(CROPOSAuditLogAuxInfo, BaseValue, SignedValue) then
            exit;
        if not SendToTA(CROPOSAuditLogAuxInfo, SignedValue, ResponseText) then
            exit;

        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(SignedValue);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        CROPOSAuditLogAuxInfo."Receipt Content".ImportStream(IStream, CROPOSAuditLogAuxInfo.FieldCaption("Receipt Content"));
        CROPOSAuditLogAuxInfo."Receipt Fiscalized" := true;
        CROPOSAuditLogAuxInfo."JIR Code" := CopyStr(GetJIRCodeFromResponse(ResponseText), 1, MaxStrLen(CROPOSAuditLogAuxInfo."JIR Code"));
        CROPOSAuditLogAuxInfo."Verification URL" := StrSubstNo(VerificationURLFormatLbl, CROPOSAuditLogAuxInfo."JIR Code", Format(CROPOSAuditLogAuxInfo."Entry Date", 8, '<Year4><Month,2><Day,2>'), Format(CROPOSAuditLogAuxInfo."Log Timestamp", 4, '<Hours24,2><Minutes,2>'), DelChr(CROAuditMgt.FormatDecimal(CROPOSAuditLogAuxInfo."Total Amount"), '=', '.'));
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure SendToTA(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; XMLMessageText: Text; var ResponseText: Text): Boolean
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        Url: Text;
        IsHandled: Boolean;
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