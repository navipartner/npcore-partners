page 6014410 "NPR Sale POS - Statistics"
{
    UsageCategory = None;
    Caption = 'Sales Statistics';
    SourceTable = "NPR POS Sale";

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
    }

    var
        SaleLinePOS: Record "NPR POS Sale Line";

    procedure EnableMenu()
    begin
        CalculatePotentialInvoiceDiscount(Rec);
    end;

    procedure SaleLineStatistics()
    begin
        SaleLinePOS.SetRange("Register No.", Rec."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Rec.Date);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);


        if SaleLinePOS.Find('-') then
            repeat
            until SaleLinePOS.Next() = 0;


    end;

    procedure CalculatePotentialInvoiceDiscount(var SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        Customer: Record Customer;
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        InvoiceDiscountBaseAmt: Decimal;
        FeeBaseAmount: Decimal;
        CurrencyFactor: Decimal;
        CurrencyDate: Date;
    begin

        if Customer.Get(Rec."Customer No.") then begin
            SaleLinePOS2.Reset();
            SaleLinePOS2.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS2.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS2.SetRange(Date, SalePOS.Date);
            SaleLinePOS2.SetRange("Sale Type", SaleLinePOS2."Sale Type"::Sale);

            InvoiceDiscountBaseAmt := 0;
            FeeBaseAmount := 0;
            if SaleLinePOS2.Find('-') then
                repeat
                    if SaleLinePOS2."Allow Invoice Discount" then begin
                        InvoiceDiscountBaseAmt += SaleLinePOS2.Amount + SaleLinePOS2."Invoice Discount Amount";
                        FeeBaseAmount += SaleLinePOS2.Amount + SaleLinePOS2."Invoice Discount Amount";
                    end;
                until SaleLinePOS2.Next() = 0;

            CustInvoiceDisc.SetRange(Code, Customer."Invoice Disc. Code");
            CustInvoiceDisc.SetRange("Currency Code", Customer."Currency Code");
            CustInvoiceDisc.SetRange("Minimum Amount", 0, FeeBaseAmount);
            if not CustInvoiceDisc.Find('+') then
                if Customer."Currency Code" <> '' then begin
                    CurrencyDate := WorkDate();
                    CurrencyFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, Customer."Currency Code");

                    CustInvoiceDisc.SetRange("Currency Code", '');
                    CustInvoiceDisc.SetRange("Minimum Amount", 0,
                      CurrencyExchangeRate.ExchangeAmtFCYToLCY(CurrencyDate, Customer."Currency Code", FeeBaseAmount, CurrencyFactor));
                    if not CustInvoiceDisc.Find('+') then
                        exit;
                    Currency.Get(Customer."Currency Code");
                    CustInvoiceDisc."Service Charge" := Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(CurrencyDate, Customer."Currency Code",
                      CustInvoiceDisc."Service Charge", CurrencyFactor), Currency."Amount Rounding Precision");
                end else
                    exit;

            if CustInvoiceDisc."Service Charge" <> 0 then begin
            end;

            CustInvoiceDisc.SetRange(Code, Customer."Invoice Disc. Code");
            CustInvoiceDisc.SetRange("Currency Code", Customer."Currency Code");
            CustInvoiceDisc.SetRange("Minimum Amount", 0, InvoiceDiscountBaseAmt);
            if not CustInvoiceDisc.Find('+') then
                if Customer."Currency Code" <> '' then begin
                    CurrencyDate := WorkDate();
                    CurrencyFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, Customer."Currency Code");
                    CustInvoiceDisc.SetRange("Currency Code", '');
                    CustInvoiceDisc.SetRange("Minimum Amount", 0, CurrencyExchangeRate.ExchangeAmtFCYToLCY(CurrencyDate, Customer."Currency Code",
                      InvoiceDiscountBaseAmt, CurrencyFactor));
                    if not CustInvoiceDisc.Find('+') then
                        Clear(CustInvoiceDisc);
                end else
                    Clear(CustInvoiceDisc);
        end;
    end;

    procedure Initialize(StatMenu: Integer)
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Register No.", Rec."Register No.");
        Rec.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        Rec.SetRange(Date, Rec.Date);
        Rec.FilterGroup(0);

        EnableMenu();
        SaleLineStatistics();
    end;

}

