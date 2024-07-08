enum 6014459 "NPR Dim. Popup Filter Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Category")
    {
        Caption = 'Item Category';
    }

}
