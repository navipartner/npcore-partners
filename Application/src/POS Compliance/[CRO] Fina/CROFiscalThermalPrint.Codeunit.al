codeunit 6151584 "NPR CRO Fiscal Thermal Print"
{
    Access = Internal;

    var
        Printer: Codeunit "NPR RP Line Print";
        AmountPaidLbl: Label 'PLAĆENO:', Locked = true;
        FinalBillLbl: Label 'ZA PLATITI €', Locked = true;
        ItemDescLbl: Label 'Artikal', Locked = true;
        LineAmountLbl: Label 'Iznos €', Locked = true;
        PriceLbl: Label 'Cijena', Locked = true;
        QtyLbl: Label 'Kol', Locked = true;
        TwoValueFormatLbl: Label '%1 %2', Locked = true;
        VATAmountLbl: Label 'PDV', Locked = true;
        VATBaseLbl: Label 'Osnovica', Locked = true;
        VATPercLbl: Label 'Porez', Locked = true;
        VATTotalLbl: Label 'Ukupno', Locked = true;

    #region CRO Fiscal Thermal Print - Receipt Print

    internal procedure PrintReceipt(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    begin
        case CROPOSAuditLogAuxInfo."Audit Entry Type" of
            "NPR CRO Audit Entry Type"::"POS Entry":
                PrintPOSThermalReceipt(CROPOSAuditLogAuxInfo);
            "NPR CRO Audit Entry Type"::"Sales Invoice":
                PrintSalesInvThermalReceipt(CROPOSAuditLogAuxInfo);
            "NPR CRO Audit Entry Type"::"Sales Credit Memo":
                PrintSalesCrMemoThermalReceipt(CROPOSAuditLogAuxInfo);
        end;
    end;

    local procedure PrintPOSThermalReceipt(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        POSEntry: Record "NPR POS Entry";
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        POSEntry.Get(CROPOSAuditLogAuxInfo."POS Entry No.");

        PrintHeaderSection(CROPOSAuditLogAuxInfo);

        PrintPOSContentSection(CROPOSAuditLogAuxInfo, POSEntry);

        PrintPOSVATSection(CROPOSAuditLogAuxInfo, POSEntry);

        PrintFooter(CROPOSAuditLogAuxInfo);

        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR CRO Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        CROPOSAuditLogAuxInfo."Receipt Printed" := true;
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure PrintSalesInvThermalReceipt(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        SalesInvoiceHdr: Record "Sales Invoice Header";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        SalesInvoiceHdr.Get(CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceHdr.CalcFields("Amount Including VAT");

        PrintHeaderSection(CROPOSAuditLogAuxInfo);

        PrintSalesInvContentSection(CROPOSAuditLogAuxInfo, SalesInvoiceHdr);

        PrintFooter(CROPOSAuditLogAuxInfo);

        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR CRO Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        CROPOSAuditLogAuxInfo."Receipt Printed" := true;
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure PrintSalesCrMemoThermalReceipt(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);

        SalesCrMemoHdr.Get(CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoHdr.CalcFields("Amount Including VAT");

        PrintHeaderSection(CROPOSAuditLogAuxInfo);

        PrintSalesCrMemoContentSection(CROPOSAuditLogAuxInfo, SalesCrMemoHdr);

        PrintFooter(CROPOSAuditLogAuxInfo);

        PrintThermalLine('PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR CRO Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);

        CROPOSAuditLogAuxInfo."Receipt Printed" := true;
        CROPOSAuditLogAuxInfo.Modify();
    end;

    #endregion

    #region CRO Fiscal Thermal Print - POS Sections Printing
    local procedure PrintPOSContentSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalesLineType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
    begin
        PrintFourColumnText(ItemDescLbl, QtyLbl, PriceLbl, LineAmountLbl, true);
        PrintDottedLine();

        POSEntrySalesLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetRange(Type, SalesLineType::Item);
        if POSEntrySalesLine.FindSet() then
            repeat
                PrintTextLine(POSEntrySalesLine.Description, false);
                PrintFourColumnText(Format(POSEntrySalesLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(Abs(POSEntrySalesLine."Unit Price")), FormatDecimal(POSEntrySalesLine."Amount Incl. VAT"), false);
            until POSEntrySalesLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(POSEntry."Amount Incl. Tax"), true);
        PrintTextLine('', false);
    end;

    local procedure PrintPOSVATSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; POSEntry: Record "NPR POS Entry")
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, VATTotalLbl, true);
        PrintDottedLine();

        POSEntryTaxLine.SetRange("POS Entry No.", CROPOSAuditLogAuxInfo."POS Entry No.");
        if POSEntryTaxLine.FindSet() then
            repeat
                PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(Abs(POSEntryTaxLine."Tax %"), 0.1)), '%'), FormatDecimal(Abs(POSEntryTaxLine."Tax Base Amount")), FormatDecimal(Abs(POSEntryTaxLine."Tax Amount")), FormatDecimal(Abs(POSEntryTaxLine."Amount Including Tax")), false);
            until POSEntryTaxLine.Next() = 0;

        PrintFullLine();

        PrintFourColumnText(AmountPaidLbl, Format(CROPOSAuditLogAuxInfo."Payment Method"), '', FormatDecimal(POSEntry."Amount Incl. Tax"), true);

        PrintTextLine('', false);
    end;

    #endregion

    #region CRO Fiscal Thermal Print - Sales Invoice Sections Printing
    local procedure PrintSalesInvContentSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; SalesInvoiceHdr: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
    begin
        PrintFourColumnText(ItemDescLbl, QtyLbl, PriceLbl, LineAmountLbl, true);
        PrintDottedLine();

        SalesInvoiceLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange(Type, "Sales Line Type"::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                PrintTextLine(SalesInvoiceLine.Description, false);
                PrintFourColumnText(Format(SalesInvoiceLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(GetUnitPriceInclVAT(SalesInvoiceHdr."Prices Including VAT", SalesInvoiceLine."Unit Price", SalesInvoiceLine."VAT %", SalesInvoiceHdr."Currency Code")), FormatDecimal(SalesInvoiceLine."Amount Including VAT"), false);

                AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
                AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
                AddAmountToDecimalDict(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
            until SalesInvoiceLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SalesInvoiceHdr."Amount Including VAT"), true);
        PrintTextLine('', false);

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, VATTotalLbl, true);
        PrintDottedLine();

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(AmountInclTaxDict.Get(DictKey)), false);

        PrintFullLine();

        PrintFourColumnText(AmountPaidLbl, Format(CROPOSAuditLogAuxInfo."Payment Method"), '', FormatDecimal(SalesInvoiceHdr."Amount Including VAT"), true);

        PrintTextLine('', false);
    end;
    #endregion

    #region CRO Fiscal Thermal Print - Sales Credit Memo Sections Printing
    local procedure PrintSalesCrMemoContentSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; SalesCrMemoHdr: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TaxableAmountDict: Dictionary of [Decimal, Decimal];
        TaxAmountDict: Dictionary of [Decimal, Decimal];
        AmountInclTaxDict: Dictionary of [Decimal, Decimal];
        DictKeysList: List of [Decimal];
        DictKey: Decimal;
    begin
        PrintFourColumnText(ItemDescLbl, QtyLbl, PriceLbl, LineAmountLbl, true);
        PrintDottedLine();

        SalesCrMemoLine.SetRange("Document No.", CROPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, "Sales Line Type"::Item);
        if SalesCrMemoLine.FindSet() then
            repeat
                PrintTextLine(SalesCrMemoLine.Description, false);
                PrintFourColumnText(Format(-Abs(SalesCrMemoLine.Quantity)).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(Abs(GetUnitPriceInclVAT(SalesCrMemoHdr."Prices Including VAT", SalesCrMemoLine."Unit Price", SalesCrMemoLine."VAT %", SalesCrMemoHdr."Currency Code"))), FormatDecimal(-Abs(SalesCrMemoLine."Amount Including VAT")), false);

                AddAmountToDecimalDict(TaxableAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount");
                AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount");
                AddAmountToDecimalDict(AmountInclTaxDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT");
            until SalesCrMemoLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SalesCrMemoHdr."Amount Including VAT"), true);
        PrintTextLine('', false);

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, VATTotalLbl, true);
        PrintDottedLine();


        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(AmountInclTaxDict.Get(DictKey)), false);

        PrintFullLine();

        PrintFourColumnText(AmountPaidLbl, Format(CROPOSAuditLogAuxInfo."Payment Method"), '', FormatDecimal(-SalesCrMemoHdr."Amount Including VAT"), true);

        PrintTextLine('', false);
    end;

    #endregion

    #region CRO Fiscal Thermal Print - Base Section Printing

    local procedure PrintHeaderSection(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        CompanyInfo: Record "Company Information";
        CROFiscalSetup: Record "NPR CRO Fiscalization Setup";
        POSStore: Record "NPR POS Store";
        BillNoLbl: Label 'Broj %1', Locked = true;
        CompanyInfoLbl: Label '%1, %2 %3', Locked = true;
        FiscalBillCopyLbl: Label 'OVO JE KOPIJA FISKALNOG RACUNA', Locked = true;
        OibLbl: Label 'OIB: %1', Locked = true;
        ParagonBillLbl: Label '%1/%2/%3', Locked = true;
        POSUnitLbl: Label 'Blagajna', Locked = true;
    begin
        PrintThermalLine('POSLOGO', 'LOGO', false, 'CENTER', true, false);

        if CROPOSAuditLogAuxInfo."Receipt Printed" then begin
            PrintTextLine(FiscalBillCopyLbl, true);
            PrintFullLine();
        end;

        CompanyInfo.Get();
        PrintTextLine(CompanyInfo.Name, true);
        PrintTextLine(StrSubstNo(CompanyInfoLbl, CompanyInfo.Address, CompanyInfo."Post Code", CompanyInfo.City), false);

        POSStore.Get(CROPOSAuditLogAuxInfo."POS Store Code");
        PrintTextLine(POSStore.Name, false);
        PrintTextLine(StrSubstNo(CompanyInfoLbl, POSStore.Address, POSStore."Post Code", POSStore.City), false);

        CROFiscalSetup.Get();
        PrintTextLine(StrSubstNo(OibLbl, CROFiscalSetup."Certificate Subject OIB"), false);
        PrintFullLine();

        PrintTwoColumnText(StrSubstNo(BillNoLbl, StrSubstNo(ParagonBillLbl, CROPOSAuditLogAuxInfo."Bill No.", CROPOSAuditLogAuxInfo."POS Store Code", CROPOSAuditLogAuxInfo."POS Unit No.")), StrSubstNo(TwoValueFormatLbl, Format(CROPOSAuditLogAuxInfo."Entry Date", 10, '<Day,2>.<Month,2>.<Year4>'), Format(CROPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24>:<Minutes,2>:<Seconds,2>')), false);

        PrintTextLine(StrSubstNo(TwoValueFormatLbl, POSUnitLbl, CROPOSAuditLogAuxInfo."POS Unit No."), false);
        PrintDottedLine();
    end;

    local procedure PrintFooter(CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info")
    var
        JIRCodeLbl: Label 'JIR:', Locked = true;
        ZKICodeLbl: Label 'ZKI:', Locked = true;
    begin
        PrintFullLine();
        PrintTextLine('', false);

        PrintTextLine(StrSubstNo(TwoValueFormatLbl, ZKICodeLbl, CROPOSAuditLogAuxInfo."ZKI Code"), true);
        PrintTextLine(StrSubstNo(TwoValueFormatLbl, JIRCodeLbl, CROPOSAuditLogAuxInfo."JIR Code"), true);
        PrintTextLine('', false);

        PrintQRCode(CROPOSAuditLogAuxInfo."Verification URL");
    end;

    #endregion

    #region CRO Fiscal Thermal Print - Printing Procedures

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
        TwoColumnValuesLbl: Label '%1%2', Locked = true;
    begin
        PrintThermalLine(StrSubstNo(TwoColumnValuesLbl, FirstColumnText.PadRight(20, ' '), SecondColumnText.PadLeft(20, ' ')), 'A11', Bold, 'CENTER', true, false);
    end;

    local procedure PrintFourColumnText(FirstColumnText: Text; SecondColumnText: Text; ThirdColumnText: Text; FourthColumnText: Text; Bold: Boolean)
    var
        FourColumnValuesLbl: Label '%1%2%3%4', Locked = true;
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

    #region CRO Fiscal Thermal Print - Formatting

    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    #endregion

    #region CRO Fiscal Thermal Print - Helper Procedures

    local procedure AddAmountToDecimalDict(var DecimalDict: Dictionary of [Decimal, Decimal]; DictKey: Decimal; DictValue: Decimal)
    var
        BaseAmount: Decimal;
    begin
        if DecimalDict.Add(DictKey, DictValue) then
            exit;
        BaseAmount := DecimalDict.Get(DictKey) + DictValue;
        DecimalDict.Set(DictKey, BaseAmount);
    end;

    local procedure GetUnitPriceInclVAT(PricesInclVAT: Boolean; UnitPrice: Decimal; VATPercentage: Decimal; CurrencyCode: Code[20]): Decimal
    var
        Currency: Record Currency;
    begin
        if PricesInclVAT then
            exit(UnitPrice);

        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else
            if not Currency.Get(CurrencyCode) then
                Currency.InitRoundingPrecision();
        exit(Round(UnitPrice * (1 + VATPercentage / 100), Currency."Amount Rounding Precision"));
    end;

    #endregion
}