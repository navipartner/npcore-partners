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
            column(COMPANYNAME; COMPANYNAME)
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
                NPRGetVESalesLCY(SalesLCY);
                if (SalesLCY = 0) and (ShowSalespersonWithSale) then
                    CurrReport.Skip();
                TempCustAmount.Init();
                TempCustAmount."Amount (LCY)" := SalesLCY;
                TempCustAmount."Customer No." := Code;
                TempCustAmount.Insert();
            end;

            trigger OnPreDataItem()
            begin
                TempCustAmount.SetCurrentKey("Amount (LCY)", "Amount 2 (LCY)", "Customer No.");
                TempCustAmount.Ascending(false);
                TempCustAmount.DeleteAll();
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) order(ascending) where(Number = filter(1 ..));
            column(IntegerNumber; Integer.Number)
            {
            }
            column("Code"; "Salesperson/Purchaser".Code)
            {
            }
            column(Name; "Salesperson/Purchaser".Name)
            {
            }
            column(SalesLcy; SalesLCY)
            {
                AutoFormatType = 1;
            }
            column(SalesLcyLast; SalesLCYSalesPersonLastYear)
            {
                AutoFormatType = 1;
            }
            column(GMargin; SalesLCY - COGSLCY)
            {
                AutoFormatType = 1;
            }
            column(GMarginLast; SalesLCYSalesPersonLastYear - COGSLCYSalesPersonLastYear)
            {
                AutoFormatType = 1;
            }
            column(GMarginPct; CalcPct(SalesLCY - COGSLCY, SalesLCY))
            {
                AutoFormatType = 1;
            }
            column(GMarginPctLast; CalcPct(SalesLCYSalesPersonLastYear - COGSLCYSalesPersonLastYear, SalesLCYSalesPersonLastYear))
            {
                AutoFormatType = 1;
            }
            column(Discount; DiscountAmount)
            {
                AutoFormatType = 1;
            }
            column(DiscountLast; DiscountAmountSalesPersonLastYear)
            {
                AutoFormatType = 1;
            }
            column(AvgDisc; CalcPct(DiscountAmount, SalesLCY + DiscountAmount))
            {
                AutoFormatType = 1;
            }
            column(AvgDiscLast; CalcPct(DiscountAmountSalesPersonLastYear, SalesLCYSalesPersonLastYear + DiscountAmountSalesPersonLastYear))
            {
                AutoFormatType = 1;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempCustAmount.FindFirst() then
                        CurrReport.Break();
                end else
                    if TempCustAmount.Next() = 0 then
                        CurrReport.Break();

                "Salesperson/Purchaser".Get(TempCustAmount."Customer No.");
                "Salesperson/Purchaser".NPRGetVESalesLCY(SalesLCY);
                "Salesperson/Purchaser".NPRGetVEDiscountAmount(DiscountAmount);
                "Salesperson/Purchaser".NPRGetVECOGSLCY(COGSLCY);
                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    SalespersonLastYear.Get(TempCustAmount."Customer No.");
                    SalespersonLastYear.NPRGetVESalesLCY(SalesLCYSalesPersonLastYear);
                    SalespersonLastYear.NPRGetVEDiscountAmount(DiscountAmountSalesPersonLastYear);
                    SalespersonLastYear.NPRGetVECOGSLCY(COGSLCYSalesPersonLastYear);
                end;
            end;

            trigger OnPostDataItem()
            begin
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
            DataItemTableView = sorting(Number);
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
                    TempPOSSalesLine.SetFilter(TempPOSSalesLine."Discount Type", Format(i));
                    if TempPOSSalesLine.FindSet() then
                        repeat
                            DiscountAmt[i + 1] += TempPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)";
                        until TempPOSSalesLine.Next() = 0;
                    i += 1;

                until i = 10;

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    i := 0;
                    repeat
                        TempPOSSalesLineLY.SetFilter("Discount Type", Format(i));
                        if TempPOSSalesLineLY.FindSet() then
                            repeat
                                DiscountAmtLY[i + 1] += TempPOSSalesLineLY."Line Dsc. Amt. Excl. VAT (LCY)";
                            until TempPOSSalesLineLY.Next() = 0;
                        i += 1;

                    until i = 10;
                end;
            end;

            trigger OnPreDataItem()
            begin
                "Salesperson/Purchaser".CopyFilter("Date Filter", POSEntry."Entry Date");
                POSEntry.SetFilter("Entry Type", '%1|%2', 1, 3);
                if POSEntry.FindSet() then
                    repeat
                        Clear(POSSalesLine);
                        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
                        if POSSalesLine.FindSet() then
                            repeat
                                TempPOSSalesLine.Init();
                                TempPOSSalesLine.TransferFields(POSSalesLine);
                                TempPOSSalesLine.Insert()
                            until POSSalesLine.Next() = 0;
                    until POSEntry.Next() = 0;

                if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then begin
                    POSEntryLastYear.SetFilter("Entry Type", '%1|%2', 1, 3);
                    POSEntryLastYear.SetRange("Entry Date", StartDate, EndDate);
                    if POSEntryLastYear.FindSet() then
                        repeat
                            Clear(POSSalesLine);
                            POSSalesLine.SetRange("POS Entry No.", POSEntryLastYear."Entry No.");
                            POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
                            if POSSalesLine.FindSet() then
                                repeat
                                    TempPOSSalesLineLY.Init();
                                    TempPOSSalesLineLY.TransferFields(POSSalesLine);
                                    TempPOSSalesLineLY.Insert();
                                until POSSalesLine.Next() = 0;
                        until POSEntryLastYear.Next() = 0;
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

        actions
        {
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
        j := '2';
        if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then
            DateFilter := TextDateFilters + "Salesperson/Purchaser".GetFilter("Date Filter");
        if "Salesperson/Purchaser".IsEmpty() then begin
            Message(NoDataErrorLbl);
            CurrReport.Break();
        end;

    end;

    var
        DateFilter: Text;
        CompanyInfo: Record "Company Information";
        TempCustAmount: Record "Customer Amount" temporary;
        SalespersonLastYear: Record "Salesperson/Purchaser";
        StartDate: Date;
        EndDate: Date;
        j: Text[30];
        i: Integer;
        DiscountAmt: array[10] of Decimal;
        DiscountAmtLY: array[10] of Decimal;

        TextDateFilters: Label 'Period :';
        POSEntry: Record "NPR POS Entry";
        POSEntryLastYear: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        TempPOSSalesLine: Record "NPR POS Entry Sales Line" temporary;
        SalesLCY: Decimal;
        SalesLCYSalesPersonLastYear: Decimal;
        DiscountAmount: Decimal;
        DiscountAmountSalesPersonLastYear: Decimal;
        COGSLCY: Decimal;
        COGSLCYSalesPersonLastYear: Decimal;
        TempPOSSalesLineLY: Record "NPR POS Entry Sales Line" temporary;
        ShowSalespersonWithSale: Boolean;
        NoDataErrorLbl: Label 'There is not data to be shown.';

    local procedure CalcPct(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
}

