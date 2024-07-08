codeunit 6184562 "NPR NO Fiscal Thermal Print"
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
        NOAuditMgt: Codeunit "NPR NO Audit Mgt.";
        NOFiscalizationNotEnabledErrLbl: Label 'Norway fiscalization is not enabled on the POS Unit: %1 (%2).', Comment = '%1 - specifies POS Unit Name, %2 - specifies POS Unit No.';
        POSUnitMissingErrLbl: Label 'POS Unit is missing on the Workshift.';
    begin
        if not POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
            Error(POSUnitMissingErrLbl);

        if not NOAuditMgt.IsNOAuditEnabled(POSUnit."POS Audit Profile") then
            Error(NOFiscalizationNotEnabledErrLbl, POSUnit.Name, POSUnit."No.");

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
        PrintGeneralInfoPart(Printer, POSWorkshiftCheckpoint);
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

    local procedure PrintReceiptHeader(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CompanyInfo: Record "Company Information";
        POSAuditLog: Record "NPR POS Audit Log";
        ZReportPOSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        FirstLoginDatetime: DateTime;
        PreviousZReportDateTime: DateTime;
        POSStoreAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies POS Store Address, %2 - specifies POS Store City, %3 - specifies POS Store Post Code', Locked = true;
        VATRegistationNoLbl: Label '%1 MVA', Comment = '%1 - specifies Company Information VAT Registration No.', Locked = true;
        PrintTxt: Text;
        PrintTxt2: Text;
        PrintTxt3: Text;
        ReportNoCaptionTxt: Text;
    begin
        CompanyInfo.Get();
        ZReportPOSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        POSStore.Get(POSUnit."POS Store Code");
        SalespersonPurchaser.Get(ZReportPOSEntry."Salesperson Code");
        PrintTxt := Format(POSWorkshiftCheckpoint.SystemCreatedAt);

        PrintThermalLine(Printer, CompanyInfo.Name, 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, StrSubstNo(POSStoreAddressInfoLbl, POSStore.Address, POSStore.City, POSStore."Post Code"), 'A11', false, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        if POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::XREPORT then
            ReportNoCaptionTxt := XReportEntryNoCaptionLbl
        else
            ReportNoCaptionTxt := ZReportEntryNoCaptionLbl;

        PrintThermalLine(Printer, CaptionValueFormat(LastZReportCaptionLbl, Format(PreviousZReportDateTime)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(DateCaptionLbl, PrintTxt), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReportNoCaptionTxt, Format(POSWorkshiftCheckpoint."Entry No.")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNoCaptionLbl, POSUnit."No."), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(POSUnitNameCaptionLbl, POSUnit.Name), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(VATRegNumberCaptionLbl, StrSubstNo(VATRegistationNoLbl, CompanyInfo."VAT Registration No.")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, POSOpenedByCaptionLbl, 'A11', true, 'LEFT', true, false);

        FirstLoginDatetime := CreateDateTime(DT2Date(POSWorkshiftCheckpoint.SystemCreatedAt), 060000T);
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', FirstLoginDatetime, POSWorkshiftCheckpoint.SystemCreatedAt);
        POSAuditLog.SetRange("Active POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
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

    local procedure PrintEODPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CalculatedAmountInclFloat, CardDifference, CashDifference, CountedAmountInclFloat, EndingFloatAmount, InitialFloatAmount, TotalEndingCards : Decimal;
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

        PrintThermalLine(Printer, IssuedVoucherCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Issued Vouchers (LCY)")), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, RedeemedVoucherCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)")), 'A11', false, 'LEFT', true, false);

        if NOReportStatisticsMgt.FindCashBalacingLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then begin
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

        PrintThermalLine(Printer, InBankCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(NOReportStatisticsMgt.GetBankDepositAmount(POSWorkshiftCheckpoint."Entry No."))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, EndingFloatAmountCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(EndingFloatAmount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, StartCardCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintCardTerminalsPart(Printer, POSWorkshiftCheckpoint."Entry No.", TotalEndingCards, CardDifference);

        PrintThermalLine(Printer, StartOtherCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintOtherPaymentsPart(Printer, POSWorkshiftCheckpoint."Entry No.");

        CashDifference := CountedAmountInclFloat - CalculatedAmountInclFloat;
        PrintThermalLine(Printer, DifferenceCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CashDifference)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, DifferenceCardCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CardDifference)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, TotalDifferenceCaptionLbl, 'A11', true, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(LCYCaptionLbl, FormatNumber(CashDifference + CardDifference)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintCardTerminalsPart(var Printer: Codeunit "NPR RP Line Print"; WorkshiftCheckpointEntryNo: Integer; var TotalCards: Decimal; var TotalDifference: Decimal)
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
            if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT then begin
                PrintThermalLine(Printer, CaptionValueFormat(PaymentBinCheckpoint."Payment Method No.", FormatNumber(PaymentBinCheckpoint."Counted Amount Incl. Float")), 'A11', false, 'LEFT', true, false);
                TotalCards += PaymentBinCheckpoint."Counted Amount Incl. Float";
                TotalDifference += PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Float Amount";
            end;
        until PaymentBinCheckpoint.Next() = 0;
    end;

    local procedure PrintOtherPaymentsPart(var Printer: Codeunit "NPR RP Line Print"; WorkshiftCheckpointEntryNo: Integer)
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

    local procedure PrintItemCategoryPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        WithItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryAmount, WithoutItemCategoryQuantity : Decimal;
        WithItemCategoryPriceCheckedCounter, WithoutItemCategoryPriceCheckedCounter : Integer;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, ItemCategoryCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintItemCategories(Printer, POSWorkshiftCheckpoint, WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity, WithItemCategoryPriceCheckedCounter, WithoutItemCategoryPriceCheckedCounter);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, POSLawCategoriesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        PrintThermalLine(Printer, UncategorizedSalesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ProductsQuantityCaptionLbl, Format(Round(WithoutItemCategoryQuantity, 1, '='))), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(WithoutItemCategoryAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(WithoutItemCategoryPriceCheckedCounter)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, CategorizedSalesCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ProductsQuantityCaptionLbl, Format(Round(WithItemCategoryQuantity, 1, '='))), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(WithItemCategoryAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(WithItemCategoryPriceCheckedCounter)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure PrintItemCategories(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var WithItemCategoryAmount: Decimal; var WithoutItemCategoryAmount: Decimal; var WithItemCategoryQuantity: Decimal; var WithoutItemCategoryQuantity: Decimal; var WithItemCategoryPriceCheckedCounter: Integer; var WithoutItemCategoryPriceCheckedCounter: Integer)
    var
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        FromEntryNo: Integer;
        AlreadyProcessedItemCategories: List of [Code[20]];
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        PrintItemCategoriesBasedOnQuery(Printer, POSWorkshiftCheckpoint, POSUnit, PreviousZReportDateTime, FromEntryNo, WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity, WithItemCategoryPriceCheckedCounter, WithoutItemCategoryPriceCheckedCounter, AlreadyProcessedItemCategories);
        PrintNotProcessedItemCategories(Printer, POSWorkshiftCheckpoint, PreviousZReportDateTime, WithItemCategoryPriceCheckedCounter, AlreadyProcessedItemCategories);
    end;

    local procedure PrintItemCategoriesBasedOnQuery(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSUnit: Record "NPR POS Unit"; PreviousZReportDateTime: DateTime; FromEntryNo: Integer; var WithItemCategoryAmount: Decimal; var WithoutItemCategoryAmount: Decimal; var WithItemCategoryQuantity: Decimal; var WithoutItemCategoryQuantity: Decimal; var WithItemCategoryPriceCheckedCounter: Integer; var WithoutItemCategoryPriceCheckedCounter: Integer; var AlreadyProcessedItemCategories: List of [Code[20]])
    var
        ItemCategory: Record "Item Category";
        ItemCategoryQuery: Query "NPR NO Sales By Item Category";
        PriceCheckedCounter: Integer;
    begin
        ItemCategoryQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.");
        ItemCategoryQuery.SetFilter(EntryType, '%1|%2', ItemCategoryQuery.EntryType::"Direct Sale", ItemCategoryQuery.EntryType::"Credit Sale");
        ItemCategoryQuery.SetRange(POSUnitNo, POSUnit."No.");
        ItemCategoryQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        ItemCategoryQuery.Open();

        while ItemCategoryQuery.Read() do begin
            if ItemCategoryQuery.ItemCategoryCode = '' then begin
                WithoutItemCategoryQuantity := ItemCategoryQuery.Quantity;
                WithoutItemCategoryAmount := ItemCategoryQuery.AmountInclVATLCY;
                WithoutItemCategoryPriceCheckedCounter := NOReportStatisticsMgt.GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog('', POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime);
            end;

            if ItemCategory.Get(ItemCategoryQuery.ItemCategoryCode) then begin
                PrintThermalLine(Printer, ItemCategory.Description, 'A11', true, 'CENTER', true, false);
                PrintThermalLine(Printer, CaptionValueFormat(ProductsQuantityCaptionLbl, Format(Round(ItemCategoryQuery.Quantity, 1, '='))), 'A11', false, 'LEFT', true, false);
                PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(ItemCategoryQuery.AmountInclVATLCY)), 'A11', false, 'LEFT', true, false);
                PriceCheckedCounter := NOReportStatisticsMgt.GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog(ItemCategory.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime);
                if PriceCheckedCounter <> 0 then
                    PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(PriceCheckedCounter)), 'A11', false, 'LEFT', true, false);

                WithItemCategoryQuantity += ItemCategoryQuery.Quantity;
                WithItemCategoryAmount += ItemCategoryQuery.AmountInclVATLCY;
                WithItemCategoryPriceCheckedCounter += PriceCheckedCounter;
                AlreadyProcessedItemCategories.Add(ItemCategory.Code);
            end;
        end;

        ItemCategoryQuery.Close();
    end;

    local procedure PrintNotProcessedItemCategories(var Printer: Codeunit "NPR RP Line Print"; var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PreviousZReportDateTime: DateTime; var WithItemCategoryPriceCheckedCounter: Integer; var AlreadyProcessedItemCategories: List of [Code[20]])
    var
        ItemCategory: Record "Item Category";
        PriceCheckedCounter: Integer;
    begin
        if ItemCategory.FindSet() then
            repeat
                if not AlreadyProcessedItemCategories.Contains(ItemCategory.Code) then begin
                    PriceCheckedCounter := NOReportStatisticsMgt.GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog(ItemCategory.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime);
                    if PriceCheckedCounter <> 0 then begin
                        PrintThermalLine(Printer, ItemCategory.Description, 'A11', true, 'CENTER', true, false);
                        PrintThermalLine(Printer, CaptionValueFormat(PriceLookupQuantityCaptionLbl, Format(PriceCheckedCounter)), 'A11', false, 'LEFT', true, false);
                    end;

                    WithItemCategoryPriceCheckedCounter += PriceCheckedCounter;
                    AlreadyProcessedItemCategories.Add(ItemCategory.Code);
                end
            until ItemCategory.Next() = 0;
    end;

    local procedure PrintSalespersonPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonQuery: Query "NPR NO Group Sales by Salespr.";
        PrintGenInfo: Boolean;
        FromEntryNo: Integer;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        PrintGenInfo := not ShouldPrintGeneralInfoAsTotal(POSUnit);

        SalespersonQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.");
        SalespersonQuery.SetFilter(EntryType, '%1|%2', SalespersonQuery.EntryType::"Direct Sale", SalespersonQuery.EntryType::"Credit Sale");
        SalespersonQuery.SetRange(POSUnitNo, POSUnit."No.");
        SalespersonQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        SalespersonQuery.Open();
        while (SalespersonQuery.Read()) do
            if SalespersonPurchaser.Get(SalespersonQuery.SalespersonCode) then
                PrintSalespersonInfo(Printer, SalespersonPurchaser, POSWorkshiftCheckpoint, PrintGenInfo);
    end;

    local procedure PrintSalespersonInfo(var Printer: Codeunit "NPR RP Line Print"; SalespersonPurchaser: Record "Salesperson/Purchaser"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; PrintGenInfo: Boolean)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        Amount: Decimal;
        AmountCards, AmountOther : Decimal;
        CountCards, CountOther : Integer;
        FromEntryNo: Integer;
        Quantity: Integer;
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
        NOReportStatisticsMgt.CalcOtherPaymentsAmountAndQuantity(POSEntry, AmountOther, CountOther);

        if CountCards > 0 then begin
            PrintThermalLine(Printer, QuantityCardCaptionLbl, 'A11', false, 'LEFT', true, false);
            PrintPaymentsQuantityOrAmount(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", true, true);
        end;

        if AmountCards > 0 then begin
            PrintThermalLine(Printer, AmountCardsCaptionLbl, 'A11', false, 'LEFT', true, false);
            PrintPaymentsQuantityOrAmount(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", false, true);
        end;

        if CountOther > 0 then begin
            PrintThermalLine(Printer, QuantityOtherCaptionLbl, 'A11', false, 'LEFT', true, false);
            PrintPaymentsQuantityOrAmount(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", true, false);
        end;

        if AmountOther > 0 then begin
            PrintThermalLine(Printer, AmountOtherCaptionLbl, 'A11', false, 'LEFT', true, false);
            PrintPaymentsQuantityOrAmount(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.", false, false);
        end;
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
        PrintThermalLine(Printer, CaptionValueFormat(ZeroLinesQtyCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);
        NOReportStatisticsMgt.CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, Amount, POSAuditLog."Action Type"::DELETE_POS_SALE_LINE);
        PrintThermalLine(Printer, CaptionValueFormat(ZeroLinesAmountCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);

        if PrintGenInfo then
            PrintGeneralInfo(Printer, SalespersonPurchaser.Code, POSWorkshiftCheckpoint);
    end;

    local procedure PrintGeneralInfoPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSUnit: Record "NPR POS Unit";
        PrintGenInfo: Boolean;
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        PrintGenInfo := ShouldPrintGeneralInfoAsTotal(POSUnit);

        if PrintGenInfo then
            PrintGeneralInfo(Printer, '', POSWorkshiftCheckpoint);
    end;

    local procedure PrintMoreInfoPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
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

    local procedure PrintTotalsPart(var Printer: Codeunit "NPR RP Line Print"; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
        POSWorkshiftCheckpoint.CalcFields("FF Total Dir. Item Return(LCY)", "FF Total Dir. Item Sales (LCY)");
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalReturnAmountCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)")), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(TotalSalesNetoCaptionLbl, FormatNumber(POSWorkshiftCheckpoint."FF Total Dir. Item Sales (LCY)" - Abs(POSWorkshiftCheckpoint."FF Total Dir. Item Return(LCY)"))), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    #endregion Printing Parts of The Receipts

    #region Printer Helper Functions

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
    internal procedure PrintSalesTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Printed: Boolean;
        AmountIncludingTax, SumOfTotalAmountIncludingTax, TaxAmount, TaxBaseAmount, TaxRoundingAmount : Decimal;
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax %");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);
        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %", "Workshift Checkpoint Entry No.");
        POSWorkshTaxCheckp.SetAscending("Tax %", true);
        POSWorkshTaxCheckp.FindSet();
        repeat
            NOReportStatisticsMgt.CalcTaxAmounts(POSEntry, true, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, AmountIncludingTax);
            TaxRoundingAmount := AmountIncludingTax - (TaxBaseAmount + TaxAmount);
            SumOfTotalAmountIncludingTax += AmountIncludingTax;

            if AmountIncludingTax <> 0 then begin
                if not Printed then begin
                    PrintThermalLine(Printer, TaxCaptionLbl, 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
                    Printed := true;
                end;

                PrintTaxAmountsSection(Printer, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, TaxRoundingAmount, AmountIncludingTax);
            end;
        until POSWorkshTaxCheckp.Next() = 0;

        if Printed then begin
            PrintThermalLine(Printer, CaptionValueFormat(SumOfTotalAmountIncludingTaxCaptionLbl, FormatNumber(SumOfTotalAmountIncludingTax)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        end;
    end;

    internal procedure PrintReturnTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    var
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
        Printed: Boolean;
        AmountIncludingTax, SumOfTotalAmountIncludingTax, TaxAmount, TaxBaseAmount, TaxRoundingAmount : Decimal;
    begin
        POSWorkshTaxCheckp.SetCurrentKey("Workshift Checkpoint Entry No.", "Tax %");
        POSWorkshTaxCheckp.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);
        if POSWorkshTaxCheckp.IsEmpty() then
            exit;

        POSWorkshTaxCheckp.SetLoadFields("Tax %", "Workshift Checkpoint Entry No.");
        POSWorkshTaxCheckp.SetAscending("Tax %", true);
        POSWorkshTaxCheckp.FindSet();
        repeat
            NOReportStatisticsMgt.CalcReturnTaxAmounts(POSEntry, true, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, AmountIncludingTax);
            TaxRoundingAmount := AmountIncludingTax - (TaxBaseAmount + TaxAmount);
            SumOfTotalAmountIncludingTax += AmountIncludingTax;

            if AmountIncludingTax <> 0 then begin
                if not Printed then begin
                    PrintThermalLine(Printer, TaxOnReturnCaptionLbl, 'A11', false, 'LEFT', true, false);
                    PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
                    Printed := true;
                end;

                PrintTaxAmountsSection(Printer, POSWorkshTaxCheckp."Tax %", TaxBaseAmount, TaxAmount, TaxRoundingAmount, AmountIncludingTax);
            end;
        until POSWorkshTaxCheckp.Next() = 0;

        if Printed then begin
            PrintThermalLine(Printer, CaptionValueFormat(SumOfTotalAmountIncludingTaxCaptionLbl, FormatNumber(SumOfTotalAmountIncludingTax)), 'A11', false, 'LEFT', true, false);
            PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        end;
    end;

    local procedure PrintTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; TaxPct: Decimal; TaxBaseAmount: Decimal; TaxAmount: Decimal; TaxRoundingAmount: Decimal; AmountIncludingTax: Decimal)
    begin
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxBaseAmountCaptionLbl, TaxPct), FormatNumber(TaxBaseAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxAmountCaptionLbl, TaxPct), FormatNumber(TaxAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(TaxRoundingCaptionLbl, TaxPct), FormatNumber(TaxRoundingAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(StrSubstNo(AmountIncludingTaxCaptionLbl, TaxPct), FormatNumber(AmountIncludingTax)), 'A11', false, 'LEFT', true, false);
    end;

    local procedure PrintPaymentsQuantityOrAmount(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer; PrintQuantity: Boolean; IncludeEFTPaymentMethods: Boolean)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        IsEFTPaymentMethod: Boolean;
        Amount: Decimal;
        TotalAmount: Decimal;
        Quantity: Integer;
        PrintTxt: Text;
    begin
        PaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.", "Payment Method No.", "Payment Bin No.");
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", POSWorkshiftCheckpointEntryNo);

        if PaymentBinCheckpoint.IsEmpty() then
            exit;

        PaymentBinCheckpoint.FindSet();
        repeat
            if POSPaymentMethod.Code <> PaymentBinCheckpoint."Payment Method No." then begin
                POSPaymentMethod.Get(PaymentBinCheckpoint."Payment Method No.");
                IsEFTPaymentMethod := POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT;
                Clear(TotalAmount);
                Clear(Quantity);
            end;

            if (IncludeEFTPaymentMethods and IsEFTPaymentMethod) or (not IncludeEFTPaymentMethods and (not IsEFTPaymentMethod)) then begin
                POSEntryPaymentLine.SetLoadFields(Amount, "POS Payment Method Code");
                POSEntry.SetLoadFields("Entry No.");
                if POSEntry.FindSet() then
                    repeat
                        Clear(Amount);
                        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                        POSEntryPaymentLine.SetRange(POSEntryPaymentLine."POS Payment Method Code", POSPaymentMethod.Code);
                        if POSEntryPaymentLine.FindSet() then
                            repeat
                                Amount += POSEntryPaymentLine.Amount;
                            until POSEntryPaymentLine.Next() = 0;
                        if Amount > 0 then begin
                            TotalAmount += Amount;
                            Quantity += 1;
                        end
                    until POSEntry.Next() = 0;

                if PrintQuantity then
                    PrintTxt := Format(Quantity)
                else
                    PrintTxt := FormatNumber(TotalAmount);
                if Quantity > 0 then
                    PrintThermalLine(Printer, CaptionValueFormat(PaymentBinCheckpoint."Payment Method No.", PrintTxt), 'A11', false, 'LEFT', true, false);
            end;
        until PaymentBinCheckpoint.Next() = 0;
    end;

    local procedure PrintGeneralInfo(var Printer: Codeunit "NPR RP Line Print"; SalespersonPurchaserCode: Code[20]; POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        Amount: Decimal;
        AmountCards, AmountOther : Decimal;
        CopyTicketAmount: Decimal;
        DiscountAmount: Decimal;
        Quantity: Decimal;
        Quantity2: Decimal;
        Quantity3: Decimal;
        ReceiptCopyCounter: Integer;
        ReceiptPrintCounter: Integer;
        ReturnAmount: Decimal;
        CountCards, CountOther : Integer;
        CountReturned: Integer;
        FromEntryNo: Integer;
    begin
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, GeneralInfoCaptionLbl, 'A11', true, 'CENTER', true, false);
        PrintThermalLine(Printer, '', 'A11', true, 'CENTER', true, false);

        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        FromEntryNo := NOReportStatisticsMgt.FindFromEntryNo(POSUnit."No.", POSWorkshiftCheckpoint."Entry No.");

        NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaserCode);

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        Clear(Amount);
        Clear(Quantity);
        NOReportStatisticsMgt.CalcCardsAmountAndQuantity(POSEntry, AmountCards, CountCards);
        NOReportStatisticsMgt.CalcOtherPaymentsAmountAndQuantity(POSEntry, AmountOther, CountOther);

        NOReportStatisticsMgt.CalcReturnsAndSalesAmount(POSEntry, Amount, ReturnAmount);

        PrintThermalLine(Printer, CaptionValueFormat(BrutoSalesCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ReturnCaptionLbl, FormatNumber(ReturnAmount)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(NetoSalesCaptionLbl, FormatNumber(Amount - Abs(ReturnAmount))), 'A11', true, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
        PrintSalesTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.");
        PrintReturnTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpoint."Entry No.");

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
        Quantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);

        PrintThermalLine(Printer, CaptionValueFormat(POSOpeningQuantityCaptionLbl, Format(Quantity)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcCopyAndPrintReceiptsQuantity(POSEntry, CopyTicketAmount, ReceiptCopyCounter, ReceiptPrintCounter);

        Clear(Quantity3);
        Quantity3 := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::CANCEL_SALE_END);

        PrintThermalLine(Printer, CaptionValueFormat(NotEndedSalesQuantityCaptionLbl, Format(Quantity3)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(PrintedReceiptsQuantityCaptionLbl, Format(ReceiptPrintCounter)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(CopiedReceiptsQuantityCaptionLbl, Format(ReceiptCopyCounter)), 'A11', false, 'LEFT', true, false);

        Clear(Quantity);
        Quantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::PRICE_CHECK);

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
        PrintThermalLine(Printer, CaptionValueFormat(TotalPrepaidCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);
        PrintThermalLine(Printer, CaptionValueFormat(ProformaReceiptsAmountCaptionLbl, Format(0)), 'A11', false, 'LEFT', true, false);

        NOReportStatisticsMgt.CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaserCode, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, Amount, POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE);

        PrintThermalLine(Printer, CaptionValueFormat(TotalOnCancelledCaptionLbl, FormatNumber(Amount)), 'A11', false, 'LEFT', true, false);

        PrintThermalLine(Printer, ThermalPrintLineLbl, 'A11', true, 'LEFT', true, false);
    end;

    local procedure ShouldPrintGeneralInfoAsTotal(POSUnit: Record "NPR POS Unit"): Boolean
    var
        POSEndofDayProfile: Record "NPR POS End of Day Profile";
    begin
        if not POSEndofDayProfile.Get(POSUnit."POS End of Day Profile") then
            exit(true);

        if POSEndofDayProfile."NO General Info Output Type" = POSEndofDayProfile."NO General Info Output Type"::Total then
            exit(true);

        exit(false);
    end;

    var
        NOReportStatisticsMgt: Codeunit "NPR NO Report Statistics Mgt.";
        AmountCardsCaptionLbl: Label 'Beløp kort', Locked = true;
        AmountIncludingTaxCaptionLbl: Label '%1% Totalt', Comment = '%1 - specifies VAT %', Locked = true;
        AmountOtherCaptionLbl: Label 'Beløp annet', Locked = true;
        AppVersionCaptionLbl: Label 'App versjon', Locked = true;
        BrutoSalesCaptionLbl: Label 'Bruttoomsetning', Locked = true;
        CalculatedAmountInclFloatCaptionLbl: Label 'Beregnet beløp', Locked = true;
        CancelledQuantityCaptionLbl: Label 'Antall kansellerte ordrer', Locked = true;
        CategorizedSalesCaptionLbl: Label 'Med varekategori', Locked = true;
        CopiedReceiptsQuantityCaptionLbl: Label 'Antall kopi kvitteringer', Locked = true;
        CopyReceiptsAmountCaptionLbl: Label 'Totalt kopi kvitteringer', Locked = true;
        CorrectionsCaptionLbl: Label 'Korreksjoner pr bruker', Locked = true;
        CountedAmountInclFloatCaptionLbl: Label 'Telt beløp', Locked = true;
        DateCaptionLbl: Label 'Dato', Locked = true;
        DeliveryReceiptAmountCaptionLbl: Label 'Totalt leverings kvitteringer', Locked = true;
        DeliveryReceiptQtyCaptionLbl: Label 'Antall leverings kvitteringer', Locked = true;
        DifferenceCaptionLbl: Label 'Avvik Kontant', Locked = true;
        DifferenceCardCaptionLbl: Label 'Avvik Kort', Locked = true;
        DiscountQuantityCaptionLbl: Label 'Antall rabatterte salg', Locked = true;
        EndingFloatAmountCaptionLbl: Label 'Kontanter ved slutt', Locked = true;
        EndOfDayCaptionLbl: Label 'EOD', Locked = true;
        FirstSaleCaptionLbl: Label 'Første salg', Locked = true;
        GeneralInfoCaptionLbl: Label 'Generell info', Locked = true;
        InBankCaptionLbl: Label 'Innskudd til bank', Locked = true;
        InitialFloatAmountCaptionLbl: Label 'Kontanter ved start', Locked = true;
        IssuedVoucherCaptionLbl: Label 'Solgt gavekort', Locked = true;
        ItemCategoryCaptionLbl: Label 'Artikkelgruppe', Locked = true;
        LastSaleCaptionLbl: Label 'Siste salg', Locked = true;
        LastZReportCaptionLbl: Label 'Siste Z-rapport', Locked = true;
        LCYCaptionLbl: Label 'NOK', Locked = true;
        MoreInfoCaptionLbl: Label 'Tilleggsinfo', Locked = true;
        NetoSalesCaptionLbl: Label 'Omsetning', Locked = true;
        NotEndedSalesQuantityCaptionLbl: Label 'Antall uavsluttede handeler', Locked = true;
        POSClosedByCaptionLbl: Label 'Lukket av', Locked = true;
        POSLawCategoriesCaptionLbl: Label 'Kassalov-kategorier', Locked = true;
        POSOpenedByCaptionLbl: Label 'Åpnet av', Locked = true;
        POSOpeningQuantityCaptionLbl: Label 'Antall skuffåpninger', Locked = true;
        POSUnitNameCaptionLbl: Label 'Kassenavn', Locked = true;
        POSUnitNoCaptionLbl: Label 'Kasse-ID', Locked = true;
        PrepaidQuantityCaptionLbl: Label 'Antall forhåndsbetalinger', Locked = true;
        PriceLookupQuantityCaptionLbl: Label 'Antall prisoppslag', Locked = true;
        PrintedReceiptsQuantityCaptionLbl: Label 'Antall utskrevne kvitteringer', Locked = true;
        ProductsQuantityCaptionLbl: Label 'Antall produkter', Locked = true;
        ProformaReceiptsAmountCaptionLbl: Label 'Omsetning pro forma kvittering', Locked = true;
        ProformaReceiptsCaptionLbl: Label 'Antall utskrevne pro forma kvittering', Locked = true;
        ProvisionalReceiptAmountCaptionLbl: Label 'Totalt foreløpige kvitteringer', Locked = true;
        ProvisionalReceiptQtyCaptionLbl: Label 'Antall foreløpige kvitteringer', Locked = true;
        QuantityCardCaptionLbl: Label 'Antall kort', Locked = true;
        QuantityOtherCaptionLbl: Label 'Antall annet', Locked = true;
        RedeemedVoucherCaptionLbl: Label 'Innløst gavekort', Locked = true;
        ReturnCaptionLbl: Label 'Returer', Locked = true;
        ReturnedProductsQuantityCaptionLbl: Label 'Antall returnerte produkter', Locked = true;
        ReturnQuantityCaptionLbl: Label 'Antall returer', Locked = true;
        SalesQuantityCaptionLbl: Label 'Antall salg', Locked = true;
        SoldProductsCaptionLbl: Label 'Antall solgte produkter', Locked = true;
        StartCardCaptionLbl: Label 'Kort ved slutt', Locked = true;
        StartOtherCaptionLbl: Label 'Annet ved slutt', Locked = true;
        SumOfTotalAmountIncludingTaxCaptionLbl: Label 'Totalt', Locked = true;
        TaxAmountCaptionLbl: Label '%1% MVA', Comment = '%1 - specifies VAT %', Locked = true;
        TaxBaseAmountCaptionLbl: Label '%1% Grunnlag', Comment = '%1 - specifies VAT %', Locked = true;
        TaxCaptionLbl: Label 'MVA', Locked = true;
        TaxOnReturnCaptionLbl: Label 'MVA fra returer', Locked = true;
        TaxRoundingCaptionLbl: Label '%1% Øreavrunding', Comment = '%1 - specifies VAT %', Locked = true;
        ThermalPrintLineLbl: Label '_____________________________________________', Locked = true;
        TotalCardsCaptionLbl: Label 'Totalt kort', Locked = true;
        TotalDifferenceCaptionLbl: Label 'Avvik Totalt', Locked = true;
        TotalDiscountAmountCaptionLbl: Label 'Totalt rabatter', Locked = true;
        TotalOnCancelledCaptionLbl: Label 'Totalt fra kansellerte salg', Locked = true;
        TotalOtherCaptionLbl: Label 'Totalt annet', Locked = true;
        TotalPrepaidCaptionLbl: Label 'Totalt forhåndsbetalinger', Locked = true;
        TotalReturnAmountCaptionLbl: Label 'Totalt returnert', Locked = true;
        TotalSalesAmountCaptionLbl: Label 'Totalt salg', Locked = true;
        TotalSalesNetoCaptionLbl: Label 'Totalt netto', Locked = true;
        TrainingReceiptAmountCaptionLbl: Label 'Totalt opplærings kvitteringer', Locked = true;
        TrainingReceiptQtyCaptionLbl: Label 'Antall opplærings kvitteringer', Locked = true;
        UncategorizedSalesCaptionLbl: Label 'Uten varekategori', Locked = true;
        VATRegNumberCaptionLbl: Label 'MVA nummer', Locked = true;
        XReportEntryNoCaptionLbl: Label 'X-rapport Serienummer', Locked = true;
        ZeroLinesAmountCaptionLbl: Label 'Beløp Linjeantall redusert til 0', Locked = true;
        ZeroLinesQtyCaptionLbl: Label 'Antal Linjeantall redusert til 0', Locked = true;
        ZReportEntryNoCaptionLbl: Label 'Z-rapport Serienummer', Locked = true;
}