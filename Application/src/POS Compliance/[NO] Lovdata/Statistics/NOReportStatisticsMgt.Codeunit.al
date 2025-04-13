codeunit 6060034 "NPR NO Report Statistics Mgt."
{
    Access = Internal;

    #region Figures Calculation

    internal procedure CalcCardsAmountAndQuantity(var POSEntry: Record "NPR POS Entry"; var AmountCards: Decimal; var CountCards: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Amount: Decimal;
    begin
        Clear(AmountCards);
        Clear(CountCards);
        POSEntryPaymentLine.SetLoadFields(Amount, "POS Payment Method Code");
        POSEntry.SetLoadFields("Document No.", "POS Unit No.");
        if POSEntry.FindSet() then
            repeat
                EFTTransactionRequest.SetRange("Sales Ticket No.", POSEntry."Document No.");
                EFTTransactionRequest.SetRange("Register No.", POSEntry."POS Unit No.");
                EFTTransactionRequest.SetRange(Successful, true);
                if not EFTTransactionRequest.IsEmpty() then begin
                    Clear(Amount);
                    POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                    if POSEntryPaymentLine.FindSet() then
                        repeat
                            POSPaymentMethod.Get(POSEntryPaymentLine."POS Payment Method Code");
                            if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::EFT then
                                Amount += POSEntryPaymentLine.Amount;
                        until POSEntryPaymentLine.Next() = 0;

                    if Amount > 0 then begin
                        AmountCards += Amount;
                        CountCards += 1;
                    end;
                end;
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcOtherPaymentsAmountAndQuantity(var POSEntry: Record "NPR POS Entry"; var AmountOther: Decimal; var CountOther: Integer)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Amount: Decimal;
    begin
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                Clear(Amount);
                POSEntryPaymentLine.SetLoadFields(Amount, "POS Payment Method Code");
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if POSEntryPaymentLine.FindSet() then
                    repeat
                        POSPaymentMethod.Get(POSEntryPaymentLine."POS Payment Method Code");
                        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
                            Amount += POSEntryPaymentLine.Amount;
                    until POSEntryPaymentLine.Next() = 0;

                if Amount > 0 then begin
                    AmountOther += Amount;
                    CountOther += 1;
                end;
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcReturnsAndSalesAmount(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal; var ReturnAmount: Decimal)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        Clear(Amount);
        Clear(ReturnAmount);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSSalesLine.SetLoadFields(Quantity, "Amount Incl. VAT");
                POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSSalesLine.SetRange("Type", POSSalesLine.Type::Item);
                POSSalesLine.SetFilter("Exclude from Posting", '=%1', false);
                if (POSSalesLine.FindSet()) then
                    repeat
                        if POSSalesLine.Quantity > 0 then
                            Amount += POSSalesLine."Amount Incl. VAT"
                        else
                            ReturnAmount += POSSalesLine."Amount Incl. VAT";
                    until POSSalesLine.Next() = 0;
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcTaxAmount(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal; TaxPct: Decimal; IncludeTaxPctFilter: Boolean)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(Amount);
        POSEntryTaxLine.SetLoadFields("Tax Amount", "Tax %");
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Amount");
                Amount += POSEntryTaxLine."Tax Amount";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcTaxAmounts(var POSEntry: Record "NPR POS Entry"; IncludeTaxPctFilter: Boolean; TaxPct: Decimal; var TaxBaseAmount: Decimal; var TaxAmount: Decimal; var AmountIncludingTax: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(TaxBaseAmount);
        Clear(TaxAmount);
        Clear(AmountIncludingTax);

        POSEntryTaxLine.SetLoadFields("Tax Base Amount", "Tax Amount", "Amount Including Tax", "Tax %");
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Base Amount", "Tax Amount", "Amount Including Tax");
                TaxBaseAmount += POSEntryTaxLine."Tax Base Amount";
                TaxAmount += POSEntryTaxLine."Tax Amount";
                AmountIncludingTax += POSEntryTaxLine."Amount Including Tax";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcReturnTaxAmount(var POSEntry: Record "NPR POS Entry"; var Amount: Decimal; TaxPct: Decimal; IncludeTaxPctFilter: Boolean)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(Amount);
        POSEntryTaxLine.SetLoadFields("Tax Amount", Quantity);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSEntryTaxLine.SetFilter(Quantity, '<%1', 0);
                if IncludeTaxPctFilter then
                    POSEntryTaxLine.SetRange("Tax %", TaxPct);

                POSEntryTaxLine.CalcSums("Tax Amount");
                Amount += POSEntryTaxLine."Tax Amount";
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcReturnTaxAmounts(var POSEntry: Record "NPR POS Entry"; IncludeTaxPctFilter: Boolean; TaxPct: Decimal; var TaxBaseAmount: Decimal; var TaxAmount: Decimal; var AmountIncludingTax: Decimal)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        Clear(TaxBaseAmount);
        Clear(TaxAmount);
        Clear(AmountIncludingTax);

        POSEntryTaxLine.SetLoadFields("Tax Base Amount", "Tax Amount", "Amount Including Tax", "Tax %", Quantity);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
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

    internal procedure CalcReturnSaleDiscountQuantity(var POSEntry: Record "NPR POS Entry"; var DiscountAmount: Decimal; var CountReturned: Integer; var Quantity: Decimal; var Quantity2: Decimal; var Quantity3: Decimal)
    var
        Count: Integer;
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        Clear(DiscountAmount);
        Clear(CountReturned);
        Clear(Quantity);
        Clear(Quantity2);
        Clear(Quantity3);
        POSEntry.SetLoadFields("Entry No.");
        if POSEntry.FindSet() then
            repeat
                Clear(Count);
                POSSalesLine.SetLoadFields(Quantity, "Line Discount Amount Incl. VAT", "Discount Type");
                POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSSalesLine.SetRange("Type", POSSalesLine.Type::Item);
                POSSalesLine.SetFilter("Exclude from Posting", '=%1', false);
                if (POSSalesLine.FindSet()) then
                    repeat
                        if POSSalesLine.Quantity > 0 then
                            Quantity += POSSalesLine.Quantity
                        else begin
                            Quantity2 += POSSalesLine.Quantity;
                            Count += 1;
                        end;
                        if POSSalesLine."Discount Type" <> POSSalesLine."Discount Type"::" " then begin
                            Quantity3 += POSSalesLine.Quantity;
                            DiscountAmount += POSSalesLine."Line Discount Amount Incl. VAT";
                        end;
                    until POSSalesLine.Next() = 0;
                if Count > 0 then
                    CountReturned += 1;
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcCopyAndPrintReceiptsQuantity(var POSEntry: Record "NPR POS Entry"; var CopyTicketAmount: Decimal; var ReceiptCopyCounter: Integer; var ReceiptPrintCounter: Integer)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        Clear(CopyTicketAmount);
        Clear(ReceiptCopyCounter);
        Clear(ReceiptPrintCounter);

        POSEntry.SetLoadFields("Amount Incl. Tax");
        POSAuditLog.SetLoadFields("Acted on POS Entry No.", "Action Type");
        if POSEntry.FindSet() then
            repeat
                POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::RECEIPT_COPY);

                if not POSAuditLog.IsEmpty() then begin
                    CopyTicketAmount += POSEntry."Amount Incl. Tax";
                    ReceiptCopyCounter += POSAuditLog.Count();
                end;

                POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::RECEIPT_PRINT);
                ReceiptPrintCounter += POSAuditLog.Count();
            until POSEntry.Next() = 0;
    end;

    internal procedure CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaserCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime; var Amount: Decimal; ActionType: Option)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        ConvertVar: Decimal;
    begin
        Clear(Amount);

        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', PreviousZReportDateTime, CurrentZReportDateTime);
        POSAuditLog.SetRange("Active POS Unit No.", POSUnitNo);
        POSAuditLog.SetRange("Action Type", ActionType);
        if SalespersonPurchaserCode <> '' then
            POSAuditLog.SetRange("Active Salesperson Code", SalespersonPurchaserCode);

        POSAuditLog.SetLoadFields("Additional Information");
        if POSAuditLog.FindSet() then
            repeat
                if Evaluate(ConvertVar, POSAuditLog."Additional Information", 9) then
                    Amount += ConvertVar;
            until POSAuditLog.Next() = 0;
    end;

    internal procedure GetHowManyTimesPriceIsCheckedForItemCategoryFromPOSAuditLog(ItemCategoryCode: Code[20]; POSUnitNo: Code[10]; CurrentZReportDateTime: DateTime; PreviousZReportDateTime: DateTime) PriceCheckedCounter: Integer
    var
        POSAuditLog: Record "NPR POS Audit Log";
        Item: Record Item;
        ItemNoAsText: Text;
    begin
        POSAuditLog.SetCurrentKey("Acted on POS Unit No.", "Action Type");
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', PreviousZReportDateTime, CurrentZReportDateTime);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::PRICE_CHECK);
        POSAuditLog.SetRange("Active POS Unit No.", POSUnitNo);

        POSAuditLog.SetLoadFields("Additional Information");
        if POSAuditLog.FindSet() then
            repeat
                if POSAuditLog."Additional Information" <> '' then
                    if POSAuditLog."Additional Information".Split('|').Get(1, ItemNoAsText) then begin
                        Item.Get(ItemNoAsText);
                        if Item."Item Category Code" = ItemCategoryCode then
                            PriceCheckedCounter += 1;
                    end;
            until POSAuditLog.Next() = 0;
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
        PreviousZReport.SetFilter(Type, '=%1|=%2', PreviousZReport.Type::ZREPORT, PreviousZReport.Type::WORKSHIFT_CLOSE);
        PreviousZReport.SetFilter(Open, '=%1', false);
        PreviousZReport.SetFilter("POS Unit No.", '=%1', POSUnitNo);
        PreviousZReport.SetFilter("Entry No.", '..%1', WorkshiftEntryNo - 1);

        exit(PreviousZReport.FindLast());
    end;

    internal procedure GetBankDepositAmount(WorkshiftCheckpointEntryNo: Integer) Result: Decimal
    var
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        PaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        PaymentBinCheckpoint.SetRange("Include In Counting", PaymentBinCheckpoint."Include In Counting"::YES);

        PaymentBinCheckpoint.SetLoadFields("Bank Deposit Amount");
        if PaymentBinCheckpoint.IsEmpty() then
            exit;

        PaymentBinCheckpoint.FindSet();
        repeat
            Result += PaymentBinCheckpoint."Bank Deposit Amount";
        until PaymentBinCheckpoint.Next() = 0;
    end;

    internal procedure GetAppVersionText(var AppVerTxt: Text)
    var
        ApplicationLbl: Label '%1.%2.%3.%4 (%5)', Comment = '%1 - specifies App Major version, %2 - specifies App Minor version, %3 - specifies App Build version, %4 - specifies App Revision version, %5 - specifes current date and time', Locked = true;
        NpGuid: Label '992c2309-cca4-43cb-9e41-911f482ec088', Locked = true;
        Info: ModuleInfo;
        DatetimeTxt: Text;
    begin
        Clear(AppVerTxt);
        NavApp.GetModuleInfo(NpGuid, Info);

        DatetimeTxt := Format(CurrentDateTime(), 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2>');
        DatetimeTxt := DelChr(DatetimeTxt, '=', ':,-');

        AppVerTxt := StrSubstNo(ApplicationLbl, Info.DataVersion.Major, Info.DataVersion.Minor, Info.DataVersion.Build, Info.DataVersion.Revision, DatetimeTxt);
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

    #endregion Find, Get and Filter data
}