codeunit 6184975 "NPR MM LoyaltyRetryQueueMgr"
{
    Access = Internal;
    trigger OnRun()
    var
        RetryQueue: Record "NPR MM LoyaltyRetryQueue";
    begin
        RetryQueue.SetCurrentKey(NextRetryDateTime);
        RetryQueue.SetFilter(NextRetryDateTime, '<=%1', CurrentDateTime());
        if (RetryQueue.FindSet()) then begin
            repeat
                if (not RetryQueueEntry(RetryQueue.EntryNo)) then
                    Sleep(100);
                Commit();
            until (RetryQueue.Next() = 0);
        end;
    end;


    internal procedure AddToQueue(EFTTransactionRequest: Record "NPR EFT Transaction Request"; SoapAction: Text; XmlRequestText: Text; ResponseMessage: Text): Boolean
    var
        RetryQueue: Record "NPR MM LoyaltyRetryQueue";
        Stream: OutStream;
    begin
        if (SoapAction <> 'RegisterReceipt') then
            exit(false);

        RetryQueue.Init();
        RetryQueue.EntryNo := EFTTransactionRequest."Entry No.";
        RetryQueue.SalesTicketNo := EFTTransactionRequest."Sales Ticket No.";
        RetryQueue.SalesId := EFTTransactionRequest."Sales ID";
        RetryQueue.RetryCount := 0;
        RetryQueue.SoapAction := CopyStr(SoapAction, 1, MaxStrLen(RetryQueue.SoapAction));
        RetryQueue.FailedDateTime := CurrentDateTime();
        RetryQueue.LastError := CopyStr(ResponseMessage, 1, MaxStrLen(RetryQueue.LastError));
        RetryQueue.NextRetryDateTime := CurrentDateTime() + 1 * 60 * 1000; // 1 minute

        RetryQueue.RequestXml.CreateOutStream(Stream);
        Stream.Write(XmlRequestText);
        exit(RetryQueue.Insert());
    end;


    internal procedure RetryQueueEntry(EntryNo: Integer): Boolean
    var
        RetryQueue: Record "NPR MM LoyaltyRetryQueue";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        LoyaltyEndpointClient: Record "NPR MM NPR Remote Endp. Setup";
        LoyaltyClientMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        ForeignMembership: Codeunit "NPR MM NPR Membership";
        ResponseMessage: Text;
        Success: Boolean;
        Stream: InStream;
        XmlRequestText: Text;
        XmlRequestDoc: XmlDocument;
        XmlResponseDoc: XmlDocument;
    begin
        RetryQueue.Get(EntryNo);
        EFTTransactionRequest.Get(EntryNo);

        LoyaltyClientMgr.GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup);
        LoyaltyEndpointClient.Get(LoyaltyStoreSetup."Store Endpoint Code");
        LoyaltyEndpointClient.TestField(Type, LoyaltyEndpointClient.Type::LoyaltyServices);

        RetryQueue.CalcFields(RequestXml);
        RetryQueue.RequestXml.CreateInStream(Stream);
        Stream.Read(XmlRequestText);
        XmlDocument.ReadFrom(XmlRequestText, XmlRequestDoc);

        Success := ForeignMembership.WebServiceApi(LoyaltyEndpointClient, RetryQueue.SoapAction, ResponseMessage, XmlRequestDoc, XmlResponseDoc);
        LoyaltyClientMgr.HandleWebServiceResult(EFTTransactionRequest, Success, ResponseMessage, XmlResponseDoc);

        if (not Success) then begin
            RetryQueue.FailedDateTime := CurrentDateTime();
            RetryQueue.NextRetryDateTime := CurrentDateTime() + CalculateBackoffCoefficient(RetryQueue.RetryCount) * 60 * 1000;
            RetryQueue.RetryCount += 1;
            RetryQueue.LastError := CopyStr(ResponseMessage, 1, MaxStrLen(RetryQueue.LastError));
            RetryQueue.Modify();
            exit(false)
        end;

        RetryQueue.Delete();
        exit(true);
    end;

    local procedure CalculateBackoffCoefficient(AttemptNumber: Integer) BackoffTime: Integer
    begin

        if (AttemptNumber < 4) then
            exit(1);

        BackoffTime := 2 * AttemptNumber - 4;
        if (BackoffTime > 30) then
            BackoffTime := 30;

        exit(BackoffTime);  // 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30
    end;


    // Job Queue management
    internal procedure CreateJobQueueEntry()
    var
        LoyaltyServiceEndpoint: Record "NPR MM NPR Remote Endp. Setup";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescription: Label 'Loyalty Pay With Points Retry Queue';
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        LoyaltyServiceEndpoint.SetFilter(Type, '=%1', LoyaltyServiceEndpoint.Type::LoyaltyServices);
        if (LoyaltyServiceEndpoint.IsEmpty()) then begin
            JobQueueManagement.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitID());
            exit;
        end;

        NotBeforeDateTime := CurrentDateTime();
        Evaluate(NextRunDateFormula, '<1D>');
        if (JobQueueManagement.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CurrCodeunitID(),
            '',
            JobQueueDescription,
            NotBeforeDateTime,
            090000T,
            210000T,
            5,
            '',
            JobQueueEntry))
        then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR MM LoyaltyRetryQueueMgr");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM NPR Remote Endp. Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure EnsureJobQueueEntryExistsOnRemoteEndpointInsert(var Rec: Record "NPR MM NPR Remote Endp. Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if Rec.IsTemporary() then
            exit;

        if (not JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitID())) then
            CreateJobQueueEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        CreateJobQueueEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = CurrCodeunitID())
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

}