report 6014430 "NPR Item Sales Stats/Provider"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales StatisticsProvider.rdlc';
    Caption = 'Item Sales Statistics by Vendor';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

            column(Vendor_No; "No.") { }
            column(Vendor_Name; Name) { }
            column(Request_Page_Filters; _RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }
            column(Show_Items; _ShowItems) { }
            column(NumberOfLevels; _NumberOfLevels) { }

            dataitem(ItemCategory; "Item Category")
            {
                DataItemTableView = sorting("Code");
                column(ItemCategory_Code; "Code") { }
                column(ItemCategory_Description; Description) { }
                column(ItemCategory_Indentation; Indentation) { }
                column(ItemCategory_PresentationOrder; "Presentation Order") { }
                column(ItemCategory_ParentCategory; "Parent Category") { }

                dataitem(Item; Item)
                {
                    CalcFields = "Sales (Qty.)", "Sales (LCY)", "Scheduled Receipt (Qty.)", Inventory, "COGS (LCY)", "Purchases (Qty.)";
                    DataItemLink = "Item Category Code" = field(Code);
                    DataItemTableView = sorting("No.");
                    RequestFilterFields = "Global Dimension 1 Filter", "Date Filter";

                    column(Item_No; "No.") { }
                    column(Item_Description; Description) { }
                    column(Item_VendorItemNo; "Vendor Item No.") { }
                    column(Item_ItemCategory; "Item Category Code") { }
                    column(Item_SalesQty; "Sales (Qty.)") { }
                    column(Item_PurchasesQty; "Purchases (Qty.)") { }
                    column(Item_SalesLCY; "Sales (LCY)") { }
                    column(Item_InventoryQty; Inventory) { }
                    column(Item_InventoryValue; Inventory * "Last Direct Cost") { }
                    column(Item_Profit; "Sales (LCY)" - "COGS (LCY)") { }
                    column(Item_COGSLCY; "COGS (LCY)") { }


                    trigger OnPreDataItem()
                    begin
                        Item.SetRange("Vendor No.", Vendor."No.");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if "Sales (Qty.)" = 0 then
                            CurrReport.Skip();
                    end;
                }
            }
            dataitem(ItemCategory2; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));

                column(ItemCategory2_Code; _UncategorizedCategoryCodeLbl) { }
                column(ItemCategory2_Description; _UncategorizedCategoryDescLbl) { }

                dataitem(Item2; Item)
                {
                    CalcFields = "Sales (Qty.)", "Purchases (Qty.)", "Sales (LCY)", Inventory, "COGS (LCY)";
                    DataItemTableView = sorting("No.") where("Item Category Code" = const(''));
                    RequestFilterFields = "Global Dimension 1 Filter", "Date Filter";

                    column(Item2_No; "No.") { }
                    column(Item2_Description; Description) { }
                    column(Item2_VendorItemNo; "Vendor Item No.") { }
                    column(Item2_ItemCategory; "Item Category Code") { }
                    column(Item2_PurchasesQty; "Purchases (Qty.)") { }
                    column(Item2_SalesQty; "Sales (Qty.)") { }
                    column(Item2_SalesLCY; "Sales (LCY)") { }
                    column(Item2_InventoryQty; Inventory) { }
                    column(Item2_InventoryValue; Inventory * "Last Direct Cost") { }
                    column(Item2_Profit; "Sales (LCY)" - "COGS (LCY)") { }
                    column(Item2_COGSLCY; "COGS (LCY)") { }

                    trigger OnPreDataItem()
                    begin
                        Item2.SetRange("Vendor No.", Vendor."No.");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if "Sales (Qty.)" = 0 then
                            CurrReport.Skip();
                    end;
                }
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
                    Caption = 'Options';
                    field("Show Items"; _ShowItems)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show Items';
                        ToolTip = 'Use this option to control whether you want to print the individual items within categories or just the category itself.';
                    }
                    field("Number of Levels"; _NumberOfLevels)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Number of Levels';
                        MinValue = 1;
                        ToolTip = 'Specifies how many levels of item categories are displayed on the report. Adjust this field to control the level of detail in the report.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'Item Sales Statistics by Vendor';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        VendorItemNoCaptionLbl = 'Vendor Item No.';
        DescCaptionLbl = 'Description';
        FiltersCaptionLbl = 'Filters:';
        PurchaseQtyCaptionLbl = 'Purchase (Qty.)';
        SalesQtyCaptionLbl = 'Sales (Qty.)';
        SalesLCYCaptionLbl = 'Sales (LCY)';
        ProfitCaptionLbl = 'Profit';
        InventoryQtyCaptionLbl = 'Inventory (Qty.)';
        InventoryValueCaptionLbl = 'Inventory Value';
        UnitContributionMarginCaptionLbl = 'Unit Contribution Margin';
        TurnoverRateCaptionLbl = 'Turnover rate';
        ProfitPctCaptionLbl = 'Profit %';
        VendorTotalCaptionLbl = 'Total for Vendor';
    }

    trigger OnPreReport()
    begin
        CreateRequestPageFiltersTxt(_RequestPageFilters);
    end;

    trigger OnInitReport()
    begin
        _NumberOfLevels := 3;
        _ShowItems := true;
    end;

    var
        _ShowItems: Boolean;
        _NumberOfLevels: Integer;
        _RequestPageFilters: Text;
        _TxtShowItem: Label 'Show items';
        _UncategorizedCategoryCodeLbl: Label '-';
        _UncategorizedCategoryDescLbl: Label 'Without category';


    local procedure CreateRequestPageFiltersTxt(var FiltersTxt: Text)
    begin
        if _ShowItems then
            FiltersTxt += _TxtShowItem;

        if (FiltersTxt <> '') and (Vendor.GetFilters() <> '') then
            FiltersTxt += ', ' + Vendor.GetFilters()
        else
            FiltersTxt += Vendor.GetFilters();

        if (FiltersTxt <> '') and (Item.GetFilters() <> '') then
            FiltersTxt += ', ' + Item.GetFilters()
        else
            FiltersTxt += Item.GetFilters();
    end;
}