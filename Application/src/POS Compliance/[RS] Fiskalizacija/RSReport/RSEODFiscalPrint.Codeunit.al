codeunit 6184934 "NPR RS EOD Fiscal Print"
{
    Access = Internal;
    TableNo = "NPR POS Workshift Checkpoint";
    trigger OnRun()
    begin
        PrintEndOfDayReceipt(Rec);
    end;

    internal procedure PrintEndOfDayReceipt(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        POSUnitMissingErrLbl: Label 'POS jedinica nedostaje na radnoj smeni.', Locked = true;
        RSFiscalizationNotEnabledErrLbl: Label 'Srpska fiskalizacija nije omogućena na POS jedinici:', Locked = true;
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            Error(POSUnitMissingErrLbl);

        if not RSAuditMgt.IsRSFiscalActive() then
            Error(RSFiscalizationNotEnabledErrLbl);

        PrintThermalReceipt(POSWorkshiftCheckpoint);
    end;

    local procedure PrintThermalReceipt(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintReceiptHeader(Printer, POSWorkshiftCheckpoint);
        PrintEODPart(Printer, POSWorkshiftCheckpoint);
        PrintItemCategoryPart(Printer, POSWorkshiftCheckpoint);
        PrintSalespersonPart(Printer, POSWorkshiftCheckpoint);
        PrintGeneralInfo(Printer, '', POSWorkshiftCheckpoint);

        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR RS EOD Fiscal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintReceiptHeader(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CompanyInfo: Record "Company Information";
        ZReportPOSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSStoreAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies POS Store Address, %2 - specifies POS Store City, %3 - specifies POS Store Post Code', Locked = true;
        VATRegistationNoLbl: Label '%1', Comment = '%1 - specifies Company Information VAT Registration No.', Locked = true;
        ReportNoCaptionTxt: Text;
    begin
        CompanyInfo.Get();
        ZReportPOSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        POSStore.Get(POSUnit."POS Store Code");
        SalespersonPurchaser.Get(ZReportPOSEntry."Salesperson Code");

        PrintThermalLine(Printer, POSStore.Name, 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(POSStoreAddressInfoLbl, POSStore.Address, POSStore.City, POSStore."Post Code"), 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::XREPORT then
            ReportNoCaptionTxt := XReportEntryNoCaptionLbl
        else
            ReportNoCaptionTxt := ZReportEntryNoCaptionLbl;

        PrintThermalLine(Printer, CaptionValueFormat(ReportDateCaptionLbl, Format(POSWorkshiftCheckpoint.SystemCreatedAt)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReportNoCaptionTxt, Format(POSWorkshiftCheckpoint."Entry No.")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNoCaptionLbl, POSUnit."No."), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNameCaptionLbl, POSUnit.Name), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(VATRegNumberCaptionLbl, StrSubstNo(VATRegistationNoLbl, POSStore."VAT Registration No.")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintEODPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CalculatedAmountInclFloat, CountedAmountInclFloat, EndingFloatAmount, InitialFloatAmount : Decimal;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, EndOfDayCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, BrutoSalesCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ReturnCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, TotalDiscountAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Total Discount (LCY)")), 'A11', false, 'LEFT', true, false);

        if RSReportStatisticsMgt.FindWorkshiftPaymentLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then begin
            InitialFloatAmount := CashBinCheckpoint."Float Amount";
            CountedAmountInclFloat := CashBinCheckpoint."Counted Amount Incl. Float";
            CalculatedAmountInclFloat := CashBinCheckpoint."Calculated Amount Incl. Float";
            EndingFloatAmount := CashBinCheckpoint."New Float Amount";
        end;

        PrintThermalLine(Printer, InitialFloatAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(InitialFloatAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CountedAmountInclFloatCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CountedAmountInclFloat)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CalculatedAmountInclFloatCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CalculatedAmountInclFloat)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, DifferenceLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CountedAmountInclFloat - CalculatedAmountInclFloat)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, InBankCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(RSReportStatisticsMgt.GetBankDepositAmount(POSWorkshiftCheckpoint."Entry No."))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, EndingFloatAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(EndingFloatAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintItemCategoryPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        WithoutItemCategoryAmount, WithoutItemCategoryQuantity : Decimal;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ItemGroupCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintItemCategories(Printer, POSWorkshiftCheckpoint, WithoutItemCategoryAmount, WithoutItemCategoryQuantity);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintItemCategories(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var WithoutItemCategoryAmount: Decimal; var WithoutItemCategoryQuantity: Decimal)
    var
        POSUnit: Record "NPR POS Unit";
        FromEntryNo: Integer;
        AlreadyProcessedItemCategories: List of [Code[20]];
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := RSReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        PrintItemCategoriesBasedOnQuery(Printer, POSWorkshiftCheckpoint, POSUnit, FromEntryNo, WithoutItemCategoryAmount, WithoutItemCategoryQuantity, AlreadyProcessedItemCategories);
    end;

    local procedure PrintItemCategoriesBasedOnQuery(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSUnit: Record "NPR POS Unit"; FromEntryNo: Integer; var WithoutItemCategoryAmount: Decimal; var WithoutItemCategoryQuantity: Decimal; var AlreadyProcessedItemCategories: List of [Code[20]])
    var
        ItemCategory: Record "Item Category";
        ItemCategoryQuery: Query "NPR RS Sales By Item Category";

    begin
        ItemCategoryQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.");
        ItemCategoryQuery.SetFilter(EntryType, '%1|%2', ItemCategoryQuery.EntryType::"Direct Sale", ItemCategoryQuery.EntryType::"Credit Sale");
        ItemCategoryQuery.SetRange(POSUnitNo, POSUnit."No.");
        ItemCategoryQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        ItemCategoryQuery.Open();
        while ItemCategoryQuery.Read() do 
            if ItemCategoryQuery.ItemCategoryCode = '' then begin
                if ItemCategoryQuery.Type = ItemCategoryQuery.Type::Item then
                    WithoutItemCategoryQuantity += ItemCategoryQuery.Quantity;
                WithoutItemCategoryAmount += ItemCategoryQuery.AmountInclVATLCY;
            end else
                if not AlreadyProcessedItemCategories.Contains(ItemCategoryQuery.ItemCategoryCode) then begin
                    AlreadyProcessedItemCategories.Add(ItemCategoryQuery.ItemCategoryCode);
                    ItemCategory.Get(ItemCategoryQuery.ItemCategoryCode);
                    PrintThermalLine(Printer, ItemCategory.Description, 'A11', true, 'CENTER', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(ProductsQuantityCaptionLbl, Format(ItemCategoryQuery.Quantity)), 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(ItemCategoryQuery.AmountInclVATLCY)), 'A11', false, 'LEFT', true, false);
                end;

        if WithoutItemCategoryQuantity > 0 then begin
            PrintThermalLine(Printer, 'N/A', 'A11', true, 'CENTER', true, false);
            PrintThermalLine(Printer, CaptionValueFormat(ProductsQuantityCaptionLbl, Format(WithoutItemCategoryQuantity)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(WithoutItemCategoryAmount)), 'A11', false, 'LEFT', true, false);
        end;

        ItemCategoryQuery.Close();
    end;
    

    local procedure PrintSalespersonPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonQuery: Query "NPR RS Group Sales by Salespr.";
        FromEntryNo: Integer;
    begin
        PrintThermalLine(Printer, SalesPersonInformationLbl, 'A11', true, 'CENTER', true, false);
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := RSReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        SalespersonQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.");
        SalespersonQuery.SetFilter(EntryType, '%1|%2', SalespersonQuery.EntryType::"Direct Sale", SalespersonQuery.EntryType::"Credit Sale");
        SalespersonQuery.SetRange(POSUnitNo, POSUnit."No.");
        SalespersonQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        SalespersonQuery.Open();
        while (SalespersonQuery.Read()) do
            if SalespersonPurchaser.Get(SalespersonQuery.SalespersonCode) then
                PrintSalespersonInfo(Printer, SalespersonPurchaser, POSWorkshiftCheckpoint);
    end;

    local procedure PrintSalespersonInfo(var Printer: Codeunit "NPR RP Line Print"; SalespersonPurchaser: Record "Salesperson/Purchaser"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        Amount: Decimal;
        FromEntryNo: Integer;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := RSReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        RSReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaser.Code);
        Clear(Amount);
        RSReportStatisticsMgt.CalcSalespersonAmount(POSEntry, Amount);
        PrintThermalLine(Printer, CaptionValueFormat(SalespersonPurchaser.Name, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintPaymentsAmount(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry")
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
                        if not PaymentAmounts.ContainsKey(POSEntryPaymentLine."POS Payment Method Code") then
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

    local procedure PrintGeneralInfo(var Printer: Codeunit "NPR RP Line Print"; SalespersonPurchaserCode: Code[20]; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        FromEntryNo: Integer;
        QuantityCancelled, QuantitySucceed : Integer;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := RSReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        RSReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaserCode);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintSalesTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.");

        PrintThermalLine(Printer, PaymentsTypeLbl, 'A11', true, 'CENTER', true, false);

        PrintPaymentsAmount(Printer, POSEntry);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        RSReportStatisticsMgt.CalcQuantitySucceedAndQuantityCancelled(POSEntry, QuantitySucceed, QuantityCancelled);

        PrintThermalLine(Printer, CaptionValueFormat(CancelledQuantityCaptionLbl, Format(QuantityCancelled)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(SucceedQuantityCaptionLbl, Format(QuantitySucceed)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    internal procedure PrintSalesTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Printed: Boolean;
        AmountIncludingTax, SumOfTotalAmountTax, TaxAmount, TaxBaseAmount : Decimal;
        PrintedTaxRates: Dictionary of [Decimal, Boolean];
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax %");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);
        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %", "Workshift Checkpoint Entry No.");
        POSWorkshTaxCheckp.SetAscending("Tax %", true);
        POSWorkshTaxCheckp.FindSet();
        repeat
            RSReportStatisticsMgt.CalcTaxAmounts(POSEntry, true, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, AmountIncludingTax);
            SumOfTotalAmountTax += TaxAmount;

            if AmountIncludingTax <> 0 then
                if not PrintedTaxRates.ContainsKey(POSWorkshTaxCheckp."Tax %") then begin
                    PrintedTaxRates.Add(POSWorkshTaxCheckp."Tax %", true);

                    if not Printed then begin
                        PrintThermalLine(Printer, TaxCaptionLbl, 'A11', true, 'CENTER', true, false);
                        Printed := true;
                    end;
                    PrintTaxAmountsSection(Printer, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount);
                end;
        until POSWorkshTaxCheckp.Next() = 0;

        if Printed then begin
            PrintThermalLine(Printer, CaptionValueFormat(SumOfTotalAmountIncludingTaxCaptionLbl, FormatNumber(SumOfTotalAmountTax)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        end;
    end;

    local procedure PrintTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; TaxPct: Decimal; TaxBaseAmount: Decimal; TaxAmount: Decimal)
    begin
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxBaseAmountCaptionLbl, TaxPct), FormatNumber(TaxBaseAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxAmountCaptionLbl, TaxPct), FormatNumber(TaxAmount)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure FormatNumber(Input: Decimal): Text
    begin
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

    var
        RSReportStatisticsMgt: Codeunit "NPR RS Report Statistics Mgt.";
        ReportDateCaptionLbl: Label 'Datum', Locked = true;
        BrutoSalesCaptionLbl: Label 'Bruto promet', Locked = true;
        CalculatedAmountInclFloatCaptionLbl: Label 'Izračunati iznos u gotovini', Locked = true;
        CancelledQuantityCaptionLbl: Label 'Broj storniranih racuna', Locked = true;
        CountedAmountInclFloatCaptionLbl: Label 'Prebrojan iznos u gotovini', Locked = true;
        DifferenceLbl: Label 'Razlika u gorovini', Locked = true;
        EndingFloatAmountCaptionLbl: Label 'Stanje u kasi', Locked = true;
        EndOfDayCaptionLbl: Label 'Kraj dana', Locked = true;
        InBankCaptionLbl: Label 'Uplata u banku', Locked = true;
        InitialFloatAmountCaptionLbl: Label 'Pocetno stanje u kasi', Locked = true;
        ItemGroupCaptionLbl: Label 'Po grupama asortimana', Locked = true;
        LCYCaptionLbl: Label 'RSD', Locked = true;
        NetoSalesCaptionLbl: Label 'Neto promet', Locked = true;
        PaymentsTypeLbl: Label 'Vrste placanja', Locked = true;
        POSUnitNameCaptionLbl: Label 'Kasa', Locked = true;
        POSUnitNoCaptionLbl: Label 'Broj kase', Locked = true;
        ProductsQuantityCaptionLbl: Label 'Broj proizvoda', Locked = true;
        ReturnCaptionLbl: Label 'Povrat', Locked = true;
        SalesPersonInformationLbl: Label 'Ukupan iznos prodaja po kasiru', Locked = true;
        SucceedQuantityCaptionLbl: Label 'Broj izdatih racuna', Locked = true;
        SumOfTotalAmountIncludingTaxCaptionLbl: Label 'Ukupno poreza', Locked = true;
        TaxAmountCaptionLbl: Label '%1% PDV', Comment = '%1 - specifikuje PDV %', Locked = true;
        TaxBaseAmountCaptionLbl: Label '%1% Osnova', Comment = '%1 - specifikuje PDV %', Locked = true;
        TaxCaptionLbl: Label 'PDV', Locked = true;
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
        TotalDiscountAmountCaptionLbl: Label 'Ukupno popusta', Locked = true;
        VATRegNumberCaptionLbl: Label 'PIB', Locked = true;
        XReportEntryNoCaptionLbl: Label 'X-izveštaj broj', Locked = true;
        ZReportEntryNoCaptionLbl: Label 'Z-izveštaj broj', Locked = true;
}
