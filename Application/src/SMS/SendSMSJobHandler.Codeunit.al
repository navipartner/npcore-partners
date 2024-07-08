codeunit 6014469 "NPR Send SMS Job Handler"
{
    Access = Internal;
    trigger OnRun()
    var
        MessageLog: Record "NPR SMS Log";
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SelectLatestVersion();
        MessageLog.LockTable();
        MessageLog.SetRange(Status, MessageLog.Status::Pending);
        MessageLog.SetFilter("Send on Date Time", '<=%1', CurrentDateTime);
        if MessageLog.FindSet() then
            repeat
                Commit();
                if not SMSImplementation.DiscardOldMessages(MessageLog) then
                    SMSImplementation.SendQueuedSMS(MessageLog);
            until MessageLog.Next() = 0;
    end;
}
