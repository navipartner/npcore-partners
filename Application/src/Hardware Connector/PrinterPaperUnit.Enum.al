enum 6014492 "NPR Printer Paper Unit"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    value(0; Inches)
    {
        Caption = 'Inches (in)';
    }
    value(1; Millimeters)
    {
        Caption = 'Millimeters (mm)';
    }
}