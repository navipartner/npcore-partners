report 6014406 "NPR Sales Person Top 20"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Salesperson Top 20.rdlc';
    Caption = 'Salesperson Top 20';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            RequestFilterFields = "Code", "Date Filter", "NPR Global Dimension 1 Filter";

            trigger OnAfterGetRecord()
            begin
                "Salesperson/Purchaser".NPRGetVESalesCostDiscount(SalesLCY, COGSLCY, DiscountAmount);
                if OnlySales then
                    if SalesLCY = 0 then
                        CurrReport.Skip();

                TempSalesPerson.Init();
                TempSalesPerson."Vendor No." := "Salesperson/Purchaser".Code;

                if SortOrder = SortOrder::Largest then
                    Multipl := -1
                else
                    Multipl := 1;

                Db := (SalesLCY - COGSLCY);

                if SalesLCY <> 0 then
                    Dg := (Db / SalesLCY) * 100

                else
                    Dg := 0;

                case ShowType of
                    ShowType::Turnover:
                        begin
                            TempSalesPerson."Amount (LCY)" := Multipl * SalesLCY;
                            TempSalesPerson."Amount 2 (LCY)" := Multipl * DiscountAmount;
                        end;
                    ShowType::Discount:
                        begin
                            TempSalesPerson."Amount (LCY)" := Multipl * DiscountAmount;
                            TempSalesPerson."Amount 2 (LCY)" := Multipl * SalesLCY;
                        end;
                    ShowType::"Contribution Margin":
                        TempSalesPerson."Amount (LCY)" := Multipl * Db;

                    ShowType::"Contribution Ratio":
                        TempSalesPerson."Amount (LCY)" := Multipl * Dg;

                end;

                TempSalesPerson.Insert();

                if (I = 0) or (I < ShowQty) then
                    I := I + 1
                else begin
                    TempSalesPerson.FindLast();
                    TempSalesPerson.Delete();
                end;

                SalesTotal += SalesLCY;

                if SalesTotal <> 0 then
                    SalesPct := ((SalesLCY) / SalesTotal) * 100;

                if SalesLCY <> 0 then
                    DgTotal += (Db / SalesLCY) * 100;

                if DiscountAmount <> 0 then
                    DiscountPctTotal += DiscountAmount / (SalesLCY + DiscountAmount) * 100;
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
            column(OrderBy_ShowTypeFilter; StrSubstNo(Text001, SelectStr(ShowType + 1, TextSort1)))
            {
            }
            column(OrderBy_SortOrderFilter; StrSubstNo(Text001, Format(SortOrder)))
            {
            }
            column(OrderBy_ShowQtyFilter; StrSubstNo(Text002, ShowQty))
            {
            }
            column(OrderBy_OnlySalesFilter; StrSubstNo(Text003, OnlySales))
            {
            }
            column(Salesperson_Purchaser_Name; "Salesperson/Purchaser".Name)
            {
                IncludeCaption = true;
            }
            column(Salesperson_Purchaser_Sales_LCY_; SalesLCY)
            {
            }
            column(Salesperson_Purchaser_Discount_AmountCaption; Discount_Amount_CaptionLbl)
            {
            }
            column(Salesperson_Purchaser_Discount_Amount; DiscountAmount)
            {
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
                    "Salesperson/Purchaser".NPRGetVESalesCostDiscount(SalesLCY, COGSLCY, DiscountAmount);

                Db := SalesLCY - COGSLCY;
                J := IncStr(J);
                if SalesLCY <> 0 then
                    Dg := (Db / SalesLCY) * 100
                else
                    Dg := 0;

                if DiscountAmount <> 0 then
                    DiscountPct := DiscountAmount / (SalesLCY + DiscountAmount) * 100
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
                        Caption = 'Show Salespersons with Sales Only';
                        ToolTip = 'View only salespersons who have performed sales for the indicated period';
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
        TurnoverPctCaptionLbl: Label '% of Turnover';
        DiscountPctCaptionLbl: Label 'Discount Amount %';
        ExclVatCaption_Lbl: Label 'excl. VAT';
        Text001: Label 'Order By: %1';
        Text002: Label 'Order Qty: %1';
        Text003: Label 'Order Only Sales: %1';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        ProfitPctCaptionLbl: Label 'Profit %';
        ProfitCaptionLbl: Label 'Profit (LCY)';
        Report_Caption_Lbl: Label 'Salesperson Top 20';
        TurnoverCaptionLbl: Label 'Turnover (LCY)';
        TextSort1: Label 'Turnover,Discount,Contribution Margin,Contribution Ratio';
        Discount_Amount_CaptionLbl: Label 'Discount Amount';
        SortOrder: Option Largest,Smallest;
        ShowType: Option Turnover,Discount,"Contribution Margin","Contribution Ratio";
        J: Text[30];
        SalespersonFilter: Text;
        SalesLCY: Decimal;
        DiscountAmount: Decimal;
        COGSLCY: Decimal;
}

