codeunit 6014696 "NPR Activities Backgrd Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        RetailSalesCue: Record "NPR Retail Sales Cue";
        Result: Dictionary of [Text, Text];
    begin
        if not RetailSalesCue.Get() then
            exit;

        RetailSalesCue.SetRange("Date Filter", Today());
        RetailSalesCue.SetActionableImportEntryTypeFilter();
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        RetailSalesCue.CalcFields("Import Pending", "Task List", "Daily Sales Orders", "Sales Orders", "Shipped Sales Orders", "Sales Return Orders",
                                    "Pending Inc. Documents", "Processed Error Tasks", "Failed Webshop Payments", "Sales Quotes", "Magento Orders",
                                    "Daily Sales Invoices", "Tasks Unprocessed", "Posted Sales Invoices", "Failed imports", "Purchase Order List", "Failed Ecom Sales Orders", "Daily Ecom Sales Orders");
#else
        RetailSalesCue.CalcFields("Import Pending", "Task List", "Daily Sales Orders", "Sales Orders", "Shipped Sales Orders", "Sales Return Orders",
                                    "Pending Inc. Documents", "Processed Error Tasks", "Failed Webshop Payments", "Sales Quotes", "Magento Orders",
                                    "Daily Sales Invoices", "Tasks Unprocessed", "Posted Sales Invoices", "Failed imports", "Purchase Order List");
#endif
        Result.Add(Format(RetailSalesCue.FieldNo("Import Pending")), Format(RetailSalesCue."Import Pending", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Task List")), Format(RetailSalesCue."Task List", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Daily Sales Orders")), Format(RetailSalesCue."Daily Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Sales Orders")), Format(RetailSalesCue."Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Shipped Sales Orders")), Format(RetailSalesCue."Shipped Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Sales Return Orders")), Format(RetailSalesCue."Sales Return Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Pending Inc. Documents")), Format(RetailSalesCue."Pending Inc. Documents", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Processed Error Tasks")), Format(RetailSalesCue."Processed Error Tasks", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Failed Webshop Payments")), Format(RetailSalesCue."Failed Webshop Payments", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Sales Quotes")), Format(RetailSalesCue."Sales Quotes", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Magento Orders")), Format(RetailSalesCue."Magento Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Daily Sales Invoices")), Format(RetailSalesCue."Daily Sales Invoices", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Tasks Unprocessed")), Format(RetailSalesCue."Tasks Unprocessed", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Posted Sales Invoices")), Format(RetailSalesCue."Posted Sales Invoices", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Failed imports")), Format(RetailSalesCue."Failed imports", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Purchase Order List")), Format(RetailSalesCue."Purchase Order List", 0, 9));
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        Result.Add(Format(RetailSalesCue.FieldNo("Failed Ecom Sales Orders")), Format(RetailSalesCue."Failed Ecom Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Daily Ecom Sales Orders")), Format(RetailSalesCue."Daily Ecom Sales Orders", 0, 9));
#endif
        Page.SetBackgroundTaskResult(Result);
    end;
}
