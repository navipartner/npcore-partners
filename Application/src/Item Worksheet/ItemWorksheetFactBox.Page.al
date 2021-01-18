page 6060051 "NPR Item Worksheet FactBox"
{
    Caption = 'Item Worksheet FactBox';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Item Worksheet Line";
    layout
    {
        area(content)
        {
            field("Item No."; Rec."Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item No. field.';
            }
            field("Existing Item No."; Rec."Existing Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Existing Item No. field.';
            }
            field(Inventory; RecExItem.Inventory)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RecExItem.Inventory field.';
            }
            field(Description; Rec.Description)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description field.';
            }
            field(ItemDescription; RecTempItem.Description)
            {
                ApplicationArea = All;
                CaptionClass = ExItemDescription;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Description field.';
            }
            field("Sales Price"; Rec."Sales Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Unit Price field.';
            }
            field("RecTempItem.""Unit Price"""; RecTempItem."Unit Price")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExItemUnitPrice;
                ShowCaption = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Unit Price field.';
            }
            field("Direct Unit Cost"; Rec."Direct Unit Cost")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Direct Unit Cost field.';
            }
            field("Last unit cost"; RecTempItem."Last Direct Cost")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExItemUnitCost;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Last Direct Cost field.';
            }
            field("Variety Lines to Skip"; Rec."Variety Lines to Skip")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Variety Lines to Skip field.';
            }
            field("Variety Lines to Update"; Rec."Variety Lines to Update")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Variety Lines to Update field.';
            }
            field("Variety Lines to Create"; Rec."Variety Lines to Create")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Variety Lines to Create field.';
            }
            field("No. of Changes"; Rec."No. of Changes")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExNoOfChanges;
                ToolTip = 'Specifies the value of the No. of Changes field.';
            }
            field("No. of Warnings"; Rec."No. of Warnings")
            {
                ApplicationArea = All;
                BlankZero = true;
                CaptionClass = ExNoOfWarnings;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the No. of Warnings field.';
            }
        }
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
        ExItemUnitCost: Text;
        ExItemUnitPrice: Text;
        [InDataSet]
        ExNoOfChanges: Text;
        [InDataSet]
        ExNoOfWarnings: Text;

    local procedure BuildCaptions()
    var
        DescriptionLbl: Label 'Existing item:';
        UnitPriceLbl: Label 'Existing item:';
        UnitCostLbl: Label 'Last Direct Unit Cost:';
    begin
        ExItemDescription := '';
        ExItemUnitPrice := '';
        ExItemUnitCost := '';
        CalcFields("No. of Changes", "No. of Warnings");
        ExNoOfChanges := '';
        ExNoOfWarnings := '';
        if ("Existing Item No." <> '') then begin
            if Description <> RecTempItem.Description then
                ExItemDescription := DescriptionLbl
            else
                RecTempItem.Description := '';
            if "Sales Price" <> RecTempItem."Unit Price" then
                ExItemUnitPrice := UnitPriceLbl
            else
                RecTempItem."Unit Price" := 0;
            if "Direct Unit Cost" <> RecTempItem."Last Direct Cost" then
                ExItemUnitCost := UnitCostLbl
            else
                RecTempItem."Last Direct Cost" := 0;
            CalcFields("No. of Changes", "No. of Warnings");
            if "No. of Changes" <> 0 then begin
                ExNoOfChanges := FieldCaption("No. of Changes");
            end;
            if "No. of Warnings" <> 0 then begin
                ExNoOfWarnings := FieldCaption("No. of Warnings");
            end;
        end;
    end;
}

