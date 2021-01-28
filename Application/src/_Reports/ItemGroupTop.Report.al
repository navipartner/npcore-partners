report 6014420 "NPR Item Group Top"
{
    RDLCLayout = './src/_Reports/layouts/Item Group Top.rdlc';
    Caption = 'Item Group Top';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = SORTING(Code, "Global Dimension No.") WHERE("Global Dimension No." = CONST(1));
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            dataitem("Item Group"; "NPR Item Group")
            {
                RequestFilterFields = "No.", "Belongs In Main Item Group", "Date Filter", "Salesperson Filter", "Vendor Filter", "Global Dimension 1 Filter";

                trigger OnAfterGetRecord()
                begin
                    IleSalesQty := 0;
                    IleSalesLCY := 0;
                    IleCostAmtActual := 0;
                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetRange("NPR Item Group No.", "No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SetFilter("NPR Vendor No.", "Item Group".GetFilter("Vendor Filter"));
                    ItemLedgerEntry.SetFilter("Posting Date", "Item Group".GetFilter("Date Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 1 Code", "Item Group".GetFilter("Global Dimension 1 Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 2 Code", "Item Group".GetFilter("Global Dimension 2 Filter"));
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            IleSalesQty += -ItemLedgerEntry.Quantity;
                        until ItemLedgerEntry.Next() = 0;

                    ValueEntry.Reset();
                    ValueEntry.SetRange("NPR Item Group No.", "No.");
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                    ValueEntry.SetFilter("NPR Vendor No.", "Item Group".GetFilter("Vendor Filter"));
                    ValueEntry.SetFilter("Posting Date", "Item Group".GetFilter("Date Filter"));
                    ValueEntry.SetFilter("Global Dimension 1 Code", "Item Group".GetFilter("Global Dimension 1 Filter"));
                    ValueEntry.SetFilter("Global Dimension 2 Code", "Item Group".GetFilter("Global Dimension 2 Filter"));
                    ValueEntry.SetFilter("Salespers./Purch. Code", "Item Group".GetFilter("Salesperson Filter"));
                    if ValueEntry.FindSet() then
                        repeat
                            IleSalesLCY += ValueEntry."Sales Amount (Actual)";
                            IleCostAmtActual += -ValueEntry."Cost Amount (Actual)";
                        until ValueEntry.Next() = 0;
                    db := IleSalesLCY - IleCostAmtActual;

                    if IleSalesLCY <> 0 then
                        dg := (db / IleSalesLCY) * 100
                    else
                        dg := 0;
                    TempNPRBufferSort.Init();
                    TempNPRBufferSort.Template := "No.";
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

                    if Sorting = Sorting::st then
                        TempNPRBufferSort.Ascending(false);
                    "Item Group".SetFilter("Item Group"."Global Dimension 1 Filter", "Dimension Value".Code);
                    "Item Group".CopyFilter("Date Filter", Item."Date Filter");
                    Item.SetFilter("Global Dimension 1 Filter", "Dimension Value".Code);
                    Item.SetRange("NPR Item Group", '');
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
                column(No_ItemGroup; "Item Group"."No.")
                {
                }
                column(Description_ItemGroup; "Item Group".Description)
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
                column(Sorting; Sorting)
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

                    "Item Group".SetFilter("Item Group"."Global Dimension 1 Filter", "Dimension Value".Code);
                    if "Item Group".Get(TempNPRBufferSort.Template) then begin
                        IleSalesQty := 0;
                        IleSalesLCY := 0;
                        IleCostAmtActual := 0;

                        ItemLedgerEntry.Reset();
                        ItemLedgerEntry.SetRange("NPR Item Group No.", "Item Group"."No.");
                        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                        ItemLedgerEntry.SetFilter("NPR Vendor No.", "Item Group".GetFilter("Vendor Filter"));
                        ItemLedgerEntry.SetFilter("Posting Date", "Item Group".GetFilter("Date Filter"));
                        ItemLedgerEntry.SetFilter("Global Dimension 1 Code", "Item Group".GetFilter("Global Dimension 1 Filter"));
                        ItemLedgerEntry.SetFilter("Global Dimension 2 Code", "Item Group".GetFilter("Global Dimension 2 Filter"));
                        if ItemLedgerEntry.FindSet() then
                            repeat
                                IleSalesQty += -ItemLedgerEntry.Quantity;
                            until ItemLedgerEntry.Next() = 0;

                        ValueEntry.Reset();
                        ValueEntry.SetRange("NPR Item Group No.", "Item Group"."No.");
                        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                        ValueEntry.SetFilter("NPR Vendor No.", "Item Group".GetFilter("Vendor Filter"));
                        ValueEntry.SetFilter("Posting Date", "Item Group".GetFilter("Date Filter"));
                        ValueEntry.SetFilter("Global Dimension 1 Code", "Item Group".GetFilter("Global Dimension 1 Filter"));
                        ValueEntry.SetFilter("Global Dimension 2 Code", "Item Group".GetFilter("Global Dimension 2 Filter"));
                        ValueEntry.SetFilter("Salespers./Purch. Code", "Item Group".GetFilter("Salesperson Filter"));
                        if ValueEntry.FindSet() then
                            repeat
                                IleSalesLCY += ValueEntry."Sales Amount (Actual)";
                                IleCostAmtActual += -ValueEntry."Cost Amount (Actual)";
                            until ValueEntry.Next() = 0;
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

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(SortType; SortType)
                    {
                        Caption = 'Show Type';
                        OptionCaption = 'Quantity,Sale(LCY),Contribution Margin,Contribution Ratio';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Type field';
                    }
                    field(ShowQty; ShowQty)
                    {
                        Caption = 'Show Quantity';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Quantity field';
                    }
                    field("Sorting"; Sorting)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sort By field';
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
        Sorting := Sorting::st;
    end;

    trigger OnPreReport()
    begin
        j := '2';

        Clear(TotalQty);
        Clear(TotalSale);
        Clear(TotalProfit);

        Dim1Filter := "Item Group".GetFilter("Global Dimension 1 Filter");
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempNPRBufferSort: Record "NPR TEMP Buffer" temporary;
        ValueEntry: Record "Value Entry";
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
        window: Dialog;
        CountDimValue: Integer;
        i: Integer;
        ShowQty: Integer;
        Text10600000: Label 'ant';
        Text10600004: Label 'db';
        Text10600002: Label 'Itemgroups Sorted by #1##########';
        Text10600003: Label 'sal';
        Text10600001: Label 'st';
        SortType: Option ant,sal,db,dg;
        Sorting: Option st,mi;
        FiltersDimValue: Text;
        Dim1Filter: Text[30];
        j: Text[30];
}

