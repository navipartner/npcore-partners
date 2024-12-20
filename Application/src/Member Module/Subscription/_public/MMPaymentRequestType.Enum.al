enum 6059835 "NPR MM Payment Request Type"
{
#if not BC17
    Access = Public;
#endif
    Extensible = false;

    value(0; Payment) { Caption = 'Payment'; }
    value(10; Refund) { Caption = 'Refund'; }
    value(20; RefundRefersed) { Caption = 'Reversed Refund'; }
    value(30; Chargeback) { Caption = 'Chargeback'; }
    value(40; ChargebackReversed) { Caption = 'Reversed Chargeback'; }
}