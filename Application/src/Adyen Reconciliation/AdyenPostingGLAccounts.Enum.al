enum 6014674 "NPR Adyen Posting GL Accounts"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "Deposit G/L Account")
    {
        Caption = 'Deposit G/L Account';
    }
    value(10; "Fee G/L Account")
    {
        Caption = 'Fee G/L Account';
    }
    value(20; "Markup G/L Account")
    {
        Caption = 'Markup G/L Account';
    }
    value(30; "Other commissions G/L Account")
    {
        Caption = 'Other commissions G/L Account';
    }
    value(40; "Invoice Deduction G/L Account")
    {
        Caption = 'Invoice Deduction G/L Account';
    }
    value(50; "Chargeback Fees G/L Account")
    {
        Caption = 'Chargeback Fees G/L Account';
    }
    value(60; "Merchant Payout G/L Account")
    {
        Caption = 'Merchant Payout G/L Account';
    }
    value(70; "Advancement External Commission G/L Account")
    {
        Caption = 'Advancement External Commission G/L Account';
    }
    value(80; "Refunded External Commission G/L Account")
    {
        Caption = 'Refunded External Commission G/L Account';
    }
    value(90; "Settled External Commission G/L Account")
    {
        Caption = 'Settled External Commission G/L Account';
    }
}
