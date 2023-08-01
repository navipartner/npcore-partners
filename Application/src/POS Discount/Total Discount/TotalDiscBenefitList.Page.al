page 6150910 "NPR Total Disc. Benefit List"
{
    Caption = 'Total Discount Benefit List';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Total Discount Benefit";
    SourceTableView = SORTING("Total Discount Code", "Step Amount");
    Extensible = false;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Step Amount"; Rec."Step Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Step Amount of the Total Discount Benefit. The benefits defined by the highest Step Amount that is lower or equal to the trigger POS Sale Amount are going to be applied to the POS Sale.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Type of the Total Discount Benefit. Item - you can specify items that are going to be given to the customer on a special price when the Total Discount is triggered. Discount - you can give a discount to the customer when the Total Discount is triggered.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the No. of the Total Discount Benefit. If the Type field is set to Item you can choose an item no. in this field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Variant Code of the Total Discount Benefit. If the Type field is set to Item you can choose an item variant in this field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Description of the Total Discount Benefit.';
                }

                field("No Input Needed"; Rec."No Input Needed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines if the users will be able to choose the benefit item.';
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Quantity of the Total Discount Benefit. If the Type field is set to Item you can specify the quantity of the item in this field.';
                }
                field("Value Type"; Rec."Value Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Value Type of the Total Discount Benefit. Amount - you can specify an amount. If the Type field is set to Item this will be Item price. If the Type field is set to Discount this will the discount amount that is going to be applied to the POS Sale. Percent - if the Type field is set to Discount you can specify a discount percentage.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Value of the Total Discount Benefit. If the Type field is set to Item you can specify the item price in this field. If the Type is set to Discount you can specify the discount amount/percentage in this field.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := Rec.Type::Item;
        Rec.Quantity := 1;
    end;
}

