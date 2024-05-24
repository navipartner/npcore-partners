enum 6014663 "NPR Adyen Rec. Log Status"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; Success)
    {
        Caption = 'Success';
    }
    value(10; Failed)
    {
        Caption = 'Failed';
    }
}
