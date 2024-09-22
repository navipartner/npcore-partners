codeunit 6184976 "NPR RS Monthly Fiscal Print"
{
    Access = Internal;

    internal procedure PrintMonthlyStatistics(StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    begin
        PrintReport(StartDate, EndDate, POSUnitNo);
    end;

    local procedure PrintReport(StartDate: Date; EndDate: Date; POSUnitNo: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print";
    begin
        POSUnit.Get(POSUnitNo);
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintReceiptHeader(Printer, POSUnit);
        PrintEODPart(Printer, POSUnit, StartDate, EndDate);
        PrintMonthlySalespersonPart(Printer, POSUnit, StartDate, EndDate);
        PrintGeneralInfo(Printer, POSUnit, StartDate, EndDate);
        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS Monthly Fiscal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintReceiptHeader(var Printer: Codeunit "NPR RP Line Print"; POSUnit: Record "NPR POS Unit")
    var
        CompanyInfo: Record "Company Information";
        POSStore: Record "NPR POS Store";
        POSStoreAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies POS Store Address, %2 - specifies POS Store City, %3 - specifies POS Store Post Code', Locked = true;
        VATRegistationNoLbl: Label '%1', Comment = '%1 - specifies Company Information VAT Registration No.', Locked = true;
    begin
        CompanyInfo.Get();
        POSStore.Get(POSUnit."POS Store Code");

        PrintThermalLine(Printer, POSStore.Name, 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(POSStoreAddressInfoLbl, POSStore.Address, POSStore.City, POSStore."Post Code"), 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNoCaptionLbl, POSUnit."No."), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNameCaptionLbl, POSUnit.Name), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(VATRegNumberCaptionLbl, StrSubstNo(VATRegistationNoLbl, POSStore."VAT Registration No.")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintEODPart(var Printer: Codeunit "NPR RP Line Print"; POSUnit: Record "NPR POS Unit"; StartDate: Date; EndDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
        DirectItemSales, DirectItemsReturns, TotalDiscount : Decimal;
    begin
        Clear(DirectItemSales);
        Clear(DirectItemsReturns);
        RSReportStatisticsMgt.SetFilterOnPOSEntryMonthly(POSEntry, POSUnit, StartDate, EndDate, '');
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetLoadFields("Amount Incl. Tax", "Discount Amount Incl. VAT");
        POSEntry.FindSet();
        repeat
            if POSEntry."Amount Incl. Tax" > 0 then
                DirectItemSales += POSEntry."Amount Incl. Tax"
            else
                DirectItemsReturns += POSEntry."Amount Incl. Tax";
            TotalDiscount += POSEntry."Discount Amount Incl. VAT";
        until POSEntry.Next() = 0;

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(EndOfDateCaptionLbl, StartDate, EndDate), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, BrutoSalesCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(DirectItemSales)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ReturnCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(DirectItemsReturns)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, TotalDiscountAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(TotalDiscount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, EndingFloatAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(DirectItemSales + DirectItemsReturns)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintMonthlySalespersonPart(var Printer: Codeunit "NPR RP Line Print"; POSUnit: Record "NPR POS Unit"; StartDate: Date; EndDate: Date)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonQuery: Query "NPR RS Group Sales by Salespr.";
    begin
        PrintThermalLine(Printer, SalesPersonInformationLbl, 'A11', true, 'CENTER', true, false);

        SalespersonQuery.SetFilter(EntryDate, '%1..%2', StartDate, EndDate);
        SalespersonQuery.SetRange(EntryType, SalespersonQuery.EntryType::"Direct Sale");
        SalespersonQuery.SetRange(POSUnitNo, POSUnit."No.");
        SalespersonQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        SalespersonQuery.Open();
        while (SalespersonQuery.Read()) do
            if SalespersonPurchaser.Get(SalespersonQuery.SalespersonCode) then
                PrintSalespersonInfo(Printer, SalespersonPurchaser, POSUnit."No.", StartDate, EndDate);
        SalespersonQuery.Close();
    end;

    local procedure PrintSalespersonInfo(var Printer: Codeunit "NPR RP Line Print"; SalespersonPurchaser: Record "Salesperson/Purchaser"; POSUnitNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        Amount: Decimal;
    begin
        POSUnit.Get(POSUnitNo);
        RSReportStatisticsMgt.SetFilterOnPOSEntryMonthly(POSEntry, POSUnit, StartDate, EndDate, SalespersonPurchaser.Code);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        Clear(Amount);
        RSReportStatisticsMgt.CalcSalespersonAmountMonthly(POSEntry, Amount);
        PrintThermalLine(Printer, CaptionValueFormat(SalespersonPurchaser.Name, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintPaymentsMonthlyAmount(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentMethodCode: Code[20];
        Amount: Decimal;
        PaymentAmounts: Dictionary of [Code[20], Decimal];
        PrintTxt: Text;
    begin
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount");
                if POSEntryPaymentLine.FindSet() then
                    repeat
                        PaymentMethodCode := POSEntryPaymentLine."POS Payment Method Code";
                        if not PaymentAmounts.ContainsKey(PaymentMethodCode) then
                            PaymentAmounts.Add(PaymentMethodCode, 0);

                        Amount := PaymentAmounts.Get(PaymentMethodCode);
                        Amount += POSEntryPaymentLine.Amount;
                        PaymentAmounts.Set(PaymentMethodCode, Amount);
                    until POSEntryPaymentLine.Next() = 0;
            until POSEntry.Next() = 0;

        POSPaymentMethod.SetLoadFields("Description");
        foreach PaymentMethodCode in PaymentAmounts.Keys do
            if POSPaymentMethod.Get(PaymentMethodCode) then begin
                Amount := PaymentAmounts.Get(PaymentMethodCode);
                if Amount > 0 then begin
                    PrintTxt := FormatNumber(Amount);
                    PrintThermalLine(Printer, CaptionValueFormat(POSPaymentMethod.Description, PrintTxt), 'A11', false, 'LEFT', true, false);
                end;
            end;
    end;

    local procedure PrintGeneralInfo(var Printer: Codeunit "NPR RP Line Print"; POSUnit: Record "NPR POS Unit"; StartDate: Date; EndDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
        QuantityCancelled, QuantitySucceed, StartReceiptNo, EndReceiptNo : Integer;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        RSReportStatisticsMgt.SetFilterOnPOSEntryMonthly(POSEntry, POSUnit, StartDate, EndDate, '');

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintSalesTaxAmountsSection(Printer, POSEntry, POSUnit, StartDate, EndDate);

        PrintThermalLine(Printer, PaymentsTypeLbl, 'A11', true, 'CENTER', true, false);

        PrintPaymentsMonthlyAmount(Printer, POSEntry);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        RSReportStatisticsMgt.CalcQuantitySucceedAndQuantityCancelled(POSEntry, QuantitySucceed, QuantityCancelled);
        RSReportStatisticsMgt.GetTotalCounterFromPOSAuditLogInPeriod(POSUnit."No.", StartDate, EndDate, StartReceiptNo, EndReceiptNo);

        PrintThermalLine(Printer, CaptionValueFormat(CancelledQuantityCaptionLbl, Format(QuantityCancelled)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(SucceedQuantityCaptionLbl, Format(QuantitySucceed)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StartReceiptCaptionLbl, Format(StartReceiptNo)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(EndReceiptCaptionLbl, Format(EndReceiptNo)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    internal procedure PrintSalesTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; POSEntry: Record "NPR POS Entry"; POSUnit: Record "NPR POS Unit"; StartDate: Date; EndDate: Date)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        Printed: Boolean;
        AmountIncludingTax, TaxAmount, TaxBaseAmount : Decimal;
        TaxPct: Decimal;
        PrintedTaxRates: Dictionary of [Decimal, Boolean];
        UniqueTaxPercents: List of [Decimal];
    begin
        RSReportStatisticsMgt.SetFilterOnPOSEntryMonthly(POSEntry, POSUnit, StartDate, EndDate, '');
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetCurrentKey("Tax %");
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryTaxLine.SetLoadFields("Tax %");
                if POSEntryTaxLine.FindSet() then
                    repeat
                        TaxPct := POSEntryTaxLine."Tax %";
                        if not UniqueTaxPercents.Contains(TaxPct) then
                            UniqueTaxPercents.Add(TaxPct);
                    until POSEntryTaxLine.Next() = 0;
            until POSEntry.Next() = 0;

        foreach TaxPct in UniqueTaxPercents do begin
            RSReportStatisticsMgt.CalcTaxAmounts(POSEntry, true, TaxPct, TaxBaseAmount, TaxAmount, AmountIncludingTax);

            if AmountIncludingTax <> 0 then
                if not PrintedTaxRates.ContainsKey(TaxPct) then begin
                    PrintedTaxRates.Add(TaxPct, true);

                    if not Printed then begin
                        PrintThermalLine(Printer, TaxCaptionLbl, 'A11', true, 'CENTER', true, false);
                        Printed := true;
                    end;
                    PrintTaxAmountsSection(Printer, TaxPct, TaxBaseAmount, TaxAmount);
                end;
        end;

        if Printed then
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;


    local procedure PrintTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; TaxPct: Decimal; TaxBaseAmount: Decimal; TaxAmount: Decimal)
    begin
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxBaseAmountCaptionLbl, TaxPct), FormatNumber(TaxBaseAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxAmountCaptionLbl, TaxPct), FormatNumber(TaxAmount)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print"; Value: Text; Font: Text; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
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

    local procedure FormatNumber(Input: Decimal): Text
    begin
        Input := Round(Input, 0.01);

        exit(Format(Input, 0, '<SIGN><INTEGER><DECIMALS,3>'));
    end;

    local procedure CaptionValueFormat(CaptionLbl: Text; Value: Text) Result: Text
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

    var
        RSReportStatisticsMgt: Codeunit "NPR RS Report Statistics Mgt.";
        BrutoSalesCaptionLbl: Label 'Bruto prodaja', Locked = true;
        CancelledQuantityCaptionLbl: Label 'Broj storniranih računa', Locked = true;
        EndingFloatAmountCaptionLbl: Label 'Ukupan iznos prodaje', Locked = true;
        EndOfDateCaptionLbl: Label 'Za period od %1 do %2', Comment = '%1 - Označava početni datum, %2 - Označava krajnji datum', Locked = true;
        LCYCaptionLbl: Label 'RSD', Locked = true;
        PaymentsTypeLbl: Label 'Vrste plaćanja', Locked = true;
        POSUnitNameCaptionLbl: Label 'Naziv POS jedinice', Locked = true;
        POSUnitNoCaptionLbl: Label 'Broj POS jedinice', Locked = true;
        ReturnCaptionLbl: Label 'Povrat', Locked = true;
        SalesPersonInformationLbl: Label 'Ukupan iznos prodaje po kasiru', Locked = true;
        SucceedQuantityCaptionLbl: Label 'Broj izdatih računa', Locked = true;
        TaxAmountCaptionLbl: Label '%1% PDV', Comment = '%1 - Označava procenat PDV-a', Locked = true;
        TaxBaseAmountCaptionLbl: Label '%1% Osnovica', Comment = '%1 - Označava procenat PDV-a', Locked = true;
        TaxCaptionLbl: Label 'PDV', Locked = true;
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
        TotalDiscountAmountCaptionLbl: Label 'Ukupan iznos popusta', Locked = true;
        VATRegNumberCaptionLbl: Label 'PIB', Locked = true;
        StartReceiptCaptionLbl: Label 'Broj početnog računa', Locked = true;
        EndReceiptCaptionLbl: Label 'Broj završnog računa', Locked = true;
}