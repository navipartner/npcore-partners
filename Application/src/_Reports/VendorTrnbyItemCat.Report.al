report 6014449 "NPR Vendor Trn. by Item Cat."
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor trn. by Item Cat.rdlc';
    Caption = 'Vendor Turnover by Item Category';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategory; "Item Category")
        {
            CalcFields = "NPR Consumption (Amount)";
            RequestFilterFields = "Code", "NPR Date Filter", "NPR Global Dimension 1 Filter", "NPR Vendor Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(DateFilters; GetFilter("NPR Date Filter"))
            {
            }
            column(No_Filter; GetFilter("Code"))
            {
            }
            column(GlobalDimension1_Filter; GetFilter("NPR Global Dimension 1 Filter"))
            {
            }
            column(Vendor_Filter; GetFilter("NPR Vendor Filter"))
            {
            }
            column(No_vg; ItemCategory."Code")
            {
            }
            column(Description_vg; ItemCategory.Description)
            {
            }
            column(PurchaseLCY_vg; ItemCategory."NPR Purchases (LCY)")
            {
            }
            column(PurchaseQuantity_vg; ItemCategory."NPR Purchases (Qty.)")
            {
            }
            column(SaleLCY_vg; ItemCategory."NPR Sales (LCY)")
            {
            }
            column(SalesQty_vg; ItemCategory."NPR Sales (Qty.)")
            {
            }
            column(pctvaresalgfjor_vg; pctvaresalgfjor)
            {
            }
            column(DB_vg; "NPR Sales (LCY)" - "NPR Consumption (Amount)")
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
                DataItemLink = "NPR Item Category Filter" = FIELD("Code"), "Date Filter" = FIELD("NPR Date Filter"), "Global Dimension 1 Filter" = FIELD("NPR Global Dimension 1 Filter"), "No." = FIELD("NPR Vendor Filter");
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = false;
                column(No_Vendor; Vendor."No.")
                {
                }
                column(Name_Vendor; Vendor.Name)
                {
                }
                column(PurchaseLCY_vgvendor; vgvendor."NPR Purchases (LCY)")
                {
                }
                column(PurchaseQty_vgvendor; vgvendor."NPR Purchases (Qty.)")
                {
                }
                column(SaleLCY_vgvendor; vgvendor."NPR Sales (LCY)")
                {
                }
                column(SaleQty_vgvendor; vgvendor."NPR Sales (Qty.)")
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
                    if (ItemCategory.GetFilter("NPR Vendor Filter") = '') and ("NPR Sales (LCY)" = 0) then CurrReport.Skip();

                    Clear(dg);
                    if "NPR Sales (LCY)" <> 0 then
                        dg := (("NPR Sales (LCY)" - "NPR COGS (LCY)") / "NPR Sales (LCY)") * 100;

                    ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Vendor);
                    ItemLedgerEntry.SetRange("Source No.", "No.");
                    ItemLedgerEntry.CalcSums(Quantity);
                    vgvendor.SetFilter("NPR Vendor Filter", "No.");
                    vgvendor.CalcFields("NPR Purchases (LCY)", "NPR Purchases (Qty.)", "NPR Sales (LCY)", "NPR Sales (Qty.)");
                end;

                trigger OnPreDataItem()
                begin
                    ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Item Category Code", "Source No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SetRange("Item Category Code", ItemCategory."Code");
                    ItemCategory.CopyFilter("NPR Date Filter", ItemLedgerEntry."Posting Date");

                    vgvendor.CopyFilters(ItemCategory);
                    vgvendor.SetRange("Code", ItemCategory."Code");
                    if vgvendor.Find('-') then;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //Varesalg sidste år
                CalcFields("NPR Purchases (LCY)");

                if ItemCategory.GetFilter("NPR Date Filter") <> '' then begin
                    varegruppefjor.SetRange("Code", "Code");
                    varegruppefjor.Find('-');
                    varegruppefjor.CalcFields("NPR Sales (LCY)", "NPR Purchases (LCY)");
                    varesalgfjor := varegruppefjor."NPR Sales (LCY)";
                    varekobfjor := varegruppefjor."NPR Purchases (LCY)";

                    Clear(pctvaresalgfjor);
                    if varesalgfjor <> 0 then
                        pctvaresalgfjor := ("NPR Sales (LCY)" / varesalgfjor) * 100;
                end;

                if not visudensalg then begin
                    if not ("NPR Sales (Qty.)" <> 0) then CurrReport.Skip();
                end;

                Clear(dgItemGrp);
                if "NPR Sales (LCY)" <> 0 then
                    dgItemGrp := (("NPR Sales (LCY)" - "NPR Consumption (Amount)") / "NPR Sales (LCY)") * 100;

                Clear(pcttot);
                if totalsalg <> 0 then
                    pcttot := ("NPR Sales (LCY)" / totalsalg) * 100;

                TotalPurchaseLCY += "NPR Purchases (LCY)";
                TotalPurchaseQty += "NPR Purchases (Qty.)";
                TotalSaleLCY += "NPR Sales (LCY)";
                TotalSaleQty += "NPR Sales (Qty.)";
                TotalConsumptionAmt += "NPR Consumption (Amount)";
                TotalProfitLCY := (TotalSaleLCY - TotalConsumptionAmt);
                if TotalSaleLCY <> 0 then
                    Totaldg := ((TotalSaleLCY - TotalConsumptionAmt) / TotalSaleLCY) * 100;
            end;

            trigger OnPreDataItem()
            begin
                //Totalsalg
                CopyFilter("NPR Date Filter", ValueEntry."Posting Date");

                //TODO:Temporary Aux Value Entry Reimplementation
                // CopyFilter("NPR Vendor Filter", ValueEntry."NPR Vendor No.");
                ValueEntry.SetCurrentKey("Item No.", "Posting Date", "Item Ledger Entry Type", "Entry Type", "Variance Type", "Item Charge No.", "Location Code", "Variant Code");
                CopyFilter("NPR Date Filter", ValueEntry."Posting Date");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.CalcSums("Sales Amount (Actual)");
                totalsalg := ValueEntry."Sales Amount (Actual)";

                //Salg sidste år - filtre
                if ItemCategory.GetFilter("NPR Date Filter") <> '' then begin
                    varegruppefjor.CopyFilters(ItemCategory);
                    startdato := CalcDate('<-1Y>', ItemCategory.GetRangeMin("NPR Date Filter"));
                    slutdato := CalcDate('<-1Y>', ItemCategory.GetRangeMax("NPR Date Filter"));
                    varegruppefjor.SetRange("NPR Date Filter", startdato, slutdato);
                end;
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
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("visuden salg"; visudensalg)
                    {
                        Caption = 'Display Item Category With No Sales';

                        ToolTip = 'Specifies the value of the Display Item Category With No Sales field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    labels
    {
        Report_Caption = 'Vendor Turnover by Item Category';
        Period_Caption = 'Period:';
        ItemCategoryFilter_Caption = 'Item Category Filter:';
        DeptFilter_Caption = 'Departmentfilter:';
        SupplierFilter_Caption = 'Supplier Filter:';
        ItemCategory_Caption = 'Item Category';
        Supplier_Caption = 'Supplier';
        Description_Caption = 'Description';
        Purchases_Caption = 'Purchases';
        Quantity_Caption = 'Quantity';
        Turnover_Caption = 'Turnover';
        PctLastYear_Caption = '% Last Year';
        DB_Caption = 'Profit';
        DB_Pct_Caption = 'Profit %';
        TotalSales_Caption = '% Total Sales';
        Total_Caption = 'Total';
    }

    trigger OnInitReport()
    begin
        firmaoplysninger.Get();
        firmaoplysninger.CalcFields(Picture);
        visudensalg := false;
    end;

    var
        firmaoplysninger: Record "Company Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        varegruppefjor: Record "Item Category";
        vgvendor: Record "Item Category";
        ValueEntry: Record "Value Entry";
        visudensalg: Boolean;
        slutdato: Date;
        startdato: Date;
        dg: Decimal;
        dgItemGrp: Decimal;
        pcttot: Decimal;
        pctvaresalgfjor: Decimal;
        TotalConsumptionAmt: Decimal;
        Totaldg: Decimal;
        TotalProfitLCY: Decimal;
        TotalPurchaseLCY: Decimal;
        TotalPurchaseQty: Decimal;
        TotalSaleLCY: Decimal;
        TotalSaleQty: Decimal;
        totalsalg: Decimal;
        varekobfjor: Decimal;
        varesalgfjor: Decimal;
}

