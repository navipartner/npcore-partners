codeunit 6248674 "NPR NPRE Static Kitchen Print"
{
    Access = Internal;
    TableNo = "NPR NPRE W.Pad.Line Out.Buffer";

    var
        Printer: Codeunit "NPR RP Line Print";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
    begin
        KitchenPrintMgt.GetPrintLines(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.15, 0.85);
        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);

        AddReceiptInformation(Rec);

        Printer.ProcessBuffer(Codeunit::"NPR NPRE Static Kitchen Print", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddReceiptInformation(var WPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer")
    var
        TempRestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        B21FontLbl: Label 'B21', Locked = true;
        B22FontLbl: Label 'B22', Locked = true;
        B12FontLbl: Label 'B12', Locked = true;
        NumberOfGuestsLbl: Label 'Number of Guests: ';
        KitchenDescriptionLineMaxLength: Integer;
        LastLineNo: Integer;
    begin
        if WPadLineOutBuffer.IsEmpty() then
            exit;

        KitchenPrintMgt.GetPrintHeader(WPadLineOutBuffer."Waiter Pad No.", false, TempRestaurantPrintHeader);

        KitchenDescriptionLineMaxLength := 20; // B22/B12 on 80mm paper = 28 chars/line; col 2 gets 85% = ~20

        Printer.SetFont(B21FontLbl);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);

        //CurrentDateTime
        Printer.AddLine(Format(TempRestaurantPrintHeader."Print Date Time"), 1);

        // Salesperson info
        if TempRestaurantPrintHeader."Waiter Code" <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Waiter Code" + ' / ' + TempRestaurantPrintHeader."Waiter Name", 1);

        // Customer information
        if TempRestaurantPrintHeader."Customer Name" <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Customer Name", 1);
        if TempRestaurantPrintHeader."Customer Phone No." <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Customer Phone No.", 1);

        //Waiter pad seating and number of guests info
        if TempRestaurantPrintHeader."Seating Description" <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Seating Description", 1);
        Printer.AddLine(NumberOfGuestsLbl + Format(TempRestaurantPrintHeader."Number of Guests"), 1);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Kitchen print line information
        if WPadLineOutBuffer.FindLast() then
            LastLineNo := WPadLineOutBuffer."Waiter Pad Line No.";

        if WPadLineOutBuffer.FindSet() then
            repeat
                if WPadLineOutBuffer."Attached to Line No." <> 0 then begin
                    Printer.SetFont(B12FontLbl);
                    PrintWrappedDescriptionLine('  ' + Format(WPadLineOutBuffer.Quantity) + ' x ', '  ' + WPadLineOutBuffer.Description, KitchenDescriptionLineMaxLength, false);
                    Printer.SetFont(B21FontLbl);
                end else begin
                    Printer.SetFont(B22FontLbl);
                    PrintWrappedDescriptionLine(
                        Format(WPadLineOutBuffer.Quantity) + ' x ',
                        WPadLineOutBuffer.Description,
                        KitchenDescriptionLineMaxLength,
                        WPadLineOutBuffer."Line Type" <> WPadLineOutBuffer."Line Type"::Comment);
                    if (WPadLineOutBuffer."Line Type" = WPadLineOutBuffer."Line Type"::Comment) and (WPadLineOutBuffer."Waiter Pad Line No." <> LastLineNo) then
                        Printer.AddLine('', 0);
                end;
            until WPadLineOutBuffer.Next() = 0;

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;

    local procedure PrintWrappedDescriptionLine(LeftColumnText: Text; DescriptionText: Text; MaxLineLength: Integer; Bold: Boolean)
    var
        RemainingText: Text;
        TextChunk: Text;
    begin
        RemainingText := DelChr(DescriptionText, '<', ' ');

        Printer.SetBold(Bold);

        Printer.AddTextField(1, 0, LeftColumnText);
        TextChunk := GetNextTextChunk(RemainingText, MaxLineLength);
        Printer.AddTextField(2, 0, TextChunk);

        while RemainingText <> '' do begin
            Printer.NewLine();
            Printer.AddTextField(1, 0, '');
            TextChunk := GetNextTextChunk(RemainingText, MaxLineLength);
            Printer.AddTextField(2, 0, TextChunk);
        end;

        Printer.SetBold(false);
    end;

    local procedure GetNextTextChunk(var RemainingText: Text; MaxLineLength: Integer): Text
    var
        ChunkText: Text;
        SplitPosition: Integer;
        i: Integer;
    begin
        if StrLen(RemainingText) <= MaxLineLength then begin
            ChunkText := RemainingText;
            RemainingText := '';
            exit(ChunkText);
        end;

        ChunkText := CopyStr(RemainingText, 1, MaxLineLength);
        for i := StrLen(ChunkText) downto 1 do
            if ChunkText[i] = ' ' then begin
                SplitPosition := i;
                break;
            end;

        if SplitPosition > 0 then begin
            ChunkText := DelChr(CopyStr(ChunkText, 1, SplitPosition - 1), '>', ' ');
            RemainingText := DelChr(CopyStr(RemainingText, SplitPosition + 1), '<', ' ');
        end else
            RemainingText := DelChr(CopyStr(RemainingText, MaxLineLength + 1), '<', ' ');

        exit(ChunkText);
    end;
}
