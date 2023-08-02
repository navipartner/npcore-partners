page 6151591 "NPR NpDc Coupon Types"
{
    Extensible = False;
    Caption = 'Coupon Types';
    ContextSensitiveHelpPage = 'docs/retail/coupons/reference/coupon_types/';
    CardPageID = "NPR NpDc Coupon Type Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon Type";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ToolTip = 'Specifies the discount type of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the discount in percentage of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the discount amount of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies if the coupon type is enabled or not';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the starting date of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the ending date of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Application Sequence No."; Rec."Application Sequence No.")
                {
                    ToolTip = 'Specifies the application sequence number of the coupon type';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Coupon Qty. (Open)"; Rec."Coupon Qty. (Open)")
                {
                    ToolTip = 'Specifies the quantity of the coupons that are open for the coupon type';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Arch. Coupon Qty."; Rec."Arch. Coupon Qty.")
                {
                    ToolTip = 'Specifies the quantity of the coupons that are archived for the coupon type';
                    ApplicationArea = NPRRetail;
                    Visible = false;
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

                ToolTip = 'Enable issuing coupons for the selected coupon type. If clicked, the page in which you can enter the number of coupons to be issued is displayed.';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Displays all coupons which belong to the selected coupon type.';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Displays all comments associated with the selected coupon type.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

