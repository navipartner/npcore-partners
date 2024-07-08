codeunit 6184868 "NPR SE CC Report Stat. Mgt."
{
    Access = Internal;

    #region Figures Calculation

    internal procedure CalcTaxAmounts(var POSEntry: Record "NPR POS Entry"; IncludeTaxPctFilter: Boolean; TaxPct: Decimal; var TaxBaseAmount: Decimal; var TaxAmount: Decimal; var AmountIncludingTax: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(TaxBaseAmount);
        Clear(TaxAmount);
        Clear(AmountIncludingTax);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetLoadFields("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                TaxBaseAmount += POSEntryTaxLine."Tax Base Amount";
                TaxAmount += POSEntryTaxLine."Tax Amount";
                AmountIncludingTax += POSEntryTaxLine."Amount Including Tax";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcReturnTaxAmounts(var POSEntry: Record "NPR POS Entry"; IncludeTaxPctFilter: Boolean; TaxPct: Decimal; var TaxBaseAmount: Decimal; var TaxAmount: Decimal; var AmountIncludingTax: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(TaxBaseAmount);
        Clear(TaxAmount);
        Clear(AmountIncludingTax);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetLoadFields("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryTaxLine.SetFilter(Quantity, '<%1', 0);
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                TaxBaseAmount += POSEntryTaxLine."Tax Base Amount";
                TaxAmount += POSEntryTaxLine."Tax Amount";
                AmountIncludingTax += POSEntryTaxLine."Amount Including Tax";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcCopyAndPrintReceiptsQuantity(var POSEntry: Record "NPR POS Entry"; var CopyTicketAmount: Decimal; var Quantity: Integer)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        Clear(CopyTicketAmount);
        Clear(Quantity);

        POSEntry.SetLoadFields("Amount Incl. Tax", "Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::RECEIPT_COPY);

                if not POSAuditLog.IsEmpty() then begin
                    CopyTicketAmount += POSEntry."Amount Incl. Tax";
                    Quantity += POSAuditLog.Count();
                end;
            until POSEntry.Next() = 0;
    end;

    internal procedure GetPOSAuditLogCount(SalespersonPurchaserCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime; ActionType: Option): Integer
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', PreviousZReportDateTime, CurrentZReportDateTime);
        if SalespersonPurchaserCode <> '' then
            POSAuditLog.SetRange("Active Salesperson Code", SalespersonPurchaserCode);
        POSAuditLog.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", ActionType);

        exit(POSAuditLog.Count())
    end;

    #endregion Figures Calculation

    internal procedure SetFilterOnPOSEntry(var POSEntry: Record "NPR POS Entry"; POSUnit: Record "NPR POS Unit"; FromEntryNo: Integer; ToPOSEntryNo: Integer; SalespersonCode: Code[20])
    begin
        POSEntry.Reset();
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        if SalespersonCode <> '' then
            POSEntry.SetRange("Salesperson Code", SalespersonCode);
        POSEntry.SetFilter("Entry No.", '%1..%2', FromEntryNo, ToPOSEntryNo);
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
    end;

    internal procedure FindCashBalacingLine(WorkshiftCheckpointEntryNo: Integer; var PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp."): Boolean
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        PaymentBinCheckpoint.SetRange("Payment Method No.", 'K');

        exit(PaymentBinCheckpoint.FindFirst());
    end;

    #region Find, Get and Filter data

    internal procedure FindPreviousZReport(var PreviousZReport: Record "NPR POS Workshift Checkpoint"; POSUnitNo: Code[10]; WorkshiftEntryNo: Integer): Boolean
    begin
        PreviousZReport.Reset();
        PreviousZReport.SetCurrentKey("POS Unit No.", Open, "Type");
        PreviousZReport.SetFilter(Type, '=%1|=%2', PreviousZReport.Type::ZREPORT, PreviousZReport.Type::WORKSHIFT_CLOSE);
        PreviousZReport.SetFilter(Open, '=%1', false);
        PreviousZReport.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        PreviousZReport.SetFilter("Entry No.", '..%1', WorkshiftEntryNo - 1);

        exit(PreviousZReport.FindLast());
    end;

    internal procedure FindFromEntryNo(POSUnitNo: Code[10]; WorkshiftEntryNo: Integer): Integer
    var
        PreviousUnitCheckpoint: Record "NPR POS Workshift Checkpoint";
        FromEntryNo: Integer;
    begin
        FromEntryNo := 1;
        PreviousUnitCheckpoint.SetCurrentKey("POS Unit No.", Open, "Type");
        PreviousUnitCheckpoint.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        PreviousUnitCheckpoint.SetFilter(Open, '=%1', false);
        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::ZREPORT);
        PreviousUnitCheckpoint.SetFilter("Entry No.", '..%1', WorkshiftEntryNo - 1);
        if PreviousUnitCheckpoint.FindLast() then
            FromEntryNo := PreviousUnitCheckpoint."POS Entry No.";

        PreviousUnitCheckpoint.SetFilter(Type, '=%1', PreviousUnitCheckpoint.Type::WORKSHIFT_CLOSE);
        PreviousUnitCheckpoint.SetFilter("Entry No.", '%1..', PreviousUnitCheckpoint."Entry No.");

        if not PreviousUnitCheckpoint.FindLast() then
            exit(FromEntryNo);

        PreviousUnitCheckpoint.Get(PreviousUnitCheckpoint."Consolidated With Entry No.");
        FromEntryNo := PreviousUnitCheckpoint."POS Entry No.";

        exit(FromEntryNo);
    end;

    #endregion Find, Get and Filter data
}