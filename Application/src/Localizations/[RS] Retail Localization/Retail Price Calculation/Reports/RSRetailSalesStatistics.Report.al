report 6014546 "NPR RS Retail Sales Statistics"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/Localizations/[RS] Retail Localization/Retail Price Calculation/Reports/Retail Sales Statistics by Item Category.rdlc';
    Caption = 'Retail Sales Statistics by Item Category';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRSRLocal;
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
            column(NumberOfLevels; _NumberofLevels) { }
            dataitem(Item; Item)
            {
                DataItemLink = "Item Category Code" = field(Code);
                DataItemTableView = sorting("No.");
                RequestFilterFields = "Item Category Code", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter", "Vendor No.";

                column(Item_No; "No.") { }
                column(Item_Description; Description) { }
                column(Item_ItemCategory; "Item Category Code") { }
                column(Item_SalesQty; ItemSalesQty) { }
                column(Item_SalesLCY; ItemSalesLCY) { }
                column(Item_InventoryQty; ItemInvQty) { }
                column(Item_Profit; ItemSalesLCY - ItemCOGSLCY) { }
                column(Item_COGSLCY; ItemCOGSLCY) { }

                trigger OnAfterGetRecord()
                begin
                    Clear(ItemSalesLCY);
                    Clear(ItemSalesQty);
                    Clear(ItemCOGSLCY);
                    Clear(ItemInvQty);

                    CalculateSalesAmount(ItemSalesLCY, ItemSalesQty, Item);
                    if ItemSalesQty = 0 then
                        CurrReport.Skip();

                    CalculateCOGSAmount(ItemCOGSLCY, Item);
                    CalculateInventoryQty(ItemInvQty, Item);
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
                DataItemTableView = sorting("No.") where("Item Category Code" = const(''));

                column(Item2_No; "No.") { }
                column(Item2_Description; Description) { }
                column(Item2_ItemCategory; "Item Category Code") { }
                column(Item2_SalesQty; Item2SalesQty) { }
                column(Item2_SalesLCY; Item2SalesLCY) { }
                column(Item2_InventoryQty; Item2InvQty) { }
                column(Item2_Profit; Item2SalesLCY - Item2COGSLCY) { }
                column(Item2_COGSLCY; Item2COGSLCY) { }

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
                    Clear(Item2SalesLCY);
                    Clear(Item2SalesQty);
                    Clear(Item2COGSLCY);
                    Clear(Item2InvQty);

                    CalculateSalesAmount(Item2SalesLCY, Item2SalesQty, Item);
                    if Item2SalesQty = 0 then
                        CurrReport.Skip();

                    CalculateCOGSAmount(Item2COGSLCY, Item);
                    CalculateInventoryQty(Item2InvQty, Item);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Show Items"; _ShowItems)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Show Items';
                        ToolTip = 'Use this option to control whether you want to print the individual items within categories without subcategory or just the category itself.';
                    }
                    field("Number of Levels"; _NumberofLevels)
                    {
                        ApplicationArea = NPRRSRLocal;
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
        ReportCaptionLbl = 'Retal Sales Statistics by Item Category';
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
        Item2COGSLCY: Decimal;
        Item2InvQty: Decimal;
        Item2SalesLCY: Decimal;
        Item2SalesQty: Decimal;
        ItemCOGSLCY: Decimal;
        ItemInvQty: Decimal;
        ItemSalesLCY: Decimal;
        ItemSalesQty: Decimal;
        _NumberofLevels: Integer;
        _TxtShowItem: Label 'Show items';
        _UncategorizedCategoryCodeLbl: Label '-', Locked = true;
        _UncategorizedCategoryDescLbl: Label 'Without category';
        _RequestPageFilters: Text;

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

    local procedure CalculateCOGSAmount(var CostAmountLCY: Decimal; Item: Record Item)
    var
        RSValueEntryMapping: Query "NPR RS Value Entry Mapping";
    begin
        RSValueEntryMapping.SetRange(Filter_COGS_Correction, true);
        RSValueEntryMapping.SetFilter(Filter_Item_No, Item."No.");

        if Item.GetFilter("Date Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Posting_Date, Item."Date Filter");

        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_1_Code, Item."Global Dimension 1 Filter");

        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_2_Code, Item."Global Dimension 2 Filter");

        RSValueEntryMapping.Open();
        while RSValueEntryMapping.Read() do
            CostAmountLCY += RSValueEntryMapping.Cost_Amount_Actual;
    end;

    local procedure CalculateSalesAmount(var SalesAmountLCY: Decimal; var SalesQty: Decimal; Item: Record Item)
    var
        ValueEntry: Record "Value Entry";
        SalesAmountToSubtract: Decimal;
        SalesQtyToSubtract: Decimal;
    begin
        CalculateRetailValueEntryAmount(SalesAmountToSubtract, SalesQtyToSubtract, Item);

        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Item No.", Item."No.");

        if Item.GetFilter("Date Filter") <> '' then
            ValueEntry.SetRange("Posting Date", Item."Date Filter");

        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Item."Global Dimension 1 Filter");

        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Item."Global Dimension 2 Filter");

        ValueEntry.CalcSums("Sales Amount (Actual)", "Invoiced Quantity");

        SalesAmountLCY := ValueEntry."Sales Amount (Actual)" - SalesAmountToSubtract;
        SalesQty := Abs(ValueEntry."Invoiced Quantity") - SalesQtyToSubtract;
    end;

    local procedure CalculateRetailValueEntryAmount(var RetailValueEntryAmount: Decimal; var RetailValueEntryQty: Decimal; Item: Record Item)
    var
        RSValueEntryMapping: Query "NPR RS Value Entry Mapping";
    begin
        RSValueEntryMapping.SetFilter(Filter_Item_No, Item."No.");

        if Item.GetFilter("Date Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Posting_Date, Item."Date Filter");

        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_1_Code, Item."Global Dimension 1 Filter");

        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_2_Code, Item."Global Dimension 2 Filter");

        RSValueEntryMapping.Open();
        while RSValueEntryMapping.Read() do begin
            RetailValueEntryAmount += RSValueEntryMapping.Sales_Amount_Actual;
            RetailValueEntryQty += RSValueEntryMapping.Invoiced_Quantity;
        end;
        RSValueEntryMapping.Close();
    end;

    local procedure CalculateInventoryQty(var InventoryQty: Decimal; Item: Record Item)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", Item."No.");

        if Item.GetFilter("Date Filter") <> '' then
            ItemLedgerEntry.SetRange("Posting Date", Item."Date Filter");

        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Item."Global Dimension 1 Filter");

        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Item."Global Dimension 2 Filter");

        ItemLedgerEntry.CalcSums(Quantity);
        InventoryQty := ItemLedgerEntry.Quantity;
    end;
}