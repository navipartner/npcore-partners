codeunit 6248352 "NPR Static EFT Receipt"
{
    Access = Internal;
    TableNo = "NPR EFT Receipt";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        AddReceiptInformation(Rec);

        Printer.ProcessBuffer(Codeunit::"NPR Static EFT Receipt", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddReceiptInformation(var EFTReceipt: Record "NPR EFT Receipt")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        B21FontLbl: Label 'B21', Locked = true;
        Caption_Copy: Label '*** Copy ***';
    begin
        Printer.SetFont(B21FontLbl);
        if EFTTransactionRequest.Get(EFTReceipt."EFT Trans. Request Entry No.") and (EFTTransactionRequest."No. of Reprints" > 0) then
            Printer.AddLine(Caption_Copy, 0);

        if EFTReceipt.FindSet() then
            repeat
                Printer.AddLine(EFTReceipt.Text, 0);
            until EFTReceipt.Next() = 0;

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}
