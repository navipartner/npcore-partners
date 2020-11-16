report 6014449 "NPR Vendor trx by Item group"
{
    // NPR70.00.00.00/LS  CASE 159377 : Convert Report to NAV 2013
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.55/BHR /20200219 CASE 361515 Change Key as it's not supported in extension
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor trn. by Item group.rdlc';

    Caption = 'Vendor Trn. By Item Group';
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem(vg; "NPR Item Group")
        {
            CalcFields = "Consumption (Amount)";
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "Vendor Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(DateFilters; GetFilter("Date Filter"))
            {
            }
            column(No_Filter; GetFilter("No."))
            {
            }
            column(GlobalDimension1_Filter; GetFilter("Global Dimension 1 Filter"))
            {
            }
            column(Vendor_Filter; GetFilter("Vendor Filter"))
            {
            }
            column(No_vg; vg."No.")
            {
            }
            column(Description_vg; vg.Description)
            {
            }
            column(PurchaseLCY_vg; vg."Purchases (LCY)")
            {
            }
            column(PurchaseQuantity_vg; vg."Purchases (Qty.)")
            {
            }
            column(SaleLCY_vg; vg."Sales (LCY)")
            {
            }
            column(SalesQty_vg; vg."Sales (Qty.)")
            {
            }
            column(pctvaresalgfjor_vg; pctvaresalgfjor)
            {
            }
            column(DB_vg; "Sales (LCY)" - "Consumption (Amount)")
            {
            }
            column(dgItemGrp_vg; dgItemGrp)
            {
            }
            column(pcttot_vg; pcttot)
            {
            }
            column(varekobfjor_vg; varekobfjor)
            {
            }
            column(varesalgfjor_vg; varesalgfjor)
            {
            }
            column(visudensalg; visudensalg)
            {
            }
            dataitem(Vendor; Vendor)
            {
                CalcFields = "NPR Sales (LCY)", "NPR COGS (LCY)";
                DataItemLink = "NPR Item Group Filter" = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "No." = FIELD("Vendor Filter");
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = false;
                column(No_Vendor; Vendor."No.")
                {
                }
                column(Name_Vendor; Vendor.Name)
                {
                }
                column(PurchaseLCY_vgvendor; vgvendor."Purchases (LCY)")
                {
                }
                column(PurchaseQty_vgvendor; vgvendor."Purchases (Qty.)")
                {
                }
                column(SaleLCY_vgvendor; vgvendor."Sales (LCY)")
                {
                }
                column(SaleQty_vgvendor; vgvendor."Sales (Qty.)")
                {
                }
                column(DB_vgvendor; "NPR Sales (LCY)" - "NPR COGS (LCY)")
                {
                }
                column(dg_vgvendor; dg)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (vg.GetFilter("Vendor Filter") = '') and ("NPR Sales (LCY)" = 0) then CurrReport.Skip;

                    Clear(dg);
                    if "NPR Sales (LCY)" <> 0 then
                        dg := (("NPR Sales (LCY)" - "NPR COGS (LCY)") / "NPR Sales (LCY)") * 100;

                    vareposter.SetRange("NPR Vendor No.", "No.");
                    vareposter.CalcSums(Quantity);
                    negatedQuantity := vareposter.Quantity * -1;
                    vgvendor.SetFilter("Vendor Filter", "No.");
                    vgvendor.CalcFields("Purchases (LCY)", "Purchases (Qty.)", "Sales (LCY)", "Sales (Qty.)");
                end;

                trigger OnPreDataItem()
                begin
                    vareposter.SetCurrentKey("Entry Type", "Posting Date", "NPR Item Group No.", "NPR Vendor No.");
                    vareposter.SetRange("Entry Type", vareposter."Entry Type"::Sale);
                    vareposter.SetRange("NPR Item Group No.", vg."No.");
                    vg.CopyFilter("Date Filter", vareposter."Posting Date");

                    vgvendor.CopyFilters(vg);
                    vgvendor.SetRange("No.", vg."No.");
                    if vgvendor.Find('-') then;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //Varesalg sidste år
                CalcFields("Purchases (LCY)");

                if vg.GetFilter("Date Filter") <> '' then begin
                    varegruppefjor.SetRange("No.", "No.");
                    varegruppefjor.Find('-');
                    varegruppefjor.CalcFields("Sales (LCY)", "Purchases (LCY)");
                    varesalgfjor := varegruppefjor."Sales (LCY)";
                    varekobfjor := varegruppefjor."Purchases (LCY)";

                    Clear(pctvaresalgfjor);
                    if varesalgfjor <> 0 then
                        pctvaresalgfjor := ("Sales (LCY)" / varesalgfjor) * 100;
                end;

                if not visudensalg then begin
                    if not ("Sales (Qty.)" <> 0) then CurrReport.Skip;
                end;

                Clear(dgItemGrp);
                if "Sales (LCY)" <> 0 then
                    dgItemGrp := (("Sales (LCY)" - "Consumption (Amount)") / "Sales (LCY)") * 100;

                Clear(pcttot);
                if totalsalg <> 0 then
                    pcttot := ("Sales (LCY)" / totalsalg) * 100;

                //-NPR70.00.00.00
                TotalPurchaseLCY += "Purchases (LCY)";
                TotalPurchaseQty += "Purchases (Qty.)";
                TotalSaleLCY += "Sales (LCY)";
                TotalSaleQty += "Sales (Qty.)";
                TotalConsumptionAmt += "Consumption (Amount)";
                TotalProfitLCY := (TotalSaleLCY - TotalConsumptionAmt);
                Totaldg := ((TotalSaleLCY - TotalConsumptionAmt) / TotalSaleLCY) * 100;
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                //Totalsalg
                CopyFilter("Date Filter", valueentry."Posting Date");

                CopyFilter("Vendor Filter", valueentry."NPR Vendor No.");
                //-NPR5.55 [361515]
                //valueentry.SETCURRENTKEY("Item No.","Posting Date","Item Ledger Entry Type","Entry Type","Item Charge No.",
                //"Location Code","Variant Code","Global Dimension 1 Code",
                //"Global Dimension 2 Code","Vendor No.");
                valueentry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type", "Variance Type", "Item Charge No.", "Location Code", "Variant Code");
                //+NPR5.55 [361515]
                CopyFilter("Date Filter", valueentry."Posting Date");
                valueentry.SetRange("Item Ledger Entry Type", valueentry."Item Ledger Entry Type"::Sale);
                valueentry.CalcSums("Sales Amount (Actual)");
                totalsalg := valueentry."Sales Amount (Actual)";

                //Salg sidste år - filtre
                if vg.GetFilter("Date Filter") <> '' then begin
                    varegruppefjor.CopyFilters(vg);
                    startdato := CalcDate('<-1Y>', vg.GetRangeMin("Date Filter"));
                    slutdato := CalcDate('<-1Y>', vg.GetRangeMax("Date Filter"));
                    varegruppefjor.SetRange("Date Filter", startdato, slutdato);
                end;

                //-NPR5.39
                //CurrReport.CREATETOTALS("Sales (Qty.)","Purchases (LCY)");
                //+NPR5.39
            end;
        }
        dataitem(Totals; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            MaxIteration = 2;
            column(Number_Totals; Totals.Number)
            {
            }
            column(TotalPurchaseLCY_vg; TotalPurchaseLCY)
            {
            }
            column(TotalPurchaseQty_vg; TotalPurchaseQty)
            {
            }
            column(TotalSaleLCY_vg; TotalSaleLCY)
            {
            }
            column(TotalSaleQty_vg; TotalSaleQty)
            {
            }
            column(TotalConsumptionAmt_vg; TotalConsumptionAmt)
            {
            }
            column(TotalProfitLCY_vg; TotalProfitLCY)
            {
            }
            column(Totaldg_vg; Totaldg)
            {
            }
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
                    field(visudensalg; visudensalg)
                    {
                        Caption = 'Display Item Groups With No Sales';
                        ApplicationArea = All;
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
        Report_Caption = 'Itemgroup/Supplier';
        Period_Caption = 'Period:';
        ItemGroupFilter_Caption = 'Item Group Filter:';
        DeptFilter_Caption = 'Departmentfilter:';
        SupplierFilter_Caption = 'Supplier Filter:';
        ItemGroup_Caption = 'Itemgroup';
        Supplier_Caption = 'Supplier';
        Description_Caption = 'Description';
        Purchases_Caption = 'Purchases';
        Quantity_Caption = 'Quantity';
        Turnover_Caption = 'Turnover';
        PctLastYear_Caption = '% last year';
        DB_Caption = 'DB';
        DB_Pct_Caption = 'DB%';
        TotalSales_Caption = '% total sales';
        Total_Caption = 'Total';
    }

    trigger OnInitReport()
    begin
        firmaoplysninger.Get;
        firmaoplysninger.CalcFields(Picture);
        visudensalg := false;

        //-NPR5.39
        // objekt.SETRANGE(ID, 6014449);
        // objekt.SETRANGE(Type, 3);
        // objekt.FIND('-');
        //+NPR5.39
    end;

    var
        firmaoplysninger: Record "Company Information";
        dg: Decimal;
        visudensalg: Boolean;
        valueentry: Record "Value Entry";
        totalsalg: Decimal;
        pcttot: Decimal;
        varegruppefjor: Record "NPR Item Group";
        startdato: Date;
        slutdato: Date;
        varesalgfjor: Decimal;
        pctvaresalgfjor: Decimal;
        vareposter: Record "Item Ledger Entry";
        negatedQuantity: Decimal;
        vgvendor: Record "NPR Item Group";
        varekobfjor: Decimal;
        dgItemGrp: Decimal;
        TotalPurchaseLCY: Decimal;
        TotalPurchaseQty: Decimal;
        TotalSaleLCY: Decimal;
        TotalSaleQty: Decimal;
        TotalConsumptionAmt: Decimal;
        TotalProfitLCY: Decimal;
        Totaldg: Decimal;
}

