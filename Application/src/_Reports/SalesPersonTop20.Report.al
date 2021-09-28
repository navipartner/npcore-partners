report 6014406 "NPR Sales Person Top 20"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Person Top 20.rdlc';
    Caption = 'Sales Person Top 20';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            CalcFields = "NPR Sales (LCY)", "NPR Discount Amount", "NPR COGS (LCY)";
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";

            trigger OnAfterGetRecord()
            begin
                if OnlySales then
                    if "Salesperson/Purchaser"."NPR Sales (LCY)" = 0 then
                        CurrReport.Skip();

                TempSalesPerson.Init();
                TempSalesPerson."Vendor No." := "Salesperson/Purchaser".Code;

                if SortOrder = SortOrder::Largest then
                    Multipl := -1
                else
                    Multipl := 1;

                Db := ("NPR Sales (LCY)" - "NPR COGS (LCY)");

                if "Salesperson/Purchaser"."NPR Sales (LCY)" <> 0 then
                    Dg := (Db / "Salesperson/Purchaser"."NPR Sales (LCY)") * 100
                else
                    Dg := 0;

                case ShowType of
                    ShowType::Turnover:
                        begin
                            TempSalesPerson."Amount (LCY)" := Multipl * "NPR Sales (LCY)";
                            TempSalesPerson."Amount 2 (LCY)" := Multipl * "NPR Discount Amount";
                        end;
                    ShowType::Discount:
                        begin
                            TempSalesPerson."Amount (LCY)" := Multipl * "NPR Discount Amount";
                            TempSalesPerson."Amount 2 (LCY)" := Multipl * "NPR Sales (LCY)";
                        end;
                    ShowType::"Contribution Margin":
                        TempSalesPerson."Amount (LCY)" := Multipl * Db;
                end;

                TempSalesPerson.Insert();

                if (I = 0) or (I < ShowQty) then
                    I := I + 1
                else begin
                    TempSalesPerson.FindLast();
                    TempSalesPerson.Delete();
                end;

                SalesTotal += "NPR Sales (LCY)";

                if SalesTotal <> 0 then
                    SalesPct := (("Salesperson/Purchaser"."NPR Sales (LCY)") / SalesTotal) * 100;

                if "Salesperson/Purchaser"."NPR Sales (LCY)" <> 0 then
                    DgTotal := (Db / "Salesperson/Purchaser"."NPR Sales (LCY)") * 100;

                if "Salesperson/Purchaser"."NPR Discount Amount" <> 0 then
                    DiscountPctTotal := "Salesperson/Purchaser"."NPR Discount Amount" / ("Salesperson/Purchaser"."NPR Sales (LCY)" + "Salesperson/Purchaser"."NPR Discount Amount") * 100
                else
                    DiscountPctTotal := 0;
            end;

            trigger OnPreDataItem()
            begin
                TempSalesPerson.DeleteAll();
                I := 0;
                SalespersonFilter := "Salesperson/Purchaser".GetFilter("Date Filter");
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Period_SalespersonFilter; 'Periode: ' + "Salesperson/Purchaser".GetFilter("Date Filter"))
            {
            }
            column(SalespersonFilter; SalespersonFilter)
            {
            }
            column(OrderBy_ShowTypeFilter; StrSubstNo(Text001, SelectStr(ShowType + 1, TextSort)))
            {
            }
            column(ShowQty; ShowQty)
            {
            }
            column(Salesperson_Purchaser_Name; "Salesperson/Purchaser".Name)
            {
                IncludeCaption = true;
            }
            column(Salesperson_Purchaser_Sales_LCY_; "Salesperson/Purchaser"."NPR Sales (LCY)")
            {
            }
            column(Salesperson_Purchaser_Discount_Amount; "Salesperson/Purchaser"."NPR Discount Amount")
            {
                IncludeCaption = true;
            }
            column(DiscountPct; DiscountPct)
            {
            }
            column(SalesPct; SalesPct)
            {
            }
            column(db; Db)
            {
            }
            column(dg; Dg)
            {
            }
            column(ExclVatCaption; ExclVatCaption_Lbl)
            {
            }
            column(TurnoverCaption; TurnoverCaptionLbl)
            {
            }
            column(DiscountPctCaption; DiscountPctCaptionLbl)
            {
            }
            column(TurnoverPctCaption; TurnoverPctCaptionLbl)
            {
            }
            column(ProfitCaption; ProfitCaptionLbl)
            {
            }
            column(ProfitPctCaption; ProfitPctCaptionLbl)
            {
            }
            column(Integer_Number; Integer.Number)
            {
            }
            column(SalesTotal; SalesTotal)
            {
            }
            column(dgTotal; DgTotal)
            {
            }
            column(DiscountPctTotal; DiscountPctTotal)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempSalesPerson.FindFirst() then
                        CurrReport.Break();
                end else
                    if TempSalesPerson.Next() = 0 then
                        CurrReport.Break();

                if "Salesperson/Purchaser".Get(TempSalesPerson."Vendor No.") then
                    "Salesperson/Purchaser".CalcFields("NPR Sales (LCY)", "NPR Discount Amount", "NPR COGS (LCY)");

                Db := "Salesperson/Purchaser"."NPR Sales (LCY)" - "Salesperson/Purchaser"."NPR COGS (LCY)";
                J := IncStr(J);
                if "Salesperson/Purchaser"."NPR Sales (LCY)" <> 0 then
                    Dg := (Db / "Salesperson/Purchaser"."NPR Sales (LCY)") * 100
                else
                    Dg := 0;

                if "Salesperson/Purchaser"."NPR Discount Amount" <> 0 then
                    DiscountPct := "Salesperson/Purchaser"."NPR Discount Amount" / ("Salesperson/Purchaser"."NPR Sales (LCY)" + "Salesperson/Purchaser"."NPR Discount Amount") * 100
                else
                    DiscountPct := 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Show Type"; ShowType)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Turnover,Discount,Contribution Margin,Contribution Ratio';

                        ToolTip = 'Specifies the value of the Sort By field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sorting"; SortOrder)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';

                        ToolTip = 'Specifies the value of the Sort By field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Qty"; ShowQty)
                    {
                        Caption = 'Quantity';

                        ToolTip = 'Specifies the value of the Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Only Sales"; OnlySales)
                    {
                        Caption = 'Only Salespersons With Sale';

                        ToolTip = 'Specifies the value of the Only Salespersons With Sale field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    trigger OnInitReport()
    begin
        ShowType := ShowType::Turnover;
        SortOrder := SortOrder::Largest;
        ShowQty := 20;
    end;

    trigger OnPreReport()
    begin
        J := '2';
    end;

    var
        TempSalesPerson: Record "Vendor Amount" temporary;
        OnlySales: Boolean;
        Db: Decimal;
        Dg: Decimal;
        DgTotal: Decimal;
        DiscountPct: Decimal;
        DiscountPctTotal: Decimal;
        SalesPct: Decimal;
        SalesTotal: Decimal;
        I: Integer;
        Multipl: Integer;
        ShowQty: Integer;
        TurnoverPctCaptionLbl: Label '% of turnover';
        DiscountPctCaptionLbl: Label 'Discount Amount %';
        ExclVatCaption_Lbl: Label 'excl. VAT';
        Text001: Label 'Order By : %1';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ProfitPctCaptionLbl: Label 'Profit %';
        ProfitCaptionLbl: Label 'Profit (LCY)';
        Report_Caption_Lbl: Label 'Sales Person Top 20';
        TurnoverCaptionLbl: Label 'Turnover (LCY)';
        TextSort: Label 'Turnover,Discount,Contribution Margin,Contribution Ratio';
        SortOrder: Option Largest,Smallest;
        ShowType: Option Turnover,Discount,"Contribution Margin","Contribution Ratio";
        J: Text[30];
        SalespersonFilter: Text;
}

