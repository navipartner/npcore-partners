codeunit 6184562 "NPR NO Fiscal Thermal Print"
{
    Access = Internal;

    internal procedure PrintEndOfDayReceipt(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
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
        PrintItemCategoryPart(Printer, POSWorkshiftCheckpoint);
        PrintSalespersonPart(Printer, POSWorkshiftCheckpoint);
        PrintTotalsPart(Printer, POSWorkshiftCheckpoint);
        PrintMoreInfoPart(Printer, POSWorkshiftCheckpoint);

        PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'CENTER', true, false);

        PrinterDeviceSettings.Init();
        PrinterDeviceSettings.Name := 'ENCODING';
        PrinterDeviceSettings.Value := 'Windows-1251';
        PrinterDeviceSettings.Insert();

        Printer.ProcessBuffer(Codeunit::"NPR NO Fiscal Thermal Print", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    #region Printing Parts of The Receipt

    local procedure PrintReceiptHeader(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CompanyInfo: Record "Company Information";
        POSAuditLog: Record "NPR POS Audit Log";
        ZReportPOSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        FirstLoginDatetime: DateTime;
        PreviousZReportDateTime: DateTime;
        CompanyAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies Company Address, %2 - specifies Company City, %3 - specifies Company Post Code', Locked = true;
        VATRegistationNoLbl: Label '%1 MVA', Locked = true;
        PrintTxt: Text;
        PrintTxt2: Text;
        PrintTxt3: Text;
    begin
        CompanyInfo.Get();
        ZReportPOSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        SalespersonPurchaser.Get(ZReportPOSEntry."Salesperson Code");
        PrintTxt := Format(POSWorkshiftCheckpoint.SystemCreatedAt);

        PrintThermalLine(Printer, CompanyInfo.Name, 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(CompanyAddressInfoLbl, CompanyInfo.Address, CompanyInfo.City, CompanyInfo."Post Code"), 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        PrintThermalLine(Printer, CaptionValueFormat(LastZReportCaptionLbl, Format(PreviousZReportDateTime)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DateCaptionLbl, PrintTxt), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ZReportEntryNoCaptionLbl, Format(POSWorkshiftCheckpoint."Entry No.")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNoCaptionLbl, POSUnit."No."), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNameCaptionLbl, POSUnit.Name), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(VATRegNumberCaptionLbl, StrSubstNo(VATRegistationNoLbl, CompanyInfo."VAT Registration No.")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, POSOpenedByCaptionLbl, 'A11', true, 'LEFT', true, false);

        FirstLoginDatetime := CreateDateTime(DT2Date(POSWorkshiftCheckpoint.SystemCreatedAt), 060000T);
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', FirstLoginDatetime, POSWorkshiftCheckpoint.SystemCreatedAt);

        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_IN);
        if POSAuditLog.FindFirst() then begin
            PrintTxt2 := Format(POSAuditLog.SystemCreatedAt);
            if SalespersonPurchaser2.Get(POSAuditLog."Active Salesperson Code") then
                PrintTxt3 := SalespersonPurchaser2.Name;
        end;
        PrintThermalLine(Printer, PrintTxt3, 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, PrintTxt2, 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, POSClosedByCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, SalespersonPurchaser.Name, 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, PrintTxt, 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintEODPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CardDifference, CashDifference, EndingFloatCash, InitialFloatCash, TotalEndingCards : Decimal;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, EndOfDayCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, BrutoSalesCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ReturnCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Returns (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, NetoSalesCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Direct Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."Direct Item Returns (LCY)"))), 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, TipsCaptionLbl, 'A11', true, 'LEFT', true, false); // TODO: Tips, not implemented
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(0.00)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, IssuedVoucherCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Issued Vouchers (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, RedeemedVoucherCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)")), 'A11', false, 'LEFT', true, false);

        if NOReportStatisticsMgt.FindCashBalacingLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then begin
            InitialFloatCash := CashBinCheckpoint."Float Amount";
            EndingFloatCash := CashBinCheckpoint."Counted Amount Incl. Float";
        end;

        PrintThermalLine(Printer, InitialFloatCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(InitialFloatCash)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, EndFloatCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(EndingFloatCash)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, InBankCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(NOReportStatisticsMgt.GetBankDepositAmount(POSWorkshiftCheckpoint."Entry No."))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, EndFloatCashCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(EndingFloatCash)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, StartCardCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintCardTerminalsPart(Printer, POSWorkshiftCheckpoint."Entry No.", TotalEndingCards, CardDifference);

        PrintThermalLine(Printer, StartOtherCaptionLbl, 'A11', true, 'LEFT', true, false);
        // TODO: Field source is not certain 
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(0)), 'A11', false, 'LEFT', true, false);

        // TODO: Related to Members with Loyalty cards
        PrintThermalLine(Printer, LoyaltiesCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(0)), 'A11', false, 'LEFT', true, false);

        CashDifference := CashBinCheckpoint."Counted Amount Incl. Float" - CashBinCheckpoint."Calculated Amount Incl. Float";
        PrintThermalLine(Printer, DifferenceCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(Abs(CashDifference))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, DifferenceCardCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(Abs(CardDifference))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, TotalDifferenceCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(Abs(CashDifference) + Abs(CardDifference))), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintCardTerminalsPart(var Printer: Codeunit "NPR RP Line Print Mgt."; WorkshiftCheckpointEntryNo: Integer; var TotalCards: Decimal; var TotalDifference: Decimal)
    var
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);

        if not PaymentBinCheckpoint.FindSet() then
            exit;

        repeat
            POSPaymentMethod.Get(PaymentBinCheckpoint."Payment Method No.");
            if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT then begin
                PrintThermalLine(Printer, CaptionValueFormat(PaymentBinCheckpoint."Payment Method No.", FormatNumber(PaymentBinCheckpoint."Counted Amount Incl. Float")), 'A11', false, 'LEFT', true, false);
                TotalCards += PaymentBinCheckpoint."Counted Amount Incl. Float";
                TotalDifference += PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Calculated Amount Incl. Float";
            end;
        until PaymentBinCheckpoint.Next() = 0;
    end;

    local procedure PrintItemCategoryPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity : Decimal;
        FromEntryNo: Integer;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ItemCategoryCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintItemCategories(Printer, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", POSUnit, WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, POSLawCategoriesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintThermalLine(Printer, UncategorizedSalesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(SoldProductsCaptionLbl, Format(Round(WithoutItemCategoryQuantity, 1, '='))), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(WithoutItemCategoryAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CategorizedSalesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(SoldProductsCaptionLbl, Format(Round(WithItemCategoryQuantity, 1, '='))), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(WithItemCategoryAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintItemCategories(var Printer: Codeunit "NPR RP Line Print Mgt."; FromEntryNo: Integer; ToPOSEntryNo: Integer; POSUnit: Record "NPR POS Unit"; var WithItemCategoryAmount: Decimal; var WithoutItemCategoryAmount: Decimal; var WithItemCategoryQuantity: Decimal; var WithoutItemCategoryQuantity: Decimal)
    var
        ItemCategory: Record "Item Category";
        ItemCategoryQuery: Query "NPR NO Sales By Item Category";
    begin
        Clear(WithItemCategoryAmount);
        Clear(WithItemCategoryQuantity);
        Clear(WithoutItemCategoryAmount);
        Clear(WithoutItemCategoryQuantity);
        ItemCategoryQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, ToPOSEntryNo);
        ItemCategoryQuery.SetFilter(EntryType, '%1|%2', ItemCategoryQuery.EntryType::"Direct Sale", ItemCategoryQuery.EntryType::"Credit Sale");
        ItemCategoryQuery.SetRange(POSUnitNo, POSUnit."No.");
        ItemCategoryQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        ItemCategoryQuery.Open();
        while ItemCategoryQuery.Read() do begin
            if ItemCategoryQuery.ItemCategoryCode = '' then begin
                WithoutItemCategoryQuantity := ItemCategoryQuery.Quantity;
                WithoutItemCategoryAmount := ItemCategoryQuery.AmountInclVATLCY;
            end;

            if ItemCategory.Get(ItemCategoryQuery.ItemCategoryCode) then begin
                PrintThermalLine(Printer, ItemCategory.Description, 'A11', true, 'CENTER', true, false);
                PrintThermalLine(Printer, CaptionValueFormat(SoldProductsCaptionLbl, Format(Round(ItemCategoryQuery.Quantity, 1, '='))), 'A11', false, 'LEFT', true, false);
                PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(ItemCategoryQuery.AmountInclVATLCY)), 'A11', false, 'LEFT', true, false);
                WithItemCategoryQuantity += ItemCategoryQuery.Quantity;
                WithItemCategoryAmount += ItemCategoryQuery.AmountInclVATLCY;
            end;
        end;
        ItemCategoryQuery.Close();
    end;

    local procedure PrintSalespersonPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonQuery: Query "NPR NO Group Sales by Salespr.";
        FromEntryNo: Integer;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        SalespersonQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.");
        SalespersonQuery.SetFilter(EntryType, '%1|%2', SalespersonQuery.EntryType::"Direct Sale", SalespersonQuery.EntryType::"Credit Sale");
        SalespersonQuery.SetRange(POSUnitNo, POSUnit."No.");
        SalespersonQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        SalespersonQuery.Open();
        while (SalespersonQuery.Read()) do
            if SalespersonPurchaser.Get(SalespersonQuery.SalespersonCode) then
                PrintSalespersonInfo(Printer, SalespersonPurchaser, POSWorkshiftCheckpoint);
    end;

    local procedure PrintSalespersonInfo(var Printer: Codeunit "NPR RP Line Print Mgt."; SalespersonPurchaser: Record "Salesperson/Purchaser"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        Amount, Amount2 : Decimal;
        AmountCards, AmountOther, CopyTicketAmount, DiscountAmount, ReturnAmount : Decimal;
        CountCards, CountOther, CountReturned : Integer;
        FromEntryNo: Integer;
        Quantity, Quantity2, Quantity3 : Integer;
        SalespersonLbl: Label '%1 (%2)', Comment = '%1 - Name, %2 - Code', Locked = true;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(SalespersonLbl, SalespersonPurchaser.Name, SalespersonPurchaser.Code), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaser.Code);
        Clear(Amount);
        Clear(Quantity);
        NOReportStatisticsMgt.CalcCardsAmountAndQuantity(POSEntry, AmountCards, CountCards);

        PrintThermalLine(Printer, CaptionValueFormat(QuantityCardCaptionLbl, Format(CountCards)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalCardsCaptionLbl, FormatNumber(AmountCards)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcOtherPaymentsAmountAndQuantity(POSEntry, AmountOther, CountOther);

        PrintThermalLine(Printer, CaptionValueFormat(QuantityOtherCaptionLbl, Format(CountOther)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalOtherCaptionLbl, FormatNumber(AmountOther)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CorrectionsCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(SalespersonLbl, SalespersonPurchaser.Name, SalespersonPurchaser.Code), 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        Clear(Quantity);
        Quantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::DELETE_POS_SALE_LINE);

        PrintThermalLine(Printer, CaptionValueFormat(ZeroLinesCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, GeneralInfoCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        NOReportStatisticsMgt.CalcReturnsAndSalesAmount(POSEntry, Amount, ReturnAmount);

        PrintThermalLine(Printer, CaptionValueFormat(BrutoSalesCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReturnCaptionLbl, FormatNumber(ReturnAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(Amount - Abs(ReturnAmount))), 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(SumOfVATCaptionLbl, FormatNumber(Amount2)), 'A11', false, 'LEFT', true, false);
        PrintTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", false);

        PrintThermalLine(Printer, SumOfVATOnReturnCaptionLbl, 'A11', false, 'LEFT', true, false);
        PrintTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", true);

        Clear(Amount);
        if NOReportStatisticsMgt.FindCashBalacingLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then
            Amount := CashBinCheckpoint."Float Amount";

        PrintThermalLine(Printer, CaptionValueFormat(InitialFloatCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(QuantityOtherCaptionLbl, Format(CountOther)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(QuantityCardCaptionLbl, Format(CountCards)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcReturnSaleDiscountQuantity(POSEntry, DiscountAmount, CountReturned, Quantity, Quantity2, Quantity3);

        PrintThermalLine(Printer, CaptionValueFormat(SoldProductsCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(ReturnedProductsQuantityCaptionLbl, Format(Quantity2)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TrainingReceiptQtyCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ProvisionalReceiptQtyCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DeliveryReceiptQtyCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(SalesQuantityCaptionLbl, Format(CountCards + CountOther)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReturnQuantityCaptionLbl, Format(CountReturned)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DiscountQuantityCaptionLbl, Format(Quantity3)), 'A11', false, 'LEFT', true, false);

        Clear(Quantity);
        Quantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);

        PrintThermalLine(Printer, CaptionValueFormat(POSOpeningQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcCopyAndPrintReceiptsQuantity(POSEntry, CopyTicketAmount, Quantity, Quantity2);

        Clear(Quantity3);
        Quantity3 := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::CANCEL_SALE_END);

        PrintThermalLine(Printer, CaptionValueFormat(NotEndedSalesQuantityCaptionLbl, Format(Quantity3)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(PrintedReceiptsQuantityCaptionLbl, Format(Quantity2)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(CopiedReceiptsQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        Clear(Quantity);
        Quantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::PRICE_CHECK);

        PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(ProformaReceiptsCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(PrepaidQuantityCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);

        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        Clear(Quantity);
        Quantity := POSEntry.Count();

        PrintThermalLine(Printer, CaptionValueFormat(CancelledQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(TotalOtherCaptionLbl, FormatNumber(AmountOther)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalCardsCaptionLbl, FormatNumber(AmountCards)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalReturnAmountCaptionLbl, FormatNumber(ReturnAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalDiscountAmountCaptionLbl, FormatNumber(DiscountAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(TrainingReceiptAmountCaptionLbl, FormatNumber(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ProvisionalReceiptAmountCaptionLbl, FormatNumber(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DeliveryReceiptAmountCaptionLbl, FormatNumber(0)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CaptionValueFormat(CopyReceiptsAmountCaptionLbl, FormatNumber(CopyTicketAmount)), 'A11', false, 'LEFT', true, false);
        // TODO: total prepaid
        PrintThermalLine(Printer, CaptionValueFormat(TotalPrepaidCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);
        // TODO: total pro forma
        PrintThermalLine(Printer, CaptionValueFormat(ProformaReceiptsAmountCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcCancelledReceiptsAmount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, Amount);

        PrintThermalLine(Printer, CaptionValueFormat(TotalOnCancelledCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintMoreInfoPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        FromEntryNo: Integer;
        AppVerTxt: Text;
        PrintTxt: Text;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, MoreInfoCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", '');

        if POSEntry.FindFirst() then begin
            PrintTxt := Format(POSEntry.SystemCreatedAt);
            PrintThermalLine(Printer, CaptionValueFormat(FirstSaleCaptionLbl, PrintTxt), 'A11', false, 'LEFT', true, false)
        end
        else
            PrintThermalLine(Printer, CaptionValueFormat(FirstSaleCaptionLbl, ''), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", '');

        if POSEntry.FindLast() then begin
            PrintTxt := Format(POSEntry.SystemCreatedAt);
            PrintThermalLine(Printer, CaptionValueFormat(LastSaleCaptionLbl, PrintTxt), 'A11', false, 'LEFT', true, false)
        end else
            PrintThermalLine(Printer, CaptionValueFormat(LastSaleCaptionLbl, ''), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.GetAppVersionText(AppVerTxt);

        PrintThermalLine(Printer, CaptionValueFormat(AppVersionCaptionLbl, AppVerTxt), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintTotalsPart(var Printer: Codeunit "NPR RP Line Print Mgt."; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
        POSWorkshiftCheckpoint.CalcFields("FF Total Dir. Item Return(LCY)", "FF Total Dir. Item Sales (LCY)");
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalReturnAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesNetoCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)"))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    #endregion Printing Parts of The Receipts

    #region Printer Helper Functions

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

    #endregion Printer Helper Functions

    local procedure PrintTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print Mgt."; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer; IsReturn: Boolean)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Amount: Decimal;
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);

        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %", "Workshift Checkpoint Entry No.");
        POSWorkshTaxCheckp.FindSet();
        repeat
            if IsReturn then
                NOReportStatisticsMgt.CalcReturnTaxAmount(POSEntry, Amount, POSWorkshTaxCheckp."Tax %", true)
            else
                NOReportStatisticsMgt.CalcTaxAmount(POSEntry, Amount, POSWorkshTaxCheckp."Tax %", true);
            PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(VATPctCaptionLbl, POSWorkshTaxCheckp."Tax %"), FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
        until POSWorkshTaxCheckp.Next() = 0;
    end;

    var
        NOReportStatisticsMgt: Codeunit "NPR NO Report Statistics Mgt.";
        EndOfDayCaptionLbl: Label 'EOD', Locked = true;
        LCYCaptionLbl: Label 'NOK', Locked = true;
        LastZReportCaptionLbl: Label 'Siste Z-rapport', Locked = true;
        DateCaptionLbl: Label 'Dato', Locked = true;
        ZReportEntryNoCaptionLbl: Label 'Z-rapport Serienummer', Locked = true;
        POSUnitNoCaptionLbl: Label 'Kasse-ID', Locked = true;
        POSUnitNameCaptionLbl: Label 'Kassenavn', Locked = true;
        VATRegNumberCaptionLbl: Label 'MVA nummer', Locked = true;
        POSOpenedByCaptionLbl: Label 'Åpnet av', Locked = true;
        POSClosedByCaptionLbl: Label 'Lukket av', Locked = true;
        BrutoSalesCaptionLbl: Label 'Bruttoomsetning', Locked = true;
        ReturnCaptionLbl: Label 'Returer', Locked = true;
        NetoSalesCaptionLbl: Label 'Omsetning', Locked = true;
        TipsCaptionLbl: Label 'Driks', Locked = true;
        IssuedVoucherCaptionLbl: Label 'Solgt gavekort', Locked = true;
        RedeemedVoucherCaptionLbl: Label 'Innløst gavekort', Locked = true;
        InitialFloatCaptionLbl: Label 'Kontanter ved start', Locked = true;
        EndFloatCaptionLbl: Label 'Kontanter ved slutt', Locked = true;
        InBankCaptionLbl: Label 'Innskudd til bank', Locked = true;
        EndFloatCashCaptionLbl: Label 'Kontanter ved dagens slutt', Locked = true;
        StartCardCaptionLbl: Label 'Kort ved slutt', Locked = true;
        StartOtherCaptionLbl: Label 'Annet ved slutt', Locked = true;
        LoyaltiesCaptionLbl: Label 'Lojalitetspoeng', Locked = true;
        DifferenceCaptionLbl: Label 'Avvik kontant', Locked = true;
        DifferenceCardCaptionLbl: Label 'Avvik kort', Locked = true;
        TotalDifferenceCaptionLbl: Label 'Avvik total', Locked = true;
        ItemCategoryCaptionLbl: Label 'Artikkelgruppe', Locked = true;
        SoldProductsCaptionLbl: Label 'Antall solgte produkter', Locked = true;
        QuantityCardCaptionLbl: Label 'Antall kort', Locked = true;
        TotalCardsCaptionLbl: Label 'Totalt kort', Locked = true;
        QuantityOtherCaptionLbl: Label 'Antall annet', Locked = true;
        TotalOtherCaptionLbl: Label 'Totalt annet', Locked = true;
        CorrectionsCaptionLbl: Label 'Korreksjoner pr bruker', Locked = true;
        ZeroLinesCaptionLbl: Label 'Linjeantall redusert til 0', Locked = true;
        GeneralInfoCaptionLbl: Label 'Generell info', Locked = true;
        SumOfVATCaptionLbl: Label 'Sum MVA', Locked = true;
        VATPctCaptionLbl: Label 'MVA %1%', Comment = '%1 - specifies VAT %', Locked = true;
        ReturnedProductsQuantityCaptionLbl: Label 'Antall returnerte produkter', Locked = true;
        SalesQuantityCaptionLbl: Label 'Antall salg', Locked = true;
        ReturnQuantityCaptionLbl: Label 'Antall returer', Locked = true;
        DiscountQuantityCaptionLbl: Label 'Antall rabatterte salg', Locked = true;
        NotEndedSalesQuantityCaptionLbl: Label 'Antall uavsluttede handeler', Locked = true;
        PrintedReceiptsQuantityCaptionLbl: Label 'Antall utskrevne kvitteringer', Locked = true;
        CopiedReceiptsQuantityCaptionLbl: Label 'Antall kopi kvitteringer', Locked = true;
        CancelledQuantityCaptionLbl: Label 'Antall kansellerte ordrer', Locked = true;
        TotalDiscountAmountCaptionLbl: Label 'Totalt rabatter', Locked = true;
        TotalReturnAmountCaptionLbl: Label 'Totalt returnert', Locked = true;
        MoreInfoCaptionLbl: Label 'Tilleggsinfo', Locked = true;
        FirstSaleCaptionLbl: Label 'Første salg', Locked = true;
        LastSaleCaptionLbl: Label 'Siste salg', Locked = true;
        AppVersionCaptionLbl: Label 'App versjon', Locked = true;
        SumOfVATOnReturnCaptionLbl: Label 'Sum MVA fra returer', Locked = true;
        TotalPrepaidCaptionLbl: Label 'Totalt forhåndsbetalinger', Locked = true;
        POSOpeningQuantityCaptionLbl: Label 'Antall skuffåpninger', Locked = true;
        ProformaReceiptsCaptionLbl: Label 'Antall utskrevne pro forma kvittering', Locked = true;
        ProformaReceiptsAmountCaptionLbl: Label 'Omsetning pro forma kvittering', Locked = true;
        PrepaidQuantityCaptionLbl: Label 'Antall forhåndsbetalinger', Locked = true;
        TotalOnCancelledCaptionLbl: Label 'Totalt fra kansellerte salg', Locked = true;
        TotalSalesAmountCaptionLbl: Label 'Totalt salg', Locked = true;
        TotalSalesNetoCaptionLbl: Label 'Totalt netto', Locked = true;
        POSLawCategoriesCaptionLbl: Label 'Kassalov-kategorier', Locked = true;
        UncategorizedSalesCaptionLbl: Label '04999 - Other', Locked = true;
        CategorizedSalesCaptionLbl: Label '04999 - Øvrige', Locked = true;
        PriceLookupQuantityCaptionLbl: Label 'Antall prisoppslag', Locked = true;
        CopyReceiptsAmountCaptionLbl: Label 'Totalt kopi kvitteringer', Locked = true;
        ProvisionalReceiptQtyCaptionLbl: Label 'Antall foreløpige kvitteringer', Locked = true;
        TrainingReceiptQtyCaptionLbl: Label 'Antall opplærings kvitteringer', Locked = true;
        DeliveryReceiptQtyCaptionLbl: Label 'Antall leverings kvitteringer', Locked = true;
        ProvisionalReceiptAmountCaptionLbl: Label 'Totalt foreløpige kvitteringer', Locked = true;
        TrainingReceiptAmountCaptionLbl: Label 'Totalt opplærings kvitteringer', Locked = true;
        DeliveryReceiptAmountCaptionLbl: Label 'Totalt leverings kvitteringer', Locked = true;
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
}