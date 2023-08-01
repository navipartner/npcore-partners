enum 6014559 "NPR Total Disc. Benefit Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(1; "Discount")
    {
        Caption = 'Discount';
    }
    value(2; "Item")
    {
        Caption = 'Item';
    }
    value(3; "Item List")
    {
        Caption = 'Item List';
    }
}
