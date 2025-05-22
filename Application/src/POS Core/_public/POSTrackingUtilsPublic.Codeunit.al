codeunit 6248452 "NPR POS Tracking Utils Public"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure SerialNumberCanBeUsedByItem_OnAfterFilterILE(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure LotCanBeUsedByItem_OnAfterFilterILE(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}