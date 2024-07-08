enum 6014424 "NPR Mag. Shipment Fee Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; Resource)
    {
        Caption = 'Resource';
    }
    value(3; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
    value(4; "Charge (Item)")
    {
        Caption = 'Charge (Item)';
    }
}
