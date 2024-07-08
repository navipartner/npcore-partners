codeunit 6184755 "NPR TM DeferCueTaskWorker"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        DeferCue: Record "NPR TM DeferralCue";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        Result: Dictionary of [Text, Text];
    begin
        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::UNRESOLVED);
        Result.Add(Format(DeferCue.FieldNo(UnresolvedCount)), Format(DeferRevenueRequest.Count(), 0, 9));

        DeferRevenueRequest.SetFilter(Status, '=%1|=%2|=%3', DeferRevenueRequest.Status::WAITING, DeferRevenueRequest.Status::REGISTERED, DeferRevenueRequest.Status::PENDING_DEFERRAL);
        Result.Add(Format(DeferCue.FieldNo(PendingDeferralCount)), Format(DeferRevenueRequest.Count(), 0, 9));

        Page.SetBackgroundTaskResult(Result);
    end;
}