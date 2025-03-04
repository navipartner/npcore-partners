codeunit 6248339 "NPR TM TicketToCouponFacade"
{
    procedure ExchangeTicketForCoupon(ExternalTicketNo: Code[30]; CouponAlias: Code[20]; var CouponReferenceNo: Text[50]; var ReasonCode: Integer; var ReasonText: Text) Success: Boolean
    var
        TicketToCoupon: Codeunit "NPR TM TicketToCoupon";
    begin
        exit(TicketToCoupon.ExchangeTicketForCoupon(ExternalTicketNo, CouponAlias, CouponReferenceNo, ReasonCode, ReasonText));
    end;

}