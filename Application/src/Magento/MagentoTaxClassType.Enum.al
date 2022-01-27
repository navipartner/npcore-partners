enum 6014422 "NPR Magento Tax Class Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
}
