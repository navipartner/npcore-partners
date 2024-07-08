enum 6014433 "NPR Magento Api Username Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Automatic)
    {
        Caption = 'Automatic';
    }
    value(1; Custom)
    {
        Caption = 'Custom';
    }
}
