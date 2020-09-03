page 6060051 "NPR Item Worksheet FactBox"
{
    // NPR4.19\BR\20160311  CASE 182391 Object Created
    // NPR5.22\BR\20160316  CASE 182391 added fields 500,510,520

    Caption = 'Item Worksheet FactBox';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Item Worksheet Line";

    layout
    {
        area(content)
        {
            field("Item No."; "Item No.")
            {
                ApplicationArea = All;
            }
            field("Existing Item No."; "Existing Item No.")
            {
                ApplicationArea = All;
            }
            field(Inventory; RecExItem.Inventory)
            {
                ApplicationArea = All;
            }
            field(Description; Description)
            {
                ApplicationArea = All;
            }
            field(ItemDescription; RecTempItem.Description)
            {
                ApplicationArea = All;
                CaptionClass = ExItemDescription;
                Style = Attention;
                StyleExpr = TRUE;
            }
            field("Sales Price"; "Sales Price")
            {
                ApplicationArea = All;
            }
            field("RecTempItem.""Unit Price"""; RecTempItem."Unit Price")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExItemUnitPrice;
                ShowCaption = false;
                Style = Attention;
                StyleExpr = TRUE;
            }
            field("Direct Unit Cost"; "Direct Unit Cost")
            {
                ApplicationArea = All;
            }
            field("Last unit cost"; RecTempItem."Last Direct Cost")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExItemUnitCost;
                Style = Attention;
                StyleExpr = TRUE;
            }
            field("Variety Lines to Skip"; "Variety Lines to Skip")
            {
                ApplicationArea = All;
            }
            field("Variety Lines to Update"; "Variety Lines to Update")
            {
                ApplicationArea = All;
            }
            field("Variety Lines to Create"; "Variety Lines to Create")
            {
                ApplicationArea = All;
            }
            field("No. of Changes"; "No. of Changes")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExNoOfChanges;
            }
            field("No. of Warnings"; "No. of Warnings")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExNoOfWarnings;
                Style = Attention;
                StyleExpr = TRUE;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        RecExItem.Init;
        if "Existing Item No." <> '' then
            if RecExItem.Get("Existing Item No.") then
                RecTempItem := RecExItem;
        RecExItem.CalcFields(Inventory);
        BuildCaptions;
    end;

    trigger OnAfterGetRecord()
    begin
        Clear(RecExItem);
        Clear(RecTempItem);
        BuildCaptions;
    end;

    var
        RecExItem: Record Item;
        RecTempItem: Record Item temporary;
        ItemWorksheetLine: Record "NPR Item Worksheet Line" temporary;
        ExItemDescription: Text;
        ExItemUnitPrice: Text;
        ExItemUnitCost: Text;
        [InDataSet]
        ExNoOfChanges: Text;
        [InDataSet]
        ExNoOfWarnings: Text;

    local procedure BuildCaptions()
    var
        TextDescription: Label 'Existing item:';
        TextUnitPrice: Label 'Existing item:';
        TextUnitCost: Label 'Last Direct Unit Cost:';
    begin
        ExItemDescription := '';
        ExItemUnitPrice := '';
        ExItemUnitCost := '';
        //-NPR5.25 [246088]
        CalcFields("No. of Changes", "No. of Warnings");
        ExNoOfChanges := '';
        ExNoOfWarnings := '';
        //+NPR5.25 [246088]
        if ("Existing Item No." <> '') then begin
            if Description <> RecTempItem.Description then
                ExItemDescription := TextDescription
            else
                RecTempItem.Description := '';
            if "Sales Price" <> RecTempItem."Unit Price" then
                ExItemUnitPrice := TextUnitPrice
            else
                RecTempItem."Unit Price" := 0;
            if "Direct Unit Cost" <> RecTempItem."Last Direct Cost" then
                ExItemUnitCost := TextUnitCost
            else
                RecTempItem."Last Direct Cost" := 0;
            //-NPR5.25 [246088]
            CalcFields("No. of Changes", "No. of Warnings");
            if "No. of Changes" <> 0 then begin
                ExNoOfChanges := FieldCaption("No. of Changes");
            end;
            if "No. of Warnings" <> 0 then begin
                ExNoOfWarnings := FieldCaption("No. of Warnings");
            end;
            //+NPR5.25 [246088]
        end;
    end;
}

