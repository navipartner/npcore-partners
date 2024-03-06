enum 6014646 "NPR TM ActivationMethod_Bom"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;
    // OptionCaption = ' ,On Scan,On Sale,Always,Per Unit';
    // OptionMembers = NA,SCAN,POS,ALWAYS,PER_UNIT;

    value(0; NA)
    {
        Caption = '';
    }
    value(1; SCAN)
    {
        Caption = 'On Scan';
    }
    value(2; POS)
    {
        Caption = 'On Sale (POS)';
    }

    value(3; ALWAYS)
    {
        Caption = 'Always';
    }
    value(4; PER_UNIT)
    {
        Caption = 'Per Unit';
    }
}