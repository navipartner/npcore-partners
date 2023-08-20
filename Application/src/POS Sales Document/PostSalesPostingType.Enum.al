enum 6014528 "NPR Post Sales Posting Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF    
    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Order)
    {
        Caption = 'Order';
    }
    value(2; "Prepayment Refund")
    {
        Caption = 'Prepayment Refund';
    }
    value(3; Prepayment)
    {
        Caption = 'Prepayment';
    }

}
