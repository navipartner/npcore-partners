report 6014435 "NPR Vendor/Item Category"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorItem Cat.rdlc';
    Caption = 'Vendor/Item Category';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            CalcFields = "NPR COGS (LCY)", "NPR Sales (LCY)", "Purchases (LCY)";
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "NPR Item Category Filter";
            column(ItemCategoryFilters; "Item Category".GetFilters)
            {
            }
            column(VendorFilters; GetFilters)
            {
            }
            column(No_Vendor; "No.")
            {
            }
            column(Name_Vendor; Name)
            {
            }
            column(PurchasesLCY_Vendor; "Purchases (LCY)")
            {
            }
            column(SalesLCY_Vendor; "NPR Sales (LCY)")
            {
            }
            column(SalesQty_Vendor; "NPR Sales (Qty.)")
            {
            }
            column(LY_SalesLCY_Vendor; Kreditorsidsteaar."NPR Sales (LCY)")
            {
            }
            column(LY_SalesQty_Vendor; Kreditorsidsteaar."NPR Sales (Qty.)")
            {
            }
            column(pctaendring_Vendor; PctaendringVen)
            {
            }
            column(DB_Vendor; "NPR Sales (LCY)" - "NPR COGS (LCY)")
            {
            }
            column(dg_Vendor; DG)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(viskunhovedtal; Viskunhovedtal)
            {
            }
            dataitem("Item Category"; "Item Category")
            {
                CalcFields = "NPR Sales (LCY)", "NPR Consumption (Amount)", "NPR Sales (Qty.)", "NPR Purchases (LCY)";
                DataItemLink = "NPR Vendor Filter" = FIELD("No."), "NPR Date Filter" = FIELD("Date Filter"), "NPR Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter");
                DataItemTableView = SORTING("Code");
                column(No_ItemCategory; "Code")
                {
                }
                column(Description_ItemCategory; Description)
                {
                }
                column(SaleLCY_ItemCategory; "NPR Sales (LCY)")
                {
                }
                column(PurchaseLCY_ItemCategory; "NPR Purchases (LCY)")
                {
                }
                column(PurchaseQty_ItemCategory; "NPR Purchases (Qty.)")
                {
                }
                column(pctoms; Pctoms)
                {
                }
                column(SalesQty_ItemCategory; "NPR Sales (Qty.)")
                {
                }
                column(CR_ItemCategory; "NPR Sales (LCY)" - "NPR Consumption (Amount)")
                {
                }
                column(dg_ItemCategory; DG)
                {
                }
                column(AmtLY_ItemCategory; Antalsidsteaar)
                {
                }
                column(TurnoverLY_ItemCategory; Omsaetningsidsteaar)
                {
                }
                column(sortervaregruppe_ItemCategory; Sortervaregruppe)
                {
                }
                column(viskunhovedtal_ItemCategory; Viskunhovedtal)
                {
                }
                column(SaleLCYLY_ItemCategory; Varegrupperec."NPR Sales (LCY)")
                {
                }
                column(PctaendringItemCategory; PctaendringItemCategory)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(DG);
                    Clear(Omsaetningsidsteaar);

                    if not ("NPR Sales (Qty.)" <> 0) then
                        CurrReport.Skip();

                    if "NPR Sales (LCY)" <> 0 then
                        DG := (("NPR Sales (LCY)" - "NPR Consumption (Amount)") / "NPR Sales (LCY)") * 100;

                    //Finder omsaetningen for sidste aar
                    Varegrupperec.Get("Code");
                    Varegrupperec.SetRange("NPR Vendor Filter", Vendor."No.");
                    Varegrupperec.SetRange("NPR Date Filter", Foerfra, Foertil);

                    if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                        Varegrupperec.SetRange("NPR Global Dimension 1 Filter", Vendor.GetFilter("Global Dimension 1 Filter"));

                    Varegrupperec.CalcFields("NPR Sales (LCY)");
                    Varegrupperec.CalcFields("NPR Sales (Qty.)");

                    Omsaetningsidsteaar := Varegrupperec."NPR Sales (LCY)";
                    Antalsidsteaar := Varegrupperec."NPR Sales (Qty.)";

                    if Sortervaregruppe then begin
                        if Vendor."NPR Sales (LCY)" <> 0 then
                            Pctoms := "NPR Sales (LCY)" / Vendor."NPR Sales (LCY)" * 100
                        else
                            Clear(Pctoms);

                        TempNPRBuffer.Init();
                        TempNPRBuffer.Template := "Code";
                        TempNPRBuffer."Line No." := 0;
                        case SortType of
                            SortType::antal:
                                TempNPRBuffer."Decimal 1" := "NPR Sales (Qty.)";
                            SortType::omsaetning:
                                TempNPRBuffer."Decimal 1" := "NPR Sales (LCY)";
                            SortType::db:
                                TempNPRBuffer."Decimal 1" := ("NPR Sales (LCY)" - "NPR Consumption (Amount)");
                        end;

                        TempNPRBuffer."Decimal 2" := Omsaetningsidsteaar;
                        TempNPRBuffer."Decimal 3" := Pctoms;
                        TempNPRBuffer."Decimal 4" := Antalsidsteaar;
                        TempNPRBuffer.Insert();
                    end;

                    if "NPR Sales (LCY)" <> 0 then
                        DG := (("NPR Sales (LCY)" - "NPR Consumption (Amount)") / "NPR Sales (LCY)") * 100;

                    PurchasesQtyCnt += "Item Category"."NPR Purchases (Qty.)";
                    SaleLCYSum += "Item Category"."NPR Sales (LCY)";
                    PurchaseLCYSum += "Item Category"."NPR Purchases (LCY)";
                    Pctoms_Sum += Pctoms;
                    SalesQtySum += "Item Category"."NPR Sales (Qty.)";
                    CRSum += ("Item Category"."NPR Sales (LCY)" - "Item Category"."NPR Consumption (Amount)");
                    if "NPR Sales (LCY)" <> 0 then
                        DgSum += (("NPR Sales (LCY)" - "NPR Consumption (Amount)") / "NPR Sales (LCY)") * 100;

                    AmtLYSum += Antalsidsteaar;
                    TurnoverLYSum += Omsaetningsidsteaar;
                    SaleLCYLYSum += Varegrupperec."NPR Sales (LCY)";
                    SumCost += "NPR Consumption (Amount)";

                    if Varegrupperec."NPR Sales (LCY)" <> 0 then
                        PctaendringItemCategory := (("NPR Sales (LCY)" - Varegrupperec."NPR Sales (LCY)") / (Varegrupperec."NPR Sales (LCY)")) * 100
                    else
                        Clear(PctaendringItemCategory);
                end;

                trigger OnPreDataItem()
                begin
                    TempNPRBuffer.DeleteAll();
                    if Vendor.GetFilter("NPR Item Category Filter") <> '' then
                        SetFilter("Code", Vendor.GetFilter("NPR Item Category Filter"));
                    if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                        SetFilter("NPR Global Dimension 1 Filter", Vendor.GetFilter("Global Dimension 1 Filter"));
                end;
            }
            dataitem(ItemGrpSum; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                MaxIteration = 1;
                column(Number_ItemGrpSum; ItemGrpSum.Number)
                {
                }
                column(PurchasesQtyCnt_ItemGrpSum; PurchasesQtyCnt)
                {
                }
                column(SaleLCYSum_ItemGrpSum; SaleLCYSum)
                {
                }
                column(PurchaseLCYSum_ItemGrpSum; PurchaseLCYSum)
                {
                }
                column(pctoms_Sum_ItemGrpSum; Pctoms_Sum)
                {
                }
                column(SalesQtySum_ItemGrpSum; SalesQtySum)
                {
                }
                column(CRSum_ItemGrpSum; CRSum)
                {
                }
                column(dgSum_ItemGrpSum; DgSum)
                {
                }
                column(AmtLYSum_ItemGrpSum; AmtLYSum)
                {
                }
                column(TurnoverLYSum_ItemGrpSum; TurnoverLYSum)
                {
                }
                column(SaleLCYLYSum_ItemGrpSum; SaleLCYLYSum)
                {
                }
                column(VendorPctoms; VendorPctoms)
                {
                }
                column(SumPctaendringItemCategory; SumPctaendringItemCategory)
                {
                }
                column(CRSumPct; CRSumPct)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (not Viskunhovedtal) and (SaleLCYSum = 0) and (PurchasesQtyCnt = 0) and (PurchaseLCYSum = 0) and (Pctoms_Sum = 0) and (SalesQtySum = 0) and (CRSum = 0) and
                       (DgSum = 0) and (AmtLYSum = 0) and (TurnoverLYSum = 0) and (SaleLCYLYSum = 0) then
                        CurrReport.Break();

                    if (CRSum <> 0) and (SaleLCYSum <> 0) then
                        CRSumPct := (CRSum / SaleLCYSum) * 100
                    else
                        CRSumPct := 0;

                    TotalPurchasesQty += PurchasesQtyCnt;
                    TotalPurchases += PurchaseLCYSum;
                    TotalSaleLCY += SaleLCYSum;
                    TotalCr += CRSum;
                    TotalLastYr += TurnoverLYSum;
                    TotalQty += SalesQtySum;
                    TotalSaleLCYYr += AmtLYSum;
                    TotalCost += SumCost;

                    if TurnoverLYSum <> 0 then
                        SumPctaendringItemCategory := ((SaleLCYSum - TurnoverLYSum) / (TurnoverLYSum)) * 100
                    else
                        Clear(SumPctaendringItemCategory);
                    VendorPctoms := (SaleLCYSum / Vendor."NPR Sales (LCY)") * 100;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; Integer.Number)
                {
                }
                column(No_ItemCategory2; "Item Category"."Code")
                {
                }
                column(Description_ItemCategory2; "Item Category".Description)
                {
                }
                column(SaleLCY_ItemCategory2; "Item Category"."NPR Sales (LCY)")
                {
                }
                column(PurchaseLCY_ItemCategory2; "Item Category"."NPR Purchases (LCY)")
                {
                }
                column(SalesQty_ItemCategory2; "Item Category"."NPR Sales (Qty.)")
                {
                }
                column(CR_ItemCategory2; "Item Category"."NPR Sales (LCY)" - "Item Category"."NPR Consumption (Amount)")
                {
                }
                column(PurchaseQty_ItemCategory2; "Item Category"."NPR Purchases (Qty.)")
                {
                }
                column(dg_ItemCategory2; DG)
                {
                }
                column(TurnoverLY_ItemCategory2; TempNPRBuffer."Decimal 2")
                {
                }
                column(pctoms2; TempNPRBuffer."Decimal 3")
                {
                }
                column(AmtLY_ItemCategory2; TempNPRBuffer."Decimal 4")
                {
                }
                column(PctaendringItemCategory2; PctaendringItemCategory)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempNPRBuffer.FindFirst() then
                            CurrReport.Break();
                    end else
                        if TempNPRBuffer.Next() = 0 then
                            CurrReport.Break();

                    "Item Category".Get(TempNPRBuffer.Template);
                    "Item Category".CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                    Clear(DG);
                    if "Item Category"."NPR Sales (LCY)" <> 0 then
                        DG := (("Item Category"."NPR Sales (LCY)" - "Item Category"."NPR Consumption (Amount)") / "Item Category"."NPR Sales (LCY)") * 100;

                    if TempNPRBuffer."Decimal 2" <> 0 then
                        PctaendringItemCategory := (("Item Category"."NPR Sales (LCY)" - TempNPRBuffer."Decimal 2") / (TempNPRBuffer."Decimal 2")) * 100
                    else
                        Clear(PctaendringItemCategory);
                end;

                trigger OnPreDataItem()
                begin
                    if (not Sortervaregruppe) then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                PurchasesQtyCnt := 0;
                PurchasesQtyCnt := 0;
                SaleLCYSum := 0;
                PurchaseLCYSum := 0;
                Pctoms_Sum := 0;
                SalesQtySum := 0;
                CRSum := 0;
                DgSum := 0;
                AmtLYSum := 0;
                TurnoverLYSum := 0;
                SaleLCYLYSum := 0;
                SumCost := 0;
                CalcFields("NPR Sales (Qty.)", "Purchases (LCY)", "NPR Sales (LCY)");

                Kreditorsidsteaar.Get("No.");
                Kreditorsidsteaar.SetRange("Date Filter", Foerfra, Foertil);
                if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                    Kreditorsidsteaar.SetFilter("Global Dimension 1 Filter", GetFilter(Vendor."Global Dimension 1 Filter"));
                Kreditorsidsteaar.CalcFields("NPR Sales (LCY)", "NPR Sales (Qty.)", "Purchases (LCY)");

                if "NPR Sales (LCY)" = 0 then
                    CurrReport.Skip();
                Clear(DG);
                if "NPR Sales (LCY)" <> 0 then
                    DG := (("NPR Sales (LCY)" - "NPR COGS (LCY)") / "NPR Sales (LCY)") * 100;

                if Kreditorsidsteaar."NPR Sales (LCY)" <> 0 then
                    PctaendringVen := ((Vendor."NPR Sales (LCY)" - Kreditorsidsteaar."NPR Sales (LCY)") / (Kreditorsidsteaar."NPR Sales (LCY)")) * 100
                else
                    Clear(PctaendringVen);

                TotalVendorSalesLCY += "NPR Sales (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                PurchasesQtyCnt := 0;
                PurchasesQtyCnt := 0;
                SaleLCYSum := 0;
                PurchaseLCYSum := 0;
                Pctoms_Sum := 0;
                SalesQtySum := 0;
                CRSum := 0;
                DgSum := 0;
                AmtLYSum := 0;
                TurnoverLYSum := 0;
                SaleLCYLYSum := 0;
                SumCost := 0;
            end;
        }
        dataitem(Summary; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            MaxIteration = 1;
            column(Number_Summary; Summary.Number)
            {
            }
            column(TotalPurchases_Summary; TotalPurchases)
            {
            }
            column(TotalPurchasesQty_Summary; TotalPurchasesQty)
            {
            }
            column(Totaloms_Summary; TotalSaleLCY)
            {
            }
            column(totalantal_Summary; TotalQty)
            {
            }
            column(CR_Summary; TotalCr)
            {
            }
            column(CRPct_Summary; TotalCrPct)
            {
            }
            column(omsaetningsidsteaar_Summary; TotalLastYr)
            {
            }
            column(TotalPctoms; TotalPctoms)
            {
            }
            column(TotalSaleLCYYr; TotalSaleLCYYr)
            {
            }
            column(TotalPctaendringItemCategory; TotalPctaendringItemCategory)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if TotalSaleLCY <> 0 then
                    TotalCrPct := (((TotalSaleLCY - TotalCost) / TotalSaleLCY) * 100);

                if TotalVendorSalesLCY <> 0 then
                    TotalPctoms := (TotalSaleLCY / TotalVendorSalesLCY) * 100;

                if TotalLastYr <> 0 then
                    TotalPctaendringItemCategory := ((TotalSaleLCY - TotalLastYr) / (TotalLastYr)) * 100
                else
                    Clear(TotalPctaendringItemCategory);
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
                    field("vis kun hovedtal"; Viskunhovedtal)
                    {
                        Caption = 'Show Only Main Figures';

                        ToolTip = 'Specifies the value of the Show Only Main Figures field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sortervare gruppe"; Sortervaregruppe)
                    {
                        Caption = 'Sort Item Category';

                        ToolTip = 'Specifies the value of the Sort Item Category field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if Sortervaregruppe then
                                ShowBool := true
                            else
                                ShowBool := false;
                        end;
                    }
                    field(sorterefter; SortType)
                    {
                        Caption = 'Show';
                        Enabled = ShowBool;
                        OptionCaption = 'Amount,Turnover,DR';

                        ToolTip = 'Specifies the value of the Show field';
                        ApplicationArea = NPRRetail;
                    }
                    field(sorter; SortOrder)
                    {
                        Caption = 'Show Largest/Smallest';
                        Enabled = ShowBool;
                        OptionCaption = 'Most,Least';

                        ToolTip = 'Specifies the value of the Show Largest/Smallest field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ShowBool := false;
        end;
    }

    labels
    {
        Report_Caption = 'Vendor/Item Category';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        Purchases_Caption = 'Purchases';
        ItemSales_Caption = 'Itemsales';
        LastYear_Caption = 'Last year';
        PctChanges_Caption = '% Changes';
        DB_Caption = 'DB';
        Pct_Caption = '%-del';
        ItemCategory_Caption = 'Item Category';
        Description_Caption = 'Description';
        PurItemCat_Caption = 'Purchases, Item Category';
        Turnover_Caption = 'Turnover';
        SalesQty_Caption = 'Sales (Qty)';
        CR_Caption = 'CR';
        CRPct_Caption = 'CR%';
        LastYrAmt_Caption = 'AmtLastYr';
        LastYrTurnover_Caption = 'Turnover last year';
        PurchasesQty_Caption = 'Purchases (qty)';
        NegPctChanges = '%-Changes';
        Total_Caption = 'Total';
        SalesAmt_Caption = 'Sales Amount';
        TotalItemCat = 'Total Item Category';
        PageNoLbl = 'Page';
    }

    trigger OnInitReport()
    begin
        Viskunhovedtal := false;
    end;

    trigger OnPreReport()
    begin
        Foerfra := CalcDate('<-1Y>', Vendor.GetRangeMin("Date Filter"));
        Foertil := CalcDate('<-1Y>', Vendor.GetRangeMax("Date Filter"));
        Omsaetningsidsteaar := 0;

        TempNPRBuffer.SetCurrentKey("Decimal 1");
        case SortOrder of
            SortOrder::Mindste:
                TempNPRBuffer.Ascending(false);
        end;
    end;

    var
        Varegrupperec: Record "Item Category";
        TempNPRBuffer: Record "NPR TEMP Buffer" temporary;
        Kreditorsidsteaar: Record Vendor;
        [InDataSet]
        ShowBool: Boolean;
        Sortervaregruppe: Boolean;
        Viskunhovedtal: Boolean;
        Foerfra: Date;
        Foertil: Date;
        AmtLYSum: Decimal;
        Antalsidsteaar: Decimal;
        CRSum: Decimal;
        CRSumPct: Decimal;
        DG: Decimal;
        DgSum: Decimal;
        Omsaetningsidsteaar: Decimal;
        PctaendringItemCategory: Decimal;
        PctaendringVen: Decimal;
        Pctoms: Decimal;
        Pctoms_Sum: Decimal;
        PurchaseLCYSum: Decimal;
        PurchasesQtyCnt: Decimal;
        SaleLCYLYSum: Decimal;
        SaleLCYSum: Decimal;
        SalesQtySum: Decimal;
        SumCost: Decimal;
        SumPctaendringItemCategory: Decimal;
        TotalCost: Decimal;
        TotalCr: Decimal;
        TotalCrPct: Decimal;
        TotalLastYr: Decimal;
        TotalPctaendringItemCategory: Decimal;
        TotalPctoms: Decimal;
        TotalPurchases: Decimal;
        TotalPurchasesQty: Decimal;
        TotalQty: Decimal;
        TotalSaleLCY: Decimal;
        TotalSaleLCYYr: Decimal;
        TotalVendorSalesLCY: Decimal;
        TurnoverLYSum: Decimal;
        VendorPctoms: Decimal;
        SortType: Option antal,omsaetning,db;
        SortOrder: Option Stoerste,Mindste;
}

