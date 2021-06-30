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
            field(ItemDescription; TempRecTempItem.Description)
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
            field("RecTempItem.""Unit Price"""; TempRecTempItem."Unit Price")
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
            field("Last unit cost"; TempRecTempItem."Last Direct Cost")
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
        RecExItem.Init();
        if Rec."Existing Item No." <> '' then
            if RecExItem.Get(Rec."Existing Item No.") then
                TempRecTempItem := RecExItem;
        RecExItem.CalcFields(Inventory);
        BuildCaptions();
    end;

    trigger OnAfterGetRecord()
    begin
        Clear(RecExItem);
        Clear(TempRecTempItem);
        BuildCaptions();
    end;

    var
        RecExItem: Record Item;
        TempRecTempItem: Record Item temporary;
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
        Rec.CalcFields("No. of Changes", "No. of Warnings");
        ExNoOfChanges := '';
        ExNoOfWarnings := '';
        if (Rec."Existing Item No." <> '') then begin
            if Rec.Description <> TempRecTempItem.Description then
                ExItemDescription := DescriptionLbl
            else
                TempRecTempItem.Description := '';
            if Rec."Sales Price" <> TempRecTempItem."Unit Price" then
                ExItemUnitPrice := UnitPriceLbl
            else
                TempRecTempItem."Unit Price" := 0;
            if Rec."Direct Unit Cost" <> TempRecTempItem."Last Direct Cost" then
                ExItemUnitCost := UnitCostLbl
            else
                TempRecTempItem."Last Direct Cost" := 0;
            Rec.CalcFields("No. of Changes", "No. of Warnings");
            if Rec."No. of Changes" <> 0 then begin
                ExNoOfChanges := Rec.FieldCaption("No. of Changes");
            end;
            if Rec."No. of Warnings" <> 0 then begin
                ExNoOfWarnings := Rec.FieldCaption("No. of Warnings");
            end;
        end;
    end;
}

