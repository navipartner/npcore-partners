report 6014412 "NPR Sold Items by Sales Person"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sold Items by Sales Person.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Sold Items By Sales Person';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "Sales (LCY)", "COGS (LCY)";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Date Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ObjectDetails; ObjectDetails)
            {
            }
            column(No_Item; Item."No.")
            {
            }
            column(Description_Item; Item.Description)
            {
            }
            column(SalesQty_Item; Item."Sales (Qty.)")
            {
            }
            column(SalesLCY_Item; Item."Sales (LCY)")
            {
            }
            column(Profit_Item; ("Sales (LCY)" - "COGS (LCY)"))
            {
            }
            column(ProfitPct_Item; ProfitPct)
            {
            }
            dataitem(AuxItemLedgerEntry; "NPR Aux. Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Posting Date" = FIELD("Date Filter"), "Location Code" = FIELD("Location Filter");
                DataItemTableView = SORTING("Item No.", "Entry Type") WHERE("Invoiced Quantity" = FILTER(<> 0), "Entry Type" = CONST(Sale), "Salespers./Purch. Code" = FILTER(<> ''));
                column(ItemNo_ItemLedgerEntry; "Item No.")
                {
                }
                column(SalespersonCode_ItemLedgerEntry; "Salespers./Purch. Code")
                {
                }
                column(InvoicedQuantity_ItemLedgerEntry; "Invoiced Quantity")
                {
                }
                column(SalespersonName_ItemLedgerEntry; SalespersonName)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SalespersonName := '';
                    if SalespersonPurchaser.Get("Salespers./Purch. Code") then
                        SalespersonName := SalespersonPurchaser.Name;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(ProfitPct);

                if "Sales (LCY)" <> 0 then
                    ProfitPct := ("Sales (LCY)" - "COGS (LCY)") / "Sales (LCY)" * 100
                else
                    ProfitPct := 0;
            end;
        }
    }

    labels
    {
        Report_Caption = 'Sold Items by Sales Person';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        Sales_Qty_Caption = 'Sales (Qty.)';
        Sales_LCY_Caption = 'Sales (LCY)';
        Name_Caption = 'Name';
        Qty_Caption = 'Qty.';
        Sales_Caption = 'Sales';
        Discount_Caption = 'Discount';
        DB_Caption = 'Margin';
        DG_Pct_Caption = 'Cov. %';
        SalesPerson_Code_Caption = 'Salesperson Code';
    }

    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ProfitPct: Decimal;
        ObjectDetails: Text[100];
        SalespersonName: Text[50];
}
