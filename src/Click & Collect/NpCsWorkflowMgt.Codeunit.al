codeunit 6151196 "NPR NpCs Workflow Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190627  CASE 344264 Bumped version list for update to TaskScheduler in ScheduleRunWorkflow() from NAV10.* and newer
    // NPR5.51/MHA /20190822  CASE 364557 Removed Calcfields of "Sell-to Customer Name"
    // NPR5.52/MHA /20191010  CASE 369476 Added function GetSmsSender() in NotifyCustomerSms()
    // NPR5.53/MHA /20191129  CASE 378216 Archivation added to RunWorkflow()
    // NPR5.54/MHA /20200214  CASE 390590 Added function ScheduleRunWorkflowDelay()
    // NPR5.54/MHA /20200130  CASE 378956 Added Expiry Notification to NotifyStoreEmail() and NotifyStoreSms()

    TableNo = "NPR NpCs Document";

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
        //-NPR10.00.00.5.51 [344264]
        TASKSCHEDULER.CreateTask(CurrCodeunitId(), 0, true, CompanyName, CurrentDateTime, NpCsDocument.RecordId);
        //+NPR10.00.00.5.51 [344264]
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
            //-NPR5.53 [378216]
            if IsReadyForArchivation(NpCsDocument) then
                NpCsArchCollectMgt.ArchiveCollectDocument(NpCsDocument);
            //+NPR5.53 [378216]
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
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        LogMessage: Text;
        LastErrorText: Text;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        Commit;
        ClearLastError;
        asserterror
        begin
            NpCsDocument.Find;
            NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
            NpCsDocument.CalcFields("Send Order Module");
            if NpCsDocument."Send Order Module" = '' then
                NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();
            NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order", NpCsDocument."Send Order Module");

            SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
            if SalesHeader.Status <> SalesHeader.Status::Released then begin
                LogMessage := StrSubstNo(Text003, SalesHeader."No.");
                ReleaseSalesDoc.PerformManualRelease(SalesHeader);
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
                Commit;
            end;

            NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Order Status";
            NpCsDocument.Modify(true);
            SendOrder(NpCsDocument, LogMessage);
            Commit;

            if LogMessage <> '' then begin
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
                LogMessage := '';
            end;

            Commit;
            Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);

        Commit;
        if NpCsDocument."Next Workflow Step" = NpCsDocument."Next Workflow Step"::"Order Status" then
            SendNotificationToStore(NpCsDocument);
    end;

    procedure RunWorkflowOrderStatus(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsUpdateOrderStatus: Codeunit "NPR NpCs Upd. Order Status";
        LogMessage: Text;
        LastErrorText: Text;
        PrevStatus: Integer;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        PrevStatus := NpCsDocument."Processing Status";
        Commit;
        ClearLastError;
        asserterror
        begin
            NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
            NpCsDocument.CalcFields("Order Status Module");
            if NpCsDocument."Order Status Module" = '' then
                NpCsDocument."Order Status Module" := NpCsUpdateOrderStatus.WorkflowCode();
            NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status", NpCsDocument."Order Status Module");
            UpdateOrderStatus(NpCsDocument, LogMessage);

            if IsComplete(NpCsDocument) then begin
                NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";
                NpCsDocument.Modify(true);
                Commit;
            end;

            if LogMessage <> '' then begin
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
                LogMessage := '';
            end;

            Commit;
            Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);

        Commit;
        if PrevStatus <> NpCsDocument."Processing Status" then begin
            SendNotificationToCustomer(NpCsDocument);
            //-NPR5.54 [378956]
            SendNotificationToStore(NpCsDocument);
            //+NPR5.54 [378956]
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

        Commit;
        ClearLastError;
        asserterror
        begin
            NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
            NpCsDocument.CalcFields("Post Processing Module");
            if NpCsDocument."Post Processing Module" = '' then
                Error('');
            NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Post Processing", NpCsDocument."Post Processing Module");
            PerformPostProcessing(NpCsDocument, LogMessage);
            if LogMessage <> '' then begin
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, LogMessage);
                LogMessage := '';
            end;

            Commit;
            Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);
        Commit;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure SendOrder(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    begin
    end;

    procedure SendNotificationToStore(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        LogMessage: Text;
        LastErrorText: Text;
    begin
        NpCsDocument.CalcFields("Send Order Module");
        if NpCsDocument."Send Order Module" = '' then
            NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();
        Commit;
        ClearLastError;
        asserterror
        begin
            //-NPR5.54 [378956]
            FindNextWorkflowModule(NpCsDocument, NpCsWorkflowModule);
            //+NPR5.54 [378956]
            if NotifyStoreEmail(NpCsDocument, LogMessage) then
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');

            Commit;
            Error('');
        end;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);

        Commit;
        ClearLastError;
        asserterror
        begin
            //-NPR5.54 [378956]
            FindNextWorkflowModule(NpCsDocument, NpCsWorkflowModule);
            //+NPR5.54 [378956]
            if NotifyStoreSms(NpCsDocument, LogMessage) then
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');

            Commit;
            Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);
    end;

    local procedure FindNextWorkflowModule(NpCsDocument: Record "NPR NpCs Document"; NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
        //-NPR5.54 [378956]
        NpCsWorkflowModule.Init;
        case NpCsDocument."Next Workflow Step" of
            NpCsDocument."Next Workflow Step"::"Send Order":
                begin
                    NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
                    NpCsWorkflowModule.Code := NpCsDocument."Send Order Module";
                end;
            NpCsDocument."Next Workflow Step"::"Order Status":
                begin
                    NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
                    NpCsWorkflowModule.Code := NpCsDocument."Order Status Module";
                end;
            NpCsDocument."Next Workflow Step"::"Post Processing":
                begin
                    NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
                    NpCsWorkflowModule.Code := NpCsDocument."Post Processing Module";
                end;
        end;

        if NpCsWorkflowModule.Find then;
        //+NPR5.54 [378956]
    end;

    local procedure NotifyStoreEmail(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        NpCsStore: Record "NPR NpCs Store";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        //-NPR5.54 [378956]
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
                begin
                    if NpCsDocument."Send Notification from Store" then
                        exit(false);
                end;
            NpCsDocument.Type::"Collect in Store":
                begin
                    if not NpCsDocument."Send Notification from Store" then
                        exit(false);
                end;
        end;

        if not NpCsDocument."Notify Store via E-mail" then
            exit(false);

        LogMessage := StrSubstNo(Text001, NpCsDocument."To Store Code");

        NpCsStore.Get(NpCsDocument."To Store Code");
        NpCsStore.TestField("E-mail");
        LogMessage := StrSubstNo(Text001, NpCsDocument."To Store Code", NpCsStore."E-mail");

        case NpCsDocument."Delivery Status" of
            NpCsDocument."Delivery Status"::Expired:
                begin
                    if NpCsDocument."Store E-mail Temp. (Expired)" = '' then
                        exit(false);

                    EmailTemplateHeader.Get(NpCsDocument."Store E-mail Temp. (Expired)");
                end;
            else
                case NpCsDocument."Processing Status" of
                    NpCsDocument."Processing Status"::Pending:
                        begin
                            if NpCsDocument."Store E-mail Temp. (Pending)" <> '' then
                                EmailTemplateHeader.Get(NpCsDocument."Store E-mail Temp. (Pending)");
                        end;
                    NpCsDocument."Processing Status"::Expired:
                        begin
                            if NpCsDocument."Store E-mail Temp. (Expired)" <> '' then
                                EmailTemplateHeader.Get(NpCsDocument."Store E-mail Temp. (Expired)");
                        end;
                end;
        end;

        if EmailTemplateHeader.Code = '' then
            exit(false);
        //+NPR5.54 [378956]
        EmailTemplateHeader.TestField("Table No.", DATABASE::"NPR NpCs Document");
        EmailTemplateHeader.SetRecFilter;

        RecRef.GetTable(NpCsDocument);
        if EmailTemplateHeader."Report ID" = 0 then
            EmailMgt.SendEmailTemplate(RecRef, EmailTemplateHeader, NpCsStore."E-mail", true)
        else
            EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, NpCsStore."E-mail", true);

        exit(true);
    end;

    local procedure NotifyStoreSms(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        SmsTemplateHeader: Record "NPR SMS Template Header";
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreLocal: Record "NPR NpCs Store";
        SmsMgt: Codeunit "NPR SMS Management";
        SmsContent: Text;
    begin
        //-NPR5.54 [378956]
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
                begin
                    if NpCsDocument."Send Notification from Store" then
                        exit(false);
                end;
            NpCsDocument.Type::"Collect in Store":
                begin
                    if not NpCsDocument."Send Notification from Store" then
                        exit(false);
                end;
        end;

        if not NpCsDocument."Notify Store via Sms" then
            exit(false);

        LogMessage := StrSubstNo(Text002, NpCsDocument."To Store Code");

        if NpCsStore.Get(NpCsDocument."To Store Code") then;
        NpCsStore.TestField("Mobile Phone No.");
        LogMessage := StrSubstNo(Text002, NpCsDocument."To Store Code", NpCsStore."Mobile Phone No.");

        case NpCsDocument."Delivery Status" of
            NpCsDocument."Delivery Status"::Expired:
                begin
                    if NpCsDocument."Store Sms Template (Expired)" <> '' then
                        SmsTemplateHeader.Get(NpCsDocument."Store Sms Template (Expired)");
                end;
            else
                case NpCsDocument."Processing Status" of
                    NpCsDocument."Processing Status"::Expired:
                        begin
                            if NpCsDocument."Store Sms Template (Expired)" <> '' then
                                SmsTemplateHeader.Get(NpCsDocument."Store Sms Template (Expired)");
                        end;
                    else begin
                            if NpCsDocument."Store Sms Template (Pending)" <> '' then
                                SmsTemplateHeader.Get(NpCsDocument."Store Sms Template (Pending)");
                        end;
                end;
        end;

        if SmsTemplateHeader.Code = '' then
            exit(false);
        //+NPR5.54 [378956]
        SmsTemplateHeader.TestField("Table No.", DATABASE::"NPR NpCs Document");
        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader, NpCsDocument);

        NpCsStoreLocal.Get(NpCsDocument."From Store Code");
        NpCsStoreLocal.TestField("Mobile Phone No.");

        SmsMgt.SendSMS(NpCsStore."Mobile Phone No.", DelChr(NpCsStoreLocal."Mobile Phone No.", '=', ' '), SmsContent);

        exit(true);
    end;

    procedure SendNotificationToCustomer(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
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
        asserterror
        begin
            if NotifyCustomerEmail(NpCsDocument, LogMessage) then
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');

            Commit;
            Error('');
        end;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);

        Commit;
        ClearLastError;
        asserterror
        begin
            if NotifyCustomerSms(NpCsDocument, LogMessage) then
                InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');

            Commit;
            Error('');
        end;

        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
            InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, true, LastErrorText);
    end;

    local procedure NotifyCustomerEmail(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ErrorText: Text;
    begin
        if not NpCsDocument."Notify Customer via E-mail" then
            exit(false);

        LogMessage := StrSubstNo(Text004, NpCsDocument."Sell-to Customer Name", NpCsDocument."Customer E-mail", NpCsDocument."Processing Status");
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
        EmailTemplateHeader.TestField("Table No.", DATABASE::"NPR NpCs Document");
        EmailTemplateHeader.SetRecFilter;

        RecRef.GetTable(NpCsDocument);
        RecRef.SetRecFilter;

        if EmailTemplateHeader."Report ID" = 0 then
            ErrorText := EmailMgt.SendEmailTemplate(RecRef, EmailTemplateHeader, NpCsDocument."Customer E-mail", true)
        else
            ErrorText := EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, NpCsDocument."Customer E-mail", true);

        if ErrorText <> '' then
            Error(CopyStr(ErrorText, 1, 1020));

        exit(true);
    end;

    local procedure NotifyCustomerSms(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        SmsTemplateHeader: Record "NPR SMS Template Header";
        SmsMgt: Codeunit "NPR SMS Management";
        SmsContent: Text;
        Sender: Text;
    begin
        if not NpCsDocument."Notify Customer via Sms" then
            exit(false);

        LogMessage := StrSubstNo(Text005, NpCsDocument."Sell-to Customer Name", NpCsDocument."Customer Phone No.", NpCsDocument."Processing Status");
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
        SmsTemplateHeader.TestField("Table No.", DATABASE::"NPR NpCs Document");
        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader, NpCsDocument);

        //-NPR5.52 [369476]
        Sender := GetSmsSender(NpCsDocument);
        Sender := DelChr(Sender, '=', ' ');
        SmsMgt.SendSMS(NpCsDocument."Customer Phone No.", Sender, SmsContent);
        //+NPR5.52 [369476]

        exit(true);
    end;

    local procedure GetSmsSender(NpCsDocument: Record "NPR NpCs Document"): Text
    var
        CompanyInfo: Record "Company Information";
        NpCsStore: Record "NPR NpCs Store";
    begin
        //-NPR5.52 [369476]
        if NpCsStore.Get(NpCsDocument."To Store Code") then begin
            if NpCsStore."Mobile Phone No." <> '' then
                exit(NpCsStore."Mobile Phone No.");

            if NpCsStore."Contact Phone No." <> '' then
                exit(NpCsStore."Contact Phone No.");
        end;

        if CompanyInfo.Get and (CompanyInfo."Phone No." <> '') then
            exit(CompanyInfo."Phone No.");

        if NpCsStore.Get(NpCsDocument."From Store Code") then begin
            if (NpCsStore."Mobile Phone No." <> '') then
                exit(NpCsStore."Mobile Phone No.");

            if NpCsStore."Contact Phone No." <> '' then
                exit(NpCsStore."Contact Phone No.");
        end;

        exit('noreply');
        //+NPR5.52 [369476]
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure UpdateOrderStatus(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure PerformPostProcessing(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
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

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Workflow Mgt.");
    end;

    local procedure IsComplete(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered] then
            exit(true);

        exit(false);
    end;

    local procedure IsReadyForArchivation(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        //-NPR5.53 [378216]
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
        //+NPR5.53 [378216]
    end;
}

