enum 6014487 "NPR Payment Processing Type" implements "NPR POS IPaymentWFHandler"
{
    Extensible = true;
#if not BC17
    Access = Public;
    UnknownValueImplementation = "NPR POS IPaymentWFHandler" = "NPR Null PaymentHandler";
#endif

    value(0; CASH)
    {
        Caption = 'Cash';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR POS Action: Cash Payment";
    }
    value(1; VOUCHER)
    {
        Caption = 'Voucher';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR Null PaymentHandler";
    }
    value(2; CHECK)
    {
        Caption = 'Check';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR Null PaymentHandler";
    }
    value(3; EFT)
    {
        Caption = 'EFT';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR POS Action: EFT Payment";
    }
    value(5; PAYOUT)
    {
        Caption = 'Payout';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR POS Action Pay-in Payout";
    }
    value(6; "FOREIGN VOUCHER")
    {
        Caption = 'Foreign Voucher';
        Implementation = "NPR POS IPaymentWFHandler" = "NPR Null PaymentHandler";
    }

}