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
        dataitem(ItemCategoryBuffer; "NPR Item Category Buffer")
        {
            DataItemTableView = sorting("Entry No.");
            column("Code"; "Code") { }
            column(CodeWithIndentation; "Code with Indentation") { }
            column(Description; Description) { }
            column(ParentCategory; "Parent Category") { }
            column(Has_Children; "Has Children") { }
            column(Presentation_Order; "Presentation Order") { }
            column(Indentation; Indentation) { }

            #region Calc Fields
            column(SalesQty; "Calc Field 1") { }
            column(CostExclVAT; "Calc Field 2") { }
            column(TurnoverExclVAT; "Calc Field 3") { }
            column(Inventory; "Calc Field 4") { }

            #endregion

            column(Request_Page_Filters; _RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }
            column(Show_Items; _ShowItems) { }
            column(Show_Items_In_All_Categories; _ShowItemsInAllCategories) { }

            dataitem(ItemCategoryBufferDetail; "NPR Item Category Buffer")
            {
                DataItemLink = "Code" = field("Code");
                DataItemTableView = sorting("Entry No.");
                column(ItemCategoryBufferDetail_Code; "Code") { }
                column(Detail_Item_No; "Detail Field 1") { }
                column(Detail_Item_Description; "Detail Field 2") { }
                column(Detail_Item_Category_Code; "Detail Field 3") { }
                column(Detail_Presentation_Order; "Presentation Order") { }

                #region Calc Fields
                column(SalesQty_Item; "Calc Field 1") { }
                column(COGSLCY_Item; "Calc Field 2") { }
                column(SalesLCY_Item; "Calc Field 3") { }
                column(Inventory_Item; "Calc Field 4") { }

                #endregion
            }
        }

        dataitem(ItemCategoryFilter; "Item Category")
        {
            DataItemTableView = sorting("Code");
            RequestFilterFields = "Code", "NPR Date Filter", "NPR Global Dimension 1 Filter", "NPR Global Dimension 2 Filter", "NPR Vendor Filter";
            UseTemporary = true;
        }
        dataitem(ItemFilter; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            UseTemporary = true;
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
                    field("Show Items in All Categories"; _ShowItemsInAllCategories)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show Items in All Categories';
                        ToolTip = 'Use this option to control whether you want to print the individual items within each category or just the category itself.';
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
    }

    trigger OnInitReport()
    begin
        _NumberofLevels := 2;
    end;

    trigger OnPreReport()
    var
        DetailFieldKeys: List of [Integer];
    begin
        _RequestPageFilters := CreateRequestPageFiltersTxt();

        CreateItemCategoryBufferDataItems(ItemCategoryBuffer, ItemCategoryBufferDetail);

        if ItemCategoryFilter.GetFilter(Code) = '' then
            AddUncategorizedToItemCategoryBuffers(ItemCategoryBuffer, ItemCategoryBufferDetail);

        DetailFieldKeys.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 1"));

        ItemCategoryBuffer.Reset();
        ItemCategoryBufferDetail.Reset();
        _ItemCategoryMgt.AddItemCategoryParentsToBuffer(ItemCategoryBuffer);
        _ItemCategoryMgt.AddItemCategoryParentsToBuffer(ItemCategoryBufferDetail, DetailFieldKeys);

        ItemCategoryBuffer.Reset();
        if ItemCategoryBuffer.IsEmpty() then
            Error(_EmptyDatasetErrorLbl);

        ItemCategoryBuffer.Reset();
        ItemCategoryBuffer.SetFilter(Indentation, '>%1', _NumberOfLevels - 1);
        ItemCategoryBuffer.DeleteAll();

        _ItemCategoryMgt.SortItemCategoryBuffer(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 1"), true);
        _ItemCategoryMgt.SortItemCategoryBuffer(ItemCategoryBufferDetail, ItemCategoryBufferDetail.FieldNo("Calc Field 1"), true);

        _ItemCategoryMgt.UpdateHasChildrenFieldInItemCategoryBuffer(ItemCategoryBuffer);
    end;

    var
        _ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        _ShowItems: Boolean;
        _ShowItemsInAllCategories: Boolean;
        _NumberofLevels: Integer;
        _RequestPageFilters: Text;
        _EmptyDatasetErrorLbl: Label 'The report couldn''t be generated, because it was empty. Adjust your filters and try again.';
        _TxtShowItem: Label 'Show items';
        _UncategorizedCategoryCodeLbl: Label '-';
        _UncategorizedCategoryDescLbl: Label 'Without category';

    local procedure CreateRequestPageFiltersTxt(): Text
    var
        RequestPageFiltersTxt: Text;
    begin
        if _ShowItems then
            RequestPageFiltersTxt += _TxtShowItem;

        if (RequestPageFiltersTxt <> '') and (ItemCategoryFilter.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + ItemCategoryFilter.GetFilters()
        else
            RequestPageFiltersTxt += ItemCategoryFilter.GetFilters();

        if (RequestPageFiltersTxt <> '') and (ItemFilter.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + ItemFilter.GetFilters()
        else
            RequestPageFiltersTxt += ItemFilter.GetFilters();

        exit(RequestPageFiltersTxt);
    end;

    local procedure AddUncategorizedToItemCategoryBuffers(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary)
    var
        Item: Record Item;
        ItemCategoryCode: Code[20];
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        ConsumptionAmount: Decimal;
        Inventory: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        TotalConsumptionAmount: Decimal;
        TotalInventory: Decimal;
        TotalSalesLCY: Decimal;
        TotalSalesQty: Decimal;
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
    begin
        ItemCategoryCode := '';
        Item.SetFilter("Item Category Code", '=%1', ItemCategoryCode);
        if ItemFilter.GetFilter("No.") <> '' then
            Item.SetFilter("No.", ItemFilter.GetFilter("No."));

        if not Item.FindSet() then
            exit;

        repeat
            Clear(SalesLCY);
            Clear(ConsumptionAmount);
            Clear(SalesQty);
            Clear(Inventory);
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
            _ItemCategoryMgt.ClearDetailFieldsDictionary(DetailFieldsDict);

            CalcSalesQty(ItemCategoryCode, Item."No.", SalesQty);

            if SalesQty > 0 then begin
                CalcSalesLCYAndConsumptionAmount(ItemCategoryCode, Item."No.", SalesLCY, ConsumptionAmount);
                CalcInventory(ItemCategoryCode, Item."No.", Inventory);

                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 1"), SalesQty);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 2"), ConsumptionAmount);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 3"), SalesLCY);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 4"), Inventory);

                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 1"), Item."No.");
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 2"), Item.Description);
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 3"), _UncategorizedCategoryCodeLbl);

                _ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer(_UncategorizedCategoryCodeLbl, _UncategorizedCategoryDescLbl, ItemCategoryBufferDetail, '', '', '', CalcFieldsDict, DetailFieldsDict);

                TotalInventory += Inventory;
                TotalSalesLCY += SalesLCY;
                TotalSalesQty += SalesQty;
                TotalConsumptionAmount += ConsumptionAmount;
            end;
        until Item.Next() = 0;

        if TotalSalesQty > 0 then begin
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
            CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 1"), TotalSalesQty);
            CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 2"), TotalConsumptionAmount);
            CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 3"), TotalSalesLCY);
            CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 4"), TotalInventory);

            _ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer(_UncategorizedCategoryCodeLbl, _UncategorizedCategoryDescLbl, ItemCategoryBuffer, '', '', '', CalcFieldsDict, DetailFieldsDict);
        end;
    end;

    local procedure CreateItemCategoryBufferDataItems(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary)
    var
        ItemCategory: Record "Item Category";
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
        ConsumptionAmount: Decimal;
        SalesLCY: Decimal;
        TotalInventory: Decimal;
    begin
        ItemCategory.CopyFilters(ItemCategoryFilter);
        if ItemFilter.GetFilter("No.") <> '' then
            ItemCategory.SetFilter("NPR Item Filter", ItemFilter.GetFilter("No."));

        ItemCategory.CalcFields("NPR Sales (Qty.)");

        ItemCategory.SetFilter("NPR Sales (Qty.)", '>%1', 0);

        if not ItemCategory.FindSet() then
            exit;

        repeat
            Clear(SalesLCY);
            Clear(ConsumptionAmount);
            Clear(TotalInventory);
            ItemCategory.CalcFields("NPR Sales (Qty.)");
            ItemCategory.NPRGetVESalesLCYAndConsumptionAmount(SalesLCY, ConsumptionAmount);

            if (SalesLCY <> 0) or (ConsumptionAmount <> 0) then begin
                _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

                TotalInventory := CreateDetailDataitem(ItemCategory.Code, ItemCategoryBufferDetail);

                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), ItemCategory."NPR Sales (Qty.)");
                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), ConsumptionAmount);
                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), SalesLCY);
                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 4"), TotalInventory);

                _ItemCategoryMgt.InsertItemCategoryToBuffer(ItemCategory.Code, ItemCategoryBuffer, '', '', '', CalcFieldsDict, DetailFieldsDict);
            end;
        until ItemCategory.Next() = 0;
    end;

    local procedure CreateDetailDataitem(ItemCategoryCode: Code[20]; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary): Decimal
    var
        Item: Record Item;
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        ConsumptionAmount: Decimal;
        Inventory: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        TotalInventory: Decimal;
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
    begin
        Item.SetRange("Item Category Code", ItemCategoryCode);

        if not Item.FindSet() then
            exit;

        repeat
            Clear(SalesLCY);
            Clear(ConsumptionAmount);
            Clear(SalesQty);
            Clear(Inventory);
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
            _ItemCategoryMgt.ClearDetailFieldsDictionary(DetailFieldsDict);

            CalcSalesQty(ItemCategoryCode, Item."No.", SalesQty);

            if SalesQty > 0 then begin

                CalcSalesLCYAndConsumptionAmount(ItemCategoryCode, Item."No.", SalesLCY, ConsumptionAmount);
                CalcInventory(ItemCategoryCode, Item."No.", Inventory);

                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 1"), SalesQty);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 2"), ConsumptionAmount);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 3"), SalesLCY);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 4"), Inventory);

                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 1"), Item."No.");
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 2"), Item.Description);
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 3"), Item."Item Category Code");

                _ItemCategoryMgt.InsertItemCategoryToBuffer(ItemCategoryCode, ItemCategoryBufferDetail, '', '', '', CalcFieldsDict, DetailFieldsDict);

                TotalInventory += Inventory;
            end;
        until Item.Next() = 0;

        exit(TotalInventory);
    end;

    internal procedure CalcSalesLCYAndConsumptionAmount(ItemCategoryCode: Code[20]; ItemNo: Code[20]; var SalesLCY: Decimal; var ConsumptionAmount: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        SalesLCY := 0;
        ConsumptionAmount := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, ItemCategoryCode);
        ValueEntryWithVendor.SetRange(Filter_Item_No, ItemNo);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, ItemCategoryFilter."NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, ItemCategoryFilter."NPR Global Dimension 2 Code");
        if ItemCategoryFilter.GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, ItemCategoryFilter.GetFilter("NPR Vendor Filter"));
        if ItemCategoryFilter.GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, ItemCategoryFilter.GetFilter("NPR Date Filter"));

        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            SalesLCY += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
            ConsumptionAmount += -ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;
        ValueEntryWithVendor.Close();
    end;

    internal procedure CalcSalesQty(ItemCategoryCode: Code[20]; ItemNo: Code[20]; var SalesQty: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        SalesQty := 0;
        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, ItemCategoryCode);
        ValueEntryWithVendor.SetRange(Filter_Item_No, ItemNo);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, ItemCategoryFilter."NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, ItemCategoryFilter."NPR Global Dimension 2 Code");
        if ItemCategoryFilter.GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, ItemCategoryFilter.GetFilter("NPR Vendor Filter"));
        if ItemCategoryFilter.GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, ItemCategoryFilter.GetFilter("NPR Date Filter"));

        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            SalesQty += -ValueEntryWithVendor.Sum_Invoiced_Quantity;
        ValueEntryWithVendor.Close();
    end;

    internal procedure CalcInventory(ItemCategoryCode: Code[20]; ItemNo: Code[20]; var Inventory: Decimal)
    var
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        Inventory := 0;
        ValueEntryWithVendor.SetRange(Filter_Item_No, ItemNo);
        ValueEntryWithVendor.SetFilter(Filter_Dim_1_Code, ItemCategoryFilter."NPR Global Dimension 1 Code");
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, ItemCategoryFilter."NPR Global Dimension 2 Code");
        if ItemCategoryFilter.GetFilter("NPR Vendor Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_Vendor_No, ItemCategoryFilter.GetFilter("NPR Vendor Filter"));
        if ItemCategoryFilter.GetFilter("NPR Date Filter") <> '' then
            ValueEntryWithVendor.SetFilter(Filter_DateTime, ItemCategoryFilter.GetFilter("NPR Date Filter"));

        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do
            Inventory += ValueEntryWithVendor.Sum_Item_Ledger_Entry_Quantity;
        ValueEntryWithVendor.Close();
    end;
}