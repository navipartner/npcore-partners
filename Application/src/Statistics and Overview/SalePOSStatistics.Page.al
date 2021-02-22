page 6014410 "NPR Sale POS - Statistics"
{
    UsageCategory = None;
    Caption = 'Sales Statistics';
    SourceTable = "NPR Sale POS";

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
        SaleLinePOS: Record "NPR Sale Line POS";
        InsuranceCompanyCode: Code[50];
        RegisterNo: Code[20];
        DG: Decimal;
        DB: Decimal;
        CostPrice: Decimal;
        Netto: Decimal;
        SalesPrice: Decimal;
        DiscountAmt: Decimal;
        InvoiceDiscountAmt: Decimal;
        InvoiceFee: Decimal;
        InsuranceCost: Decimal;
        InsuranceProfit: Decimal;
        AverageAuditRollSaleAmt: Decimal;
        NoOfAuditRollRecords: Integer;
        Utility: Codeunit "NPR Receipt Footer Mgt.";

    procedure EnableMenu()
    begin
        CalculatePotentialInvoiceDiscount(Rec);
    end;

    procedure SaleLineStatistics()
    begin
        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Date);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);

        SalesPrice := 0;
        CostPrice := 0;
        DiscountAmt := 0;
        Netto := 0;
        RegisterNo := "Register No.";

        if SaleLinePOS.Find('-') then
            repeat
                SalesPrice += SaleLinePOS."Amount Including VAT";
                CostPrice += SaleLinePOS.Cost;
                DiscountAmt += SaleLinePOS."Discount Amount";
                Netto += SaleLinePOS.Amount;
            until SaleLinePOS.Next = 0;

        DB := Netto - CostPrice;
        if Netto <> 0 then
            DG := DB * 100 / Netto
        else
            DG := 0;

        CalculateSaleLineNoAmount("Register No.", Date);
    end;

    procedure CalculatePotentialInvoiceDiscount(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS2: Record "NPR Sale Line POS";
        Customer: Record Customer;
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        InvoiceDiscountBaseAmt: Decimal;
        FeeBaseAmount: Decimal;
        CurrencyFactor: Decimal;
        CurrencyDate: Date;
    begin
        InvoiceDiscountAmt := 0;
        InvoiceFee := 0;

        if Customer.Get("Customer No.") then begin
            SaleLinePOS2.Reset;
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
                until SaleLinePOS2.Next = 0;

            CustInvoiceDisc.SetRange(Code, Customer."Invoice Disc. Code");
            CustInvoiceDisc.SetRange("Currency Code", Customer."Currency Code");
            CustInvoiceDisc.SetRange("Minimum Amount", 0, FeeBaseAmount);
            if not CustInvoiceDisc.Find('+') then
                if Customer."Currency Code" <> '' then begin
                    CurrencyDate := WorkDate;
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
                InvoiceFee += CustInvoiceDisc."Service Charge";
            end;

            CustInvoiceDisc.SetRange(Code, Customer."Invoice Disc. Code");
            CustInvoiceDisc.SetRange("Currency Code", Customer."Currency Code");
            CustInvoiceDisc.SetRange("Minimum Amount", 0, InvoiceDiscountBaseAmt);
            if not CustInvoiceDisc.Find('+') then
                if Customer."Currency Code" <> '' then begin
                    CurrencyDate := WorkDate;
                    CurrencyFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, Customer."Currency Code");
                    CustInvoiceDisc.SetRange("Currency Code", '');
                    CustInvoiceDisc.SetRange("Minimum Amount", 0, CurrencyExchangeRate.ExchangeAmtFCYToLCY(CurrencyDate, Customer."Currency Code",
                      InvoiceDiscountBaseAmt, CurrencyFactor));
                    if not CustInvoiceDisc.Find('+') then
                        Clear(CustInvoiceDisc);
                end else
                    Clear(CustInvoiceDisc);
            if CustInvoiceDisc."Discount %" <> 0 then begin
                SaleLinePOS2.SetRange("Allow Invoice Discount", true);
                if SaleLinePOS2.Find('-') then
                    repeat
                        if SaleLinePOS2.Quantity <> 0 then
                            InvoiceDiscountAmt += Round(SaleLinePOS2.Amount * CustInvoiceDisc."Discount %" / 100, 0.00001);
                    until SaleLinePOS2.Next = 0;
            end;
        end;
    end;

    procedure CalculateSaleLineNoAmount(RegisterFilter: Text[250]; CalculationDate: Date)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        if RegisterFilter <> '' then
            PaymentTypePOS.SetFilter("Register Filter", RegisterFilter)
        else
            PaymentTypePOS.SetRange("Register Filter");

        if CalculationDate <> 0D then
            PaymentTypePOS.SetRange("Date Filter", CalculationDate)
        else
            PaymentTypePOS.SetRange("Date Filter");

        PaymentTypePOS.CalcFields("No. of Sales in Audit Roll", "Normal Sale in Audit Roll", "No. of Deb. Sales in Aud. Roll",
          "Debit Sale in Audit Roll");
        NoOfAuditRollRecords := PaymentTypePOS."No. of Sales in Audit Roll";
        NoOfAuditRollRecords += PaymentTypePOS."No. of Deb. Sales in Aud. Roll";
        if NoOfAuditRollRecords <> 0 then
            AverageAuditRollSaleAmt := (PaymentTypePOS."Normal Sale in Audit Roll" + PaymentTypePOS."Debit Sale in Audit Roll") / NoOfAuditRollRecords
        else
            AverageAuditRollSaleAmt := 0;
    end;

    procedure Initialize(StatMenu: Integer)
    begin
        FilterGroup(2);
        SetRange("Register No.", "Register No.");
        SetRange("Sales Ticket No.", "Sales Ticket No.");
        SetRange(Date, Date);
        FilterGroup(0);

        EnableMenu;
        SaleLineStatistics;
    end;

}

