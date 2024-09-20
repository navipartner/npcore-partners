codeunit 6184939 "NPR RS Report Statistics Mgt."
{
    Access = Internal;

    internal procedure FindCashWorkshiftPaymentLines(WorkshiftCheckpointEntryNo: Integer; var TempPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        NPRRSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        if PaymentBinCheckpoint.FindSet() then
            repeat
                if NPRRSPOSPaymMethMapping.Get(PaymentBinCheckpoint."Payment Method No.") then
                    if NPRRSPOSPaymMethMapping."RS Payment Method" = NPRRSPOSPaymMethMapping."RS Payment Method"::Cash then begin
                        TempPaymentBinCheckpoint := PaymentBinCheckpoint;
                        TempPaymentBinCheckpoint.Insert();
                    end;
            until PaymentBinCheckpoint.Next() = 0;
    end;

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

        PreviousUnitCheckpoint.SetLoadFields("POS Entry No.", Type, "Consolidated With Entry No.");
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
                POSEntryTaxLine.SetLoadFields("Tax Base Amount", "Tax Amount", "Amount Including Tax", "Tax %");
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                TaxBaseAmount += POSEntryTaxLine."Tax Base Amount";
                TaxAmount += POSEntryTaxLine."Tax Amount";
                AmountIncludingTax += POSEntryTaxLine."Amount Including Tax";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcSalespersonAmount(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        Clear(Amount);
        POSEntry.SetLoadFields("Document No.", "POS Unit No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryPaymentLine.SetLoadFields("Amount (LCY)");
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSEntryPaymentLine.FindSet() then
                    repeat
                        Amount += POSEntryPaymentLine."Amount (LCY)";
                    until POSEntryPaymentLine.Next() = 0;
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcSalespersonAmountMonthly(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal)
    begin
        Clear(Amount);
        POSEntry.SetLoadFields("Amount Incl. Tax");
        if POSEntry.FindSet() then
            repeat
                Amount += POSEntry."Amount Incl. Tax";
            until POSEntry.Next() = 0;
    end;


    internal procedure CalcQuantitySucceedAndQuantityCancelled(var POSEntry: Record "NPR POS Entry"; var QuantitySucceed: Integer; var QuantityCancelled: Integer)
    begin
        POSEntry.SetFilter("Amount Incl. Tax", '<=0');
        QuantityCancelled := POSEntry.Count();

        POSEntry.SetFilter("Amount Incl. Tax", '>0');
        QuantitySucceed := POSEntry.Count();
    end;

    internal procedure GetBankDepositAmount(WorkshiftCheckpointEntryNo: Integer) Result: Decimal
    var
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        PaymentBinCheckpoint.SetLoadFields("Bank Deposit Amount");

        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        PaymentBinCheckpoint.SetRange("Include In Counting", PaymentBinCheckpoint."Include In Counting"::YES);

        if PaymentBinCheckpoint.IsEmpty() then
            exit;

        PaymentBinCheckpoint.FindSet();
        repeat
            Result += PaymentBinCheckpoint."Bank Deposit Amount";
        until PaymentBinCheckpoint.Next() = 0;
    end;

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

    internal procedure SetFilterOnPOSEntryMonthly(var POSEntry: Record "NPR POS Entry"; POSUnit: Record "NPR POS Unit"; StartDate: Date; EndDate: Date; SalespersonCode: Code[20])
    begin
        POSEntry.Reset();
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        if SalespersonCode <> '' then
            POSEntry.SetRange("Salesperson Code", SalespersonCode);
        POSEntry.SetFilter("Entry Date", '%1..%2', StartDate, EndDate);
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSEntry.SetFilter("POS Unit No.", '=%1', POSUnit."No.");
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
    end;
}