codeunit 6184856 "NPR SE CleanCash Fiscal Print"
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
        SEFisclaizationTable: Record "NPR SE Fiscalization Setup.";
        POSUnitMissingErr: Label 'POS Unit is missing on the Workshift.';
        SEFiscalizationNotEnabledErrLbl: Label 'Sweden fiscalization is not enabled on the POS Unit: %1 (%2).', Comment = '%1 - specifies POS Unit Name, %2 - specifies POS Unit No.';
    begin
        SEFisclaizationTable.Get();
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            Error(POSUnitMissingErr);
        if not SEFisclaizationTable."Enable SE Fiscal" then
            Error(SEFiscalizationNotEnabledErrLbl, POSUnit.Name, POSUnit."No.");

        PrintThermalReceipt(POSWorkshiftCheckpoint);
    end;

    local procedure PrintThermalReceipt(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        Printer: Codeunit "NPR RP Line Print Mgt.";
    begin
        Printer.SetThreeColumnDistribution(0.35, 0.465, 0.235);
        Printer.SetAutoLineBreak(false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintReceiptHeader(Printer, POSWorkshiftCheckpoint);
        PrintEODPart(Printer, POSWorkshiftCheckpoint);
        PrintGeneralInfo(Printer, '', POSWorkshiftCheckpoint);
        PrintTotalsPart(Printer, POSWorkshiftCheckpoint);

        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR SE CleanCash Fiscal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintReceiptHeader(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CompanyInfo: Record "Company Information";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSStoreAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies POS Store Address, %2 - specifies POS Store City, %3 - specifies POS Store Post Code', Locked = true;
        VATRegistationNoLbl: Label '%1', Comment = '%1 - specifies Company Information VAT Registration No.', Locked = true;
        PrintTxt: Text;
    begin
        CompanyInfo.Get();
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        POSStore.Get(POSUnit."POS Store Code");
        PrintTxt := Format(POSWorkshiftCheckpoint.SystemCreatedAt);

        PrintThermalLine(Printer, CompanyInfo.Name, 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(POSStoreAddressInfoLbl, POSStore.Address, POSStore.City, POSStore."Post Code"), 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(VATRegNumberCaptionLbl, StrSubstNo(VATRegistationNoLbl, CompanyInfo."VAT Registration No.")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::XREPORT then
            PrintThermalLine(Printer, XReportCaptionLbl, 'A11', false, 'LEFT', true, false)
        else
            PrintThermalLine(Printer, ZReportCaptionLbl, 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(DateCaptionLbl, PrintTxt), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReportEntryNoCaptionLbl, Format(POSWorkshiftCheckpoint."Entry No.")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNoCaptionLbl, POSUnit."No."), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintEODPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CalculatedAmountInclFloat, CountedAmountInclFloat, Difference, EndingFloatAmount : Decimal;
    begin
        if SEReportStatisticsMgt.FindCashBalacingLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then begin
            CountedAmountInclFloat := CashBinCheckpoint."Counted Amount Incl. Float";
            CalculatedAmountInclFloat := CashBinCheckpoint."Calculated Amount Incl. Float";
            EndingFloatAmount := CashBinCheckpoint."New Float Amount";
        end;
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DirectSalesCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DirectSalesQuantityCaptionLbl, Format(POSWorkshiftCheckpoint."Direct Item Sales Quantity")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReturnCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReturnCaptionQuantityLbl, Format(POSWorkshiftCheckpoint."Direct Item Returns Quantity")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TurnoverLbl, FormatNumber(POSWorkshiftCheckpoint."Turnover (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DiscountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Total Discount (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(SumCashLbl, FormatNumber(EndingFloatAmount)), 'A11', false, 'LEFT', true, false);

        PrintCardTerminalsPart(Printer, POSWorkshiftCheckpoint."Entry No.");
        PrintOtherPaymentsPart(Printer, POSWorkshiftCheckpoint."Entry No.");

        Difference := CountedAmountInclFloat - CalculatedAmountInclFloat;
        PrintThermalLine(Printer, CaptionValueFormat(DifferenceCaptionLbl, FormatNumber(Difference)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintTotalsPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
        POSWorkshiftCheckpoint.CalcFields("FF Total Dir. Item Return(LCY)", "FF Total Dir. Item Sales (LCY)");
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalReturnAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesNetoCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)"))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print Mgt."; TaxPct: Decimal; TaxBaseAmount: Decimal; TaxAmount: Decimal)
    begin
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxBaseAmountCaptionLbl, TaxPct), FormatNumber(TaxBaseAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxAmountCaptionLbl, TaxPct), FormatNumber(TaxAmount)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintedReceiptCopyReceiptAmountQuantity(var Printer: Codeunit "NPR RP Line Print Mgt."; SalespersonPurchaserCode: Code[20]; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PreviousZReportDateTime: DateTime)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        CopyTicketAmount: Decimal;
        FromEntryNo: Integer;
        Quantity: Integer;
    begin
        FromEntryNo := SEReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");
        SEReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaserCode);
        Quantity := SEReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);
        PrintThermalLine(Printer, CaptionValueFormat(POSOpeningQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        SEReportStatisticsMgt.CalcCopyAndPrintReceiptsQuantity(POSEntry, CopyTicketAmount, Quantity);
        Quantity := SEReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::RECEIPT_COPY);
        PrintThermalLine(Printer, CaptionValueFormat(PrintedReceiptsQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(CopyReceiptsAmountCaptionLbl, FormatNumber(CopyTicketAmount)), 'A11', false, 'LEFT', true, false);

        Quantity := SEReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::RECEIPT_PRINT);
        PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure SavedSalesCCTrainingQuantityAmount(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PreviousZReportDateTime: DateTime)
    var
        CleanCashTrans: Record "NPR CleanCash Trans. Request";
        POSSavedSale: Record "NPR POS Saved Sale Entry";
    begin
        POSSavedSale.SetFilter(SystemCreatedAt, '%1..%2', PreviousZReportDateTime, POSWorkshiftCheckpoint.SystemCreatedAt);
        POSSavedSale.SetRange("Register No.", POSWorkshiftCheckpoint."POS Unit No.");
        case POSSavedSale.FindSet() of
            true:
                begin
                    POSSavedSale.CalcFields("Amount Including VAT");
                    PrintThermalLine(Printer, CaptionValueFormat(CountSavedSalesLbl, Format(POSSavedSale.Count)), 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(SumSavedSalesLbl, FormatNumber(POSSavedSale."Amount Including VAT")), 'A11', false, 'LEFT', true, false);
                end;
            false:
                begin
                    PrintThermalLine(Printer, CaptionValueFormat(CountSavedSalesLbl, '0'), 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(SumSavedSalesLbl, '0'), 'A11', false, 'LEFT', true, false);
                end;
        end;

        CleanCashTrans.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        CleanCashTrans.SetFilter(SystemCreatedAt, '%1..%2', PreviousZReportDateTime, POSWorkshiftCheckpoint.SystemCreatedAt);
        CleanCashTrans.SetRange("Receipt Type", CleanCashTrans."Receipt Type"::ovning);
        case CleanCashTrans.FindSet() of
            true:
                begin
                    POSSavedSale.CalcFields(Amount);
                    PrintThermalLine(Printer, CaptionValueFormat(CountCCTransactionLbl, Format(CleanCashTrans.Count)), 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(SumCCTransactionLbl, Format(POSSavedSale.Amount)), 'A11', false, 'LEFT', true, false);
                end;
            false:
                begin
                    PrintThermalLine(Printer, CaptionValueFormat(CountCCTransactionLbl, '0'), 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, CaptionValueFormat(SumCCTransactionLbl, '0'), 'A11', false, 'LEFT', true, false);
                end
        end;
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintGeneralInfo(var Printer: Codeunit "NPR RP Line Print Mgt."; SalespersonPurchaserCode: Code[20]; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        FromEntryNo: Integer;

    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := SEReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        SEReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaserCode);

        if SEReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        PrintSalesTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.");
        PrintReturnTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.");
        PrintedReceiptCopyReceiptAmountQuantity(Printer, SalespersonPurchaserCode, POSWorkshiftCheckpoint, PreviousZReportDateTime);
        SavedSalesCCTrainingQuantityAmount(Printer, POSWorkshiftCheckpoint, PreviousZReportDateTime);
    end;

    local procedure PrintSalesTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print Mgt."; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Printed: Boolean;
        AmountIncludingTax, SumOfTotalAmountIncludingTax, TaxAmount, TaxBaseAmount : Decimal;
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax %");
        POSWorkshTaxCheckp.SetAscending("Tax %", true);
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);
        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %");
        POSWorkshTaxCheckp.FindSet();
        repeat
            SEReportStatisticsMgt.CalcTaxAmounts(POSEntry, true, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, AmountIncludingTax);
            SumOfTotalAmountIncludingTax += AmountIncludingTax;
            if AmountIncludingTax <> 0 then begin
                if not Printed then begin
                    PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
                    Printed := true;
                end;

                PrintTaxAmountsSection(Printer, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount);
            end;
        until POSWorkshTaxCheckp.Next() = 0;
        if Printed then begin
            PrintThermalLine(Printer, CaptionValueFormat(SumOfTotalAmountIncludingTaxCaptionLbl, FormatNumber(SumOfTotalAmountIncludingTax)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        end;
    end;

    local procedure PrintReturnTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print Mgt."; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Printed: Boolean;
        AmountIncludingTax, SumOfTotalAmountIncludingTax, TaxAmount, TaxBaseAmount : Decimal;
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax %");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);
        POSWorkshTaxCheckp.SetAscending("Tax %", true);
        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %");
        POSWorkshTaxCheckp.FindSet();
        repeat
            SEReportStatisticsMgt.CalcReturnTaxAmounts(POSEntry, true, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, AmountIncludingTax);
            SumOfTotalAmountIncludingTax += AmountIncludingTax;

            if AmountIncludingTax <> 0 then begin
                if not Printed then begin
                    PrintThermalLine(Printer, TaxOnReturnCaptionLbl, 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
                    Printed := true;
                end;

                PrintTaxAmountsSection(Printer, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount);
            end;
        until POSWorkshTaxCheckp.Next() = 0;

        if Printed then begin
            PrintThermalLine(Printer, CaptionValueFormat(SumOfTotalAmountIncludingTaxCaptionLbl, FormatNumber(SumOfTotalAmountIncludingTax)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        end;
    end;

    local procedure PrintCardTerminalsPart(var Printer: Codeunit "NPR RP Line Print Mgt."; WorkshiftCheckpointEntryNo: Integer)
    var
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);

        if PaymentBinCheckpoint.IsEmpty() then
            exit;

        PaymentBinCheckpoint.FindSet();
        repeat
            POSPaymentMethod.Get(PaymentBinCheckpoint."Payment Method No.");
            if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT then
                PrintThermalLine(Printer, CaptionValueFormat(PaymentBinCheckpoint."Payment Method No.", FormatNumber(PaymentBinCheckpoint."Counted Amount Incl. Float")), 'A11', false, 'LEFT', true, false);
        until PaymentBinCheckpoint.Next() = 0;
    end;

    local procedure PrintOtherPaymentsPart(var Printer: Codeunit "NPR RP Line Print Mgt."; WorkshiftCheckpointEntryNo: Integer)
    var
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);

        if PaymentBinCheckpoint.IsEmpty() then
            exit;

        PaymentBinCheckpoint.FindSet();
        repeat
            POSPaymentMethod.Get(PaymentBinCheckpoint."Payment Method No.");
            if not ((POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT) or (POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CASH)) then
                PrintThermalLine(Printer, CaptionValueFormat(PaymentBinCheckpoint."Payment Method No.", FormatNumber(PaymentBinCheckpoint."Counted Amount Incl. Float")), 'A11', false, 'LEFT', true, false);
        until PaymentBinCheckpoint.Next() = 0;
    end;

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
        SEReportStatisticsMgt: Codeunit "NPR SE CC Report Stat. Mgt.";
        CopyReceiptsAmountCaptionLbl: Label 'Totalt antal kopior', Locked = true;
        CountCCTransactionLbl: Label 'Antal träningsförsäljningar', Locked = true;
        CountSavedSalesLbl: Label 'Antal parkerade försäljningar', Locked = true;
        DateCaptionLbl: Label 'Tidpunkt', Locked = true;
        DifferenceCaptionLbl: Label 'Skillnad', Locked = true;
        DirectSalesCaptionLbl: Label 'Total Försäljning', Locked = true;
        DirectSalesQuantityCaptionLbl: Label 'Antal Försäljning', Locked = true;
        DiscountCaptionLbl: Label 'Rabattbelopp', Locked = true;
        POSOpeningQuantityCaptionLbl: Label 'Manuella dränkaröppningar', Locked = true;
        POSUnitNoCaptionLbl: Label 'Kassabeteckning', Locked = true;
        PriceLookupQuantityCaptionLbl: Label 'Antal utfärdade kvitton', Locked = true;
        PrintedReceiptsQuantityCaptionLbl: Label 'Antal kopia kvitton', Locked = true;
        ReturnCaptionLbl: Label 'Totalt returbelopp', Locked = true;
        ReturnCaptionQuantityLbl: Label 'Totalt antal returer', Locked = true;
        SumCashLbl: Label 'Kontanter', Locked = true;
        SumCCTransactionLbl: Label 'Totalt belopp för utbildningskvitton', Locked = true;
        SumOfTotalAmountIncludingTaxCaptionLbl: Label 'Bruto belopp', Locked = true;
        SumSavedSalesLbl: Label 'Totalt av parkerade försäljningar', Locked = true;
        TaxAmountCaptionLbl: Label '%1% Momsbeloppet', Comment = '%1 - specifies VAT %', Locked = true;
        TaxBaseAmountCaptionLbl: Label '%1% Mombass', Comment = '%1 - specifies VAT %', Locked = true;
        TaxOnReturnCaptionLbl: Label 'MOMS returer', Locked = true;
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
        TotalReturnAmountCaptionLbl: Label 'Stor total avkastning', Locked = true;
        TotalSalesAmountCaptionLbl: Label 'Den totala försäljningen', Locked = true;
        TotalSalesNetoCaptionLbl: Label 'Totalt netto', Locked = true;
        TurnoverLbl: Label 'Bruto belopp', Locked = true;
        VATRegNumberCaptionLbl: Label 'Momsregistreringsnummer', Locked = true;
        XReportCaptionLbl: Label 'X-rapport', Locked = true;
        ZReportCaptionLbl: Label 'Z-rapport', Locked = true;
        ReportEntryNoCaptionLbl: Label 'Rapportnummer', Locked = true;
}