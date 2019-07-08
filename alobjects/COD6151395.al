codeunit 6151395 "CS UI Stock-Take Handling Rfid"
{
    // NPR5.50/JAKUBV/20190603  CASE 344466 Transport NPR5.50 - 3 June 2019

    TableNo = "CS Stock-Take Handling Rfid";

    trigger OnRun()
    var
        CSStockTakeHandlingRfid: Record "CS Stock-Take Handling Rfid";
        RequestData: Text;
        IStream: InStream;
        OStream: OutStream;
        Values: DotNet Array;
        CommaString: DotNet String;
        Separator: DotNet String;
        Value: Text;
        LineNo: Integer;
        ItemCrossReference: Record "Item Cross Reference";
        StockTakeMgr: Codeunit "Stock-Take Manager";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        CSStockTakes: Record "CS Stock-Takes";
    begin
        CSStockTakeHandlingRfid.SetRange(Handled,false);
        CSStockTakeHandlingRfid.SetRange("Batch Id","Batch Id");
        if CSStockTakeHandlingRfid.FindSet then begin

          CSStockTakeHandlingRfid."Posting Started" := CurrentDateTime;
          StockTakeWorksheet.Get(CSStockTakeHandlingRfid."Stock-Take Config Code",CSStockTakeHandlingRfid."Worksheet Name");
          StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

          repeat

            CSStockTakeHandlingRfid.CalcFields("Request Data");

            "Request Data".CreateInStream(IStream);
            IStream.Read(RequestData,MaxStrLen(RequestData));

            CommaString := RequestData;
            Separator := ',';
            Values := CommaString.Split(Separator.ToCharArray());

            LineNo := 0;
            Clear(NewStockTakeWorksheetLine);
            NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
            NewStockTakeWorksheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
            if NewStockTakeWorksheetLine.FindLast then
              LineNo := NewStockTakeWorksheetLine."Line No." + 1000
            else
              LineNo := 1000;

            foreach Value in Values do begin
              if Value <> '' then begin
                if StrLen(Value) <= MaxStrLen(StockTakeWorksheetLine.Barcode) then begin

                  StockTakeWorksheetLine.Init;
                  StockTakeWorksheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
                  StockTakeWorksheetLine."Worksheet Name" := StockTakeWorksheet.Name;
                  StockTakeWorksheetLine."Line No." := LineNo;

                  if StrLen(Value) > MaxStrLen(ItemCrossReference."Cross-Reference No.") then
                    StockTakeWorksheetLine.Validate(Barcode, CopyStr(Value,5))
                  else
                    StockTakeWorksheetLine.Validate(Barcode, Value);

                  StockTakeWorksheetLine."Qty. (Counted)" := 1;
                  StockTakeWorksheetLine."Session Name" := "Device Id";
                  StockTakeWorksheetLine."Date of Inventory" := WorkDate;
                  if StockTakeWorksheetLine.Insert(true) then
                    LineNo := StockTakeWorksheetLine."Line No." + 1000

                end;
              end;
            end;

            CSStockTakeHandlingRfid."Posting Ended" := CurrentDateTime;
            CSStockTakeHandlingRfid.Handled := true;
            CSStockTakeHandlingRfid.Modify(false);

          until CSStockTakeHandlingRfid.Next = 0;

          StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

          if CSStockTakes.Get(CSStockTakeHandlingRfid."Batch Id") then begin
            case StockTakeWorksheet.Name of
              'SALESFLOOR' : begin
                              CSStockTakes."Salesfloor Closed" := CurrentDateTime;
                              CSStockTakes."Salesfloor Closed By" := UserId;
                              CSStockTakes.Modify(true);
                             end;
              'STOCKROOM' :  begin
                              CSStockTakes."Stockroom Closed" := CurrentDateTime;
                              CSStockTakes."Stockroom Closed By" := UserId;
                              CSStockTakes.Modify(true);
                             end;
            end;
          end;
        end;
    end;

    local procedure TransferDataLine(var CSStockTakeCounting: Record "CS Stock-Take Handling";StockTakeWorksheet: Record "Stock-Take Worksheet"): Boolean
    var
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
    begin
        Clear(NewStockTakeWorksheetLine);
        NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        NewStockTakeWorksheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
        LineNo := 0;
        if NewStockTakeWorksheetLine.FindLast then
          LineNo := NewStockTakeWorksheetLine."Line No." + 1000
        else
          LineNo := 1000;

        Clear(StockTakeWorkSheetLine);
        StockTakeWorkSheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
        StockTakeWorkSheetLine."Worksheet Name" := StockTakeWorksheet.Name;
        StockTakeWorkSheetLine."Line No." := LineNo;
        StockTakeWorkSheetLine.Validate(Barcode, CSStockTakeCounting.Barcode);
        StockTakeWorkSheetLine."Shelf  No." := CSStockTakeCounting."Shelf  No.";
        StockTakeWorkSheetLine."Qty. (Counted)" := CSStockTakeCounting.Qty;
        StockTakeWorkSheetLine."Session Name" := CSStockTakeCounting.Id;
        StockTakeWorkSheetLine."Date of Inventory" := WorkDate;
        StockTakeWorkSheetLine.Insert(true);

        exit(true);
    end;
}

