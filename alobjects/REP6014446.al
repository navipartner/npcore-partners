report 6014446 "Salesperson Statistics"
{
    // NPR4.14/TSA/20150731/ CASE 219602 - Clean CRLF from Lables Captions - NavInfo and Report_Lbl
    // NPR4.14/TSA/20150731/ CASE 219602 - Changes (indent) to Comply to Critical Guidelines
    // NPR4.14/LS/20150909  CASE 222267 Corrections to report + change variable to Std English + format codes
    // NPR5.25/JLK /20160629 CASE 222267 Corrected RDLC Rounding to 1 (It was 2)
    //                                   Adjusted Font Sizes
    //                                   Added Discount type to 10
    // NPR5.31/JLK /20170414 CASE 269893 Added filter on Audit Roll with Debit Sale
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.43/JDH /20180604 CASE 317971 Removed a danish unused label
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Salesperson Statistics.rdlc';

    Caption = 'Salesperson Statistics';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
        {
            CalcFields = "Sales (LCY)";
            RequestFilterFields = "Code","Date Filter","Global Dimension 1 Filter";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInfo.Picture)
            {
            }
            column(DateFilter;DateFilter)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CustAmountTemp.Init;
                CustAmountTemp."Amount (LCY)" := "Sales (LCY)";
                CustAmountTemp."Customer No." := Code;
                CustAmountTemp.Insert;
            end;

            trigger OnPreDataItem()
            begin
                CustAmountTemp.SetCurrentKey("Amount (LCY)","Amount 2 (LCY)","Customer No.");
                CustAmountTemp.Ascending(false);
                CustAmountTemp.DeleteAll;
            end;
        }
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number=FILTER(1..));
            column(IntegerNumber;Integer.Number)
            {
            }
            column("Code";"Salesperson/Purchaser".Code)
            {
            }
            column(Name;"Salesperson/Purchaser".Name)
            {
            }
            column(SalesLcy;"Salesperson/Purchaser"."Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(SalesLcyLast;SalespersonLastYear."Sales (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMargin;"Salesperson/Purchaser"."Sales (LCY)"-"Salesperson/Purchaser"."COGS (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMarginLast;SalespersonLastYear."Sales (LCY)"-SalespersonLastYear."COGS (LCY)")
            {
                AutoFormatType = 1;
            }
            column(GMarginPct;"Pct."("Salesperson/Purchaser"."Sales (LCY)"-"Salesperson/Purchaser"."COGS (LCY)","Salesperson/Purchaser"."Sales (LCY)"))
            {
                AutoFormatType = 1;
            }
            column(GMarginPctLast;"Pct."(SalespersonLastYear."Sales (LCY)"-SalespersonLastYear."COGS (LCY)",SalespersonLastYear."Sales (LCY)"))
            {
                AutoFormatType = 1;
            }
            column(Discount;"Salesperson/Purchaser"."Discount Amount")
            {
                AutoFormatType = 1;
            }
            column(DiscountLast;SalespersonLastYear."Discount Amount")
            {
                AutoFormatType = 1;
            }
            column(AvgDisc;"Pct."("Salesperson/Purchaser"."Discount Amount","Salesperson/Purchaser"."Sales (LCY)"+"Salesperson/Purchaser"."Discount Amount"))
            {
                AutoFormatType = 1;
            }
            column(AvgDiscLast;"Pct."(SalespersonLastYear."Discount Amount",SalespersonLastYear."Sales (LCY)"+SalespersonLastYear."Discount Amount"))
            {
                AutoFormatType = 1;
            }
            column(SalesPct;"Pct."("Salesperson/Purchaser"."Item Group Sales (LCY)", "Salesperson/Purchaser"."Sales (LCY)"))
            {
                AutoFormatType = 1;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                  if not CustAmountTemp.Find('-') then
                    CurrReport.Break;
                end else
                  if CustAmountTemp.Next = 0 then
                    CurrReport.Break;

                "Salesperson/Purchaser".Get(CustAmountTemp."Customer No.");
                "Salesperson/Purchaser".CalcFields("Sales (LCY)","Discount Amount","COGS (LCY)", "Item Group Sales (LCY)");

                if "Salesperson/Purchaser".GetFilter("Date Filter")<>'' then begin
                  SalespersonLastYear.Get(CustAmountTemp."Customer No.");
                  SalespersonLastYear.CalcFields("Sales (LCY)","Discount Amount","COGS (LCY)");
                end;
            end;

            trigger OnPostDataItem()
            begin
                PctPeriodTotal := "Pct."("Salesperson/Purchaser"."Discount Amount","Salesperson/Purchaser"."Sales (LCY)"+"Salesperson/Purchaser"."Discount Amount");
                PctPeriodTotalLastYear := "Pct."(SalespersonLastYear."Discount Amount",SalespersonLastYear."Sales (LCY)"+ SalespersonLastYear."Discount Amount");
            end;

            trigger OnPreDataItem()
            begin
                if "Salesperson/Purchaser".GetFilter("Date Filter")<>'' then begin
                  SalespersonLastYear.CopyFilters("Salesperson/Purchaser");
                  StartDate := CalcDate('<-1Y>',"Salesperson/Purchaser".GetRangeMin("Date Filter"));
                  EndDate := CalcDate('<-1Y>',"Salesperson/Purchaser".GetRangeMax("Date Filter"));
                  SalespersonLastYear.SetRange("Date Filter", StartDate, EndDate);
                end;

                CurrReport.CreateTotals("Salesperson/Purchaser"."Sales (LCY)",
                                        "Salesperson/Purchaser"."Discount Amount",
                                        "Salesperson/Purchaser"."COGS (LCY)",
                                        SalespersonLastYear."Sales (LCY)",
                                        SalespersonLastYear."Discount Amount",
                                        SalespersonLastYear."COGS (LCY)");
            end;
        }
        dataitem(DiscountStatistics;"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(Number_DiscountStatistics;DiscountStatistics.Number)
            {
            }
            column(DiscountAmt1;DiscountAmt[1])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt1Last;DiscountAmtLY[1])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt2;DiscountAmt[2])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt2Last;DiscountAmtLY[2])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt3;DiscountAmt[3])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt3Last;DiscountAmtLY[3])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt4;DiscountAmt[4])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt4Last;DiscountAmtLY[4])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt5;DiscountAmt[5])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt5Last;DiscountAmtLY[5])
            {
                AutoFormatType = 1;
            }
            column(DiscountAmt6;DiscountAmt[6])
            {
            }
            column(DiscountAmt6Last;DiscountAmtLY[6])
            {
            }
            column(DiscountAmt7;DiscountAmt[7])
            {
            }
            column(DiscountAmt7Last;DiscountAmtLY[7])
            {
            }
            column(DiscountAmt8;DiscountAmt[8])
            {
            }
            column(DiscountAmt8Last;DiscountAmtLY[8])
            {
            }
            column(DiscountAmt9;DiscountAmt[9])
            {
            }
            column(DiscountAmt9Last;DiscountAmtLY[9])
            {
            }
            column(DiscountAmt10;DiscountAmt[10])
            {
            }
            column(DiscountAmt10Last;DiscountAmtLY[10])
            {
            }

            trigger OnAfterGetRecord()
            begin
                i := 0;
                repeat
                  AuditRoll.SetFilter("Discount Type",Format(i));
                  AuditRoll.CalcSums("Line Discount Amount");
                  DiscountAmt[i+1] := AuditRoll."Line Discount Amount";
                  i += 1;
                //+NPR5.25
                //UNTIL i = 5;
                until i = 10;
                //-NPR5.25

                if "Salesperson/Purchaser".GetFilter("Date Filter")<>'' then begin
                  i := 0;
                  repeat
                    AuditRollLastYear.SetFilter("Discount Type", Format(i));
                    AuditRollLastYear.CalcSums("Line Discount Amount");
                    DiscountAmtLY[i+1] := AuditRollLastYear."Line Discount Amount";
                    i += 1;
                //+NPR5.25
                //    UNTIL i = 5;
                until i = 10;
                //-NPR5.25
                end;
            end;

            trigger OnPreDataItem()
            begin
                AuditRoll.SetCurrentKey("Register No.","Sale Type",Type,"No.","Sale Date","Discount Type");
                "Salesperson/Purchaser".CopyFilter("Date Filter", AuditRoll."Sale Date");

                //-NPR5.31
                //AuditRoll.SETRANGE("Sale Type",0);
                AuditRoll.SetFilter("Sale Type",'%1|%2',0,2);
                //+NPR5.31
                AuditRoll.SetRange(Type,1);

                if "Salesperson/Purchaser".GetFilter("Date Filter")<>'' then begin
                  AuditRollLastYear.SetCurrentKey("Register No.","Sale Type",Type,"No.","Sale Date","Discount Type");
                  AuditRollLastYear.CopyFilters(AuditRoll);
                  AuditRollLastYear.SetRange("Sale Date", StartDate, EndDate);
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
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
        Rbt1_Lbl = 'Uncategorized Disc';
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
        
        //-NPR5.39
        // Object.SETRANGE(ID, 6014446);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
        
        j := '2';
        
        //-NPR4.14
        if "Salesperson/Purchaser".GetFilter("Date Filter") <> '' then
          DateFilter := TextDateFilters + "Salesperson/Purchaser".GetFilter("Date Filter");
        
        /*
        IF DateFilter = '' THEN
          DateFilter := Text001;
        */
        //+NPR4.14

    end;

    var
        DateFilter: Text;
        CompanyInfo: Record "Company Information";
        CustAmountTemp: Record "Customer Amount" temporary;
        SalespersonLastYear: Record "Salesperson/Purchaser";
        StartDate: Date;
        EndDate: Date;
        ikkesoegivarepost: Boolean;
        j: Text[30];
        ShowExcel: Option " ",salg,db,dg,rab,gmnrab;
        AuditRoll: Record "Audit Roll";
        AuditRollLastYear: Record "Audit Roll";
        i: Integer;
        DiscountAmt: array [10] of Decimal;
        DiscountAmtLY: array [10] of Decimal;
        PctPeriodTotal: Decimal;
        PctPeriodTotalLastYear: Decimal;
        TextDateFilters: Label 'Period :';

    local procedure "Pct."(Tal1: Decimal;Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
          exit(0);
        exit(Round(Tal1 / Tal2 * 100,0.1));
    end;
}

