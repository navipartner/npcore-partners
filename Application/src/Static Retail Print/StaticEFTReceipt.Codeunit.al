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
                AddEFTReceiptText(EFTReceipt.Text, 28); // B21 font on 80mm Epson = 28 chars per line
            until EFTReceipt.Next() = 0;

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;

    local procedure AddEFTReceiptText(LineText: Text; MaxLineLength: Integer)
    var
        Words: List of [Text];
        Word: Text;
        CurrentLine: Text;
    begin
        if DelChr(LineText, '=', ' ') = '' then begin
            Printer.AddLine('', 0);
            exit;
        end;

        Words := LineText.Split(' ');

        foreach Word in Words do
            CurrentLine := AppendWord(CurrentLine, Word, MaxLineLength);

        if CurrentLine <> '' then
            Printer.AddLine(CurrentLine, 0);
    end;

    local procedure AppendWord(CurrentLine: Text; Word: Text; MaxLineLength: Integer): Text
    begin
        if StrLen(Word) > MaxLineLength then begin
            if CurrentLine <> '' then
                Printer.AddLine(CurrentLine, 0);
            PrintLongWord(Word, MaxLineLength);
            exit('');
        end;

        if CurrentLine = '' then
            exit(Word);

        if StrLen(CurrentLine) + 1 + StrLen(Word) <= MaxLineLength then
            exit(CurrentLine + ' ' + Word);

        Printer.AddLine(CurrentLine, 0);
        exit(Word);
    end;

    local procedure PrintLongWord(Word: Text; MaxLineLength: Integer)
    var
        StartPos: Integer;
    begin
        StartPos := 1;
        while StartPos <= StrLen(Word) do begin
            Printer.AddLine(CopyStr(Word, StartPos, MaxLineLength), 0);
            StartPos += MaxLineLength;
        end;
    end;
}
