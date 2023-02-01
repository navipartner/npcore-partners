codeunit 6059901 "NPR POS Post ILE Public Access"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateItemJournalLine(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line"; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;
}