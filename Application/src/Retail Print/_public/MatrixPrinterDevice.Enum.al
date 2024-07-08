enum 6014491 "NPR Matrix Printer Device" implements "NPR IMatrix Printer"
{
    Extensible = false;

    value(0; Zebra)
    {
        Caption = 'Zebra';
        Implementation = "NPR IMatrix Printer" = "NPR RP Zebra ZPL Device Lib.";

    }
    value(1; Blaster)
    {
        Caption = 'Blaster';
        Implementation = "NPR IMatrix Printer" = "NPR RP Blaster CPL Device Lib.";
    }
    value(2; Citizen)
    {
        Caption = 'Citizen';
        Implementation = "NPR IMatrix Printer" = "NPR RP Citizen CLP Device Lib.";
    }
    value(3; Epson)
    {
        Caption = 'Epson';
        Implementation = "NPR IMatrix Printer" = "NPR RP Epson Label Device Lib.";
    }
    value(4; Boca)
    {
        Caption = 'Boca';
        Implementation = "NPR IMatrix Printer" = "NPR RP Boca Label Device Lib.";
    }
}