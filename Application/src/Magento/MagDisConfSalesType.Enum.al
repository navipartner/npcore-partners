enum 6014420 "NPR Mag. Dis. Conf. Sales Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Customer)
    {
        Caption = 'Customer';
    }
    value(1; "Display Group")
    {
        Caption = 'Display Group';
    }
    value(2; "All Customers")
    {
        Caption = 'All Customers';
    }
}
