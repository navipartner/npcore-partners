report 6014412 "Sold Items by Sales Person"
{
    // NPR70.00.00.00/LS Convert Report to Nav 2013
    // NPR5.38/JLK /20180124  CASE 300892 Corrected AL Error on obsolite property CurrReport_PAGENO
    DefaultLayout = RDLC;
    RDLCLayout = './Sold Items by Sales Person.rdlc';

    Caption = 'Sold Items By Sales Person';

    dataset
    {
        dataitem(Item;Item)
        {
            CalcFields = "Sales (LCY)","COGS (LCY)";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.","Date Filter";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(ObjectDetails;ObjectDetails)
            {
            }
            column(No_Item;Item."No.")
            {
            }
            column(Description_Item;Item.Description)
            {
            }
            column(SalesQty_Item;Item."Sales (Qty.)")
            {
            }
            column(SalesLCY_Item;Item."Sales (LCY)")
            {
            }
            column(Profit_Item;("Sales (LCY)"-"COGS (LCY)"))
            {
            }
            column(ProfitPct_Item;ProfitPct)
            {
            }
            dataitem("Item Ledger Entry";"Item Ledger Entry")
            {
                DataItemLink = "Item No."=FIELD("No."),"Variant Code"=FIELD("Variant Filter"),"Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),"Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),"Posting Date"=FIELD("Date Filter"),"Location Code"=FIELD("Location Filter");
                DataItemTableView = SORTING("Item No.","Salesperson Code") WHERE("Invoiced Quantity"=FILTER(<>0),"Entry Type"=CONST(Sale),"Salesperson Code"=FILTER(<>''));
                column(ItemNo_ItemLedgerEntry;"Item Ledger Entry"."Item No.")
                {
                }
                column(SalespersonCode_ItemLedgerEntry;"Item Ledger Entry"."Salesperson Code")
                {
                }
                column(InvoicedQuantity_ItemLedgerEntry;"Item Ledger Entry"."Invoiced Quantity")
                {
                }
                column(SalespersonName_ItemLedgerEntry;SalespersonName)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR70.00.00.00
                    SalespersonName := '';
                    SalespersonPurchaser.Reset;
                    SalespersonPurchaser.SetRange(Code,"Salesperson Code");
                    if SalespersonPurchaser.Find('-') then
                      SalespersonName := SalespersonPurchaser.Name;
                    //+NPR70.00.00.00
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(ProfitPct);

                if "Sales (LCY)"<> 0 then
                  ProfitPct := ("Sales (LCY)"-"COGS (LCY)")/"Sales (LCY)"*100
                else
                  ProfitPct := 0;
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
        CompanyInfo: Record "Company Information";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ProfitPct: Decimal;
        "Object": Record "Object";
        "//-NPR7": Integer;
        ObjectDetails: Text[100];
        SalespersonName: Text[30];
        "//+NPR7": Integer;
}

