codeunit 6150636 "NPR POS Rounding"
{
    // NPR5.37.03/MMV /20171130 CASE 296642 Created object
    // NPR5.38/MMV /20180108 CASE 300957 Rounding fix.
    // NPR5.39/MMV /20180208 CASE 304165 Added comment for clarity.
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles


    trigger OnRun()
    begin
    end;

    procedure InsertRounding(SalePOS: Record "NPR Sale POS"; ReturnPaymentType: Record "NPR Payment Type POS"; RoundAmount: Decimal) InsertedRounding: Decimal
    var
        GLAccount: Record "G/L Account";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //-NPR5.38 [300957]
        // IF SubTotal = 0 THEN
        //  EXIT;
        //
        // IF SaleAmount = 0 THEN
        //  EXIT;
        //
        // IF (ABS(SubTotal) < PaymentType."Rounding Precision") THEN
        //  RoundingPaymentType := PaymentType
        // ELSE
        //  RoundingPaymentType := ReturnPaymentType;
        //
        // IF RoundingPaymentType."Rounding Precision" = 0 THEN
        //  EXIT;
        //
        // CASE RoundingPaymentType."Rounding Direction" OF
        //  RoundingPaymentType."Rounding Direction"::Nearest : RoundingAmount := ROUND(SaleAmount, RoundingPaymentType."Rounding Precision", '=');
        //  RoundingPaymentType."Rounding Direction"::Down : RoundingAmount := ROUND(SaleAmount, RoundingPaymentType."Rounding Precision", '<');
        //  RoundingPaymentType."Rounding Direction"::Up : RoundingAmount := ROUND(SaleAmount, RoundingPaymentType."Rounding Precision", '>');
        // END;
        //
        // IF RoundingAmount = 0 THEN
        //  RoundingAmount := RoundingPaymentType."Rounding Precision";
        //
        // RoundingAmount := SaleAmount - RoundingAmount;
        //
        // IF RoundingAmount = 0 THEN
        //  EXIT;

        if RoundAmount = 0 then
            exit(0);

        RoundAmount *= -1; //Is out payment line
        //+NPR5.38 [300957]

        //-NPR5.53 [371955]-revoked
        //Register.GET(SalePOS."Register No.");
        //Register.TESTFIELD(Rounding);
        //GLAccount.GET(Register.Rounding);
        //+NPR5.53 [371955]-revoked
        //-NPR5.53 [371955]
        POSUnit.Get(SalePOS."Register No.");
        POSSetup.SetPOSUnit(POSUnit);
        GLAccount.Get(POSSetup.RoundingAccount(true));
        //+NPR5.53 [371955]
        InsertLine(SalePOS, GLAccount, RoundAmount);

        exit(RoundAmount);
    end;

    local procedure GetLastLineNo(SalePOS: Record "NPR Sale POS"): Integer
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then;
        exit(SaleLinePOS."Line No.");
    end;

    local procedure InsertLine(SalePOS: Record "NPR Sale POS"; GLAccount: Record "G/L Account"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.Init;
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := SalePOS.Date;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Out payment";
        SaleLinePOS."Line No." := GetLastLineNo(SalePOS) + 10000;
        SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
        SaleLinePOS.Validate("No.", GLAccount."No.");
        SaleLinePOS."Location Code" := SalePOS."Location Code";
        SaleLinePOS.Reference := SalePOS.Reference;
        SaleLinePOS.Description := GLAccount.Name;
        SaleLinePOS.Quantity := 0;
        SaleLinePOS."Unit Price" := Amount;
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Rounding; // This is the only thing that differentiates a rounding line from a normal out payment line later on!
        SaleLinePOS.Insert(true);
    end;
}

