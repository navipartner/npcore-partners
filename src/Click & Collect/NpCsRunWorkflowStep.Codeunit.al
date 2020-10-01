codeunit 6151212 "NPR NpCs Run Workflow Step"
{
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        NpCsDocument := Rec;
        case WorkflowFunctionType of
            WorkflowFunctionType::" ":
                Error(NotInitialized);
            WorkflowFunctionType::"Send Order":
                RunWorkflowSendOrder(NpCsDocument);
            WorkflowFunctionType::"Order Status":
                RunWorkflowOrderStatus(NpCsDocument);
            WorkflowFunctionType::"Post Processing":
                RunWorkflowPostProcessing(NpCsDocument);
            WorkflowFunctionType::"Send Notification to Store":
                SendNotificationToStore(NpCsDocument);
            WorkflowFunctionType::"Send Notification to Customer":
                SendNotificationToCustomer(NpCsDocument);
        end;
        if WorkflowFunctionType in [WorkflowFunctionType::"Send Order", WorkflowFunctionType::"Order Status", WorkflowFunctionType::"Post Processing"] then
            Rec := NpCsDocument;
    end;

    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NotificationType: Option " ",Email,Sms;
        WorkflowFunctionType: Option " ","Send Order","Order Status","Post Processing","Send Notification to Store","Send Notification to Customer";
        NotInitialized: Label 'Codeunit 6151212 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';

    procedure SetWorkflowFunctionType(WorkflowFunctionTypeIn: Option " ","Send Order","Order Status","Post Processing","Send Notification to Store","Send Notification to Customer")
    begin
        WorkflowFunctionType := WorkflowFunctionTypeIn;
    end;

    procedure SetNotificationType(NotificationTypeIn: Option " ",Email,Sms)
    begin
        NotificationType := NotificationTypeIn;
    end;

    local procedure RunWorkflowSendOrder(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        LogMessage: Text;
        SOReleasedLbl: Label 'Sales Order %1 Released ';
    begin
        NpCsDocument.Find;
        NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
        NpCsDocument.CalcFields("Send Order Module");
        if NpCsDocument."Send Order Module" = '' then
            NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();
        NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order", NpCsDocument."Send Order Module");

        SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
        if SalesHeader.Status <> SalesHeader.Status::Released then begin
            LogMessage := StrSubstNo(SOReleasedLbl, SalesHeader."No.");
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
            Commit;
        end;

        NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Order Status";
        NpCsDocument.Modify(true);
        NpCsWorkflowMgt.SendOrder(NpCsDocument, LogMessage);
        Commit;

        if LogMessage <> '' then
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
    end;

    local procedure RunWorkflowOrderStatus(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsUpdateOrderStatus: Codeunit "NPR NpCs Upd. Order Status";
        LogMessage: Text;
    begin
        NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
        NpCsDocument.CalcFields("Order Status Module");
        if NpCsDocument."Order Status Module" = '' then
            NpCsDocument."Order Status Module" := NpCsUpdateOrderStatus.WorkflowCode();
        NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status", NpCsDocument."Order Status Module");
        NpCsWorkflowMgt.UpdateOrderStatus(NpCsDocument, LogMessage);

        if IsComplete(NpCsDocument) then begin
            NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";
            NpCsDocument.Modify(true);
            Commit;
        end;

        if LogMessage <> '' then
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
    end;

    local procedure IsComplete(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered] then
            exit(true);

        exit(false);
    end;

    local procedure RunWorkflowPostProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        LogMessage: Text;
    begin
        if NpCsDocument.Type <> NpCsDocument.Type::"Send to Store" then
            exit;

        NpCsDocument.TestField(Type, NpCsDocument.Type::"Send to Store");
        NpCsDocument.CalcFields("Post Processing Module");
        if NpCsDocument."Post Processing Module" = '' then
            Error('');
        NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Post Processing", NpCsDocument."Post Processing Module");
        NpCsWorkflowMgt.PerformPostProcessing(NpCsDocument, LogMessage);
        if LogMessage <> '' then begin
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, LogMessage);
            LogMessage := '';
        end;
    end;

    local procedure SendNotificationToStore(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        LogMessage: Text;
    begin
        NpCsDocument.CalcFields("Send Order Module");
        if NpCsDocument."Send Order Module" = '' then
            NpCsDocument."Send Order Module" := NpCsSendOrder.WorkflowCode();

        FindNextWorkflowModule(NpCsDocument, NpCsWorkflowModule);
        case NotificationType of
            NotificationType::" ":
                Erase(NotInitialized);
            NotificationType::Email:
                if NotifyStoreEmail(NpCsDocument, LogMessage) then
                    NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
            NotificationType::Sms:
                if NotifyStoreSms(NpCsDocument, LogMessage) then
                    NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
        end;
    end;

    local procedure FindNextWorkflowModule(NpCsDocument: Record "NPR NpCs Document"; NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
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
    end;

    local procedure NotifyStoreEmail(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        NpCsStore: Record "NPR NpCs Store";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        NotifSentLbl: Label 'E-mail Notification sent to Store %1 (%2)';
    begin
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

        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."To Store Code");

        NpCsStore.Get(NpCsDocument."To Store Code");
        NpCsStore.TestField("E-mail");
        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."To Store Code", NpCsStore."E-mail");

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
        NotifSentLbl: Label 'Sms Notification sent to Store %1 (%2)';
    begin
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

        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."To Store Code");

        if NpCsStore.Get(NpCsDocument."To Store Code") then;
        NpCsStore.TestField("Mobile Phone No.");
        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."To Store Code", NpCsStore."Mobile Phone No.");

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
        SmsTemplateHeader.TestField("Table No.", DATABASE::"NPR NpCs Document");
        SmsContent := SmsMgt.MakeMessage(SmsTemplateHeader, NpCsDocument);

        NpCsStoreLocal.Get(NpCsDocument."From Store Code");
        NpCsStoreLocal.TestField("Mobile Phone No.");

        SmsMgt.SendSMS(NpCsStore."Mobile Phone No.", DelChr(NpCsStoreLocal."Mobile Phone No.", '=', ' '), SmsContent);

        exit(true);
    end;

    local procedure SendNotificationToCustomer(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        LogMessage: Text;
    begin
        NpCsDocument.CalcFields("Order Status Module");
        NpCsWorkflowModule.Init;
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := NpCsDocument."Order Status Module";
        if NpCsWorkflowModule.Find then;

        case NotificationType of
            NotificationType::" ":
                Erase(NotInitialized);
            NotificationType::Email:
                if NotifyCustomerEmail(NpCsDocument, LogMessage) then
                    NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
            NotificationType::Sms:
                if NotifyCustomerSms(NpCsDocument, LogMessage) then
                    NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
        end;
    end;

    local procedure NotifyCustomerEmail(NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ErrorText: Text;
        NotifSentLbl: Label 'E-mail Notification (%3) sent to Customer %1 (%2)';
    begin
        if not NpCsDocument."Notify Customer via E-mail" then
            exit(false);

        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."Sell-to Customer Name", NpCsDocument."Customer E-mail", NpCsDocument."Processing Status");
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
        NotifSentLbl: Label 'Sms Notification (%3) sent to Customer %1 (%2)';
    begin
        if not NpCsDocument."Notify Customer via Sms" then
            exit(false);

        LogMessage := StrSubstNo(NotifSentLbl, NpCsDocument."Sell-to Customer Name", NpCsDocument."Customer Phone No.", NpCsDocument."Processing Status");
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

        Sender := GetSmsSender(NpCsDocument);
        Sender := DelChr(Sender, '=', ' ');
        SmsMgt.SendSMS(NpCsDocument."Customer Phone No.", Sender, SmsContent);

        exit(true);
    end;

    local procedure GetSmsSender(NpCsDocument: Record "NPR NpCs Document"): Text
    var
        CompanyInfo: Record "Company Information";
        NpCsStore: Record "NPR NpCs Store";
    begin
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
    end;
}