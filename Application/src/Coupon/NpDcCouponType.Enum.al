enum 6014462 "NPR NpDc Coupon Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Categories")
    {
        Caption = 'Item Categories';
    }
    value(2; "Item Disc. Group")
    {
        Caption = 'Item Disc. Group';
    }
    value(3; "Magento Brand")
    {
        Caption = 'Magento Brand';
    }
}
