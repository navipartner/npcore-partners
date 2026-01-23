#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248678 "NPR Apply Retention Policy"
{
    Access = Internal;
    TableNo = "NPR Retention Policy";

    trigger OnRun();
    var
        IRetentionPolicy: Interface "NPR IRetention Policy";
    begin
        // Ensure the retention policy for a table is not executed simultaneously by multiple sessions
        Rec.ReadIsolation := IsolationLevel::UpdLock;
        Rec.Get(Rec."Table Id");

        IRetentionPolicy := Rec.Implementation;
        IRetentionPolicy.DeleteExpiredRecords(Rec, CurrentDateTime());
    end;
}
#endif