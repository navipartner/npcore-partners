report 6014448 "NPR Item Group Inv. Value"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Inventory Value.rdlc';
    Caption = 'Item Group Inventory Value';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;



    dataset
    {
        dataitem("Item Category"; "Item Category")
        {
            CalcFields = "NPR Sales (LCY)", "NPR Consumption (Amount)";
            RequestFilterFields = "Code", "NPR Date Filter", "NPR Vendor Filter", "NPR Global Dimension 1 Filter", "NPR Location Filter";
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(DateFilter; GetFilter("NPR Date Filter"))
            {
            }
            column(Primo; StrSubstNo(StartOf, Format(GetRangeMin("NPR Date Filter"))))
            {
            }
            column(Ultimo; StrSubstNo(EndOf, Format(GetRangeMax("NPR Date Filter"))))
            {
            }
            column(No; "Code")
            {
                AutoFormatType = 1;
            }
            column(Description; Description)
            {
            }
            column(ItemGroupMovementAtStartOf; ItemGroupMovementAtStartOf)
            {
            }
            column(ItemGroupInventoryAtStartOf; ItemGroupInventoryAtStartOf)
            {
            }
            column(PurchaseQuantity; "NPR Purchases (Qty.)")
            {
            }
            column(PurchaseLCY; "NPR Purchases (LCY)")
            {
            }
            column(SalesQty; "NPR Sales (Qty.)")
            {
            }
            column(SaleLCY; "NPR Sales (LCY)")
            {
            }
            column(Profit; Profit)
            {
            }
            column(Dg; Dg)
            {
            }
            column(ItemGroupMovementAtEndOf; ItemGroupMovementAtEndOf)
            {
            }
            column(ItemGroupInventoryAtEndOf; ItemGroupInventoryAtEndOf)
            {
            }
            column(SaleLbl; StrSubstNo(SaleLbl, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(PurchaseLbl; StrSubstNo(PurchaseLbl, GeneralLedgerSetup."LCY Code"))
            {
            }

            trigger OnAfterGetRecord()
            begin
                ItemCategoryLast.Get("Code");
                ItemCategoryLast.SetFilter("NPR Date Filter", '..%1', GetRangeMax("NPR Date Filter"));
                ItemCategoryLast.SetFilter("NPR Global Dimension 1 Filter", GetFilter("NPR Global Dimension 1 Filter"));
                ItemCategoryLast.SetFilter("NPR Vendor Filter", GetFilter("NPR Vendor Filter"));
                ItemCategoryLast.SETFILTER("NPR Location Filter", GETFILTER("NPR Location Filter"));

                ItemCategoryLast.CalcFields("NPR Movement", "NPR Inventory Value");

                ItemGroupMovementAtEndOf := ItemCategoryLast."NPR Movement";
                ItemGroupInventoryAtEndOf := ItemCategoryLast."NPR Inventory Value";

                ItemCategoryFirst.Get("Code");
                ItemCategoryFirst.SetFilter("NPR Date Filter", '..%1', GetRangeMin("NPR Date Filter") - 1);
                ItemCategoryFirst.SetFilter("NPR Global Dimension 1 Filter", GetFilter("NPR Global Dimension 1 Filter"));
                ItemCategoryFirst.SetFilter("NPR Vendor Filter", GetFilter("NPR Vendor Filter"));
                ItemCategoryFirst.SETFILTER("NPR Location Filter", GETFILTER("NPR Location Filter"));

                ItemCategoryFirst.CalcFields("NPR Movement", "NPR Inventory Value");

                ItemGroupMovementAtStartOf := ItemCategoryFirst."NPR Movement";
                ItemGroupInventoryAtStartOf := ItemCategoryFirst."NPR Inventory Value";

                Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";

                if "NPR Sales (LCY)" <> 0 then
                    Dg := Profit / "NPR Sales (LCY)" * 100
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
        ReportCap = 'Item Group Inventory Value';
        ItemGroupCap = 'Item Group';
        NameCap = 'Name';
        QtyCap = 'Qty';
        AmountCap = 'Amount';
        PurchaseAtyCap = 'Purchase (Qty)';
        SalesQtyCap = 'Sales (Qty)';
        DBCap = 'Margin';
        DGCap = 'Margin %';
        PeriodCap = 'Period ';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        GeneralLedgerSetup.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemCategoryFirst: Record "Item Category";
        ItemCategoryLast: Record "Item Category";
        Dg: Decimal;
        ItemGroupInventoryAtEndOf: Decimal;
        ItemGroupInventoryAtStartOf: Decimal;
        ItemGroupMovementAtEndOf: Decimal;
        ItemGroupMovementAtStartOf: Decimal;
        Profit: Decimal;
        EndOf: Label '------- End of %1 -------';
        PurchaseLbl: Label 'Purchases (%1)';
        SaleLbl: Label 'Sales (%1)';
        StartOf: Label '------- Start of %1 -------';
}

