codeunit 6150951 "NPR Top 10 Salespersons BT"
{
    Access = Internal;
    trigger OnRun()
    begin
        Execute();
    end;

    local procedure Execute()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        Inserted: Boolean;
        EndDate: Date;
        StartDate: Date;
        MaximumCashReturnsale: Decimal;
        SalesLCY: Decimal;
        StartNo: Integer;
        Result: Dictionary of [Text, Text];
    begin
        if not Evaluate(StartDate, Page.GetBackgroundParameters().Get('StartDate')) then
            Error('Could not parse parameter StartDate');
        if not Evaluate(EndDate, Page.GetBackgroundParameters().Get('EndDate')) then
            Error('Could not parse parameter EndDate');

        StartNo := 1;
        SalespersonPurchaser.SetFilter("Date Filter", '%1..%2', StartDate, Enddate);
        if SalespersonPurchaser.FindSet() then
            repeat
                SalespersonPurchaser.NPRGetVESalesQty(MaximumCashReturnsale);
                if MaximumCashReturnsale <> 0 then begin
                    SalespersonPurchaser.NPRGetVESalesLCY(SalesLCY);
                    TempSalespersonPurchaser.Init();
                    TempSalespersonPurchaser.TransferFields(SalespersonPurchaser);
                    TempSalespersonPurchaser."NPR Maximum Cash Returnsale" := MaximumCashReturnsale;
                    TempSalespersonPurchaser."NPR Sales (LCY)" := SalesLCY;
                    TempSalespersonPurchaser.Insert();
                    Clear(SalesLCY);
                    Clear(MaximumCashReturnsale);
                    StartNo += 1;
                    Inserted := true;
                end;
            until (SalespersonPurchaser.Next() = 0) or (StartNo > 10);

        StartNo := 1;
        TempSalespersonPurchaser.SetCurrentKey("NPR Sales (LCY)");
        TempSalespersonPurchaser.Ascending(false);
        if TempSalespersonPurchaser.FindSet() then
            repeat
                Result.Add('Code ' + Format(StartNo), TempSalespersonPurchaser.Code);
                Result.Add('Name ' + Format(StartNo), TempSalespersonPurchaser.Name);
                Result.Add('MaximumCashReturnsale ' + Format(StartNo), Format(TempSalespersonPurchaser."NPR Maximum Cash Returnsale"));
                Result.Add('SalesLCY ' + Format(StartNo), Format(TempSalespersonPurchaser."NPR Sales (LCY)"));
                StartNo += 1;
            until TempSalespersonPurchaser.Next() = 0;

        if Inserted then begin
            Result.Add('Count', Format(StartNo - 1));
            Page.SetBackgroundTaskResult(Result);
        end;
    end;
}