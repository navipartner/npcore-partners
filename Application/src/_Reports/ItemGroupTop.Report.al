report 6014420 "NPR Item Group Top"
{
    RDLCLayout = './src/_Reports/layouts/Item Group Top.rdlc';
    Caption = 'Item Group Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = SORTING(Code, "Global Dimension No.") WHERE("Global Dimension No." = CONST(1));
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            dataitem("Item Category"; "Item Category")
            {
                RequestFilterFields = "Code", "NPR Main Category Code", "NPR Date Filter", "NPR Salesperson/Purch. Filter", "NPR Vendor Filter", "NPR Global Dimension 1 Filter";

                trigger OnAfterGetRecord()
                begin
                    IleSalesQty := 0;
                    IleSalesLCY := 0;
                    IleCostAmtActual := 0;

                    AuxItemLedgerEntry.Reset();
                    AuxItemLedgerEntry.SetRange("Item Category Code", "Code");
                    AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                    AuxItemLedgerEntry.SetFilter("Vendor No.", "Item Category".GetFilter("NPR Vendor Filter"));
                    AuxItemLedgerEntry.SetFilter("Posting Date", "Item Category".GetFilter("NPR Date Filter"));
                    AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", "Item Category".GetFilter("NPR Global Dimension 1 Filter"));
                    AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", "Item Category".GetFilter("NPR Global Dimension 2 Filter"));

                    AuxItemLedgerEntry.CalcSums(Quantity);

                    IleSalesQty := -AuxItemLedgerEntry.Quantity;

                    AuxValueEntry.Reset();
                    AuxValueEntry.SetRange("Item Category Code", "Code");
                    AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                    AuxValueEntry.SetFilter("Vendor No.", "Item Category".GetFilter("NPR Vendor Filter"));
                    AuxValueEntry.SetFilter("Posting Date", "Item Category".GetFilter("NPR Date Filter"));
                    AuxValueEntry.SetFilter("Global Dimension 1 Code", "Item Category".GetFilter("NPR Global Dimension 1 Filter"));
                    AuxValueEntry.SetFilter("Global Dimension 2 Code", "Item Category".GetFilter("NPR Global Dimension 2 Filter"));
                    AuxValueEntry.SetFilter("Salespers./Purch. Code", "Item Category".GetFilter("NPR Salesperson/Purch. Filter"));

                    AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");

                    IleSalesLCY := AuxValueEntry."Sales Amount (Actual)";
                    IleCostAmtActual := -AuxValueEntry."Cost Amount (Actual)";

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

                    TempNPRBufferSort.Insert();
                end;

                trigger OnPreDataItem()
                begin
                    TempNPRBufferSort.DeleteAll();
                    TempNPRBufferSort.SetCurrentKey("Decimal 1", "Short Code 1");

                    if SortOrder = SortOrder::st then
                        TempNPRBufferSort.Ascending(false);
                    "Item Category".SetFilter("Item Category"."NPR Global Dimension 1 Filter", "Dimension Value".Code);
                    "Item Category".CopyFilter("NPR Date Filter", Item."Date Filter");
                    Item.SetFilter("Global Dimension 1 Filter", "Dimension Value".Code);
                    Item.SetRange("Item Category Code", '');
                    if Item.Find('-') then
                        repeat
                            Item.CalcFields("Sales (Qty.)", "Sales (LCY)");
                            QtyOutside += Item."Sales (Qty.)";
                            SalesOutside += Item."Sales (LCY)";
                        until Item.Next() = 0;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(Number_Integer; CountDimValue)
                {
                }
                column(Code_DimensionValue; "Dimension Value".Code)
                {
                }
                column(Name_DimensionValue; "Dimension Value".Name)
                {
                }
                column(No_ItemGroup; "Item Category"."Code")
                {
                }
                column(Description_ItemGroup; "Item Category".Description)
                {
                }
                column(SalesQty_ItemGroup; IleSalesQty)
                {
                }
                column(SaleLCY_ItemGroup; IleSalesLCY)
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
                column(Sorting; SortOrder)
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
                    end
                    else
                        if TempNPRBufferSort.Next() = 0 then
                            CurrReport.Break();

                    if i > ShowQty then
                        CurrReport.Break();

                    i += 1;

                    "Item Category".SetFilter("Item Category"."NPR Global Dimension 1 Filter", "Dimension Value".Code);
                    if "Item Category".Get(TempNPRBufferSort.Template) then begin
                        IleSalesQty := 0;
                        IleSalesLCY := 0;
                        IleCostAmtActual := 0;

                        AuxItemLedgerEntry.Reset();
                        AuxItemLedgerEntry.SetRange("Item Category Code", "Item Category"."Code");
                        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                        AuxItemLedgerEntry.SetFilter("Vendor No.", "Item Category".GetFilter("NPR Vendor Filter"));
                        AuxItemLedgerEntry.SetFilter("Posting Date", "Item Category".GetFilter("NPR Date Filter"));
                        AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", "Item Category".GetFilter("NPR Global Dimension 1 Filter"));
                        AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", "Item Category".GetFilter("NPR Global Dimension 2 Filter"));

                        AuxItemLedgerEntry.CalcSums(Quantity);

                        IleSalesQty += -AuxItemLedgerEntry.Quantity;

                        AuxValueEntry.Reset();
                        AuxValueEntry.SetRange("Item Category Code", "Item Category"."Code");
                        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                        AuxValueEntry.SetFilter("Vendor No.", "Item Category".GetFilter("NPR Vendor Filter"));
                        AuxValueEntry.SetFilter("Posting Date", "Item Category".GetFilter("NPR Date Filter"));
                        AuxValueEntry.SetFilter("Global Dimension 1 Code", "Item Category".GetFilter("NPR Global Dimension 1 Filter"));
                        AuxValueEntry.SetFilter("Global Dimension 2 Code", "Item Category".GetFilter("NPR Global Dimension 2 Filter"));
                        AuxValueEntry.SetFilter("Salespers./Purch. Code", "Item Category".GetFilter("NPR Salesperson/Purch. Filter"));

                        AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");

                        IleSalesLCY := AuxValueEntry."Sales Amount (Actual)";
                        IleCostAmtActual := -AuxValueEntry."Cost Amount (Actual)";
                    end;

                    db := IleSalesLCY - IleCostAmtActual;
                    if IleSalesLCY <> 0 then
                        dg := (db / IleSalesLCY) * 100
                    else
                        dg := 0;

                    j := IncStr(j);

                    if "Dimension Value".Code <> PreviousDimValueCode then begin
                        Clear(CountDimValue);
                        PreviousDimValueCode := "Dimension Value".Code;
                    end;
                    CountDimValue += 1;
                end;

                trigger OnPreDataItem()
                begin
                    i := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(QtyOutside);
                Clear(SalesOutside);

                FiltersDimValue := FiltersDimValue + ' ' + "Dimension Value".Code + ' ';

                if Dim1Filter <> '' then begin
                    if "Dimension Value".Code <> Dim1Filter then
                        CurrReport.Skip();
                end;
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
        Report_Caption = 'Item Group Top';
        Sequence_Caption = 'Sequence';
        ItemGroup_Caption = 'Item Group';
        Description_Caption = 'Description';
        Quantity_Caption = 'Quantity';
        Sale_LCY_Caption = 'Sale (LCY)';
        Profit_LCY_Caption = 'Profit (LCY)';
        Profit_Pct_Caption = 'Profit %';
        Ikke_Caption = 'Not in item group';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        SortType := SortType::ant;
        ShowQty := 20;
        SortOrder := SortOrder::st;
    end;

    trigger OnPreReport()
    begin
        j := '2';

        Clear(TotalQty);
        Clear(TotalSale);
        Clear(TotalProfit);

        Dim1Filter := "Item Category".GetFilter("NPR Global Dimension 1 Filter");
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        TempNPRBufferSort: Record "NPR TEMP Buffer" temporary;
        AuxValueEntry: Record "NPR Aux. Value Entry";
        PreviousDimValueCode: Code[20];
        db: Decimal;
        dg: Decimal;
        IleCostAmtActual: Decimal;
        IleSalesLCY: Decimal;
        IleSalesQty: Decimal;
        QtyOutside: Decimal;
        SalesOutside: Decimal;
        TotalProfit: Decimal;
        TotalQty: Decimal;
        TotalSale: Decimal;
        CountDimValue: Integer;
        i: Integer;
        ShowQty: Integer;
        SortType: Option ant,sal,db,dg;
        SortOrder: Option st,mi;
        FiltersDimValue: Text;
        Dim1Filter: Text;
        j: Text[30];
}

