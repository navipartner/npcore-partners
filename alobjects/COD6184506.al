codeunit 6184506 "EFT Trx Background Session Mgt"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object


    trigger OnRun()
    begin
    end;

    local procedure "// Request"()
    begin
    end;

    procedure CreateRequestRecord(TrxEntryNo: Integer;var EFTTransactionAsyncRequest: Record "EFT Transaction Async Request")
    begin
        EFTTransactionAsyncRequest.Init;
        EFTTransactionAsyncRequest."Request Entry No" := TrxEntryNo;
        EFTTransactionAsyncRequest.Insert;
    end;

    procedure IsRequestDone(TrxEntryNo: Integer;WithLock: Boolean): Boolean
    var
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
    begin
        if WithLock then
          EFTTransactionAsyncRequest.LockTable;

        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        exit(EFTTransactionAsyncRequest.Done);
    end;

    procedure IsRequestAbortAttempted(TrxEntryNo: Integer;WithLock: Boolean): Boolean
    var
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
    begin
        if WithLock then
          EFTTransactionAsyncRequest.LockTable;

        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        exit(EFTTransactionAsyncRequest."Abort Requested");
    end;

    procedure MarkRequestAsDone(TrxEntryNo: Integer)
    var
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
    begin
        EFTTransactionAsyncRequest.LockTable;
        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        EFTTransactionAsyncRequest.Done := true;
        EFTTransactionAsyncRequest.Modify;
    end;

    procedure MarkRequestAsAbortAttempted(TrxEntryNo: Integer)
    var
        EFTTransactionAsyncRequest: Record "EFT Transaction Async Request";
    begin
        EFTTransactionAsyncRequest.LockTable;
        EFTTransactionAsyncRequest.Get(TrxEntryNo);
        EFTTransactionAsyncRequest."Abort Requested" := true;
        EFTTransactionAsyncRequest.Modify;
    end;

    local procedure "// Response"()
    begin
    end;

    procedure CreateResponseRecord(TrxEntryNo: Integer;Response: Text;ErrorMessage: Text;Error: Boolean)
    var
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
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

    procedure TryGetResponseRecord(TrxEntryNo: Integer;var EFTTransactionAsyncResponse: Record "EFT Transaction Async Response")
    begin
        EFTTransactionAsyncResponse.LockTable;
        EFTTransactionAsyncResponse.SetAutoCalcFields(Response);
        EFTTransactionAsyncResponse.Get(TrxEntryNo);
    end;
}

