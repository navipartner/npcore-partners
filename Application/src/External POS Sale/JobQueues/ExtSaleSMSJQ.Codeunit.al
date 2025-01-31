codeunit 6248238 "NPR Ext. Sale SMS JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        ExternalPOSSaleSet: Record "NPR External POS Sale";
        ExternalPOSSaleRec: Record "NPR External POS Sale";
        SMSLog: Record "NPR SMS Log";
    begin
        SelectLatestVersion();
        ExternalPOSSaleSet.SetFilter("Converted To POS Entry", '=%1', true);
        ExternalPOSSaleSet.SetFilter("Send Receipt: SMS", '=%1', true);
        ExternalPOSSaleSet.SetFilter("SMS Receipt Sent", '=%1', false);
        if ExternalPOSSaleSet.FindSet() then
            repeat
                Commit();
                ExternalPOSSaleRec := ExternalPOSSaleSet;
                ExternalPOSSaleRec.LockTable();
                ExternalPOSSaleRec.Find();
                if (SMSLog.Get(ExternalPOSSaleRec."SMS Receipt Log")) then begin
                    if (SMSLog.Status = SMSLog.Status::Sent) then begin
                        ExternalPOSSaleRec."SMS Receipt Sent" := true;
                        ExternalPOSSaleRec.Modify();
                    end;
                end else begin
                    ExtPosSaleQueueSMSReceipt(ExternalPOSSaleRec);
                end;
            until ExternalPOSSaleSet.Next() = 0;
    end;

    internal procedure ExtPosSaleQueueSMSReceipt(var ExternalPOSSale: Record "NPR External POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        SMSLog: Record "NPR SMS Log";
        POSActionSendSMSRcptB: Codeunit "NPR POS Action: Send SMS RcptB";
        NotConvertedErrorLbl: Label 'The External POS Sale is not yet converted to POS Entry!';
    begin

        if (not ExternalPOSSale."Converted To POS Entry") then
            Error(NotConvertedErrorLbl);
        if ((ExternalPOSSale."Send Receipt: SMS") and
            (ExternalPOSSale."Phone Number" <> '')) then begin
            ExternalPOSSale.TestField(ExternalPOSSale."SMS Template");
            POSEntry.Get(ExternalPOSSale."POS Entry No.");
            POSActionSendSMSRcptB.SendReceipt(ExternalPOSSale."SMS Template", ExternalPOSSale."Phone Number", POSEntry."Entry No.");
            SMSLog.SetFilter("Reciepient No.", '=%1', ExternalPOSSale."Phone Number");
            if (SMSLog.FindLast()) then begin
                ExternalPOSSale."SMS Receipt Log" := SMSLog."Entry No.";
                ExternalPOSSale.Modify();
            end;
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddExtPOSSaleSMSReceiptJobQueue()
    begin
        AddExtPOSSaleSMSReceiptJobQueue();
    end;

    internal procedure AddExtPOSSaleSMSReceiptJobQueue()
    var
        ExtSaleConvertJQ: Codeunit "NPR Ext. Sale Convert JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'External POS Sale SMS Receipt Sender', MaxLength = 250;
    begin
        JobQueueManagement.SetJobTimeout(4, 0);  //4 hours

        if not JobQueueManagement.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Ext. Sale SMS JQ",
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
