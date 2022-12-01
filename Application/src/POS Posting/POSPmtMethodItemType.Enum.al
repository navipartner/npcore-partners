enum 6014513 "NPR POS Pmt. Method Item Type"
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
}
