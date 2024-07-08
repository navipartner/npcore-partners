enum 6014548 "NPR NPRE Send All on New Lines"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(1; No)
    {
        Caption = 'No';
    }
    value(2; Yes)
    {
        Caption = 'Yes';
    }
    value(3; Ask)
    {
        Caption = 'Ask';
    }
}
