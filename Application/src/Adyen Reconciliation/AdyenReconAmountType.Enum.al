enum 6014687 "NPR Adyen Recon. Amount Type"
{
    Extensible = true;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; "Transaction")
    {
        Caption = 'Transaction';
    }
    value(10; "Fee")
    {
        Caption = 'Fee';
    }
    value(20; "Markup")
    {
        Caption = 'Markup';
    }
    value(30; "Other commissions")
    {
        Caption = 'Other commissions';
    }
    value(40; "Invoice Deduction")
    {
        Caption = 'Invoice Deduction';
    }
    value(50; "Chargeback Fees")
    {
        Caption = 'Chargeback Fees';
    }
    value(60; "Merchant Payout")
    {
        Caption = 'Merchant Payout';
    }
    value(65; "Acquirer Payout")
    {
        Caption = 'Acquirer Payout';
    }
    value(70; "Advancement External Commission")
    {
        Caption = 'Advancement External Commission';
    }
    value(80; "Refunded External Commission")
    {
        Caption = 'Refunded External Commission';
    }
    value(90; "Settled External Commission")
    {
        Caption = 'Settled External Commission';
    }
    value(100; "Realized Gains")
    {
        Caption = 'Realized Gains';
    }
    value(110; "Realized Losses")
    {
        Caption = 'Realized Losses';
    }
}
