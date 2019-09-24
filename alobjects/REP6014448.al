report 6014448 "Item Group Inventory Value"
{
    // NPK1.00/20140415/TR Case 176200 : Report converted. Copied from retail 12.
    // NOTE : I changed the textbox test to PurchaseQuantity since it is being used in textbox96 's expressions
    //         + report expression for textbox98 to SaleQty instead of SalesQty
    //         + report exp for textbox 105 from test to PurchaseQuantity
    // NPR5.29/JLK /20161206  CASE 251757 Report variables and text constents changed for ENU wordings
    //                                    Cleared unused variables and Labels
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Item Group Inventory Value.rdlc';

    Caption = 'Item Group Inventory Value';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Group";"Item Group")
        {
            CalcFields = "Sales (LCY)","Consumption (Amount)";
            RequestFilterFields = "No.","Date Filter","Vendor Filter","Global Dimension 1 Filter";
            column(CompanyInfoName;CompanyInfo.Name)
            {
            }
            column(CompanyInfoPicture;CompanyInfo.Picture)
            {
            }
            column(DateFilter;GetFilter("Date Filter"))
            {
            }
            column(Primo;StrSubstNo(StartOf,Format(GetRangeMin("Date Filter"))))
            {
            }
            column(Ultimo;StrSubstNo(EndOf,Format(GetRangeMax("Date Filter"))))
            {
            }
            column(No;"No.")
            {
                AutoFormatType = 1;
            }
            column(Description;Description)
            {
            }
            column(ItemGroupMovementAtStartOf;ItemGroupMovementAtStartOf)
            {
            }
            column(ItemGroupInventoryAtStartOf;ItemGroupInventoryAtStartOf)
            {
            }
            column(PurchaseQuantity;"Purchases (Qty.)")
            {
            }
            column(PurchaseLCY;"Purchases (LCY)")
            {
            }
            column(SalesQty;"Sales (Qty.)")
            {
            }
            column(SaleLCY;"Sales (LCY)")
            {
            }
            column(Profit;Profit)
            {
            }
            column(Dg;Dg)
            {
            }
            column(ItemGroupMovementAtEndOf;ItemGroupMovementAtEndOf)
            {
            }
            column(ItemGroupInventoryAtEndOf;ItemGroupInventoryAtEndOf)
            {
            }
            column(SaleLbl;StrSubstNo(SaleLbl,GeneralLedgerSetup."LCY Code"))
            {
            }
            column(PurchaseLbl;StrSubstNo(PurchaseLbl,GeneralLedgerSetup."LCY Code"))
            {
            }

            trigger OnAfterGetRecord()
            begin
                ItemGroupLast.Get("No.");
                ItemGroupLast.SetFilter("Date Filter", '..%1', GetRangeMax("Date Filter"));
                ItemGroupLast.SetFilter("Global Dimension 1 Filter", GetFilter("Global Dimension 1 Filter"));
                ItemGroupLast.SetFilter("Vendor Filter", GetFilter("Vendor Filter"));
                ItemGroupLast.CalcFields(Movement,"Inventory Value");
                ItemGroupMovementAtEndOf := ItemGroupLast.Movement;
                ItemGroupInventoryAtEndOf := ItemGroupLast."Inventory Value";

                ItemGroupFirst.Get("No.");
                ItemGroupFirst.SetFilter("Date Filter", '..%1', GetRangeMin("Date Filter")-1);
                ItemGroupFirst.SetFilter("Global Dimension 1 Filter", GetFilter("Global Dimension 1 Filter"));
                ItemGroupFirst.SetFilter("Vendor Filter", GetFilter("Vendor Filter"));
                ItemGroupFirst.CalcFields(Movement,"Inventory Value");
                ItemGroupMovementAtStartOf:=ItemGroupFirst.Movement;
                ItemGroupInventoryAtStartOf:=ItemGroupFirst."Inventory Value";

                Profit := "Sales (LCY)"-"Consumption (Amount)";

                if "Sales (LCY)" <> 0 then
                  Dg := Profit/"Sales (LCY)"*100
                else
                  Clear(Dg);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
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
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
        //-NPR5.39
        // Object.SETRANGE(ID, 6014448);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
        //-NPR5.29
        GeneralLedgerSetup.Get;
        //+NPR5.29
    end;

    var
        ItemGroupMovementAtStartOf: Decimal;
        ItemGroupMovementAtEndOf: Decimal;
        Profit: Decimal;
        Dg: Decimal;
        CompanyInfo: Record "Company Information";
        ItemGroupFirst: Record "Item Group";
        ItemGroupLast: Record "Item Group";
        ItemGroupInventoryAtStartOf: Decimal;
        ItemGroupInventoryAtEndOf: Decimal;
        StartOf: Label '------- Start of %1 -------';
        EndOf: Label '------- End of %1 -------';
        SaleLbl: Label 'Sales (%1)';
        PurchaseLbl: Label 'Purchases (%1)';
        GeneralLedgerSetup: Record "General Ledger Setup";
}

