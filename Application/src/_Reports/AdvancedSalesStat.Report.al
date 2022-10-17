﻿report 6014490 "NPR Advanced Sales Stat."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Advanced Sales Statistics.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Advanced Sales Statistics';
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(0 ..));
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Title; Title)
            {
            }
            column(Dim1Filter; Dim1Filter)
            {
            }
            column(Dim2Filter; Dim2Filter)
            {
            }
            column(ItemCategoryFilter; ItemCategoryFilter)
            {
            }
            column(PeriodeFilter; PeriodeFilter)
            {
            }
            column(PeriodFilters; PeriodFilters)
            {
            }
            column(Periodestart; Periodestart)
            {
            }
            column(Periodeslut; Periodeslut)
            {
            }
            column(Number_Integer; Integer.Number)
            {
            }
            column(No_Buffer; TempBuffer."No.")
            {
            }
            column(Description_Buffer; TempBuffer.Description)
            {
            }
            column(Sales_Qty_Buffer; TempBuffer."Sales qty." * -1)
            {
            }
            column(Sales_Qty_LastYr_Buffer; TempBuffer."Sales qty. last year" * -1)
            {
            }
            column(Sales_LCY_Buffer; TempBuffer."Sales LCY")
            {
            }
            column(Sales_LCY_LastYr_Buffer; TempBuffer."Sales LCY last year")
            {
            }
            column(Profit_LCY_Buffer; TempBuffer."Profit LCY")
            {
            }
            column(Profit_LCY_LastYr_Buffer; TempBuffer."Profit LCY last year")
            {
            }
            column(Profit_Pct_Buffer; TempBuffer."Profit %")
            {
            }
            column(Profit_Pct_LastYr_Buffer; TempBuffer."Profit % last year")
            {
            }
            column(Totals_1; Totals[1] * -1)
            {
            }
            column(Totals_2; Totals[2] * -1)
            {
            }
            column(Totals_3; Totals[3])
            {
            }
            column(Totals_4; Totals[4])
            {
            }
            column(Totals_5; Totals[5])
            {
            }
            column(Totals_6; Totals[6])
            {
            }
            column(Totals_7; Totals[7])
            {
            }
            column(Totals_8; Totals[8])
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Integer.Number = 0 then
                    exit
                else begin

                end;
                Totals[1] += TempBuffer."Sales qty.";
                Totals[2] += TempBuffer."Sales qty. last year";
                Totals[3] += TempBuffer."Sales LCY";
                Totals[4] += TempBuffer."Sales LCY last year";
                Totals[5] += TempBuffer."Profit LCY";
                Totals[6] += TempBuffer."Profit LCY last year";
                if Totals[3] <> 0 then
                    Totals[7] := Totals[5] / Totals[3] * 100
                else
                    Totals[7] := 0;
                if Totals[4] <> 0 then
                    Totals[8] := Totals[6] / Totals[4] * 100
                else
                    Totals[8] := 0;
                if Integer.Number = TempBuffer.Count() then
                    CurrReport.Break();
                if Integer.Number > 0 then
                    TempBuffer.Next();
            end;

            trigger OnPostDataItem()
            begin
                TotalAmt[1] := Totals[1];
                TotalAmt[2] := Totals[2];
                TotalAmt[3] := Totals[3];
                TotalAmt[4] := Totals[4];
                TotalAmt[5] := Totals[5];
                TotalAmt[6] := Totals[6];
                TotalAmt[7] := Totals[7];
                TotalAmt[8] := Totals[8];
            end;

            trigger OnPreDataItem()
            var
                EmptyLinesEngErr: Label 'There is only empty lines on the report.';
                EmptyLinesDeErr: Label 'Der er kun tomme linjer på rapporten.';
            begin
                fillTable();

                // Rewind
                UpdateSortKey();
                if not TempBuffer.Find('-') then begin
                    if CurrReport.Language = 1030 then
                        Error(EmptyLinesDeErr)
                    else
                        Error(EmptyLinesEngErr);
                end;

                if Type = Type::Period then begin
                    PeriodFilters := StrSubstNo(Pct1Lbl, Periodestart);
                end else begin
                    PeriodFilters := StrSubstNo(Pct2Lbl, Periodestart, Periodeslut);
                end;
            end;
        }
        dataitem(Totalling; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            MaxIteration = 1;
            column(Number_Totalling; Totalling.Number)
            {
            }
            column(TotalAmt_1_Totalling; TotalAmt[1] * -1)
            {
            }
            column(TotalAmt_2_Totalling; TotalAmt[2] * -1)
            {
            }
            column(TotalAmt_3_Totalling; TotalAmt[3])
            {
            }
            column(TotalAmt_4_Totalling; TotalAmt[4])
            {
            }
            column(TotalAmt_5_Totalling; TotalAmt[5])
            {
            }
            column(TotalAmt_6_Totalling; TotalAmt[6])
            {
            }
            column(TotalAmt_7_Totalling; TotalAmt[7])
            {
            }
            column(TotalAmt_8_Totalling; TotalAmt[8])
            {
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
                field("Periode start"; Periodestart)
                {
                    Caption = 'Period Start';
                    ToolTip = 'Specifies the value of the Period Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Sort By"; SortBy)
                {
                    Caption = 'Sort By';
                    OptionCaption = 'No.,Description,Period Start,Sales qty.,Sales qty. last year,Sales LCY,Sales LCY last year,Profit LCY,Profit LCY last year,Profit %,Profit % last year';
                    ToolTip = 'Specifies the value of the Sort by field';
                    ApplicationArea = NPRRetail;
                }
                field("Lines field"; Lines)
                {
                    Caption = 'Lines';
                    ToolTip = 'Specifies the value of the Lines field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Filter"; Dim1Filter)
                {
                    CaptionClass = '1,1,1';
                    Caption = 'Global Dimension 1 Code';
                    ToolTip = 'Specifies Global Dimension 1 Filter';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Filter"; Dim2Filter)
                {
                    CaptionClass = '1,1,2';
                    Caption = 'Global Dimension 2 Code';
                    ToolTip = 'Specifies Global Dimension 2 Filter';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ApplicationArea = NPRRetail;
                }
                field("Item Category"; ItemCategoryFilter)
                {
                    Caption = 'Item Category';
                    ToolTip = 'Specifies the default Item Category';
                    TableRelation = "Item Category".Code;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Advanced Sales Statistics';
        Page_Caption = 'Page';
        GlobalDim1_Caption = 'Global Dimension 1 Code:';
        GlobalDim2_Caption = 'Global Dimension 2 Code:';
        ItemCategoryFilter_Caption = 'Item Category filter:';
        Period_Caption = 'Period:';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        SalesQty_Caption = 'Sales qty.';
        SalesQty_LastYr_Caption = 'Last year\Sales qty.';
        SalesLCY_Caption = 'Sales LCY';
        SalesLCY_LastYr_Caption = 'Last year\Sales LCY';
        ProfitLCY_Caption = 'Profit LCY';
        ProfitLCY_LastYr_Caption = 'Last year\Profit LCY';
        ProfitPct_Caption = 'Profit %';
        ProfitPct_LastYr_Caption = 'Last year\Profit %';
        CarriedOver_Caption = 'Carried over';
        CarriedThrough_Caption = 'Carried through';
        Total_Caption = 'Total';
        LastYear_Caption = 'Last Year';
    }

    trigger OnInitReport()
    begin
        Clear(Totals);
        Lines := 30;
    end;

    trigger OnPreReport()
    begin

        Firmaoplysninger.Get();
        Firmaoplysninger.CalcFields(Picture);
    end;

    var
        Firmaoplysninger: Record "Company Information";
        Customer: Record Customer;
        DateRecord: Record Date;
        Item: Record Item;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        TempBuffer: Record "NPR Advanced Sales Statistics" temporary;
        ItemCategory: Record "Item Category";
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
        ValueEntry: Record "Value Entry";
        Vendor: Record Vendor;
        "Record": RecordRef;
        Caption: FieldRef;
        EndRef: FieldRef;
        "Field": FieldRef;
        FilterField: FieldRef;
        StartRef: FieldRef;
        TypeField: FieldRef;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemCategoryFilter: Code[20];
        ProjektKodeSlut: Code[20];
        ProjektKodeStart: Code[20];
        Periodeslut: Date;
        Periodestart: Date;
        TotalAmt: array[8] of Decimal;
        Totals: array[8] of Decimal;
        d: Dialog;
        "Count": Integer;
        Lines: Integer;
        TitleCustomer: Label 'Customers';
        TitleItemCategory: Label 'Item Category';
        TitleItem: Label 'Items';
        TitlePeriod: Label 'Period';
        DialogText: Label 'Processing No. #1######## @2@@@@@@@@';
        TitleSalesperson: Label 'Salespersons';
        TitleVendor: Label 'Vendor';
        Day: Option Day,Week,Month,Quarter,Year;
        SortBy: Option "No.",Description,"Period Start","Sales qty.","Sales qty. last year","Sales LCY","Sales LCY last year","Profit LCY","Profit LCY last year","Profit %","Profit % last year";
        Type: Option Period,Salesperson,ItemCategory,Item,Customer,Vendor,Projectcode;
        Title: Text[30];
        CalcLastYear: Text[50];
        PeriodeFilter: Text[255];
        PeriodFilters: Text[255];
        Pct1Lbl: Label '%1..', locked = true;
        Pct2Lbl: Label '%1..%2', locked = true;

    internal procedure setFilter(xType: Option Period,Salesperson,ItemCategory,Item,Customer,Vendor,Projectcode; xDay: Option Day,Week,Month,Quarter,Year; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemCategory: Code[20]; LastYearCalc: Text[50]; hide: Boolean)
    begin
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemCategoryFilter := ItemCategory;
        CalcLastYear := LastYearCalc;
        Day := xDay;
        Type := xType;

        if Type = Type::Period then begin
            PeriodeFilter := StrSubstNo(Pct1Lbl, Periodestart);
        end else begin
            PeriodeFilter := StrSubstNo(Pct2Lbl, Periodestart, Periodeslut);
        end;
    end;

    internal procedure fillTable()
    var
        NoTypeErr: Label 'No Type selected';
    begin
        TempBuffer.DeleteAll();

        case Type of
            Type::Period:
                begin
                    Record.Open(DATABASE::Date);
                    // Datoen skal starte på Periodestart
                    FilterField := Record.Field(DateRecord.FieldNo("Period Start"));
                    FilterField.SetFilter(StrSubstNo(Pct1Lbl,
                                               Periodestart));
                    TypeField := Record.Field(DateRecord.FieldNo("Period Type"));
                    TypeField.SetRange(Day);

                    StartRef := Record.Field(DateRecord.FieldNo("Period Start"));
                    EndRef := Record.Field(DateRecord.FieldNo("Period End"));

                    Field := Record.Field(DateRecord.FieldNo("Period Start"));
                    Caption := Record.Field(DateRecord.FieldNo("Period Start"));
                    Title := TitlePeriod;
                end;

            Type::Item:
                begin
                    Record.Open(DATABASE::Item);
                    Field := Record.Field(Item.FieldNo("No."));
                    Caption := Record.Field(Item.FieldNo(Description));
                    Title := TitleItem;
                end;

            Type::ItemCategory:
                begin
                    Record.Open(DATABASE::"Item Category");
                    Field := Record.Field(ItemCategory.FieldNo(Code));
                    Caption := Record.Field(ItemCategory.FieldNo(Description));
                    Title := TitleItemCategory;
                end;

            Type::Salesperson:
                begin
                    Record.Open(DATABASE::"Salesperson/Purchaser");
                    Field := Record.Field("Salesperson/Purchaser".FieldNo(Code));
                    Caption := Record.Field("Salesperson/Purchaser".FieldNo(Name));
                    Title := TitleSalesperson
                end;

            Type::Customer:
                begin
                    Record.Open(DATABASE::Customer);
                    Field := Record.Field(Customer.FieldNo("No."));
                    Caption := Record.Field(Customer.FieldNo(Name));
                    Title := TitleCustomer;
                end;

            Type::Vendor:
                begin
                    Record.Open(DATABASE::Vendor);
                    Field := Record.Field(Vendor.FieldNo("No."));
                    Caption := Record.Field(Vendor.FieldNo(Name));
                    Title := TitleVendor;
                end;
            else begin
                Error(NoTypeErr);
            end;
        end;

        d.Open(DialogText);
        Count := 0;
        // Henter de data vi skal bruge
        if Type <> Type::Period then
            Lines := Record.Count() - 1;

        if Record.Find('-') then begin
            repeat
                Count += 1;
                d.Update(1, Format(Field.Value));
                d.Update(2, Round(Count / Lines * 10000, 1, '='));

                if Type = Type::Period then begin
                    Periodestart := StartRef.Value;
                    Periodeslut := EndRef.Value;
                end;
                if Type = Type::Projectcode then begin
                    ProjektKodeStart := StartRef.Value;
                    ProjektKodeSlut := EndRef.Value;
                end;

                // F¢rst beregner vi dette år
                SetValueEntryFilter(ValueEntry, false, Format(Field.Value));
                ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

                SetItemLedgerEntryFilter(POSEntrySalesLine, false, Format(Field.Value));
                POSEntrySalesLine.CalcSums(Quantity);

                TempBuffer.Init();
                if Type = Type::Period then begin
                    TempBuffer."Date 1" := Field.Value;
                    TempBuffer."No." := Format(Count);
                end else
                    TempBuffer."No." := Format(Field.Value);
                if not (Type = Type::Projectcode) then
                    TempBuffer.Description := Format(Caption.Value)
                else
                    TempBuffer.Description := StrSubstNo(Pct2Lbl, ProjektKodeStart, ProjektKodeSlut);
                TempBuffer."Sales qty." := POSEntrySalesLine.Quantity;
                TempBuffer."Sales LCY" := ValueEntry."Sales Amount (Actual)";
                TempBuffer."Profit LCY" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
                if TempBuffer."Sales LCY" <> 0 then
                    TempBuffer."Profit %" := TempBuffer."Profit LCY" / TempBuffer."Sales LCY" * 100
                else
                    TempBuffer."Profit %" := 0;

                // Dernæst sidste år
                SetValueEntryFilter(ValueEntry, true, Format(Field.Value));
                ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

                SetItemLedgerEntryFilter(POSEntrySalesLine, true, Format(Field.Value));
                POSEntrySalesLine.CalcSums(Quantity);

                TempBuffer."Sales qty. last year" := POSEntrySalesLine.Quantity;
                TempBuffer."Sales LCY last year" := ValueEntry."Sales Amount (Actual)";
                TempBuffer."Profit LCY last year" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
                if TempBuffer."Sales LCY last year" <> 0 then
                    TempBuffer."Profit % last year" := TempBuffer."Profit LCY last year" / TempBuffer."Sales LCY last year" * 100
                else
                    TempBuffer."Profit % last year" := 0;

                TempBuffer.Insert();
            until (Record.Next() = 0) or ((Type = Type::Period) and (Count >= Lines));
        end;
        d.Close();

    end;

    internal procedure SetItemLedgerEntryFilter(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; LastYear: Boolean; "Code": Code[20])
    begin

        case Type of
            Type::Item:
                begin
                    POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
                    POSEntrySalesLine.SetRange("No.", Code);
                end;
            Type::ItemCategory:
                POSEntrySalesLine.SetRange("Item Category Code", Code);
            Type::Salesperson:
                POSEntrySalesLine.SetRange("Salesperson Code", Code);
            Type::Customer:
                POSEntrySalesLine.SetRange("Document No.", Code);
            Type::Vendor:
                POSEntrySalesLine.SetRange("Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        POSEntrySalesLine.SetFilter("Shortcut Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            POSEntrySalesLine.SetFilter("Entry Date", '%1..%2', Periodestart, Periodeslut)
        else
            POSEntrySalesLine.SetFilter("Entry Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));

        if Type <> Type::ItemCategory then begin
            if ItemCategoryFilter <> '' then
                POSEntrySalesLine.SetRange("Item Category Code", ItemCategoryFilter)
            else
                POSEntrySalesLine.SetRange("Item Category Code");
        end;

        if Dim1Filter <> '' then
            POSEntrySalesLine.SetRange("Shortcut Dimension 1 Code", Dim1Filter)
        else
            POSEntrySalesLine.SetRange("Shortcut Dimension 1 Code");

        if not (Type = Type::Projectcode) then begin
            if Dim2Filter <> '' then
                POSEntrySalesLine.SetRange("Shortcut Dimension 2 Code", Dim2Filter)
            else
                POSEntrySalesLine.SetRange("Shortcut Dimension 2 Code");
        end;
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry"; LastYear: Boolean; "Code": Code[20])
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);

        case Type of
            Type::Item:
                ValueEntry.SetRange("Item No.", Code);
            //TODO:Temporary Aux Value Entry Reimplementation
            // Type::ItemCategory:
            //     ValueEntry.SetRange("NPR Item Category Code", Code);
            Type::Salesperson:
                ValueEntry.SetRange("Salespers./Purch. Code", Code);
            Type::Customer:
                ValueEntry.SetRange("Source No.", Code);
            //TODO:Temporary Aux Value Entry Reimplementation
            // Type::Vendor:
            //     ValueEntry.SetRange("NPR Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        ValueEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));

        //TODO:Temporary Aux Value Entry Reimplementation
        // if Type <> Type::ItemCategory then begin
        //     if ItemCategoryFilter <> '' then
        //         ValueEntry.SetRange("NPR Item Category Code", ItemCategoryFilter)
        //     else
        //         ValueEntry.SetRange("NPR Item Category Code");
        // end;

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if not (Type = Type::Projectcode) then begin
            if Dim2Filter <> '' then
                ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
            else
                ValueEntry.SetRange("Global Dimension 2 Code");
        end;
    end;

    internal procedure UpdateSortKey()
    begin
        // UpdateSortKey
        case SortBy of
            SortBy::Description:
                TempBuffer.SetCurrentKey(Description);
            SortBy::"Period Start":
                TempBuffer.SetCurrentKey("Period Start");
            SortBy::"Sales qty.":
                TempBuffer.SetCurrentKey("Sales qty.");
            SortBy::"Sales qty. last year":
                TempBuffer.SetCurrentKey("Sales qty. last year");
            SortBy::"Sales LCY":
                TempBuffer.SetCurrentKey("Sales LCY");
            SortBy::"Sales LCY last year":
                TempBuffer.SetCurrentKey("Sales LCY last year");
            SortBy::"Profit LCY":
                TempBuffer.SetCurrentKey("Profit LCY");
            SortBy::"Profit LCY last year":
                TempBuffer.SetCurrentKey("Profit LCY last year");
            SortBy::"Profit %":
                TempBuffer.SetCurrentKey("Profit %");
            SortBy::"Profit % last year":
                TempBuffer.SetCurrentKey("Profit % last year");
            else begin
                if Type = Type::Period then
                    TempBuffer.SetCurrentKey("Date 1")
                else
                    TempBuffer.SetCurrentKey("No.");
            end;
        end;
    end;
}

