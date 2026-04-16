#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151119 "NPR EcomCreateCouponTryProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    trigger OnRun()
    var
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.Process(Rec);
    end;
}
#endif
