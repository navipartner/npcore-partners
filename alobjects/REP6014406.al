report 6014406 "Sales Person Top 20"
{
    // NPR70.00.00.00/LS/230414 CASE 176115 : Conversion of Report 6014406 as RTC
    // NPR5.36/TJ  /20170927 CASE 286283 Renamed options in variable ShowType into english
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Sales Person Top 20.rdlc';

    Caption = 'Sales Person Top 20';
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
        {
            CalcFields = "Sales (LCY)","Discount Amount","COGS (LCY)";
            RequestFilterFields = "Code","Date Filter","Global Dimension 1 Filter";

            trigger OnAfterGetRecord()
            begin
                if OnlySales then
                  if "Salesperson/Purchaser"."Sales (LCY)" = 0 then
                    CurrReport.Skip;

                SalesPersonTemp.Init;
                SalesPersonTemp."Vendor No." := "Salesperson/Purchaser".Code;

                if Sorting = Sorting::Largest then
                  Multipl := -1
                else
                  Multipl := 1;

                Db := ("Sales (LCY)" - "COGS (LCY)");

                if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                  Dg := (Db / "Salesperson/Purchaser"."Sales (LCY)") * 100
                else
                  Dg := 0;

                case ShowType of
                //-NPR5.39
                //  ShowType::Turnover : salesPersonTemp."Amount (LCY)" := multipl*"Sales (LCY)";
                //  ShowType::Turnover : salesPersonTemp."Amount 2 (LCY)" := multipl*"Discount Amount";
                //  ShowType::Discount : salesPersonTemp."Amount (LCY)" := multipl*"Discount Amount";
                //  ShowType::Discount : salesPersonTemp."Amount 2 (LCY)" := multipl*"Sales (LCY)";
                  ShowType::Turnover :
                    begin
                      SalesPersonTemp."Amount (LCY)" := Multipl * "Sales (LCY)";
                      SalesPersonTemp."Amount 2 (LCY)" := Multipl * "Discount Amount";
                     end;
                  ShowType::Discount :
                    begin
                      SalesPersonTemp."Amount (LCY)" := Multipl * "Discount Amount";
                      SalesPersonTemp."Amount 2 (LCY)" := Multipl * "Sales (LCY)";
                    end;
                //+NPR5.39
                  ShowType::"Contribution Margin"  : SalesPersonTemp."Amount (LCY)" := Multipl * Db;
                end;

                SalesPersonTemp.Insert;

                if (I = 0) or (I < ShowQty) then
                  I := I + 1
                else begin
                  SalesPersonTemp.FindLast;
                  SalesPersonTemp.Delete;
                end;

                SalesTotal += "Sales (LCY)";

                //-NPR70.00.00.00/LS/230414
                if SalesTotal <> 0 then
                  SalesPct := (("Salesperson/Purchaser"."Sales (LCY)") / SalesTotal) * 100;

                if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                  DgTotal := (Db / "Salesperson/Purchaser"."Sales (LCY)") * 100;

                if "Salesperson/Purchaser"."Discount Amount" <> 0 then
                  DiscountPctTotal := "Salesperson/Purchaser"."Discount Amount" / ("Salesperson/Purchaser"."Sales (LCY)" + "Salesperson/Purchaser"."Discount Amount") * 100
                else
                  DiscountPctTotal := 0;
                //+NPR70.00.00.00/LS/230414
            end;

            trigger OnPreDataItem()
            begin
                SalesPersonTemp.DeleteAll;
                I := 0;
                SalespersonFilter := "Salesperson/Purchaser".GetFilter("Date Filter");
                CurrReport.CreateTotals("Salesperson/Purchaser"."Sales (LCY)","Salesperson/Purchaser"."COGS (LCY)");
            end;
        }
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=FILTER(1..));
            column(CurrReport_PAGENOCaption;CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Report_Caption;Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Period_SalespersonFilter;'Periode: ' +"Salesperson/Purchaser".GetFilter("Date Filter"))
            {
            }
            column(SalespersonFilter;SalespersonFilter)
            {
            }
            column(OrderBy_ShowTypeFilter;StrSubstNo(Text001,SelectStr(ShowType + 1,TextSort)))
            {
            }
            column(ShowQty;ShowQty)
            {
            }
            column(Salesperson_Purchaser_Name;"Salesperson/Purchaser".Name)
            {
                IncludeCaption = true;
            }
            column(Salesperson_Purchaser_Sales_LCY_;"Salesperson/Purchaser"."Sales (LCY)")
            {
            }
            column(Salesperson_Purchaser_Discount_Amount;"Salesperson/Purchaser"."Discount Amount")
            {
                IncludeCaption = true;
            }
            column(DiscountPct;DiscountPct)
            {
            }
            column(SalesPct;SalesPct)
            {
            }
            column(db;Db)
            {
            }
            column(dg;Dg)
            {
            }
            column(ExclVatCaption;ExclVatCaption_Lbl)
            {
            }
            column(TurnoverCaption;TurnoverCaptionLbl)
            {
            }
            column(DiscountPctCaption;DiscountPctCaptionLbl)
            {
            }
            column(TurnoverPctCaption;TurnoverPctCaptionLbl)
            {
            }
            column(ProfitCaption;ProfitCaptionLbl)
            {
            }
            column(ProfitPctCaption;ProfitPctCaptionLbl)
            {
            }
            column(Integer_Number;Integer.Number)
            {
            }
            column(SalesTotal;SalesTotal)
            {
            }
            column(dgTotal;DgTotal)
            {
            }
            column(DiscountPctTotal;DiscountPctTotal)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                  if not SalesPersonTemp.FindFirst then
                    CurrReport.Break;
                end else
                  if SalesPersonTemp.Next = 0 then
                      CurrReport.Break;

                if "Salesperson/Purchaser".Get(SalesPersonTemp."Vendor No.") then
                  "Salesperson/Purchaser".CalcFields("Sales (LCY)","Discount Amount", "COGS (LCY)");

                Db := "Salesperson/Purchaser"."Sales (LCY)" - "Salesperson/Purchaser"."COGS (LCY)";
                J := IncStr(J);
                if "Salesperson/Purchaser"."Sales (LCY)" <> 0 then
                  Dg := (Db / "Salesperson/Purchaser"."Sales (LCY)") * 100
                else
                  Dg := 0;

                if "Salesperson/Purchaser"."Discount Amount" <> 0 then
                  DiscountPct := "Salesperson/Purchaser"."Discount Amount" / ("Salesperson/Purchaser"."Sales (LCY)" + "Salesperson/Purchaser"."Discount Amount") * 100
                else
                  DiscountPct := 0;
            end;

            trigger OnPreDataItem()
            begin
                CurrReport.CreateTotals("Salesperson/Purchaser"."Discount Amount", Db, SalesPct);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowType;ShowType)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Turnover,Discount,Contribution Margin,Contribution Ratio';
                    }
                    field(Sorting;Sorting)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';
                    }
                    field(ShowQty;ShowQty)
                    {
                        Caption = 'Quantity';
                    }
                    field(OnlySales;OnlySales)
                    {
                        Caption = 'Only Salespersons With Sale';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        ShowType := ShowType::Turnover;
        Sorting := Sorting::Largest;
        ShowQty := 20;

        //-NPR5.39
        // Object.SETRANGE(ID, 6014406);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    trigger OnPreReport()
    begin
        J := '2';
        //-NPR5.39
        //ObjectDetails := FORMAT(Object.ID)+', '+FORMAT(Object."Version List");
        //+NPR5.39
    end;

    var
        SalespersonFilter: Text[250];
        ShowType: Option Turnover,Discount,"Contribution Margin","Contribution Ratio";
        Text001: Label 'Order By : %1';
        TextSort: Label 'Turnover,Discount,Contribution Margin,Contribution Ratio';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Report_Caption_Lbl: Label 'Sales Person Top 20';
        ExclVatCaption_Lbl: Label 'excl. VAT';
        Sorting: Option Largest,Smallest;
        ShowQty: Integer;
        I: Integer;
        SalesPersonTemp: Record "Vendor Amount" temporary;
        OnlySales: Boolean;
        Db: Decimal;
        Multipl: Integer;
        Dg: Decimal;
        J: Text[30];
        DiscountPct: Decimal;
        SalesPct: Decimal;
        SalesTotal: Decimal;
        TurnoverCaptionLbl: Label 'Turnover (LCY)';
        DiscountPctCaptionLbl: Label 'Discount Amount %';
        TurnoverPctCaptionLbl: Label '% of turnover';
        ProfitCaptionLbl: Label 'Profit (LCY)';
        ProfitPctCaptionLbl: Label 'Profit %';
        DgTotal: Decimal;
        DiscountPctTotal: Decimal;
}

