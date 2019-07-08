codeunit 6151397 "CS UI WH Counting Handling"
{
    // NPR5.50/CLVA/20190114 CASE 332844 Object created - NP Capture Service
    // NPR5.50/CLVA/20190404 CASE 350740 Added automated transfer

    TableNo = "Stock-Take Worksheet";

    trigger OnRun()
    var
        CSStockTakesData: Record "CS Stock-Takes Data";
        StockTakeMgr: Codeunit "Stock-Take Manager";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
        ItemCrossReference: Record "Item Cross Reference";
        CSHelperFunctions: Codeunit "CS Helper Functions";
    begin
        CSStockTakesData.SetRange("Transferred To Worksheet",false);
        CSStockTakesData.SetRange("Stock-Take Config Code","Stock-Take Config Code");
        CSStockTakesData.SetRange("Worksheet Name",Name);
        if CSStockTakesData.FindSet then begin

          //StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

          LineNo := 0;
          Clear(NewStockTakeWorksheetLine);
          NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", "Stock-Take Config Code");
          NewStockTakeWorksheetLine.SetRange("Worksheet Name", Name);
          if NewStockTakeWorksheetLine.FindLast then
            LineNo := NewStockTakeWorksheetLine."Line No." + 1000
          else
            LineNo := 1000;

          repeat

            StockTakeWorksheetLine.Init;
            StockTakeWorksheetLine."Stock-Take Config Code" := "Stock-Take Config Code";
            StockTakeWorksheetLine."Worksheet Name" := Name;
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

          StockTakeMgr.ImportPostHandler(Rec);

        end;

        Validate(Status,Status::READY_TO_TRANSFER);
        //-NPR5.50 [350740]
        //MODIFY(TRUE);
        if Modify(true) then begin
          Commit;
          StockTakeMgr.TransferToItemInvJnl(Rec, 0, WorkDate);
        end;
        //+NPR5.50 [350740]
    end;
}

