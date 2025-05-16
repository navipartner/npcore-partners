codeunit 6248443 "NPR ReceiptPrintUtilities"
{
    /// This function is used to add a footer text to the receipt.
    /// It returns true if the footer text was added successfully, otherwise false.
    procedure AddReceiptFooterText(POSUnitNo: Code[10]; var Printer: Codeunit "NPR RP Line Print"; Alignment: Integer): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
    begin
        POSUnit.SetLoadFields("POS Unit Receipt Text Profile");
        POSUnit.Get(POSUnitNo);

        POSUnitRcptTxtProfile.SetLoadFields(Code);
        if (not POSUnitRcptTxtProfile.Get(POSUnit."POS Unit Receipt Text Profile")) then
            exit(false);

        POSTicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitRcptTxtProfile.Code);
        if (not POSTicketRcptText.FindSet()) then
            exit(false);

        repeat
            Printer.AddLine(POSTicketRcptText."Receipt Text", Alignment);
        until (POSTicketRcptText.Next() = 0);
        exit(true);
    end;

    /// This function is used to check if the receipt is a reprint.
    procedure IsReprint(POSEntryNo: Integer): Boolean
    var
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
    begin
        //POS Entry Output Log is inserted after printing receipt, therefore this check works
        //to determine if the receipt is a reprint or not.
        POSEntryOutputLog.SetFilter("POS Entry No.", '=%1', POSEntryNo);
        exit(not POSEntryOutputLog.IsEmpty());
    end;

}