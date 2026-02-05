codeunit 6184660 "NPR NpCs Del.CollectDoc OnSale"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        NpCsPOSSessionMgt: Codeunit "NPR NpCs POSSession Mgt.";
    begin
        NpCsPOSSessionMgt.DeliverCollectDoc(Rec);
    end;
}