codeunit 6059928 "NPR Retail Top 10 Items BT"
{
    Access = Internal;
    trigger OnRun()
    begin
        Execute();
    end;

    local procedure Execute()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        Query1: Query "NPR Retail Top 10 ItemsByQty.";
        EndDate: Date;
        StartDate: Date;
        i: Integer;
        Result: Dictionary of [Text, Text];
    begin
        if not Evaluate(StartDate, Page.GetBackgroundParameters().Get('StartDate')) then
            Error('Could not parse parameter StartDate');
        if not Evaluate(EndDate, Page.GetBackgroundParameters().Get('EndDate')) then
            Error('Could not parse parameter EndDate');

        Query1.SetFilter(Posting_Date, '%1..%2', StartDate, EndDate);
        Query1.SetFilter(Item_Ledger_Entry_Type, 'Sale');
        Query1.Open();
        i := 1;
        while Query1.Read() do begin
            if Item.Get(Query1.Item_No) then begin
                TempItem.TransferFields(Item);
                TempItem.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
                TempItem.CalcFields("Sales (Qty.)");
                TempItem."Low-Level Code" := Round(TempItem."Sales (Qty.)", 0.01) * 100;
                Result.Add('No ' + Format(I), TempItem."No.");
                Result.Add('Description ' + Format(I), TempItem.Description);
                Result.Add('LowLevelCode ' + Format(I), Format(TempItem."Low-Level Code"));
                i += 1;
            end;
        end;
        Query1.Close();
        Result.Add('Count', Format(I - 1));
        Page.SetBackgroundTaskResult(Result);
    end;
}
