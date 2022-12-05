page 6060085 "NPR Package Dimension Details"
{
    Caption = 'Package Dimension Details';
    PageType = List;
    SourceTable = "NPR Package Dimension Details";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sales Line No."; Rec."Sales Line No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Line No. field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Item Quantity"; Rec."Item Quantity")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Item Quantity field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }

            }
        }
    }
}
