#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059894 "NPR LoyaltyApiFunctions"
{
    Extensible = false;
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'This API is being phased out';

    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(1; GET_LOYALTY_POINTS)
    {
        Caption = 'Get loyalty points';
    }
    value(2; GET_LOYALTY_POINT_ENTRIES)
    {
        Caption = 'Get loyalty point entries';
    }
    value(3; GET_MEMBERSHIP_RECEIPT_LIST)
    {
        Caption = 'Get membership receipt list';
    }
    value(4; GET_MEMBERSHIP_RECEIPT_PDF)
    {
        Caption = 'Get membership receipt PDF';
    }
    value(5; REGISTER_SALE)
    {
        Caption = 'Register sale';
    }
    value(6; RESERVE_POINTS)
    {
        Caption = 'Reserve points';
    }
    value(7; CANCEL_RESERVE_POINTS)
    {
        Caption = 'Cancel reserve points';
    }
    value(8; CAPTURE_RESERVE_POINTS)
    {
        Caption = 'Capture reserve points';
    }
    value(9; GET_LOYALTY_CONFIGURATION)
    {
        Caption = 'Get loyalty configuration';
    }
    value(10; GET_COUPON_ELIGIBILITY)
    {
        Caption = 'Get coupon eligibility';
    }
    value(11; CREATE_COUPON)
    {
        Caption = 'Create coupon';
    }
    value(12; LIST_COUPON)
    {
        Caption = 'List coupon';
    }
    value(13; DELETE_COUPON)
    {
        Caption = 'Delete coupon';
    }
}
#endif