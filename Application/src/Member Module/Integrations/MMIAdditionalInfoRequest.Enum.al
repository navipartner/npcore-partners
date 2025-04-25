enum 6059817 "NPR MM Add. Info. Request" implements "NPR MM IAdd. Info. Request"
{
#if not BC17
    Access = Internal;
#endif
    DefaultImplementation = "NPR MM IAdd. Info. Request" = "NPR MM Unkown Add. Info. Req.";

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "Vipps MobilePay")
    {
        Caption = 'Vipps MobilePay', Locked = true;
        Implementation = "NPR MM IAdd. Info. Request" = "NPR MM VippsMP Add. Info. Req.";
    }
    value(2; Adyen)
    {
        Caption = 'Adyen', Locked = true;
        Implementation = "NPR MM IAdd. Info. Request" = "NPR Adyen Data Collection";
    }
}
