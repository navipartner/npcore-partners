codeunit 6151198 "NPR NpCs Upd. Order Status"
{
    Access = Internal;
    var
        Text000: Label 'Collect in Store Document is first Processed by Store and then Delivered';
        Text001: Label 'Update Order Status';
        Text002: Label 'Collect Document has been deleted in Store';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpCs Workflow Mgt.", 'OnInitWorkflowModules', '', true, true)]
    local procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
        if not NpCsWorkflowModule.WritePermission then
            exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status", WorkflowCode()) then
            exit;

        NpCsWorkflowModule.Init();
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := WorkflowCode();
        NpCsWorkflowModule.Description := CopyStr(Text000, 1, MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CurrCodeunitId();
        NpCsWorkflowModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpCs Workflow Mgt.", 'UpdateOrderStatus', '', true, true)]
    local procedure UpdateOrderStatus(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    var
        NpCsStore: Record "NPR NpCs Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node2: XmlNode;
        Node: XmlNode;
        NodeList: XmlNodeList;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        ExceptionMessage: Text;
        ReqBody: Text;
        ResponseText: Text;
        XPath: Text;
        Status: Integer;
        PrevRec: Text;
    begin
        if not (NpCsDocument."Order Status Module" in ['', WorkflowCode()]) then
            exit;

        LogMessage := '';

        ReqBody := InitReqBody(NpCsDocument);

        NpCsStore.Get(NpCsDocument."To Store Code");

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpCsStore.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(NpCsStore."Service Url");

        RequestContent.WriteFrom(ReqBody);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        ContentHeader.Add('SOAPAction', 'GetCollectDocuments');
        ContentHeader := Client.DefaultRequestHeaders();

        RequestMessage.Content(RequestContent);
        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode then begin
            ExceptionMessage := ResponseMessage.ReasonPhrase;
            if XmlDocument.ReadFrom(ExceptionMessage, Document) then begin
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ExceptionMessage := Node.AsXmlElement().InnerText();
            end;

            LogMessage := Text001;
            Error(CopyStr(ExceptionMessage, 1, 1020));
        end;

        ResponseMessage.Content.ReadAs(ResponseText);
        ResponseText := XmlDomManagement.RemoveNamespaces(ResponseText);
        if not XmlDocument.ReadFrom(ResponseText, Document) then begin
            LogMessage := Text001;
            Error(ResponseText);
        end;

        XPath := '//Body/GetCollectDocuments_Result/collect_documents/collect_document';
        XPath += '[@type="' + Format(NpCsDocument.Type::"Collect in Store", 0, 2) + '" ';
        XPath += 'and @from_document_type="' + Format(NpCsDocument."Document Type", 0, 2) + '" ';
        XPath += 'and @from_document_no="' + NpCsDocument."Document No." + '"]';
        if not Document.SelectSingleNode(XPath, Node) then
            Error(Text002);

        NpCsDocument.Find();
        PrevRec := Format(NpCsDocument);

        Status := NpXmlDomMgt.GetElementInt(Node.AsXmlElement(), 'processing_status', true);
        if NpCsDocument."Processing Status" <> Status then begin
            NpCsDocument."Processing Status" := Status;
            NpCsDocument."Processing updated at" := NpXmlDomMgt.GetElementDT(Node.AsXmlElement(), 'processing_updated_at', true);
            NpCsDocument."Processing updated by" := CopyStr(NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'processing_updated_by', MaxStrLen(NpCsDocument."Processing updated by"), true), 1, MaxStrLen(NpCsDocument."Processing updated by"));
        end;

        Status := NpXmlDomMgt.GetElementInt(Node.AsXmlElement(), 'delivery_status', true);
        if NpCsDocument."Delivery Status" <> Status then begin
            NpCsDocument."Delivery Status" := Status;
            NpCsDocument."Delivery updated at" := NpXmlDomMgt.GetElementDT(Node.AsXmlElement(), 'delivery_updated_at', true);
            NpCsDocument."Delivery updated by" := CopyStr(NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'delivery_updated_by', MaxStrLen(NpCsDocument."Delivery updated by"), true), 1, MaxStrLen(NpCsDocument."Delivery updated by"));
        end;

        if OrderProcessingComplete(NpCsDocument) then
            NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";

        if PrevRec <> Format(NpCsDocument) then
            NpCsDocument.Modify(true);

        Node.AsXmlElement().SelectNodes('//log_entries/log_entry', NodeList);
        foreach Node2 in NodeList do
            InsertLogEntry(NpCsStore, NpCsDocument, Node2.AsXmlElement());
    end;

    local procedure InsertLogEntry(NpCsStore: Record "NPR NpCs Store"; NpCsDocument: Record "NPR NpCs Document"; Element: XmlElement)
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        EntryNo: BigInteger;
        OutStr: OutStream;
    begin
        EntryNo := NpXmlDomMgt.GetAttributeBigInt(Element, '', 'entry_no', false);
        if EntryNo <= 0 then
            exit;

        NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
        NpCsDocumentLogEntry.SetRange("Store Log Entry No.", EntryNo);
        NpCsDocumentLogEntry.SetRange("Store Code", NpCsStore.Code);
        if NpCsDocumentLogEntry.FindFirst() then
            exit;

        NpCsDocumentLogEntry.Init();
        NpCsDocumentLogEntry."Entry No." := 0;
        NpCsDocumentLogEntry."Document Entry No." := NpCsDocument."Entry No.";
        NpCsDocumentLogEntry."Store Log Entry No." := EntryNo;
        NpCsDocumentLogEntry."Store Code" := NpCsStore.Code;
        NpCsDocumentLogEntry."Log Date" := NpXmlDomMgt.GetElementDT(Element, 'log_date', true);
        NpCsDocumentLogEntry."Workflow Type" := NpXmlDomMgt.GetElementInt(Element, 'workflow_type', true);
        NpCsDocumentLogEntry."Workflow Module" := CopyStr(NpXmlDomMgt.GetElementCode(Element, 'workflow_module', MaxStrLen(NpCsDocumentLogEntry."Workflow Module"), true), 1, MaxStrLen(NpCsDocumentLogEntry."Workflow Module"));
        NpCsDocumentLogEntry."Log Message" := CopyStr(NpXmlDomMgt.GetElementText(Element, 'log_message', MaxStrLen(NpCsDocumentLogEntry."Log Message"), true), 1, MaxStrLen(NpCsDocumentLogEntry."Log Message"));
        NpCsDocumentLogEntry."Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(NpXmlDomMgt.GetElementText(Element, 'error_message', 0, true));
        NpCsDocumentLogEntry."Error Entry" := NpXmlDomMgt.GetElementBoolean(Element, 'error_entry', true);
        NpCsDocumentLogEntry."User ID" := CopyStr(NpXmlDomMgt.GetElementCode(Element, 'user_id', MaxStrLen(NpCsDocumentLogEntry."User ID"), true), 1, MaxStrLen(NpCsDocumentLogEntry."User ID"));
        NpCsDocumentLogEntry.Insert(true);
    end;

    local procedure InitReqBody(NpCsDocument: Record "NPR NpCs Document") Content: Text
    var
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreLocal: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        ServiceName: Text;
    begin
        NpCsStore.Get(NpCsDocument."To Store Code");
        ServiceName := NpCsStore.GetServiceName();
        NpCsWorkflow.Get(NpCsDocument."Workflow Code");
        NpCsStoreLocal.Get(NpCsDocument."From Store Code");

        Content :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Body>' +
              '<GetCollectDocuments xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                '<collect_documents>' +
                  '<collect_document xmlns="urn:microsoft-dynamics-nav/xmlports/collect_document"' +
                  ' type="' + Format(NpCsDocument.Type::"Collect in Store", 0, 2) + '"' +
                  ' from_document_type="' + Format(NpCsDocument."Document Type", 0, 2) + '"' +
                  ' from_document_no="' + Escape(NpCsDocument."Document No.") + '"' +
                  ' from_store_code="' + Escape(NpCsDocument."From Store Code") + '">' +
                    '<reference_no>' + Escape(NpCsDocument."Reference No.") + '</reference_no>' +
                  '</collect_document>' +
                '</collect_documents>' +
              '</GetCollectDocuments>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';
    end;

    local procedure Escape(StringValue: Text): Text
    begin
        StringValue := StringValue.Replace('&', '&amp;');
        StringValue := StringValue.Replace('<', '&lt;');
        StringValue := StringValue.Replace('>', '&gt;');
        StringValue := StringValue.Replace('"', '&quot;');
        StringValue := StringValue.Replace('''', '&apos;');
        exit(StringValue);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Upd. Order Status");
    end;

    local procedure OrderProcessingComplete(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if NpCsDocument."Processing Status" = NpCsDocument."Processing Status"::Rejected then
            exit(true);
        if NpCsDocument."Processing Status" = NpCsDocument."Processing Status"::Expired then
            exit(true);

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Delivered then
            exit(true);
        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Expired then
            exit(true);

        exit(false);
    end;

    procedure WorkflowCode(): Code[20]
    begin
        exit('ORDER_STATUS');
    end;
}

