enum 6059910 "NPR Merchant Account"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif
    value(0; " ")
    {
        Caption = '';
    }
    value(10; "Merchant Payout")
    {
        Caption = 'Merchant Payout';
    }
    value(20; "External Merchant Payout")
    {
        Caption = 'External Merchant Payout';
    }
    value(30; Fee)
    {
        Caption = 'Fee';
    }
    value(40; Deposit)
    {
        Caption = 'Deposit';
    }
    value(50; Markup)
    {
        Caption = 'Markup';
    }
    value(60; "Other commissions")
    {
        Caption = 'Other commissions';
    }
    value(70; "Invoice Deduction")
    {
        Caption = 'Invoice Deduction';
    }
    value(80; "Reconciled Payment")
    {
        Caption = 'Reconciled Payment';
    }
    value(90; "Missing Transaction")
    {
        Caption = 'Missing Transaction';
    }
    value(100; "Chargeback Fees")
    {
        Caption = 'Chargeback Fees';
    }
    value(110; "Advancement External Commission")
    {
        Caption = 'Advancement External Commission';
    }
    value(120; "Refunded External Commission")
    {
        Caption = 'Refunded External Commission';
    }
    value(130; "Settled External Commission")
    {
        Caption = 'Settled External Commission';
    }
}
