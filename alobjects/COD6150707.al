codeunit 6150707 "POS Payment Line"
{
    // NPR5.28/TSA/20161114  CASE 254327 added several functions to support payment
    // NPR5.32.11/CLVA  /20170623  CASE 279495 Added event OnAfterInsertPaymentLine and OnAfterDeleteLine
    // NPR5.37/TSA /20170828 CASE 288119 Adding some missing functions regarding refresh and set first / last
    // NPR5.37/MHA /20171011  CASE 293084 Added function GetNextLineNo()
    // NPR5.37/TSA /20171019 CASE 293979 Fixed issue with wrong rec in publisher OnAfterDeleteLine, added OnBeforeDeleteLine
    // NPR5.37/TSA /20171025 CASE 294454 Fixed sortorder in GetNextLineNo()
    // NPR5.37.03/MMV /20171123 CASE 296642 Support for rounding direction
    // NPR5.38/MMV /20171230 CASE 300957 Rounding fix.
    // NPR5.38/MHA /20180105  CASE 301053 Renamed parameter DataSet to CurrDataSet in function ToDataSet() as the word is reserved in V2
    // NPR5.39/TSA /20180206 CASE 303052 Made CalculateBalance() safe from not initialized codeunit
    // NPR5.43/TSA /20180614 CASE 319244 Set OnBeforeDeleteLine as publisher function
    // NPR5.46/MMV /20180914 CASE 290734 Created cleaner balancing and amount suggestion helper functions.
    // NPR5.46/MHA /20180928 CASE 329523 POSSale.RefreshCurrent() is now invoked after every transactional change
    // NPR5.47/MHA /20181114 CASE 335992 ReturnAmount should still be set in CalculateBalance()
    // NPR5.48/MHA /20181101  CASE 328255 Changed FunctionVisibility to External for all Global Functions
    // NPR5.49/MHA /20190212 CASE 345354 Description should be set from Parameter in InsertPaymentLine()
    // NPR5.50/MMV /20190403 CASE 300557 Added init handling
    // NPR5.50/TSA /20190530 CASE 354832 Added ReverseUnrealizedSalesVAT()
    // NPR5.51/ALPO/20190820 CASE 365161 Lines with Type=Comment excluded from CalculateBalance()
    // NPR5.52/MHA /20191016 CASE 373294 Added "Allow Cashback" to ValidatePaymentLine()
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    // NPR5.53/MHA /20190114 CASE 384841 Added parameter NegativePaymentBalance to function CalculateRemainingPaymentSuggestion()
    // NPR5.55/MMV /20200421 CASE 386254 Added ValidateAmountBeforePayment


    trigger OnRun()
    begin
    end;

    var
        Rec: Record "Sale Line POS";
        Sale: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        Setup: Codeunit "POS Setup";
        FrontEnd: Codeunit "POS Front End Management";
        RegisterNo: Code[20];
        SalesTicketNo: Code[20];
        NotFound: Label '%1 %2 not found.';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        DeleteNotAllowed: Label 'Payments approved by a 3-party must be cancelled, not deleted.';
        Initialized: Boolean;
        ErrVATCalcNotSupportInPOS: Label '%1 %2 not supported in POS';
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        InvalidAmount: Label 'Amount %1 is not valid for payment type %2';

        procedure Init(RegisterNoIn: Code[20];SalesTicketNoIn: Code[20];SaleIn: Codeunit "POS Sale";SetupIn: Codeunit "POS Setup";FrontEndIn: Codeunit "POS Front End Management")
    begin
        Clear(Rec);
        with Rec do begin
          FilterGroup(2);
          SetRange(Type,Type::Payment);
          SetRange("Register No.",RegisterNoIn);
          SetRange("Sales Ticket No.",SalesTicketNoIn);
          FilterGroup(0);
        end;

        Sale.Get(RegisterNoIn,SalesTicketNoIn);

        POSSale := SaleIn;
        Setup := SetupIn;
        FrontEnd := FrontEndIn;

        RegisterNo := RegisterNoIn;
        SalesTicketNo := SalesTicketNoIn;

        Initialized := true;
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        //-NPR5.50 [300557]
        if WithError and (not Initialized) then
          Error('Codeunit POS Payment Line was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
        //+NPR5.50 [300557]
    end;

        procedure ToDataset(var CurrDataSet: DotNet npNetDataSet;DataSource: DotNet npNetDataSource0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        DataMgt: Codeunit "POS Data Management";
        SaleAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        Subtotal: Decimal;
    begin
        //-NPR5.38 [301053]
        // DataMgt.RecordToDataSet(Rec,DataSet,DataSource,POSSession,FrontEnd);
        //
        // CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,Subtotal);
        // DataSet.Totals.Add('SaleAmount',SaleAmount);
        // DataSet.Totals.Add('PaidAmount',PaidAmount);
        // DataSet.Totals.Add('ReturnAmount',ReturnAmount);
        // DataSet.Totals.Add('Subtotal',Subtotal);
        DataMgt.RecordToDataSet(Rec,CurrDataSet,DataSource,POSSession,FrontEnd);

        CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,Subtotal);
        CurrDataSet.Totals.Add('SaleAmount',SaleAmount);
        CurrDataSet.Totals.Add('PaidAmount',PaidAmount);
        CurrDataSet.Totals.Add('ReturnAmount',ReturnAmount);
        CurrDataSet.Totals.Add('Subtotal',Subtotal);
        //+NPR5.38 [301053]
    end;

        procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find);
    end;

        procedure RefreshCurrent(): Boolean
    begin
        exit (Rec.Find());
    end;

        procedure SetFirst()
    begin
        Rec.FindFirst ();
    end;

        procedure SetLast()
    begin
        Rec.FindLast ();
    end;

        procedure GetCurrentPaymentLine(var PaymentLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.37 [288119]
        RefreshCurrent();
        //+NPR5.37 [288119]

        PaymentLinePOS.Copy (Rec);
    end;

        procedure CalculateBalance(var SaleAmount: Decimal;var PaidAmount: Decimal;var ReturnAmount: Decimal;var Subtotal: Decimal)
    var
        PaymentLine: Record "Sale Line POS";
        PaymentType: Record "Payment Type POS";
        Register: Record Register;
        RetailCode: Codeunit "Retail Form Code";
        Functions: Codeunit "Touch Screen - Functions";
        RoundingAmount: Decimal;
        Decimal: Decimal;
        DiscountRounding: Decimal;
        i: Integer;
        t001: Label 'You have to set a return payment type on the register.';
        SaleLinePOS: Record "Sale Line POS";
        ReturnRounding: Decimal;
    begin
        //ReturnAmount is deprecated - it cannot be calculated correctly without knowing the last payment type used.


        //-NPR5.46 [290734]
        // IF (NOT IsInitialized) THEN
        // EXIT;
        //
        // WITH Rec DO BEGIN
        //  SaleAmount := 0;
        //  ReturnRounding := 0;

        //  PaymentLine.SETCURRENTKEY("Discount Type");;
        //  PaymentLine.SETRANGE("Register No.",RegisterNo);
        //  PaymentLine.SETRANGE("Sales Ticket No.",SalesTicketNo);
        //
        //  PaymentLine.SETFILTER("Sale Type",'%1|%2',"Sale Type"::Sale,"Sale Type"::Deposit);
        //  PaymentLine.SETRANGE("Discount Type");
        //  IF PaymentLine.CALCSUMS("Amount Including VAT") THEN
        //    Total := PaymentLine."Amount Including VAT";
        //
        //  PaymentLine.SETRANGE("Sale Type","Sale Type"::"Out payment");
        //  PaymentLine.SETFILTER("Discount Type",'<>%1',"Discount Type"::Rounding);
        //  IF PaymentLine.CALCSUMS("Amount Including VAT") THEN
        //    Total := Total - PaymentLine."Amount Including VAT";
        //
        //  SaleAmount := Total;
        //
        //  Setup.GetRegisterRecord(Register);
        //
        //  IF (NOT GetPaymentType(PaymentType, Register."Return Payment Type", Register."Register No.")) THEN
        //    ERROR(t001);
        //
        //  PaymentLine.SETRANGE("Sale Type","Sale Type"::Payment);
        //  PaymentLine.SETRANGE("Discount Type");
        //  IF PaymentLine.CALCSUMS("Amount Including VAT") THEN
        //    PaidAmount := PaymentLine."Amount Including VAT";
        //
        //  PaymentLine.SETRANGE("Sale Type",PaymentLine."Sale Type"::"Out payment");
        //  PaymentLine.SETRANGE("Discount Type","Discount Type"::Rounding);
        //  IF PaymentLine.CALCSUMS("Amount Including VAT") THEN
        //    Rounding := PaymentLine."Amount Including VAT";

        //  DiscountRounding := RetailCode.GetDiscountRounding("Sales Ticket No.","Register No.");
        //
        //  Rounding += DiscountRounding;
        //
        //
        //  Total := Total - PaidAmount - Rounding;
        //  Subtotal := Total;

        if (not Initialized) then
         exit;

        Setup.GetRegisterRecord(Register);
        if (not GetPaymentType(PaymentType, Register."Return Payment Type", Register."Register No.")) then
          Error(t001);

        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;

        with SaleLinePOS do begin
          SetRange("Register No.", RegisterNo);
          SetRange("Sales Ticket No.", SalesTicketNo);
          SetFilter(Type,'<>%1',Type::Comment);  //-+NPR5.51 [365161]
          if FindSet then
            repeat
              case true of
                ("Sale Type" in ["Sale Type"::Sale, "Sale Type"::Deposit]) : SaleAmount += "Amount Including VAT";
                ("Sale Type" = "Sale Type"::"Out payment") and ("Discount Type" <> "Discount Type"::Rounding) : SaleAmount -= "Amount Including VAT";
                ("Sale Type" = "Sale Type"::"Out payment") and ("Discount Type" = "Discount Type"::Rounding) : RoundingAmount += "Amount Including VAT";
                ("Sale Type" = "Sale Type"::Payment) : PaidAmount += "Amount Including VAT";
              end;
            until Next = 0;
        end;

        Subtotal := SaleAmount - PaidAmount - RoundingAmount;
        //+NPR5.46 [290734]


        //-NPR5.47 [335992]
        // // TODO: WTF! WTBF!! This piece of code was taken from old solution, and mildly refactored (variable names).
        // // It looks overly complex, and I think the whole loop could be replaced with a couple of simple mathematical operations.
        // // If only I could understand the original requirement and what exactly is the code below hoping to achieve through unnecessary complication.
        // // If you know why the code below looks the way it looks, please contact me (npvb@navipartner.dk)
        // IF (Subtotal < 0) AND (Register.Rounding <> '') AND (Setup.AmountRoundingPrecision > 0) THEN BEGIN
        //  Decimal := ABS(Subtotal) - ROUND(ABS(Subtotal),1,'<');
        //  i := 0;
        //  ReturnRounding := -Decimal;
        //  REPEAT
        //    i += 1;
        //    IF ABS(i * Setup.AmountRoundingPrecision - Decimal) <= ABS(ReturnRounding) THEN
        //      ReturnRounding := i * Setup.AmountRoundingPrecision - Decimal;
        //  UNTIL i * Setup.AmountRoundingPrecision >= 1;
        // END;
        //
        //ReturnAmount := Total - ReturnRounding;
        ReturnAmount := SaleAmount - PaidAmount - RoundingAmount - ReturnRounding;
        //-NPR5.53 [371955]-revoked
        //IF (ReturnAmount < 0) AND (Register.Rounding <> '') AND (Setup.AmountRoundingPrecision > 0) THEN
        //  ReturnAmount := ROUND(ReturnAmount,Setup.AmountRoundingPrecision,'=');
        //+NPR5.53 [371955]-revoked
        //-NPR5.53 [371955]
        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision > 0) then
          ReturnAmount := Round(ReturnAmount,Setup.AmountRoundingPrecision,Setup.AmountRoundingDirection);
        //+NPR5.53 [371955]
        //+NPR5.47 [335992]
    end;

    local procedure InitLine()
    begin
        //-NPR5.37 [293084]
        //Rec."Line No." := 10000;
        //IF (Rec.FINDLAST ()) THEN
        //  Rec."Line No." += 10000;
        //+NPR5.37 [293084]

        Rec.Init();
        //-NPR5.37 [293084]
        Rec."Register No." := Sale."Register No.";
        Rec."Sales Ticket No." := Sale."Sales Ticket No.";
        Rec."Line No." := GetNextLineNo();
        //+NPR5.37 [293084]
    end;

        procedure GetNextLineNo() NextLineNo: Integer
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.37 [294454]
        SaleLinePOS.SetCurrentKey ("Register No.","Sales Ticket No.","Line No.");
        //+NPR5.37 [294454]

        //-NPR5.37 [293084]
        SaleLinePOS.SetRange("Register No.",Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
        //+NPR5.37 [293084]
    end;

        procedure GetPaymentLine(var PaymentLinePOS: Record "Sale Line POS")
    begin
        SetPaymentLineType (PaymentLinePOS);
    end;

    local procedure SetPaymentLineType(var PaymentLinePOS: Record "Sale Line POS")
    begin
        with PaymentLinePOS do begin
          "Register No." := Sale."Register No.";
          "Sales Ticket No." := Sale."Sales Ticket No.";
          Date := Sale.Date;
          "Sale Type" := "Sale Type"::Payment;
          Type := Type::Payment;
        end;
    end;

        procedure InsertPaymentLine(Line: Record "Sale Line POS";ForeignCurrencyAmount: Decimal) Return: Boolean
    begin

        ValidatePaymentLine (Line);

        with Rec do begin
          InitLine ();
          Rec.TransferFields (Line, false);
          SetPaymentLineType (Rec);

          Validate ("No.", Line."No.");
          Quantity := 0;

          ApplyForeignAmountConversion (Rec, (ForeignCurrencyAmount <> 0), ForeignCurrencyAmount);

          //-NPR5.50 [354832]
          ReverseUnrealizedSalesVAT (Rec);
          //+NPR5.50 [354832]

          //-NPR5.49 [345354]
          if Line.Description <> '' then
            Description := Line.Description;
          //+NPR5.49 [345354]

          Return := Insert (true);
        end;

        //-NPR5.32.11
        OnAfterInsertPaymentLine(Rec);
        //+NPR5.32.11

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

        procedure DeleteLine()
    begin

        //-NPR5.37 [293979]
        OnBeforeDeleteLine (Rec);
        //+NPR5.37 [293979]

        //-NPR5.37 [288119]
        if (Rec."EFT Approved") then
          Error (DeleteNotAllowed);
        //+NPR5.37 [288119]

        with Rec do begin
          Delete(true);

          //-NPR5.37 [293979]
          OnAfterDeleteLine (Rec);
          //+NPR5.37 [293979]

          if not Find('><') then;
        end;

        //-NPR5.37 [293979]
        // //-NPR5.32.11
        // OnAfterDeleteLine(Rec);
        // //+NPR5.32.11
        //+NPR5.37 [293979]

        //-NPR5.46 [329523]
        POSSale.RefreshCurrent();
        //+NPR5.46 [329523]
    end;

    local procedure ValidatePaymentLine(Line: Record "Sale Line POS")
    var
        PaymentType: Record "Payment Type POS";
    begin

        if (not GetPaymentType(PaymentType, Line."No.", Line."Register No.")) then
          Error (PaymentType.TableCaption, StrSubstNo ('%1, %2', Line."No.", Line."Register No."));

        if (PaymentType."Account Type" = PaymentType."Account Type"::"G/L Account") then
          PaymentType.TestField (PaymentType."G/L Account No.");

        PaymentType.TestField (Status, PaymentType.Status::Active);
    end;

    local procedure ApplyForeignAmountConversion(var SaleLinePOS: Record "Sale Line POS";PrecalculatedAmount: Boolean;ForeignAmount: Decimal)
    var
        PaymentType: Record "Payment Type POS";
        Functions: Codeunit "Touch Screen - Functions";
        Register: Record Register;
    begin

        with SaleLinePOS do begin
          "Currency Amount" := "Amount Including VAT";

          if (not GetPaymentType(PaymentType, SaleLinePOS."No.", SaleLinePOS."Register No.")) then
            exit;

          if (PaymentType."Fixed Rate" <> 0) then
            "Currency Amount" := "Amount Including VAT" / ( PaymentType."Fixed Rate" / 100 );

          if (PrecalculatedAmount) then
            "Currency Amount" := ForeignAmount;

          if (PaymentType."Fixed Rate" <> 0) then
             Validate( "Amount Including VAT", Round( "Currency Amount" * PaymentType."Fixed Rate" / 100, 0.01, '=' ));
        end
    end;

        local procedure ReverseUnrealizedSalesVAT(var SaleLinePOS: Record "Sale Line POS")
    var
        PaymentType: Record "Payment Type POS";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin

        //-NPR5.50 [354832]
        with SaleLinePOS do begin
          if (not GetPaymentType(PaymentType, "No.", "Register No.")) then
            exit;

          Currency.InitRoundingPrecision();

          if (PaymentType."Reverse Unrealized VAT") then begin
            "Line Amount" := "Amount Including VAT";

              case "VAT Calculation Type" of
                "VAT Calculation Type"::"Reverse Charge VAT",
                "VAT Calculation Type"::"Normal VAT":
                  begin
                    Amount:= Round(("Line Amount") / (1 + "VAT %" / 100), Currency."Amount Rounding Precision");
                    "VAT Base Amount" := Amount;
                  end;

                "VAT Calculation Type"::"Sales Tax":
                  begin
                    TestField("Tax Area Code");
                    Amount := SalesTaxCalculate.ReverseCalculateTax(
                      "Tax Area Code", "Tax Group Code", "Tax Liable", Rec.Date,
                      "Amount Including VAT", "Quantity (Base)", 0);

                    if Amount <> 0 then
                      "VAT %" := Round(100 * ("Amount Including VAT" - Amount) / Amount,0.00001)
                    else
                      "VAT %" := 0;
                    "Amount Including VAT" := Round("Amount Including VAT");
                    Amount := Round(Amount);
                    "VAT Base Amount" := Amount;
                  end;
                else
                  Error (ErrVATCalcNotSupportInPOS, FieldCaption("VAT Calculation Type"), "VAT Calculation Type");
              end;
          end;
        end;
        //+NPR5.50 [354832]
    end;

        procedure GetPaymentType(var PaymentTypePosOut: Record "Payment Type POS";PaymentTypeCode: Code[10];RegisterNo: Code[10]): Boolean
    begin

        if (PaymentTypePosOut.Get (PaymentTypeCode, RegisterNo)) then
          exit (true);

        exit (PaymentTypePosOut.Get (PaymentTypeCode, ''));
    end;

        procedure CalculateMinimumReturnAmount(PaymentTypePOS: Record "Payment Type POS") ret: Decimal
    var
        Kasse: Record Register;
        Betalingsvalg: Record "Payment Type POS";
    begin

        ret := Round (PaymentTypePOS."Rounding Precision" / 2, 0.001, '=');
    end;

        procedure CalculateForeignAmount(PaymentTypePOS: Record "Payment Type POS";AmountLCY: Decimal) Amount: Decimal
    begin

        if (PaymentTypePOS."Fixed Rate" <> 0) then
          Amount := AmountLCY / PaymentTypePOS."Fixed Rate" * 100
        else
          Amount := AmountLCY;
    end;

        procedure CalculateRemainingPaymentSuggestion(SalesAmount: Decimal;PaidAmount: Decimal;PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";AllowNegativePaymentBalance: Boolean): Decimal
    var
        Balance: Decimal;
        ReturnRoundedBalance: Decimal;
        Result: Decimal;
    begin
        //-NPR5.38 [300957]
        Balance := PaidAmount - SalesAmount;

        if (SalesAmount >= 0) and (Balance >= 0) then begin //Paid exact or more.
          //-NPR5.53 [384841]
          if AllowNegativePaymentBalance and (PaymentType."No." = ReturnPaymentType."No.") then
            exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);
          //+NPR5.53 [384841]
          exit(0);
        end;

        if (SalesAmount >= 0) and (Balance < 0) then //Not paid enough.
          exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);

        if (SalesAmount < 0) and (Balance >= 0) then //Not returned enough.
          exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);

        if (SalesAmount < 0) and (Balance < 0) then begin //Returned too much.
          if ReturnPaymentType."Rounding Precision" = 0 then
            Result := Balance
          else begin
            ReturnRoundedBalance := Round(Balance, ReturnPaymentType."Rounding Precision", '=');
            Result := ReturnRoundedBalance + Round(Balance - ReturnRoundedBalance, ReturnPaymentType."Rounding Precision", '=');
          end;
          exit(RoundAmount(ReturnPaymentType, CalculateForeignAmount(ReturnPaymentType, Result)) * -1);
        end;
        //+NPR5.38 [300957]
    end;

        procedure CalculateRemainingPaymentSuggestionInCurrentSale(PaymentTypePOS: Record "Payment Type POS"): Decimal
    var
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        Register: Record Register;
        ReturnPaymentTypePOS: Record "Payment Type POS";
    begin
        //-NPR5.46 [290734]
        if not Initialized then
          exit;

        CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);
        Register.Get(RegisterNo);
        GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", RegisterNo);
        //-NPR5.53 [384841
        exit(CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, PaymentTypePOS, ReturnPaymentTypePOS,false));
        //+NPR5.53 [384841
        //+NPR5.46 [290734]
    end;

        procedure RoundAmount(PaymentTypePOS: Record "Payment Type POS";Amount: Decimal): Decimal
    begin

        if (PaymentTypePOS."Rounding Precision" = 0) then
          exit(Amount);

        //-NPR5.38 [300957]
        if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Foreign Currency" then
          exit (Round(Amount, PaymentTypePOS."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.

        exit (Round(Amount, PaymentTypePOS."Rounding Precision", '='));

        //-NPR5.37.03 [296642]
        // IF Amount = 0 THEN
        //  EXIT(Amount);
        //
        // CASE PaymentTypePOS."Rounding Direction" OF
        //  PaymentTypePOS."Rounding Direction"::Nearest : RoundAmount := (ROUND(Amount, PaymentTypePOS."Rounding Precision", '='));
        //  PaymentTypePOS."Rounding Direction"::Down : RoundAmount := (ROUND(Amount, PaymentTypePOS."Rounding Precision", '<'));
        //  PaymentTypePOS."Rounding Direction"::Up : RoundAmount := (ROUND(Amount, PaymentTypePOS."Rounding Precision", '>'));
        // END;

        // IF (RoundAmount <> 0) OR (Amount < 0) THEN
        //  EXIT(RoundAmount)
        // ELSE
        //  EXIT(PaymentTypePOS."Rounding Precision");
        //+NPR5.38 [300957]

        //EXIT (ROUND(Amount, PaymentTypePOS."Rounding Precision", '='));
        //+NPR5.37.03 [296642]
    end;

    procedure ValidateAmountBeforePayment(PaymentTypePOS: Record "Payment Type POS";AmountToCapture: Decimal)
    begin
        //-NPR5.55 [386254]
        if (PaymentTypePOS."Maximum Amount" <> 0) then
          if (AmountToCapture > PaymentTypePOS."Maximum Amount") then
            Error(MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Maximum Amount");

        if (PaymentTypePOS."Minimum Amount" <> 0) then
          if (AmountToCapture < PaymentTypePOS."Minimum Amount") then
            Error(MinAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Minimum Amount");

        if (PaymentTypePOS."Rounding Precision" <> 0) then
          if (AmountToCapture mod PaymentTypePOS."Rounding Precision") <> 0 then
            Error(InvalidAmount, AmountToCapture, PaymentTypePOS.Description);

        if (PaymentTypePOS."Account Type" = PaymentTypePOS."Account Type"::"G/L Account") then
          PaymentTypePOS.TestField("G/L Account No.");

        if AmountToCapture < 0 then
          PaymentTypePOS.TestField("Allow Refund");

        PaymentTypePOS.TestField(Status, PaymentTypePOS.Status::Active);
        //+NPR5.55 [386254]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPaymentLine(SaleLinePOS: Record "Sale Line POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteLine(var SaleLinePOS: Record "Sale Line POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteLine(SaleLinePOS: Record "Sale Line POS")
    begin
    end;
}

