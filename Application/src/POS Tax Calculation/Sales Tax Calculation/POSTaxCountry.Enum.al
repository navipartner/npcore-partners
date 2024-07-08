enum 6150758 "NPR POS Tax Group Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "Tax Area")
    {
        Caption = 'Tax Area';
    }
    value(1; "Tax Jurisdiction")
    {
        Caption = 'Tax Jurisdiction';
    }
}
