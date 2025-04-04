﻿codeunit 6150707 "NPR POS Payment Line"
{
    Access = Public;

    var
        Rec: Record "NPR POS Sale Line";
        Sale: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        RegisterNo: Code[20];
        SalesTicketNo: Code[20];
        DeleteNotAllowed: Label 'Payments approved by a 3-party must be cancelled, not deleted.';
        Initialized: Boolean;
        ErrVATCalcNotSupportInPOS: Label '%1 %2 not supported in POS';
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        InvalidAmount: Label 'The payment amount %1 cannot be accepted because it does not meet the rounding precision requirements ("%2") set for payment type %3.', Comment = '%1 - payment amount, %2 - rounding precision, %3 - payment type description';

    procedure Init(RegisterNoIn: Code[20]; SalesTicketNoIn: Code[20]; SaleIn: Codeunit "NPR POS Sale"; SetupIn: Codeunit "NPR POS Setup"; FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        Clear(Rec);
        Rec.FilterGroup(2);
        Rec.SetRange("Line Type", Rec."Line Type"::"POS Payment");
        Rec.SetRange("Register No.", RegisterNoIn);
        Rec.SetRange("Sales Ticket No.", SalesTicketNoIn);
        Rec.FilterGroup(0);

        Sale.Get(RegisterNoIn, SalesTicketNoIn);

        POSSale := SaleIn;
        Setup := SetupIn;
        _FrontEnd := FrontEndIn;

        RegisterNo := RegisterNoIn;
        SalesTicketNo := SalesTicketNoIn;

        Initialized := true;
    end;

    internal procedure ToDataset(CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Mgmt. Internal";
        SaleAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        Subtotal: Decimal;
    begin
        DataMgt.RecordToDataSet(Rec, CurrDataSet, DataSource, POSSession, FrontEnd);

        CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        CurrDataSet.AddTotal('SaleAmount', SaleAmount);
        CurrDataSet.AddTotal('PaidAmount', PaidAmount);
        CurrDataSet.AddTotal('ReturnAmount', ReturnAmount);
        CurrDataSet.AddTotal('Subtotal', Subtotal);
    end;

    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find());
    end;

    internal procedure GetPosition(UseNames: Boolean): Text
    begin
        exit(Rec.GetPosition(UseNames));
    end;

    procedure RefreshCurrent(): Boolean
    begin
        exit(Rec.Find());
    end;

    procedure SetFirst()
    begin
        Rec.FindFirst();
    end;

    procedure SetLast()
    begin
        Rec.FindLast();
    end;

    procedure IsEmpty(): Boolean
    begin
        if not Initialized then
            exit(true);
        exit(Rec.IsEmpty());
    end;

    procedure GetCurrentPaymentLine(var PaymentLinePOS: Record "NPR POS Sale Line")
    begin
        RefreshCurrent();

        PaymentLinePOS.Copy(Rec);
    end;

    procedure CalculateBalance(POSPaymentMethod: Record "NPR POS Payment Method"; var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        if not Initialized then
            exit;

        if not POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethod.Code) then
            CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal)
        else
            if IsDocumentPaymentReservation() then
                CalculateBalanceFromCombinedEntries(POSPaymentMethod.Code, SaleAmount, PaidAmount, ReturnAmount, Subtotal)
            else
                CalculateBalanceV2(POSPaymentMethod.Code, SaleAmount, PaidAmount, ReturnAmount, Subtotal);

    end;

    //ReturnAmount is LEGACY. Cannot calculate true return amount without knowing payment type that is being paid with, to adjust roundings. If you use this incorrectly you will not have equal transactions in both directions (positive/negative) for nearest rounding.
    //Look at how the payment action calculates remaining amount to pay instead of using the parameter in new code.
    procedure CalculateBalance(var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        RoundingAmount: Decimal;
        ReturnRounding: Decimal;
    begin
        if not Initialized then
            exit;

        InitCalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        SaleLinePOS.SetRange("Register No.", RegisterNo);
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::Comment);
        if SaleLinePOS.FindSet() then
            repeat
                case true of
                    (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::"Customer Deposit", SaleLinePOS."Line Type"::"Issue Voucher", SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Item Category", SaleLinePOS."Line Type"::"BOM List"]):
                        SaleAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"GL Payment"):
                        SaleAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Rounding):
                        RoundingAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"POS Payment"):
                        PaidAmount += SaleLinePOS."Amount Including VAT";
                end;
            until SaleLinePOS.Next() = 0;


        Subtotal := SaleAmount - PaidAmount - RoundingAmount;
        ReturnAmount := SaleAmount - PaidAmount - RoundingAmount - ReturnRounding;

        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision() > 0) then
            ReturnAmount := Round(ReturnAmount, Setup.AmountRoundingPrecision(), Setup.AmountRoundingDirection());
    end;

    [Obsolete('Not used. Use function CalculateBalanceV2 instead', '2024-08-11')]
    local procedure CalculateBalance(POSPaymentMethodCode: Code[20]; var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        POSSaleLine: Record "NPR POS Sale Line";
        TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine : Record "NPR POS Sale Line" temporary;
    begin
        if not Initialized then
            exit;

        InitCalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSSaleLine.SetRange("Register No.", RegisterNo);
        POSSaleLine.SetRange("Sales Ticket No.", SalesTicketNo);
        PaidAmount := CalculateAlreadyPaidAmountWithThisPOSPaymentMethod(POSSaleLine, POSPaymentMethodCode);

        FindOtherPaymentPOSSaleLines(POSSaleLine, TempOtherPaymentPOSSaleLine, POSPaymentMethodCode);
        FindSalePOSSalesLines(POSSaleLine, TempSalePOSSaleLine);

        DecreaseOnlySalesPOSSaleLinesThatCanOnlyBePaidWithOtherPOSPaymentMethods(TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine, POSPaymentMethodCode);
        DecreaseSalesPOSSaleLinesThatCanBePaidWithOtherPOSPaymentMethods(TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine);
        SaleAmount := CalculateSaleAmountWithThisPOSPaymentMethod(TempSalePOSSaleLine, POSPaymentMethodCode);

        Subtotal := SaleAmount - PaidAmount;
        ReturnAmount := SaleAmount - PaidAmount;

        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision() > 0) then
            ReturnAmount := Round(ReturnAmount, Setup.AmountRoundingPrecision(), Setup.AmountRoundingDirection());
    end;

    local procedure CalculateBalanceV2(POSPaymentMethodCode: Code[10]; var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        POSSaleLine: Record "NPR POS Sale Line";
        TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine : Record "NPR POS Sale Line" temporary;
        TotalPaidAmount: Decimal;
        TotalSalesAmount: Decimal;
        TotalSubtotal: Decimal;
    begin
        if not Initialized then
            exit;

        InitCalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        PaidAmount := CalculateAlreadyPaidAmountWithThisPOSPaymentMethodV2(POSPaymentMethodCode, RegisterNo, SalesTicketNo);
        FindOtherPaymentPOSSaleLinesV2(SalesTicketNo, RegisterNo, TempOtherPaymentPOSSaleLine, POSPaymentMethodCode);

        POSSaleLine.SetRange("Register No.", RegisterNo);
        POSSaleLine.SetRange("Sales Ticket No.", SalesTicketNo);
        FindSalePOSSalesLines(POSSaleLine, TempSalePOSSaleLine);

        DecreaseOnlySalesPOSSaleLinesThatCanOnlyBePaidWithOtherPOSPaymentMethods(TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine, POSPaymentMethodCode);
        DecreaseSalesPOSSaleLinesThatCanBePaidWithOtherPOSPaymentMethods(TempSalePOSSaleLine, TempOtherPaymentPOSSaleLine);
        SaleAmount := CalculateSaleAmountWithThisPOSPaymentMethod(TempSalePOSSaleLine, POSPaymentMethodCode);

        TotalPaidAmount := CalcTotalPaidAmount(RegisterNo, SalesTicketNo);
        TotalSalesAmount := CalcTotalSalesAmount(RegisterNo, SalesTicketNo);
        TotalSubtotal := TotalSalesAmount - TotalPaidAmount;

        Subtotal := SaleAmount - PaidAmount;
        if Subtotal > TotalSubtotal then begin
            Subtotal := TotalSubtotal;
            SaleAmount := TotalSalesAmount;
            PaidAmount := TotalPaidAmount;
        end;
        ReturnAmount := SaleAmount - PaidAmount;

        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision() > 0) then
            ReturnAmount := Round(ReturnAmount, Setup.AmountRoundingPrecision(), Setup.AmountRoundingDirection());
    end;

    local procedure InitCalculateBalance(var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    begin
        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;
    end;

    [Obsolete('Replaced by CalculateAlreadyPaidAmountWithThisPOSPaymentMethodV2.', '2024-10-13')]
    local procedure CalculateAlreadyPaidAmountWithThisPOSPaymentMethod(var POSSaleLine: Record "NPR POS Sale Line"; POSPaymentMethodCode: Code[20]): Decimal
    begin
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.SetRange("No.", POSPaymentMethodCode);
        POSSaleLine.CalcSums("Amount Including VAT");
        exit(POSSaleLine."Amount Including VAT");
    end;

    local procedure CalculateAlreadyPaidAmountWithThisPOSPaymentMethodV2(POSPaymentMethodCode: Code[10]; CurrRegisterNo: Code[20]; CurrSalesTicketNo: Code[20]) PaidAmount: Decimal
    var
        CurrSaleLinePOS: Record "NPR POS Sale Line";
        CurrVoucherSalesLine: Record "NPR NpRv Sales Line";
        RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempRelatedPOSSaleLineProcessed: Record "NPR POS Sale Line" temporary;
        NPRPOSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        POSPaymentMethod.Get(POSPaymentMethodCode);
        if (POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::VOUCHER) or
           (not NPRPOSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethodCode))
        then begin
            CurrSaleLinePOS.Reset();
            CurrSaleLinePOS.SetRange("Register No.", CurrRegisterNo);
            CurrSaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
            CurrSaleLinePOS.SetRange("Line Type", CurrSaleLinePOS."Line Type"::"POS Payment");
            CurrSaleLinePOS.SetRange("No.", POSPaymentMethodCode);
            CurrSaleLinePOS.CalcSums("Amount Including VAT");
            PaidAmount := CurrSaleLinePOS."Amount Including VAT";
            exit;
        end;

        CurrSaleLinePOS.Reset();
        CurrSaleLinePOS.SetRange("Register No.", CurrRegisterNo);
        CurrSaleLinePOS.SetRange("Sales Ticket No.", CurrSalesTicketNo);
        CurrSaleLinePOS.SetRange("Line Type", CurrSaleLinePOS."Line Type"::"POS Payment");
        CurrSaleLinePOS.SetRange("No.", POSPaymentMethodCode);
        CurrSaleLinePOS.SetLoadFields("Register No.", "Sales Ticket No.", "Line Type", "No.", SystemId, "Amount Including VAT");
        if not CurrSaleLinePOS.FindSet() then
            exit;

        repeat
            if not TempRelatedPOSSaleLineProcessed.Get(CurrSaleLinePOS.RecordId) then begin
                PaidAmount += CurrSaleLinePOS."Amount Including VAT";
                CurrVoucherSalesLine.Reset();
                CurrVoucherSalesLine.SetCurrentKey("Retail ID", "Document Source", Type);
                CurrVoucherSalesLine.SetRange("Retail ID", CurrSaleLinePOS.SystemId);
                CurrVoucherSalesLine.SetLoadFields("Id", "Retail ID", "Parent Id");
                if CurrVoucherSalesLine.FindFirst() then begin
                    RelatedVoucherSalesLine.SetLoadFields(Id, "Retail ID");
                    if RelatedVoucherSalesLine.Get(CurrVoucherSalesLine."Parent Id") then
                        ProcessRelatedVoucherSalesLineWhenCalculatingAlreadyPaidAmounts(RelatedVoucherSalesLine, PaidAmount, TempRelatedPOSSaleLineProcessed);

                    RelatedVoucherSalesLine.Reset();
                    RelatedVoucherSalesLine.SetLoadFields("Parent Id", "Retail ID");
                    RelatedVoucherSalesLine.SetRange("Parent Id", CurrVoucherSalesLine.Id);
                    if RelatedVoucherSalesLine.FindFirst() then
                        ProcessRelatedVoucherSalesLineWhenCalculatingAlreadyPaidAmounts(RelatedVoucherSalesLine, PaidAmount, TempRelatedPOSSaleLineProcessed);
                end;
            end;
        until CurrSaleLinePOS.Next() = 0;

    end;

    local procedure ProcessRelatedVoucherSalesLineWhenCalculatingAlreadyPaidAmounts(RelatedVoucherSalesLine: Record "NPR NpRv Sales Line"; var PaidAmount: Decimal; var TempRelatedPOSSaleLineProcessed: Record "NPR POS Sale Line" temporary)
    var
        RelatedSaleLinePOS: Record "NPR POS Sale Line";
        TempRelatedPOSSaleLineProcessedErrorLbl: Label 'Parameter TempRelatedPOSSaleLineProcessed must be temporary. This is a programming bug';
    begin
        if not TempRelatedPOSSaleLineProcessed.IsTemporary then
            Error(TempRelatedPOSSaleLineProcessedErrorLbl);

        RelatedSaleLinePOS.SetLoadFields("Amount Including VAT");
        if not RelatedSaleLinePOS.GetBySystemId(RelatedVoucherSalesLine."Retail ID") then
            exit;
        PaidAmount += RelatedSaleLinePOS."Amount Including VAT";
        if TempRelatedPOSSaleLineProcessed.Get(RelatedSaleLinePOS.RecordId) then
            exit;

        TempRelatedPOSSaleLineProcessed.Init();
        TempRelatedPOSSaleLineProcessed := RelatedSaleLinePOS;
        TempRelatedPOSSaleLineProcessed.Insert();
    end;

    local procedure CalcTotalPaidAmount(CurrRegisterNo: Code[20]; CurrSalesTicketNo: Code[20]) TotalPaidAmount: Decimal;
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.Reset();
        POSSaleLine.SetRange("Register No.", CurrRegisterNo);
        POSSaleLine.SetRange("Sales Ticket No.", CurrSalesTicketNo);
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.CalcSums("Amount Including VAT");
        TotalPaidAmount := POSSaleLine."Amount Including VAT";
    end;

    local procedure CalcTotalSalesAmount(CurrRegisterNo: Code[20]; CurrSalesTicketNo: Code[20]) TotalPaidAmount: Decimal;
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.Reset();
        POSSaleLine.SetRange("Register No.", CurrRegisterNo);
        POSSaleLine.SetRange("Sales Ticket No.", CurrSalesTicketNo);
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"Item");
        POSSaleLine.CalcSums("Amount Including VAT");
        TotalPaidAmount := POSSaleLine."Amount Including VAT";
    end;

    [Obsolete('Not used. Use function FindOtherPaymentPOSSaleLinesV2 instead', '2024-10-13')]
    local procedure FindOtherPaymentPOSSaleLines(var POSSaleLine: Record "NPR POS Sale Line"; var TempOtherPaymentPOSSaleLine: Record "NPR POS Sale Line" temporary; POSPaymentMethodCode: Code[20])
    begin
        POSSaleLine.SetFilter("No.", '<>%1', POSPaymentMethodCode);
        if POSSaleLine.FindSet() then
            repeat
                TempOtherPaymentPOSSaleLine := POSSaleLine;
                TempOtherPaymentPOSSaleLine.Insert();
            until POSSaleLine.Next() = 0;
    end;

    local procedure FindOtherPaymentPOSSaleLinesV2(CurrSalesTicketNo: Code[20]; CurrRegisterNo: Code[20]; var TempOtherPaymentPOSSaleLine: Record "NPR POS Sale Line" temporary; POSPaymentMethodCode: Code[10])
    var
        CurrSaleLinePOS: Record "NPR POS Sale Line";
        TempCurrSaleLinePOS: Record "NPR POS Sale Line" temporary;
        CurrVoucherSalesLine: Record "NPR NpRv Sales Line";
        RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
        TempRelatedProcessedSalesLinePOS: Record "NPR POS Sale Line" temporary;
        SkipLine: Boolean;
        TempOtherPaymentPOSSaleLineErrorLbl: Label 'Parameter TempOtherPaymentPOSSaleLine must be temporary. This is a programming error.';
    begin
        if not TempOtherPaymentPOSSaleLine.IsTemporary then
            Error(TempOtherPaymentPOSSaleLineErrorLbl);

        TempOtherPaymentPOSSaleLine.Reset();
        if not TempOtherPaymentPOSSaleLine.IsEmpty then
            TempOtherPaymentPOSSaleLine.DeleteAll();

        CurrSaleLinePOS.Reset();
        CurrSaleLinePOS.SetRange("Sales Ticket No.", CurrSalesTicketNo);
        CurrSaleLinePOS.SetRange("Register No.", CurrRegisterNo);
        CurrSaleLinePOS.SetFilter("No.", '<>%1', POSPaymentMethodCode);
        CurrSaleLinePOS.SetRange("Line Type", CurrSaleLinePOS."Line Type"::"POS Payment");
        if not CurrSaleLinePOS.FindSet() then
            exit;

        repeat
            if not TempRelatedProcessedSalesLinePOS.Get(CurrSaleLinePOS.RecordId) then begin
                SkipLine := false;
                TempCurrSaleLinePOS := CurrSaleLinePOS;

                CurrVoucherSalesLine.Reset();
                CurrVoucherSalesLine.SetCurrentKey("Retail ID", "Document Source", Type);
                CurrVoucherSalesLine.SetRange("Retail ID", TempCurrSaleLinePOS.SystemId);
                if CurrVoucherSalesLine.FindFirst() then begin
                    if RelatedVoucherSalesLine.Get(CurrVoucherSalesLine."Parent Id") then
                        ProcessRelatedSalesLinePOSWhenFindingOtherPaymentMethods(TempCurrSaleLinePOS, RelatedVoucherSalesLine, POSPaymentMethodCode, SkipLine, TempRelatedProcessedSalesLinePOS);

                    RelatedVoucherSalesLine.Reset();
                    RelatedVoucherSalesLine.SetRange("Parent Id", CurrVoucherSalesLine.Id);
                    RelatedVoucherSalesLine.SetLoadFields("Retail ID");
                    if RelatedVoucherSalesLine.FindFirst() then
                        ProcessRelatedSalesLinePOSWhenFindingOtherPaymentMethods(TempCurrSaleLinePOS, RelatedVoucherSalesLine, POSPaymentMethodCode, SkipLine, TempRelatedProcessedSalesLinePOS);

                end;
                if not SkipLine then begin
                    TempOtherPaymentPOSSaleLine := TempCurrSaleLinePOS;
                    TempOtherPaymentPOSSaleLine.Insert();
                end;
            end;
        until CurrSaleLinePOS.Next() = 0;
    end;

    local procedure ProcessRelatedSalesLinePOSWhenFindingOtherPaymentMethods(var CurrentSalesLinePOS: Record "NPR POS Sale Line"; RelatedVoucherSalesLine: Record "NPR NpRv Sales Line"; POSPaymentMethodCode: Code[10]; var SkipLine: boolean; var TempRelatedProcessedSalesLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempRelatedProcessedSalesLinePOSErrorLbl: Label 'Parameter TempRelatedProcessedSalesLinePOS must be temporary. This is a programming error.';
        RelatedSaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not TempRelatedProcessedSalesLinePOS.IsTemporary then
            Error(TempRelatedProcessedSalesLinePOSErrorLbl);

        RelatedSaleLinePOS.SetLoadFields("No.");
        if not RelatedSaleLinePOS.GetBySystemId(RelatedVoucherSalesLine."Retail ID") then
            exit;

        SkipLine := SkipLine or (RelatedSaleLinePOS."No." = POSPaymentMethodCode);
        if SkipLine then
            exit;

        CurrentSalesLinePOS."Amount Including VAT" += RelatedSaleLinePOS."Amount Including VAT";
        if TempRelatedProcessedSalesLinePOS.Get(RelatedSaleLinePOS.RecordId) then
            exit;

        TempRelatedProcessedSalesLinePOS := RelatedSaleLinePOS;
        TempRelatedProcessedSalesLinePOS.Insert()
    end;

    local procedure FindSalePOSSalesLines(var POSSaleLine: Record "NPR POS Sale Line"; var TempSalePOSSaleLine: Record "NPR POS Sale Line" temporary)
    begin
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange("No.");
        if POSSaleLine.FindSet() then
            repeat
                TempSalePOSSaleLine := POSSaleLine;
                TempSalePOSSaleLine.Insert();
            until POSSaleLine.Next() = 0;
    end;

    local procedure DecreaseOnlySalesPOSSaleLinesThatCanOnlyBePaidWithOtherPOSPaymentMethods(var TempSalePOSSaleLine: Record "NPR POS Sale Line" temporary; var TempOtherPaymentPOSSaleLine: Record "NPR POS Sale Line" temporary; POSPaymentMethodCode: Code[20])
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        TempOtherPaymentPOSSaleLine.Reset();
        if TempOtherPaymentPOSSaleLine.FindSet() then
            repeat
                TempSalePOSSaleLine.Reset();
                if TempSalePOSSaleLine.FindSet() then
                    repeat
                        if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(TempOtherPaymentPOSSaleLine."No.", TempSalePOSSaleLine) then
                            if not POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(POSPaymentMethodCode, TempSalePOSSaleLine) then
                                if TempOtherPaymentPOSSaleLine."Amount Including VAT" >= TempSalePOSSaleLine."Amount Including VAT" then begin
                                    TempOtherPaymentPOSSaleLine."Amount Including VAT" -= TempSalePOSSaleLine."Amount Including VAT";
                                    TempOtherPaymentPOSSaleLine.Modify();
                                    TempSalePOSSaleLine."Amount Including VAT" := 0;
                                    TempSalePOSSaleLine.Modify();
                                end else begin
                                    TempSalePOSSaleLine."Amount Including VAT" -= TempOtherPaymentPOSSaleLine."Amount Including VAT";
                                    TempSalePOSSaleLine.Modify();
                                    TempOtherPaymentPOSSaleLine."Amount Including VAT" := 0;
                                    TempOtherPaymentPOSSaleLine.Modify();
                                end;
                    until (TempSalePOSSaleLine.Next() = 0) or (TempOtherPaymentPOSSaleLine."Amount Including VAT" = 0);

                TempSalePOSSaleLine.Reset();
                TempSalePOSSaleLine.SetRange("Amount Including VAT", 0);
                TempSalePOSSaleLine.DeleteAll();
            until TempOtherPaymentPOSSaleLine.Next() = 0;

        TempOtherPaymentPOSSaleLine.Reset();
        TempOtherPaymentPOSSaleLine.SetRange("Amount Including VAT", 0);
        TempOtherPaymentPOSSaleLine.DeleteAll();
    end;

    local procedure DecreaseSalesPOSSaleLinesThatCanBePaidWithOtherPOSPaymentMethods(var TempSalePOSSaleLine: Record "NPR POS Sale Line" temporary; var TempOtherPaymentPOSSaleLine: Record "NPR POS Sale Line" temporary)
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        TempOtherPaymentPOSSaleLine.Reset();
        if TempOtherPaymentPOSSaleLine.FindSet() then
            repeat
                TempSalePOSSaleLine.Reset();
                if TempSalePOSSaleLine.FindSet() then
                    repeat
                        if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(TempOtherPaymentPOSSaleLine."No.", TempSalePOSSaleLine) then
                            if TempOtherPaymentPOSSaleLine."Amount Including VAT" >= TempSalePOSSaleLine."Amount Including VAT" then begin
                                TempOtherPaymentPOSSaleLine."Amount Including VAT" -= TempSalePOSSaleLine."Amount Including VAT";
                                TempOtherPaymentPOSSaleLine.Modify();
                                TempSalePOSSaleLine."Amount Including VAT" := 0;
                                TempSalePOSSaleLine.Modify();
                            end else begin
                                TempSalePOSSaleLine."Amount Including VAT" -= TempOtherPaymentPOSSaleLine."Amount Including VAT";
                                TempSalePOSSaleLine.Modify();
                                TempOtherPaymentPOSSaleLine."Amount Including VAT" := 0;
                                TempOtherPaymentPOSSaleLine.Modify();
                            end;
                    until (TempSalePOSSaleLine.Next() = 0) or (TempOtherPaymentPOSSaleLine."Amount Including VAT" = 0);

                TempSalePOSSaleLine.Reset();
                TempSalePOSSaleLine.SetRange("Amount Including VAT", 0);
                TempSalePOSSaleLine.DeleteAll();
            until TempOtherPaymentPOSSaleLine.Next() = 0;
    end;

    local procedure CalculateSaleAmountWithThisPOSPaymentMethod(var TempSalePOSSaleLine: Record "NPR POS Sale Line" temporary; POSPaymentMethodCode: Code[20]) SaleAmount: Decimal
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        TempSalePOSSaleLine.Reset();
        if TempSalePOSSaleLine.FindSet() then
            repeat
                if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(POSPaymentMethodCode, TempSalePOSSaleLine) then
                    SaleAmount += TempSalePOSSaleLine."Amount Including VAT";
            until TempSalePOSSaleLine.Next() = 0;
    end;



    local procedure InitLine()
    begin
        Rec.Init();
        Rec."Register No." := Sale."Register No.";
        Rec."Sales Ticket No." := Sale."Sales Ticket No.";
        Rec."Line No." := GetNextLineNo();
    end;

    procedure GetNextLineNo() NextLineNo: Integer
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast() then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
    end;

    procedure GetPaymentLine(var PaymentLinePOS: Record "NPR POS Sale Line")
    begin
        SetPaymentLineType(PaymentLinePOS);
    end;

    local procedure SetPaymentLineType(var PaymentLinePOS: Record "NPR POS Sale Line")
    begin
        PaymentLinePOS."Register No." := Sale."Register No.";
        PaymentLinePOS."Sales Ticket No." := Sale."Sales Ticket No.";
        PaymentLinePOS.Date := Sale.Date;
        PaymentLinePOS."Line Type" := PaymentLinePOS."Line Type"::"POS Payment";
    end;

    procedure InsertPaymentLine(Line: Record "NPR POS Sale Line"; ForeignCurrencyAmount: Decimal) Return: Boolean
    begin

        ValidatePaymentLine(Line);

        InitLine();
        Rec.TransferFields(Line, false);
        SetPaymentLineType(Rec);

        Rec.Validate("No.", Line."No.");
        Rec.Quantity := 0;

        ApplyForeignAmountConversion(Rec, (ForeignCurrencyAmount <> 0), ForeignCurrencyAmount);
        ReverseUnrealizedSalesVAT(Rec);

        if Line.Description <> '' then
            Rec.Description := Line.Description;

        Return := Rec.Insert(true);

        OnAfterInsertPaymentLine(Rec);
        POSSale.RefreshCurrent();
    end;

    procedure DeleteLine()
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        Handled, IsAllowed : Boolean;
    begin
        OnBeforeDeleteLine(Rec);

        if Rec."EFT Approved" then begin
            EFTInterface.AllowVoidEFTRequestOnPaymentLineDelete(Rec, Handled, IsAllowed);
            if not IsAllowed then
                Error(DeleteNotAllowed);
            if (Handled and IsAllowed) then begin
                Handled := false;
                EFTInterface.OnCreateVoidEFTRequestOnPaymentLineDelete(Rec, Handled);
            end;
        end else begin
            Rec.Delete(true);
            OnAfterDeleteLine(Rec);
        end;

        if not Rec.Find('><') then;

        POSSale.RefreshCurrent();
    end;

    local procedure ValidatePaymentLine(Line: Record "NPR POS Sale Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentMethodNotFound: Label '%1 %2 for POS unit %3 was not found.';
    begin

        if not POSPaymentMethod.Get(Line."No.") then
            Error(POSPaymentMethodNotFound, POSPaymentMethod.TableCaption, Line."No.", Line."Register No.");


        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    local procedure ApplyForeignAmountConversion(var SaleLinePOS: Record "NPR POS Sale Line"; PrecalculatedAmount: Boolean; ForeignAmount: Decimal)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";

        if not POSPaymentMethod.Get(SaleLinePOS."No.") then
            exit;

        if (POSPaymentMethod."Fixed Rate" <> 0) then
            SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT" / (POSPaymentMethod."Fixed Rate" / 100);

        if (PrecalculatedAmount) then
            SaleLinePOS."Currency Amount" := ForeignAmount;

        if POSPaymentMethod."Use Stand. Exc. Rate for Bal." then
            SaleLinePOS.Validate("Amount Including VAT", Round(CurrExchRate.ExchangeAmtFCYToLCY(SaleLinePOS.Date, POSPaymentMethod."Currency Code", SaleLinePOS."Currency Amount", CurrExchRate.ExchangeRate(SaleLinePOS.Date, POSPaymentMethod."Currency Code"))))
        else
            if (POSPaymentMethod."Fixed Rate" <> 0) then
                SaleLinePOS.Validate("Amount Including VAT", Round(SaleLinePOS."Currency Amount" * POSPaymentMethod."Fixed Rate" / 100, 0.01, POSPaymentMethod.GetRoundingType()));
    end;

    procedure ReverseUnrealizedSalesVAT(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin

        if not POSPaymentMethod.Get(SaleLinePOS."No.") then
            exit;

        Currency.InitRoundingPrecision();

        if (POSPaymentMethod."Reverse Unrealized VAT") then begin
            SaleLinePOS."Line Amount" := SaleLinePOS."Amount Including VAT";

            case SaleLinePOS."VAT Calculation Type" of
                SaleLinePOS."VAT Calculation Type"::"Reverse Charge VAT",
                SaleLinePOS."VAT Calculation Type"::"Normal VAT":
                    begin
                        SaleLinePOS.Amount := Round((SaleLinePOS."Line Amount") / (1 + SaleLinePOS."VAT %" / 100), Currency."Amount Rounding Precision");
                        SaleLinePOS."VAT Base Amount" := SaleLinePOS.Amount;
                    end;

                SaleLinePOS."VAT Calculation Type"::"Sales Tax":
                    begin
                        SaleLinePOS.TestField("Tax Area Code");
                        SaleLinePOS.Amount := SalesTaxCalculate.ReverseCalculateTax(
                          SaleLinePOS."Tax Area Code", SaleLinePOS."Tax Group Code", SaleLinePOS."Tax Liable", Rec.Date,
                          SaleLinePOS."Amount Including VAT", SaleLinePOS."Quantity (Base)", 0);

                        if SaleLinePOS.Amount <> 0 then
                            SaleLinePOS."VAT %" := Round(100 * (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount) / SaleLinePOS.Amount, 0.00001)
                        else
                            SaleLinePOS."VAT %" := 0;
                        SaleLinePOS."Amount Including VAT" := Round(SaleLinePOS."Amount Including VAT");
                        SaleLinePOS.Amount := Round(SaleLinePOS.Amount);
                        SaleLinePOS."VAT Base Amount" := SaleLinePOS.Amount;
                    end;
                else
                    Error(ErrVATCalcNotSupportInPOS, SaleLinePOS.FieldCaption("VAT Calculation Type"), SaleLinePOS."VAT Calculation Type");
            end;
        end;
    end;

    procedure GetPOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentTypeCode: Code[10]): Boolean
    begin
        exit(POSPaymentMethod.Get(PaymentTypeCode));
    end;

    procedure CalculateForeignAmount(POSPaymentMethod: Record "NPR POS Payment Method"; AmountLCY: Decimal) Amount: Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin

        if POSPaymentMethod."Use Stand. Exc. Rate for Bal." then
            Amount := CurrExchRate.ExchangeAmtLCYToFCY(Today(), POSPaymentMethod."Currency Code", AmountLCY, CurrExchRate.ExchangeRate(Today(), POSPaymentMethod."Currency Code"))
        else
            if POSPaymentMethod."Fixed Rate" <> 0 then
                Amount := AmountLCY / POSPaymentMethod."Fixed Rate" * 100
            else
                Amount := AmountLCY;
    end;

    procedure CalculateRemainingPaymentSuggestion(SalesAmount: Decimal; PaidAmount: Decimal; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; AllowNegativePaymentBalance: Boolean): Decimal
    var
        Balance: Decimal;
        ReturnRoundedBalance: Decimal;
        Result: Decimal;
    begin
        Balance := PaidAmount - SalesAmount;

        if (SalesAmount >= 0) and (Balance >= 0) then begin //Paid exact or more.
            if AllowNegativePaymentBalance and (POSPaymentMethod.Code = ReturnPOSPaymentMethod.Code) then
                exit(RoundAmount(POSPaymentMethod, CalculateForeignAmount(POSPaymentMethod, Balance)) * -1);
            exit(0);
        end;

        if (SalesAmount >= 0) and (Balance < 0) then //Not paid enough.
            exit(RoundAmount(POSPaymentMethod, CalculateForeignAmount(POSPaymentMethod, Balance)) * -1);

        if (SalesAmount < 0) and (Balance >= 0) then //Not returned enough.
            exit(RoundAmount(POSPaymentMethod, CalculateForeignAmount(POSPaymentMethod, Balance)) * -1);

        if (SalesAmount < 0) and (Balance < 0) then begin //Returned too much.
            if ReturnPOSPaymentMethod."Rounding Precision" = 0 then
                Result := Balance
            else begin
                ReturnRoundedBalance := Round(Balance, ReturnPOSPaymentMethod."Rounding Precision", ReturnPOSPaymentMethod.GetRoundingType());
                Result := ReturnRoundedBalance + Round(Balance - ReturnRoundedBalance, ReturnPOSPaymentMethod."Rounding Precision", ReturnPOSPaymentMethod.GetRoundingType());
            end;
            exit(RoundAmount(ReturnPOSPaymentMethod, CalculateForeignAmount(ReturnPOSPaymentMethod, Result)) * -1);
        end;
    end;

    procedure CalculateRemainingPaymentSuggestionInCurrentSale(POSPaymentMethod: Record "NPR POS Payment Method"): Decimal
    var
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if not Initialized then
            exit;

        CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);
        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
        exit(CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false));
    end;

    procedure RoundAmount(POSPaymentMethod: Record "NPR POS Payment Method"; Amount: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
    begin

        if (POSPaymentMethod."Rounding Precision" = 0) then
            exit(Amount);

        if POSPaymentMethod."Currency Code" <> '' then begin
            if not GLSetup.Get() then
                GLSetup.Init();
            if GLSetup."LCY Code" <> POSPaymentMethod."Currency Code" then
                exit(Round(Amount, POSPaymentMethod."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.
        end;

        exit(Round(Amount, POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType()));
    end;

    [Obsolete('Replaced by overload procedure ValidateAmountBeforePayment with 3 parameters.', '2023-06-28')]
    procedure ValidateAmountBeforePayment(POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal)
    begin
        if POSPaymentMethod.Description = '' then
            POSPaymentMethod.Description := POSPaymentMethod."Code";

        if (POSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > POSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Maximum Amount");

        if (POSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < POSPaymentMethod."Minimum Amount") then
                Error(MinAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Minimum Amount");

        if (POSPaymentMethod."Rounding Precision" <> 0) then
            if (AmountToCapture mod POSPaymentMethod."Rounding Precision") <> 0 then
                Error(InvalidAmount, AmountToCapture, POSPaymentMethod."Rounding Precision", POSPaymentMethod.Description);

        if AmountToCapture < 0 then
            POSPaymentMethod.TestField("Allow Refund");

        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    procedure ValidateAmountBeforePayment(POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal; DefaultAmountToCapture: Decimal)
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
        AmountIncreasedErr: Label 'The suggested payment amount cannot be increased for payment type %1.', Comment = '%1 - POS Payment Method description';
    begin
        if POSPaymentMethod.Description = '' then
            POSPaymentMethod.Description := POSPaymentMethod."Code";

        if (POSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > POSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Maximum Amount");

        if (POSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < POSPaymentMethod."Minimum Amount") then
                Error(MinAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Minimum Amount");

        if (POSPaymentMethod."Rounding Precision" <> 0) then
            if (AmountToCapture mod POSPaymentMethod."Rounding Precision") <> 0 then
                Error(InvalidAmount, AmountToCapture, POSPaymentMethod."Rounding Precision", POSPaymentMethod.Description);

        if AmountToCapture < 0 then
            POSPaymentMethod.TestField("Allow Refund");

        POSPaymentMethod.TestField("Block POS Payment", false);

        POSPaymentMethodItem.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
        if not POSPaymentMethodItem.IsEmpty() then
            if AmountToCapture > DefaultAmountToCapture then
                Error(AmountIncreasedErr, POSPaymentMethod.Description);
    end;

    internal procedure CalculateBalanceFromCombinedEntries(POSPaymentMethodCode: Code[10]; var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        SalesHeader: Record "Sales Header";
        TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
        TempDocumentVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
        TempDocumentMagentoPaymentLines: Record "NPR Magento Payment Line" temporary;
        TempSalesLinePOS: Record "NPR POS Sale Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        TempOtherVoucherPaymentLines: Record "NPR Magento Payment Line" temporary;
        NPRNpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        TotalPaidAmount: Decimal;
        TotalSalesAmount: Decimal;
        TotalSubtotal: Decimal;
    begin
        GetSalesLinesPOSAsBuffer(SalesTicketNo, RegisterNo, TempSalesLinePOS);

        TempSalesLinePOS.Reset();
        TempSalesLinePOS.SetFilter("Sales Document No.", '<>%1', '');
        if TempSalesLinePOS.FindFirst() then
            if not SalesHeader.Get(TempSalesLinePOS."Sales Document Type", TempSalesLinePOS."Sales Document No.") then
                Clear(SalesHeader);

        TempSalesLinePOS.Reset();
        NPRNpRvSalesDocMgt.GetSalesDocumentMagentoPaymentLines(SalesHeader, TempDocumentMagentoPaymentLines);
        NPRNpRvSalesDocMgt.GetVoucherSalesLinesPOSBuffer(SalesTicketNo, RegisterNo, TempVoucherSalesLine);

        NPRNpRvSalesDocMgt.GetSalesPOSVoucherLinesAsSalesDocumentMagentoPaymentLines(SalesHeader, TempVoucherSalesLine, TempSalesLinePOS, TempDocumentMagentoPaymentLines);
        NPRNpRvSalesDocMgt.GetSalesDocumentVoucherLines(SalesHeader, TempDocumentVoucherSalesLine);
        CopyVoucherSalesLines(TempDocumentVoucherSalesLine, TempVoucherSalesLine);
        NPRNpRvSalesDocMgt.FindSalesLines(SalesHeader, TempSalesLine);

        TotalPaidAmount := NPRNpRvSalesDocMgt.CalcPaidAmountFromMagentoPaymentLineBuffer(TempDocumentMagentoPaymentLines);
        TotalSalesAmount := CalcSalesAmountFromBuffer(TempSalesLine);
        TotalSubtotal := TotalSalesAmount - TotalPaidAmount;

        NPRNpRvSalesDocMgt.FindOtherVoucherPaymentLinesFromBuffers(TempOtherVoucherPaymentLines, TempDocumentMagentoPaymentLines, TempVoucherSalesLine, POSPaymentMethodCode);
        NPRNpRvSalesDocMgt.DecreaseOnlySalesLineThatCanOnlyBePaidWithOtherVouchersPaymentTypes(TempSalesLine, TempOtherVoucherPaymentLines, POSPaymentMethodCode);
        NPRNpRvSalesDocMgt.DecreaseSalesLinesThatCanBePaidWithOtherVouchersPaymentTypes(TempSalesLine, TempOtherVoucherPaymentLines);
        SaleAmount := NPRNpRvSalesDocMgt.CalculateSaleAmountWithThisPOSPaymentMethod(TempSalesLine, POSPaymentMethodCode);
        PaidAmount := NPRNpRvSalesDocMgt.CalcSalesOrderPaymentMethodItemPaymentAmountFromBuffers(SalesHeader, TempVoucherSalesLine, TempDocumentMagentoPaymentLines, POSPaymentMethodCode);

        Subtotal := SaleAmount - PaidAmount;
        if Subtotal > TotalSubtotal then begin
            Subtotal := TotalSubtotal;
            SaleAmount := TotalSalesAmount;
            PaidAmount := TotalPaidAmount;
        end;

        ReturnAmount := SaleAmount - PaidAmount;
    end;

    local procedure IsDocumentPaymentReservation() DocumentPaymentReservation: Boolean;
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange("Register No.", RegisterNo);
        SaleLinePOS.SetRange("Document Payment Reservation", true);
        DocumentPaymentReservation := not SaleLinePOS.IsEmpty;
    end;

    local procedure GetSalesLinesPOSAsBuffer(CurrSalesTicketNo: Code[20]; CurrRegisterNo: Code[20]; var TempSalesLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SalesLinePOS: Record "NPR POS Sale Line";
        TempVoucherSalesLineErrorLbl: Label 'TempSalesLinePOS must be temporary. This is a programming error.';
    begin
        if not TempSalesLinePOS.IsTemporary then
            Error(TempVoucherSalesLineErrorLbl);

        TempSalesLinePOS.Reset();
        if not TempSalesLinePOS.IsEmpty then
            TempSalesLinePOS.DeleteAll();

        SalesLinePOS.Reset();
        SalesLinePOS.SetRange("Sales Ticket No.", CurrSalesTicketNo);
        SalesLinePOS.SetRange("Register No.", CurrRegisterNo);
        if not SalesLinePOS.FindSet() then
            exit;

        repeat
            TempSalesLinePOS.Init();
            TempSalesLinePOS := SalesLinePOS;
            TempSalesLinePOS.Insert();
        until SalesLinePOS.Next() = 0;
    end;

    local procedure CopyVoucherSalesLines(var FromVoucherSalesLines: Record "NPR NpRv Sales Line"; var ToVoucherSalesLines: Record "NPR NpRv Sales Line")
    begin
        if not FromVoucherSalesLines.FindSet() then
            exit;

        repeat
            if not ToVoucherSalesLines.Get(FromVoucherSalesLines.RecordId) then begin
                ToVoucherSalesLines.Init();
                ToVoucherSalesLines := FromVoucherSalesLines;
                ToVoucherSalesLines.Insert();
            end
        until FromVoucherSalesLines.Next() = 0;
    end;

    local procedure CalcSalesAmountFromBuffer(var TempSalesLine: Record "Sales Line" temporary) SalesAmount: Decimal;
    var
        TempCurrSalesLine: Record "Sales Line" temporary;
    begin
        TempCurrSalesLine := TempSalesLine;
        TempCurrSalesLine.CopyFilters(TempSalesLine);

        TempSalesLine.Reset();
        TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
        TempSalesLine.CalcSums("Amount Including VAT");

        SalesAmount := TempSalesLine."Amount Including VAT";

        TempSalesLine := TempCurrSalesLine;
        TempSalesLine.Reset();
        TempSalesLine.CopyFilters(TempCurrSalesLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPaymentLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;
}

