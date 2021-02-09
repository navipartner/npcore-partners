codeunit 6151201 "NPR NpCs Lookup Sales Document"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        Document: XmlDocument;
        Node: XmlNode;
    begin
        if not Rec.LoadXmlDoc(Document) then
            Error(Text000);

        if not Document.SelectSingleNode('//sales_document', Node) then
            Error(Text000);

        if FindNpCsDocuments(Node.AsXmlElement(), NpCsDocument) then begin
            PAGE.Run(PAGE::"NPR NpCs Coll. Store Orders", NpCsDocument);
            exit;
        end;

        MarkOrderMappings(Node.AsXmlElement(), NpCsDocumentMapping);
        NpCsDocumentMapping.MarkedOnly(true);
        if NpCsDocumentMapping.FindFirst then begin
            PAGE.Run(0, NpCsDocumentMapping);
            exit;
        end;

        Error('');
    end;

    var
        Text000: Label 'Invalid Xml data';
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    local procedure MarkOrderMappings(Element: XmlElement; var NpCsDocumentMapping: Record "NPR NpCs Document Mapping")
    var
        Element2: XmlElement;
        Node: XmlNode;
        NodeList: XmlNodeList;
        FromStore: Code[20];
        FromNo: Code[50];
    begin
        if Element.IsEmpty() then
            exit;

        FromStore := GetFromStoreCode(Element);

        Element.SelectSingleNode('sell_to_customer', Node);
        Element2 := Node.AsXmlElement();
        FromNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element2, 'customer_no', true), 1, MaxStrLen(NpCsDocumentMapping."From No."));
        MarkOrderMapping(NpCsDocumentMapping.Type::"Customer No.", FromStore, FromNo, NpCsDocumentMapping);

        Element.SelectNodes('sales_lines/sales_line [type=2 and cross_reference_no!=""]', NodeList);
        foreach Node in NodeList do begin
            FromNo := NpXmlDomMgt.GetXmlText(Element2, 'cross_reference_no', MaxStrLen(NpCsDocumentMapping."From No."), true);
            MarkOrderMapping(NpCsDocumentMapping.Type::"Item Cross Reference No.", FromStore, FromNo, NpCsDocumentMapping);
        end;
    end;

    local procedure MarkOrderMapping(Type: Integer; FromStore: Code[20]; FromNo: Code[50]; var NpCsDocumentMapping: Record "NPR NpCs Document Mapping")
    begin
        if FromStore = '' then
            exit;
        if FromNo = '' then
            exit;

        if NpCsDocumentMapping.Get(Type, FromStore, FromNo) then
            NpCsDocumentMapping.Mark(true);
    end;

    local procedure FindNpCsDocuments(Element: XmlElement; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
    begin
        DocType := NpXmlDomMgt.GetAttributeInt(Element, '', 'document_type', true);
        DocNo := UpperCase(NpXmlDomMgt.GetAttributeText(Element, '', 'document_no', MaxStrLen(NpCsDocument."From Document No."), true));
        if DocNo = '' then
            exit(false);

        StoreCode := GetFromStoreCode(Element);
        if StoreCode = '' then
            exit(false);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("From Document Type", DocType);
        NpCsDocument.SetRange("From Document No.", DocNo);
        NpCsDocument.SetRange("From Store Code", StoreCode);
        exit(NpCsDocument.FindFirst);
    end;

    local procedure GetFromStoreCode(Element: XmlElement) StoreCode: Code[20]
    begin
        StoreCode := UpperCase(NpXmlDomMgt.GetAttributeText(Element, '/*/sales_document/from_store', 'store_code', MaxStrLen(StoreCode), true));
        exit(StoreCode);
    end;
}

