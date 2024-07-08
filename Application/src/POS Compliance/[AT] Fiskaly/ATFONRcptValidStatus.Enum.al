enum 6014678 "NPR AT FON Rcpt. Valid. Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; SUCCESS)
    {
        Caption = 'SUCCESS';
    }
    value(2; ERROR_UNSPECIFIED)
    {
        Caption = 'ERROR_UNSPECIFIED';
    }
}
