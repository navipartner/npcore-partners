enum 6014461 "NPR Magento Price Visibility"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; VISIBLE)
    {
        Caption = 'Visible';
    }
    value(1; HIDDEN)
    {
        Caption = 'Hidden';
    }

}
