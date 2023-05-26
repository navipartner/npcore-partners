report 6014431 "NPR S.Person Trn by Item Cat."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Person Trn. by Item Cat.rdlc';
    Caption = 'Salesperson Turnover per Item Category';
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

            #endregion

            column(Request_Page_Filters; _RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }
            column(Show_Salespersons_In_All_Categories; _ShowSalespersonsInAllCategories) { }

            dataitem(ItemCategoryBufferDetail; "NPR Item Category Buffer")
            {
                DataItemLink = "Code" = field("Code");
                DataItemTableView = sorting("Entry No.");
                column(ItemCategoryBufferDetail_Code; "Code") { }
                column(Salesperson_Code; "Detail Field 1") { }
                column(Salesperson_Name; "Detail Field 2") { }

                #region Calc Fields
                column(Salesperson_SalesQty; "Calc Field 1") { }
                column(Salesperson_COGSLCY; "Calc Field 2") { }
                column(Salesperson_SalesLCY; "Calc Field 3") { }

                #endregion
            }
        }

        dataitem(ItemCategoryFilter; "Item Category")
        {
            DataItemTableView = sorting("Code");
            RequestFilterFields = "Code", "NPR Date Filter";
            UseTemporary = true;
        }
        dataitem(SalespersonPurchaserFilter; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting("Code");
            RequestFilterFields = "Code";
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
                    field("Show Salespersons in All Categories"; _ShowSalespersonsInAllCategories)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show Salesperson in All Categories';
                        ToolTip = 'Use this option to control whether you want to print the individual Salespersons within each category';
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
        ReportCaptionLbl = 'Salesperson Turnover per Item Category';
        SalesPersonCaptionLbl = 'Salesperson';
        MarginCaptionLbl = 'Margin';
        PartPctCaptionLbl = 'Part %';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        DescCaptionLbl = 'Description';
        SaleQtyCaptionLbl = 'Sales (Qty.)';
        TurnoverExclVatCaptionLbl = 'Turnover Excl. VAT';
        ProfitPctCaptionLbl = 'Profit %';
        InventoryCaptionLbl = 'Inventory';
        FiltersCaptionLbl = 'Filters:';
    }

    trigger OnInitReport()
    begin
        _NumberofLevels := 2;
    end;

    trigger OnPreReport()
    begin
        _RequestPageFilters := CreateRequestPageFiltersTxt();

        CreateItemCategoryBufferDataItems(ItemCategoryBuffer, ItemCategoryBufferDetail);

        ItemCategoryBuffer.Reset();
        ItemCategoryBufferDetail.Reset();
        _ItemCategoryMgt.AddItemCategoryParentsToBuffer(ItemCategoryBuffer);

        if ItemCategoryFilter.GetFilter(Code) = '' then
            AddUncategorizedToItemCategoryBuffers(ItemCategoryBuffer, ItemCategoryBufferDetail);

        if ItemCategoryBuffer.IsEmpty() then
            Error(_EmptyDatasetErrorLbl);

        ItemCategoryBuffer.Reset();
        ItemCategoryBuffer.SetFilter(Indentation, '>%1', _NumberOfLevels - 1);
        ItemCategoryBuffer.DeleteAll();

        ItemCategoryBuffer.Reset();
        _ItemCategoryMgt.UpdateHasChildrenFieldInItemCategoryBuffer(ItemCategoryBuffer);
    end;

    var
        _ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        _ShowSalespersonsInAllCategories: Boolean;
        _NumberofLevels: Integer;
        _RequestPageFilters: Text;
        _EmptyDatasetErrorLbl: Label 'The report couldn''t be generated, because it was empty. Adjust your filters and try again.';
        _UncategorizedCategoryCodeLbl: Label '-';
        _UncategorizedCategoryDescLbl: Label 'Without category';

    local procedure CreateRequestPageFiltersTxt(): Text
    var
        RequestPageFiltersTxt: Text;
    begin
        if (RequestPageFiltersTxt <> '') and (ItemCategoryFilter.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + ItemCategoryFilter.GetFilters()
        else
            RequestPageFiltersTxt += ItemCategoryFilter.GetFilters();

        if (RequestPageFiltersTxt <> '') and (SalespersonPurchaserFilter.GetFilters() <> '') then
            RequestPageFiltersTxt += ', ' + SalespersonPurchaserFilter.GetFilters()
        else
            RequestPageFiltersTxt += SalespersonPurchaserFilter.GetFilters();

        exit(RequestPageFiltersTxt);
    end;

    local procedure CreateItemCategoryBufferDataItems(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary)
    var
        ItemCategory: Record "Item Category";
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
        ConsumptionAmount: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
    begin
        ItemCategory.CopyFilters(ItemCategoryFilter);
        ItemCategory.SetFilter("NPR Salesperson/Purch. Filter", SalespersonPurchaserFilter.GetFilter("Code"));

        if not ItemCategory.FindSet() then
            exit;

        repeat
            Clear(SalesLCY);
            Clear(SalesQty);
            Clear(ConsumptionAmount);

            CreateDetailDataitem(ItemCategory.Code, ItemCategoryBufferDetail, SalesQty, ConsumptionAmount, SalesLCY);

            if (SalesLCY <> 0) or (ConsumptionAmount <> 0) then begin
                _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), SalesQty);
                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), ConsumptionAmount);
                CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), SalesLCY);

                _ItemCategoryMgt.InsertItemCategoryToBuffer(ItemCategory.Code, ItemCategoryBuffer, '', '', '', CalcFieldsDict, DetailFieldsDict);
            end;
        until ItemCategory.Next() = 0;
    end;

    local procedure AddUncategorizedToItemCategoryBuffers(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        COGSLCY: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        TotalCOGSLCY: Decimal;
        TotalSalesLCY: Decimal;
        TotalSalesQty: Decimal;
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
    begin
        SalespersonPurchaser.SetFilter("Code", SalespersonPurchaserFilter.GetFilter("Code"));
        SalespersonPurchaser.SetFilter("NPR Item Category Filter", '=%1', '');

        if ItemCategoryFilter.GetFilter("NPR Date Filter") <> '' then
            SalespersonPurchaser.SetFilter("Date Filter", ItemCategoryFilter.GetFilter("NPR Date Filter"));

        if not SalespersonPurchaser.FindSet() then
            exit;

        repeat
            Clear(SalesQty);
            Clear(SalesLCY);
            Clear(COGSLCY);
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
            _ItemCategoryMgt.ClearDetailFieldsDictionary(DetailFieldsDict);

            SalespersonPurchaser.NPRGetVESalesQty(SalesQty);
            SalespersonPurchaser.NPRGetVESalesLCY(SalesLCY);
            SalespersonPurchaser.NPRGetVECOGSLCY(COGSLCY);

            if SalesQty > 0 then begin
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 1"), SalesQty);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 2"), COGSLCY);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 3"), SalesLCY);

                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 1"), SalespersonPurchaser."Code");
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 2"), SalespersonPurchaser.Name);

                _ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer(_UncategorizedCategoryCodeLbl, _UncategorizedCategoryDescLbl, ItemCategoryBufferDetail, '', '', '', CalcFieldsDict, DetailFieldsDict);

                TotalSalesQty += SalesQty;
                TotalCOGSLCY += COGSLCY;
                TotalSalesLCY += SalesLCY;
            end;
        until SalespersonPurchaser.Next() = 0;


        if (TotalSalesLCY <> 0) or (TotalCOGSLCY <> 0) then begin
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

            CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), TotalSalesQty);
            CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), TotalCOGSLCY);
            CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), TotalSalesLCY);

            _ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer(_UncategorizedCategoryCodeLbl, _UncategorizedCategoryDescLbl, ItemCategoryBuffer, '', '', '', CalcFieldsDict, DetailFieldsDict);
        end;
    end;

    local procedure CreateDetailDataitem(ItemCategoryCode: Code[20]; var ItemCategoryBufferDetail: Record "NPR Item Category Buffer" temporary; var TotalSalesQty: Decimal; var TotalCOGSLCY: Decimal; var TotalSalesLCY: Decimal)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CalcFieldsDict: Dictionary of [Integer, Decimal];
        COGSLCY: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        DetailFieldsDict: Dictionary of [Integer, Text[100]];
    begin
        SalespersonPurchaser.SetFilter("Code", SalespersonPurchaserFilter.GetFilter("Code"));
        SalespersonPurchaser.SetFilter("NPR Item Category Filter", ItemCategoryCode);

        if ItemCategoryFilter.GetFilter("NPR Date Filter") <> '' then
            SalespersonPurchaser.SetFilter("Date Filter", ItemCategoryFilter.GetFilter("NPR Date Filter"));

        if not SalespersonPurchaser.FindSet() then
            exit;

        repeat
            Clear(SalesQty);
            Clear(SalesLCY);
            Clear(COGSLCY);
            _ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
            _ItemCategoryMgt.ClearDetailFieldsDictionary(DetailFieldsDict);

            SalespersonPurchaser.NPRGetVESalesQty(SalesQty);
            SalespersonPurchaser.NPRGetVESalesLCY(SalesLCY);
            SalespersonPurchaser.NPRGetVECOGSLCY(COGSLCY);

            if SalesQty > 0 then begin
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 1"), SalesQty);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 2"), COGSLCY);
                CalcFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Calc Field 3"), SalesLCY);

                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 1"), SalespersonPurchaser."Code");
                DetailFieldsDict.Add(ItemCategoryBufferDetail.FieldNo("Detail Field 2"), SalespersonPurchaser.Name);

                _ItemCategoryMgt.InsertItemCategoryToBuffer(ItemCategoryCode, ItemCategoryBufferDetail, SalespersonPurchaser.Code, '', '', CalcFieldsDict, DetailFieldsDict);

                TotalSalesQty += SalesQty;
                TotalCOGSLCY += COGSLCY;
                TotalSalesLCY += SalesLCY;
            end;
        until SalespersonPurchaser.Next() = 0;
    end;
}