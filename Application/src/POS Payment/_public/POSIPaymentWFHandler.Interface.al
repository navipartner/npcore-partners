interface "NPR POS IPaymentWFHandler"
{
#if not BC17
    Access = Public;
#endif
    procedure GetPaymentHandler(): Code[20];

}