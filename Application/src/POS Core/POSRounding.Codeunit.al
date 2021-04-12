codeunit 6150636 "NPR POS Rounding"
{
    procedure InsertRounding(SalePOS: Record "NPR POS Sale"; RoundAmount: Decimal) InsertedRounding: Decimal
    var
        GLAccount: Record "G/L Account";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
    begin

        if RoundAmount = 0 then
            exit(0);

        RoundAmount *= -1; //Is out payment line

        POSUnit.Get(SalePOS."Register No.");
        POSSetup.SetPOSUnit(POSUnit);
        GLAccount.Get(POSSetup.RoundingAccount(true));
        InsertLine(SalePOS, GLAccount, RoundAmount);

        exit(RoundAmount);
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

    local procedure InsertLine(SalePOS: Record "NPR POS Sale"; GLAccount: Record "G/L Account"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Init();
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

