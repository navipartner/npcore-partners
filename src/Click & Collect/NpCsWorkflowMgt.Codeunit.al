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

    //--- Init ---

    [IntegrationEvent(false, false)]
    procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
    end;

    local procedure "--- Run"()
    begin
    end;

    procedure ScheduleRunWorkflow(var NpCsDocument: Record "NPR NpCs Document")
    var
        NewSessionId: Integer;
    begin
        TASKSCHEDULER.CreateTask(CurrCodeunitId(), 0, true, CompanyName, CurrentDateTime, NpCsDocument.RecordId);
        SESSION.StartSession(NewSessionId, CurrCodeunitId(), CompanyName, NpCsDocument);
    end;

    procedure ScheduleRunWorkflowDelay(var NpCsDocument: Record "NPR NpCs Document"; DelayMS: Integer)
    var
        NewSessionId: Integer;
    begin
        //-NPR10.00.00.NPR5.54 [390590]
        //TASKSCHEDULER.CREATETASK(CurrCodeunitId(),0,TRUE,COMPANYNAME,CURRENTDATETIME + DelayMS,NpCsDocument.RECORDID);
        //+NPR10.00.00.NPR5.54 [390590]
    end;

    local procedure RunWorkflow(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsArchCollectMgt: Codeunit "NPR NpCs Arch. Collect Mgt.";
        PrevWorkflowStep: Integer;
    begin
        if NpCsDocument.Type = NpCsDocument.Type::"Collect in Store" then begin
            if IsReadyForArchivation(NpCsDocument) then
                NpCsArchCollectMgt.ArchiveCollectDocument(NpCsDocument);
            RunCallback(NpCsDocument);
            exit;
        end;

        if not NpCsDocument.Find then
            exit;
        PrevWorkflowStep := NpCsDocument."Next Workflow Step";
        case NpCsDocument."Next Workflow Step" of
            NpCsDocument."Next Workflow Step"::"Send Order":
                begin
                    RunWorkflowSendOrder(NpCsDocument);
                end;
            NpCsDocument."Next Workflow Step"::"Order Status":
                begin
                    RunWorkflowOrderStatus(NpCsDocument);
                end;
            NpCsDocument."Next Workflow Step"::"Post Processing":
                begin
                    RunWorkflowPostProcessing(NpCsDocument);
                end;
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
        LogMessage: Text;
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
        LogMessage: Text;
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
        LastErrorText: Text;
    begin
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
                begin
                    if NpCsDocument."Send Notification from Store" then
                        exit;
                end;
            NpCsDocument.Type::"Collect in Store":
                begin
                    if not NpCsDocument."Send Notification from Store" then
                        exit;
                end;
        end;

        NpCsDocument.CalcFields("Order Status Module");
        NpCsWorkflowModule.Init;
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := NpCsDocument."Order Status Module";
        if NpCsWorkflowModule.Find then;

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
        Credential: DotNet NPRNetNetworkCredential;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        WebException: DotNet NPRNetWebException;
        InStr: InStream;
        ExceptionMessage: Text;
        ReqBody: Text;
    begin
        if not NpCsStore.Get(NpCsDocument."From Store Code") then
            exit;
        if NpCsStore."Service Url" = '' then
            exit;

        if not NpCsDocument.Find then begin
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
            if not NpCsArchDocument.FindLast then
                exit;
            if not NpCsArchDocument."Callback Data".HasValue then
                exit;
            NpCsArchDocument.CalcFields("Callback Data");
            NpCsDocument."Callback Data" := NpCsArchDocument."Callback Data";
        end;
        if not NpCsDocument."Callback Data".HasValue then
            exit;
        NpCsDocument.CalcFields("Callback Data");
        NpCsDocument."Callback Data".CreateInStream(InStr, TEXTENCODING::UTF8);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        XmlElement := XmlDoc.DocumentElement;

        HttpWebRequest := HttpWebRequest.CreateHttp(NpCsStore."Service Url");
        HttpWebRequest.ContentType := NpXmlDomMgt.GetElementText(XmlElement, 'content_type', 0, true);
        foreach XmlElement2 in XmlElement.SelectNodes('headers/header') do
            HttpWebRequest.Headers.Add(XmlElement2.GetAttribute('name'), XmlElement2.InnerText);

        HttpWebRequest.Method := NpXmlDomMgt.GetElementText(XmlElement, 'method', 0, true);
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username", NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);

        ReqBody := NpXmlDomMgt.GetElementText(XmlElement, 'request_body', 0, true);

        if not NpXmlDomMgt.SendWebRequestText(ReqBody, HttpWebRequest, HttpWebResponse, WebException) then begin
            ExceptionMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            if NpXmlDomMgt.TryLoadXml(ExceptionMessage, XmlDoc) then begin
                if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement, '//faultstring', XmlElement) then
                    ExceptionMessage := XmlElement.InnerText;
            end;

            Error(CopyStr(ExceptionMessage, 1, 1020));
        end;
    end;

    procedure InsertLogEntry(NpCsDocument: Record "NPR NpCs Document"; NpCsWorkflowModule: Record "NPR NpCs Workflow Module"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        OutStr: OutStream;
    begin
        NpCsDocumentLogEntry.Init;
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

    //--- Aux ---

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Workflow Mgt.");
    end;

    local procedure IsReadyForArchivation(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if not NpCsDocument.Find then
            exit(false);

        case NpCsDocument."Delivery Status" of
            NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired:
                begin
                    exit(NpCsDocument."Archive on Delivery");
                end;
        end;

        case NpCsDocument."Processing Status" of
            NpCsDocument."Processing Status"::Rejected, NpCsDocument."Processing Status"::Expired:
                begin
                    exit(NpCsDocument."Archive on Delivery");
                end;
        end;

        exit(false);
    end;
}