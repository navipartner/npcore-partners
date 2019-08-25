codeunit 6151196 "NpCs Workflow Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 Bumped version list for update to TaskScheduler in ScheduleRunWorkflow() from NAV10.* and newer
    // #364557/MHA /20190822  CASE 364557 Removed Calcfields of "Sell-to Customer Name"

    TableNo = "NpCs Document";

    trigger OnRun()
    begin
        RunWorkflow(Rec);
    end;

    var
        Text001: Label 'E-mail Notification sent to Store %1 (%2)';
        Text002: Label 'Sms Notification sent to Store %1 (%2)';
        Text003: Label 'Sales Order %1 Released ';
        Text004: Label 'E-mail Notification (%3) sent to Customer %1 (%2)';
        Text005: Label 'Sms Notification (%3) sent to Customer %1 (%2)';

    local procedure "--- Init"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NpCs Workflow Module")
    begin
    end;

    local procedure "--- Run"()
    begin
    end;

    procedure ScheduleRunWorkflow(var NpCsDocument: Record "NpCs Document")
    var
        NewSessionId: Integer;
    begin
        //-NPR10.00.00.5.51 [344264]
        TASKSCHEDULER.CreateTask(CurrCodeunitId(),0,true,CompanyName,CurrentDateTime,NpCsDocument.RecordId);
        //+NPR10.00.00.5.51 [344264]
    end;

    local procedure RunWorkflow(var NpCsDocument: Record "NpCs Document")
    var
        PrevWorkflowStep: Integer;
    begin
        if NpCsDocument.Type = NpCsDocument.Type::"Collect in Store" then begin
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

    procedure RunWorkflowSendOrder(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpCsSendOrder: Codeunit "NpCs Send Order";
        LogMessage: Text;
        LastErrorText: Text;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
          exit;

        Commit;
        ClearLastError;
        asserterror begin
          NpCsDocument.Find;
          NpCsDocument.TestField(Type,NpCsDocument.Type::"Send to Store");
          NpCsDocument.CalcFields("Send Order Module");
          if NpCsDocument."Send Order Module" = '' then
            NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();
          NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order",NpCsDocument."Send Order Module");

          SalesHeader.Get(SalesHeader."Document Type"::Order,NpCsDocument."Document No.");
          if SalesHeader.Status <> SalesHeader.Status::Released then begin
            LogMessage := StrSubstNo(Text003,SalesHeader."No.");
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
            Commit;
          end;

          NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Order Status";
          NpCsDocument.Modify(true);
          SendOrder(NpCsDocument,LogMessage);
          Commit;

          if LogMessage <> '' then begin
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
            LogMessage := '';
          end;

          Commit;
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);

        Commit;
        if NpCsDocument."Next Workflow Step" = NpCsDocument."Next Workflow Step"::"Order Status" then
          SendNotificationToStore(NpCsDocument);
    end;

    procedure RunWorkflowOrderStatus(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsUpdateOrderStatus: Codeunit "NpCs Update Order Status";
        LogMessage: Text;
        LastErrorText: Text;
        PrevStatus: Integer;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
          exit;

        PrevStatus := NpCsDocument."Processing Status";
        Commit;
        ClearLastError;
        asserterror begin
          NpCsDocument.TestField(Type,NpCsDocument.Type::"Send to Store");
          NpCsDocument.CalcFields("Order Status Module");
          if NpCsDocument."Order Status Module" = '' then
            NpCsDocument."Order Status Module" := NpCsUpdateOrderStatus.WorkflowCode();
          NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status",NpCsDocument."Order Status Module");
          UpdateOrderStatus(NpCsDocument,LogMessage);

          if IsComplete(NpCsDocument) then begin
            NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";
            NpCsDocument.Modify(true);
            Commit;
          end;

          if LogMessage <> '' then begin
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
            LogMessage := '';
          end;

          Commit;
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);

        Commit;
        if PrevStatus <> NpCsDocument."Processing Status" then
          SendNotificationToCustomer(NpCsDocument);
    end;

    procedure RunWorkflowPostProcessing(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        LogMessage: Text;
        LastErrorText: Text;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
          exit;

        Commit;
        ClearLastError;
        asserterror begin
          NpCsDocument.TestField(Type,NpCsDocument.Type::"Send to Store");
          NpCsDocument.CalcFields("Post Processing Module");
          if NpCsDocument."Post Processing Module" = '' then
            Error('');
          NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Post Processing",NpCsDocument."Post Processing Module");
          PerformPostProcessing(NpCsDocument,LogMessage);
          if LogMessage <> '' then begin
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,LogMessage);
            LogMessage := '';
          end;

          Commit;
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);
        Commit;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure SendOrder(var NpCsDocument: Record "NpCs Document";var LogMessage: Text)
    begin
    end;

    procedure SendNotificationToStore(NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsSendOrder: Codeunit "NpCs Send Order";
        LogMessage: Text;
        LastErrorText: Text;
    begin
        NpCsDocument.CalcFields("Send Order Module");
        if NpCsDocument."Send Order Module" = '' then
            NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();
        Commit;
        ClearLastError;
        asserterror begin
          NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order",NpCsDocument."Send Order Module");
          NpCsDocument.TestField(Type,NpCsDocument.Type::"Send to Store");
          if NotifyStoreEmail(NpCsDocument,LogMessage) then
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');

          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);

        Commit;
        ClearLastError;
        asserterror begin
          NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order",NpCsDocument."Send Order Module");
          NpCsDocument.TestField(Type,NpCsDocument.Type::"Send to Store");
          if NotifyStoreSms(NpCsDocument,LogMessage) then
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');

          Commit;
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);
    end;

    local procedure NotifyStoreEmail(NpCsDocument: Record "NpCs Document";var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "E-mail Template Header";
        NpCsStore: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        EmailMgt: Codeunit "E-mail Management";
        RecRef: RecordRef;
    begin
        NpCsWorkflow.Get(NpCsDocument."Workflow Code");
        if not NpCsWorkflow."Notify Store via E-mail" then
          exit(false);

        LogMessage := StrSubstNo(Text001,NpCsDocument."To Store Code");

        NpCsStore.Get(NpCsDocument."To Store Code");
        NpCsStore.TestField("E-mail");
        LogMessage := StrSubstNo(Text001,NpCsDocument."To Store Code",NpCsStore."E-mail");

        NpCsWorkflow.TestField("E-mail Template");
        EmailTemplateHeader.Get(NpCsWorkflow."E-mail Template");
        EmailTemplateHeader.TestField("Table No.",DATABASE::"NpCs Document");
        EmailTemplateHeader.SetRecFilter;

        RecRef.GetTable(NpCsDocument);
        if EmailTemplateHeader."Report ID" = 0 then
          EmailMgt.SendEmailTemplate(RecRef,EmailTemplateHeader,NpCsStore."E-mail",true)
        else
          EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID",RecRef,EmailTemplateHeader,NpCsStore."E-mail",true);

        exit(true);
    end;

    local procedure NotifyStoreSms(NpCsDocument: Record "NpCs Document";var LogMessage: Text): Boolean
    var
        SmsTemplateHeader: Record "SMS Template Header";
        NpCsStore: Record "NpCs Store";
        NpCsStoreLocal: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        SmsMgt: Codeunit "SMS Management";
        SmsContent: Text;
    begin
        NpCsWorkflow.Get(NpCsDocument."Workflow Code");
        if not NpCsWorkflow."Notify Store via Sms" then
          exit(false);

        LogMessage := StrSubstNo(Text002,NpCsDocument."To Store Code");

        if NpCsStore.Get(NpCsDocument."To Store Code") then;
        NpCsStore.TestField("Mobile Phone No.");
        LogMessage := StrSubstNo(Text002,NpCsDocument."To Store Code",NpCsStore."Mobile Phone No.");

        NpCsWorkflow.TestField("Sms Template");
        SmsTemplateHeader.Get(NpCsWorkflow."Sms Template");
        SmsTemplateHeader.TestField("Table No.",DATABASE::"NpCs Document");
        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader,NpCsDocument);

        NpCsStoreLocal.Get(NpCsDocument."From Store Code");
        NpCsStoreLocal.TestField("Mobile Phone No.");

        SmsMgt.SendSMS(NpCsStore."Mobile Phone No.",DelChr(NpCsStoreLocal."Mobile Phone No.",'=',' '),SmsContent);

        exit(true);
    end;

    procedure SendNotificationToCustomer(NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        LogMessage: Text;
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

        Commit;
        ClearLastError;
        asserterror begin
          if NotifyCustomerEmail(NpCsDocument,LogMessage) then
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');

          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);

        Commit;
        ClearLastError;
        asserterror begin
          if NotifyCustomerSms(NpCsDocument,LogMessage) then
            InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');

          Commit;
          Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,true,LastErrorText);
    end;

    local procedure NotifyCustomerEmail(NpCsDocument: Record "NpCs Document";var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "E-mail Template Header";
        EmailMgt: Codeunit "E-mail Management";
        RecRef: RecordRef;
        ErrorText: Text;
    begin
        if not NpCsDocument."Notify Customer via E-mail" then
          exit(false);

        LogMessage := StrSubstNo(Text004,NpCsDocument."Sell-to Customer Name",NpCsDocument."Customer E-mail",NpCsDocument."Processing Status");
        NpCsDocument.TestField("Customer E-mail");

        case NpCsDocument."Processing Status" of
          NpCsDocument."Processing Status"::Pending:
            begin
              if NpCsDocument."E-mail Template (Pending)" = '' then
                exit(false);

              EmailTemplateHeader.Get(NpCsDocument."E-mail Template (Pending)");
            end;
          NpCsDocument."Processing Status"::Confirmed:
            begin
              if NpCsDocument."E-mail Template (Confirmed)" = '' then
                exit(false);

              EmailTemplateHeader.Get(NpCsDocument."E-mail Template (Confirmed)");
            end;
          NpCsDocument."Processing Status"::Rejected:
            begin
              if NpCsDocument."E-mail Template (Rejected)" = '' then
                exit(false);

              EmailTemplateHeader.Get(NpCsDocument."E-mail Template (Rejected)");
            end;
          NpCsDocument."Processing Status"::Expired:
            begin
              if NpCsDocument."E-mail Template (Expired)" = '' then
                exit(false);

              EmailTemplateHeader.Get(NpCsDocument."E-mail Template (Expired)");
            end;
          else
            exit(false);
        end;
        EmailTemplateHeader.TestField("Table No.",DATABASE::"NpCs Document");
        EmailTemplateHeader.SetRecFilter;

        RecRef.GetTable(NpCsDocument);
        RecRef.SetRecFilter;

        if EmailTemplateHeader."Report ID" = 0 then
          ErrorText := EmailMgt.SendEmailTemplate(RecRef,EmailTemplateHeader,NpCsDocument."Customer E-mail",true)
        else
          ErrorText := EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID",RecRef,EmailTemplateHeader,NpCsDocument."Customer E-mail",true);

        if ErrorText <> '' then
          Error(CopyStr(ErrorText,1,1020));

        exit(true);
    end;

    local procedure NotifyCustomerSms(NpCsDocument: Record "NpCs Document";var LogMessage: Text): Boolean
    var
        SmsTemplateHeader: Record "SMS Template Header";
        SmsMgt: Codeunit "SMS Management";
        SmsContent: Text;
    begin
        if not NpCsDocument."Notify Customer via Sms" then
          exit(false);

        LogMessage := StrSubstNo(Text005,NpCsDocument."Sell-to Customer Name",NpCsDocument."Customer Phone No.",NpCsDocument."Processing Status");
        NpCsDocument.TestField("Customer Phone No.");

        case NpCsDocument."Processing Status" of
          NpCsDocument."Processing Status"::Pending:
            begin
              if NpCsDocument."Sms Template (Pending)" = '' then
                exit(false);

              SmsTemplateHeader.Get(NpCsDocument."Sms Template (Pending)");
            end;
          NpCsDocument."Processing Status"::Confirmed:
            begin
              if NpCsDocument."Sms Template (Confirmed)" = '' then
                exit(false);

              SmsTemplateHeader.Get(NpCsDocument."Sms Template (Confirmed)");
            end;
          NpCsDocument."Processing Status"::Rejected:
            begin
              if NpCsDocument."Sms Template (Rejected)" = '' then
                exit(false);

              SmsTemplateHeader.Get(NpCsDocument."Sms Template (Rejected)");
            end;
          NpCsDocument."Processing Status"::Expired:
            begin
              if NpCsDocument."Sms Template (Expired)" = '' then
                exit(false);

              SmsTemplateHeader.Get(NpCsDocument."Sms Template (Expired)");
            end;
          else
            exit(false);
        end;
        SmsTemplateHeader.TestField("Table No.",DATABASE::"NpCs Document");
        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader,NpCsDocument);

        SmsMgt.SendSMS(NpCsDocument."Customer Phone No.",DelChr(NpCsDocument."Customer Phone No.",'=',' '),SmsContent);

        exit(true);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure UpdateOrderStatus(var NpCsDocument: Record "NpCs Document";var LogMessage: Text)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure PerformPostProcessing(var NpCsDocument: Record "NpCs Document";var LogMessage: Text)
    begin
    end;

    procedure RunCallback(NpCsDocument: Record "NpCs Document")
    var
        NpCsStore: Record "NpCs Store";
        NpCsArchDocument: Record "NpCs Arch. Document";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        InStr: InStream;
        ExceptionMessage: Text;
        ReqBody: Text;
    begin
        if not NpCsStore.Get(NpCsDocument."From Store Code") then
          exit;
        if NpCsStore."Service Url" = '' then
          exit;

        if not NpCsDocument.Find then begin
          NpCsArchDocument.SetRange(Type,NpCsDocument.Type);
          case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
              begin
                NpCsArchDocument.SetRange("Document Type",NpCsDocument."From Document Type");
                NpCsArchDocument.SetRange("Document No.",NpCsDocument."From Document No.");
              end;
            NpCsDocument.Type::"Collect in Store":
              begin
                NpCsArchDocument.SetRange("From Document Type",NpCsDocument."From Document Type");
                NpCsArchDocument.SetRange("From Document No.",NpCsDocument."From Document No.");
              end;
          end;
          NpCsArchDocument.SetRange("From Store Code",NpCsDocument."From Store Code");
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
        NpCsDocument."Callback Data".CreateInStream(InStr,TEXTENCODING::UTF8);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        XmlElement := XmlDoc.DocumentElement;

        HttpWebRequest := HttpWebRequest.CreateHttp(NpCsStore."Service Url");
        HttpWebRequest.ContentType := NpXmlDomMgt.GetElementText(XmlElement,'content_type',0,true);
        foreach XmlElement2 in XmlElement.SelectNodes('headers/header') do
          HttpWebRequest.Headers.Add(XmlElement2.GetAttribute('name'),XmlElement2.InnerText);

        HttpWebRequest.Method := NpXmlDomMgt.GetElementText(XmlElement,'method',0,true);
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);

        ReqBody := NpXmlDomMgt.GetElementText(XmlElement,'request_body',0,true);

        if not NpXmlDomMgt.SendWebRequestText(ReqBody,HttpWebRequest,HttpWebResponse,WebException) then begin
          ExceptionMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ExceptionMessage,XmlDoc) then begin
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ExceptionMessage := XmlElement.InnerText;
          end;

          Error(CopyStr(ExceptionMessage,1,1020));
        end;
    end;

    procedure InsertLogEntry(NpCsDocument: Record "NpCs Document";NpCsWorkflowModule: Record "NpCs Workflow Module";LogMessage: Text;ErrorEntry: Boolean;ErrorMessage: Text)
    var
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
        OutStr: OutStream;
    begin
        NpCsDocumentLogEntry.Init;
        NpCsDocumentLogEntry."Entry No." := 0;
        NpCsDocumentLogEntry."Log Date" := CurrentDateTime;
        NpCsDocumentLogEntry."Document Entry No." := NpCsDocument."Entry No.";
        NpCsDocumentLogEntry."Workflow Type" := NpCsWorkflowModule.Type;
        NpCsDocumentLogEntry."Workflow Module" := NpCsWorkflowModule.Code;
        NpCsDocumentLogEntry."Log Message" := CopyStr(LogMessage,1,MaxStrLen(NpCsDocumentLogEntry."Log Message"));
        NpCsDocumentLogEntry."Error Message".CreateOutStream(OutStr,TEXTENCODING::UTF8);
        OutStr.WriteText(ErrorMessage);
        NpCsDocumentLogEntry."Error Entry" := ErrorEntry;
        NpCsDocumentLogEntry.Insert(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Workflow Mgt.");
    end;

    local procedure IsComplete(NpCsDocument: Record "NpCs Document"): Boolean
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered] then
          exit(true);

        exit(false);
    end;
}

