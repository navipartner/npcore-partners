enum 6014404 "NPR CC Unit Stor. Stat."
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    value(0; OK)
    {
        Caption = 'OK';
    }

    value(1; WARNING)
    {
        Caption = 'High level warning.';
    }

    value(2; MEMORY)
    {
        Caption = 'Transaction memory full.';
    }

    value(999; NO_VALUE)
    {
        Caption = '';
    }
}
