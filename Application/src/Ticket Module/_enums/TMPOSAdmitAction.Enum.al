enum 6059858 "NPR TM POS Admit Action"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; NONE)
    {
        Caption = 'None';
    }
    value(1; PRINT)
    {
        Caption = 'Print';
    }
    value(2; ADMIT)
    {
        Caption = 'Admit';
    }
    value(3; PRINT_ADMIT)
    {
        Caption = 'Print and Admit';
    }
}
