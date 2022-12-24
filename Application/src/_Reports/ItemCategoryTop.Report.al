report 6014420 "NPR Item Category Top"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    RDLCLayout = './src/_Reports/layouts/Item Category Top.rdlc';
    Caption = 'Item Category Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategoryFilter; "Item Category")
        {
            RequestFilterFields = "Code", "NPR Main Category Code", "NPR Date Filter", "NPR Salesperson/Purch. Filter", "NPR Global Dimension 1 Filter", "NPR Vendor Filter";
            UseTemporary = true;
        }
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = sorting(Code, "Global Dimension No.") where("Global Dimension No." = const(1));
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            dataitem("Item Category"; "Item Category")
            {
                DataItemTableView = sorting(Code);

                trigger OnAfterGetRecord()
                begin
                    IleSalesQty := 0;
                    IleSalesLCY := 0;
                    IleCostAmtActual := 0;
                    CalculateValues("Item Category"."Code", "Dimension Value".Code, IleSalesQty, IleSalesLCY, IleCostAmtActual);

                    db := IleSalesLCY - IleCostAmtActual;

                    if IleSalesLCY <> 0 then
                        dg := (db / IleSalesLCY) * 100
                    else
                        dg := 0;
                    TempNPRBufferSort.Init();
                    TempNPRBufferSort.Template := "Code";
                    TempNPRBufferSort."Line No." := 0;
                    case SortType of
                        SortType::ant:
                            begin
                                TempNPRBufferSort."Decimal 1" := IleSalesQty;
                            end;
                        SortType::sal:
                            begin
                                TempNPRBufferSort."Decimal 1" := IleSalesLCY;
                            end;
                        SortType::db:
                            begin
                                TempNPRBufferSort."Decimal 1" := db;
                            end;
                        SortType::dg:
                            begin
                                TempNPRBufferSort."Decimal 1" := dg;
                            end;
                    end;
                    TempNPRBufferSort."Decimal 2" := IleSalesQty;
                    TempNPRBufferSort."Decimal 3" := IleSalesLCY;
                    TempNPRBufferSort."Decimal 4" := IleCostAmtActual;
                    TempNPRBufferSort.Insert();
                end;

                trigger OnPreDataItem()
                var
                    CostOutside: Decimal;
                begin
                    TempNPRBufferSort.DeleteAll();
                    TempNPRBufferSort.SetCurrentKey("Decimal 1", "Short Code 1");

                    if SortOrder = SortOrder::st then
                        TempNPRBufferSort.Ascending(false);

                    QtyOutside := 0;
                    SalesOutside := 0;
                    CalculateValues('', "Dimension Value".Code, QtyOutside, SalesOutside, CostOutside);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(Number_Integer; "Integer".Number)
                {
                }
                column(Code_DimensionValue; "Dimension Value".Code)
                {
                }
                column(Name_DimensionValue; "Dimension Value".Name)
                {
                }
                column(No_ItemCategory; "Item Category"."Code")
                {
                }
                column(Description_ItemCategory; "Item Category".Description)
                {
                }
                column(SalesQty_ItemCategory; IleSalesQty)
                {
                }
                column(SaleLCY_ItemCategory; IleSalesLCY)
                {
                }
                column(db; db)
                {
                }
                column(dg; dg)
                {
                }
                column(QtyOutside; QtyOutside)
                {
                }
                column(SalesOutside; SalesOutside)
                {
                }
                column(COMPANYNAME; CompanyName)
                {
                }
                column("Sorting"; SortOrder)
                {
                }
                column(SortType; SortType)
                {
                }
                column(decsort; TempNPRBufferSort."Decimal 1")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not TempNPRBufferSort.Find('-') then
                            CurrReport.Break();
                    end else
                        if TempNPRBufferSort.Next() = 0 then
                            CurrReport.Break();

                    if Number > ShowQty then
                        CurrReport.Break();

                    "Item Category".Get(TempNPRBufferSort.Template);
                    IleSalesQty := TempNPRBufferSort."Decimal 2";
                    IleSalesLCY := TempNPRBufferSort."Decimal 3";
                    IleCostAmtActual := TempNPRBufferSort."Decimal 4";

                    db := IleSalesLCY - IleCostAmtActual;
                    if IleSalesLCY <> 0 then
                        dg := (db / IleSalesLCY) * 100
                    else
                        dg := 0;
                end;

            }
            trigger OnPreDataItem()
            begin
                ItemCategoryFilter.CopyFilter("NPR Global Dimension 1 Filter", "Dimension Value".Code);
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(QtyOutside);
                Clear(SalesOutside);
            end;
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
                    field("Sort Type"; SortType)
                    {
                        Caption = 'Show Type';
                        OptionCaption = 'Quantity,Sale(LCY),Contribution Margin,Contribution Ratio';

                        ToolTip = 'Specifies the value of the Show Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Qty"; ShowQty)
                    {
                        Caption = 'Show Quantity';

                        ToolTip = 'Specifies the value of the Show Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sorting"; SortOrder)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';

                        ToolTip = 'Specifies the value of the Sort By field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Item Category Top';
        Sequence_Caption = 'Sequence';
        ItemCategory_Caption = 'Item Category';
        Description_Caption = 'Description';
        Quantity_Caption = 'Quantity';
        Sale_LCY_Caption = 'Sale (LCY)';
        Profit_LCY_Caption = 'Profit (LCY)';
        Profit_Pct_Caption = 'Profit %';
        NotInItemCategory_Caption = 'Not in Item Category';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        SortType := SortType::ant;
        ShowQty := 20;
        SortOrder := SortOrder::st;
    end;


    local procedure CalculateValues(ItemCategoryCode: Code[20]; GlobalDimension1Code: Code[20]; var Quantity: Decimal; var SalesAmount: Decimal; var CostAmount: Decimal)
    var
        SalesStatisticsByPerson: Query "NPR Sales Statistics By Person";
        ValueEntryWithVendor: Query "NPR Value Entry With Vendor";
    begin
        Quantity := 0;
        SalesAmount := 0;
        CostAmount := 0;
        SalesStatisticsByPerson.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        SalesStatisticsByPerson.SetRange(Filter_Item_Category_Code, ItemCategoryCode);
        SalesStatisticsByPerson.SetRange(Filter_Global_Dimension_1_Code, GlobalDimension1Code);
        SalesStatisticsByPerson.SetFilter(Filter_Vendor_No_, ItemCategoryFilter.GetFilter("NPR Vendor Filter"));
        SalesStatisticsByPerson.SetFilter(Filter_Posting_Date, ItemCategoryFilter.GetFilter("NPR Date Filter"));
        SalesStatisticsByPerson.SetFilter(Filter_Global_Dimension_2_Code, ItemCategoryFilter.GetFilter("NPR Global Dimension 2 Filter"));
        SalesStatisticsByPerson.SetFilter(Filter_SalesPers_Purch_Code, ItemCategoryFilter.GetFilter("NPR Salesperson/Purch. Filter"));
        SalesStatisticsByPerson.Open();
        while SalesStatisticsByPerson.Read() do
            Quantity += -SalesStatisticsByPerson.Quantity;

        ValueEntryWithVendor.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntryWithVendor.SetRange(Filter_Item_Category_Code, ItemCategoryCode);
        ValueEntryWithVendor.SetRange(Filter_Dim_1_Code, GlobalDimension1Code);
        ValueEntryWithVendor.SetFilter(Filter_Vendor_No, ItemCategoryFilter.GetFilter("NPR Vendor Filter"));
        ValueEntryWithVendor.SetFilter(Filter_DateTime, ItemCategoryFilter.GetFilter("NPR Date Filter"));
        ValueEntryWithVendor.SetFilter(Filter_Dim_2_Code, ItemCategoryFilter.GetFilter("NPR Global Dimension 2 Filter"));
        ValueEntryWithVendor.SetFilter(Filter_Salespers_Purch_Code, ItemCategoryFilter.GetFilter("NPR Salesperson/Purch. Filter"));
        ValueEntryWithVendor.Open();
        while ValueEntryWithVendor.Read() do begin
            SalesAmount += ValueEntryWithVendor.Sum_Sales_Amount_Actual;
            CostAmount += -ValueEntryWithVendor.Sum_Cost_Amount_Actual;
        end;

    end;

    var
        CompanyInformation: Record "Company Information";
        TempNPRBufferSort: Record "NPR TEMP Buffer" temporary;
        db: Decimal;
        dg: Decimal;
        IleCostAmtActual: Decimal;
        IleSalesLCY: Decimal;
        IleSalesQty: Decimal;
        QtyOutside: Decimal;
        SalesOutside: Decimal;
        // TotalProfit: Decimal;
        ShowQty: Integer;
        SortType: Option ant,sal,db,dg;
        SortOrder: Option st,mi;
}

