report 6014457 "NPR Sales Stat/Analysis"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics by Item Category.rdlc';
    Caption = 'Sales Statistics by Item Category';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategory; "Item Category")
        {
            DataItemTableView = sorting("Code");
            column(ItemCategory_Code; "Code") { }
            column(ItemCategory_Description; Description) { }
            column(ItemCategory_Indentation; Indentation) { }
            column(ItemCategory_PresentationOrder; "Presentation Order") { }
            column(ItemCategory_ParentCategory; "Parent Category") { }

            column(Request_Page_Filters; _RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }
            column(Show_Items; _ShowItems) { }
            column(NumberOfLevels; _NumberOfLevels) { }

            dataitem(Item; Item)
            {
                CalcFields = "Sales (Qty.)", "Sales (LCY)", Inventory, "COGS (LCY)";
                DataItemLink = "Item Category Code" = field(Code);
                DataItemTableView = sorting("No.");
                RequestFilterFields = "Item Category Code", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter", "Vendor No.";

                column(Item_No; "No.") { }
                column(Item_Description; Description) { }
                column(Item_ItemCategory; "Item Category Code") { }
                column(Item_SalesQty; "Sales (Qty.)") { }
                column(Item_SalesLCY; "Sales (LCY)") { }
                column(Item_InventoryQty; Inventory) { }
                column(Item_Profit; "Sales (LCY)" - "COGS (LCY)") { }
                column(Item_COGSLCY; "COGS (LCY)") { }

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
                CalcFields = "Sales (Qty.)", "Sales (LCY)", Inventory, "COGS (LCY)";
                DataItemTableView = sorting("No.") where("Item Category Code" = const(''));

                column(Item2_No; "No.") { }
                column(Item2_Description; Description) { }
                column(Item2_ItemCategory; "Item Category Code") { }
                column(Item2_SalesQty; "Sales (Qty.)") { }
                column(Item2_SalesLCY; "Sales (LCY)") { }
                column(Item2_InventoryQty; Inventory) { }
                column(Item2_Profit; "Sales (LCY)" - "COGS (LCY)") { }
                column(Item2_COGSLCY; "COGS (LCY)") { }

                trigger OnPreDataItem()
                begin
                    if Item.GetFilter("Date Filter") <> '' then
                        Item2.SetFilter("Date Filter", Item.GetFilter("Date Filter"));
                    if Item.GetFilter("Global Dimension 1 Filter") <> '' then
                        Item2.SetFilter("Global Dimension 1 Filter", Item.GetFilter("Global Dimension 1 Filter"));
                    if Item.GetFilter("Global Dimension 2 Filter") <> '' then
                        Item2.SetFilter("Global Dimension 2 Filter", Item.GetFilter("Global Dimension 2 Filter"));
                    if Item.GetFilter("Vendor No.") <> '' then
                        Item2.SetFilter("Vendor No.", Item.GetFilter("Vendor No."));
                end;

                trigger OnAfterGetRecord()
                begin
                    if "Sales (Qty.)" = 0 then
                        CurrReport.Skip();
                end;
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
                        ToolTip = 'Use this option to control whether you want to print the individual items within categories without subcategory or just the category itself.';
                    }
                    field("Number of Levels"; _NumberofLevels)
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
        ReportCaptionLbl = 'Sales Statistics by Item Category';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        DescCaptionLbl = 'Description';
        SaleQtyCaptionLbl = 'Sales (Qty.)';
        CostExclVatCaptionLbl = 'Cost Excl. VAT';
        TurnoverExclVatCaptionLbl = 'Turnover Excl. VAT';
        ProfitPctCaptionLbl = 'Profit %';
        InventoryCaptionLbl = 'Inventory';
        CoverageMarginCaptionLbl = 'Coverage Margin';
        UnitContributionMarginCaptionLbl = 'Unit Contribution Margin';
        FiltersCaptionLbl = 'Filters:';
        TotalCaptionLbl = 'Total';
    }

    trigger OnInitReport()
    begin
        _NumberofLevels := 3;
    end;

    trigger OnPreReport()
    begin
        _RequestPageFilters := CreateRequestPageFiltersTxt();
    end;

    var
        _ShowItems: Boolean;
        _NumberofLevels: Integer;
        _RequestPageFilters: Text;
        _TxtShowItem: Label 'Show items';
        _UncategorizedCategoryCodeLbl: Label '-';
        _UncategorizedCategoryDescLbl: Label 'Without category';

    local procedure CreateRequestPageFiltersTxt(): Text
    var
        RequestPageFiltersTxt: Text;
    begin
        if _ShowItems then
            RequestPageFiltersTxt += _TxtShowItem;

        if (RequestPageFiltersTxt <> '') and (ItemCategory.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + ItemCategory.GetFilters()
        else
            RequestPageFiltersTxt += ItemCategory.GetFilters();

        if (RequestPageFiltersTxt <> '') and (Item.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + Item.GetFilters()
        else
            RequestPageFiltersTxt += Item.GetFilters();

        exit(RequestPageFiltersTxt);
    end;

}