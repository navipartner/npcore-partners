page 6151591 "NPR NpDc Coupon Types"
{
    Caption = 'Coupon Types';
    CardPageID = "NPR NpDc Coupon Type Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon Type";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Application Sequence No."; "Application Sequence No.")
                {
                    ApplicationArea = All;
                }
                field("Coupon Qty. (Open)"; "Coupon Qty. (Open)")
                {
                    ApplicationArea = All;
                }
                field("Arch. Coupon Qty."; "Arch. Coupon Qty.")
                {
                    ApplicationArea = All;
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
            }
            action("How-to Videos")
            {
                Caption = 'How-to Videos';
                Image = UserInterface;
                ApplicationArea = All;

                trigger OnAction()
                var
                    EmbeddedVideoMgt: Codeunit "NPR Embedded Video Mgt.";
                begin
                    EmbeddedVideoMgt.ShowEmbeddedVideos('NPDC');
                end;
            }
        }
    }
}

