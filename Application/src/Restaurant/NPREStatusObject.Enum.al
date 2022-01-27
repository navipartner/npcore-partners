enum 6150664 "NPR NPRE Status Object"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Seating)
    {
        Caption = 'Seating';
    }
    value(1; WaiterPad)
    {
        Caption = 'Waiter Pad';
    }
    value(2; WaiterPadLineMealFlow)
    {
        Caption = 'Waiter Pad Line Meal Flow';
    }
    value(3; WaiterPadLineStatus)
    {
        Caption = 'Waiter Pad Line Status';
    }
}
