report 6014405 "NPR Salesp./Item Cat Top 20"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Salesperson Item Category Top 20.rdlc';
    Caption = 'Salesperson/Item Category Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(POSEntry; "NPR POS Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Entry Date", "Salesperson Code";
            UseTemporary = true;
        }
        dataitem(SalespersonPurchaser; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);

            column(Code_SalespersonPurchaser; "Code") { }
            column(Name_SalespersonPurchaser; Name) { }
            column(Turnover_SalespersonPurchaser; Turnover) { }
            column(Profit_SalespersonPurchaser; ProfitTotal) { }
            column(ProfitPercentage_SalespersonPurchaser; ProfitPercentageTotal) { }
            column(CostExclVAT_SalespersonPurchaserBuffer; CostExclVATTotal) { }
            column(FiltersText; FiltersText) { }
            column(Name_CompanyInformation; CompanyInformation.Name) { }
            dataitem(ItemCategoryBuffer; "NPR Item Category Buffer")
            {
                DataItemLink = "Salesperson Code" = field(Code);
                DataItemTableView = sorting("Entry No.");

                column("Code"; "Code") { }
                column(CodeWithIndentation; "Code with Indentation") { }
                column(Description; Description) { }
                column(ParentCategory; "Parent Category") { }
                column(AmountExclVAT; "Calc Field 1") { }
                column(ProfitExclVAT; "Calc Field 2") { }
                column(ProfitPercentage; "Calc Field 3") { }
                column(CostExclVAT; "Calc Field 4") { }
                column(SalespersonCode; "Salesperson Code") { }
                column(Presentation_Order; "Presentation Order") { }
                column(OrderNo; "Order No.") { }
            }

            trigger OnAfterGetRecord()
            var
                TempItemCategoryBuffer2: Record "NPR Item Category Buffer" temporary;
                TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
                SalespersonItemCategory: Query "NPR Salesperson/Item Category";
                Ascending: Boolean;
                CalcFieldsDict: Dictionary of [Integer, Decimal];
                DetailFieldsDict: Dictionary of [Integer, Text[100]];
                CostExclVAT: Decimal;
                ProfitExclVAT: Decimal;
                ProfitPercentage: Decimal;
                Index: Integer;
            begin
                Turnover := 0;
                ProfitTotal := 0;
                ProfitPercentageTotal := 0;
                CostExclVATTotal := 0;

                TempSalespersonPurchaser.Reset();
                TempSalespersonPurchaser.SetFilter(Code, SalespersonPurchaser.Code);

                if not TempSalespersonPurchaser.FindFirst() then
                    CurrReport.Skip();

                SalespersonItemCategory.SetFilter(Salesperson_Code, SalespersonPurchaser.Code);
                SalespersonItemCategory.SetFilter(Entry_Date, POSEntry.GetFilter("Entry Date"));

                #region Insert Data from the Query to Item Category Buffer

                SalespersonItemCategory.Open();
                while SalespersonItemCategory.Read() do begin
                    ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

                    CostExclVAT := SalespersonItemCategory.Unit_Cost * SalespersonItemCategory.Quantity;
                    ProfitExclVAT := SalespersonItemCategory.Amount_Excl_VAT - CostExclVAT;
                    ProfitPercentage := ProfitExclVAT / SalespersonItemCategory.Amount_Excl_VAT;

                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), SalespersonItemCategory.Amount_Excl_VAT);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), ProfitExclVAT);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), ProfitPercentage);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 4"), CostExclVAT);

                    ItemCategoryMgt.InsertItemCategoryToBuffer(SalespersonItemCategory.Item_Category_Code, ItemCategoryBuffer, SalespersonPurchaser.Code, '', '', CalcFieldsDict, DetailFieldsDict);
                end;
                SalespersonItemCategory.Close();

                #endregion

                #region Insert Uncatagorized To Item Category Buffer

                ItemCategoryBuffer.Reset();

                SalespersonItemCategory.SetRange(Salesperson_Code, SalespersonPurchaser.Code);
                SalespersonItemCategory.SetFilter(Entry_Date, POSEntry.GetFilter("Entry Date"));
                SalespersonItemCategory.SetRange(Item_Category_Code, '');

                SalespersonItemCategory.Open();
                while SalespersonItemCategory.Read() do begin
                    ItemCategoryMgt.ClearCalcFieldsDictionary(CalcFieldsDict);

                    CostExclVAT := SalespersonItemCategory.Unit_Cost * SalespersonItemCategory.Quantity;
                    ProfitExclVAT := SalespersonItemCategory.Amount_Excl_VAT - CostExclVAT;
                    ProfitPercentage := ProfitExclVAT / SalespersonItemCategory.Amount_Excl_VAT;

                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 1"), SalespersonItemCategory.Amount_Excl_VAT);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 2"), ProfitExclVAT);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 3"), ProfitPercentage);
                    CalcFieldsDict.Add(ItemCategoryBuffer.FieldNo("Calc Field 4"), CostExclVAT);

                    ItemCategoryMgt.InsertUncatagorizedToItemCategoryBuffer('-', 'Without category', ItemCategoryBuffer, SalespersonPurchaser.Code, '', '', CalcFieldsDict, DetailFieldsDict);
                end;

                SalespersonItemCategory.Close();

                ItemCategoryMgt.AddItemCategoryParentsToBuffer(ItemCategoryBuffer);

                #endregion

                #region Delete unwanted Levels and Format Identation

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetFilter(Indentation, '>%1', NumberOfLevels - 1);
                ItemCategoryBuffer.DeleteAll();

                ItemCategoryMgt.FormatIndentationInItemCategories(ItemCategoryBuffer, 4);

                #endregion

                #region Get only Top Item Categorories 

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);
                ItemCategoryBuffer.SetRange(Indentation, 0);

                if ItemCategoryBuffer.Count() > NumberOfCategories then begin
                    Index := 0;
                    TempItemCategoryBuffer.DeleteAll();
                    TempItemCategoryBuffer2.DeleteAll();
                    ItemCategoryBuffer.Reset();
                    ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);

                    if ItemCategoryBuffer.FindSet() then
                        repeat
                            TempItemCategoryBuffer.Init();
                            TempItemCategoryBuffer := ItemCategoryBuffer;
                            TempItemCategoryBuffer.Insert();
                        until ItemCategoryBuffer.Next() = 0;

                    ItemCategoryBuffer.Reset();
                    ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);
                    ItemCategoryBuffer.SetRange(Indentation, 0);

                    if ItemCategoryBuffer.FindSet() then
                        repeat
                            TempItemCategoryBuffer2.Init();
                            TempItemCategoryBuffer2 := ItemCategoryBuffer;
                            TempItemCategoryBuffer2.Insert();
                        until ItemCategoryBuffer.Next() = 0;

                    case SortBy of
                        SortBy::"Amount Excl. VAT":
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 1");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 1", false);
                            end;
                        SortBy::Profit:
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 2");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 2", false);
                            end;
                        SortBy::"Profit %":
                            begin
                                TempItemCategoryBuffer2.SetCurrentKey("Calc Field 3");
                                TempItemCategoryBuffer2.SetAscending("Calc Field 3", false);
                            end;
                    end;

                    if TempItemCategoryBuffer2.FindSet() then
                        repeat
                            if Index > NumberOfCategories - 1 then
                                ItemCategoryMgt.DeleteItemCategoryBuffer(TempItemCategoryBuffer2.Code, SalespersonPurchaser.Code, '', '', ItemCategoryBuffer, TempItemCategoryBuffer);
                            Index += 1;
                        until TempItemCategoryBuffer2.Next() = 0;
                end;


                #endregion

                #region Sorting and updating Salesperson Totals

                if (SortOrder = SortOrder::Ascending) and (NumberOfCategories > 1) then
                    Ascending := true
                else
                    Ascending := false;

                case SortBy of
                    SortBy::"Amount Excl. VAT":
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 1");
                    SortBy::Profit:
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 2");
                    SortBy::"Profit %":
                        SortByFieldNo := ItemCategoryBuffer.FieldNo("Calc Field 3");
                end;

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);
                ItemCategoryMgt.SortItemCategoryBuffer(ItemCategoryBuffer, SortByFieldNo, Ascending);

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);
                ItemCategoryBuffer.SetRange(Indentation, 0);
                ItemCategoryBuffer.CalcSums("Calc Field 1", "Calc Field 2", "Calc Field 4");
                Turnover := ItemCategoryBuffer."Calc Field 1";
                ProfitTotal := ItemCategoryBuffer."Calc Field 2";
                CostExclVATTotal := ItemCategoryBuffer."Calc Field 4";
                if ItemCategoryBuffer."Calc Field 1" > 0 then
                    ProfitPercentageTotal := ItemCategoryBuffer."Calc Field 2" / ItemCategoryBuffer."Calc Field 1";
                #endregion

                #region Set Order No. On Item Category Buffer

                ItemCategoryBuffer.Reset();
                ItemCategoryBuffer.SetRange("Salesperson Code", SalespersonPurchaser.Code);
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
                        OptionCaption = 'Amount Excl. VAT,Profit,Profit %';
                        ToolTip = 'Specifies the value of the Sort By field.';
                    }
                    field("Sort Order"; SortOrder)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Sort Order';
                        OptionCaption = 'Ascending,Descending';
                        ToolTip = 'Specifies the order of sorting for item categories on print.';
                    }
                }
            }
        }
    }

    labels
    {
        ProfitLbl = 'Profit';
        ProfitPercentageLbl = 'Profit %';
        DescriptionLbl = 'Description';
        ItemCategoryCodeLbl = 'Item Category Code';
        AmountExclVATLbl = 'Amount Excl. VAT';
        CostExclVATLbl = 'Cost Excl. VAT';
        ReportCaptionLbl = 'Salesperson/Item Category Top';
        NotInItemCategoryLbl = 'Without category';
        FiltersLbl = 'Filters: ';
        TotalLbl = 'Total';
    }

    trigger OnInitReport()
    begin
        NumberOfLevels := 5;
        NumberOfCategories := 20;
    end;

    trigger OnPreReport()
    var
        SalespersonItemCategory: Query "NPR Salesperson/Item Category";

    begin
        if not CheckIfFilterIsSet() then
            CurrReport.Quit();

        CompanyInformation.Get();

        TempSalespersonPurchaser.Reset();

        SalespersonItemCategory.SetFilter(Salesperson_Code, POSEntry.GetFilter("Salesperson Code"));
        SalespersonItemCategory.SetFilter(Entry_Date, POSEntry.GetFilter("Entry Date"));

        SalespersonItemCategory.Open();
        while SalespersonItemCategory.Read() do begin
            TempSalespersonPurchaser.Reset();
            TempSalespersonPurchaser.SetFilter(Code, SalespersonItemCategory.Salesperson_Code);
            if not TempSalespersonPurchaser.FindFirst() then begin
                if SalespersonPurchaser2.Get(SalespersonItemCategory.Salesperson_Code) then begin
                    TempSalespersonPurchaser.Init();
                    TempSalespersonPurchaser.Code := SalespersonPurchaser2.Code;
                    TempSalespersonPurchaser.Name := SalespersonPurchaser2.Name;
                    TempSalespersonPurchaser.Insert();
                end;
            end;
        end;
        SalespersonItemCategory.Close();

        FiltersText := POSEntry.GetFilters();
    end;

    local procedure CheckIfFilterIsSet(): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CheckFilterQst: Label 'This report might take longer to process if you do not enter Salesperson Code filter. Are you sure you want to proceed?';
    begin
        if POSEntry.GetFilter("Salesperson Code") = '' then
            if not ConfirmManagement.GetResponseOrDefault(CheckFilterQst, true) then
                exit;
        exit(true);
    end;

    var
        CompanyInformation: Record "Company Information";
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        CostExclVATTotal: Decimal;
        ProfitPercentageTotal: Decimal;
        ProfitTotal: Decimal;
        Turnover: Decimal;
        NumberOfCategories: Integer;
        NumberOfLevels: Integer;
        SortByFieldNo: Integer;
        SortBy: Option "Amount Excl. VAT","Profit","Profit %";
        SortOrder: Option "Ascending","Descending";
        FiltersText: Text;
}