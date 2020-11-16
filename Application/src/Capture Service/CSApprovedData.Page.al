page 6151396 "NPR CS Approved Data"
{
    // NPR5.54/CLVA/20200218  CASE 391080 Object created

    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR CS Approved Data";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Qty."; "Qty.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CSStockTakes.Get(localStockTakeId);

        CSStockTakesData.SetRange(Stock_Take_Id, CSStockTakes."Stock-Take Id");
        CSStockTakesData.SetRange(Stock_Take_Config_Code, CSStockTakes."Journal Template Name");
        CSStockTakesData.SetRange(Worksheet_Name, CSStockTakes."Journal Batch Name");
        CSStockTakesData.Open;
        while CSStockTakesData.Read do begin
            NextRowNo := NextRowNo + 1;
            "Entry No." := NextRowNo;
            "Item No." := CSStockTakesData.ItemNo;
            "Variant Code" := CSStockTakesData.Variant_Code;
            "Qty." := CSStockTakesData.Count_;
            Insert;
        end;
        CSStockTakesData.Close;

        FindFirst;
    end;

    var
        CSStockTakesData: Query "NPR CS Stock-Takes Data";
        localStockTakeId: Guid;
        NextRowNo: Integer;
        CSStockTakes: Record "NPR CS Stock-Takes";

    procedure SetParameters(globalStockTakeId: Guid)
    begin
        localStockTakeId := globalStockTakeId;
    end;
}

