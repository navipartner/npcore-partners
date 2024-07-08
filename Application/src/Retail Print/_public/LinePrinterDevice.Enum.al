enum 6014490 "NPR Line Printer Device" implements "NPR ILine Printer"
{
    Extensible = false;

    value(0; Epson)
    {
        Caption = 'Epson';
        Implementation = "NPR ILine Printer" = "NPR RP Epson TM Device Lib.";
    }
    value(1; BixolonDisplay)
    {
        Caption = 'Bixolon Display';
        Implementation = "NPR ILine Printer" = "NPR RP BixolonDisp Device Lib.";
    }
    value(2; Boca)
    {
        Caption = 'Boca';
        Implementation = "NPR ILine Printer" = "NPR RP Boca FGL Device Lib.";
    }
}