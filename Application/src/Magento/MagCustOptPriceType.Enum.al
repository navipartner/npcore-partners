enum 6014417 "NPR Mag. Cust. Opt. Price Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Fixed)
    {
        Caption = 'Fixed';
    }
    value(1; Percent)
    {
        Caption = 'Percent';
    }
}
