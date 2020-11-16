codeunit 6184506 "NPR EFT Trx Bgd. Session Mgt"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object
    // NPR5.54/MMV /20200226 CASE 364340 Added method IsRequestOutdated & ResponseExists()


    trigger OnRun()
    begin
    end;

    local procedure "// Request"()
    begin
    end;

    procedure CreateRequestRecord(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.")
    begin
        EFTTransactionAsyncRequest.Init;
        //-NPR5.54 [364340]
        EFTTransactionAsyncRequest."Request Entry No" := EFTTransactionRequest."Entry No.";
        EFTTransactionAsyncRequest."Hardware ID" := EFTTransactionRequest."Hardware ID";
        //+NPR5.54 [364340]
        EFTTransactionAsyncRequest.Insert;
    end;

    procedure IsRequestDone(TrxEntryNo: Integer; WithLock: Boolean): Boolean
    var
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
    begin
        if WithLock then
            EFTTransactionAsyncRequest.LockTable;

        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        exit(EFTTransactionAsyncRequest.Done);
    end;

    procedure IsRequestAbortAttempted(TrxEntryNo: Integer; WithLock: Boolean): Boolean
    var
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
    begin
        if WithLock then
            EFTTransactionAsyncRequest.LockTable;

        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        exit(EFTTransactionAsyncRequest."Abort Requested");
    end;

    procedure IsRequestOutdated(TrxEntryNo: Integer; HardwareID: Text): Boolean
    var
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
    begin
        //-NPR5.54 [364340]
        EFTTransactionAsyncRequest.SetRange("Hardware ID", HardwareID);
        EFTTransactionAsyncRequest.SetFilter("Request Entry No", '>%1', TrxEntryNo);
        exit(not EFTTransactionAsyncRequest.IsEmpty);
        //+NPR5.54 [364340]
    end;

    procedure MarkRequestAsDone(TrxEntryNo: Integer)
    var
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
    begin
        EFTTransactionAsyncRequest.LockTable;
        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        EFTTransactionAsyncRequest.Done := true;
        EFTTransactionAsyncRequest.Modify;
    end;

    procedure MarkRequestAsAbortAttempted(TrxEntryNo: Integer)
    var
        EFTTransactionAsyncRequest: Record "NPR EFT Trx Async Req.";
    begin
        EFTTransactionAsyncRequest.LockTable;
        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        EFTTransactionAsyncRequest."Abort Requested" := true;
        EFTTransactionAsyncRequest.Modify;
    end;

    local procedure "// Response"()
    begin
    end;

    procedure CreateResponseRecord(TrxEntryNo: Integer; Response: Text; ErrorMessage: Text; Error: Boolean)
    var
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
        OutStream: OutStream;
    begin
        EFTTransactionAsyncResponse.Init;
        EFTTransactionAsyncResponse."Request Entry No" := TrxEntryNo;
        EFTTransactionAsyncResponse.Error := Error;
        EFTTransactionAsyncResponse."Error Text" := CopyStr(ErrorMessage, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
        if Response <> '' then begin
            EFTTransactionAsyncResponse.Response.CreateOutStream(OutStream);
            OutStream.Write(Response);
        end;
        EFTTransactionAsyncResponse.Insert;
    end;

    procedure TryGetResponseRecord(TrxEntryNo: Integer; var EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.")
    begin
        EFTTransactionAsyncResponse.LockTable;
        EFTTransactionAsyncResponse.SetAutoCalcFields(Response);
        EFTTransactionAsyncResponse.Get(TrxEntryNo);
    end;

    procedure ResponseExists(TrxEntryNo: Integer): Boolean
    var
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
    begin
        //-NPR5.54 [364340]
        EFTTransactionAsyncResponse.SetRange("Request Entry No", TrxEntryNo);
        exit(not EFTTransactionAsyncResponse.IsEmpty);
        //+NPR5.54 [364340]
    end;
}

