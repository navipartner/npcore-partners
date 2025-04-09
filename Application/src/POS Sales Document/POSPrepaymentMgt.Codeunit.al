codeunit 6014408 "NPR POS Prepayment Mgt."
{
    Access = Internal;

    var
        GLSetup: Record "General Ledger Setup";

    procedure GetPrepaymentAmountToDeductInclVAT(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        DocumentType: Option Invoice,"Credit Memo";
    begin
        //Returns the prepayment amount that would be deducted on post.
        if SalesHeader."Currency Code" <> '' then begin
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        DocumentType := DocumentType::"Credit Memo";
        SalesPostPrepmt.SetDocumentType(DocumentType);
        SalesPostPrepmt.GetSalesLines(SalesHeader, 0, TempSalesLine);
        SalesPostPrepmt.CalcVATAmountLines(SalesHeader, TempSalesLine, TempVATAmountLine, DocumentType);
        TempVATAmountLine.CalcSums("Amount Including VAT");
        exit(TempVATAmountLine."Amount Including VAT");
    end;

    procedure SetPrepaymentAmountToPayInclVAT(SalesHeader: Record "Sales Header"; var NewPrepmtAmtToInvoice: Decimal)
    var
        Currency: Record Currency;
        SalesLine: Record "Sales Line";
        RemainderAmt: Decimal;
        LinePrepayment: Decimal;
        RemainingPrepmtAmtToInvoice: Decimal;
        SplitRatio: Decimal;
        RemainingDocAmtZeroErr: Label 'Remaining prepayment amount is zero for the document.';
    begin
        if SalesHeader."Currency Code" = '' then begin
            Currency.InitRoundingPrecision()
        end else begin
            Currency.Get(SalesHeader."Currency Code");
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        ApplyFilters(SalesHeader, SalesLine);
        if not SalesLine.FindSet(true) then
            exit;
        repeat
            RemainingPrepmtAmtToInvoice += CalcRemainingLinePrepmtAmtToInvoice(SalesLine, SalesHeader."Prices Including VAT", Currency."Amount Rounding Precision");
        until SalesLine.Next() = 0;

        case true of
            RemainingPrepmtAmtToInvoice = 0:
                Error(RemainingDocAmtZeroErr);
            NewPrepmtAmtToInvoice >= RemainingPrepmtAmtToInvoice:
                begin
                    NewPrepmtAmtToInvoice := RemainingPrepmtAmtToInvoice;
                    SplitRatio := 1;
                end;
            else
                SplitRatio := NewPrepmtAmtToInvoice / RemainingPrepmtAmtToInvoice;
        end;
        RemainderAmt := 0;

        SalesLine.SetHideValidationDialog(true);
        SalesLine.SuspendStatusCheck(true);
        SalesLine.FindSet(true);
        repeat
            LinePrepayment := CalcRemainingLinePrepmtAmtToInvoice(SalesLine, SalesHeader."Prices Including VAT", Currency."Amount Rounding Precision") * SplitRatio + RemainderAmt;
            RemainderAmt := LinePrepayment - Round(LinePrepayment, Currency."Amount Rounding Precision");
            LinePrepayment := Round(LinePrepayment, Currency."Amount Rounding Precision");
            SalesLine.Validate("Prepayment %",
                Round((CalcAmtIncludingVAT(SalesLine."Prepmt. Amt. Inv.", SalesLine."Prepayment VAT %", SalesHeader."Prices Including VAT", Currency."Amount Rounding Precision") + LinePrepayment) * 100 / SalesLine."Amount Including VAT", 0.00001));
            if LinePrepayment = 0 then begin
                SalesLine."Prepayment Amount" := 0;
                SalesLine."Prepmt. Amt. Incl. VAT" := 0;
            end;
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;

        CalcPrepmtVatAmounts(SalesHeader, SalesLine);
        SalesLine.CalcSums("Prepmt. Amt. Incl. VAT");
        NewPrepmtAmtToInvoice := SalesLine."Prepmt. Amt. Incl. VAT";
    end;

    procedure SetPrepaymentPercentageToPay(SalesHeader: Record "Sales Header"; Percent: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesHeader."Currency Code" <> '' then begin
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        ApplyFilters(SalesHeader, SalesLine);
        if not SalesLine.FindSet(true) then
            exit;
        SalesLine.SetHideValidationDialog(true);
        SalesLine.SuspendStatusCheck(true);
        repeat
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
            SalesLine.Validate("Prepayment %", SalesLine."Prepayment %" + Percent);
            if Percent = 0 then begin
                SalesLine."Prepayment Amount" := 0;
                SalesLine."Prepmt. Amt. Incl. VAT" := 0;
            end;
            SalesLine.Modify();
        until SalesLine.Next() = 0;

        CalcPrepmtVatAmounts(SalesHeader, SalesLine);
        SalesLine.CalcSums(SalesLine."Prepmt. Amt. Incl. VAT");
        exit(SalesLine."Prepmt. Amt. Incl. VAT");
    end;

    procedure SetManualLinePrepaymentPercentageToPay(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
        PrepaymentPercentage: Decimal;
    begin
        if SalesHeader."Currency Code" <> '' then begin
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        ApplyFilters(SalesHeader, SalesLine);
        if not SalesLine.FindSet(true) then
            exit;

        SalesLine.SetHideValidationDialog(true);
        SalesLine.SuspendStatusCheck(true);
        repeat
            PrepaymentPercentage := SalesLine."Prepayment %";
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
            SalesLine.Validate("Prepayment %", PrepaymentPercentage); // Re-validating after Prepmt. Line Amount has been reset to invoiced amount

            if SalesLine."Prepayment %" = 0 then begin
                SalesLine."Prepayment Amount" := 0;
                SalesLine."Prepmt. Amt. Incl. VAT" := 0;
            end;
            SalesLine.Modify();
        until SalesLine.Next() = 0;

        CalcPrepmtVatAmounts(SalesHeader, SalesLine);
        SalesLine.CalcSums(SalesLine."Prepmt. Amt. Incl. VAT");
        exit(SalesLine."Prepmt. Amt. Incl. VAT");
    end;

    local procedure CalcRemainingLinePrepmtAmtToInvoice(SalesLine: Record "Sales Line"; PricesInclidingVAT: Boolean; RoundingPrecision: Decimal): Decimal
    var
        RemainingLineAmtToInvoice: Decimal;
    begin
        if (SalesLine.Quantity <> 0) and (SalesLine."Quantity Invoiced" <> 0) then
            RemainingLineAmtToInvoice := Round(SalesLine."Amount Including VAT" * (SalesLine.Quantity - SalesLine."Quantity Invoiced") / SalesLine.Quantity, RoundingPrecision)
        else
            RemainingLineAmtToInvoice := SalesLine."Amount Including VAT";

        exit(RemainingLineAmtToInvoice - CalcAmtIncludingVAT(SalesLine."Prepmt. Amt. Inv." - SalesLine."Prepmt Amt Deducted", SalesLine."Prepayment VAT %", PricesInclidingVAT, RoundingPrecision));
    end;

    local procedure CalcAmtIncludingVAT(Amount: Decimal; VATRate: Decimal; PricesInclidingVAT: Boolean; RoundingPrecision: Decimal) AmountInclVAT: Decimal
    begin
        if PricesInclidingVAT or (VATRate = 0) then
            AmountInclVAT := Amount
        else
            AmountInclVAT := Amount * (1 + VATRate / 100);
        AmountInclVAT := Round(AmountInclVAT, RoundingPrecision);
    end;

    procedure GetPrepaymentAmountToPay(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        ApplyFilters(SalesHeader, SalesLine);
        if SalesLine.IsEmpty() then
            exit(0);
        CalcPrepmtVatAmounts(SalesHeader, SalesLine);
        SalesLine.CalcSums("Prepmt. Amt. Incl. VAT");
        exit(SalesLine."Prepmt. Amt. Incl. VAT");
    end;

    local procedure CalcPrepmtVatAmounts(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempVATAmountLineDeduct: Record "VAT Amount Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        DocumentType: Option Invoice,"Credit Memo";
    begin
        Clear(SalesPostPrepmt);
        DocumentType := DocumentType::Invoice;
        SalesPostPrepmt.SetDocumentType(DocumentType);
        SalesPostPrepmt.GetSalesLinesToDeduct(SalesHeader, TempSalesLine);
        if not TempSalesLine.IsEmpty then
            SalesPostPrepmt.CalcVATAmountLines(SalesHeader, TempSalesLine, TempVATAmountLineDeduct, DocumentType::"Credit Memo");
        SalesPostPrepmt.CalcVATAmountLines(SalesHeader, SalesLine, TempVATAmountLine, DocumentType);
        TempVATAmountLine.DeductVATAmountLine(TempVATAmountLineDeduct);
        SalesPostPrepmt.UpdateVATOnLines(SalesHeader, SalesLine, TempVATAmountLine, DocumentType);
    end;

    local procedure ApplyFilters(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter(Quantity, '>%1', 0);
        SalesLine.SetFilter("Line Amount", '>%1', 0);
    end;
}