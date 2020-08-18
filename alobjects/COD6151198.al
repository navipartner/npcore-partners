codeunit 6151198 "NpCs Update Order Status"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.55/MHA /20200701  CASE 411513 Removed unused references to SalesHeader and Customer in InitReqBody()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Collect in Store Document is first Processed by Store and then Delivered';
        Text001: Label 'Update Order Status';
        Text002: Label 'Collect Document has been deleted in Store';

    local procedure "--- Init"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151196, 'OnInitWorkflowModules', '', true, true)]
    local procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NpCs Workflow Module")
    begin
        if not NpCsWorkflowModule.WritePermission then
          exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status",WorkflowCode()) then
          exit;

        NpCsWorkflowModule.Init;
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := WorkflowCode();
        NpCsWorkflowModule.Description := CopyStr(Text000,1,MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CurrCodeunitId();
        NpCsWorkflowModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151196, 'UpdateOrderStatus', '', true, true)]
    local procedure UpdateOrderStatus(var NpCsDocument: Record "NpCs Document";var LogMessage: Text)
    var
        NpCsStore: Record "NpCs Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ExceptionMessage: Text;
        Response: Text;
        XPath: Text;
        Status: Integer;
        PrevRec: Text;
    begin
        if not (NpCsDocument."Order Status Module" in ['',WorkflowCode()]) then
          exit;

        LogMessage := '';

        InitReqBody(NpCsDocument,XmlDoc);

        NpCsStore.Get(NpCsDocument."To Store Code");
        HttpWebRequest := HttpWebRequest.CreateHttp(NpCsStore."Service Url");
        HttpWebRequest.ContentType := 'text/xml;charset=UTF-8';
        HttpWebRequest.Headers.Add('SOAPAction','GetCollectDocuments');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ExceptionMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ExceptionMessage,XmlDoc) then begin
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ExceptionMessage := XmlElement.InnerText;
          end;

          LogMessage := Text001;
          Error(CopyStr(ExceptionMessage,1,1020));
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not NpXmlDomMgt.TryLoadXml(Response,XmlDoc) then begin
          LogMessage := Text001;
          Error(Response);
        end;

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XPath := 'Body/GetCollectDocuments_Result/collect_documents/collect_document';
        XPath += '[@type="' + Format(NpCsDocument.Type::"Collect in Store",0,2) + '" ';
        XPath += 'and @from_document_type="' + Format(NpCsDocument."Document Type",0,2) + '" ';
        XPath += 'and @from_document_no="' + NpCsDocument."Document No." + '"]';
        if not NpXmlDomMgt.FindElement(XmlDoc.DocumentElement,XPath,false,XmlElement) then
          Error(Text002);

        NpCsDocument.Find;
        PrevRec := Format(NpCsDocument);

        Status := NpXmlDomMgt.GetElementInt(XmlElement,'processing_status',true);
        if NpCsDocument."Processing Status" <> Status then begin
          NpCsDocument."Processing Status" := Status;
          NpCsDocument."Processing updated at" := NpXmlDomMgt.GetElementDT(XmlElement,'processing_updated_at',true);
          NpCsDocument."Processing updated by" := NpXmlDomMgt.GetElementText(XmlElement,'processing_updated_by',MaxStrLen(NpCsDocument."Processing updated by"),true);
        end;

        Status := NpXmlDomMgt.GetElementInt(XmlElement,'delivery_status',true);
        if NpCsDocument."Delivery Status" <> Status then begin
          NpCsDocument."Delivery Status" := Status;
          NpCsDocument."Delivery updated at" := NpXmlDomMgt.GetElementDT(XmlElement,'delivery_updated_at',true);
          NpCsDocument."Delivery updated by" := NpXmlDomMgt.GetElementText(XmlElement,'delivery_updated_by',MaxStrLen(NpCsDocument."Delivery updated by"),true);
        end;

        if OrderProcessingComplete(NpCsDocument) then
          NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";

        if PrevRec <> Format(NpCsDocument) then
          NpCsDocument.Modify(true);

        foreach XmlElement2 in XmlElement.SelectNodes('log_entries/log_entry') do
          InsertLogEntry(NpCsStore,NpCsDocument,XmlElement2);
    end;

    local procedure InsertLogEntry(NpCsStore: Record "NpCs Store";NpCsDocument: Record "NpCs Document";XmlElement: DotNet npNetXmlElement)
    var
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        EntryNo: BigInteger;
        OutStr: OutStream;
    begin
        EntryNo := NpXmlDomMgt.GetAttributeBigInt(XmlElement,'','entry_no',false);
        if EntryNo <= 0 then
          exit;

        NpCsDocumentLogEntry.SetRange("Document Entry No.",NpCsDocument."Entry No.");
        NpCsDocumentLogEntry.SetRange("Store Log Entry No.",EntryNo);
        NpCsDocumentLogEntry.SetRange("Store Code",NpCsStore.Code);
        if NpCsDocumentLogEntry.FindFirst then
          exit;

        NpCsDocumentLogEntry.Init;
        NpCsDocumentLogEntry."Entry No." := 0;
        NpCsDocumentLogEntry."Document Entry No." := NpCsDocument."Entry No.";
        NpCsDocumentLogEntry."Store Log Entry No." := EntryNo;
        NpCsDocumentLogEntry."Store Code" := NpCsStore.Code;
        NpCsDocumentLogEntry."Log Date" := NpXmlDomMgt.GetElementDT(XmlElement,'log_date',true);
        NpCsDocumentLogEntry."Workflow Type" := NpXmlDomMgt.GetElementInt(XmlElement,'workflow_type',true);
        NpCsDocumentLogEntry."Workflow Module" := NpXmlDomMgt.GetElementCode(XmlElement,'workflow_module',MaxStrLen(NpCsDocumentLogEntry."Workflow Module"),true);
        NpCsDocumentLogEntry."Log Message" := NpXmlDomMgt.GetElementText(XmlElement,'log_message',MaxStrLen(NpCsDocumentLogEntry."Log Message"),true);
        NpCsDocumentLogEntry."Error Message".CreateOutStream(OutStr,TEXTENCODING::UTF8);
        OutStr.WriteText(NpXmlDomMgt.GetElementText(XmlElement,'error_message',0,true));
        NpCsDocumentLogEntry."Error Entry" := NpXmlDomMgt.GetElementBoolean(XmlElement,'error_entry',true);
        NpCsDocumentLogEntry."User ID" := NpXmlDomMgt.GetElementCode(XmlElement,'user_id',MaxStrLen(NpCsDocumentLogEntry."User ID"),true);
        NpCsDocumentLogEntry.Insert(true);
    end;

    local procedure InitReqBody(NpCsDocument: Record "NpCs Document";var XmlDoc: DotNet npNetXmlDocument)
    var
        NpCsStore: Record "NpCs Store";
        NpCsStoreLocal: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        ServiceName: Text;
        Content: Text;
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
                  ' type="' + Format(NpCsDocument.Type::"Collect in Store",0,2) + '"' +
                  ' from_document_type="' + Format(NpCsDocument."Document Type",0,2) + '"' +
                  ' from_document_no="' + NpCsDocument."Document No." + '"' +
                  ' from_store_code="' + NpCsDocument."From Store Code" + '">' +
                    '<reference_no>' + NpCsDocument."Reference No." + '</reference_no>' +
                  '</collect_document>' +
                '</collect_documents>' +
              '</GetCollectDocuments>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Content);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Update Order Status");
    end;

    local procedure OrderProcessingComplete(NpCsDocument: Record "NpCs Document"): Boolean
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

