enum 6014426 "NPR Magento Picture Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; Brand)
    {
        Caption = 'Brand';
    }
    value(2; "Item Group")
    {
        Caption = 'Item Group';
    }
    value(3; Customer)
    {
        Caption = 'Customer';
    }
}
