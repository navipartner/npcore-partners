report 6014448 "NPR Item Cat. Inv. Value"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Category Inventory Value.rdlc';
    Caption = 'Item Category Inventory Value';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;
    dataset
    {
        dataitem("Item Category"; "Item Category")
        {
            RequestFilterFields = "Code", "NPR Date Filter", "NPR Vendor Filter", "NPR Global Dimension 1 Filter", "NPR Location Filter";
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(AppliedFilters; AppliedFilters)
            {
            }
            column(PeriodDateFilter; PeriodDateFilter)
            {
            }
            column("Code"; "Code")
            {
            }
            column(Parent_Category; "Parent Category")
            {
                AutoFormatType = 1;
            }
            column(Description; Description)
            {
            }
            column(PurchaseQuantity; "NPR Purchases (Qty.)")
            {
            }
            column(PurchaseLCY; PurchaseLCY)
            {
            }
            column(SalesQty; "NPR Sales (Qty.)")
            {
            }
            column(SaleLCY; SaleLCY)
            {
            }
            column(ItemCategoryMovementAtStartOf; ItemCategoryMovementAtStartOf)
            {
            }
            column(ItemCategoryInventoryAtStartOf; ItemCategoryInventoryAtStartOf)
            {
            }
            column(Profit; Profit)
            {
            }
            column(Dg; Dg)
            {
            }
            column(ItemCategoryMovementAtEndOf; ItemCategoryMovementAtEndOf)
            {
            }
            column(ItemCategoryInventoryAtEndOf; ItemCategoryInventoryAtEndOf)
            {
            }
            column(SaleLbl; StrSubstNo(SaleLbl, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(PurchaseLbl; StrSubstNo(PurchaseLbl, GeneralLedgerSetup."LCY Code"))
            {
            }
            trigger OnAfterGetRecord()
            var
                ConsumptionAmount: Decimal;
                InventoryValue: Decimal;
            begin
                "Item Category".NPRGetVESalesLCYAndConsumptionAmount(SaleLCY, ConsumptionAmount);
                ItemCategoryLast.Get("Code");
                ItemCategoryLast.SetFilter("NPR Date Filter", '..%1', GetRangeMax("NPR Date Filter"));
                ItemCategoryLast.SetFilter("NPR Global Dimension 1 Filter", GetFilter("NPR Global Dimension 1 Filter"));
                ItemCategoryLast.SetFilter("NPR Vendor Filter", GetFilter("NPR Vendor Filter"));
                ItemCategoryLast.SETFILTER("NPR Location Filter", GETFILTER("NPR Location Filter"));

                ItemCategoryLast.CalcFields("NPR Movement");
                ItemCategoryLast.NPRGetVEInventoryValue(InventoryValue);
                ItemCategoryMovementAtEndOf := ItemCategoryLast."NPR Movement";
                ItemCategoryInventoryAtEndOf := InventoryValue;

                ItemCategoryFirst.Get("Code");
                ItemCategoryFirst.SetFilter("NPR Date Filter", '..%1', GetRangeMin("NPR Date Filter") - 1);
                ItemCategoryFirst.SetFilter("NPR Global Dimension 1 Filter", GetFilter("NPR Global Dimension 1 Filter"));
                ItemCategoryFirst.SetFilter("NPR Vendor Filter", GetFilter("NPR Vendor Filter"));
                ItemCategoryFirst.SETFILTER("NPR Location Filter", GETFILTER("NPR Location Filter"));

                ItemCategoryFirst.CalcFields("NPR Movement");
                ItemCategoryFirst.NPRGetVEInventoryValue(InventoryValue);
                ItemCategoryMovementAtStartOf := ItemCategoryFirst."NPR Movement";
                ItemCategoryInventoryAtStartOf := InventoryValue;

                Profit := SaleLCY - ConsumptionAmount;
                if SaleLCY <> 0 then
                    Dg := Profit / SaleLCY * 100
                else
                    Clear(Dg);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        ReportCap = 'Item Category Inventory Value';
        ItemCategoryCap = 'Item Category';
        NameCap = 'Name';
        StartQtyCap = 'Start Qty';
        EndQtyCap = 'End Qty';
        AmountCap = 'Amount';
        PurchaseAtyCap = 'Purchase (Qty)';
        SalesQtyCap = 'Sales (Qty)';
        DBCap = 'Margin';
        DGCap = 'Margin %';
        PeriodCap = 'Period ';
        Total = 'Total ';
        Off = 'of';
        AppliedFiltersCaption = 'Applied Filters:';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        GeneralLedgerSetup.Get();
        CompanyInfo.Get();

    end;

    trigger OnPreReport()
    var
        "Date": Record "Date";
    begin

        CompanyInfo.CalcFields(Picture);

        if PeriodDateFilter <> '' then begin
            "Date".SetRange("Period Type", "Date"."Period Type"::"Date");
            "Date".SetFilter("Date"."Period Start", PeriodDateFilter);
            "Item Category".SetFilter("NPR Date Filter", '<=%1', "Date".GetRangeMax("Date"."Period Start"));
            "Item Category".SetFilter("NPR Date Filter", '>=%1', "Date".GetRangeMin("Date"."Period Start"));
        end;

        if "Item Category".GetFilters <> '' then
            AppliedFilters := StrSubstNo('%1', CopyStr("Item Category".GetFilters(), 1, MaxStrLen(AppliedFilters)))
        else
            AppliedFilters := CopyStr("Item Category".GetFilters(), 1, MaxStrLen(AppliedFilters));
    end;

    var
        CompanyInfo: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemCategoryFirst: Record "Item Category";
        ItemCategoryLast: Record "Item Category";
        Dg: Decimal;
        ItemCategoryInventoryAtEndOf: Decimal;
        ItemCategoryInventoryAtStartOf: Decimal;
        ItemCategoryMovementAtEndOf: Decimal;
        ItemCategoryMovementAtStartOf: Decimal;
        PurchaseLCY: Decimal;
        SaleLCY: Decimal;
        AppliedFilters: Text[200];
        PeriodDateFilter: Text;
        Profit: Decimal;
        PurchaseLbl: Label 'Purchases (%1)';
        SaleLbl: Label 'Sales (%1)';
}

