codeunit 6014408 "NPR POS Prepayment Mgt."
{
    procedure GetPrepaymentAmountToDeductInclVAT(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        GLSetup: Record "General Ledger Setup";
    begin
        //Returns the prepayment amount that would be deducted on post.

        // NAV does not support retrieving prepayment amount to deduct incl. VAT on lines without this flag on header and
        // any amount input in a POS dialog is implicitly incl. VAT, hence it is required.
        SalesHeader.TestField("Prices Including VAT", true);

        if SalesHeader."Currency Code" <> '' then begin
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        SalesPostPrepmt.GetSalesLines(SalesHeader, 0, TempSalesLine);
        TempSalesLine.CalcSums("Prepmt Amt to Deduct");
        exit(TempSalesLine."Prepmt Amt to Deduct");
    end;

    procedure SetPrepaymentAmountToPayInclVAT(SalesHeader: Record "Sales Header"; Persist: Boolean; Amount: Decimal)
    var
        SalesLine: Record "Sales Line";
        LineCount: Integer;
        i: Integer;
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        RemainingDocumentAmount: Decimal;
        SplitPercentage: Decimal;
        LinePrepayment: Decimal;
    begin
        if SalesHeader."Currency Code" = '' then begin
            Currency.InitRoundingPrecision()
        end else begin
            Currency.Get(SalesHeader."Currency Code");
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        // NAV does not support specifying prepayment amount incl. VAT on lines without this flag on header and
        // any amount input in a POS dialog is implicitly incl. VAT, hence it is required.
        SalesHeader.TestField("Prices Including VAT", true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter("Line Amount", '<>%1', 0);
        SalesLine.SetHideValidationDialog(true);
        SalesLine.SuspendStatusCheck(true);

        if not SalesLine.FindSet(true) then
            exit;

        repeat
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
            RemainingDocumentAmount += (SalesLine."Line Amount" - SalesLine."Prepmt Amt Deducted" - SalesLine."Prepmt Amt to Deduct");
            LineCount += 1;
        until SalesLine.Next() = 0;

        SplitPercentage := 100 / (RemainingDocumentAmount / Amount);

        SalesLine.FindSet(true);
        repeat
            i += 1;
            SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.

            if (i <> LineCount) then begin
                LinePrepayment := Round(((SalesLine."Line Amount" - SalesLine."Prepmt Amt Deducted" - SalesLine."Prepmt Amt to Deduct") / 100) * SplitPercentage, Currency."Amount Rounding Precision");
                SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Line Amount" + LinePrepayment);
                Amount -= LinePrepayment;
            end else begin
                SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Line Amount" + Amount);
            end;

            if Persist then
                SalesLine.Modify(true);
        until SalesLine.Next() = 0;
    end;

    procedure SetPrepaymentPercentageToPay(SalesHeader: Record "Sales Header"; Persist: Boolean; Percent: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";
        GLSetup: Record "General Ledger Setup";
        PrepaymentAmountDiff: Decimal;
    begin
        if SalesHeader."Currency Code" <> '' then begin
            GLSetup.Get();
            SalesHeader.TestField("Currency Code", GLSetup."LCY Code");
        end;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter("Line Amount", '<>%1', 0);
        SalesLine.SetHideValidationDialog(true);
        SalesLine.SuspendStatusCheck(true);

        if SalesLine.FindSet(true) then
            repeat
                SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv."); //Set prepayment amount back to invoiced, in case someone modified it without posting.
                SalesLine.Validate("Prepayment %", SalesLine."Prepayment %" + Percent);

                PrepaymentAmountDiff += (SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.");

                if Persist then
                    SalesLine.Modify(true);
            until SalesLine.Next() = 0;

        exit(PrepaymentAmountDiff);
    end;

    procedure GetPrepaymentAmountToPay(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter("Line Amount", '<>%1', 0);
        if not SalesLine.IsEmpty() then begin
            SalesLine.CalcSums("Prepmt. Line Amount", "Prepmt. Amt. Inv.");
            exit(SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.");
        end;
    end;
}

