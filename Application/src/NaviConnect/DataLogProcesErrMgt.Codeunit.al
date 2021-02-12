codeunit 6059897 "NPR Data Log Proces. Err. Mgt."
{
    TableNo = "NPR Data Log Processing Entry";

    trigger OnRun()
    begin
        RegisterLastErrorMessage(Rec);
        RunFailureCodeunit(Rec);
    end;

    local procedure RegisterLastErrorMessage(var DataLogProcessingEntry: Record "NPR Data Log Processing Entry")
    var
        LastErrorText: Text;
        OutStr: OutStream;
    begin
        LastErrorText := GetLastErrorText;
        ClearLastError;

        if LastErrorText = '' then
            exit;

        DataLogProcessingEntry.Find;
        Clear(DataLogProcessingEntry."Error Message");
        DataLogProcessingEntry."Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(LastErrorText);
        DataLogProcessingEntry."Processing Completed at" := CurrentDateTime;
        DataLogProcessingEntry.Modify(true);
        Commit;
    end;

    local procedure RunFailureCodeunit(var DataLogProcessingEntry: Record "NPR Data Log Processing Entry")
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        DataLogRecord: Record "NPR Data Log Record";
    begin
        if not DataLogSubscriber.Get(DataLogProcessingEntry."Subscriber Code", DataLogProcessingEntry."Table Number", '') then
            exit;

        if DataLogSubscriber."Failure Codeunit ID" <= 0 then
            exit;

        if not DataLogRecord.Get(DataLogProcessingEntry."Data Log Entry No.") then
            exit;

        Commit;
        CODEUNIT.Run(DataLogSubscriber."Failure Codeunit ID", DataLogRecord);
    end;
}