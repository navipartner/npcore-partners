enum 6014430 "NPR Magento Variant System"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(2; Variety)
    {
        Caption = 'Variety';
    }
}
