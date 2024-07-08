codeunit 6184903 "NPR AT Fiscal Thermal Print"
{
    Access = Internal;

    var
        Printer: Codeunit "NPR RP Line Print";
        TwoValuesClosePlaceholderLbl: Label '%1%2', Locked = true, Comment = '%1 - placeholder 1, %2 - placeholder 2';

    #region Print Fiscal Receipt
    internal procedure PrintReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        PrintReceiptNotSupportedErr: Label 'Printing of the receipt is not supported for this receipt type.';
    begin
        case true of
            (ATPOSAuditLogAuxInfo."Audit Entry Type" = Enum::"NPR AT Audit Entry Type"::"POS Entry") and
            (ATPOSAuditLogAuxInfo."Receipt Type" in [Enum::"NPR AT Receipt Type"::NORMAL, Enum::"NPR AT Receipt Type"::TRAINING, Enum::"NPR AT Receipt Type"::CANCELLATION]):
                PrintThermalReceipt(ATPOSAuditLogAuxInfo);
            (ATPOSAuditLogAuxInfo."Audit Entry Type" = Enum::"NPR AT Audit Entry Type"::"Control Transaction") and
            (ATPOSAuditLogAuxInfo."Receipt Type" = Enum::"NPR AT Receipt Type"::NORMAL):
                PrintThermalControlReceipt(ATPOSAuditLogAuxInfo);
            else
                Error(PrintReceiptNotSupportedErr);
        end;
    end;

    local procedure PrintThermalReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        PrintHeader(ATPOSAuditLogAuxInfo);
        PrintContent(ATPOSAuditLogAuxInfo);
        PrintVATBreakdown(ATPOSAuditLogAuxInfo);
        PrintFooter(ATPOSAuditLogAuxInfo);
        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        InsertPrinterDeviceSettings(PrinterDeviceSettings);
        Printer.ProcessBuffer(Codeunit::"NPR AT Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
        SetReceiptPrintedOnATPOSAuditLogAuxInfo(ATPOSAuditLogAuxInfo);
    end;

    local procedure PrintThermalControlReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        PrintHeader(ATPOSAuditLogAuxInfo);
        PrintControlContent();
        PrintControlVATBreakdown();
        PrintFooter(ATPOSAuditLogAuxInfo);
        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        InsertPrinterDeviceSettings(PrinterDeviceSettings);
        Printer.ProcessBuffer(Codeunit::"NPR AT Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
        SetReceiptPrintedOnATPOSAuditLogAuxInfo(ATPOSAuditLogAuxInfo);
    end;

    local procedure InsertPrinterDeviceSettings(var PrinterDeviceSettings: Record "NPR Printer Device Settings")
    begin
        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();
    end;

    local procedure SetReceiptPrintedOnATPOSAuditLogAuxInfo(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    begin
        ATPOSAuditLogAuxInfo."Receipt Printed" := true;
        ATPOSAuditLogAuxInfo.Modify();
    end;
    #endregion

    #region Printing Sections
    local procedure PrintHeader(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        CompanyInfo: Record "Company Information";
        POSStore: Record "NPR POS Store";
        ReceiptCopyLbl: Label 'THIS IS A COPY OF A RECEIPT';
        TwoValuesPlaceholderLbl: Label '%1 %2', Locked = true, Comment = '%1 - placeholder 1, %2 - placeholder 2';
    begin
        CompanyInfo.Get();
        POSStore.Get(ATPOSAuditLogAuxInfo."POS Store Code");

        PrintThermalLine('POSLOGO', 'LOGO', false, 'CENTER', true, false);
        PrintTextOnCenter('', false);

        if ATPOSAuditLogAuxInfo."Receipt Printed" then begin
            PrintDottedLine();
            PrintTextOnCenter(ReceiptCopyLbl, true);
            PrintDottedLine();
        end;

        PrintTextOnCenter(CompanyInfo.Name, true);
        PrintTextOnCenter(POSStore.Name, true);
        PrintTextOnCenter(POSStore.Address, true);
        PrintTextOnCenter(StrSubstNo(TwoValuesPlaceholderLbl, POSStore."Post Code", POSStore.City), true);
        if POSStore."Phone No." <> '' then
            PrintTextOnCenter(StrSubstNo(TwoValuesPlaceholderLbl, POSStore.FieldCaption("Phone No."), POSStore."Phone No."), true);

        PrintTextOnCenter(CompanyInfo."VAT Registration No.", true);
        if POSStore."Home Page" <> '' then
            PrintTextOnCenter(POSStore."Home Page", true);

        PrintTextOnCenter('', false);
    end;

    local procedure PrintContent(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        UnitPrice: Decimal;
        AmountIncludingTaxLbl: Label 'Summe', Locked = true;
        ItemDescriptionLbl: Label 'Artikel', Locked = true;
        LineAmountIncludingVATLbl: Label 'Betrag', Locked = true;
        QuantityLbl: Label 'Mge.', Locked = true;
        UnitPriceLbl: Label 'Preis', Locked = true;
    begin
        PrintFullLine();
        PrintFourColumnText(ItemDescriptionLbl, QuantityLbl, UnitPriceLbl, LineAmountIncludingVATLbl, true);
        PrintDottedLine();

        POSEntrySalesLine.SetRange("POS Entry No.", ATPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetFilter(Quantity, '<>0');
        if POSEntrySalesLine.IsEmpty() then
            exit;

        POSEntrySalesLine.FindSet();

        repeat
            PrintTextOnLeft(POSEntrySalesLine.Description, false);
            UnitPrice := Abs(Round(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity, 0.01));
            PrintFourColumnText(
                '',
                StrSubstNo(TwoValuesClosePlaceholderLbl, Format(Round(POSEntrySalesLine.Quantity, 0.01), 0, '<Precision,0:26><Standard Format,2>'), 'x'),
                StrSubstNo(TwoValuesClosePlaceholderLbl, Format(UnitPrice, 0, '<Precision,2:5><Standard Format,2>'), '€'),
                StrSubstNo(TwoValuesClosePlaceholderLbl, Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:5><Standard Format,2>'), '€'),
                false);
        until POSEntrySalesLine.Next() = 0;

        PrintFullLine();
        PrintTwoColumnText(AmountIncludingTaxLbl, StrSubstNo(TwoValuesClosePlaceholderLbl, Format(ATPOSAuditLogAuxInfo."Amount Incl. Tax", 0, '<Precision,2:5><Standard Format,2>'), '€'), true);
        PrintTextOnCenter('', false);
    end;

    local procedure PrintControlContent()
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
        AmountIncludingTaxLbl: Label 'Summe', Locked = true;
        ItemDescriptionLbl: Label 'Artikel', Locked = true;
        LineAmountIncludingVATLbl: Label 'Betrag', Locked = true;
        QuantityLbl: Label 'Mge.', Locked = true;
        UnitPriceLbl: Label 'Preis', Locked = true;
    begin
        PrintFullLine();
        PrintFourColumnText(ItemDescriptionLbl, QuantityLbl, UnitPriceLbl, LineAmountIncludingVATLbl, true);
        PrintDottedLine();

        PrintTextOnLeft(ATAuditMgt.GetControlReceiptItemText(), false);
        PrintFourColumnText(
            '',
            StrSubstNo(TwoValuesClosePlaceholderLbl, Format(1.00, 0, '<Precision,0:26><Standard Format,2>'), 'x'),
            StrSubstNo(TwoValuesClosePlaceholderLbl, Format(0.00, 0, '<Precision,2:5><Standard Format,2>'), '€'),
            StrSubstNo(TwoValuesClosePlaceholderLbl, Format(0.00, 0, '<Precision,2:5><Standard Format,2>'), '€'),
            false);

        PrintFullLine();
        PrintTwoColumnText(AmountIncludingTaxLbl, StrSubstNo(TwoValuesClosePlaceholderLbl, Format(0.00, 0, '<Precision,2:5><Standard Format,2>'), '€'), true);
        PrintTextOnCenter('', false);
    end;

    local procedure PrintVATBreakdown(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        AmountIncludingTaxLbl: Label 'Betrag', Locked = true;
        TaxBaseAmountLbl: Label 'Grundbetrag', Locked = true;
        TaxPctLbl: Label 'MwSt %', Locked = true;
        VATAmountLbl: Label 'MwSt', Locked = true;
    begin
        PrintDottedLine();
        PrintFourColumnText2(TaxPctLbl, TaxBaseAmountLbl, VATAmountLbl, AmountIncludingTaxLbl, true);
        PrintDottedLine();

        POSEntryTaxLine.SetRange("POS Entry No.", ATPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryTaxLine.IsEmpty() then
            exit;

        POSEntryTaxLine.FindSet();

        repeat
            PrintFourColumnText2(
                StrSubstNo(TwoValuesClosePlaceholderLbl, Format(Round(POSEntryTaxLine."Tax %", 0.1)), '%'),
                Format(POSEntryTaxLine."Tax Base Amount", 0, '<Precision,2:2><Standard Format,2>'),
                Format(POSEntryTaxLine."Tax Amount", 0, '<Precision,2:2><Standard Format,2>'),
                Format(POSEntryTaxLine."Amount Including Tax", 0, '<Precision,2:2><Standard Format,2>'),
                false);
        until POSEntryTaxLine.Next() = 0;

        PrintTextOnCenter('', false);
    end;

    local procedure PrintControlVATBreakdown()
    var
        AmountIncludingTaxLbl: Label 'Betrag', Locked = true;
        TaxBaseAmountLbl: Label 'Grundbetrag', Locked = true;
        TaxPctLbl: Label 'MwSt %', Locked = true;
        VATAmountLbl: Label 'MwSt', Locked = true;
    begin
        PrintDottedLine();
        PrintFourColumnText2(TaxPctLbl, TaxBaseAmountLbl, VATAmountLbl, AmountIncludingTaxLbl, true);
        PrintDottedLine();

        PrintFourColumnText2(
            StrSubstNo(TwoValuesClosePlaceholderLbl, Format(Round(0.0, 0.1)), '%'),
            Format(0.00, 0, '<Precision,2:2><Standard Format,2>'),
            Format(0.00, 0, '<Precision,2:2><Standard Format,2>'),
            Format(0.00, 0, '<Precision,2:2><Standard Format,2>'),
            false);

        PrintTextOnCenter('', false);
    end;

    local procedure PrintFooter(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATCashRegisterSerialNumberLbl: Label 'Kasse identifikation: %1', Locked = true, Comment = '%1 - AT Cash Register Serial Number value';
        POSUnitNoLbl: Label 'Kasse: %1', Locked = true, Comment = '%1 - POS Unit No. value';
        ReceiptNumberLbl: Label 'Rechnungs Nr.: %1', Locked = true, Comment = '%1 - Receipt Number value';
    begin
        PrintTextOnCenter('', false);
        PrintQRCode(ATPOSAuditLogAuxInfo.GetQRCode());
        PrintTextOnCenter('', false);
        PrintTextOnCenter(StrSubstNo(ReceiptNumberLbl, ATPOSAuditLogAuxInfo."Receipt Number"), true);
        PrintTextOnCenter(StrSubstNo(POSUnitNoLbl, ATPOSAuditLogAuxInfo."POS Unit No."), true);
        PrintTextOnCenter(StrSubstNo(ATCashRegisterSerialNumberLbl, ATPOSAuditLogAuxInfo."AT Cash Register Serial Number"), true);
        PrintTextOnCenter(Format(ATPOSAuditLogAuxInfo."Signed At"), true);
        PrintTextOnCenter('', false);

        if ATPOSAuditLogAuxInfo.Hints <> '' then begin
            PrintDottedLine();
            PrintTextOnCenter(ATPOSAuditLogAuxInfo.Hints, true);
            PrintDottedLine();
            PrintTextOnCenter('', false);
        end;
    end;
    #endregion

    #region Printing Procedures
    local procedure PrintThermalLine(Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
    begin
        case true of
            Font in ['A11', 'B21', 'Control']:
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
            Font in ['QR']:
                Printer.AddBarcode(CopyStr(Font, 1, 30), Value, 5, true, 5);
            Font in ['COMMAND']:
                begin
                    Printer.SetFont('COMMAND');
                    Printer.AddLine('PAPERCUT', 0);
                end;
            Font in ['LOGO']:
                begin
                    Printer.SetFont('Logo');
                    Printer.AddLine(Value, 0);
                end;
        end;

        if CR then
            Printer.NewLine();
    end;

    local procedure PrintTextOnCenter(TextToPrint: Text; Bold: Boolean)
    begin
        PrintThermalLine(TextToPrint, 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintTextOnLeft(TextToPrint: Text; Bold: Boolean)
    begin
        PrintThermalLine(TextToPrint.PadRight(40, ' '), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintTwoColumnText(FirstColumnText: Text; SecondColumnText: Text; Bold: Boolean)
    var
        TwoColumnValuesPlaceholderLbl: Label '%1%2', Comment = '%1 - placeholder 1, %2 - placeholder 2';
    begin
        PrintThermalLine(StrSubstNo(TwoColumnValuesPlaceholderLbl, FirstColumnText.PadRight(20, ' '), SecondColumnText.PadLeft(20, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintFourColumnText(FirstColumnText: Text; SecondColumnText: Text; ThirdColumnText: Text; FourthColumnText: Text; Bold: Boolean)
    var
        FourColumnValuesPlaceholderLbl: Label '%1%2%3%4', Locked = true, Comment = '%1 - placeholder 1, %2 - placeholder 2, %3 - placeholder 3, %4 - placeholder 4';
    begin
        PrintThermalLine(StrSubstNo(FourColumnValuesPlaceholderLbl, FirstColumnText.PadRight(10, ' '), SecondColumnText.PadRight(10, ' '), ThirdColumnText.PadLeft(10, ' '), FourthColumnText.PadLeft(10, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintFourColumnText2(FirstColumnText: Text; SecondColumnText: Text; ThirdColumnText: Text; FourthColumnText: Text; Bold: Boolean)
    var
        FourColumnValuesPlaceholderLbl: Label '%1%2%3%4', Locked = true, Comment = '%1 - placeholder 1, %2 - placeholder 2, %3 - placeholder 3, %4 - placeholder 4';
    begin
        PrintThermalLine(StrSubstNo(FourColumnValuesPlaceholderLbl, FirstColumnText.PadRight(10, ' '), SecondColumnText.PadLeft(10, ' '), ThirdColumnText.PadLeft(10, ' '), FourthColumnText.PadLeft(10, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintQRCode(QRCode: Text)
    begin
        PrintThermalLine(QRCode, 'QR', false, 'CENTER', true, false);
    end;

    local procedure PrintDottedLine()
    var
        DottedLineLbl: Label '---------------------------------------------', Locked = true;
    begin
        PrintThermalLine(DottedLineLbl, 'A11', true, 'CENTER', true, false);
    end;

    local procedure PrintFullLine()
    var
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
    begin
        PrintThermalLine(ThermalPrintLineLbl, 'A11', true, 'CENTER', true, false);
    end;
    #endregion
}