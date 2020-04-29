codeunit 6151201 "NpCs Lookup Sales Document"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        NpCsDocument: Record "NpCs Document";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
    begin
        if not Rec.LoadXmlDoc(XmlDoc) then
          Error(Text000);

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        if IsNull(XmlDoc.DocumentElement) then
          Error(Text000);

        XmlElement := XmlDoc.DocumentElement.SelectSingleNode('sales_document');
        if FindNpCsDocuments(XmlElement,NpCsDocument) then begin
          PAGE.Run(PAGE::"NpCs Collect Store Orders",NpCsDocument);
          exit;
        end;

        MarkOrderMappings(XmlElement,NpCsDocumentMapping);
        NpCsDocumentMapping.MarkedOnly(true);
        if NpCsDocumentMapping.FindFirst then begin
          PAGE.Run(0,NpCsDocumentMapping);
          exit;
        end;

        Error('');
    end;

    var
        Text000: Label 'Invalid Xml data';
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";

    local procedure MarkOrderMappings(XmlElement: DotNet npNetXmlElement;var NpCsDocumentMapping: Record "NpCs Document Mapping")
    var
        XmlElement2: DotNet npNetXmlElement;
        FromStore: Code[20];
        FromNo: Code[20];
    begin
        if IsNull(XmlElement) then
          exit;

        FromStore := GetFromStoreCode(XmlElement);

        XmlElement2 := XmlElement.SelectSingleNode('sell_to_customer');
        FromNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement2,'customer_no',true),1,MaxStrLen(NpCsDocumentMapping."From No."));
        MarkOrderMapping(NpCsDocumentMapping.Type::"Customer No.",FromStore,FromNo,NpCsDocumentMapping);

        foreach XmlElement2 in XmlElement.SelectNodes('sales_lines/sales_line [type=2 and cross_reference_no!=""]') do begin
          FromNo := NpXmlDomMgt.GetXmlText(XmlElement2,'cross_reference_no',MaxStrLen(NpCsDocumentMapping."From No."),true);
          MarkOrderMapping(NpCsDocumentMapping.Type::"Item Cross Reference No.",FromStore,FromNo,NpCsDocumentMapping);
        end;
    end;

    local procedure MarkOrderMapping(Type: Integer;FromStore: Code[20];FromNo: Code[20];var NpCsDocumentMapping: Record "NpCs Document Mapping")
    begin
        if FromStore = '' then
          exit;
        if FromNo = '' then
          exit;

        if NpCsDocumentMapping.Get(Type,FromStore,FromNo) then
          NpCsDocumentMapping.Mark(true);
    end;

    local procedure FindNpCsDocuments(XmlElement: DotNet npNetXmlElement;var NpCsDocument: Record "NpCs Document"): Boolean
    var
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
    begin
        DocType := NpXmlDomMgt.GetAttributeInt(XmlElement,'','document_type',true);
        DocNo := UpperCase(NpXmlDomMgt.GetAttributeText(XmlElement,'','document_no',MaxStrLen(NpCsDocument."From Document No."),true));
        if DocNo = '' then
          exit(false);

        StoreCode := GetFromStoreCode(XmlElement);
        if StoreCode = '' then
          exit(false);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type,NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("From Document Type",DocType);
        NpCsDocument.SetRange("From Document No.",DocNo);
        NpCsDocument.SetRange("From Store Code",StoreCode);
        exit(NpCsDocument.FindFirst);
    end;

    local procedure GetFromStoreCode(XmlElement: DotNet npNetXmlElement) StoreCode: Code[20]
    begin
        StoreCode := UpperCase(NpXmlDomMgt.GetAttributeText(XmlElement,'/*/sales_document/from_store','store_code',MaxStrLen(StoreCode),true));
        exit(StoreCode);
    end;
}

