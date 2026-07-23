codeunit 6151143 "NPR Static Begin Workshift"
{
    Access = Internal;
    TableNo = "NPR POS Workshift Checkpoint";

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        Printer.SetAutoLineBreak(true);
        Printer.SetTwoColumnDistribution(0.60, 0.40);
        AddContent(Rec);
        Printer.ProcessBuffer(Codeunit::"NPR Static Begin Workshift", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    local procedure AddContent(WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        RetailLogo: Record "NPR Retail Logo";
        POSUnit: Record "NPR POS Unit";
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        FloatLabel: Text;
        CommandFontLbl: Label 'COMMAND', Locked = true;
        LogoFontLbl: Label 'Logo', Locked = true;
        ReceiptLogoLbl: Label 'RECEIPT', Locked = true;
        A11FontLbl: Label 'A11', Locked = true;
        B22FontLbl: Label 'B22', Locked = true;
        PapercutLbl: Label 'PAPERCUT', Locked = true;
        BeginWorkshiftLbl: Label 'BEGIN WORK SHIFT';
        CurrenciesLbl: Label 'Currencies';
        AmountLbl: Label 'Amount';
        SignatureLbl: Label 'Signature';
    begin
        RetailLogo.SetRange("Register No.", WorkshiftCheckpoint."POS Unit No.");
        if RetailLogo.IsEmpty() then
            RetailLogo.SetRange("Register No.", '');
        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);
        if RetailLogo.FindFirst() then begin
            Printer.SetFont(LogoFontLbl);
            Printer.AddLine(ReceiptLogoLbl, 1);
            Printer.SetFont(A11FontLbl);
        end;

        Printer.SetFont(B22FontLbl);
        Printer.AddLine(BeginWorkshiftLbl, 1);
        Printer.SetFont(A11FontLbl);

        if POSUnit.Get(WorkshiftCheckpoint."POS Unit No.") then
            Printer.AddLine(WorkshiftCheckpoint."POS Unit No." + ': ' + POSUnit.Name + ' - ' + Format(WorkshiftCheckpoint."Created At"), 1)
        else
            Printer.AddLine(WorkshiftCheckpoint."POS Unit No." + ' - ' + Format(WorkshiftCheckpoint."Created At"), 1);

        POSPaymentBinCheckp.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckp.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpoint."Entry No.");
        if POSPaymentBinCheckp.FindSet() then begin
            Printer.SetBold(true);
            Printer.AddTextField(1, 0, CurrenciesLbl);
            Printer.AddTextField(2, 2, AmountLbl);
            Printer.SetBold(false);
            Printer.SetPadChar('_');
            Printer.AddLine('', 0);
            Printer.SetPadChar('');
            repeat
                Printer.SetBold(true);
                if POSPaymentBinCheckp.Description <> '' then
                    Printer.AddLine(POSPaymentBinCheckp."Payment Method No." + ' - ' + POSPaymentBinCheckp.Description, 0)
                else
                    Printer.AddLine(POSPaymentBinCheckp."Payment Method No.", 0);
                Printer.SetBold(false);
                FloatLabel := POSPaymentBinCheckp.FieldCaption("Float Amount");
                if POSPaymentBinCheckp."Currency Code" <> '' then
                    FloatLabel += ' (' + POSPaymentBinCheckp."Currency Code" + ')';
                Printer.AddTextField(1, 0, FloatLabel);
                Printer.AddTextField(2, 2, FormatAmt(POSPaymentBinCheckp."New Float Amount"));
            until POSPaymentBinCheckp.Next() = 0;
        end;

        Printer.SetPadChar('-');
        Printer.AddLine('', 0);
        Printer.SetPadChar('');
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine('', 0);
        Printer.AddLine(SignatureLbl, 1);

        Printer.SetFont(CommandFontLbl);
        Printer.AddLine(PapercutLbl, 0);
    end;

    local procedure FormatAmt(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;
}
