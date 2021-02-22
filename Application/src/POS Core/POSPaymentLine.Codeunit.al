codeunit 6150707 "NPR POS Payment Line"
{
    var
        Rec: Record "NPR Sale Line POS";
        Sale: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
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

    procedure Init(RegisterNoIn: Code[20]; SalesTicketNoIn: Code[20]; SaleIn: Codeunit "NPR POS Sale"; SetupIn: Codeunit "NPR POS Setup"; FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        Clear(Rec);
        with Rec do begin
            FilterGroup(2);
            SetRange(Type, Type::Payment);
            SetRange("Register No.", RegisterNoIn);
            SetRange("Sales Ticket No.", SalesTicketNoIn);
            FilterGroup(0);
        end;

        Sale.Get(RegisterNoIn, SalesTicketNoIn);

        POSSale := SaleIn;
        Setup := SetupIn;
        FrontEnd := FrontEndIn;

        RegisterNo := RegisterNoIn;
        SalesTicketNo := SalesTicketNoIn;

        Initialized := true;
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        if WithError and (not Initialized) then
            Error('Codeunit POS Payment Line was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
    end;

    procedure ToDataset(CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        DataSet: Codeunit "NPR Data Set";
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
        exit(Rec.Find);
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

    procedure GetCurrentPaymentLine(var PaymentLinePOS: Record "NPR Sale Line POS")
    begin
        RefreshCurrent();

        PaymentLinePOS.Copy(Rec);
    end;

    //ReturnAmount is LEGACY. Cannot calculate true return amount without knowing payment type that is being paid with, to adjust roundings. If you use this incorrectly you will not have equal transactions in both directions (positive/negative) for nearest rounding.
    //Look at how the payment action calculates remaining amount to pay instead of using the parameter in new code.
    procedure CalculateBalance(var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        PaymentLine: Record "NPR Sale Line POS";
        Register: Record "NPR Register";
        RoundingAmount: Decimal;
        Decimal: Decimal;
        DiscountRounding: Decimal;
        i: Integer;
        t001: Label 'You have to set a return payment type on the register.';
        SaleLinePOS: Record "NPR Sale Line POS";
        ReturnRounding: Decimal;
    begin
        if (not Initialized) then
            exit;

        Setup.GetRegisterRecord(Register);
        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;

        SaleLinePOS.SetRange(SaleLinePOS."Register No.", RegisterNo);
        SaleLinePOS.SetRange(SaleLinePOS."Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetFilter(SaleLinePOS.Type, '<>%1', SaleLinePOS.Type::Comment);
        if SaleLinePOS.FindSet then
            repeat
                case true of
                    (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Deposit]):
                        SaleAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment") and (SaleLinePOS."Discount Type" <> SaleLinePOS."Discount Type"::Rounding):
                        SaleAmount -= SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment") and (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Rounding):
                        RoundingAmount += SaleLinePOS."Amount Including VAT";
                    (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment):
                        PaidAmount += SaleLinePOS."Amount Including VAT";
                end;
            until SaleLinePOS.Next = 0;


        Subtotal := SaleAmount - PaidAmount - RoundingAmount;
        ReturnAmount := SaleAmount - PaidAmount - RoundingAmount - ReturnRounding;

        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision > 0) then
            ReturnAmount := Round(ReturnAmount, Setup.AmountRoundingPrecision, Setup.AmountRoundingDirection);
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
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
    end;

    procedure GetPaymentLine(var PaymentLinePOS: Record "NPR Sale Line POS")
    begin
        SetPaymentLineType(PaymentLinePOS);
    end;

    local procedure SetPaymentLineType(var PaymentLinePOS: Record "NPR Sale Line POS")
    begin
        with PaymentLinePOS do begin
            "Register No." := Sale."Register No.";
            "Sales Ticket No." := Sale."Sales Ticket No.";
            Date := Sale.Date;
            "Sale Type" := "Sale Type"::Payment;
            Type := Type::Payment;
        end;
    end;

    procedure InsertPaymentLine(Line: Record "NPR Sale Line POS"; ForeignCurrencyAmount: Decimal) Return: Boolean
    begin

        ValidatePaymentLine(Line);

        with Rec do begin
            InitLine();
            Rec.TransferFields(Line, false);
            SetPaymentLineType(Rec);

            Validate("No.", Line."No.");
            Quantity := 0;

            ApplyForeignAmountConversion(Rec, (ForeignCurrencyAmount <> 0), ForeignCurrencyAmount);
            ReverseUnrealizedSalesVAT(Rec);

            if Line.Description <> '' then
                Description := Line.Description;

            Return := Insert(true);
        end;

        OnAfterInsertPaymentLine(Rec);
        POSSale.RefreshCurrent();
    end;

    procedure DeleteLine()
    begin
        OnBeforeDeleteLine(Rec);

        if (Rec."EFT Approved") then
            Error(DeleteNotAllowed);

        with Rec do begin
            Delete(true);
            OnAfterDeleteLine(Rec);

            if not Find('><') then;
        end;

        POSSale.RefreshCurrent();
    end;

    local procedure ValidatePaymentLine(Line: Record "NPR Sale Line POS")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        if not POSPaymentMethod.Get(Line."No.") then
            Error(POSPaymentMethod.TableCaption, StrSubstNo('%1, %2', Line."No.", Line."Register No."));

        if (POSPaymentMethod."Account Type" = POSPaymentMethod."Account Type"::"G/L Account") then
            POSPaymentMethod.TestField("Account No.");

        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    local procedure ApplyForeignAmountConversion(var SaleLinePOS: Record "NPR Sale Line POS"; PrecalculatedAmount: Boolean; ForeignAmount: Decimal)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        Register: Record "NPR Register";
    begin

        with SaleLinePOS do begin
            "Currency Amount" := "Amount Including VAT";

            if not POSPaymentMethod.Get(SaleLinePOS."No.") then
                exit;

            if (POSPaymentMethod."Fixed Rate" <> 0) then
                "Currency Amount" := "Amount Including VAT" / (POSPaymentMethod."Fixed Rate" / 100);

            if (PrecalculatedAmount) then
                "Currency Amount" := ForeignAmount;

            if (POSPaymentMethod."Fixed Rate" <> 0) then
                Validate("Amount Including VAT", Round("Currency Amount" * POSPaymentMethod."Fixed Rate" / 100, 0.01, POSPaymentMethod.GetRoundingType()));
        end
    end;

    local procedure ReverseUnrealizedSalesVAT(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin

        with SaleLinePOS do begin
            if not POSPaymentMethod.Get("No.") then
                exit;

            Currency.InitRoundingPrecision();

            if (POSPaymentMethod."Reverse Unrealized VAT") then begin
                "Line Amount" := "Amount Including VAT";

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Reverse Charge VAT",
                    "VAT Calculation Type"::"Normal VAT":
                        begin
                            Amount := Round(("Line Amount") / (1 + "VAT %" / 100), Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                        end;

                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            TestField("Tax Area Code");
                            Amount := SalesTaxCalculate.ReverseCalculateTax(
                              "Tax Area Code", "Tax Group Code", "Tax Liable", Rec.Date,
                              "Amount Including VAT", "Quantity (Base)", 0);

                            if Amount <> 0 then
                                "VAT %" := Round(100 * ("Amount Including VAT" - Amount) / Amount, 0.00001)
                            else
                                "VAT %" := 0;
                            "Amount Including VAT" := Round("Amount Including VAT");
                            Amount := Round(Amount);
                            "VAT Base Amount" := Amount;
                        end;
                    else
                        Error(ErrVATCalcNotSupportInPOS, FieldCaption("VAT Calculation Type"), "VAT Calculation Type");
                end;
            end;
        end;
    end;

    procedure GetPOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentTypeCode: Code[10]): Boolean
    begin
        exit(POSPaymentMethod.Get(PaymentTypeCode));
    end;


    procedure CalculateForeignAmount(POSPaymentMethod: Record "NPR POS Payment Method"; AmountLCY: Decimal) Amount: Decimal
    begin

        if (POSPaymentMethod."Fixed Rate" <> 0) then
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
    begin

        if (POSPaymentMethod."Rounding Precision" = 0) then
            exit(Amount);

        if POSPaymentMethod."Currency Code" <> '' then
            exit(Round(Amount, POSPaymentMethod."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.

        exit(Round(Amount, POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType()));
    end;

    procedure ValidateAmountBeforePayment(POSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal)
    begin
        if (POSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > POSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Maximum Amount");

        if (POSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < POSPaymentMethod."Minimum Amount") then
                Error(MinAmountLimit, POSPaymentMethod.Description, POSPaymentMethod."Minimum Amount");

        if (POSPaymentMethod."Rounding Precision" <> 0) then
            if (AmountToCapture mod POSPaymentMethod."Rounding Precision") <> 0 then
                Error(InvalidAmount, AmountToCapture, POSPaymentMethod.Description);

        if AmountToCapture < 0 then
            POSPaymentMethod.TestField("Allow Refund");

        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPaymentLine(SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteLine(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteLine(SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;
}

