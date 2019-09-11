codeunit 6151397 "CS UI WH Counting Handling"
{
    // NPR5.50/CLVA/20190114 CASE 332844 Object created - NP Capture Service
    // NPR5.50/CLVA/20190404 CASE 350740 Added automated transfer
    // NPR5.51/CLVA/20190627 CASE 359375 Added ItemInvJnl posting option and re-create Stock-take worksheet

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
        StockTakeConfiguration: Record "Stock-Take Configuration";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        CurrStockTakeConfigCode: Code[10];
        CurrWorkSheetName: Code[10];
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.51
        case Status of
          Status::OPEN : begin
        //+NPR5.51
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
        //      //-NPR5.51 [359375]
        //      CSSetup.GET;
        //      StockTakeConfiguration.GET("Stock-Take Config Code");
        //      CurrStockTakeConfigCode := "Stock-Take Config Code";
        //      CurrWorkSheetName := Name;
        //      //+NPR5.51 [359375]
        //      COMMIT;
        //      //-NPR5.51 [359375]
        //      //StockTakeMgr.TransferToItemInvJnl(Rec, 0, WORKDATE);
        //      StockTakeMgr.TransferToItemInvJnl(Rec, StockTakeConfiguration."Transfer Action", WORKDATE);
        //      IF NOT StockTakeWorksheet.GET(CurrStockTakeConfigCode, CurrWorkSheetName) THEN BEGIN
        //        StockTakeWorksheet.INIT;
        //        StockTakeWorksheet."Stock-Take Config Code" := StockTakeConfiguration.Code;
        //        StockTakeWorksheet.Name := Name;
        //        StockTakeWorksheet.INSERT(TRUE);
        //      END;
        //      //+NPR5.51 [359375]
            end;
            //+NPR5.50 [350740]
          //-NPR5.51
          end;
          Status::READY_TO_TRANSFER : begin
        //    CSSetup.GET;
        //    StockTakeConfiguration.GET("Stock-Take Config Code");
        //    CurrStockTakeConfigCode := "Stock-Take Config Code";
        //    CurrWorkSheetName := Name;
        //    StockTakeMgr.TransferToItemInvJnl(Rec, StockTakeConfiguration."Transfer Action", WORKDATE);
        //    IF NOT StockTakeWorksheet.GET(CurrStockTakeConfigCode, CurrWorkSheetName) THEN BEGIN
        //      StockTakeWorksheet.INIT;
        //      StockTakeWorksheet."Stock-Take Config Code" := StockTakeConfiguration.Code;
        //      StockTakeWorksheet.Name := Name;
        //      StockTakeWorksheet.INSERT(TRUE);
        //    END;
          end;
        end;
          //+NPR5.51
    end;
}

