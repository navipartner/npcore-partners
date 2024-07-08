page 6151099 "NPR RS Posted Niv. Lines Subp."
{
    PageType = ListPart;
    Caption = 'Nivelation Lines';
    UsageCategory = None;
    CardPageId = "NPR RS Posted Nivelation Doc";
    SourceTable = "NPR RS Posted Nivelation Lines";
    Editable = false;
    Extensible = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(NivelationLines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Item Number.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Item Description.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Variant Code of the given Item.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Location Code related to the chosen Sales Price List.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Quantity of items for which the price is beeing adjusted.';
                }
                field("UOM Code"; Rec."UOM Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Unit of Measure for the given item.';
                }
                field("Old Price"; Rec."Old Price")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Old Price of the given item.';
                }
                field("Old Value"; Rec."Old Value")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Old Value of the given item.';
                }
                field("New Price"; Rec."New Price")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the New Price of the given item.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the New Value of the given item.';
                }
                field("Price Difference"; Rec."Price Difference")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the difference between new and old price.';
                }
                field("Value Difference"; Rec."Value Difference")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the difference between new and old value.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the VAT rate.';
                }
                field("Calculated VAT"; Rec."Calculated VAT")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the Calculated VAT amount.';
                }
            }
        }
    }
}