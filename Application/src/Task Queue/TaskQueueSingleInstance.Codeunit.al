codeunit 6059910 "NPR Task Queue: SingleInstance"
{
    Access = Internal;
    // TQ1.29/JDH /20161101 CASE 242044 Used to get the current log entry no for other tasks that wants to write to the log

    SingleInstance = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NP Retail. We are now using Job Queue instead.';
    ObsoleteTag = '20';

    trigger OnRun()
    begin
    end;

    var
        CurrentLogEntryNo: Integer;

    procedure SetCurrentLogEntryNo(LogEntryNo: Integer)
    begin
        CurrentLogEntryNo := LogEntryNo;
    end;

    procedure GetCurrentLogEntryNo(): Integer
    begin
        exit(CurrentLogEntryNo);
    end;
}

