enum 6014564 "NPR Item Wksht. Price Handling"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;
    
    value(0; Item)
    {
        Caption = 'Item';
    }

    value(1; PriceList)
    {
        Caption = 'Price List';
    }
}