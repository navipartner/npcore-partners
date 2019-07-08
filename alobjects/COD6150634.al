codeunit 6150634 "POS Give Change"
{
    // NPR5.37/BR  /20171017  CASE 293711 Object Created
    // NPR5.37.03/MMV /20171122  CASE 296642 Added function InsertChange.
    //                                    Removed subscriber (replaced with direct call from transcendence).
    // NPR5.38/BR  /20171219  CASE 300558 Take Dimensions from Sale
    // NPR5.38/MMV /20180108  CASE 300957 Rounding fix.


    trigger OnRun()
    begin
    end;

    var
        TextNoReturnPaymentType: Label 'Setup missing: no %1 could be found to give the customer change in. ';
        TextChange: Label 'Change';

    procedure InsertChange(SalePOS: Record "Sale POS";ReturnPaymentType: Record "Payment Type POS";Balance: Decimal) ChangeToGive: Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
        RoundedBalance: Decimal;
    begin
        //Called from transcendence POS
        //-NPR5.38 [300957]
        RoundedBalance := POSPaymentLine.RoundAmount(ReturnPaymentType, Balance);
        ChangeToGive := RoundedBalance + POSPaymentLine.RoundAmount(ReturnPaymentType, Balance - RoundedBalance);

        if ChangeToGive = 0 then
          exit(0);

        InsertOutPaymentLine(SalePOS, -ChangeToGive, ReturnPaymentType."No.", TextChange);
        exit(ChangeToGive);

        // RoundingAmount *= -1; //Is outpayment
        // IF (ABS(SaleAmount) + ABS(RoundingAmount)) >= ABS(PaymentAmount) THEN
        //  EXIT;
        //
        // InsertOutPaymentLine(SalePOS, - (PaymentAmount - SaleAmount - RoundingAmount), ReturnPaymentType."No.", TextChange);
        // EXIT( PaymentAmount - SaleAmount - RoundingAmount );
        //+NPR5.38 [300957]
    end;

    procedure CalcAndInsertChange(var SalePOS: Record "Sale POS") ChangeToGive: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        GLAccount: Record "G/L Account";
        SaleAmount: Decimal;
        PaymentAmount: Decimal;
        RoundingAmount: Decimal;
    begin
        //Called from standard POS
        SaleAmount := GetSaleAmountInclTax(SalePOS);
        PaymentAmount := GetPaymentAmount(SalePOS);
        if SaleAmount >= PaymentAmount then
          exit;

        RoundingAmount := GetRoundingAmount(SalePOS,PaymentAmount - SaleAmount);

        //-NPR5.37.03 [296642]
        if (Abs(SaleAmount) + Abs(RoundingAmount)) = Abs(PaymentAmount) then
          exit;
        //+NPR5.37.03 [296642]

        InsertOutPaymentLine(SalePOS,- (PaymentAmount - SaleAmount - RoundingAmount), GetReturnPaymentType(SalePOS),TextChange);
        exit( (PaymentAmount - SaleAmount - RoundingAmount));
    end;

    local procedure "--- Helper functions"()
    begin
    end;

    local procedure InsertOutPaymentLine(var SalePOS: Record "Sale POS";AmountIn: Decimal;NoIn: Code[10];DescriptionIn: Text)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        with SaleLinePOS do begin
          Init;
          "Register No." := SalePOS."Register No.";
          "Sales Ticket No." := SalePOS."Sales Ticket No.";
          Date := SalePOS.Date;
          "Sale Type" := "Sale Type"::Payment;
          "Line No." := GetLastLineNo(SalePOS) + 10000;
          //-NPR5.37.03 [296642]
        //  SETRECFILTER;
        //  IF NOT ISEMPTY THEN REPEAT
        //    "Line No." := "Line No." + 10000; //Ensure the line no. is not already taken
        //    SETRECFILTER;
        //  UNTIL ISEMPTY;
        //  RESET;
          //+NPR5.37.03 [296642]
          Insert(true);
          "Location Code" := SalePOS."Location Code";
          Reference := SalePOS.Reference;
          Type := Type::Payment;
          "No." := NoIn;
          Description := DescriptionIn;
          "Amount Including VAT" := AmountIn;
          //-NPR5.38 [300558]
          "Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
          "Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
          "Dimension Set ID" := SalePOS."Dimension Set ID";
          //+NPR5.38 [300558]
          Modify(true);
        end;
    end;

    local procedure GetReturnPaymentType(SalePOS: Record "Sale POS"): Code[10]
    var
        PaymentTypePOS: Record "Payment Type POS";
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
    begin
        RetailSetup.Get;
        Register.Get(SalePOS."Register No.");
        with PaymentTypePOS do begin
          Reset;
          SetRange("Processing Type","Processing Type"::Cash);
          SetRange(Status,Status::Active);
          if RetailSetup."Payment Type By Register" then
            SetRange("Register No.",SalePOS."Register No.");
          SetRange("No.",Register."Return Payment Type");
          if FindFirst then
            exit("No.");
        end;
        Error(TextNoReturnPaymentType,PaymentTypePOS.TableCaption);
    end;

    local procedure GetRoundingAccount(SalePOS: Record "Sale POS";var GLAccount: Record "G/L Account")
    var
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
    begin
        Register.Get(SalePOS."Register No.");
        Register.TestField(Rounding);
        GLAccount.Get(Register.Rounding);
    end;

    local procedure GetRoundingAmount(SalePOS: Record "Sale POS";ChangeAmount: Decimal): Decimal
    var
        RetailSetup: Record "Retail Setup";
        Register: Record Register;
    begin
        RetailSetup.Get;
        Register.Get(SalePOS."Register No.");
        if (RetailSetup."Amount Rounding Precision" = 0) or (Register.Rounding = '') then
          exit(0);
        exit(ChangeAmount - Round(ChangeAmount,RetailSetup."Amount Rounding Precision",'='));
    end;

    local procedure GetLastLineNo(SalePOS: Record "Sale POS"): Integer
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.37.03 [296642]
        with SaleLinePOS do begin
          SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
          SetRange("Register No.", SalePOS."Register No.");
          SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
          if SaleLinePOS.FindLast then;
          exit(SaleLinePOS."Line No.");
        end;

        // WITH SaleLinePOS DO BEGIN
        //  SETRANGE("Register No.",SalePOS."Register No.");
        //  SETRANGE("Sales Ticket No.",SalePOS."Sales Ticket No.");
        //  SETRANGE(Date,SalePOS.Date);
        //  SETRANGE("Sale Type","Sale Type"::"Out payment");
        //  IF FINDLAST THEN
        //    EXIT("Line No.");
        // END;
        // EXIT(0);
        //+NPR5.37.03 [296642]
    end;

    local procedure GetSaleAmountInclTax(SalePOS: Record "Sale POS"): Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        TotalAmount: Decimal;
    begin
        with SaleLinePOS do begin
          SetRange("Register No.",SalePOS."Register No.");
          SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SetRange(Date,SalePOS.Date);
          SetRange("Sale Type","Sale Type"::Sale);
          if FindSet then repeat
            TotalAmount := TotalAmount + "Amount Including VAT";
          until Next = 0;

          SetRange("Sale Type","Sale Type"::Deposit);
          if FindSet then repeat
            TotalAmount := TotalAmount + "Amount Including VAT";
          until Next = 0;

          SetRange("Sale Type","Sale Type"::"Out payment");
          if FindSet then repeat
            TotalAmount := TotalAmount - "Amount Including VAT";
          until Next = 0;
        end;
        exit(TotalAmount);
    end;

    local procedure GetPaymentAmount(SalePOS: Record "Sale POS"): Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        TotalAmount: Decimal;
    begin
        with SaleLinePOS do begin
          SetRange("Register No.",SalePOS."Register No.");
          SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SetRange(Date,SalePOS.Date);
          SetRange("Sale Type","Sale Type"::Payment);
          if FindSet then repeat
            TotalAmount := TotalAmount + "Amount Including VAT";
          until Next = 0;
        end;
        exit(TotalAmount);
    end;
}

