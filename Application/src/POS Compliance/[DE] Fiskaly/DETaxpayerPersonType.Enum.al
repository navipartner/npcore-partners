enum 6059831 "NPR DE Taxpayer Person Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; natural)
    {
        Caption = 'Natural';
    }
    value(2; legal)
    {
        Caption = 'Legal';
    }
}
