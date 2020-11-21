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

    procedure CalculateBalance(var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        PaymentLine: Record "NPR Sale Line POS";
        PaymentType: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        RetailCode: Codeunit "NPR Retail Form Code";
        Functions: Codeunit "NPR Touch Screen - Func.";
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
        if (not GetPaymentType(PaymentType, Register."Return Payment Type", Register."Register No.")) then
            Error(t001);

        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;

        with SaleLinePOS do begin
            SetRange("Register No.", RegisterNo);
            SetRange("Sales Ticket No.", SalesTicketNo);
            SetFilter(Type, '<>%1', Type::Comment);
            if FindSet then
                repeat
                    case true of
                        ("Sale Type" in ["Sale Type"::Sale, "Sale Type"::Deposit]):
                            SaleAmount += "Amount Including VAT";
                        ("Sale Type" = "Sale Type"::"Out payment") and ("Discount Type" <> "Discount Type"::Rounding):
                            SaleAmount -= "Amount Including VAT";
                        ("Sale Type" = "Sale Type"::"Out payment") and ("Discount Type" = "Discount Type"::Rounding):
                            RoundingAmount += "Amount Including VAT";
                        ("Sale Type" = "Sale Type"::Payment):
                            PaidAmount += "Amount Including VAT";
                    end;
                until Next = 0;
        end;

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
        PaymentType: Record "NPR Payment Type POS";
    begin

        if (not GetPaymentType(PaymentType, Line."No.", Line."Register No.")) then
            Error(PaymentType.TableCaption, StrSubstNo('%1, %2', Line."No.", Line."Register No."));

        if (PaymentType."Account Type" = PaymentType."Account Type"::"G/L Account") then
            PaymentType.TestField(PaymentType."G/L Account No.");

        PaymentType.TestField(Status, PaymentType.Status::Active);
    end;

    local procedure ApplyForeignAmountConversion(var SaleLinePOS: Record "NPR Sale Line POS"; PrecalculatedAmount: Boolean; ForeignAmount: Decimal)
    var
        PaymentType: Record "NPR Payment Type POS";
        Functions: Codeunit "NPR Touch Screen - Func.";
        Register: Record "NPR Register";
    begin

        with SaleLinePOS do begin
            "Currency Amount" := "Amount Including VAT";

            if (not GetPaymentType(PaymentType, SaleLinePOS."No.", SaleLinePOS."Register No.")) then
                exit;

            if (PaymentType."Fixed Rate" <> 0) then
                "Currency Amount" := "Amount Including VAT" / (PaymentType."Fixed Rate" / 100);

            if (PrecalculatedAmount) then
                "Currency Amount" := ForeignAmount;

            if (PaymentType."Fixed Rate" <> 0) then
                Validate("Amount Including VAT", Round("Currency Amount" * PaymentType."Fixed Rate" / 100, 0.01, '='));
        end
    end;

    local procedure ReverseUnrealizedSalesVAT(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        PaymentType: Record "NPR Payment Type POS";
        Currency: Record Currency;
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin

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

    procedure GetPaymentType(var PaymentTypePosOut: Record "NPR Payment Type POS"; PaymentTypeCode: Code[10]; RegisterNo: Code[10]): Boolean
    begin

        if (PaymentTypePosOut.Get(PaymentTypeCode, RegisterNo)) then
            exit(true);

        exit(PaymentTypePosOut.Get(PaymentTypeCode, ''));
    end;

    procedure CalculateMinimumReturnAmount(PaymentTypePOS: Record "NPR Payment Type POS") ret: Decimal
    var
        Kasse: Record "NPR Register";
        Betalingsvalg: Record "NPR Payment Type POS";
    begin

        ret := Round(PaymentTypePOS."Rounding Precision" / 2, 0.001, '=');
    end;

    procedure CalculateForeignAmount(PaymentTypePOS: Record "NPR Payment Type POS"; AmountLCY: Decimal) Amount: Decimal
    begin

        if (PaymentTypePOS."Fixed Rate" <> 0) then
            Amount := AmountLCY / PaymentTypePOS."Fixed Rate" * 100
        else
            Amount := AmountLCY;
    end;

    procedure CalculateRemainingPaymentSuggestion(SalesAmount: Decimal; PaidAmount: Decimal; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; AllowNegativePaymentBalance: Boolean): Decimal
    var
        Balance: Decimal;
        ReturnRoundedBalance: Decimal;
        Result: Decimal;
    begin
        Balance := PaidAmount - SalesAmount;

        if (SalesAmount >= 0) and (Balance >= 0) then begin //Paid exact or more.
            if AllowNegativePaymentBalance and (PaymentType."No." = ReturnPaymentType."No.") then
                exit(RoundAmount(PaymentType, CalculateForeignAmount(PaymentType, Balance)) * -1);
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
    end;

    procedure CalculateRemainingPaymentSuggestionInCurrentSale(PaymentTypePOS: Record "NPR Payment Type POS"): Decimal
    var
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        Register: Record "NPR Register";
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
    begin
        if not Initialized then
            exit;

        CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, SubTotal);
        Register.Get(RegisterNo);
        GetPaymentType(ReturnPaymentTypePOS, Register."Return Payment Type", RegisterNo);
        exit(CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, PaymentTypePOS, ReturnPaymentTypePOS, false));
    end;

    procedure RoundAmount(PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal): Decimal
    begin

        if (PaymentTypePOS."Rounding Precision" = 0) then
            exit(Amount);

        if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Foreign Currency" then
            exit(Round(Amount, PaymentTypePOS."Rounding Precision", '>')); //Amount is not in LCY - Round up to avoid hitting a value causing LCY loss.

        exit(Round(Amount, PaymentTypePOS."Rounding Precision", '='));
    end;

    procedure ValidateAmountBeforePayment(PaymentTypePOS: Record "NPR Payment Type POS"; AmountToCapture: Decimal)
    begin
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

