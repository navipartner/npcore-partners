codeunit 6248586 "NPR NpDc Coupon Manual Post"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::"Codeunit", Codeunit::"NPR POS Sale Line", 'OnBeforeDeletePOSSaleLine', '', false, false)]
    local procedure POSSaleLineOnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        NpDcCouponMgt.PostSaleLinePOS(SaleLinePOS);
    end;
}
