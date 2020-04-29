xmlport 6014663 "Import Multi-StockTake Wrksht."
{
    // NPR4.18/JDH/20160209 CASE 223529 Created by TSA - found when releasing version 4.18

    Caption = 'Import Multi-StockTake Wrksht.';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = ',';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement(tmpstocktakeworksheetline;"Stock-Take Worksheet Line")
            {
                XmlName = 'tmpStockTakeWorksheetLine';
                UseTemporary = true;
                textelement(config_code)
                {
                }
                textelement(worksheet_name)
                {
                }
                textelement(scanned_item_code)
                {
                }
                textelement(quantity)
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    tmpStockTakeWorksheetLine."Stock-Take Config Code" := config_code;
                    tmpStockTakeWorksheetLine."Worksheet Name" := worksheet_name;
                    LineNo += 1000;
                    tmpStockTakeWorksheetLine."Line No." := LineNo;

                    if  (scanned_item_code <> '') and (quantity <> '') then begin
                      tmpStockTakeWorksheetLine.Barcode := scanned_item_code;
                      Evaluate (tmpStockTakeWorksheetLine."Qty. (Counted)", quantity);
                    end;
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Import Multi-StockTake Wrksht.';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin

        SessionName := Format (CurrentDateTime(), 0, 9);
    end;

    trigger OnPostXmlPort()
    var
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        StockTakeWorksheetLine2: Record "Stock-Take Worksheet Line";
    begin

        if (tmpStockTakeWorksheetLine.FindSet ()) then begin
          repeat
            if ((tmpStockTakeWorksheetLine."Stock-Take Config Code" <> PrevConfigCode) or
                (tmpStockTakeWorksheetLine."Worksheet Name" <> PrevWorksheetName)) then begin
              StockTakeWorksheetLine.SetRange ("Stock-Take Config Code", tmpStockTakeWorksheetLine."Stock-Take Config Code");
              StockTakeWorksheetLine.SetRange ("Worksheet Name", tmpStockTakeWorksheetLine."Worksheet Name");
              LineNo := 0;
              if (StockTakeWorksheetLine.FindLast ()) then
                LineNo := StockTakeWorksheetLine."Line No.";
            end;
            LineNo += 1000;

            if (not StockTakeWorksheet.Get (tmpStockTakeWorksheetLine."Stock-Take Config Code", tmpStockTakeWorksheetLine."Worksheet Name")) then begin
              StockTakeWorksheet.Init;
              StockTakeWorksheet.Validate ("Stock-Take Config Code", tmpStockTakeWorksheetLine."Stock-Take Config Code");
              StockTakeWorksheet.Validate (Name, tmpStockTakeWorksheetLine."Worksheet Name");
              StockTakeWorksheet.Insert (true);
            end;

            StockTakeWorksheetLine2.TransferFields (tmpStockTakeWorksheetLine, true);
            StockTakeWorksheetLine2."Line No." := LineNo;
            StockTakeWorksheetLine2."Session Name" := SessionName;
            StockTakeWorksheetLine2.Insert ();

            PrevConfigCode := tmpStockTakeWorksheetLine."Stock-Take Config Code";
            PrevWorksheetName := tmpStockTakeWorksheetLine."Worksheet Name";

          until (tmpStockTakeWorksheetLine.Next () = 0);
        end;
    end;

    trigger OnPreXmlPort()
    begin

        LineNo := 0;
    end;

    var
        PrevConfigCode: Code[20];
        PrevWorksheetName: Code[20];
        LineNo: Integer;
        SessionName: Text[40];
}

