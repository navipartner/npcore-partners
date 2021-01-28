report 6014435 "NPR Vendor/Item Group"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorItem Group.rdlc';
    Caption = 'Vendor/Item Group';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(Vendor; Vendor)
        {
            CalcFields = "NPR COGS (LCY)", "NPR Sales (LCY)", "Purchases (LCY)";
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "NPR Item Group Filter";
            column(ItemGroupFilters; "Item Group".GetFilters)
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
            dataitem("Item Group"; "NPR Item Group")
            {
                CalcFields = "Sales (LCY)", "Consumption (Amount)", "Sales (Qty.)", "Purchases (LCY)";
                DataItemLink = "Vendor Filter" = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter");
                DataItemTableView = SORTING("No.");
                column(No_ItemGroup; "No.")
                {
                }
                column(Description_ItemGroup; Description)
                {
                }
                column(SaleLCY_ItemGroup; "Sales (LCY)")
                {
                }
                column(PurchaseLCY_ItemGroup; "Purchases (LCY)")
                {
                }
                column(PurchaseQty_ItemGroup; "Purchases (Qty.)")
                {
                }
                column(pctoms; Pctoms)
                {
                }
                column(SalesQty_ItemGroup; "Sales (Qty.)")
                {
                }
                column(CR_ItemGroup; "Sales (LCY)" - "Consumption (Amount)")
                {
                }
                column(dg_ItemGroup; DG)
                {
                }
                column(AmtLY_ItemGroup; Antalsidsteaar)
                {
                }
                column(TurnoverLY_ItemGroup; Omsaetningsidsteaar)
                {
                }
                column(sortervaregruppe_ItemGroup; Sortervaregruppe)
                {
                }
                column(viskunhovedtal_ItemGroup; Viskunhovedtal)
                {
                }
                column(SaleLCYLY_ItemGroup; Varegrupperec."Sales (LCY)")
                {
                }
                column(PctaendringItemGroup; PctaendringItemGroup)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(DG);
                    Clear(Omsaetningsidsteaar);

                    if not ("Sales (Qty.)" <> 0) then
                        CurrReport.Skip();

                    if "Sales (LCY)" <> 0 then
                        DG := (("Sales (LCY)" - "Consumption (Amount)") / "Sales (LCY)") * 100;

                    //Finder omsaetningen for sidste aar
                    Varegrupperec.Get("No.");
                    Varegrupperec.SetRange("Vendor Filter", Vendor."No.");
                    Varegrupperec.SetRange("Date Filter", Foerfra, Foertil);

                    if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                        Varegrupperec.SetRange("Global Dimension 1 Filter", Vendor.GetFilter("Global Dimension 1 Filter"));

                    Varegrupperec.CalcFields("Sales (LCY)");
                    Varegrupperec.CalcFields("Sales (Qty.)");

                    Omsaetningsidsteaar := Varegrupperec."Sales (LCY)";
                    Antalsidsteaar := Varegrupperec."Sales (Qty.)";

                    if Sortervaregruppe then begin
                        if Vendor."NPR Sales (LCY)" <> 0 then
                            Pctoms := "Sales (LCY)" / Vendor."NPR Sales (LCY)" * 100
                        else
                            Clear(Pctoms);

                        TempNPRBuffer.Init();
                        TempNPRBuffer.Template := "No.";
                        TempNPRBuffer."Line No." := 0;
                        case Sorterefter of
                            Sorterefter::antal:
                                TempNPRBuffer."Decimal 1" := "Sales (Qty.)";
                            Sorterefter::omsaetning:
                                TempNPRBuffer."Decimal 1" := "Sales (LCY)";
                            Sorterefter::db:
                                TempNPRBuffer."Decimal 1" := ("Sales (LCY)" - "Consumption (Amount)");
                        end;

                        TempNPRBuffer."Decimal 2" := Omsaetningsidsteaar;
                        TempNPRBuffer."Decimal 3" := Pctoms;
                        TempNPRBuffer."Decimal 4" := Antalsidsteaar;
                        TempNPRBuffer.Insert();
                    end;

                    if "Sales (LCY)" <> 0 then
                        DG := (("Sales (LCY)" - "Consumption (Amount)") / "Sales (LCY)") * 100;

                    PurchasesQtyCnt += "Item Group"."Purchases (Qty.)";
                    SaleLCYSum += "Item Group"."Sales (LCY)";
                    PurchaseLCYSum += "Item Group"."Purchases (LCY)";
                    Pctoms_Sum += Pctoms;
                    SalesQtySum += "Item Group"."Sales (Qty.)";
                    CRSum += ("Item Group"."Sales (LCY)" - "Item Group"."Consumption (Amount)");
                    if "Sales (LCY)" <> 0 then
                        DgSum += (("Sales (LCY)" - "Consumption (Amount)") / "Sales (LCY)") * 100;

                    AmtLYSum += Antalsidsteaar;
                    TurnoverLYSum += Omsaetningsidsteaar;
                    SaleLCYLYSum += Varegrupperec."Sales (LCY)";
                    SumCost += "Consumption (Amount)";

                    if Varegrupperec."Sales (LCY)" <> 0 then
                        PctaendringItemGroup := (("Sales (LCY)" - Varegrupperec."Sales (LCY)") / (Varegrupperec."Sales (LCY)")) * 100
                    else
                        Clear(PctaendringItemGroup);
                end;

                trigger OnPreDataItem()
                begin
                    TempNPRBuffer.DeleteAll();
                    if Vendor.GetFilter("NPR Item Group Filter") <> '' then
                        SetFilter("No.", Vendor.GetFilter("NPR Item Group Filter"));
                    if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                        SetFilter("Global Dimension 1 Filter", Vendor.GetFilter("Global Dimension 1 Filter"));
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
                column(SumPctaendringItemGroup; SumPctaendringItemGroup)
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
                        SumPctaendringItemGroup := ((SaleLCYSum - TurnoverLYSum) / (TurnoverLYSum)) * 100
                    else
                        Clear(SumPctaendringItemGroup);
                    VendorPctoms := (SaleLCYSum / Vendor."NPR Sales (LCY)") * 100;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; Integer.Number)
                {
                }
                column(No_ItemGroup2; "Item Group"."No.")
                {
                }
                column(Description_ItemGroup2; "Item Group".Description)
                {
                }
                column(SaleLCY_ItemGroup2; "Item Group"."Sales (LCY)")
                {
                }
                column(PurchaseLCY_ItemGroup2; "Item Group"."Purchases (LCY)")
                {
                }
                column(SalesQty_ItemGroup2; "Item Group"."Sales (Qty.)")
                {
                }
                column(CR_ItemGroup2; "Item Group"."Sales (LCY)" - "Item Group"."Consumption (Amount)")
                {
                }
                column(PurchaseQty_ItemGroup2; "Item Group"."Purchases (Qty.)")
                {
                }
                column(dg_ItemGroup2; DG)
                {
                }
                column(TurnoverLY_ItemGroup2; TempNPRBuffer."Decimal 2")
                {
                }
                column(pctoms2; TempNPRBuffer."Decimal 3")
                {
                }
                column(AmtLY_ItemGroup2; TempNPRBuffer."Decimal 4")
                {
                }
                column(PctaendringItemGroup2; PctaendringItemGroup)
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

                    "Item Group".Get(TempNPRBuffer.Template);
                    "Item Group".CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                    Clear(DG);
                    if "Item Group"."Sales (LCY)" <> 0 then
                        DG := (("Item Group"."Sales (LCY)" - "Item Group"."Consumption (Amount)") / "Item Group"."Sales (LCY)") * 100;

                    if TempNPRBuffer."Decimal 2" <> 0 then
                        PctaendringItemGroup := (("Item Group"."Sales (LCY)" - TempNPRBuffer."Decimal 2") / (TempNPRBuffer."Decimal 2")) * 100
                    else
                        Clear(PctaendringItemGroup);
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
                PctChanges := 0;
                SumCost := 0;
                CalcFields("NPR Sales (Qty.)", "Purchases (LCY)", "NPR Sales (LCY)");

                Kreditorsidsteaar.Get("No.");
                Kreditorsidsteaar.SetRange("Date Filter", Foerfra, Foertil);
                if Vendor.GetFilter("Global Dimension 1 Filter") <> '' then
                    Kreditorsidsteaar.SetFilter("Global Dimension 1 Filter", GetFilter(Vendor."Global Dimension 1 Filter"));
                Kreditorsidsteaar.CalcFields("NPR Sales (LCY)", "NPR Sales (Qty.)", "Purchases (LCY)");

                if "NPR Sales (LCY)" = 0 then
                    CurrReport.Skip;
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
                PctChanges := 0;
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
            column(TotalPctaendringItemGroup; TotalPctaendringItemGroup)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if TotalSaleLCY <> 0 then
                    TotalCrPct := (((TotalSaleLCY - TotalCost) / TotalSaleLCY) * 100);

                if TotalVendorSalesLCY <> 0 then
                    TotalPctoms := (TotalSaleLCY / TotalVendorSalesLCY) * 100;

                if TotalLastYr <> 0 then
                    TotalPctaendringItemGroup := ((TotalSaleLCY - TotalLastYr) / (TotalLastYr)) * 100
                else
                    Clear(TotalPctaendringItemGroup);
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
                    field(viskunhovedtal; Viskunhovedtal)
                    {
                        Caption = 'Show Only Main Figures';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Only Main Figures field';
                    }
                    field(sortervaregruppe; Sortervaregruppe)
                    {
                        Caption = 'Sort Item Groups';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sort Item Groups field';

                        trigger OnValidate()
                        begin
                            if Sortervaregruppe then
                                ShowBool := true
                            else
                                ShowBool := false;
                        end;
                    }
                    field(sorterefter; Sorterefter)
                    {
                        Caption = 'Show';
                        Enabled = ShowBool;
                        OptionCaption = 'Amount,Turnover,DR';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show field';
                    }
                    field(sorter; Sorter)
                    {
                        Caption = 'Show Largest/Smallest';
                        Enabled = ShowBool;
                        OptionCaption = 'Most,Least';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Largest/Smallest field';
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
        Report_Caption = 'Vendor/Item Group';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        Purchases_Caption = 'Purchases';
        ItemSales_Caption = 'Itemsales';
        LastYear_Caption = 'Last year';
        PctChanges_Caption = '% Changes';
        DB_Caption = 'DB';
        Pct_Caption = '%-del';
        ItemGroup_Caption = 'Itemgroups';
        Description_Caption = 'Description';
        PurItemGrp_Caption = 'Purchases, itemgroups';
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
        TotalItemGrp = 'Total Item Group';
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
        Totalantal := 0;

        TempNPRBuffer.SetCurrentKey("Decimal 1");
        case Sorter of
            Sorter::Mindste:
                TempNPRBuffer.Ascending(false);
        end;
    end;

    var
        Varegrupperec: Record "NPR Item Group";
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
        PctaendringItemGroup: Decimal;
        PctaendringVen: Decimal;
        PctChanges: Decimal;
        Pctoms: Decimal;
        Pctoms_Sum: Decimal;
        PurchaseLCYSum: Decimal;
        PurchasesQtyCnt: Decimal;
        SaleLCYLYSum: Decimal;
        SaleLCYSum: Decimal;
        SalesQtySum: Decimal;
        SumCost: Decimal;
        SumPctaendringItemGroup: Decimal;
        Totalantal: Decimal;
        TotalCost: Decimal;
        TotalCr: Decimal;
        TotalCrPct: Decimal;
        TotalLastYr: Decimal;
        TotalPctaendringItemGroup: Decimal;
        TotalPctoms: Decimal;
        TotalPurchases: Decimal;
        TotalPurchasesQty: Decimal;
        TotalQty: Decimal;
        TotalSaleLCY: Decimal;
        TotalSaleLCYYr: Decimal;
        TotalVendorSalesLCY: Decimal;
        TurnoverLYSum: Decimal;
        VendorPctoms: Decimal;
        Sorterefter: Option antal,omsaetning,db;
        Sorter: Option Stoerste,Mindste;
}

