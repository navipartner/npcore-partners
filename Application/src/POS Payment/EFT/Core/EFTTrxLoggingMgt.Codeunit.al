codeunit 6184505 "NPR EFT Trx Logging Mgt."
{
    Access = Internal;

    procedure WriteLogEntry(TrxEntryNo: Integer; Description: Text; LogContents: Text)
    var
        EFTTransactionLog: Record "NPR EFT Transaction Log";
        OutStream: OutStream;
    begin
        EFTTransactionLog.Init();
        EFTTransactionLog."Transaction Entry No." := TrxEntryNo;
        EFTTransactionLog.Description := CopyStr(Description, 1, MaxStrLen(EFTTransactionLog.Description));
        if LogContents <> '' then begin
            EFTTransactionLog.Log.CreateOutStream(OutStream);
            OutStream.Write(LogContents);
        end;
        EFTTransactionLog."Log Entry No." := 0; //autoinc
        EFTTransactionLog."Logged At" := CreateDateTime(Today, Time);
        EFTTransactionLog.Insert();
    end;
}

