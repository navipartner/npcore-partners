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
        ClickCollect: Codeunit "NPR Click & Collect";
    begin
        if not CollectInStoreCue.Get() then
            exit;

        CollectInStoreCue.CalcFields("CiS Orders - Pending", "CiS Orders - Confirmed", "CiS Orders - Finished");
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Pending")), Format(CollectInStoreCue."CiS Orders - Pending", 0, 9));
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Confirmed")), Format(CollectInStoreCue."CiS Orders - Confirmed", 0, 9));
        Result.Add(Format(CollectInStoreCue.FieldNo("CiS Orders - Finished")), Format(CollectInStoreCue."CiS Orders - Finished", 0, 9));
        ClickCollect.OnBackgroundCalculateNpCsActivities(CollectInStoreCue, Result);

        Page.SetBackgroundTaskResult(Result);
    end;
}