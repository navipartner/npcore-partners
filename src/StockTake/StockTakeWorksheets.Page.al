page 6014662 "NPR Stock-Take Worksheets"
{
    // NPR4.16/TS/20150525  CASE 213313 Page Created
    // NPRX.xx/TSA/20160623 CASE 245258 Added some fields I think are useful
    // NPR5.49/TSA /20190318 CASE 348372 Added line counts statistics

    Caption = 'Stock-Take Worksheets';
    PageType = Worksheet;
    SourceTable = "NPR Stock-Take Worksheet";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Item Group Filter"; "Item Group Filter")
                {
                    ApplicationArea = All;
                }
                field("Vendor Code Filter"; "Vendor Code Filter")
                {
                    ApplicationArea = All;
                }
                field(Metrics; LineTypeCountText)
                {
                    ApplicationArea = All;
                    Caption = 'Metrics';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.49 [348372]
        CountWorksheetLines();
        //+NPR5.49 [348372]
    end;

    var
        LineTypeCountText: Text;

    local procedure CountWorksheetLines()
    var
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        WorksheetsCount: Integer;
        WorksheetLinesCount: Integer;
        ReadyCount: Integer;
        IgnoreCount: Integer;
        TransferCount: Integer;
    begin

        //-NPR5.49 [348372]
        StockTakeWorksheet.SetFilter("Stock-Take Config Code", '=%1', Rec."Stock-Take Config Code");
        WorksheetsCount := StockTakeWorksheet.Count();

        StockTakeWorksheetLine.SetFilter("Stock-Take Config Code", '=%1', Rec."Stock-Take Config Code");
        StockTakeWorksheetLine.SetFilter("Worksheet Name", '=%1', Rec.Name);
        WorksheetLinesCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::READY);
        ReadyCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::IGNORE);
        IgnoreCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::TRANSFERRED);
        TransferCount := StockTakeWorksheetLine.Count();

        LineTypeCountText := StrSubstNo('%2 [%3/%4/%5]', WorksheetsCount, WorksheetLinesCount, ReadyCount, IgnoreCount, TransferCount);
        //+NPR5.49 [348372]
    end;
}

