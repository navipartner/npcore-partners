codeunit 6151588 "NPR SI Fiscal Thermal Print"
{
    Access = Internal;

    var
        Printer: Codeunit "NPR RP Line Print";
        TwoValueFormatLbl: Label '%1 %2', Locked = true, Comment = '%1 = First Value, %2 = Second Value';

    internal procedure PrintReceipt(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    begin
        PrintThermalReceipt(SIPOSAuditLogAuxInfo);
    end;

    local procedure PrintThermalReceipt(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        PrintHeader(SIPOSAuditLogAuxInfo);

        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                PrintPOSEntryContent(SIPOSAuditLogAuxInfo);
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                PrintSalesInvoiceContent(SIPOSAuditLogAuxInfo);
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                PrintSalesCreditMemoContent(SIPOSAuditLogAuxInfo);
        end;

        PrintFooter(SIPOSAuditLogAuxInfo);

        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR SI Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        SIPOSAuditLogAuxInfo."Receipt Printed" := true;
        SIPOSAuditLogAuxInfo.Modify();
    end;

    #region SI Fiscal Thermal Print - Printing Sections
    local procedure PrintHeader(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        CompanyInfo: Record "Company Information";
        POSStore: Record "NPR POS Store";
        CompanyAddressFormatLbl: Label '%1, %2 %3', Locked = true, Comment = '%1 = Address, %2 = Post Code, %3 = City';
        DateFormatLbl: Label 'Dne: %1, %2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        IDStLbl: Label 'ID. ŠT.: %1', Locked = true, Comment = '%1 = Company Registration Number';
        ReceiptCopyLbl: Label 'THIS IS A COPY %1 OF A RECEIPT', Comment = '%1 = Receipt Copy No.';
        ReceiptNoLbl: Label 'Št. računa: %1-%2-%3', Locked = true, Comment = '%1 = POS Store Code, %2 = POS Unit No., %3 = Receipt No.';
    begin
        CompanyInfo.Get();
        POSStore.Get(SIPOSAuditLogAuxInfo."POS Store Code");

        PrintThermalLine('POSLOGO', 'LOGO', false, 'CENTER', true, false);

        if SIPOSAuditLogAuxInfo."Receipt Printed" then begin
            SIPOSAuditLogAuxInfo."Copies Printed" += 1;
            PrintDottedLine();
            PrintTextLine(StrSubstNo(ReceiptCopyLbl, SIPOSAuditLogAuxInfo."Copies Printed"), true);
            PrintDottedLine();
        end;

        PrintTextLine(CompanyInfo.Name, true);
        PrintTextLine(POSStore.Name, true);
        PrintTextLine(StrSubstNo(CompanyAddressFormatLbl, POSStore.Address, POSStore."Post Code", POSStore.City), true);
        PrintTextLine(StrSubstNo(IDStLbl, CompanyInfo."Registration No."), true);
        PrintFullLine();

        PrintTextLine(StrSubstNo(DateFormatLbl, Format(SIPOSAuditLogAuxInfo."Entry Date", 10, '<Day,2>.<Month,2>.<Year4>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24>:<Minutes,2>:<Seconds,2>')), true);
        PrintTextLine(StrSubstNo(ReceiptNoLbl, SIPOSAuditLogAuxInfo."POS Store Code", SIPOSAuditLogAuxInfo."POS Unit No.", SIPOSAuditLogAuxInfo."Receipt No."), true);
    end;

    local procedure PrintPOSEntryContent(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        FinalBillLbl: Label 'SKUPAJ EUR', Locked = true;
        ItemDescLbl: Label 'Postavka', Locked = true;
        ItemPriceLbl: Label 'Skupaj €', Locked = true;
        QtyLbl: Label 'Kol', Locked = true;
        UnitPriceLbl: Label 'Cena', Locked = true;
        AmountInclVATLbl: Label 'Vrednost', Locked = true;
        VATAmountLbl: Label 'DDV', Locked = true;
        VATBaseLbl: Label 'Osnova', Locked = true;
        VATPercLbl: Label 'Stopnja', Locked = true;
        SalesLineType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
    begin
        PrintDottedLine();
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, true);
        PrintDottedLine();

        POSEntrySalesLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', SalesLineType::Item, SalesLineType::Voucher);
        if not POSEntrySalesLine.FindSet() then
            exit;
        repeat
            PrintTextLine(POSEntrySalesLine.Description, false);
            PrintFourColumnText(Format(POSEntrySalesLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(POSEntrySalesLine."Unit Price"), FormatDecimal(POSEntrySalesLine."Amount Incl. VAT"), false);
        until POSEntrySalesLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), true);
        PrintTextLine('', false);

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, true);
        PrintDottedLine();

        POSEntryTaxLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        if not POSEntryTaxLine.FindSet() then
            exit;
        repeat
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(POSEntryTaxLine."Tax %", 0.1)), '%'), FormatDecimal(POSEntryTaxLine."Tax Base Amount"), FormatDecimal(POSEntryTaxLine."Tax Amount"), FormatDecimal(POSEntryTaxLine."Amount Including Tax"), false);
        until POSEntryTaxLine.Next() = 0;
    end;

    local procedure PrintSalesInvoiceContent(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        FinalBillLbl: Label 'SKUPAJ EUR', Locked = true;
        ItemDescLbl: Label 'Postavka', Locked = true;
        ItemPriceLbl: Label 'Skupaj €', Locked = true;
        QtyLbl: Label 'Kol', Locked = true;
        UnitPriceLbl: Label 'Cena', Locked = true;
        AmountInclVATLbl: Label 'Vrednost', Locked = true;
        VATAmountLbl: Label 'DDV', Locked = true;
        VATBaseLbl: Label 'Osnova', Locked = true;
        VATPercLbl: Label 'Stopnja', Locked = true;
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
    begin
        PrintDottedLine();
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, true);
        PrintDottedLine();

        SalesInvoiceLine.SetLoadFields(Description, Quantity, "Unit Price", "VAT Base Amount", "VAT %", "Amount Including VAT");
        SalesInvoiceLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.FindSet();
        repeat
            PrintTextLine(SalesInvoiceLine.Description, false);
            PrintFourColumnText(Format(SalesInvoiceLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(SalesInvoiceLine."Unit Price"), FormatDecimal(SalesInvoiceLine."Amount Including VAT"), false);

            AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
        until SalesInvoiceLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), true);
        PrintTextLine('', false);

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, true);
        PrintDottedLine();

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(AmountInclTaxDict.Get(DictKey)), false);
        end;
    end;

    local procedure PrintSalesCreditMemoContent(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        FinalBillLbl: Label 'SKUPAJ EUR', Locked = true;
        ItemDescLbl: Label 'Postavka', Locked = true;
        ItemPriceLbl: Label 'Skupaj €', Locked = true;
        QtyLbl: Label 'Kol', Locked = true;
        UnitPriceLbl: Label 'Cena', Locked = true;
        AmountInclVATLbl: Label 'Vrednost', Locked = true;
        VATAmountLbl: Label 'DDV', Locked = true;
        VATBaseLbl: Label 'Osnova', Locked = true;
        VATPercLbl: Label 'Stopnja', Locked = true;
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
    begin
        PrintDottedLine();
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, true);
        PrintDottedLine();

        SalesCrMemoLine.SetLoadFields(Description, Quantity, "Unit Price", "VAT Base Amount", "VAT %", "Amount Including VAT");
        SalesCrMemoLine.SetAutoCalcFields("Amount Including VAT");
        SalesCrMemoLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.FindSet();
        repeat
            PrintTextLine(SalesCrMemoLine.Description, false);
            PrintFourColumnText(Format(SalesCrMemoLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(SalesCrMemoLine."Unit Price"), FormatDecimal(SalesCrMemoLine."Amount Including VAT"), false);

            AddAmountToDecimalDict(TaxableAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT");
        until SalesCrMemoLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), true);
        PrintTextLine('', false);

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, true);
        PrintDottedLine();

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(AmountInclTaxDict.Get(DictKey)), false);
        end;
    end;

    local procedure PrintFooter(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        CashierIDLbl: Label 'Račun izdal: %1', Locked = true, Comment = '%1 = Cashier ID';
    begin
        PrintFullLine();
        PrintTextLine(StrSubstNo(CashierIDLbl, SIPOSAuditLogAuxInfo."Cashier ID"), true);
        PrintTextLine('', false);
        PrintTextLine(StrSubstNo(TwoValueFormatLbl, 'ZOI:', SIPOSAuditLogAuxInfo."ZOI Code"), true);
        PrintTextLine(StrSubstNo(TwoValueFormatLbl, 'EOR:', SIPOSAuditLogAuxInfo."EOR Code"), true);
        PrintTextLine('', false);

        PrintQRCode(SIPOSAuditLogAuxInfo."Validation Code");
    end;

    #endregion

    #region SI Fiscal Thermal Print - Printing Procedures

    local procedure PrintThermalLine(Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
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
                    Printer.AddLine('PAPERCUT', 0);
                end;
            (Font in ['LOGO']):
                begin
                    Printer.SetFont('Logo');
                    Printer.AddLine(Value, 0);
                end;
        end;
        if CR then
            Printer.NewLine();
    end;

    local procedure PrintTextLine(TextToPrint: Text; Bold: Boolean)
    begin
        PrintThermalLine(TextToPrint.PadRight(40, ' '), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintTwoColumnText(FirstColumnText: Text; SecondColumnText: Text; Bold: Boolean)
    var
        TwoColumnValuesLbl: Label '%1%2', Locked = true, Comment = '%1 = First Value, %2 = Second Value';
    begin
        PrintThermalLine(StrSubstNo(TwoColumnValuesLbl, FirstColumnText.PadRight(20, ' '), SecondColumnText.PadLeft(20, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintFourColumnText(FirstColumnText: Text; SecondColumnText: Text; ThirdColumnText: Text; FourthColumnText: Text; Bold: Boolean)
    var
        FourColumnValuesLbl: Label '%1%2%3%4', Locked = true, Comment = '%1 = First Value, %2 = Second Value, %3 = Third Value, %4 = Fourth Value';
    begin
        PrintThermalLine(StrSubstNo(FourColumnValuesLbl, FirstColumnText.PadRight(10, ' '), SecondColumnText.PadRight(10, ' '), ThirdColumnText.PadLeft(10, ' '), FourthColumnText.PadLeft(10, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintQRCode(QRCodeValue: Text)
    begin
        PrintThermalLine(QRCodeValue, 'QR', false, 'CENTER', true, false);
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

    #region SI Fiscal Thermal Print - Formatting

    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    #endregion

    #region SI Fiscal Thermal Print - Helper Procedures

    local procedure AddAmountToDecimalDict(var DecimalDict: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDict.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDict.Get(DictKey) + DictValue;
        DecimalDict.Set(DictKey, BaseAmount);
    end;

    #endregion
}