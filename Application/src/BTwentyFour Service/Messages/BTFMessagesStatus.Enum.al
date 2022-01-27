enum 6014650 "NPR BTF Messages Status"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(30; "Awaiting delivery")
    {
        Caption = 'Awaiting delivery';
    }
    value(31; "Delivering")
    {
        Caption = 'Delivering';
    }
    value(40; "Delivered")
    {
        Caption = 'Delivered';
    }
}
