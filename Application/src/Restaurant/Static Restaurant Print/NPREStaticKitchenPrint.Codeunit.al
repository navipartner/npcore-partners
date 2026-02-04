codeunit 6248674 "NPR NPRE Static Kitchen Print"
{
    Access = Internal;
    TableNo = "NPR NPRE Waiter Pad Line";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.15, 0.85);
        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);

        AddReceiptInformation(Rec);

        Printer.ProcessBuffer(Codeunit::"NPR NPRE Static Kitchen Print", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddReceiptInformation(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        SeatWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        LastWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        B21FontLbl: Label 'B21', Locked = true;
        A11FontLbl: Label 'A11', Locked = true;
        NumberOfGuestsLbl: Label 'Number of Guests: ';
        LastLineNo: Integer;
    begin
        if not WaiterPad.Get(WaiterPadLine."Waiter Pad No.") then
            exit;

        Printer.SetFont(B21FontLbl);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);

        //CurrentDateTime
        Printer.AddLine(Format(CurrentDateTime), 1);

        // Salesperson info
        if SalespersonPurchaser.Get(WaiterPad."Assigned Waiter Code") then
            Printer.AddLine(SalespersonPurchaser.Code + ' / ' + SalespersonPurchaser.Name, 1);

        // Customer information
        if Customer.Get(WaiterPad."Customer No.") and (Customer.Name <> '') then
            Printer.AddLine(Customer.Name, 1);
        if WaiterPad."Customer Phone No." <> '' then
            Printer.AddLine(WaiterPad."Customer Phone No.", 1);

        //Waiter pad seating and number of guests info
        SeatWaiterPadLink.SetLoadFields("Seating Code");
        SeatWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        if SeatWaiterPadLink.FindFirst() then begin
            Seating.SetLoadFields("Seating Location", Description);
            if Seating.Get(SeatWaiterPadLink."Seating Code") then
                Printer.AddLine(Seating.Description, 1);
        end;
        Printer.AddLine(NumberOfGuestsLbl + Format(WaiterPad."Number of Guests"), 1);

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);

        // Waiter Pad Line information
        LastWaiterPadLine.Copy(WaiterPadLine);
        LastWaiterPadLine.SetLoadFields("Line No.");
        if LastWaiterPadLine.FindLast() then
            LastLineNo := LastWaiterPadLine."Line No.";

        if WaiterPadLine.FindSet() then
            repeat
                if WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Comment then
                    Printer.SetFont(A11FontLbl);
                Printer.SetBold(true);
                Printer.AddTextField(1, 0, Format(WaiterPadLine.Quantity) + ' x ');
                Printer.AddTextField(2, 0, WaiterPadLine.Description);
                Printer.SetBold(false);
                if WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Comment then begin
                    Printer.SetFont(B21FontLbl);
                    if WaiterPadLine."Line No." <> LastLineNo then
                        Printer.AddLine('', 0);
                end;
            until WaiterPadLine.Next() = 0;

        Printer.SetFont('COMMAND');
        Printer.AddLine('PAPERCUT', 0);
    end;
}
