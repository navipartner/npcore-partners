codeunit 6150634 "NPR POS Give Change"
{
    var
        TextNoReturnPaymentType: Label 'Setup missing: no %1 could be found to give the customer change in. ', Comment = '%1=POSPaymentMethod.TableCaption()';
        TextChange: Label 'Change';
        POSSetup: Codeunit "NPR POS Setup";

    procedure InsertChange(SalePOS: Record "NPR POS Sale"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; Balance: Decimal) ChangeToGive: Decimal
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

    procedure CalcAndInsertChange(var SalePOS: Record "NPR POS Sale") ChangeToGive: Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
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

    local procedure InsertOutPaymentLine(var SalePOS: Record "NPR POS Sale"; AmountIn: Decimal; NoIn: Code[10]; DescriptionIn: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := SalePOS.Date;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Payment;
        SaleLinePOS."Line No." := GetLastLineNo(SalePOS) + 10000;
        SaleLinePOS.Insert(true);
        SaleLinePOS."Location Code" := SalePOS."Location Code";
        SaleLinePOS.Reference := SalePOS.Reference;
        SaleLinePOS.Type := SaleLinePOS.Type::Payment;
        SaleLinePOS."No." := NoIn;
        SaleLinePOS.Description := DescriptionIn;
        SaleLinePOS."Amount Including VAT" := AmountIn;
        SaleLinePOS."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        SaleLinePOS."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        SaleLinePOS."Dimension Set ID" := SalePOS."Dimension Set ID";
        SaleLinePOS.Modify(true);
    end;

    local procedure GetReturnPaymentType(SalePOS: Record "NPR POS Sale"): Code[10]
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentMethod.Reset();
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::CASH);
        POSPaymentMethod.SetRange("Block POS Payment", false);
        POSPaymentMethod.SetRange(Code, POSPaymentMethod."Return Payment Method Code");
        if POSPaymentMethod.FindFirst() then
            exit(POSPaymentMethod.Code);

        Error(TextNoReturnPaymentType, POSPaymentMethod.TableCaption());
    end;

    local procedure GetRoundingAmount(SalePOS: Record "NPR POS Sale"; ChangeAmount: Decimal): Decimal
    begin
        SetPOSSetupPOSUnitContext(SalePOS."POS Store Code");
        if (POSSetup.AmountRoundingPrecision() = 0) or (POSSetup.RoundingAccount(false) = '') then
            exit(0);
        exit(ChangeAmount - Round(ChangeAmount, POSSetup.AmountRoundingPrecision, POSSetup.AmountRoundingDirection));
    end;

    local procedure GetLastLineNo(SalePOS: Record "NPR POS Sale"): Integer
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast() then;
        exit(SaleLinePOS."Line No.");
    end;

    local procedure GetSaleAmountInclTax(SalePOS: Record "NPR POS Sale"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalAmount: Decimal;
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        if SaleLinePOS.FindSet() then
            repeat
                TotalAmount := TotalAmount + SaleLinePOS."Amount Including VAT";
            until SaleLinePOS.Next() = 0;

        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        if SaleLinePOS.FindSet() then
            repeat
                TotalAmount := TotalAmount + SaleLinePOS."Amount Including VAT";
            until SaleLinePOS.Next() = 0;

        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::"Out payment");
        if SaleLinePOS.FindSet() then
            repeat
                TotalAmount := TotalAmount - SaleLinePOS."Amount Including VAT";
            until SaleLinePOS.Next() = 0;
        exit(TotalAmount);
    end;

    local procedure GetPaymentAmount(SalePOS: Record "NPR POS Sale"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalAmount: Decimal;
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Payment);
        if SaleLinePOS.FindSet() then
            repeat
                TotalAmount := TotalAmount + SaleLinePOS."Amount Including VAT";
            until SaleLinePOS.Next() = 0;
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

