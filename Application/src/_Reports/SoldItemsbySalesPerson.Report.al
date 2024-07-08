report 6014412 "NPR Sold Items by Sales Person"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sold Items by Sales Person.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Sold Items By Salesperson';
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
            dataitem(AuxItemLedgerEntry; "NPR POS Entry Sales Line")
            {
                DataItemLink = "No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Entry Date" = FIELD("Date Filter"), "Location Code" = FIELD("Location Filter");
                DataItemTableView = SORTING("No.") WHERE("Quantity" = FILTER(<> 0), "Salesperson Code" = FILTER(<> ''));
                column(ItemNo_ItemLedgerEntry; "No.")
                {
                }
                column(SalespersonCode_ItemLedgerEntry; "Salesperson Code")
                {
                }
                column(InvoicedQuantity_ItemLedgerEntry; "Quantity")
                {
                }
                column(SalespersonName_ItemLedgerEntry; SalespersonName)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SalespersonName := '';
                    if SalespersonPurchaser.Get("Salesperson Code") then
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

                if (Item."Sales (Qty.)" = 0) and (not ShowItemsWithoutSale) then
                    CurrReport.Skip();
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
                field("Show Items Without Sale"; ShowItemsWithoutSale)
                {
                    Caption = 'Show Items Without Sale';
                    ToolTip = 'Specifies the value of the Show Items Without Sale field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    labels
    {
        Report_Caption = 'Sold Items by Salesperson';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        Sales_Qty_Caption = 'Sales (Qty.)';
        Sales_LCY_Caption = 'Sales Excl. VAT (LCY)';
        Name_Caption = 'Name';
        Qty_Caption = 'Qty.';
        Sales_Caption = 'Sales';
        Discount_Caption = 'Discount';
        DB_Caption = 'Margin';
        DG_Pct_Caption = 'Cov. %';
        SalesPerson_Code_Caption = 'Salesperson Code';
        Total_Caption = 'Total:';
        Page_Lbl = 'Page: ';
    }

    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ProfitPct: Decimal;
        ObjectDetails: Text[100];
        SalespersonName: Text[50];
        ShowItemsWithoutSale: Boolean;
}
