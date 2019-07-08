codeunit 6151396 "CS UI Store Counting Handling"
{
    // NPR5.50/JAKUBV/20190603  CASE 332844 Transport NPR5.50 - 3 June 2019

    TableNo = "CS Stock-Takes";

    trigger OnRun()
    var
        CSStockTakesData: Record "CS Stock-Takes Data";
        StockTakeMgr: Codeunit "Stock-Take Manager";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
        ItemCrossReference: Record "Item Cross Reference";
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        CSStockTakesData.SetRange("Stock-Take Id","Stock-Take Id");
        CSStockTakesData.SetRange("Worksheet Name",'STOCKROOM');
        if CSStockTakesData.FindSet then begin

          StockTakeWorksheet.Get(Location,CSStockTakesData."Worksheet Name");
          //StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

          LineNo := 0;
          Clear(NewStockTakeWorksheetLine);
          NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          NewStockTakeWorksheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
          if NewStockTakeWorksheetLine.FindLast then
            LineNo := NewStockTakeWorksheetLine."Line No." + 1000
          else
            LineNo := 1000;

          repeat

            StockTakeWorksheetLine.Init;
            StockTakeWorksheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
            StockTakeWorksheetLine."Worksheet Name" := StockTakeWorksheet.Name;
            StockTakeWorksheetLine."Line No." := LineNo;

            if StrLen(CSStockTakesData."Tag Id") > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
              StockTakeWorksheetLine.Validate(Barcode, CopyStr(CSStockTakesData."Tag Id",5))
            else
              StockTakeWorksheetLine.Validate(Barcode, CSStockTakesData."Tag Id");

            StockTakeWorksheetLine."Qty. (Counted)" := 1;
            StockTakeWorksheetLine."Session Name" := CSStockTakesData."Created By";
            StockTakeWorksheetLine."Date of Inventory" := DT2Date(CSStockTakesData.Created);
            if StockTakeWorksheetLine.Insert(true) then begin
              LineNo := StockTakeWorksheetLine."Line No." + 1000;
              CSStockTakesData."Transferred To Worksheet" := true;
              CSStockTakesData.Modify(true);
            end;

          until CSStockTakesData.Next = 0;

          StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

        end;

        Clear(CSStockTakesData);
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        CSStockTakesData.SetRange("Stock-Take Id","Stock-Take Id");
        CSStockTakesData.SetRange("Worksheet Name",'SALESFLOOR');
        if CSStockTakesData.FindSet then begin

          StockTakeWorksheet.Get(Location,CSStockTakesData."Worksheet Name");
          //StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

          LineNo := 0;
          Clear(NewStockTakeWorksheetLine);
          NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          NewStockTakeWorksheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
          if NewStockTakeWorksheetLine.FindLast then
            LineNo := NewStockTakeWorksheetLine."Line No." + 1000
          else
            LineNo := 1000;

          repeat

            StockTakeWorksheetLine.Init;
            StockTakeWorksheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
            StockTakeWorksheetLine."Worksheet Name" := StockTakeWorksheet.Name;
            StockTakeWorksheetLine."Line No." := LineNo;

            if StrLen(CSStockTakesData."Tag Id") > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
              StockTakeWorksheetLine.Validate(Barcode, CopyStr(CSStockTakesData."Tag Id",5))
            else
              StockTakeWorksheetLine.Validate(Barcode, CSStockTakesData."Tag Id");

            StockTakeWorksheetLine."Qty. (Counted)" := 1;
            StockTakeWorksheetLine."Session Name" := CSStockTakesData."Created By";
            StockTakeWorksheetLine."Date of Inventory" := DT2Date(CSStockTakesData.Created);
            if StockTakeWorksheetLine.Insert(true) then begin
              LineNo := StockTakeWorksheetLine."Line No." + 1000;
              CSStockTakesData."Transferred To Worksheet" := true;
              CSStockTakesData.Modify(true);
            end;

          until CSStockTakesData.Next = 0;

          StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

        end;

        Commit;

        if ("Stockroom Closed" <> 0DT) and ("Salesfloor Closed" <> 0DT) then begin
          CSHelperFunctions.CreateRefillData("Stock-Take Id");
        end;
    end;
}

