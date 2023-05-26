codeunit 6150981 "NPR RS PTFPI Try Print"
{
    Access = Internal;

    #region PRINT FISCAL RECEIPT
    internal procedure PrintReceipt(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    begin
        PrintThermalReceipt(RSPOSAuditLogAuxInfo)
    end;

    internal procedure PrintReceipt(RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy")
    begin
        PrintThermalReceipt(RSPOSAuditLogAuxCopy)
    end;
    #endregion

    #region Journal Text To Thermal Printer Parsers
    local procedure PrintThermalReceipt(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        i: Integer;
        PrintTextList: List of [Text];
        PrintRawInputText: Text;
        PrintText: Text;
    begin
        PrintRawInputText := RSPOSAuditLogAuxInfo.Journal;
        if StrLen(PrintRawInputText) = 0 then
            exit;

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);
        PrintTextList := PrintRawInputText.Split('\r\n');
        // PrintThermalLine(Printer, 'INSERT KEYWORD', 'LOGO', false, 'LEFT', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        for i := 1 to PrintTextList.Count() do begin
            PrintTextList.Get(i, PrintText);
            if i = (PrintTextList.Count() - 1) then
                PrintThermalLine(Printer, RSPOSAuditLogAuxInfo."Verification URL", 'QR', false, 'CENTER', true, false);
            if ShouldSkipPrintLine(PrintText, RSPOSAuditLogAuxInfo."Customer Identification") then
                PrintThermalLine(Printer, PrintText, 'A11', true, 'CENTER', true, false);
        end;
        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS PTFPI Try Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        PrintDiscountNonFiscal(RSPOSAuditLogAuxInfo);
        PrintNonFiscalCopyForNormalRefund(RSPOSAuditLogAuxInfo);
    end;

    local procedure PrintThermalReceipt(RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        i: Integer;
        CustomerSignaturePrintLbl: Label '              Потпис купца              ', Locked = true;
        PrintTextList: List of [Text];
        PrintRawInputText: Text;
        PrintText: Text;
    begin
        PrintRawInputText := RSPOSAuditLogAuxCopy.Journal;
        if StrLen(PrintRawInputText) = 0 then
            exit;

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);
        PrintTextList := PrintRawInputText.Split('\r\n');
        // PrintThermalLine(Printer, 'INSERT KEYWORD', 'LOGO', false, 'LEFT', true, false);6
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        for i := 1 to PrintTextList.Count() do begin
            PrintTextList.Get(i, PrintText);
            if i = (PrintTextList.Count() - 1) then begin
                PrintThermalLine(Printer, RSPOSAuditLogAuxCopy."Verification URL", 'QR', false, 'CENTER', true, false);
                if (RSPOSAuditLogAuxCopy."RS Invoice Type" in [RSPOSAuditLogAuxCopy."RS Invoice Type"::COPY]) and
                (RSPOSAuditLogAuxCopy."RS Transaction Type" in [RSPOSAuditLogAuxCopy."RS Transaction Type"::REFUND]) then
                    if (RSAuditMgt.POSCheckIfPaymentMethodCashAndDirectSale(RSPOSAuditLogAuxCopy."POS Entry No.") or not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) or
                        (RSAuditMgt.DocumentCheckIfPaymentMethodCash(RSPOSAuditLogAuxCopy."Payment Method Code") and not (RSPOSAuditLogAuxCopy."Audit Entry Type" in [RSPOSAuditLogAuxCopy."Audit Entry Type"::"POS Entry"])) then begin
                        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
                        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
                        PrintThermalLine(Printer, CustomerSignaturePrintLbl, 'A11', true, 'CENTER', true, false);
                    end;
            end;
            if ShouldSkipPrintLine(PrintText, RSPOSAuditLogAuxCopy."Customer Identification") then
                PrintThermalLine(Printer, PrintText, 'A11', true, 'CENTER', true, false);
        end;
        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS PTFPI Try Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;
    #endregion

    #region Additional Non-Fiscal (Slip) Printing
    local procedure PrintDiscountNonFiscal(RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        HasDiscountHeadlineLbl: Label 'ОСТВАРИЛИ СТЕ ПОПУСТ', Locked = true;
        TotalDiscountAmountLbl: Label 'Износ попуста: ', Locked = true;
    begin
        if not (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE])
            and not (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) then
            exit;
        if RSPOSAuditLogAuxInfo."Discount Amount" = 0 then
            exit;
        Printer.SetAutoLineBreak(false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, HasDiscountHeadlineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, TotalDiscountAmountLbl + Format(Round(RSPOSAuditLogAuxInfo."Discount Amount", 0.01)), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS PTFPI Try Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintNonFiscalCopyForNormalRefund(var RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info")
    var
        RSPOSAuditLogAuxCopy: Record "NPR RS POS Audit Log Aux. Copy";
    begin
        RSPOSAuditLogAuxInfo.CalcFields("Fiscal Bill Copies");
        if RSPOSAuditLogAuxInfo."Fiscal Bill Copies" and (RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND])
            and (RSPOSAuditLogAuxInfo."RS Invoice Type" in [RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL]) then begin
            RSPOSAuditLogAuxCopy.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type");
            RSPOSAuditLogAuxCopy.SetRange("Audit Entry No.", RSPOSAuditLogAuxInfo."Audit Entry No.");
            RSPOSAuditLogAuxCopy.FindLast();
            PrintThermalReceipt(RSPOSAuditLogAuxCopy);
        end;
    end;
    #endregion

    #region Helper Procedures
    local procedure ShouldSkipPrintLine(PrintText: Text; CustomerIdentification: Code[30]): Boolean
    begin
        case true of
            PrintText.Contains('ИД купца'):
                exit(CustomerIdentification <> '0');
            PrintText.Contains('ЕСИР време'):
                exit(false);
            else
                exit(true);
        end;
    end;
    #endregion

    #region Thermal Printer Processing
    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
    begin
        case true of
            (Font in ['A11', 'B21', 'Control']):
                begin
                    Printer.SetFont(CopyStr(Font, 1, 30));
                    Printer.SetBold(Bold);
                    Printer.SetUnderLine(Underline);

                    case Alignment of
                        'LEFT':
                            Printer.AddTextField(1, 0, Value);
                        'CENTER':
                            Printer.AddTextField(2, 1, Value);
                        'RIGHT':
                            Printer.AddTextField(3, 2, Value);
                    end;
                end;
            (Font in ['QR']):
                Printer.AddBarcode(CopyStr(Font, 1, 30), Value, 5, true, 5);
            (Font in ['COMMAND']):
                begin
                    Printer.SetFont('COMMAND');
                    Printer.AddLine('PAPERCUT');
                end;
            (Font in ['LOGO']):
                begin
                    Printer.SetFont('Logo');
                    Printer.AddLine(Value);
                end;
        end;
        if CR then
            Printer.NewLine();
    end;
    #endregion

    var
        ThermalPrintLineLbl: Label '________________________________________', Locked = true;
}