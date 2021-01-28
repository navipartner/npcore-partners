report 6014446 "NPR Salesperson Stats"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Salesperson Statistics.rdlc';
    Caption = 'Salesperson Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            CalcFields = "NPR Sales (LCY)";
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(DateFilter; DateFilter)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CustAmountTemp.Init();
                CustAmountTemp."Amount (LCY)" := "NPR Sales (LCY)";
                CustAmountTemp."Customer No." := Code;
                CustAmountTemp.Insert();
            end;

            trigger OnPreDataItem()
            begin
                CustAmountTemp.SetCurrentKey("Amount (LCY)", "Amount 2 (LCY)", "Customer No.");
                CustAmountTemp.Ascending(false);
                CustAmountTemp.DeleteAll();
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(1 ..));
            column(IntegerNumber; Integer.Number)
            {
            }
            column("Code"; "Salesperson/Purchaser".Code)
            {
            }
            column(Name; "Salesperson/Purchaser".Name)
            {
            }
            column(SalesLcy; "Salesperson/Purchaser"."NPR Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(SalesLcyLast; SalespersonLastYear."NPR Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMargin; "Salesperson/Purchaser"."NPR Sales (LCY)" - "Salesperson/Purchaser"."NPR COGS (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMarginLast; SalespersonLastYear."NPR Sales (LCY)" - SalespersonLastYear."NPR COGS (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMarginPct; "Pct."("Salesperson/Purchaser"."NPR Sales (LCY)" - "Salesperson/Purchaser"."NPR COGS (LCY)", "Salesperson/Purchaser"."NPR Sales (LCY)"))
            {
                AutoFormatType = 1;
            }
            column(GMarginPctLast; "Pct."(SalespersonLastYear."NPR Sales (LCY)" - SalespersonLastYear."NPR COGS (LCY)", SalespersonLastYear."NPR Sales (LCY)"))
            {
                AutoFormatType = 1;
            }
            column(Discount; "Salesperson/Purchaser"."NPR Discount Amount")
            {
                AutoFormatType = 1;
            }
            column(DiscountLast; SalespersonLastYear."NPR Discount Amount")
            {
                AutoFormatType = 1;
            }
            column(AvgDisc; "Pct."("Salesperson/Purchaser"."NPR Discount Amount", "Salesperson/Purchaser"."NPR Sales (LCY)" + "Salesperson/Purchaser"."NPR Discount Amount"))
            {
                AutoFormatType = 1;
            }
            column(AvgDiscLast; "Pct."(SalespersonLastYear."NPR Discount Amount", SalespersonLastYear."NPR Sales (LCY)" + SalespersonLastYear."NPR Discount Amount"))
            {
                AutoFormatType = 1;
            }
            column(SalesPct; "Pct."("Salesperson/Purchaser"."NPR Item Group Sales (LCY)", "Salesperson/Purchaser"."NPR Sales (LCY)"))
            {
                AutoFormatType = 1;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not CustAmountTemp.Find('-') then
                        CurrReport.Break();
                end else
                    if CustAmountTemp.Next = 0 then
                        CurrReport.Break();

                "Salesperson/Purchaser".Get(CustAmountTemp."Customer No.");
                "Salesperson/Purchaser".CalcFields("NPR Sales (LCY)", "NPR Discount Amount", "NPR COGS (LCY)", "NPR Item Group Sales (LCY)");

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    SalespersonLastYear.Get(CustAmountTemp."Customer No.");
                    SalespersonLastYear.CalcFields("NPR Sales (LCY)", "NPR Discount Amount", "NPR COGS (LCY)");
                end;
            end;

            trigger OnPostDataItem()
            begin
                PctPeriodTotal := "Pct."("Salesperson/Purchaser"."NPR Discount Amount", "Salesperson/Purchaser"."NPR Sales (LCY)" + "Salesperson/Purchaser"."NPR Discount Amount");
                PctPeriodTotalLastYear := "Pct."(SalespersonLastYear."NPR Discount Amount", SalespersonLastYear."NPR Sales (LCY)" + SalespersonLastYear."NPR Discount Amount");
            end;

            trigger OnPreDataItem()
            begin
                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    SalespersonLastYear.CopyFilters("Salesperson/Purchaser");
                    StartDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMin("Date Filter"));
                    EndDate := CalcDate('<-1Y>', "Salesperson/Purchaser".GetRangeMax("Date Filter"));
                    SalespersonLastYear.SetRange("Date Filter", StartDate, EndDate);
                end;
            end;
        }
        dataitem(DiscountStatistics; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(Number_DiscountStatistics; DiscountStatistics.Number)
            {
            }
            column(DiscountAmt1; DiscountAmt[1])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt1Last; DiscountAmtLY[1])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt2; DiscountAmt[2])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt2Last; DiscountAmtLY[2])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt3; DiscountAmt[3])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt3Last; DiscountAmtLY[3])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt4; DiscountAmt[4])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt4Last; DiscountAmtLY[4])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt5; DiscountAmt[5])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt5Last; DiscountAmtLY[5])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt6; DiscountAmt[6])
            {
            }
            column(DiscountAmt6Last; DiscountAmtLY[6])
            {
            }
            column(DiscountAmt7; DiscountAmt[7])
            {
            }
            column(DiscountAmt7Last; DiscountAmtLY[7])
            {
            }
            column(DiscountAmt8; DiscountAmt[8])
            {
            }
            column(DiscountAmt8Last; DiscountAmtLY[8])
            {
            }
            column(DiscountAmt9; DiscountAmt[9])
            {
            }
            column(DiscountAmt9Last; DiscountAmtLY[9])
            {
            }
            column(DiscountAmt10; DiscountAmt[10])
            {
            }
            column(DiscountAmt10Last; DiscountAmtLY[10])
            {
            }

            trigger OnAfterGetRecord()
            begin
                i := 0;
                repeat
                    AuditRoll.SetFilter("Discount Type", Format(i));
                    AuditRoll.CalcSums("Line Discount Amount");
                    DiscountAmt[i + 1] := AuditRoll."Line Discount Amount";
                    i += 1;
                until i = 10;

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    i := 0;
                    repeat
                        AuditRollLastYear.SetFilter("Discount Type", Format(i));
                        AuditRollLastYear.CalcSums("Line Discount Amount");
                        DiscountAmtLY[i + 1] := AuditRollLastYear."Line Discount Amount";
                        i += 1;
                    until i = 10;
                end;
            end;

            trigger OnPreDataItem()
            begin
                AuditRoll.SetCurrentKey("Register No.", "Sale Type", Type, "No.", "Sale Date", "Discount Type");
                "Salesperson/Purchaser".CopyFilter("Date Filter", AuditRoll."Sale Date");

                AuditRoll.SetFilter("Sale Type", '%1|%2', 0, 2);
                AuditRoll.SetRange(Type, 1);
                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    AuditRollLastYear.SetCurrentKey("Register No.", "Sale Type", Type, "No.", "Sale Date", "Discount Type");
                    AuditRollLastYear.CopyFilters(AuditRoll);
                    AuditRollLastYear.SetRange("Sale Date", StartDate, EndDate);
                end;
            end;
        }
    }

    labels
    {
        Page_Lbl = 'Page';
        Report_Lbl = 'SalesPerson Statistics';
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
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        j := '2';

        if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then
            DateFilter := TextDateFilters + "Salesperson/Purchaser".GetFilter("Date Filter");
    end;

    var
        CompanyInfo: Record "Company Information";
        CustAmountTemp: Record "Customer Amount" temporary;
        AuditRoll: Record "NPR Audit Roll";
        AuditRollLastYear: Record "NPR Audit Roll";
        SalespersonLastYear: Record "Salesperson/Purchaser";
        ikkesoegivarepost: Boolean;
        EndDate: Date;
        StartDate: Date;
        DiscountAmt: array[10] of Decimal;
        DiscountAmtLY: array[10] of Decimal;
        PctPeriodTotal: Decimal;
        PctPeriodTotalLastYear: Decimal;
        i: Integer;
        TextDateFilters: Label 'Period :';
        ShowExcel: Option " ",salg,db,dg,rab,gmnrab;
        DateFilter: Text;
        j: Text[30];

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
}

