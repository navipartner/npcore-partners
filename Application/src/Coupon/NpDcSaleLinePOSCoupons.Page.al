page 6151598 "NPR NpDc SaleLinePOS Coupons"
{
    Caption = 'Sale Line POS Coupons';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc SaleLinePOS Coupon";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sale Date"; Rec."Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Sale Line No."; Rec."Sale Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Line No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type field';
                }
                field("Coupon No."; Rec."Coupon No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
            }
        }
    }
}

