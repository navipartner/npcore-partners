page 6151591 "NPR NpDc Coupon Types"
{
    Caption = 'Coupon Types';
    CardPageID = "NPR NpDc Coupon Type Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon Type";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Application Sequence No."; Rec."Application Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Application Sequence No. field';
                }
                field("Coupon Qty. (Open)"; Rec."Coupon Qty. (Open)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Qty. (Open) field';
                }
                field("Arch. Coupon Qty."; Rec."Arch. Coupon Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Arch. Coupon Qty. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Issue Coupons")
            {
                Caption = 'Issue Coupons';
                Image = PostedVoucherGroup;
                ApplicationArea = All;
                ToolTip = 'Executes the Issue Coupons action';

                trigger OnAction()
                var
                    NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                begin
                    NpDcCouponMgt.IssueCoupons(Rec);
                end;
            }
        }
        area(navigation)
        {
            action(Coupons)
            {
                Caption = 'Coupons';
                Image = Voucher;
                RunObject = Page "NPR NpDc Coupons";
                RunPageLink = "Coupon Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Coupons action';
            }
            action(Comments)
            {
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "NPR Retail Comments";
                RunPageLink = "Table ID" = CONST(6151590),
                              "No." = FIELD(Code),
                              "No. 2" = FILTER(''),
                              Option = CONST("0"),
                              "Option 2" = CONST("0"),
                              Integer = CONST(0),
                              "Integer 2" = CONST(0);
                ApplicationArea = All;
                ToolTip = 'Executes the Co&mments action';
            }
        }
    }
}

