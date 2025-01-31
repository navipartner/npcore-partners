codeunit 6248236 "NPR Ext. Sale Convert JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        ExternalPOSSale: Record "NPR External POS Sale";
        ExtPOSSaleConverter: Codeunit "NPR Ext. POS Sale Converter";
        ExtPOSSaleProcessing: Codeunit "NPR Ext. POS Sale Processing";
    begin
        SelectLatestVersion();
        ExternalPOSSale.SetFilter("Converted To POS Entry", '=%1', False);
        ExternalPOSSale.SetFilter("Has Conversion Error", '=%1', False);
        if ExternalPOSSale.FindSet() then
            repeat
                Commit();
                if (not ExtPOSSaleConverter.Run(ExternalPOSSale)) then begin
                    ExternalPOSSale.LockTable();
                    ExternalPOSSale.Find();
                    ExtPOSSaleProcessing.AddConversionError(ExternalPOSSale, GetLastErrorText());
                end;
            until ExternalPOSSale.Next() = 0;
    end;


#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddExtPOSSaleConversionJobQueue()
    begin
        AddExtPOSSaleConversionJobQueue();
    end;

    internal procedure AddExtPOSSaleConversionJobQueue()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'External POS Sale Conversion', MaxLength = 250;
    begin
        JobQueueManagement.SetJobTimeout(4, 0);  //4 hours

        if not JobQueueManagement.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Ext. Sale Convert JQ",
            '',
            JobQueueDescrLbl,
            JobQueueManagement.NowWithDelayInSeconds(360),
            1,
            GetExternalSaleCategory(),
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

    internal procedure GetExternalSaleCategory(): Code[10]
    begin
        exit('EXT. SALE');
    end;
}
