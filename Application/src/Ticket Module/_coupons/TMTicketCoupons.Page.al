page 6184595 "NPR TM TicketCoupons"
{
    Extensible = false;
    PageType = List;
    Caption = 'Ticket Coupons';
    UsageCategory = None;
    SourceTable = "NPR TM TicketCoupons";
    Editable = false;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_coupon_profile/';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CouponAlias; Rec.CouponAlias)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Alias field.';
                }
                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                }
                field(CouponNo; Rec.CouponNo)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon No. field.';
                }
                field(CouponReferenceNo; Rec.CouponReferenceNo)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Reference No. field.';
                }
                field(Archived; Rec.Archived)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Archived field.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Open field.';
                }
                field(InUseQuantity; Rec.InUseQuantity)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the In-use Quantity field.';
                }
                field("In-use Quantity (Web)"; Rec."In-use Quantity (Web)")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the In-use Quantity (Web) field.';
                }

                field(TicketNo; Rec.TicketNo)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {

            action(Print)
            {
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Print action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Coupon: Record "NPR NpDc Coupon";
                    NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                begin
                    Coupon.Get(Rec.CouponNo);
                    NpDcCouponMgt.PrintCoupon(Coupon);
                end;
            }
            action("Reset Coupons In-use")
            {
                Caption = 'Reset Coupons In-use';
                Image = RefreshVoucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Reset Coupons In-use action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Coupon: Record "NPR NpDc Coupon";
                    NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    ConfirmDeleteCoupons: Label 'Are you sure you want to delete Coupons In-use?';
                begin
                    Coupon.Get(Rec.CouponNo);
                    if not Confirm(ConfirmDeleteCoupons, false) then
                        exit;

                    NpDcCouponMgt.ResetInUseQty(Coupon);
                end;
            }
        }
    }
}