enum 6014466 "NPR MobilePayV10 Aux. Req."
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    value(1; AuthTokenRequest) { }
    value(2; CreatePOSRequest) { }
    value(3; DeletePOSRequest) { }
    value(4; FindActivePayment) { }
    value(5; FindActiveRefund) { }
    value(6; FindAllPayments) { }
    value(7; FindAllRefunds) { }
    value(8; GetPaymentDetail) { }
    value(9; GetRefundDetail) { }
}
