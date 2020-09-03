page 6151591 "NPR NpDc Coupon Types"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Deleted field 1010 "Coupon Qty. (Closed)" and renamed field 1020 "Posted Coupon Qty." to "Arch. Coupon Qty."
    // NPR5.37/MHA /20171016  CASE 293531 Added Actions: How-to Videos
    // NPR5.39/MHA /20180214  CASE 305146 Added field 70 "Enabled"
    // NPR5.40/MHA /20180308  CASE 305859 Added Action "Comments"
    // NPR5.55/ALPO/20200518  CASE 387376 Possibility to define sequence in which discount coupons are applied

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
            }
            action("How-to Videos")
            {
                Caption = 'How-to Videos';
                Image = UserInterface;

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

