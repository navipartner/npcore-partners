codeunit 6151588 "NPR SI Fiscal Thermal Print"
{
    Access = Internal;

    var
        Printer: Codeunit "NPR RP Line Print";
        TwoValueFormatLbl: Label '%1 %2', Locked = true, Comment = '%1 = First Value, %2 = Second Value';
        VATRegNoLbl: Label 'DŠ: %1', Locked = true, Comment = '%1 = VAT Registration No.';

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
        DateLbl: Label 'Dne: ';
        DateFormatLbl: Label '%1, %2', Locked = true, Comment = '%1 = Entry Date, %2 = Time Stamp';
        ReceiptCopyLbl: Label 'THIS IS A COPY %1 OF A RECEIPT', Comment = '%1 = Receipt Copy No.';
        ReceiptNoLbl: Label 'Št. računa: ';
    begin
        CompanyInfo.Get();
        POSStore.Get(SIPOSAuditLogAuxInfo."POS Store Code");

        PrintThermalLine('POSLOGO', 'LOGO', false, 'CENTER', true, false);

        if SIPOSAuditLogAuxInfo."Receipt Printed" then begin
            SIPOSAuditLogAuxInfo."Copies Printed" += 1;
            PrintDottedLine();
            PrintTextLine(StrSubstNo(ReceiptCopyLbl, SIPOSAuditLogAuxInfo."Copies Printed"), 'CENTER', true);
            PrintDottedLine();
            SIPOSAuditLogAuxInfo.Modify();
        end;

        PrintTextLine(CompanyInfo.Name, 'CENTER', true);
        PrintTextLine(POSStore.Name, 'CENTER', true);
        PrintTextLine(FormatAddressLine(POSStore.Address, POSStore."Post Code", POSStore.City), 'CENTER', true);
        PrintTextLine(StrSubstNo(VATRegNoLbl, POSStore."VAT Registration No."), 'CENTER', true);
        PrintFullLine();

        PrintCustomerAdditionalInfo(SIPOSAuditLogAuxInfo);
        PrintFullLine();

        PrintTwoColumnText(DateLbl, StrSubstNo(DateFormatLbl, Format(SIPOSAuditLogAuxInfo."Entry Date", 10, '<Day,2>.<Month,2>.<Year4>'), Format(SIPOSAuditLogAuxInfo."Log Timestamp", 8, '<Hours24>:<Minutes,2>:<Seconds,2>')), 'CENTER', true);

        PrintTwoColumnText(ReceiptNoLbl, FormatReceiptNo(SIPOSAuditLogAuxInfo), 'CENTER', true);
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
    begin
        PrintDottedLine();
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, 'CENTER', true);
        PrintDottedLine();

        POSEntrySalesLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if not POSEntrySalesLine.FindSet() then
            exit;
        repeat
            PrintTextLine(POSEntrySalesLine.Description, 'CENTER', false);
            PrintFourColumnText(Format(POSEntrySalesLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(POSEntrySalesLine."Unit Price"), FormatDecimal(POSEntrySalesLine."Amount Incl. VAT"), 'CENTER', false);
        until POSEntrySalesLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), 'CENTER', true);
        PrintEmptyLine();

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, 'CENTER', true);
        PrintDottedLine();

        POSEntryTaxLine.SetRange("POS Entry No.", SIPOSAuditLogAuxInfo."POS Entry No.");
        if not POSEntryTaxLine.FindSet() then
            exit;
        repeat
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(POSEntryTaxLine."Tax %", 0.1)), '%'), FormatDecimal(Abs(POSEntryTaxLine."Tax Base Amount")), FormatDecimal(Abs(POSEntryTaxLine."Tax Amount")), FormatDecimal(POSEntryTaxLine."Amount Including Tax"), 'CENTER', false);
        until POSEntryTaxLine.Next() = 0;
    end;

    local procedure PrintSalesInvoiceContent(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
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
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, 'CENTER', true);
        PrintDottedLine();

        SalesInvoiceHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.");

        SalesInvoiceLine.SetLoadFields(Description, Quantity, "Unit Price", "VAT Base Amount", "VAT %", "Amount Including VAT");
        SalesInvoiceLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.FindSet();
        repeat
            PrintTextLine(SalesInvoiceLine.Description, 'CENTER', false);
            PrintFourColumnText(Format(SalesInvoiceLine.Quantity).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(GetUnitPriceInclVAT(SalesInvoiceHeader."Prices Including VAT", SalesInvoiceLine."Unit Price", SalesInvoiceLine."VAT %", SalesInvoiceHeader."Currency Code")), FormatDecimal(SalesInvoiceLine."Amount Including VAT"), 'CENTER', false);

            AddAmountToDecimalDict(TaxableAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount");
            AddAmountToDecimalDict(AmountInclTaxDict, SalesInvoiceLine."VAT %", SalesInvoiceLine."Amount Including VAT");
        until SalesInvoiceLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), 'CENTER', true);
        PrintEmptyLine();

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, 'CENTER', true);
        PrintDottedLine();

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(AmountInclTaxDict.Get(DictKey)), 'CENTER', false);
        end;
    end;

    local procedure PrintSalesCreditMemoContent(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Currency: Record Currency;
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
        PrintFourColumnText(ItemDescLbl, QtyLbl, UnitPriceLbl, ItemPriceLbl, 'CENTER', true);
        PrintDottedLine();

        SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.");

        SalesCrMemoLine.SetLoadFields(Description, Quantity, "Unit Price", "VAT Base Amount", "VAT %", "Amount Including VAT");
        SalesCrMemoLine.SetRange("Document No.", SIPOSAuditLogAuxInfo."Source Document No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.FindSet();
        repeat
            PrintTextLine(SalesCrMemoLine.Description, 'CENTER', false);
            PrintFourColumnText(Format(-Abs(SalesCrMemoLine.Quantity)).PadLeft(StrLen(Format(ItemDescLbl).PadRight(10, ' ')), ' '), 'x', FormatDecimal(GetUnitPriceInclVAT(SalesCrMemoHeader."Prices Including VAT", SalesCrMemoLine."Unit Price", SalesCrMemoLine."VAT %", SalesCrMemoHeader."Currency Code")), FormatDecimal(Round(-Abs(SalesCrMemoLine."Amount Including VAT"), Currency."Amount Rounding Precision")), 'CENTER', false);

            AddAmountToDecimalDict(TaxableAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDict(TaxAmountDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine."VAT Base Amount");
            AddAmountToDecimalDict(AmountInclTaxDict, SalesCrMemoLine."VAT %", SalesCrMemoLine."Amount Including VAT");
        until SalesCrMemoLine.Next() = 0;
        PrintFullLine();

        PrintTwoColumnText(FinalBillLbl, FormatDecimal(SIPOSAuditLogAuxInfo."Total Amount"), 'CENTER', true);
        PrintEmptyLine();

        PrintDottedLine();
        PrintFourColumnText(VATPercLbl, VATBaseLbl, VATAmountLbl, AmountInclVATLbl, 'CENTER', true);
        PrintDottedLine();

        DictKeysList := TaxableAmountDict.Keys();
        foreach DictKey in DictKeysList do begin
            PrintFourColumnText(StrSubstNo(TwoValueFormatLbl, Format(Round(DictKey, 0.1)), '%'), FormatDecimal(TaxableAmountDict.Get(DictKey)), FormatDecimal(TaxAmountDict.Get(DictKey)), FormatDecimal(-AmountInclTaxDict.Get(DictKey)), 'CENTER', false);
        end;
    end;

    local procedure PrintFooter(var SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        CashierIDLbl: Label 'Račun izdal: ', Locked = true;
        ZOICodeLbl: Label 'ZOI: ', Locked = true;
        EORCodeLbl: Label 'EOR: ', Locked = true;
    begin
        PrintFullLine();
        PrintTwoColumnText(CashierIDLbl, Format(SIPOSAuditLogAuxInfo."Salesperson Code"), 'CENTER', true);
        PrintEmptyLine();

        if SIPOSAuditLogAuxInfo."ZOI Code" <> '' then
            PrintTwoColumnText(ZOICodeLbl, SIPOSAuditLogAuxInfo."ZOI Code", 'CENTER', true);

        PrintTwoColumnText(EORCodeLbl, SIPOSAuditLogAuxInfo."EOR Code", 'CENTER', true);
        PrintEmptyLine();

        if SIPOSAuditLogAuxInfo."Validation Code" <> '' then
            PrintQRCode(SIPOSAuditLogAuxInfo."Validation Code");
    end;

    local procedure PrintCustomerAdditionalInfo(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info")
    var
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SIPOSAuditLogAuxInfo."Customer VAT Number" = '' then
            exit;

        case SIPOSAuditLogAuxInfo."Audit Entry Type" of
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry":
                begin
                    POSEntry.Get(SIPOSAuditLogAuxInfo."POS Entry No.");
                    PrintCustomerAdditionalInfo(POSEntry."Customer No.");
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.");
                    PrintCustomerAdditionalInfo(SalesInvoiceHeader."Sell-to Customer No.");
                end;
            SIPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Cr. Memo Header":
                begin
                    SalesCrMemoHeader.Get(SIPOSAuditLogAuxInfo."Source Document No.");
                    PrintCustomerAdditionalInfo(SalesCrMemoHeader."Sell-to Customer No.");
                end;
        end;
    end;

    local procedure PrintCustomerAdditionalInfo(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit;

        if not Customer.Get(CustomerNo) then
            exit;

        if Customer.Name <> '' then
            PrintTextLine(Customer.Name, 'CENTER', false);

        PrintTextLine(FormatAddressLine(Customer.Address, Customer."Post Code", Customer.City), 'CENTER', false);
        PrintTextLine(StrSubstNo(VATRegNoLbl, Customer."VAT Registration No."), 'CENTER', true);
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

    local procedure PrintTextLine(TextToPrint: Text; Alignment: Text; Bold: Boolean)
    begin
        PrintThermalLine(TextToPrint.PadRight(ReceiptWidth(), ' '), 'A11', Bold, Alignment, true, false);
    end;

    local procedure PrintTwoColumnText(FirstColumnText: Text; SecondColumnText: Text; Alignment: Text; Bold: Boolean)
    begin
        if SecondColumnText <> '' then
            PrintThermalLine(FormatTwoColumnText(FirstColumnText, SecondColumnText), 'A11', Bold, Alignment, true, false);
    end;

    local procedure PrintFourColumnText(FirstColumnText: Text; SecondColumnText: Text; ThirdColumnText: Text; FourthColumnText: Text; Alignment: Text; Bold: Boolean)
    var
        FourColumnValuesLbl: Label '%1%2%3%4', Locked = true, Comment = '%1 = First Value, %2 = Second Value, %3 = Third Value, %4 = Fourth Value';
    begin
        PrintThermalLine(StrSubstNo(FourColumnValuesLbl, FirstColumnText.PadRight(11, ' '), SecondColumnText.PadRight(10, ' '), ThirdColumnText.PadLeft(10, ' '), FourthColumnText.PadLeft(11, ' ')), 'A11', Bold, Alignment, true, false);
    end;

    local procedure PrintEmptyLine()
    begin
        PrintThermalLine('', 'A11', false, 'CENTER', true, false);
    end;

    local procedure PrintQRCode(QRCodeValue: Text)
    begin
        PrintThermalLine(QRCodeValue, 'QR', false, 'CENTER', true, false);
    end;

    local procedure PrintDottedLine()
    var
        Dots: Text;
    begin
        Dots := '-';
        PrintThermalLine(Dots.PadRight(ReceiptWidth(), '-'), 'A11', true, 'CENTER', true, false);
    end;

    local procedure PrintFullLine()
    var
        Line: Text;
    begin
        Line := '_';
        PrintThermalLine(Line.PadRight(ReceiptWidth(), '_'), 'A11', true, 'CENTER', true, false);
    end;

    #endregion

    #region SI Fiscal Thermal Print - Formatting

    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Precision,2:2><Sign><Integer><Decimals><Comma,.>'));
    end;

    local procedure FormatAddressLine(Address: Text[100]; PostCode: Code[20]; City: Text[30]) AddressLine: Text
    begin
        if Address <> '' then
            AddressLine += Address + ', ';
        if PostCode <> '' then
            AddressLine += PostCode + ', ';
        if City <> '' then
            AddressLine += City;
        if AddressLine = '' then
            exit;

        AddressLine := AddressLine.TrimEnd(', ');
    end;

    local procedure FormatReceiptNo(SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info"): Text
    var
        ReceiptNoFormatLbl: Label '%1-%2-%3', Locked = true, Comment = '%1 = POS Store Code, %2 = POS Unit No., %3 = Receipt No.';
    begin
        if SIPOSAuditLogAuxInfo."Receipt No." <> '' then
            exit(StrSubstNo(ReceiptNoFormatLbl, SIPOSAuditLogAuxInfo."POS Store Code", SIPOSAuditLogAuxInfo."POS Unit No.", SIPOSAuditLogAuxInfo."Receipt No."))
        else
            exit(StrSubstNo(ReceiptNoFormatLbl, SIPOSAuditLogAuxInfo."POS Store Code", SIPOSAuditLogAuxInfo."POS Unit No.", SIPOSAuditLogAuxInfo."Sales Book Invoice No."));
    end;

    local procedure FormatTwoColumnText(CaptionLbl: Text; Value: Text) Result: Text
    var
        TotalTxtLen: Integer;
    begin
        TotalTxtLen := StrLen(CaptionLbl) + StrLen(Value);

        if TotalTxtLen < ReceiptWidth() then
            Result := PadStr(CaptionLbl, ReceiptWidth() - StrLen(Value), ' ') + Value
        else
            Result := CaptionLbl + Value;
    end;

    local procedure ReceiptWidth(): Integer
    begin
        exit(42);
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