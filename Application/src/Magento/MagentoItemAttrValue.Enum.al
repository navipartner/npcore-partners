enum 6014414 "NPR Magento Item Attr. Value"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "")
    {
        Caption = '';
    }
    value(1; Single)
    {
        Caption = 'Single';
    }
    value(2; Multiple)
    {
        Caption = 'Multiple';
    }
    value(3; "Text Area (single)")
    {
        Caption = 'Text Area (single)';
    }
}
