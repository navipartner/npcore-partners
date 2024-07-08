report 6014446 "NPR S.Person POS Sales Stats"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/SalespersonPOSSalesStats.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Salesperson POS Sales Statistics';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";
            column("Code"; "Salesperson/Purchaser".Code) { }
            column(Name; "Salesperson/Purchaser".Name) { }
            column(COMPANYNAME; COMPANYNAME) { }
            column(CompanyInfoPicture; CompanyInfo.Picture) { }
            column(DateFilter; DateFilter) { }
            column(SalesLcy; SalesLCY) { }
            column(SalesLcyLast; SalesLCYSalesPersonLastYear) { }
            column(GMargin; SalesLCY - COGSLCY) { }
            column(GMarginLast; SalesLCYSalesPersonLastYear - COGSLCYSalesPersonLastYear) { }
            column(GMarginPct; CalcPct(SalesLCY - COGSLCY, SalesLCY)) { }
            column(GMarginPctLast; CalcPct(SalesLCYSalesPersonLastYear - COGSLCYSalesPersonLastYear, SalesLCYSalesPersonLastYear)) { }
            column(Discount; DiscountAmount) { }
            column(DiscountLast; DiscountAmountSalesPersonLastYear) { }
            column(AvgDisc; CalcPct(DiscountAmount, SalesLCY + DiscountAmount)) { }
            column(AvgDiscLast; CalcPct(DiscountAmountSalesPersonLastYear, SalesLCYSalesPersonLastYear + DiscountAmountSalesPersonLastYear)) { }
            column(DiscountAmt1; DiscountAmt[1]) { }
            column(DiscountAmt1Last; DiscountAmtLY[1]) { }
            column(DiscountAmt2; DiscountAmt[2]) { }
            column(DiscountAmt2Last; DiscountAmtLY[2]) { }
            column(DiscountAmt3; DiscountAmt[3]) { }
            column(DiscountAmt3Last; DiscountAmtLY[3]) { }
            column(DiscountAmt4; DiscountAmt[4]) { }
            column(DiscountAmt4Last; DiscountAmtLY[4]) { }
            column(DiscountAmt5; DiscountAmt[5]) { }
            column(DiscountAmt5Last; DiscountAmtLY[5]) { }
            column(DiscountAmt6; DiscountAmt[6]) { }
            column(DiscountAmt6Last; DiscountAmtLY[6]) { }
            column(DiscountAmt7; DiscountAmt[7]) { }
            column(DiscountAmt7Last; DiscountAmtLY[7]) { }
            column(DiscountAmt8; DiscountAmt[8]) { }
            column(DiscountAmt8Last; DiscountAmtLY[8]) { }
            column(DiscountAmt9; DiscountAmt[9]) { }
            column(DiscountAmt9Last; DiscountAmtLY[9]) { }
            column(DiscountAmt10; DiscountAmt[10]) { }
            column(DiscountAmt10Last; DiscountAmtLY[10]) { }

            trigger OnAfterGetRecord()
            var
                POSSLDiscAmtType: Query "NPR POS SL Disc. Amt. Type";
                Index: Integer;
            begin
                "Salesperson/Purchaser".NPRGetVESalesCostDiscount(SalesLCY, COGSLCY, DiscountAmount);
                if (SalesLCY = 0) then
                    CurrReport.Skip();

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    SalespersonLastYear.Get("Salesperson/Purchaser".Code);
                    SalespersonLastYear.CopyFilters("Salesperson/Purchaser");
                    StartDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMin("Date Filter"));
                    EndDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMax("Date Filter"));
                    SalespersonLastYear.SetRange("Date Filter", StartDate, EndDate);
                    SalespersonLastYear.NPRGetVESalesCostDiscount(SalesLCYSalesPersonLastYear, COGSLCYSalesPersonLastYear, DiscountAmountSalesPersonLastYear);
                end;

                POSSLDiscAmtType.SetFilter(SalespersonCode, "Salesperson/Purchaser".Code);
                POSSLDiscAmtType.SetFilter(EntryDate, "Salesperson/Purchaser".GetFilter("Date Filter"));

                POSSLDiscAmtType.Open();
                while POSSLDiscAmtType.Read() do begin
                    Index := ConvertDiscountTypeToInteger(POSSLDiscAmtType.DiscountType);
                    if Index <> -1 then
                        DiscountAmt[Index] += POSSLDiscAmtType.LineDscAmtExclVATLCY;
                end;
                POSSLDiscAmtType.Close();

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    POSSLDiscAmtType.SetRange(EntryDate, StartDate, EndDate);

                    POSSLDiscAmtType.Open();
                    while POSSLDiscAmtType.Read() do begin
                        Index := ConvertDiscountTypeToInteger(POSSLDiscAmtType.DiscountType);
                        if Index <> -1 then
                            DiscountAmtLY[Index] += POSSLDiscAmtType.LineDscAmtExclVATLCY;
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field("Show Salesperson With Sale"; ShowSalespersonWithSale)
                {
                    Caption = 'Show Salesperson With Sale';
                    ToolTip = 'Specifies the value of the Show Salesperson With Sale field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Page_Lbl = 'Page';
        Report_Lbl = 'Salesperson Statistics';
        Period_Lbl = 'Period :';
        InfoExTax = 'All amounts are excl. VAT';
        SalesPerson_Lbl = 'Salesperson';
        Name_Lbl = 'Name';
        SalesLcy_Lbl = 'Sales excl. VAT';
        GMargin_Lbl = 'GMargin';
        GMarginPct_Lbl = 'GMargin %';
        Discount_Lbl = 'Discount Granted';
        AvgDisc_Lbl = 'Average disc. %';
        SalesDisc_Lbl = 'Group Sales %';
        SalesDisc2_Lbl = 'On item no.';
        Rbt1_Lbl = 'Uncategorized Disc.';
        Rbt2_Lbl = 'Period Disc.';
        Rbt3_Lbl = 'Mixed Disc.';
        Rbt4_Lbl = 'Multiple Unit Disc.';
        Rbt5_Lbl = 'Salesperson Disc.';
        Period2_Lbl = 'Period';
        PeriodLast_Lbl = 'Last Year';
        TotalPeriod = 'Total for Period';
        TotalPeriodLYr = 'Total for Period LastYear';
        Rbt6_Lbl = 'Inventory';
        Rbt7_Lbl = 'Photo Work';
        Rbt8_Lbl = 'Afrunding';
        Rbt9_Lbl = 'Combination';
        Rbt10_Lbl = 'Customer';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then
            DateFilter := TextDateFilters + "Salesperson/Purchaser".GetFilter("Date Filter");

        if "Salesperson/Purchaser".IsEmpty() then begin
            Message(NoDataErrorLbl);
            CurrReport.Break();
        end;

        if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
            SalespersonLastYear.CopyFilters("Salesperson/Purchaser");
            StartDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMin("Date Filter"));
            EndDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMax("Date Filter"));
            SalespersonLastYear.SetRange("Date Filter", StartDate, EndDate);
        end;

    end;

    var
        DateFilter: Text;
        CompanyInfo: Record "Company Information";
        SalespersonLastYear: Record "Salesperson/Purchaser";
        StartDate: Date;
        EndDate: Date;
        DiscountAmt: array[10] of Decimal;
        DiscountAmtLY: array[10] of Decimal;

        TextDateFilters: Label 'Period :';
        SalesLCY: Decimal;
        SalesLCYSalesPersonLastYear: Decimal;
        DiscountAmount: Decimal;
        DiscountAmountSalesPersonLastYear: Decimal;
        COGSLCY: Decimal;
        COGSLCYSalesPersonLastYear: Decimal;
        ShowSalespersonWithSale: Boolean;
        NoDataErrorLbl: Label 'There is not data to be shown.';

    local procedure CalcPct(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;

    local procedure ConvertDiscountTypeToInteger(DiscountType: Option " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer): Integer
    begin
        case DiscountType of
            DiscountType::" ":
                exit(1);
            DiscountType::Campaign:
                exit(2);
            DiscountType::Mix:
                exit(3);
            DiscountType::Quantity:
                exit(4);
            DiscountType::Manual:
                exit(5);
            DiscountType::"BOM List":
                exit(6);
            DiscountType::"Photo work":
                exit(7);
            DiscountType::Rounding:
                exit(8);
            DiscountType::Combination:
                exit(9);
            DiscountType::Customer:
                exit(10);
            else
                exit(-1);
        end;
    end;
}

