codeunit 6151398 "CS UI Store Transfer Handling"
{
    // NPR5.50/CLVA/20190404 CASE 332844 Object created - NP Capture Service

    TableNo = "Stock-Take Worksheet";

    trigger OnRun()
    var
        StockTakeMgr: Codeunit "Stock-Take Manager";
    begin
        StockTakeMgr.TransferToItemInvJnl(Rec, 0, WorkDate);
    end;
}

