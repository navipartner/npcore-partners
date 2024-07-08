enum 6014544 "NPR POS Sales Document Post"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; No)
    {
        Caption = 'No';
    }
    value(1; Synchronous)
    {
        Caption = 'Synchronous';
    }
    value(2; Asynchronous)
    {
        Caption = 'Asynchronous';
    }
    value(3; Posted)
    {
        Caption = 'Posted';
    }
}
