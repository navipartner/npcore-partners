codeunit 6248239 "NPR Ext. Sale Email JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        ExternalPOSSale: Record "NPR External POS Sale";
    begin
        SelectLatestVersion();
        ExternalPOSSale.SetFilter("Converted To POS Entry", '=%1', true);
        ExternalPOSSale.SetFilter("Send Receipt: Email", '=%1', true);
        ExternalPOSSale.SetFilter("Email Receipt Sent", '=%1', false);
        if ExternalPOSSale.FindSet() then
            repeat
                Commit();
                SendEmailReceipt(ExternalPOSSale);
            until ExternalPOSSale.Next() = 0;
    end;

    internal procedure SendEmailReceipt(var ExternalPOSSaleSet: Record "NPR External POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        ExternalPOSSale: Record "NPR External POS Sale";
        EmailManagement: Codeunit "NPR E-mail Management";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        POSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry";
        POSActionIssueDigRcptB: Codeunit "NPR POS Action: IssueDigRcpt B";
        RecRef: RecordRef;
        MailErrorMessage: Text;
        DigitalReceiptLink: Text;
        FooterText: Text;
    begin
        ExternalPOSSale := ExternalPOSSaleSet;
        ExternalPOSSale.LockTable();
        ExternalPOSSale.Find();
        if ((ExternalPOSSale."Send Receipt: Email") and
            (ExternalPOSSale."E-mail" <> '')) then begin
            if (ExternalPOSSale."Email Receipt Sent") then
                exit;
            ExternalPOSSale.TestField(ExternalPOSSale."Email Template");
            ExternalPOSSale.TestField(ExternalPOSSale."POS Entry System Id");
            POSEntry.GetBySystemId(ExternalPOSSale."POS Entry System Id");
            POSSaleDigitalReceiptEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSSaleDigitalReceiptEntry.IsEmpty() then begin
                POSActionIssueDigRcptB.CheckIfGlobalSetupEnabledAndCreateReceipt(POSEntry."Document No.", DigitalReceiptLink, FooterText);
            end;
            POSSaleDigitalReceiptEntry.FindLast();
            RecRef.GetTable(POSSaleDigitalReceiptEntry);
            RecRef.SetRecFilter();
            EmailTemplateHeader.Get(ExternalPOSSale."Email Template");
            EmailTemplateHeader.SetRecFilter();
            if EmailTemplateHeader."Report ID" > 0 then
                MailErrorMessage := EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, ExternalPOSSale."E-mail", true)
            else
                MailErrorMessage := EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, ExternalPOSSale."E-mail", true);
            ExternalPOSSale."Email Receipt Sent" := MailErrorMessage = '';
            ExternalPOSSale.Modify();
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddExtPOSSaleSendEmailReceiptJobQueue()
    begin
        AddExtPOSSaleSendEmailReceiptJobQueue();
    end;

    internal procedure AddExtPOSSaleSendEmailReceiptJobQueue()
    var
        ExtSaleConvertJQ: Codeunit "NPR Ext. Sale Convert JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'External POS Sale Email Receipt Sender', MaxLength = 250;
    begin
        JobQueueManagement.SetJobTimeout(4, 0);  //4 hours

        if not JobQueueManagement.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Ext. Sale Email JQ",
            '',
            JobQueueDescrLbl,
            JobQueueManagement.NowWithDelayInSeconds(360),
            1,
            ExtSaleConvertJQ.GetExternalSaleCategory(),
            JobQueueEntry)
        then
            exit;

        JobQueueEntry."Maximum No. of Attempts to Run" := 999999999;
        JobQueueEntry."Rerun Delay (sec.)" := 10;
        JobQueueEntry."NPR Auto-Resched. after Error" := true;
        JobQueueEntry."NPR Auto-Resched. Delay (sec.)" := 20;
        JobQueueEntry.Modify(true);
        JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;
}
