enum 6014556 "NPR Total Discount Line Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;
    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Category")
    {
        Caption = 'Item Category';
    }
    value(2; "Vendor")
    {
        Caption = 'Vendor';
    }
    value(3; All)
    {
        Caption = 'All';
    }
}
