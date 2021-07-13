page 6151598 "NPR NpDc SaleLinePOS Coupons"
{
    Caption = 'Sale Line POS Coupons';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    PopulateAllFields = true;
    SourceTable = "NPR NpDc SaleLinePOS Coupon";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Date"; Rec."Sale Date")
                {

                    ToolTip = 'Specifies the value of the Sale Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Line No."; Rec."Sale Line No.")
                {

                    ToolTip = 'Specifies the value of the Sale Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon Type"; Rec."Coupon Type")
                {

                    ToolTip = 'Specifies the value of the Coupon Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon No."; Rec."Coupon No.")
                {

                    ToolTip = 'Specifies the value of the Coupon No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

