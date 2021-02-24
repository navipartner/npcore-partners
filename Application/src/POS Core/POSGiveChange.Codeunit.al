codeunit 6150634 "NPR POS Give Change"
{
    trigger OnRun()
    begin
    end;

    var
        TextNoReturnPaymentType: Label 'Setup missing: no %1 could be found to give the customer change in. ';
        TextChange: Label 'Change';
        POSSetup: Codeunit "NPR POS Setup";

    procedure InsertChange(SalePOS: Record "NPR Sale POS"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; Balance: Decimal) ChangeToGive: Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        RoundedBalance: Decimal;
    begin
        RoundedBalance := POSPaymentLine.RoundAmount(ReturnPOSPaymentMethod, Balance);
        ChangeToGive := RoundedBalance + POSPaymentLine.RoundAmount(ReturnPOSPaymentMethod, Balance - RoundedBalance);

        if ChangeToGive = 0 then
            exit(0);

        InsertOutPaymentLine(SalePOS, -ChangeToGive, ReturnPOSPaymentMethod.Code, TextChange);
        exit(ChangeToGive);
    end;

    procedure CalcAndInsertChange(var SalePOS: Record "NPR Sale POS") ChangeToGive: Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
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

        RoundingAmount := GetRoundingAmount(SalePOS, PaymentAmount - SaleAmount);
        if (Abs(SaleAmount) + Abs(RoundingAmount)) = Abs(PaymentAmount) then
            exit;

        InsertOutPaymentLine(SalePOS, -(PaymentAmount - SaleAmount - RoundingAmount), GetReturnPaymentType(SalePOS), TextChange);
        exit((PaymentAmount - SaleAmount - RoundingAmount));
    end;

    local procedure "--- Helper functions"()
    begin
    end;

    local procedure InsertOutPaymentLine(var SalePOS: Record "NPR Sale POS"; AmountIn: Decimal; NoIn: Code[10]; DescriptionIn: Text)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        with SaleLinePOS do begin
            Init;
            "Register No." := SalePOS."Register No.";
            "Sales Ticket No." := SalePOS."Sales Ticket No.";
            Date := SalePOS.Date;
            "Sale Type" := "Sale Type"::Payment;
            "Line No." := GetLastLineNo(SalePOS) + 10000;
            Insert(true);
            "Location Code" := SalePOS."Location Code";
            Reference := SalePOS.Reference;
            Type := Type::Payment;
            "No." := NoIn;
            Description := DescriptionIn;
            "Amount Including VAT" := AmountIn;
            "Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
            "Dimension Set ID" := SalePOS."Dimension Set ID";
            Modify(true);
        end;
    end;

    local procedure GetReturnPaymentType(SalePOS: Record "NPR Sale POS"): Code[10]
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(SalePOS."Register No.");

        POSPaymentMethod.Reset();
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::CASH);
        POSPaymentMethod.SetRange("Block POS Payment", false);
        POSPaymentMethod.SetRange(Code, POSPaymentMethod."Return Payment Method Code");
        if POSPaymentMethod.FindFirst then
            exit(POSPaymentMethod.Code);

        Error(TextNoReturnPaymentType, POSPaymentMethod.TableCaption);
    end;

    local procedure GetRoundingAmount(SalePOS: Record "NPR Sale POS"; ChangeAmount: Decimal): Decimal
    begin
        SetPOSSetupPOSUnitContext(SalePOS."Register No.");
        if (POSSetup.AmountRoundingPrecision = 0) or (POSSetup.RoundingAccount(false) = '') then
            exit(0);
        exit(ChangeAmount - Round(ChangeAmount, POSSetup.AmountRoundingPrecision, POSSetup.AmountRoundingDirection));
    end;

    local procedure GetLastLineNo(SalePOS: Record "NPR Sale POS"): Integer
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        with SaleLinePOS do begin
            SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
            SetRange("Register No.", SalePOS."Register No.");
            SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if SaleLinePOS.FindLast then;
            exit(SaleLinePOS."Line No.");
        end;
    end;

    local procedure GetSaleAmountInclTax(SalePOS: Record "NPR Sale POS"): Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TotalAmount: Decimal;
    begin
        with SaleLinePOS do begin
            SetRange("Register No.", SalePOS."Register No.");
            SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SetRange(Date, SalePOS.Date);
            SetRange("Sale Type", "Sale Type"::Sale);
            if FindSet then
                repeat
                    TotalAmount := TotalAmount + "Amount Including VAT";
                until Next = 0;

            SetRange("Sale Type", "Sale Type"::Deposit);
            if FindSet then
                repeat
                    TotalAmount := TotalAmount + "Amount Including VAT";
                until Next = 0;

            SetRange("Sale Type", "Sale Type"::"Out payment");
            if FindSet then
                repeat
                    TotalAmount := TotalAmount - "Amount Including VAT";
                until Next = 0;
        end;
        exit(TotalAmount);
    end;

    local procedure GetPaymentAmount(SalePOS: Record "NPR Sale POS"): Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TotalAmount: Decimal;
    begin
        with SaleLinePOS do begin
            SetRange("Register No.", SalePOS."Register No.");
            SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SetRange(Date, SalePOS.Date);
            SetRange("Sale Type", "Sale Type"::Payment);
            if FindSet then
                repeat
                    TotalAmount := TotalAmount + "Amount Including VAT";
                until Next = 0;
        end;
        exit(TotalAmount);
    end;

    local procedure SetPOSSetupPOSUnitContext(POSUnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(POSUnitNo);
        POSSetup.SetPOSUnit(POSUnit);
    end;
}

