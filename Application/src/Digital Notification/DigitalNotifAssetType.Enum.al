#if not (BC17 or BC18 or BC19 or BC20 or BC21)
enum 6248181 "NPR Dig. Notif. Asset Type" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;
    Extensible = false;

    value(0; None)       { Caption = 'None';       Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif NoOp Impl"; }
    value(1; Voucher)    { Caption = 'Voucher';    Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif Voucher Impl"; }
    value(2; Membership) { Caption = 'Membership'; Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif Membership Impl"; }
    value(3; Coupon)     { Caption = 'Coupon';     Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif Coupon Impl"; }
    value(4; Ticket)     { Caption = 'Ticket';     Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif Ticket Impl"; }
    value(5; Wallet)     { Caption = 'Wallet';     Implementation = "NPR IDigNotifAssetProcessor" = "NPR DigNotif Wallet Impl"; }
}
#endif
