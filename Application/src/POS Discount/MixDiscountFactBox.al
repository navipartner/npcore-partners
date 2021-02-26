page 6014654 "NPR Mix Discount FactBox"
{

    Caption = 'Mix Discount FactBox';
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Mixed Discount";

    layout
    {
        area(content)
        {
            group(Control6014407)
            {
                ShowCaption = false;
                Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Total Discount Amt. per Min. Qty.") AND (Rec."Discount Type" <> Rec."Discount Type"::"Multiple Discount Levels") AND (NOT Rec."Lot");
                field(MinimumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, false))
                {
                    ApplicationArea = All;
                    Caption = 'Min. Discount Amount';
                    ToolTip = 'Specifies the value of the Min. Discount Amount field';
                }
                field(MaximumDiscount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, true))
                {
                    ApplicationArea = All;
                    Caption = 'Max. Discount Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Max. Discount Amount field';
                }
            }
            group(Control6014417)
            {
                ShowCaption = false;
                Visible = (Rec."Discount Type" <> Rec."Discount Type"::"Total Discount Amt. per Min. Qty.") AND (Rec."Lot");
                field(Discount; MixedDiscountMgt.CalcExpectedDiscAmount(Rec, true))
                {
                    ApplicationArea = All;
                    Caption = 'Discount Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
            }
            field("Created the"; Rec."Created the")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the Created Date field';
            }
            field("Last Date Modified"; Rec."Last Date Modified")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the value of the Last Date Modified field';
            }
        }
    }

    var
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";

}

