report 6014448 "NPR Item Group Inv. Value"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Group Inventory Value.rdlc';
    Caption = 'Item Group Inventory Value';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Item Group"; "NPR Item Group")
        {
            CalcFields = "Sales (LCY)", "Consumption (Amount)";
            RequestFilterFields = "No.", "Date Filter", "Vendor Filter", "Global Dimension 1 Filter", "Location Filter";
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(DateFilter; GetFilter("Date Filter"))
            {
            }
            column(Primo; StrSubstNo(StartOf, Format(GetRangeMin("Date Filter"))))
            {
            }
            column(Ultimo; StrSubstNo(EndOf, Format(GetRangeMax("Date Filter"))))
            {
            }
            column(No; "No.")
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
            column(PurchaseQuantity; "Purchases (Qty.)")
            {
            }
            column(PurchaseLCY; "Purchases (LCY)")
            {
            }
            column(SalesQty; "Sales (Qty.)")
            {
            }
            column(SaleLCY; "Sales (LCY)")
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
                ItemGroupLast.Get("No.");
                ItemGroupLast.SetFilter("Date Filter", '..%1', GetRangeMax("Date Filter"));
                ItemGroupLast.SetFilter("Global Dimension 1 Filter", GetFilter("Global Dimension 1 Filter"));
                ItemGroupLast.SetFilter("Vendor Filter", GetFilter("Vendor Filter"));
                ItemGroupLast.SETFILTER("Location Filter", GETFILTER("Location Filter"));
                ItemGroupLast.CalcFields(Movement, "Inventory Value");
                ItemGroupMovementAtEndOf := ItemGroupLast.Movement;
                ItemGroupInventoryAtEndOf := ItemGroupLast."Inventory Value";

                ItemGroupFirst.Get("No.");
                ItemGroupFirst.SetFilter("Date Filter", '..%1', GetRangeMin("Date Filter") - 1);
                ItemGroupFirst.SetFilter("Global Dimension 1 Filter", GetFilter("Global Dimension 1 Filter"));
                ItemGroupFirst.SetFilter("Vendor Filter", GetFilter("Vendor Filter"));
                ItemGroupFirst.SETFILTER("Location Filter", GETFILTER("Location Filter"));
                ItemGroupFirst.CalcFields(Movement, "Inventory Value");
                ItemGroupMovementAtStartOf := ItemGroupFirst.Movement;
                ItemGroupInventoryAtStartOf := ItemGroupFirst."Inventory Value";

                Profit := "Sales (LCY)" - "Consumption (Amount)";

                if "Sales (LCY)" <> 0 then
                    Dg := Profit / "Sales (LCY)" * 100
                else
                    Clear(Dg);
            end;
        }
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
        ItemGroupFirst: Record "NPR Item Group";
        ItemGroupLast: Record "NPR Item Group";
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

