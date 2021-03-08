report 6014490 "NPR Advanced Sales Stat."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Advanced Sales Statistics.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Advanced Sales Statistics';
    UseSystemPrinter = true;

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
            column(ItemGroupFilter; ItemCategoryFilter)
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
            column(No_Buffer; Buffer."No.")
            {
            }
            column(Description_Buffer; Buffer.Description)
            {
            }
            column(Sales_Qty_Buffer; Buffer."Sales qty." * -1)
            {
            }
            column(Sales_Qty_LastYr_Buffer; Buffer."Sales qty. last year" * -1)
            {
            }
            column(Sales_LCY_Buffer; Buffer."Sales LCY")
            {
            }
            column(Sales_LCY_LastYr_Buffer; Buffer."Sales LCY last year")
            {
            }
            column(Profit_LCY_Buffer; Buffer."Profit LCY")
            {
            }
            column(Profit_LCY_LastYr_Buffer; Buffer."Profit LCY last year")
            {
            }
            column(Profit_Pct_Buffer; Buffer."Profit %")
            {
            }
            column(Profit_Pct_LastYr_Buffer; Buffer."Profit % last year")
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
                    if (Number / 2) = Round((Number / 2), 1) then
                        Grey := false
                    else
                        Grey := true;
                end;
                Totals[1] += Buffer."Sales qty.";
                Totals[2] += Buffer."Sales qty. last year";
                Totals[3] += Buffer."Sales LCY";
                Totals[4] += Buffer."Sales LCY last year";
                Totals[5] += Buffer."Profit LCY";
                Totals[6] += Buffer."Profit LCY last year";
                if Totals[3] <> 0 then
                    Totals[7] := Totals[5] / Totals[3] * 100
                else
                    Totals[7] := 0;
                if Totals[4] <> 0 then
                    Totals[8] := Totals[6] / Totals[4] * 100
                else
                    Totals[8] := 0;
                if Integer.Number = Buffer.Count then
                    CurrReport.Break();
                if Integer.Number > 0 then
                    Buffer.Next();
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
                UpdateSortKey;
                if not Buffer.Find('-') then begin
                    if CurrReport.Language = 1030 then
                        Error(EmptyLinesDeErr)
                    else
                        Error(EmptyLinesEngErr);
                end;

                if Type = Type::Period then begin
                    PeriodFilters := StrSubstNo('%1..', Periodestart);
                end else begin
                    PeriodFilters := StrSubstNo('%1..%2', Periodestart, Periodeslut);
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

        layout
        {
            area(content)
            {
                field(Periodestart; Periodestart)
                {
                    Caption = 'Period Start';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Start field';
                }
                field(SortBy; SortBy)
                {
                    Caption = 'Sort by';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort by field';
                }
                field(Lines; Lines)
                {
                    Caption = 'Lines';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lines field';
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Advanced Sales Statistics';
        Page_Caption = 'Page';
        GlobalDim1_Caption = 'Global dim. 1:';
        GlobalDim2_Caption = 'Global dim. 2:';
        ItemGroupFilter_Caption = 'Item Group filter:';
        Period_Caption = 'Period:';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        SalesQty_Caption = 'Sales qty.';
        SalesQty_LastYr_Caption = 'Last year\Sales qty.';
        SalesLCY_Caption = 'Sales LCY';
        SalesLCY_LastYr_Caption = 'Last year\Sales LCY';
        AvanceLCY_Caption = 'Avance LCY';
        AvanceLCY_LastYr_Caption = 'Last year\Avance LCY';
        AvancePct_Caption = 'Avance %';
        AvancePct_LastYr_Caption = 'Last year\Avance %';
        CarriedOver_Caption = 'Carried over';
        CarriedThrough_Caption = 'Carried through';
        Total_Caption = 'Total';
        LastYear_Caption = 'Last Year';
    }

    trigger OnInitReport()
    begin
        Clear(Totals);
        hideEmptyLines := true;
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
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        Buffer: Record "NPR Advanced Sales Statistics" temporary;
        ItemCategory: Record "Item Category";
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
        AuxValueEntry: Record "NPR Aux. Value Entry";
        Vendor: Record Vendor;
        "Record": RecordRef;
        Caption: FieldRef;
        EndRef: FieldRef;
        "Field": FieldRef;
        FilterField: FieldRef;
        StartRef: FieldRef;
        TypeField: FieldRef;
        Grey: Boolean;
        hideEmptyLines: Boolean;
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
        TitleItemGroup: Label 'Item Groups';
        TitleItem: Label 'Items';
        TitlePeriod: Label 'Period';
        DialogText: Label 'Processing No. #1######## @2@@@@@@@@';
        TitleSalesperson: Label 'Salespersons';
        TitleVendor: Label 'Vendor';
        Day: Option Day,Week,Month,Quarter,Year;
        SortBy: Option "No.",Description,"Period Start","Sales qty.","Sales qty. last year","Sales LCY","Sales LCY last year","Profit LCY","Profit LCY last year","Profit %","Profit % last year";
        Type: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode;
        Title: Text[30];
        CalcLastYear: Text[50];
        PeriodeFilter: Text[255];
        PeriodFilters: Text[255];

    procedure setFilter(xType: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode; xDay: Option Day,Week,Month,Quarter,Year; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50]; hide: Boolean)
    begin
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemCategoryFilter := ItemGroup;
        CalcLastYear := LastYearCalc;
        Day := xDay;
        Type := xType;
        hideEmptyLines := hide;

        if Type = Type::Period then begin
            PeriodeFilter := StrSubstNo('%1..', Periodestart);
        end else begin
            PeriodeFilter := StrSubstNo('%1..%2', Periodestart, Periodeslut);
        end;
    end;

    procedure fillTable()
    var
        NoTypeErr: Label 'No Type selected';
    begin
        Buffer.DeleteAll;

        case Type of
            Type::Period:
                begin
                    Record.Open(DATABASE::Date);
                    // Datoen skal starte på Periodestart
                    FilterField := Record.Field(DateRecord.FieldNo("Period Start"));
                    FilterField.SetFilter(StrSubstNo('%1..',
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

            Type::ItemGroup:
                begin
                    Record.Open(DATABASE::"Item Category");
                    Field := Record.Field(ItemCategory.FieldNo(Code));
                    Caption := Record.Field(ItemCategory.FieldNo(Description));
                    Title := TitleItemGroup;
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
            Lines := Record.Count - 1;

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
                SetValueEntryFilter(AuxValueEntry, false, Format(Field.Value));
                AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

                SetItemLedgerEntryFilter(AuxItemLedgerEntry, false, Format(Field.Value));
                AuxItemLedgerEntry.CalcSums(Quantity);

                Buffer.Init();
                if Type = Type::Period then begin
                    Buffer."Date 1" := Field.Value;
                    Buffer."No." := Format(Count);
                end else
                    Buffer."No." := Format(Field.Value);
                if not (Type = Type::Projectcode) then
                    Buffer.Description := Format(Caption.Value)
                else
                    Buffer.Description := StrSubstNo('%1..%2', ProjektKodeStart, ProjektKodeSlut);
                Buffer."Sales qty." := AuxItemLedgerEntry.Quantity;
                Buffer."Sales LCY" := AuxValueEntry."Sales Amount (Actual)";
                Buffer."Profit LCY" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
                if Buffer."Sales LCY" <> 0 then
                    Buffer."Profit %" := Buffer."Profit LCY" / Buffer."Sales LCY" * 100
                else
                    Buffer."Profit %" := 0;

                // Dernæst sidste år
                SetValueEntryFilter(AuxValueEntry, true, Format(Field.Value));
                AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

                SetItemLedgerEntryFilter(AuxItemLedgerEntry, true, Format(Field.Value));
                AuxItemLedgerEntry.CalcSums(Quantity);

                Buffer."Sales qty. last year" := AuxItemLedgerEntry.Quantity;
                Buffer."Sales LCY last year" := AuxValueEntry."Sales Amount (Actual)";
                Buffer."Profit LCY last year" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
                if Buffer."Sales LCY last year" <> 0 then
                    Buffer."Profit % last year" := Buffer."Profit LCY last year" / Buffer."Sales LCY last year" * 100
                else
                    Buffer."Profit % last year" := 0;

                Buffer.Insert();
            until (Record.Next() = 0) or ((Type = Type::Period) and (Count >= Lines));
        end;
        d.Close();

    end;

    procedure SetItemLedgerEntryFilter(var AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry"; LastYear: Boolean; "Code": Code[20])
    begin
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);

        case Type of
            Type::Item:
                AuxItemLedgerEntry.SetRange("Item No.", Code);
            Type::ItemGroup:
                AuxItemLedgerEntry.SetRange("Item Category Code", Code);
            Type::Salesperson:
                AuxItemLedgerEntry.SetRange("Salespers./Purch. Code", Code);
            Type::Customer:
                AuxItemLedgerEntry.SetRange("Source No.", Code);
            Type::Vendor:
                AuxItemLedgerEntry.SetRange("Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));

        if Type <> Type::ItemGroup then begin
            if ItemCategoryFilter <> '' then
                AuxItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
            else
                AuxItemLedgerEntry.SetRange("Item Category Code");
        end;

        if Dim1Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if not (Type = Type::Projectcode) then begin
            if Dim2Filter <> '' then
                AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
            else
                AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");
        end;
    end;

    procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry"; LastYear: Boolean; "Code": Code[20])
    begin
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);

        case Type of
            Type::Item:
                AuxValueEntry.SetRange("Item No.", Code);
            Type::ItemGroup:
                AuxValueEntry.SetRange("Item Category Code", Code);
            Type::Salesperson:
                AuxValueEntry.SetRange("Salespers./Purch. Code", Code);
            Type::Customer:
                AuxValueEntry.SetRange("Source No.", Code);
            Type::Vendor:
                AuxValueEntry.SetRange("Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        AuxValueEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));

        if Type <> Type::ItemGroup then begin
            if ItemCategoryFilter <> '' then
                AuxValueEntry.SetRange("Item Category Code", ItemCategoryFilter)
            else
                AuxValueEntry.SetRange("Item Category Code");
        end;

        if Dim1Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if not (Type = Type::Projectcode) then begin
            if Dim2Filter <> '' then
                AuxValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
            else
                AuxValueEntry.SetRange("Global Dimension 2 Code");
        end;
    end;

    procedure UpdateSortKey()
    begin
        // UpdateSortKey
        case SortBy of
            SortBy::Description:
                Buffer.SetCurrentKey(Description);
            SortBy::"Period Start":
                Buffer.SetCurrentKey("Period Start");
            SortBy::"Sales qty.":
                Buffer.SetCurrentKey("Sales qty.");
            SortBy::"Sales qty. last year":
                Buffer.SetCurrentKey("Sales qty. last year");
            SortBy::"Sales LCY":
                Buffer.SetCurrentKey("Sales LCY");
            SortBy::"Sales LCY last year":
                Buffer.SetCurrentKey("Sales LCY last year");
            SortBy::"Profit LCY":
                Buffer.SetCurrentKey("Profit LCY");
            SortBy::"Profit LCY last year":
                Buffer.SetCurrentKey("Profit LCY last year");
            SortBy::"Profit %":
                Buffer.SetCurrentKey("Profit %");
            SortBy::"Profit % last year":
                Buffer.SetCurrentKey("Profit % last year");
            else begin
                    if Type = Type::Period then
                        Buffer.SetCurrentKey("Date 1")
                    else
                        Buffer.SetCurrentKey("No.");
                end;
        end;
    end;
}

