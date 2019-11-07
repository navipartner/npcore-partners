codeunit 6014408 "POS Prepayment Mgt."
{
    // NPR5.52/MMV /20190911 CASE 352473 Created object


    trigger OnRun()
    begin
    end;

    procedure GetPrepaymentAmountToDeductInclVAT(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        PrepmtTotalAmount: Decimal;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PrepmtVATAmount: Decimal;
        PrepmtVATAmountText: Text;
        GLSetup: Record "General Ledger Setup";
    begin
        //Returns the prepayment amount that would be deducted on full document qty. post

        // NAV does not support retrieving prepayment amount to deduct incl. VAT on lines without this flag on header and
        // any amount input in a POS dialog is implicitly incl. VAT, hence it is required.
        SalesHeader.TestField("Prices Including VAT", true);

        if SalesHeader."Currency Code" <> '' then begin
          GLSetup.Get;
          SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        SalesPostPrepmt.GetSalesLines(SalesHeader,0,TempSalesLine);
        TempSalesLine.CalcSums("Prepmt Amt to Deduct");
        exit(TempSalesLine."Prepmt Amt to Deduct");
    end;

    procedure GetPrepaymentAmountToPayInclVATFromPercentage(SalesHeader: Record "Sales Header";Percent: Decimal): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        PrepmtTotalAmount: Decimal;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PrepmtVATAmount: Decimal;
        PrepmtVATAmountText: Text;
        GLSetup: Record "General Ledger Setup";
    begin
        //Returns the diff between already invoiced prepayment and what the new percent would add.

        // NAV does not support retrieving prepayment amount to pay incl. VAT on lines without this flag on header and
        // any amount input in a POS dialog is implicitly incl. VAT, hence it is required.
        SalesHeader.TestField("Prices Including VAT", true);

        if SalesHeader."Currency Code" <> '' then begin
          GLSetup.Get;
          SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        SalesPostPrepmt.GetSalesLines(SalesHeader,0,TempSalesLine);

        if TempSalesLine.FindSet then repeat
          TempSalesLine.Validate("Prepmt. Line Amount", TempSalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
          TempSalesLine.Validate("Prepayment %", TempSalesLine."Prepayment %" + Percent);
        until TempSalesLine.Next = 0;

        TempSalesLine.CalcSums("Prepmt. Amount Inv. (LCY)");
        exit(TempSalesLine."Prepmt. Amount Inv. (LCY)");
    end;

    procedure SetPrepaymentAmountToPayInclVAT(SalesHeader: Record "Sales Header";Persist: Boolean;Amount: Decimal)
    var
        SalesLine: Record "Sales Line";
        TotalAmount: Decimal;
        LineCount: Integer;
        i: Integer;
        Currency: Record Currency;
        RemainingAmount: Decimal;
        GLSetup: Record "General Ledger Setup";
    begin
        if SalesHeader."Currency Code" = '' then begin
          Currency.InitRoundingPrecision()
        end else begin
          Currency.Get(SalesHeader."Currency Code");
          GLSetup.Get;
          SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        // NAV does not support specifying prepayment amount incl. VAT on lines without this flag on header and
        // any amount input in a POS dialog is implicitly incl. VAT, hence it is required.
        SalesHeader.TestField("Prices Including VAT", true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetHideValidationDialog(true);

        if not SalesLine.FindSet(true) then
          exit;

        LineCount := SalesLine.Count;
        RemainingAmount := Amount;

        repeat
          i += 1;
          SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.

          if (i <> LineCount) then begin
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Line Amount" + Round(Amount / LineCount, Currency."Amount Rounding Precision"));
            RemainingAmount -= Round(Amount / LineCount, Currency."Amount Rounding Precision");
          end else begin
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Line Amount" + RemainingAmount);
          end;

          if Persist then
            SalesLine.Modify(true);
        until SalesLine.Next = 0;
    end;

    procedure SetPrepaymentPercentageToPay(SalesHeader: Record "Sales Header";Persist: Boolean;Percent: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";
        GLSetup: Record "General Ledger Setup";
        PrepaymentAmountDiff: Decimal;
    begin
        if SalesHeader."Currency Code" <> '' then begin
          GLSetup.Get;
          SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        SalesHeader.TestField("Prices Including VAT", true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetHideValidationDialog(true);

        if SalesLine.FindSet(true) then repeat
          SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
          SalesLine.Validate("Prepayment %", SalesLine."Prepayment %" + Percent);

          PrepaymentAmountDiff += (SalesLine."Prepmt. Line Amount" -  SalesLine."Prepmt. Amt. Inv.");

          if Persist then
            SalesLine.Modify(true);
        until SalesLine.Next = 0;

        exit(PrepaymentAmountDiff);
    end;
}

