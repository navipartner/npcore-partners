codeunit 6185128 "NPR Adyen Skip Post Check"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'OnBeforeCheckEntries', '', false, false)]
    local procedure OnBeforeCheckEntries(ReversalEntry: Record "Reversal Entry"; TableID: Integer; var SkipCheck: Boolean)
    begin
        if TableID in [Database::"G/L Entry", Database::"Bank Account Ledger Entry", Database::"Cust. Ledger Entry"] then
            SkipCheck := true;
    end;
}
