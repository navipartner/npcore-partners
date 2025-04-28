enum 6059861 "NPR HU L Cash Mgt. Reason"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(1; "Change Pay-in")
    {
        Caption = 'Change Pay-in';
    }
    value(2; "Cashier Pay-in")
    {
        Caption = 'Cashier Pay-in';
    }
    value(3; "Fee Collection")
    {
        Caption = 'Fee Collection';
    }
    value(4; "Lottery Ticket Selling")
    {
        Caption = 'Lottery Ticket Selling';
    }
    value(5; "Deposit")
    {
        Caption = 'Deposit';
    }
    value(6; "Cash Shortage")
    {
        Caption = 'Cash Shortage';
    }
    value(7; Tip)
    {
        Caption = 'Tip';
    }
    value(8; "Other Pay-in")
    {
        Caption = 'Other Pay-in';
    }
    value(31; "SKIM")
    {
        Caption = 'SKIM';
    }
    value(32; "Cashier Log-out")
    {
        Caption = 'Cashier Log-out';
    }
    value(33; "Voucher Out")
    {
        Caption = 'Voucher Out';
    }
    value(34; "Gift Card Out")
    {
        Caption = 'Gift Card Out';
    }
    value(35; "Salary Payout")
    {
        Caption = 'Salary Payout';
    }
    value(36; "Wages Payout")
    {
        Caption = 'Wages Payout';
    }
    value(37; "Post Fee Payout")
    {
        Caption = 'Post Fee Payout';
    }
    value(38; "Other Costs")
    {
        Caption = 'Other Costs';
    }
    value(39; "Buy Goods")
    {
        Caption = 'Buy Goods';
    }
    value(40; "Closure Amount Payout")
    {
        Caption = 'Closure Amount Payout';
    }
    value(41; "Other payout")
    {
        Caption = 'Other payout';
    }
}