enum 6014421 "NPR Magento Order Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Processing)
    {
        Caption = 'Processing';
    }
    value(1; Complete)
    {
        Caption = 'Complete';
    }
    value(2; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
