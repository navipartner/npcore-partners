codeunit 6059771 "NPR Order Cue Backgrd Task"
{
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        RetailOrderCue: Record "NPR Retail Order Cue";
        Result: Dictionary of [Text, Text];
    begin
        if not RetailOrderCue.Get() then
            exit;

        RetailOrderCue.CalcFields("Open Sales Orders", "Open Credit Memos", "Open Web Sales Orders", "Posted Sales Invoices",
                                "Posted Credit Memos", "Posted Web Sales Orders", "Open Purchase Orders", "Posted Purchase Orders");

        Result.Add(Format(RetailOrderCue.FieldNo("Open Sales Orders")), Format(RetailOrderCue."Open Sales Orders", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Open Credit Memos")), Format(RetailOrderCue."Open Credit Memos", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Open Web Sales Orders")), Format(RetailOrderCue."Open Web Sales Orders", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Posted Sales Invoices")), Format(RetailOrderCue."Posted Sales Invoices", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Posted Credit Memos")), Format(RetailOrderCue."Posted Credit Memos", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Posted Web Sales Orders")), Format(RetailOrderCue."Posted Web Sales Orders", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Open Purchase Orders")), Format(RetailOrderCue."Open Purchase Orders", 0, 9));
        Result.Add(Format(RetailOrderCue.FieldNo("Posted Purchase Orders")), Format(RetailOrderCue."Posted Purchase Orders", 0, 9));

        Page.SetBackgroundTaskResult(Result);
    end;
}