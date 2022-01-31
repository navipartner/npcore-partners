page 6060051 "NPR Item Worksheet FactBox"
{
    Extensible = False;
    Caption = 'Item Worksheet FactBox';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Item Worksheet Line";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            field("Item No."; Rec."Item No.")
            {

                ToolTip = 'Specifies the value of the Item No. field.';
                ApplicationArea = NPRRetail;
            }
            field("Existing Item No."; Rec."Existing Item No.")
            {

                ToolTip = 'Specifies the value of the Existing Item No. field.';
                ApplicationArea = NPRRetail;
            }
            field(Inventory; RecExItem.Inventory)
            {

                ToolTip = 'Specifies the value of the RecExItem.Inventory field.';
                ApplicationArea = NPRRetail;
            }
            field(Description; Rec.Description)
            {

                ToolTip = 'Specifies the value of the Description field.';
                ApplicationArea = NPRRetail;
            }
            field(ItemDescription; TempItem.Description)
            {

                CaptionClass = ExItemDescription;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Description field.';
                ApplicationArea = NPRRetail;
            }
            field("Sales Price"; Rec."Sales Price")
            {

                ToolTip = 'Specifies the value of the Unit Price field.';
                ApplicationArea = NPRRetail;
            }
            field("Unit Price"; TempItem."Unit Price")
            {

                BlankZero = true;
                CaptionClass = ExItemUnitPrice;
                ShowCaption = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Unit Price field.';
                ApplicationArea = NPRRetail;
            }
            field("Direct Unit Cost"; Rec."Direct Unit Cost")
            {

                ToolTip = 'Specifies the value of the Direct Unit Cost field.';
                ApplicationArea = NPRRetail;
            }
            field("Last unit cost"; TempItem."Last Direct Cost")
            {

                BlankZero = true;
                CaptionClass = ExItemUnitCost;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the RecTempItem.Last Direct Cost field.';
                ApplicationArea = NPRRetail;
            }
            field("Variety Lines to Skip"; Rec."Variety Lines to Skip")
            {

                ToolTip = 'Specifies the value of the Variety Lines to Skip field.';
                ApplicationArea = NPRRetail;
            }
            field("Variety Lines to Update"; Rec."Variety Lines to Update")
            {

                ToolTip = 'Specifies the value of the Variety Lines to Update field.';
                ApplicationArea = NPRRetail;
            }
            field("Variety Lines to Create"; Rec."Variety Lines to Create")
            {

                ToolTip = 'Specifies the value of the Variety Lines to Create field.';
                ApplicationArea = NPRRetail;
            }
            field("No. of Changes"; Rec."No. of Changes")
            {

                BlankZero = true;
                CaptionClass = ExNoOfChanges;
                ToolTip = 'Specifies the value of the No. of Changes field.';
                ApplicationArea = NPRRetail;
            }
            field("No. of Warnings"; Rec."No. of Warnings")
            {

                BlankZero = true;
                CaptionClass = ExNoOfWarnings;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the No. of Warnings field.';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RecExItem.Init();
        if Rec."Existing Item No." <> '' then
            if RecExItem.Get(Rec."Existing Item No.") then
                TempItem := RecExItem;
        RecExItem.CalcFields(Inventory);
        BuildCaptions();
    end;

    trigger OnAfterGetRecord()
    begin
        Clear(RecExItem);
        Clear(TempItem);
        BuildCaptions();
    end;

    var
        RecExItem: Record Item;
        TempItem: Record Item temporary;
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
            if Rec.Description <> TempItem.Description then
                ExItemDescription := DescriptionLbl
            else
                TempItem.Description := '';
            if Rec."Sales Price" <> TempItem."Unit Price" then
                ExItemUnitPrice := UnitPriceLbl
            else
                TempItem."Unit Price" := 0;
            if Rec."Direct Unit Cost" <> TempItem."Last Direct Cost" then
                ExItemUnitCost := UnitCostLbl
            else
                TempItem."Last Direct Cost" := 0;
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

