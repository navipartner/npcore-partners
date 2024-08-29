enum 6059795 "NPR Adyen Rec. Header Status"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; Unmatched)
    {
        Caption = 'Unmatched';
    }
    value(10; Matched)
    {
        Caption = 'Matched';
    }
    value(30; Posted)
    {
        Caption = 'Posted';
    }
}
