codeunit 6151196 "NPR NpCs Workflow Mgt."
{
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    begin
        RunWorkflow(Rec);
    end;

    var
        RunWorkflowStep: Codeunit "NPR NpCs Run Workflow Step";
        WorkflowFunctionType: Option " ","Send Order","Order Status","Post Processing","Send Notification to Store","Send Notification to Customer";

    [IntegrationEvent(false, false)]
    procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
    end;

    procedure ScheduleRunWorkflow(var NpCsDocument: Record "NPR NpCs Document")
    begin
        TASKSCHEDULER.CreateTask(CurrCodeunitId(), 0, true, CompanyName, CurrentDateTime, NpCsDocument.RecordId);
    end;

    procedure ScheduleRunWorkflowDelay(var NpCsDocument: Record "NPR NpCs Document"; DelayMS: Integer)
    begin
        TASKSCHEDULER.CREATETASK(CurrCodeunitId(), 0, TRUE, COMPANYNAME, CURRENTDATETIME + DelayMS, NpCsDocument.RECORDID);
    end;

    local procedure RunWorkflow(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsArchCollectMgt: Codeunit "NPR NpCs Arch. Collect Mgt.";
    begin
        if NpCsDocument.Type = NpCsDocument.Type::"Collect in Store" then begin
            if IsReadyForArchivation(NpCsDocument) then begin
                RunCallback(NpCsDocument);
                NpCsArchCollectMgt.ArchiveCollectDocument(NpCsDocument);
            end;
            exit;
        end;

        if not NpCsDocument.Find() then
            exit;
        case NpCsDocument."Next Workflow Step" of
            NpCsDocument."Next Workflow Step"::"Send Order":
                RunWorkflowSendOrder(NpCsDocument);
            NpCsDocument."Next Workflow Step"::"Order Status":
                RunWorkflowOrderStatus(NpCsDocument);
            NpCsDocument."Next Workflow Step"::"Post Processing":
                RunWorkflowPostProcessing(NpCsDocument);
        end;
    end;

    procedure RunWorkflowSendOrder(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Send Order");
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
        if NpCsDocument."Next Workflow Step" = NpCsDocument."Next Workflow Step"::"Order Status" then
            SendNotificationToStore(NpCsDocument);
    end;

    procedure RunWorkflowOrderStatus(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        PrevStatus: Integer;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        PrevStatus := NpCsDocument."Processing Status";
        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Order Status");
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
        if PrevStatus <> NpCsDocument."Processing Status" then begin
            SendNotificationToCustomer(NpCsDocument);
            SendNotificationToStore(NpCsDocument);
        end;
    end;

    procedure RunWorkflowPostProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        LastErrorText: Text;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Post Processing");
        if not RunWorkflowStep.Run(NpCsDocument) then begin
            LastErrorText := GetLastErrorText();
            if LastErrorText <> '' then
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, LastErrorText);
        end;

        Commit();
    end;

    [IntegrationEvent(TRUE, false)]
    procedure SendOrder(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    begin
    end;

    procedure SendNotificationToStore(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
    begin
        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Send Notification to Store");
        RunWorkflowStep.SetNotificationType(1);  //Email
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Send Notification to Store");
        RunWorkflowStep.SetNotificationType(2);  //Sms
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
    end;

    procedure SendNotificationToCustomer(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
    begin
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
                if NpCsDocument."Send Notification from Store" then
                    exit;
            NpCsDocument.Type::"Collect in Store":
                if not NpCsDocument."Send Notification from Store" then
                    exit;
        end;

        NpCsDocument.CalcFields("Order Status Module");
        NpCsWorkflowModule.Init();
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := NpCsDocument."Order Status Module";
        if NpCsWorkflowModule.Find() then;

        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Send Notification to Customer");
        RunWorkflowStep.SetNotificationType(1);  //Email
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
        ClearLastError();
        clear(RunWorkflowStep);
        RunWorkflowStep.SetWorkflowFunctionType(WorkflowFunctionType::"Send Notification to Customer");
        RunWorkflowStep.SetNotificationType(2);  //Sms
        if not RunWorkflowStep.Run(NpCsDocument) then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, '', true, GetLastErrorText());

        Commit();
    end;

    [IntegrationEvent(TRUE, false)]
    procedure UpdateOrderStatus(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure PerformPostProcessing(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    begin
    end;

    procedure RunCallback(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsStore: Record "NPR NpCs Store";
        NpCsArchDocument: Record "NPR NpCs Arch. Document";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        Element: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        InStr: InStream;
        ExceptionMessage: Text;
        ReqBody: Text;
        ContentType: Text;
        Method: Text;
    begin
        if not NpCsStore.Get(NpCsDocument."From Store Code") then
            exit;
        if NpCsStore."Service Url" = '' then
            exit;

        if not NpCsDocument.Find() then begin
            NpCsArchDocument.SetRange(Type, NpCsDocument.Type);
            case NpCsDocument.Type of
                NpCsDocument.Type::"Send to Store":
                    begin
                        NpCsArchDocument.SetRange("Document Type", NpCsDocument."From Document Type");
                        NpCsArchDocument.SetRange("Document No.", NpCsDocument."From Document No.");
                    end;
                NpCsDocument.Type::"Collect in Store":
                    begin
                        NpCsArchDocument.SetRange("From Document Type", NpCsDocument."From Document Type");
                        NpCsArchDocument.SetRange("From Document No.", NpCsDocument."From Document No.");
                    end;
            end;
            NpCsArchDocument.SetRange("From Store Code", NpCsDocument."From Store Code");
            if not NpCsArchDocument.FindLast() then
                exit;
            if not NpCsArchDocument."Callback Data".HasValue() then
                exit;
            NpCsArchDocument.CalcFields("Callback Data");
            NpCsDocument."Callback Data" := NpCsArchDocument."Callback Data";
        end else begin
            if not NpCsDocument."Callback Data".HasValue() then
                exit;
            NpCsDocument.CalcFields("Callback Data");
        end;
        NpCsDocument."Callback Data".CreateInStream(InStr, TEXTENCODING::UTF8);
        XmlDocument.ReadFrom(InStr, Document);
        Document.GetRoot(Element);

        ReqBody := NpXmlDomMgt.GetElementText(Element, '//request_body', 0, true);
        ContentType := NpXmlDomMgt.GetElementText(Element, '//content_type', 0, true);
        Method := NpXmlDomMgt.GetElementText(Element, '//method', 0, true);

        Content.WriteFrom(ReqBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', ContentType);

        Document.SelectNodes('//headers/header', NodeList);
        foreach Node in NodeList do begin
            AttributeCollection := Node.AsXmlElement().Attributes();
            AttributeCollection.Get('name', Attribute);
            ContentHeaders.Add(Attribute.Value, Node.AsXmlElement().InnerText);
        end;

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpCsStore.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content(Content);
        RequestMessage.Method(Method);
        RequestMessage.SetRequestUri(NpCsStore."Service Url");
        Client.Send(RequestMessage, Response);

        if not Response.IsSuccessStatusCode then begin
            ExceptionMessage := Response.ReasonPhrase;
            if XmlDocument.ReadFrom(ExceptionMessage, Document) then
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ExceptionMessage := Node.AsXmlElement().InnerText();

            Error(CopyStr(ExceptionMessage, 1, 1020));
        end;
    end;

    procedure InsertLogEntry(NpCsDocument: Record "NPR NpCs Document"; NpCsWorkflowModule: Record "NPR NpCs Workflow Module"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        OutStr: OutStream;
    begin
        NpCsDocumentLogEntry.Init();
        NpCsDocumentLogEntry."Entry No." := 0;
        NpCsDocumentLogEntry."Log Date" := CurrentDateTime;
        NpCsDocumentLogEntry."Document Entry No." := NpCsDocument."Entry No.";
        NpCsDocumentLogEntry."Workflow Type" := NpCsWorkflowModule.Type;
        NpCsDocumentLogEntry."Workflow Module" := NpCsWorkflowModule.Code;
        NpCsDocumentLogEntry."Log Message" := CopyStr(LogMessage, 1, MaxStrLen(NpCsDocumentLogEntry."Log Message"));
        NpCsDocumentLogEntry."Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(ErrorMessage);
        NpCsDocumentLogEntry."Error Entry" := ErrorEntry;
        NpCsDocumentLogEntry.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Workflow Mgt.");
    end;

    local procedure IsReadyForArchivation(NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        ReadyForArchivation: Boolean;
        Handled: Boolean;
    begin
        if not NpCsDocument.FindFirst() then
            exit(false);

        OnIsReadyForArchivation(NpCsDocument, ReadyForArchivation, Handled);
        if Handled then
            exit(ReadyForArchivation);

        case NpCsDocument."Delivery Status" of
            NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired:
                exit(NpCsDocument."Archive on Delivery");
        end;

        case NpCsDocument."Processing Status" of
            NpCsDocument."Processing Status"::Rejected, NpCsDocument."Processing Status"::Expired:
                exit(NpCsDocument."Archive on Delivery");
        end;

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnIsComplete(NpCsDocument: Record "NPR NpCs Document"; var IsComplete: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsReadyForArchivation(NpCsDocument: Record "NPR NpCs Document"; var IsReadyForArchivation: Boolean; var IsHandled: Boolean)
    begin
    end;
}
