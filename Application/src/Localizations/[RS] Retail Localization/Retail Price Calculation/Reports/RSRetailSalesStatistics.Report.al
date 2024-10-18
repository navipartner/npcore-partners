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
                RequestFilterFields = "Item Category Code";

                column(Item_No; "No.") { }
                column(Item_Description; Description) { }
                column(Item_ItemCategory; "Item Category Code") { }
                column(Item_SalesQty; Abs(ItemSalesQty)) { }
                column(Item_SalesLCY; ItemSalesLCY) { }
                column(Item_InventoryQty; Abs(ItemInvQty)) { }
                column(Item_Profit; ItemSalesLCY - Abs(ItemCOGSLCY)) { }
                column(Item_COGSLCY; Abs(ItemCOGSLCY)) { }

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
                column(Item2_SalesQty; Abs(Item2SalesQty)) { }
                column(Item2_SalesLCY; Item2SalesLCY) { }
                column(Item2_InventoryQty; Abs(Item2InvQty)) { }
                column(Item2_Profit; Item2SalesLCY - Abs(Item2COGSLCY)) { }
                column(Item2_COGSLCY; Abs(Item2COGSLCY)) { }

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
                group(Filters)
                {
                    Caption = 'Filters';
                    field("Start Date"; _StartDate)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field.';
                    }
                    field("End Date"; _EndDate)
                    {
                        ApplicationArea = NPRRSRLocal;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the value of the End Date field.';
                    }
                    field("Location Code"; _LocationCode)
                    {
                        ApplicationArea = NPRRSRLocal;
                        TableRelation = Location;
                        Caption = 'Location Code';
                        ToolTip = 'Specifies the value of the Location Code field.';
                    }
                    field("Global Dimension 1 Code"; _GlobalDim1Code)
                    {
                        ApplicationArea = NPRRSRLocal;
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                        CaptionClass = '1,1,1';
                        Caption = 'Global Dimension 1 Code';
                        ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    }
                    field("Global Dimension 2 Code"; _GlobalDim2Code)
                    {
                        ApplicationArea = NPRRSRLocal;
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
                        CaptionClass = '1,1,2';
                        Caption = 'Global Dimension 2 Code';
                        ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
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
        _StartDate: Date;
        _EndDate: Date;
        _TxtShowItem: Label 'Show items';
        _FilterLocationTxt: Label 'Location Code: %1', Comment = '%1 = Location Code';
        _FilterGlobalDim1Txt: Label 'Global Dimension 1 Code: %1', Comment = '%1 = Global Dimension Code';
        _FilterGlobalDim2Txt: Label 'Global Dimension 2 Code: %1', Comment = '%1 = Global Dimension Code';
        _UncategorizedCategoryCodeLbl: Label '-', Locked = true;
        _UncategorizedCategoryDescLbl: Label 'Without category';
        _DateFilterLbl: Label '%1..%2', Locked = true, Comment = '%1 = Start Date, %2 = End Date';
        _LocationCode: Code[20];
        _GlobalDim1Code: Code[20];
        _GlobalDim2Code: Code[20];
        _NumberofLevels: Integer;
        _RequestPageFilters: Text;

    local procedure CreateRequestPageFiltersTxt(): Text
    var
        RequestPageFiltersTxt: Text;
    begin
        if _ShowItems then
            RequestPageFiltersTxt += _TxtShowItem;

        if _LocationCode <> '' then
            if (RequestPageFiltersTxt <> '') then
                RequestPageFiltersTxt += ',' + StrSubstNo(_FilterLocationTxt, _LocationCode)
            else
                RequestPageFiltersTxt += StrSubstNo(_FilterLocationTxt, _LocationCode);

        if _StartDate <> 0D then
            if (RequestPageFiltersTxt <> '') then
                RequestPageFiltersTxt += ',' + StrSubstNo(_DateFilterLbl, _StartDate, _EndDate)
            else
                RequestPageFiltersTxt += StrSubstNo(_DateFilterLbl, _StartDate, _EndDate);

        if _GlobalDim1Code <> '' then
            if (RequestPageFiltersTxt <> '') then
                RequestPageFiltersTxt += ',' + StrSubstNo(_FilterGlobalDim1Txt, _GlobalDim1Code)
            else
                RequestPageFiltersTxt += StrSubstNo(_FilterGlobalDim1Txt, _GlobalDim1Code);

        if _GlobalDim2Code <> '' then
            if (RequestPageFiltersTxt <> '') then
                RequestPageFiltersTxt += ',' + StrSubstNo(_FilterGlobalDim2Txt, _GlobalDim2Code)
            else
                RequestPageFiltersTxt += StrSubstNo(_FilterGlobalDim2Txt, _GlobalDim2Code);

        exit(RequestPageFiltersTxt);
    end;

    local procedure CalculateCOGSAmount(var CostAmountLCY: Decimal; Item: Record Item)
    var
        ValueEntry: Record "Value Entry";
        RSValueEntryMapping: Query "NPR RS Value Entry Mapping";
    begin
        RSValueEntryMapping.SetRange(Filter_COGS_Correction, true);
        RSValueEntryMapping.SetFilter(Filter_Item_No, Item."No.");

        if _StartDate <> 0D then begin
            RSValueEntryMapping.SetFilter(Filter_Posting_Date, StrSubstNo(_DateFilterLbl, _StartDate, _EndDate));
            ValueEntry.SetFilter("Posting Date", StrSubstNo(_DateFilterLbl, _StartDate, _EndDate));
        end;

        if _LocationCode <> '' then begin
            RSValueEntryMapping.SetRange(Filter_Location_Code, _LocationCode);
            ValueEntry.SetRange("Location Code", _LocationCode);
        end;

        if _GlobalDim1Code <> '' then begin
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_1_Code, _GlobalDim1Code);
            ValueEntry.SetRange("Global Dimension 1 Code", _GlobalDim1Code);
        end;

        if _GlobalDim2Code <> '' then begin
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_2_Code, _GlobalDim2Code);
            ValueEntry.SetRange("Global Dimension 2 Code", _GlobalDim2Code);
        end;

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
        CalculateRetailValueEntrySalesAmount(SalesAmountToSubtract, SalesQtyToSubtract, Item);

        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Item No.", Item."No.");

        if _StartDate <> 0D then
            ValueEntry.SetFilter("Posting Date", StrSubstNo(_DateFilterLbl, _StartDate, _EndDate));

        if _LocationCode <> '' then
            ValueEntry.SetRange("Location Code", _LocationCode);

        if _GlobalDim1Code <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", _GlobalDim1Code);

        if _GlobalDim2Code <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", _GlobalDim2Code);

        ValueEntry.CalcSums("Sales Amount (Actual)", "Invoiced Quantity");

        SalesAmountLCY := ValueEntry."Sales Amount (Actual)" - SalesAmountToSubtract;
        SalesQty := ValueEntry."Invoiced Quantity" - SalesQtyToSubtract;
    end;

    local procedure CalculateRetailValueEntrySalesAmount(var RetailValueEntryAmount: Decimal; var RetailValueEntryQty: Decimal; Item: Record Item)
    var
        RSValueEntryMapping: Query "NPR RS Value Entry Mapping";
    begin
        RSValueEntryMapping.SetFilter(Filter_Item_No, Item."No.");

        if _StartDate <> 0D then
            RSValueEntryMapping.SetFilter(Filter_Posting_Date, StrSubstNo(_DateFilterLbl, _StartDate, _EndDate));

        if _LocationCode <> '' then
            RSValueEntryMapping.SetRange(Filter_Location_Code, _LocationCode);

        if _GlobalDim1Code <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_1_Code, _GlobalDim1Code);

        if _GlobalDim2Code <> '' then
            RSValueEntryMapping.SetRange(Filter_Global_Dimension_2_Code, _GlobalDim2Code);

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

        if _EndDate <> 0D then
            ItemLedgerEntry.SetFilter("Posting Date", StrSubstNo(_DateFilterLbl, 0D, _EndDate));

        if _LocationCode <> '' then
            ItemLedgerEntry.SetRange("Location Code", _LocationCode);

        if _GlobalDim1Code <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", _GlobalDim1Code);

        if _GlobalDim2Code <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", _GlobalDim2Code);

        ItemLedgerEntry.CalcSums(Quantity);
        InventoryQty := ItemLedgerEntry.Quantity;
    end;
}