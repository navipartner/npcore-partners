enum 6014665 "NPR AT FON Auth. Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; AUTHENTICATED)
    {
        Caption = 'AUTHENTICATED';
    }
    value(2; UNAUTHENTICATED)
    {
        Caption = 'UNAUTHENTICATED';
    }
    value(3; ERROR_UNSPECIFIED)
    {
        Caption = 'ERROR_UNSPECIFIED';
    }
}
