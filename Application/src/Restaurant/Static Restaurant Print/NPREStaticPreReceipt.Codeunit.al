codeunit 6248673 "NPR NPRE Static Pre Receipt"
{
    Access = Internal;
    TableNo = "NPR NPRE Waiter Pad";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.4, 0.6);
        Printer.SetThreeColumnDistribution(0.1, 0.7, 0.2);

        AddReceiptInformation(Rec);

        Printer.ProcessBuffer(Codeunit::"NPR NPRE Static Pre Receipt", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddReceiptInformation(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        RetailLogo: Record "NPR Retail Logo";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SeatWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        AmountInclVat: Decimal;
        AmountExclVat: Decimal;
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
        Printer.SetFont(B21FontLbl);
        Printer.SetBold(true);
        Printer.AddLine(PreReceiptLbl, 1);
        Printer.SetBold(false);
        Printer.SetFont(A11FontLbl);

        // Logo section
        RetailLogo.SetRange("Register No.", POSUnit.GetCurrentPOSUnit());
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindFirst() then begin
            Printer.SetFont(LogoFontLbl);
            Printer.AddLine(ReceiptLogoLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        Printer.AddLine('', 0);

        // POS Store information
        SeatWaiterPadLink.SetLoadFields("Seating Code");
        SeatWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if SeatWaiterPadLink.FindFirst() then begin
            Seating.SetLoadFields("Seating Location", "Seating No.", Description);
            if Seating.Get(SeatWaiterPadLink."Seating Code") then begin
                SeatingLocation.SetLoadFields("POS Store");
                if SeatingLocation.Get(Seating."Seating Location") then
                    if POSStore.Get(SeatingLocation."POS Store") then begin
                        if POSStore.Address <> '' then
                            Printer.AddLine(POSStore.Address, 1);

                        if (POSStore."Post Code" <> '') or (POSStore.City <> '') then
                            Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City, 1);

                        if POSStore."Phone No." <> '' then
                            Printer.AddLine(PhoneNoLbl + POSStore."Phone No.", 1);

                        if POSStore."VAT Registration No." <> '' then
                            Printer.AddLine(VATRegistrationNoLbl + POSStore."VAT Registration No.", 1);
                    end;
            end;
        end;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Waiter Pad Line information
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.FindSet() then
            repeat
                Printer.AddTextField(1, 0, Format(WaiterPadLine.Quantity) + ' x ');
                Printer.AddTextField(2, 0, WaiterPadLine.Description);
                Printer.AddTextField(3, 2, Format(WaiterPadLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
            until WaiterPadLine.Next() = 0;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Total Amt. Incl. VAT
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.CalcSums("Amount Incl. VAT");
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, WaiterPadLine.FieldCaption("Amount Incl. VAT"));
        Printer.AddTextField(2, 2, Format(WaiterPadLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(false);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Seating no., description and no. of guests info
        if Seating."Seating No." <> '' then begin
            Printer.SetBold(true);
            Printer.AddLine(Seating."Seating No.", 1);
            Printer.SetBold(false);
        end;
        if Seating.Description <> '' then begin
            Printer.SetBold(true);
            Printer.AddLine(Seating.Description, 1);
            Printer.SetBold(false);
        end;
        if WaiterPad.Description <> '' then
            Printer.AddLine(WaiterPad.Description, 0);
        Printer.SetBold(true);
        Printer.AddLine(NumberOfGuestsLbl + Format(WaiterPad."Number of Guests"), 1);
        Printer.SetBold(false);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        //Totals excl. and incl. vat
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.CalcSums("Amount Incl. VAT");
        AmountInclVat := WaiterPadLine."Amount Incl. VAT";
        WaiterPadLine.CalcSums("Amount Excl. VAT");
        AmountExclVat := WaiterPadLine."Amount Excl. VAT";
        Printer.AddTextField(1, 0, WaiterPadLine.FieldCaption("Amount Excl. VAT"));
        Printer.AddTextField(2, 2, Format(AmountExclVat, 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, VATAmountLbl);
        Printer.AddTextField(2, 2, Format(AmountInclVat - AmountExclVat, 0, '<Precision,2:2><Standard Format,2>'));
        Printer.SetBold(false);

        //CurrentDateTime
        Printer.AddLine(Format(CurrentDateTime), 0);

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}
