xmlport 6014662 "NPR Import StockT.Wrksht.Line"
{
    // CASE213313/TS/20151115  CASE 213313 Object Created
    // NPR5.48/JDH /20181108 CASE 334163 Adding missing Captions
    // NPR5.50/BHR /20190508 CASE 348372 Validate barcode

    Caption = 'Import StockTake Wrksht. Line';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = '|';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement(tmpstocktakeworksheetline; "NPR Stock-Take Worksheet Line")
            {
                XmlName = 'tmpStockTakeWorksheetLine';
                UseTemporary = true;
                textelement(shelf)
                {
                }
                textelement(scanned_item_code)
                {
                }
                textelement(quantity)
                {
                }
                textelement(empty01)
                {
                }
                textelement(empty02)
                {
                }
                textelement(empty03)
                {
                    MinOccurs = Zero;
                }

                trigger OnAfterInitRecord()
                begin
                    tmpStockTakeWorksheetLine."Stock-Take Config Code" := JournalCode;
                    tmpStockTakeWorksheetLine."Worksheet Name" := BatchName;
                    LineNo += 1000;
                    tmpStockTakeWorksheetLine."Line No." := LineNo;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if (scanned_item_code <> '') and (quantity <> '') then begin
                        //-NPR5.50
                        //tmpStockTakeWorksheetLine.Barcode := scanned_item_code;
                        tmpStockTakeWorksheetLine.Validate(Barcode, scanned_item_code);
                        //+NPR5.50
                        tmpStockTakeWorksheetLine."Shelf  No." := shelf;
                        Evaluate(tmpStockTakeWorksheetLine."Qty. (Counted)", quantity);
                    end;
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Import StockTake Wrksht. Line';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        SessionName := Format(CurrentDateTime(), 0, 9);
    end;

    trigger OnPostXmlPort()
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
    begin
        if (tmpStockTakeWorksheetLine.FindSet()) then begin
            repeat
                StockTakeWorksheetLine.TransferFields(tmpStockTakeWorksheetLine, true);
                StockTakeWorksheetLine."Session Name" := SessionName;
                StockTakeWorksheetLine.Insert();
            until (tmpStockTakeWorksheetLine.Next() = 0);
        end;
    end;

    trigger OnPreXmlPort()
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
    begin
        JournalCode := tmpStockTakeWorksheetLine.GetFilter("Stock-Take Config Code");
        BatchName := tmpStockTakeWorksheetLine.GetFilter("Worksheet Name");

        StockTakeWorksheetLine.SetRange("Stock-Take Config Code", JournalCode);
        StockTakeWorksheetLine.SetRange("Worksheet Name", BatchName);
        LineNo := 0;
        if (StockTakeWorksheetLine.FindLast()) then
            LineNo := StockTakeWorksheetLine."Line No.";
    end;

    var
        JournalCode: Code[20];
        BatchName: Code[20];
        LineNo: Integer;
        SessionName: Text[40];
}

