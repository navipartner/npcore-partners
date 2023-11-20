page 6151089 "NPR RS Nivelation Lines Part"
{
    AutoSplitKey = true;
    Caption = 'Nivelation Lines';
    MultipleNewLines = true;
    PageType = ListPart;
    CardPageId = "NPR RS Nivelation Header";
    SourceTable = "NPR RS Nivelation Lines";
    Extensible = false;
    SourceTableView = sorting("Line No.") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(NivelationLines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("UOM Code"; Rec."UOM Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.';
                }
                field("Old Price"; Rec."Old Price")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Old Price field.';
                }
                field("Old Value"; Rec."Old Value")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Old Value field.';
                }
                field("New Price"; Rec."New Price")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the New Price field.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the New Value field.';
                }
                field("Price Difference"; Rec."Price Difference")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Price Difference field.';
                }
                field("Value Difference"; Rec."Value Difference")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Price Difference field.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the VAT % field.';
                }
                field("Calculated VAT"; Rec."Calculated VAT")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Calculated VAT field.';
                }
            }
        }
    }
}