codeunit 6014696 "NPR Activities Backgrd Task"
{
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
        RetailSalesCue.CalcFields("Import Pending", "Task List", "Daily Sales Orders", "Sales Orders", "Shipped Sales Orders", "Sales Return Orders");

        Result.Add(Format(RetailSalesCue.FieldNo("Import Pending")), Format(RetailSalesCue."Import Pending", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Task List")), Format(RetailSalesCue."Task List", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Daily Sales Orders")), Format(RetailSalesCue."Daily Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Sales Orders")), Format(RetailSalesCue."Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Shipped Sales Orders")), Format(RetailSalesCue."Shipped Sales Orders", 0, 9));
        Result.Add(Format(RetailSalesCue.FieldNo("Sales Return Orders")), Format(RetailSalesCue."Sales Return Orders", 0, 9));

        Page.SetBackgroundTaskResult(Result);
    end;
}