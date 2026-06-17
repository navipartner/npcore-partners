codeunit 6248673 "NPR NPRE Static Pre Receipt"
{
    Access = Internal;
    TableNo = "NPR NPRE W.Pad.Line Out.Buffer";

    var
        Printer: Codeunit "NPR RP Line Print";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        if not Rec.FindFirst() then
            exit;

        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.4, 0.6);
        Printer.SetThreeColumnDistribution(0.1, 0.7, 0.2);

        AddReceiptInformation(Rec."Waiter Pad No.");

        Printer.ProcessBuffer(Codeunit::"NPR NPRE Static Pre Receipt", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddReceiptInformation(WaiterPadNo: Code[20])
    var
        TempRestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary;
        TempBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        PreReceiptLbl: Label 'PRE-RECEIPT';
        A11FontLbl: Label 'A11', Locked = true;
        B21FontLbl: Label 'B21', Locked = true;
        PhoneNoLbl: Label 'Phone No.';
        VATRegistrationNoLbl: Label 'VAT Registration No.';
        NumberOfGuestsLbl: Label 'Number of Guests: ';
        VATAmountLbl: Label 'VAT Amount';
    begin
        KitchenPrintMgt.GetPrintHeader(WaiterPadNo, true, TempRestaurantPrintHeader);
        KitchenPrintMgt.GetPrintLines(WaiterPadNo, TempBuffer);

        Printer.SetFont(B21FontLbl);
        Printer.SetBold(true);
        Printer.AddLine(PreReceiptLbl, 1);
        Printer.SetBold(false);
        Printer.SetFont(A11FontLbl);

        // Logo section
        if TempRestaurantPrintHeader."Has Receipt Logo" then begin
            Printer.SetFont(LogoFontLbl);
            Printer.AddLine(ReceiptLogoLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        Printer.AddLine('', 0);

        // POS Store information
        if TempRestaurantPrintHeader."Store Address" <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Store Address", 1);

        if (TempRestaurantPrintHeader."Store Post Code" <> '') or (TempRestaurantPrintHeader."Store City" <> '') then
            Printer.AddLine(TempRestaurantPrintHeader."Store Post Code" + ' ' + TempRestaurantPrintHeader."Store City", 1);

        if TempRestaurantPrintHeader."Store Phone No." <> '' then
            Printer.AddLine(PhoneNoLbl + TempRestaurantPrintHeader."Store Phone No.", 1);

        if TempRestaurantPrintHeader."Store VAT Registration No." <> '' then
            Printer.AddLine(VATRegistrationNoLbl + TempRestaurantPrintHeader."Store VAT Registration No.", 1);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Line information
        if TempBuffer.FindSet() then
            repeat
                if TempBuffer."Attached to Line No." <> 0 then begin
                    Printer.AddTextField(1, 0, '  ' + Format(TempBuffer.Quantity) + ' x ');
                    Printer.AddTextField(2, 0, '  ' + TempBuffer.Description);
                end else begin
                    Printer.AddTextField(1, 0, Format(TempBuffer.Quantity) + ' x ');
                    Printer.AddTextField(2, 0, TempBuffer.Description);
                end;
                Printer.AddTextField(3, 2, Format(TempBuffer."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
            until TempBuffer.Next() = 0;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Total Amt. Incl. VAT
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, TempBuffer.FieldCaption("Amount Incl. VAT"));
        Printer.AddTextField(2, 2, Format(TempRestaurantPrintHeader."Total Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(false);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Seating no., description and no. of guests info
        if TempRestaurantPrintHeader."Seating No." <> '' then begin
            Printer.SetBold(true);
            Printer.AddLine(TempRestaurantPrintHeader."Seating No.", 1);
            Printer.SetBold(false);
        end;
        if TempRestaurantPrintHeader."Seating Description" <> '' then begin
            Printer.SetBold(true);
            Printer.AddLine(TempRestaurantPrintHeader."Seating Description", 1);
            Printer.SetBold(false);
        end;
        if TempRestaurantPrintHeader."Waiter Pad Description" <> '' then
            Printer.AddLine(TempRestaurantPrintHeader."Waiter Pad Description", 0);
        Printer.SetBold(true);
        Printer.AddLine(NumberOfGuestsLbl + Format(TempRestaurantPrintHeader."Number of Guests"), 1);
        Printer.SetBold(false);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Totals excl. and incl. vat
        Printer.AddTextField(1, 0, TempBuffer.FieldCaption("Amount Excl. VAT"));
        Printer.AddTextField(2, 2, Format(TempRestaurantPrintHeader."Total Amount Excl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATAmountLbl);
        Printer.AddTextField(2, 2, Format(TempRestaurantPrintHeader."Total Amount Incl. VAT" - TempRestaurantPrintHeader."Total Amount Excl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(false);

        //CurrentDateTime
        Printer.AddLine(Format(TempRestaurantPrintHeader."Print Date Time"), 0);

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}
