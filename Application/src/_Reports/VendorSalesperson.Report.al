report 6014529 "NPR Vendor/Salesperson"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/VendorSalesperson.rdlc';
    Caption = 'Vendor/Salesperson';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(ReportTitle; ReportTitleLbl) { }
            column(CompanyName; CompanyName) { }
            column(VendorNoLbl; VendorNoLbl) { }
            column(VendorNameLbl; VendorNameLbl) { }
            column(VendorNo; "No.") { }
            column(VendorName; Name) { }
            column(TodaysDate; System.Today) { }
            column(PageNoCap; PageNoLbl) { }
            column(PageNoTxt; PageNoTxt) { }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemTableView = sorting(Code);
                PrintOnlyIfDetail = true;
                RequestFilterFields = Code, "Date Filter";
                RequestFilterHeading = 'Salesperson';

                column(SalesPersonNoLbl; SalesPesonNoLbl) { }
                column(SalesPersonNameLbl; SalesPersonNameLbl) { }
                column(SalesPersonCode; Code) { }
                column(SalesPersonName; Name) { }
                dataitem(Item; Item)
                {
                    DataItemTableView = sorting("No.");
                    column(ItemNoLbl; ItemNoLbl) { }
                    column(ItemNo; Item."No.") { }
                    column(ItemDescLbl; ItemDescLbl) { }
                    column(ItemDesc; Item.Description) { }
                    column(TotalSalesPerItem; TotalSalesPerItem) { }
                    column(TotalCOGSPerItem; TotalCOGSPerItem) { }
                    column(TotalSalesCaption; TotalSalesLbl) { }
                    column(TotalSales; TotalSalesPerItem) { }
                    column(TotalCOGSCaption; TotalCOGSLbl) { }
                    column(TotalCOGS; TotalCOGSPerItem) { }
                    column(InvQtyCaption; InvQtyLbl) { }
                    column(Quantity; InvoicedQty) { }
                    column(UOMCaption; UOMLbl) { }
                    column(Base_Unit_of_Measure; "Base Unit of Measure") { }
                    column(DiscAmountCaption; DiscAmountLbl) { }
                    column(DiscAmount; DiscAmount) { }
                    column(ProfitCap; ProfitLbl) { }
                    column(Profit; Profit) { }
                    column(ProfitPercCaption; ProfitPercLbl) { }
                    column(ProfitPerc; ProfitPerc) { }
                    column(FiltersLbl; FiltersLbl) { }
                    column(FiltersText; FiltersText) { }
                    column(TotalLbl; TotalLbl) { }
                    column(NoCaption; NoCaptionLbl) { }
                    column(DescCaption; DescCaptionLbl) { }

                    trigger OnPreDataItem()
                    begin
                        Item.SetCurrentKey("Vendor No.");
                        Item.SetRange("Vendor No.", Vendor."No.");
                        Item.SetLoadFields("No.", "Vendor No.");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        TotalSalesPerItem := 0;
                        TotalCOGSPerItem := 0;
                        InvoicedQty := 0;
                        DiscAmount := 0;
                        Profit := 0;
                        ProfitPerc := 0;

                        ValueEntry.SetLoadFields("Salespers./Purch. Code", "Item Ledger Entry Type", "Source Type", "Sales Amount (Actual)", "Item No.", "Posting Date", "Cost Amount (Actual)", "Invoiced Quantity", "Discount Amount");

                        ValueEntry.SetCurrentKey("Source Type", "Source No.", "Item No.", "Posting Date", "Entry Type", Adjustment, "Item Ledger Entry Type");
                        ValueEntry.SetFilter("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                        ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
                        ValueEntry.SetFilter("Sales Amount (Actual)", '<>0');
                        ValueEntry.SetRange("Item No.", Item."No.");
                        ValueEntry.SetFilter("Posting Date", "Salesperson/Purchaser".GetFilter("Date Filter"));

                        if ValueEntry.IsEmpty() then
                            CurrReport.Skip();

                        ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Invoiced Quantity", "Discount Amount");

                        TotalSalesPerItem := Round(ValueEntry."Sales Amount (Actual)", 0.01);
                        TotalCOGSPerItem := Round(-ValueEntry."Cost Amount (Actual)", 0.01);
                        InvoicedQty := -ValueEntry."Invoiced Quantity";
                        DiscAmount := -ValueEntry."Discount Amount";

                        if TotalCOGSPerItem > 0 then begin
                            ProfitPerc := Round(((TotalSalesPerItem - TotalCOGSPerItem) / TotalSalesPerItem) * 100);
                            Profit := Round(TotalSalesPerItem - TotalCOGSPerItem, 0.01);
                        end;
                    end;
                }
                trigger OnPreDataItem()
                begin
                    "Salesperson/Purchaser".SetCurrentKey(Code);
                    "Salesperson/Purchaser".SetLoadFields(Code, Name);
                end;
            }
            trigger OnPreDataItem()
            begin
                Vendor.SetCurrentKey("No.");
                Vendor.SetLoadFields("No.");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    trigger OnPreReport()
    begin
        CreateRequestPageFiltersText(FiltersText);
    end;

    local procedure CreateRequestPageFiltersText(var FiltersTextParam: Text)

    begin
        Clear(FiltersTextParam);
        if Vendor.GetFilters() <> '' then
            FiltersTextParam := Vendor.GetFilters();
        if ("Salesperson/Purchaser".GetFilters() <> '') and (FiltersTextParam <> '') then
            FiltersTextParam += ', ' + "Salesperson/Purchaser".GetFilters()
        else
            FiltersTextParam += "Salesperson/Purchaser".GetFilters();
    end;

    var
        ValueEntry: Record "Value Entry";
        DiscAmount: Decimal;
        InvoicedQty: Decimal;
        Profit: Decimal;
        ProfitPerc: Decimal;
        TotalCOGSPerItem: Decimal;
        TotalSalesPerItem: Decimal;
        FiltersText: Text;
        PageNoTxt: Text[10];
        DiscAmountLbl: Label 'Discount Amount';
        FiltersLbl: Label 'Filters: ';
        InvQtyLbl: Label 'Invoiced Quantity';
        ItemDescLbl: Label 'Item Name';
        ItemNoLbl: Label 'Item No.';
        PageNoLbl: Label 'Page';
        ProfitLbl: Label 'Profit';
        ProfitPercLbl: Label 'Profit %';
        ReportTitleLbl: Label 'Vendor/Salesperson';
        SalesPersonNameLbl: Label 'Name';
        SalesPesonNoLbl: Label 'Salesperson No.';
        TotalCOGSLbl: Label 'Total COGS';
        TotalLbl: Label 'Total';
        TotalSalesLbl: Label 'Total Sales';
        UOMLbl: Label 'Unit of Measure';
        VendorNameLbl: Label 'Vendor Name';
        VendorNoLbl: Label 'Vendor No.';
        NoCaptionLbl: Label 'No.';
        DescCaptionLbl: Label 'Description';
}
