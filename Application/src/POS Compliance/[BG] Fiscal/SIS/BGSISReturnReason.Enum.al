enum 6014600 "NPR BG SIS Return Reason"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "Cashier Error")
    {
        Caption = 'Cashier Error';
    }
    value(1; "Refund/Return")
    {
        Caption = 'Refund/Return';
    }
    value(2; "Wrong Price")
    {
        Caption = 'Wrong Price (Return Only Cash)';
    }
    value(99; " ")
    {
        Caption = ' ';
    }
}
