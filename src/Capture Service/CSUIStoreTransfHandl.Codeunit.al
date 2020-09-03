codeunit 6151398 "NPR CS UI Store Transf. Handl."
{
    // NPR5.50/CLVA/20190404 CASE 332844 Object created - NP Capture Service

    TableNo = "NPR Stock-Take Worksheet";

    trigger OnRun()
    var
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
    begin
        StockTakeMgr.TransferToItemInvJnl(Rec, 0, WorkDate);
    end;
}

