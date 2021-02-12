codeunit 6151223 "NPR NpCs Store Stock Sync Mgt."
{
    trigger OnRun()
    var
        NpCsStoreStockDataMgt: Codeunit "NPR NpCs Store Stock Data Mgt.";
    begin
        NpCsStoreStockDataMgt.InitStoreStockItems();
    end;

    procedure ScheduleStockItemInitiation()
    begin
        TaskScheduler.CreateTask(CurrCodeunitId, 0, true, CompanyName, CurrentDateTime);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Store Stock Sync Mgt.");
    end;
}