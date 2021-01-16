page 6014410 "NPR Sale POS - Statistics"
{
    // NPR4.12/JDH/20150703 CASE 217884 Caption changed
    // NPR5.35/TJ /20170823 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                  Removed unused variables
    // NPR5.40/BHR /20180316 CASE 308385 Removed unused function CallSub

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
        RetailContractSetup: Record "NPR Retail Contr. Setup";
        RetailContractMgt: Codeunit "NPR Retail Contract Mgt.";
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
        Utility: Codeunit "NPR Utility";

    procedure EnableMenu()
    begin
        //EnableMenu

        //CurrForm.CAPTION("Eksp. Caption");
        CalculatePotentialInvoiceDiscount(Rec);
    end;

    procedure SaleLineStatistics()
    begin
        //SaleLineStatistics
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

        if RetailContractSetup.Get then begin
            InsuranceCost := RetailContractMgt.CalcInsCost(Rec, InsuranceCompanyCode);
            InsuranceProfit := RetailContractMgt.GetInsuranceProfit;
            ShowFoto(true);
        end else
            ShowFoto(false);
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
        //CalculatePotentialInvoiceDiscount
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
        //CalculateSaleLineNoAmount
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
        //OnInit
        FilterGroup(2);
        SetRange("Register No.", "Register No.");
        SetRange("Sales Ticket No.", "Sales Ticket No.");
        SetRange(Date, Date);
        FilterGroup(0);
        if RetailContractSetup.Get then
            InsuranceCompanyCode := RetailContractSetup."Default Insurance Company";

        //CurrForm.Kassenummer.VISIBLE( TRUE );
        EnableMenu;
        SaleLineStatistics;
    end;

    procedure ShowFoto(Show: Boolean)
    begin
        //CurrForm.Forsikringsselskab.VISIBLE( Show );
        //CurrForm.Forsikringssum.VISIBLE( Show );
        //CurrForm.Forsikringsavance.VISIBLE( Show );
        //CurrForm.txtForsikringsselskab.VISIBLE( Show );
        //CurrForm.txtForsikringssum.VISIBLE( Show );
        //CurrForm.txtForsikringsavance.VISIBLE( Show );
    end;

    procedure GetSaleLineStat(var NPRTempBuffer: Record "NPR TEMP Buffer")
    var
        Txt001: Label 'Gross price total';
        Txt002: Label 'Discount';
        Txt003: Label 'Profit incl. VAT';
        Txt008: Label 'Invoice discount';
        Txt009: Label 'Invoice fee';
        Txt010: Label 'Net price';
        Txt011: Label 'Unit cost';
        Txt012: Label 'Profit contribution';
        Txt013: Label 'Contribution ratio';
        i: Integer;
        j: Integer;
        Txt016: Label 'Register No.';
        Txt017: Label 'Receipt No.';
    begin
        // GetSaleLineStat

        i := 1;
        NPRTempBuffer.Init;
        NPRTempBuffer."Line No." := i;
        //buffer.Description := "Eksp. Caption";
        NPRTempBuffer.Bold := true;
        NPRTempBuffer.Sel := true;
        NPRTempBuffer.Insert;

        i += 1;
        NPRTempBuffer.Init;
        NPRTempBuffer."Line No." := i;
        NPRTempBuffer.Description := Txt016;
        NPRTempBuffer.Bold := true;
        NPRTempBuffer."Description 2" := "Register No.";
        NPRTempBuffer.Insert;

        i += 1;
        NPRTempBuffer.Init;
        NPRTempBuffer."Line No." := i;
        NPRTempBuffer.Description := Txt017;
        NPRTempBuffer.Bold := true;
        NPRTempBuffer."Description 2" := "Sales Ticket No.";
        NPRTempBuffer.Insert;

        for j := 1 to 11 do begin
            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Bold := true;
            case j of
                1:
                    begin
                        NPRTempBuffer.Description := Txt001;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(SalesPrice + DiscountAmt, 2);
                    end;
                2:
                    begin
                        NPRTempBuffer.Description := Txt002;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DiscountAmt, 2);
                    end;
                3:
                    begin
                        NPRTempBuffer.Description := Txt003;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(SalesPrice - Netto, 2);
                    end;
                4:
                    begin
                        NPRTempBuffer.Description := Txt008;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(InvoiceDiscountAmt, 2);
                    end;
                5:
                    begin
                        NPRTempBuffer.Description := Txt009;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(InvoiceFee, 2);
                    end;
                6:
                    begin
                        NPRTempBuffer.Description := Txt010;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(Netto, 2);
                    end;
                7:
                    begin
                        NPRTempBuffer.Description := Txt011;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(CostPrice, 2);
                    end;
                8:
                    begin
                        NPRTempBuffer.Description := Txt012;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DB, 2);
                    end;
                9:
                    begin
                        NPRTempBuffer.Description := Txt013;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DG, 2);
                    end;
            end;
            NPRTempBuffer.Insert;
        end;
    end;
}

