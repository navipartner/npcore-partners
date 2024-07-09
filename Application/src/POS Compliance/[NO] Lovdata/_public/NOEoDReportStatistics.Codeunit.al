codeunit 6184788 "NPR NO EoD Report Statistics"
{
    SingleInstance = true;
    Access = Public;

    var
        POSAuditLog: Record "NPR POS Audit Log";
        NOFiscalThermalPrint: Codeunit "NPR NO Fiscal Thermal Print";
        EoDReportStatistics: Codeunit "NPR NO Report Statistics Mgt.";
        NOAuditMgt: Codeunit "NPR NO Audit Mgt.";

    procedure IsNOAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    begin
        exit(NOAuditMgt.IsNOAuditEnabled(POSAuditProfileCode));
    end;

    procedure FindPreviousZReport(var PreviousZReport: Record "NPR POS Workshift Checkpoint"; POSUnitNo: Code[10]; WorkshiftEntryNo: Integer): Boolean
    begin
        exit(EoDReportStatistics.FindPreviousZReport(PreviousZReport, POSUnitNo, WorkshiftEntryNo));
    end;

    procedure FindFromEntryNo(POSUnitNo: Code[10]; WorkshiftEntryNo: Integer): Integer
    begin
        exit(EoDReportStatistics.FindFromEntryNo(POSUnitNo, WorkshiftEntryNo));
    end;

    procedure SetFilterOnPOSEntry(var POSEntry: Record "NPR POS Entry"; POSUnit: Record "NPR POS Unit"; FromEntryNo: Integer; ToPOSEntryNo: Integer; SalespersonCode: Code[20])
    begin
        EoDReportStatistics.SetFilterOnPOSEntry(POSEntry, POSUnit, FromEntryNo, ToPOSEntryNo, SalespersonCode);
    end;

    procedure CalcOtherPaymentsAmountAndQuantity(var POSEntry: Record "NPR POS Entry"; var AmountOther: Decimal; var CountOther: Integer)
    begin
        EoDReportStatistics.CalcOtherPaymentsAmountAndQuantity(POSEntry, AmountOther, CountOther);
    end;

    procedure CalcReturnsAndSalesAmount(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal; var ReturnAmount: Decimal)
    begin
        EoDReportStatistics.CalcReturnsAndSalesAmount(POSEntry, Amount, ReturnAmount);
    end;

    procedure CalcReturnSaleDiscountQuantity(var POSEntry: Record "NPR POS Entry"; var DiscountAmount: Decimal; var CountReturned: Integer; var Quantity: Decimal; var Quantity2: Decimal; var Quantity3: Decimal)
    begin
        EoDReportStatistics.CalcReturnSaleDiscountQuantity(POSEntry, DiscountAmount, CountReturned, Quantity, Quantity2, Quantity3);
    end;

    procedure PrintSalesTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    begin
        NOFiscalThermalPrint.PrintSalesTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpointEntryNo)
    end;

    procedure PrintReturnTaxAmountsSection(var Printer: Codeunit "NPR RP Line Print"; var POSEntry: Record "NPR POS Entry"; POSWorkshiftCheckpointEntryNo: Integer)
    begin
        NOFiscalThermalPrint.PrintReturnTaxAmountsSection(Printer, POSEntry, POSWorkshiftCheckpointEntryNo);
    end;

    procedure CalcCardsAmountAndQuantity(var POSEntry: Record "NPR POS Entry"; var AmountCards: Decimal; var CountCards: Integer)
    begin
        EoDReportStatistics.CalcCardsAmountAndQuantity(POSEntry, AmountCards, CountCards);
    end;

    procedure CalcCopyAndPrintReceiptsQuantity(var POSEntry: Record "NPR POS Entry"; var CopyTicketAmount: Decimal; var ReceiptCopyCounter: Integer; var ReceiptPrintCounter: Integer)
    begin
        EoDReportStatistics.CalcCopyAndPrintReceiptsQuantity(POSEntry, CopyTicketAmount, ReceiptCopyCounter, ReceiptPrintCounter);
    end;

    procedure CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaserCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime; var Amount: Decimal; ActionType: Option)
    begin
        EoDReportStatistics.CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaserCode, POSUnitNo, CurrentZReportDateTime, PreviousZReportDateTime, Amount, ActionType);
    end;

    procedure GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog(ItemCategoryCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime) PriceCheckedCounter: Integer
    begin
        exit(EoDReportStatistics.GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog(ItemCategoryCode, POSUnitNo, CurrentZReportDateTime, PreviousZReportDateTime));
    end;

    procedure GetBankDepositAmount(WorkshiftCheckpointEntryNo: Integer) Result: Decimal
    begin
        exit(EoDReportStatistics.GetBankDepositAmount(WorkshiftCheckpointEntryNo));
    end;

    procedure GetPOSAuditLogCount(SalespersonPurchaserCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime; ActionType: Option): Integer
    begin
        exit(EoDReportStatistics.GetPOSAuditLogCount(SalespersonPurchaserCode, POSUnitNo, CurrentZReportDateTime, PreviousZReportDateTime, ActionType));
    end;

    procedure LoginDateAndSalesPersonName(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; FirstLoginDatetime: DateTime; var PrintTxt2: Text; var PrintTxt3: Text)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";

    begin
        POSAuditLog.SetRange(SystemCreatedAt, FirstLoginDatetime, POSWorkshiftCheckpoint.SystemCreatedAt);
        POSAuditLog.SetRange("Active POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_IN);
        if POSAuditLog.FindFirst() then begin
            PrintTxt2 := Format(POSAuditLog.SystemCreatedAt);
            if SalespersonPurchaser.Get(POSAuditLog."Active Salesperson Code") then
                PrintTxt3 := SalespersonPurchaser.Name;
        end;
    end;

    [Obsolete('This procedure is not used anymore.', '2024-07-28')]
    procedure GetPOSAuditLogSystemCreatedAt(POSUnitNo: Code[20]; ActionType: Option): DateTime
    begin
        POSAuditLog.SetLoadFields(SystemCreatedAt);
        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", ActionType);
        if POSAuditLog.FindFirst() then
            exit(POSAuditLog.SystemCreatedAt);
        exit(0DT);
    end;

    [Obsolete('This procedure is not used anymore.', '2024-07-28')]
    procedure GetPOSAuditLOGActiveSalespersonCode(POSUnitNo: Code[20]; ActionType: Option): Code[20]
    begin
        POSAuditLog.SetLoadFields("Active Salesperson Code");
        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", ActionType);
        if POSAuditLog.FindFirst() then
            exit(POSAuditLog."Active Salesperson Code");
        exit('');
    end;

}
