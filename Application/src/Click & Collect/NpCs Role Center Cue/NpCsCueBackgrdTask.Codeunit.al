codeunit 6184869 "NPR NpCs Cue Backgrd Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        CollectInStoreCue: Record "NPR NpCs Cue";
        Result: Dictionary of [Text, Text];
    begin
        if not CollectInStoreCue.Get() then
            exit;

        CollectInStoreCue.CalcFields("CiS Orders - Pending", "CiS Orders - Confirmed", "CiS Orders - Finished");
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Pending")), Format(CollectInStoreCue."CiS Orders - Pending", 0, 9));
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Confirmed")), Format(CollectInStoreCue."CiS Orders - Confirmed", 0, 9));
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Finished")), Format(CollectInStoreCue."CiS Orders - Finished", 0, 9));

#if not BC17
        CollectInStoreCue.CalcFields("Spfy CC Orders - Unprocessed");
        Result.Add(Format(CollectInStoreCue.FieldNo("Spfy CC Orders - Unprocessed")), Format(CollectInStoreCue."Spfy CC Orders - Unprocessed", 0, 9));
#endif

        Page.SetBackgroundTaskResult(Result);
    end;
}