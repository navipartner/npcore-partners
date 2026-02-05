codeunit 6151223 "NPR NpCs Store Stock Sync Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    trigger OnRun()
    var
        NpCsStoreStockDataMgt: Codeunit "NPR NpCs Store Stock Data Mgt.";
    begin
        NpCsStoreStockDataMgt.InitStoreStockItems();
    end;

    procedure ScheduleStockItemInitiation()
    begin
        TaskScheduler.CreateTask(CurrCodeunitId(), 0, true, CompanyName, CurrentDateTime);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Store Stock Sync Mgt.");
    end;
}
