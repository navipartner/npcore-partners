enum 6014419 "NPR Mag. Display Config Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Group")
    {
        Caption = 'Item Group';
    }
    value(2; Brand)
    {
        Caption = 'Brand';
    }
    value(3; None)
    {
        Caption = 'None';
    }
}
