codeunit 6184660 "NPR NpCs Del.CollectDoc OnSale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        NpCsPOSSessionMgt: Codeunit "NPR NpCs POSSession Mgt.";
    begin
        NpCsPOSSessionMgt.DeliverCollectDoc(Rec);
    end;
}