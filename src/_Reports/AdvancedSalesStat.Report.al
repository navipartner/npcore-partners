report 6014490 "NPR Advanced Sales Stat."
{
    // NPR70.00.00.00/LS/280613 CASE 186853 : Convert Report to Nav 2013
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.55/BHR/20200728  CASE 361515 remove Key reference not used in AL
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Advanced Sales Statistics.rdlc';

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
            column(ItemGroupFilter; ItemGroupFilter)
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
                //+NPR70.00.00.00
                /*
                // CALCSUMS
                IF Integer.Number = 1 THEN
                  EXIT;
                */
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

                //-NPR70.00.00.00
                if Integer.Number = Buffer.Count then
                    CurrReport.Break;
                if Integer.Number > 0 then
                    Buffer.Next;

                /*
                IF Integer.Number > Buffer.COUNT THEN
                  CurrReport.BREAK;
                IF Integer.Number > 0 THEN
                  Buffer.NEXT;
                //+NPR70.00.00.00
                 */

            end;

            trigger OnPostDataItem()
            begin
                //-NPR70.00.00.00
                TotalAmt[1] := Totals[1];
                TotalAmt[2] := Totals[2];
                TotalAmt[3] := Totals[3];
                TotalAmt[4] := Totals[4];
                TotalAmt[5] := Totals[5];
                TotalAmt[6] := Totals[6];
                TotalAmt[7] := Totals[7];
                TotalAmt[8] := Totals[8];
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                fillTable;

                // Rewind
                UpdateSortKey;
                if not Buffer.Find('-') then begin
                    if CurrReport.Language = 1030 then
                        Error('Der er kun tomme linjer på rapporten.')
                    else
                        Error('There is only empty lines on the report.');
                end;

                //-NPR70.00.00.00
                if Type = Type::Period then begin
                    PeriodFilters := StrSubstNo('%1..', Periodestart);
                end else begin
                    PeriodFilters := StrSubstNo('%1..%2', Periodestart, Periodeslut);
                end;
                //+NPR70.00.00.00
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
                    ApplicationArea=All;
                }
                field(SortBy; SortBy)
                {
                    Caption = 'Sort by';
                    ApplicationArea=All;
                }
                field(Lines; Lines)
                {
                    Caption = 'Lines';
                    ApplicationArea=All;
                }
            }
        }

        actions
        {
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
        //-NPR5.39
        // Objekt.SETRANGE(ID, 6014490);
        // Objekt.SETRANGE(Type, 3);
        // Objekt.FIND('-');
        //+NPR5.39

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
        DateRecord: Record Date;
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
        "Item Group": Record "NPR Item Group";
        Item: Record Item;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Buffer: Record "NPR Advanced Sales Statistics" temporary;
        hideEmptyLines: Boolean;
        Type: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode;
        Day: Option Day,Week,Month,Quarter,Year;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemGroupFilter: Code[20];
        Periodestart: Date;
        Periodeslut: Date;
        CalcLastYear: Text[50];
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        "Record": RecordRef;
        "Field": FieldRef;
        FilterField: FieldRef;
        TypeField: FieldRef;
        Caption: FieldRef;
        Title: Text[30];
        Totals: array[8] of Decimal;
        d: Dialog;
        "Count": Integer;
        Lines: Integer;
        StartRef: FieldRef;
        EndRef: FieldRef;
        SortBy: Option "No.",Description,"Period Start","Sales qty.","Sales qty. last year","Sales LCY","Sales LCY last year","Profit LCY","Profit LCY last year","Profit %","Profit % last year";
        PeriodeFilter: Text[255];
        ProjektKodeStart: Code[20];
        ProjektKodeSlut: Code[20];
        Grey: Boolean;
        Firmaoplysninger: Record "Company Information";
        TitleItem: Label 'Items';
        TitleItemGroup: Label 'Item Groups';
        TitleCustomer: Label 'Customers';
        TitleVendor: Label 'Vendor';
        TitlePeriod: Label 'Period';
        TitleSalesperson: Label 'Salespersons';
        DialogText: Label 'Processing No. #1######## @2@@@@@@@@';
        TotalAmt: array[8] of Decimal;
        PeriodFilters: Text[255];

    procedure setFilter(xType: Option Period,Salesperson,ItemGroup,Item,Customer,Vendor,Projectcode; xDay: Option Day,Week,Month,Quarter,Year; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50]; hide: Boolean)
    begin
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemGroupFilter := ItemGroup;
        CalcLastYear := LastYearCalc;
        Day := xDay;
        Type := xType;
        hideEmptyLines := hide;

        if Type = Type::Period then begin
            PeriodeFilter := StrSubstNo('%1..', Periodestart);
            ///RequestOptionsForm.LinjerInput.VISIBLE := TRUE;
            ///RequestOptionsForm.LinjerCaption.VISIBLE := TRUE;
        end else begin
            PeriodeFilter := StrSubstNo('%1..%2', Periodestart, Periodeslut);
            ///RequestOptionsForm.LinjerInput.VISIBLE := FALSE;
            ///RequestOptionsForm.LinjerCaption.VISIBLE := FALSE;
        end;
    end;

    procedure fillTable()
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
                    Record.Open(DATABASE::"NPR Item Group");
                    Field := Record.Field("Item Group".FieldNo("No."));
                    Caption := Record.Field("Item Group".FieldNo(Description));
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
                    Error('No Type selected');
                end;
        end;

        d.Open(DialogText);
        Count := 0;
        // Henter de data vi skal bruge
        if Type <> Type::Period then begin
            //Lines := Record.COUNT;
            Lines := Record.Count - 1;
        end;

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

                SetItemLedgerEntryFilter(ItemLedgerEntry, false, Format(Field.Value));
                ItemLedgerEntry.CalcSums(Quantity);

                Buffer.Init;
                if Type = Type::Period then begin
                    Buffer."Date 1" := Field.Value;
                    Buffer."No." := Format(Count);
                end else
                    Buffer."No." := Format(Field.Value);
                if not (Type = Type::Projectcode) then
                    Buffer.Description := Format(Caption.Value)
                else
                    Buffer.Description := StrSubstNo('%1..%2', ProjektKodeStart, ProjektKodeSlut);
                Buffer."Sales qty." := ItemLedgerEntry.Quantity;
                Buffer."Sales LCY" := ValueEntry."Sales Amount (Actual)";
                Buffer."Profit LCY" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
                if Buffer."Sales LCY" <> 0 then
                    Buffer."Profit %" := Buffer."Profit LCY" / Buffer."Sales LCY" * 100
                else
                    Buffer."Profit %" := 0;


                // Dernæst sidste år
                SetValueEntryFilter(ValueEntry, true, Format(Field.Value));
                ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

                SetItemLedgerEntryFilter(ItemLedgerEntry, true, Format(Field.Value));
                ItemLedgerEntry.CalcSums(Quantity);

                Buffer."Sales qty. last year" := ItemLedgerEntry.Quantity;
                Buffer."Sales LCY last year" := ValueEntry."Sales Amount (Actual)";
                Buffer."Profit LCY last year" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
                if Buffer."Sales LCY last year" <> 0 then
                    Buffer."Profit % last year" := Buffer."Profit LCY last year" / Buffer."Sales LCY last year" * 100
                else
                    Buffer."Profit % last year" := 0;

                //IF  Count >26 THEN MESSAGE('BufferNo.=%1,COunt=%2,Lines=%3, Record.COUNT=%4,date=%5',Count,Buffer."No.",Lines,Record.COUNT,Buffer.Date1);
                Buffer.Insert;
            //IF  Count >28 THEN MESSAGE('BufferNo.=%1,COunt=%2,Lines=%3, Record.COUNT=%4,date=%5',Count,Buffer."No.",Lines,Record.COUNT,Buffer.Date1);
            //Count+=1;  //NPK
            until (Record.Next = 0) or ((Type = Type::Period) and (Count >= Lines));
        end;
        d.Close;

        /*//
        IF hideEmptyLines THEN
          Buffer.SETFILTER("Sales qty.",'<>0');
           */

    end;

    procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry"; LastYear: Boolean; "Code": Code[20])
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);

        case Type of
            Type::Item:
                ItemLedgerEntry.SetRange("Item No.", Code);
            Type::ItemGroup:
                ItemLedgerEntry.SetRange("NPR Item Group No.", Code);
            Type::Salesperson:
                ItemLedgerEntry.SetRange("NPR Salesperson Code", Code);
            Type::Customer:
                ItemLedgerEntry.SetRange("Source No.", Code);
            Type::Vendor:
                ItemLedgerEntry.SetRange("NPR Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        ItemLedgerEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            //-NPR70.00.00.00
            //ItemLedgerEntry.SETFILTER( "Posting Date", '%1..%2', CALCDATE(CalcLastYear,Periodestart), CALCDATE(CalcLastYear,Periodeslut) );
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));
        //+NPR70.00.00.00

        if Type <> Type::ItemGroup then begin
            if ItemGroupFilter <> '' then
                ItemLedgerEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
            else
                ItemLedgerEntry.SetRange("NPR Item Group No.");
        end;

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if not (Type = Type::Projectcode) then begin
            if Dim2Filter <> '' then
                ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
            else
                ItemLedgerEntry.SetRange("Global Dimension 2 Code");
        end;
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry"; LastYear: Boolean; "Code": Code[20])
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);

        case Type of
            Type::Item:
                ValueEntry.SetRange("Item No.", Code);
            Type::ItemGroup:
                ValueEntry.SetRange("NPR Item Group No.", Code);
            Type::Salesperson:
                ValueEntry.SetRange("Salespers./Purch. Code", Code);
            Type::Customer:
                ValueEntry.SetRange("Source No.", Code);
            Type::Vendor:
                ValueEntry.SetRange("NPR Vendor No.", Code);
            Type::Projectcode:
                begin
                    if (ProjektKodeStart <> '') and (ProjektKodeStart <> '') then
                        ValueEntry.SetFilter("Global Dimension 2 Code", '%1..%2', ProjektKodeStart, ProjektKodeSlut);
                end;
        end;

        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            //-NPR70.00.00.00
            //ValueEntry.SETFILTER( "Posting Date", '%1..%2',CALCDATE(CalcLastYear,Periodestart), CALCDATE(CalcLastYear,Periodeslut) );
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<- 1Y>', Periodestart), CalcDate('<- 1Y>', Periodeslut));
        //+NPR70.00.00.00

        if Type <> Type::ItemGroup then begin
            if ItemGroupFilter <> '' then
                ValueEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
            else
                ValueEntry.SetRange("NPR Item Group No.");
        end;

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

