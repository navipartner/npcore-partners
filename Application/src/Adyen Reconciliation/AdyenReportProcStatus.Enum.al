enum 6059806 "NPR Adyen Report Proc. Status"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; Success)
    {
        Caption = 'Success';
    }
    value(20; Failed)
    {
        Caption = 'Failed';
    }
}
