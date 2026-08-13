codeunit 85353 "NPR DE ZRep Blocking Handler"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _InjectWriteConflict: Boolean;
        _InjectionCount: Integer;

    internal procedure SetInjectWriteConflict(InjectWriteConflict: Boolean)
    begin
        _InjectWriteConflict := InjectWriteConflict;
        _InjectionCount := 0;
    end;

    internal procedure GetInjectionCount(): Integer
    begin
        exit(_InjectionCount);
    end;

    /// <summary>
    /// Makes every write to a DSFinV-K closing row fail.
    /// This stands in for the production failure: the "NPR DE Fiskaly DSFINVK Job" holds an
    /// UPDLOCK on the row while it talks to Fiskaly, so the POS session waits out the SQL
    /// lock timeout (~30 s in the captured profile) and the write then throws. The trigger
    /// differs, the effect is identical - the write inside
    /// "NPR DE Audit Mgt.".SetDSFINVKErrorMsg raises an error that escapes the DE audit
    /// event subscriber and aborts whatever the POS was doing.
    /// Note a same-session rowversion bump is NOT usable here: BC's optimistic concurrency
    /// only reports conflicts caused by *other* sessions, so such a write still succeeds.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"NPR DSFINVK Closing", 'OnBeforeModifyEvent', '', false, false)]
    local procedure FailClosingWrite(var Rec: Record "NPR DSFINVK Closing"; RunTrigger: Boolean)
    var
        SimulatedLockErr: Label 'The DSFINVK Closing table cannot be locked because another session already has a lock on it. Simulated by test.', Locked = true;
    begin
        if not _InjectWriteConflict then
            exit;
        if Rec.IsTemporary() then
            exit;

        _InjectionCount += 1;
        Error(SimulatedLockErr);
    end;
}
