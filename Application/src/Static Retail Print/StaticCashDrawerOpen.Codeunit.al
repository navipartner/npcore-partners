codeunit 6151272 "NPR Static Cash Drawer Open"
{
    Access = Internal;
    TableNo = "NPR POS Payment Bin";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
        CommandFontLbl: Label 'COMMAND', Locked = true;
        OpenDrawerLbl: Label 'OPENDRAWER', Locked = true;
    begin
        Printer.SetFont(CommandFontLbl);
        Printer.AddLine(OpenDrawerLbl, 0);
        Printer.ProcessBuffer(Codeunit::"NPR Static Cash Drawer Open", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;
}
