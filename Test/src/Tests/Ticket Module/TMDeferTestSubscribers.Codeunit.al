/// <summary>
/// Changes or refuses a write to a deferral request from inside the deferral batch, so a test can see how the batch
/// handles a request that another run changed, and what a failing token leaves behind.
/// </summary>
codeunit 85631 "NPR TM Defer Test Subscribers"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _FlipOnModify: Boolean;
        _Flipped: Boolean;
        _TriggerEntryNo: Integer;
        _TargetEntryNo: Integer;
        _SentinelDocumentNo: Code[20];
        _ErrorOnModify: Boolean;
        _ErrorEntryNo: Integer;
        _ModifyRefusedErr: Label 'The test subscriber refuses to modify this deferral request.', Locked = true;

    internal procedure SetFlipOnModify(TriggerEntryNo: Integer; TargetEntryNo: Integer; SentinelDocumentNo: Code[20])
    begin
        _FlipOnModify := true;
        _TriggerEntryNo := TriggerEntryNo;
        _TargetEntryNo := TargetEntryNo;
        _SentinelDocumentNo := SentinelDocumentNo;
    end;

    internal procedure SetErrorOnModify(ErrorEntryNo: Integer)
    begin
        _ErrorOnModify := true;
        _ErrorEntryNo := ErrorEntryNo;
    end;

    internal procedure ErrorText(): Text
    begin
        exit(_ModifyRefusedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR TM DeferRevenueRequest", 'OnAfterModifyEvent', '', false, false)]
    local procedure FlipTargetAfterTriggerModify(var Rec: Record "NPR TM DeferRevenueRequest"; var xRec: Record "NPR TM DeferRevenueRequest"; RunTrigger: Boolean)
    var
        TargetRequest: Record "NPR TM DeferRevenueRequest";
    begin
        if Rec.IsTemporary() then
            exit;
        if ((not _FlipOnModify) or _Flipped) then
            exit;
        if (Rec.TicketAccessEntryNo <> _TriggerEntryNo) then
            exit;

        // Flips once only: a later modify of the trigger request must not change the target again.
        _Flipped := true;
        TargetRequest.Get(_TargetEntryNo);
        TargetRequest.Status := TargetRequest.Status::DEFERRED_FORCED;
        TargetRequest.DeferralDocumentNo := _SentinelDocumentNo;
        TargetRequest.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR TM DeferRevenueRequest", 'OnBeforeModifyEvent', '', false, false)]
    local procedure RefuseModify(var Rec: Record "NPR TM DeferRevenueRequest"; var xRec: Record "NPR TM DeferRevenueRequest"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if (not _ErrorOnModify) then
            exit;
        if (Rec.TicketAccessEntryNo <> _ErrorEntryNo) then
            exit;

        Error(_ModifyRefusedErr);
    end;
}
