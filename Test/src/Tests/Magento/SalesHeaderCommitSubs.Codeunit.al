codeunit 85059 "NPR Sales Header Commit Subs."
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure CommitOnAfterOnInsert()
    begin
        Commit();
    end;
}