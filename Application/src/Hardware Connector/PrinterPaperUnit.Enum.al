enum 6014492 "NPR Printer Paper Unit"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    value(0; "Inches")
    {
        Caption = 'IN', Locked = true;
    }
    value(1; "Millimeters")
    {
        Caption = 'MM', Locked = true;
    }
    value(2; "Points")
    {
        Caption = 'PT', Locked = true;
    }
    value(3; "Hundredth of Inch")
    {
        Caption = 'HI', Locked = true;
    }
    value(4; "Thousandth of Inch")
    {
        Caption = 'TI', Locked = true;
    }
    value(5; "Centimeters")
    {
        Caption = 'CM', Locked = true;
    }
    value(6; "Picas")
    {
        Caption = 'PC', Locked = true;
    }
}