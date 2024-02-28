enum 6014642 "NPR BG SIS Cust. ID No. Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "BG Company")
    {
        Caption = 'BG Company';
    }
    value(1; "BG Physical Person")
    {
        Caption = 'BG Physical Person';
    }
    value(2; "Foreign Company or Physical Person")
    {
        Caption = 'Foreign Company or Physical Person';
    }
    value(99; " ")
    {
        Caption = ' ';
    }
}
