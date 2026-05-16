#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248678 "NPR Apply Retention Policy"
{
    Access = Internal;
    TableNo = "NPR Retention Policy";

    trigger OnRun();
    var
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        EmptyDateFormula: DateFormula;
        NoPeriodsDefinedErr: Label 'No retention periods are defined for table %1 %2.', Comment = '%1 = Table Id, %2 = Table Caption';
    begin
        // Ensure the retention policy for a table is not executed simultaneously by multiple sessions
        Rec.ReadIsolation := IsolationLevel::UpdLock;
        Rec.Get(Rec."Table Id");

        if Rec.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1") = EmptyDateFormula then begin
            Rec.CalcFields("Table Caption");
            Error(NoPeriodsDefinedErr, Rec."Table Id", Rec."Table Caption");
        end;

        IRetentionPolicy := Rec."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(Rec, CurrentDateTime());
    end;
}
#endif