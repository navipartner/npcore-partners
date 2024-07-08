report 6014420 "NPR Item Category Top"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    RDLCLayout = './src/_Reports/layouts/Item Category Top.rdlc';
    Caption = 'Item Category Top per Department';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategoryFilter; "Item Category")
        {
            RequestFilterFields = "NPR Date Filter", "NPR Global Dimension 1 Filter";
            UseTemporary = true;
        }
        dataitem(DimensionValue; "Dimension Value")
        {
            DataItemTableView = sorting(Code, "Global Dimension No.") where("Global Dimension No." = const(1));

            column(Code_DimensionValue; Code) { }
            column(Name_DimensionValue; Name) { }
            column(Quantity_DimensionValue; TotalQuantity) { }
            column(SalesLCY_DimensionValue; TotalSalesLCY) { }
            column(ProfitLCY_DimensionValue; TotalProfitLCY) { }
            column(ProfitPerc_DimensionValue; TotalProfitPercentage) { }

            column(Name_CompanyInformation; CompanyInformation.Name) { }

            column(FiltersText; FiltersText) { }

            dataitem(ItemCategoryBuffer; "NPR Item Category Buffer")
            {
                DataItemLink = "Global Dimension 1 Code" = field(Code);
                DataItemTableView = sorting("Entry No.");

                column("Code"; "Code") { }
                column(CodeWithIndentation; "Code with Indentation") { }
                column(Description; Description) { }
                column(ParentCategory; "Parent Category") { }
                column(Indentation; Indentation) { }
                column(Quantity; "Calc Field 1") { }
                column(SalesLCY; "Calc Field 2") { }
                column(ProfitLCY; "Calc Field 3") { }
                column(ProfitPerc; "Calc Field 4") { }
                column(Presentation_Order; "Presentation Order") { }
                column(Global_Dimension_1_Code; "Global Dimension 1 Code") { }
                column(OrderNo; "Order No.") { }
            }

            trigger OnPreDataItem()
            begin
                ItemCategoryFilter.CopyFilter("NPR Global Dimension 1 Filter", DimensionValue.Code);
            end;

            trigger OnAfterGetRecord()
            var
                TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
                TempItemCategoryBuffer2: Record "NPR Item Category Buffer" temporary;
                DepartmentItemCategory: Query "NPR Department/Item Category";
                CalcFieldsDict: Dictionary of [Integer, Decimal];
                DetailFieldsDict: Dictionary of [Integer, Text[100]];
                ProfitLCY: Decimal;
                ProfitPercentage: Decimal;
                Index: Integer;
                Ascending: Boolean;
            begin

                TotalQuantity := 0;
                TotalSalesLCY := 0;
                TotalProfitLCY := 0;
                TotalProfitPercentage := 0;

                TempDimensionValue.Reset();
                TempDimensionValue.SetFilter(Code, DimensionValue.Code);
                if not TempDimensionValue.FindFirst() then
                    CurrReport.Skip();

                DepartmentItemCategory.SetRange(Global_Dimension_1_Code, DimensionValue.Code);
                DepartmentItemCategory.SetFilter(Filter_Posting_Date, ItemCategoryFilter.GetFilter("NPR Date Filter"));

                DepartmentItemCategory.Open();
                while DepartmentItemCategory.Read() do begin
                    ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

                    ProfitLCY := DepartmentItemCategory.Sales_Amount_Actual + DepartmentItemCategory.Cost_Amount_Actual; // Cost Amount Actual field from Item Ledger Entry is saved with minus sign
                    ProfitPercentage := ProfitLCY / DepartmentItemCategory.Sales_Amount_Actual;

                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), DepartmentItemCategory.Quantity * (-1));
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), DepartmentItemCategory.Sales_Amount_Actual);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), ProfitLCY);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 4"), ProfitPercentage);

                    ItemCategoryMgt.InsertItemCategoryToBuffer(DepartmentItemCategory.Item_Category_Code, ItemCategoryBuffer, '', DepartmentItemCategory.Global_Dimension_1_Code, '', CalcFieldsDict, DetailFieldsDict);
                end;
                DepartmentItemCategory.Close();


                DepartmentItemCategory.SetRange(Global_Dimension_1_Code, DimensionValue.Code);
                DepartmentItemCategory.SetFilter(Filter_Posting_Date, ItemCategoryFilter.GetFilter("NPR Date Filter"));

                DepartmentItemCategory.SetRange(Item_Category_Code, '');
                DepartmentItemCategory.Open();
                while DepartmentItemCategory.Read() do begin
                    ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);
                    ProfitLCY := 0;
                    ProfitPercentage := 0;

                    ProfitLCY := DepartmentItemCategory.Sales_Amount_Actual + DepartmentItemCategory.Cost_Amount_Actual; // Cost Amount Actial field from Item Ledger Entry is saved with minus sign
                    ProfitPercentage := ProfitLCY / DepartmentItemCategory.Sales_Amount_Actual;

                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), DepartmentItemCategory.Quantity * (-1));
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), DepartmentItemCategory.Sales_Amount_Actual);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), ProfitLCY);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 4"), ProfitPercentage);

                    ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer('-', NotInItemCategoryLbl, ItemCategoryBuffer, DepartmentItemCategory.Global_Dimension_1_Code, '', '', CalcFieldsDict, DetailFieldsDict);
                end;
                DepartmentItemCategory.Close();

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                ItemCategoryMgt.AddItemCategoryParentsToBuffer(ItemCategoryBuffer);

                #region Delete unwanted Levels and Format Identation

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetFilter(Indentation, '>%1', NumberOfLevels - 1);
                ItemCategoryBuffer.DeleteAll();

                ItemCategoryMgt.FormatIndentationInItemCategories(ItemCategoryBuffer, 4);

                #endregion

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                ItemCategoryBuffer.SetRange(Indentation, 0);

                if ItemCategoryBuffer.Count() > NumberOfCategories then begin
                    Index := 0;
                    TempItemCategoryBuffer.DeleteAll();
                    TempItemCategoryBuffer2.DeleteAll();
                    ItemCategoryBuffer.Reset();
                    ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);

                    if ItemCategoryBuffer.FindSet() then
                        repeat
                            TempItemCategoryBuffer.Init();
                            TempItemCategoryBuffer := ItemCategoryBuffer;
                            TempItemCategoryBuffer.Insert();
                        until ItemCategoryBuffer.Next() = 0;

                    ItemCategoryBuffer.Reset();
                    ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                    ItemCategoryBuffer.SetRange(Indentation, 0);

                    if ItemCategoryBuffer.FindSet() then
                        repeat
                            TempItemCategoryBuffer2.Init();
                            TempItemCategoryBuffer2 := ItemCategoryBuffer;
                            TempItemCategoryBuffer2.Insert();
                        until ItemCategoryBuffer.Next() = 0;

                    case SortBy of
                        SortBy::Quantity:
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 1");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 1", false);
                            end;
                        SortBy::"Sales (LCY)":
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 2");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 2", false);
                            end;
                        SortBy::"Profit (LCY)":
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 3");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 3", false);
                            end;
                        SortBy::"Profit %":
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 4");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 4", false);
                            end;
                    end;

                    if TempItemCategoryBuffer2.FindSet() then
                        repeat
                            if Index > NumberOfCategories - 1 then
                                ItemCategoryMgt.DeleteItemCategoryBuffer(TempItemCategoryBuffer2.Code, '', DimensionValue.Code, '', ItemCategoryBuffer, TempItemCategoryBuffer);
                            Index += 1;
                        until TempItemCategoryBuffer2.Next() = 0;
                end;


                CalculateProfitPercentage(ItemCategoryBuffer);
                #region Sorting and updating Dimension Value Totals

                if (SortOrder = SortOrder::Ascending) and (NumberOfCategories > 1) then
                    Ascending := true
                else
                    Ascending := false;

                case SortBy of
                    SortBy::Quantity:
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 1");
                    SortBy::"Sales (LCY)":
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 2");
                    SortBy::"Profit (LCY)":
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 3");
                    SortBy::"Profit %":
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 4");
                end;


                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                ItemCategoryMgt.SortItemCategoryBuffer(ItemCategoryBuffer, SortByFieldNo, Ascending);

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                ItemCategoryBuffer.SetRange(Indentation, 0);

                ItemCategoryBuffer.CalcSums("Calc Field 1", "Calc Field 2", "Calc Field 3");
                TotalQuantity := ItemCategoryBuffer."Calc Field 1";
                TotalSalesLCY := ItemCategoryBuffer."Calc Field 2";
                TotalProfitLCY := ItemCategoryBuffer."Calc Field 3";
                TotalProfitPercentage := ItemCategoryBuffer."Calc Field 3" / ItemCategoryBuffer."Calc Field 2";

                #endregion

                #region Set Order No. On Item Category Buffer
                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Global Dimension 1 Code", DimensionValue.Code);
                ItemCategoryMgt.SetOrderNoInItemCategoryBuffer(ItemCategoryBuffer);

                #endregion

                ItemCategoryBuffer.Reset();
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
                group(Options)
                {
                    field("Number Of Categories"; NumberOfCategories)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Display Top';
                        MinValue = 1;
                        ToolTip = 'Specifies the value of the Display Top field.';
                    }
                    field("Number Of Levels"; NumberOfLevels)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Number of levels to display';
                        MinValue = 1;
                        ToolTip = 'Specifies the value of the Number of levels to display field.';
                    }
                    field("Sort By"; SortBy)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Sort By';
                        ToolTip = 'Specifies the value of the Sort By field.';
                        OptionCaption = 'Sales (LCY),Profit (LCY),Profit %,Quantity';
                    }
                    field("Sort Order"; SortOrder)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Sort Order';
                        ToolTip = 'Specifies the order of sorting for item categories on print.';
                        OptionCaption = 'Ascending,Descending';
                    }
                }
            }
        }
    }


    labels
    {
        ReportCaption = 'Item Category Top per Department';
        SequenceCaption = 'Sequence';
        ItemCategoryCaption = 'Item Category';
        DescriptionCaption = 'Description';
        QuantityCaption = 'Quantity';
        SaleLCYCaption = 'Sales (LCY)';
        ProfitLCYCaption = 'Profit (LCY)';
        ProfitPctCaption = 'Profit %';
        TotalCaption = 'Total';
        PageNumberCaption = 'Page';
    }

    trigger OnInitReport()
    begin
        NumberOfLevels := 5;
        NumberOfCategories := 20;
    end;

    trigger OnPreReport()
    var
        DepartmentItemCategory: Query "NPR Department/Item Category";
    begin

        CompanyInformation.Get();

        TempDimensionValue.Reset();

        DepartmentItemCategory.SetFilter(Global_Dimension_1_Code, ItemCategoryFilter.GetFilter("NPR Global Dimension 1 Filter"));
        DepartmentItemCategory.SetFilter(Filter_Posting_Date, ItemCategoryFilter.GetFilter("NPR Date Filter"));

        DepartmentItemCategory.Open();

        while DepartmentItemCategory.Read() do begin
            TempDimensionValue.Reset();
            TempDimensionValue.SetFilter(Code, DepartmentItemCategory.Global_Dimension_1_Code);
            if TempDimensionValue.IsEmpty() then begin
                TempDimensionValue.Init();
                TempDimensionValue.Code := DepartmentItemCategory.Global_Dimension_1_Code;
                TempDimensionValue.Insert();
            end;
        end;

        FiltersText := ItemCategoryFilter.GetFilters();
    end;

    local procedure CalculateProfitPercentage(var ItemCategoryBuffer: Record "NPR Item Category Buffer")
    begin
        if not ItemCategoryBuffer.FindSet(true) then
            exit;

        // "Calc Field 2" -> SalesLCY
        // "Calc Field 3" -> ProfitLCY
        // "Calc Field 4" -> ProfitPerc
        repeat
            ItemCategoryBuffer."Calc Field 4" := ItemCategoryBuffer."Calc Field 3" / ItemCategoryBuffer."Calc Field 2";
            ItemCategoryBuffer.Modify();
        until ItemCategoryBuffer.Next() = 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        TempDimensionValue: Record "Dimension Value" temporary;
        NumberOfCategories: Integer;
        NumberOfLevels: Integer;
        SortByFieldNo: Integer;
        SortOrder: Option "Ascending","Descending";
        SortBy: Option "Sales (LCY)","Profit (LCY)","Profit %","Quantity";
        NotInItemCategoryLbl: Label 'Without category';
        TotalQuantity: Decimal;
        TotalSalesLCY: Decimal;
        TotalProfitLCY: Decimal;
        TotalProfitPercentage: Decimal;
        FiltersText: Text;
}