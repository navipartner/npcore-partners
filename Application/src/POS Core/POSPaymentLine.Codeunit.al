codeunit 6150707 "NPR POS Payment Line"
{
    var
        Rec: Record "NPR POS Sale Line";
        Sale: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        RegisterNo: Code[20];
        SalesTicketNo: Code[20];
        DeleteNotAllowed: Label 'Payments approved by a 3-party must be cancelled, not deleted.';
        Initialized: Boolean;
        ErrVATCalcNotSupportInPOS: Label '%1 %2 not supported in POS';
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        InvalidAmount: Label 'Amount %1 is not valid for payment type %2';

    procedure Init(RegisterNoIn: Code[20]; SalesTicketNoIn: Code[20]; SaleIn: Codeunit "NPR POS Sale"; SetupIn: Codeunit "NPR POS Setup"; FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        Clear(Rec);
        Rec.FilterGroup(2);
        Rec.SetRange(Type, Rec.Type::Payment);
        Rec.SetRange("Register No.", RegisterNoIn);
        Rec.SetRange("Sales Ticket No.", SalesTicketNoIn);
        Rec.FilterGroup(0);

        Sale.Get(RegisterNoIn, SalesTicketNoIn);

        POSSale := SaleIn;
        Setup := SetupIn;
        FrontEnd := FrontEndIn;

        RegisterNo := RegisterNoIn;
        SalesTicketNo := SalesTicketNoIn;

        Initialized := true;
    end;

    procedure ToDataset(CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
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

    procedure GetCurrentPaymentLine(var PaymentLinePOS: Record "NPR POS Sale Line")
    begin
        RefreshCurrent();

        PaymentLinePOS.Copy(Rec);
    end;

    //ReturnAmount is LEGACY. Cannot calculate true return amount without knowing payment type that is being paid with, to adjust roundings. If you use this incorrectly you will not have equal transactions in both directions (positive/negative) for nearest rounding.
    //Look at how the payment action calculates remaining amount to pay instead of using the parameter in new code.
    procedure CalculateBalance(var SaleAmount: Decimal; var PaidAmount: Decimal; var ReturnAmount: Decimal; var Subtotal: Decimal)
    var
        POSUnit: Record "NPR POS Unit";
        RoundingAmount: Decimal;
        SaleLinePOS: Record "NPR POS Sale Line";
        ReturnRounding: Decimal;
    begin
        if (not Initialized) then
            exit;

        Setup.GetPOSUnit(POSUnit);
        SaleAmount := 0;
        PaidAmount := 0;
        ReturnAmount := 0;
        Subtotal := 0;

        SaleLinePOS.SetRange(SaleLinePOS."Register No.", RegisterNo);
        SaleLinePOS.SetRange(SaleLinePOS."Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetFilter(SaleLinePOS.Type, '<>%1', SaleLinePOS.Type::Comment);
        if SaleLinePOS.FindSet() then
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
            until SaleLinePOS.Next() = 0;


        Subtotal := SaleAmount - PaidAmount - RoundingAmount;
        ReturnAmount := SaleAmount - PaidAmount - RoundingAmount - ReturnRounding;

        if (ReturnAmount < 0) and (Setup.RoundingAccount(false) <> '') and (Setup.AmountRoundingPrecision() > 0) then
            ReturnAmount := Round(ReturnAmount, Setup.AmountRoundingPrecision(), Setup.AmountRoundingDirection());
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
        PaymentLinePOS."Sale Type" := PaymentLinePOS."Sale Type"::Payment;
        PaymentLinePOS.Type := PaymentLinePOS.Type::Payment;
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
    begin
        OnBeforeDeleteLine(Rec);

        if (Rec."EFT Approved") then
            Error(DeleteNotAllowed);

        Rec.Delete(true);
        OnAfterDeleteLine(Rec);

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
    begin
        SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT";

        if not POSPaymentMethod.Get(SaleLinePOS."No.") then
            exit;

        if (POSPaymentMethod."Fixed Rate" <> 0) then
            SaleLinePOS."Currency Amount" := SaleLinePOS."Amount Including VAT" / (POSPaymentMethod."Fixed Rate" / 100);

        if (PrecalculatedAmount) then
            SaleLinePOS."Currency Amount" := ForeignAmount;

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

