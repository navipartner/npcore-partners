enum 6014596 "NPR BG SIS Payment Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; Cash)
    {
        Caption = 'Cash';
    }
    value(1; "Bank Transfer")
    {
        Caption = 'Bank Transfer';
    }
    value(2; "Credit/Debit Card")
    {
        Caption = 'Credit/Debit Card';
    }
    value(3; Cheque)
    {
        Caption = 'Cheque';
    }
    value(4; "Internal Usage")
    {
        Caption = 'Internal Usage';
    }
    value(5; Voucher)
    {
        Caption = 'Voucher';
    }
    value(6; "External Voucher")
    {
        Caption = 'External Voucher';
    }
    value(7; NHIT)
    {
        Caption = 'National Health Insurance';
    }
    value(8; Empties)
    {
        Caption = 'Empties';
    }
    value(99; " ")
    {
        Caption = ' ';
    }
}