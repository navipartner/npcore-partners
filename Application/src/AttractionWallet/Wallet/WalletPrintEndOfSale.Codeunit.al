codeunit 6185079 "NPR WalletPrintEndOfSale"
{
    TableNo = "NPR AttractionWallet";
    Access = Internal;

    trigger OnRun()
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Wallet: Record "NPR AttractionWallet";
    begin
        Wallet.CopyFilters(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        if (Wallet.FindFirst()) then
            PrintOne(Wallet);

        Printer.ProcessBuffer(Codeunit::"NPR TM Report - Ticket", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    local procedure PrintOne(Wallet: Record "NPR AttractionWallet")
    var
    begin
        if (Wallet.Description = '') then
            Wallet.Description := 'Wallet';

        Printer.SetFont('COMMAND');
        Printer.AddLine('STOREDLOGO_1', 0);
        Printer.SetFont('A11');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
        Printer.AddLine(' ', 0);

        Printer.SetBold(true);
        Printer.SetFont('A11');
        Printer.AddLine(Wallet.Description, 0);

        Printer.AddBarcode('QR', Wallet.ReferenceNumber, 6, false, 0);
        Printer.AddLine(' ', 0);

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}
