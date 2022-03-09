report 6014418 "NPR Sale Time Report POS"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/SaleTimeReportPOS.rdlc';

    Caption = 'Sale Time Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Suite;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("POS Entry"; "NPR POS Entry")
        {

            RequestFilterFields = "Entry Date";
            MaxIteration = 1;
            column(PageCaption; Page_Caption)
            {
            }
            column(ReportCaption; Report_Caption)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(FirmaoplysningerPicture; CompanyInfo.Picture)
            {
            }
            column(SalesPerson_Header; "POS Entry"."Salesperson Code")
            {
            }
            column(DateFilter; Text10600008 + DateFilter)
            {
            }
            column(WeekDay; WeekDay)
            {
            }
            column(Filters_AuditRoll; "POS Entry".GetFilters)
            {
            }
            column(SalespersonFilters_AuditRoll; "POS Entry".GetFilter("Salesperson Code"))
            {
            }
            column(TextTime; TextTime)
            {
            }
            column(TextItemExpedition; TextItemExpedition)
            {
            }
            column(TextExpedition; TextExpedition)
            {
            }
            column(TextFrom; TextFrom)
            {
            }
            column(TextTo; TextTo)
            {
            }
            column(TextQty; TextQty)
            {
            }
            column(TextAvgLines; TextAvgLines)
            {
            }
            column(TextSaleExp; TextSaleExp)
            {
            }
            column(TextAmount; TextSalesAmt)
            {
            }
            column(TextReturn; TextReturn)
            {
            }
            column(TextNetSales; TextNetSales)
            {
            }
            column(TextDiscount; TextDiscount)
            {
            }
            column(TextDebit; TextDebit)
            {
            }
            column(TextDb; TextDb)
            {
            }
            column(TextDg; TextDg)
            {
            }
            column(TextCancelled; TextCancelled)
            {
            }
            column(TextOther; TextOther)
            {
            }
            column(EndText; Text10600010)
            {
            }
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(> 0));
            MaxIteration = 13;
            column(Number_Integer; Integer.Number)
            {
            }
            column(TidNumber; Format(TimeArray[Number]))
            {
            }
            column(TidNumberPlus1; Format(TimeArray[Number + 1]))
            {
            }
            column(Values_Number_1; Values[Number] [1])
            {
            }
            column(Values_Number_2; Values[Number] [2])
            {
            }
            column(Values_Number_3; Values[Number] [3])
            {
            }
            column(Values_Number_4; Values[Number] [4])
            {
            }
            column(Values_Number_5; Values[Number] [5])
            {
            }
            column(Values_Number_6; Values[Number] [6])
            {
            }
            column(Values_Number_7; Values[Number] [7])
            {
            }
            column(Values_Number_8; Values[Number] [8])
            {
            }
            column(Values_Number_9; Values[Number] [9])
            {
            }
            column(Values_Number_10; Values[Number] [10])
            {
            }
            column(Values_Number_11; Values[Number] [11])
            {
            }
            column(Values_Number_12; Values[Number] [12])
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number > Interval + 1 then
                    CurrReport.Break();

                if Values[Number] [1] <> 0 then
                    Values[Number] [2] := Values[Number] [2] / Values[Number] [1];

                if Values[Number] [3] <> 0 then
                    Values[Number] [10] := Round((Values[Number] [9] / Values[Number] [3]) * 100, 0.01);

                if Values[Number] [1] <> 0 then
                    Values[Number] [3] := Round((Values[Number] [3] / Values[Number] [1]), 0.01)
                else
                    Values[Number] [3] := 0;

                if Number = 13 then begin
                    //Divider_14_3 := Values[14] [3]; //Divider_14_3_Comment
                    //Divider_14_1 := Values[14] [1]; //Divider_14_1_Comment
                end;

            end;

            trigger OnPreDataItem()
            begin
                CalcValue();
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
                group(Control6150614)
                {
                    ShowCaption = false;
                    group(TimeFilter)
                    {
                        Caption = 'Time Filter';
                        field(TimeArray_1; TimeArray[1])
                        {
                            Caption = '1';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 1 field.';
                        }
                        field(TimeArray_2; TimeArray[2])
                        {
                            Caption = '2';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 2 field.';
                        }
                        field(TimeArray_3; TimeArray[3])
                        {
                            Caption = '3';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 3 field.';
                        }
                        field(TimeArray_4; TimeArray[4])
                        {
                            Caption = '4';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 4 field.';
                        }
                        field(TimeArray_5; TimeArray[5])
                        {
                            Caption = '5';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 5 field.';
                        }
                        field(TimeArray_6; TimeArray[6])
                        {
                            Caption = '6';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 6 field.';
                        }
                        field(TimeArray_7; TimeArray[7])
                        {
                            Caption = '7';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 7 field.';
                        }
                        field(TimeArray_8; TimeArray[8])
                        {
                            Caption = '8';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 8 field.';
                        }
                        field(TimeArray_9; TimeArray[9])
                        {
                            Caption = '9';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 9 field.';
                        }
                        field(TimeArray_10; TimeArray[10])
                        {
                            Caption = '10';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 10 field.';
                        }
                        field(TimeArray_11; TimeArray[11])
                        {
                            Caption = '11';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 11 field.';
                        }
                        field(TimeArray_12; TimeArray[12])
                        {
                            Caption = '12';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 12 field.';
                        }
                        field(TimeArray_13; TimeArray[13])
                        {
                            Caption = '13';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 13 field.';
                        }
                        field(TimeArray_14; TimeArray[14])
                        {
                            Caption = '14';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the 14 field.';
                        }
                    }
                    group(Weekdays)
                    {
                        Caption = 'Weekdays';
                        field(DayArray_1; DayArray[1])
                        {
                            Caption = 'Monday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Monday field.';
                        }
                        field(DayArray_2; DayArray[2])
                        {
                            Caption = 'Tuesday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Tuesday field.';
                        }
                        field(DayArray_3; DayArray[3])
                        {
                            Caption = 'Wednesday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Wednesday field.';
                        }
                        field(DayArray_4; DayArray[4])
                        {
                            Caption = 'Thursday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Thursday field.';
                        }
                        field(DayArray_5; DayArray[5])
                        {
                            Caption = 'Friday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Friday field.';
                        }
                        field(DayArray_6; DayArray[6])
                        {
                            Caption = 'Saturday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Saturday field.';
                        }
                        field(DayArray_7; DayArray[7])
                        {
                            Caption = 'Sunday';
                            ApplicationArea = Suite;
                            ToolTip = 'Specifies the value of the Sunday field.';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if "POS Entry"."Entry Date" = 0D then
                "POS Entry"."Entry Date" := Today;
        end;
    }

    labels
    {
        Margin_Caption = 'Margin on Total Sales';
    }

    trigger OnInitReport()
    var
        i: Integer;
    begin
        j_global := '2';
        TimeArray[1] := 000000T;
        TimeArray[2] := 080000T;
        TimeArray[3] := 090000T;
        TimeArray[4] := 100000T;
        TimeArray[5] := 110000T;
        TimeArray[6] := 120000T;
        TimeArray[7] := 130000T;
        TimeArray[8] := 140000T;
        TimeArray[9] := 150000T;
        TimeArray[10] := 160000T;
        TimeArray[11] := 170000T;
        TimeArray[12] := 180000T;
        TimeArray[13] := 190000T;
        TimeArray[ArrayLen(TimeArray)] := 235959.099T;

        for i := 1 to ArrayLen(DayArray) do
            DayArray[i] := true;

        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    trigger OnPreReport()
    var
        I: Integer;
        J: Integer;
    begin
        J := 1;
        for I := 2 to ArrayLen(TimeArray) do
            if TimeArray[I] <> 0T then begin
                J := J + 1;
                TimeArray[J] := TimeArray[I];
                if TimeArray[J] < TimeArray[J - 1] then
                    Error(Text10600000, J, J - 1);
            end;
        Interval := J - 1;

        for I := 1 to ArrayLen(DayArray) do begin
            if not DayArray[I] then
                DayFilter := true
            else
                case I of
                    1:
                        WeekDay += Text10600001;
                    2:
                        WeekDay += Text10600002;
                    3:
                        WeekDay += Text10600003;
                    4:
                        WeekDay += Text10600004;
                    5:
                        WeekDay += Text10600005;
                    6:
                        WeekDay += Text10600006;
                    7:
                        WeekDay += Text10600007;
                end;
        end;

        DateFilter := "POS Entry".GetFilter("Entry Date");
        if DateFilter = '' then
            DateFilter := Format(Today);
    end;

    var
        CompanyInfo: Record "Company Information";
        PosEntry1: Record "NPR POS Entry";
        PosEntry2: Record "NPR POS Entry";
        TimeArray: array[15] of Time;
        DayArray: array[7] of Boolean;
        Date: Record Date;
        DayFilter: Boolean;
        ItemAmt: Decimal;
        Lines: Decimal;
        DiscountAmt: Decimal;
        OtherAmt: Decimal;
        InterruptedAmt: Decimal;
        Interval: Integer;
        DateFilter: Text[50];
        WeekDay: Text[100];
        j_global: Text[30];
        SalesReturnAmt: Decimal;
        NetSalesAmt: Decimal;
        ItemSalesAmt: Decimal;
        db: Decimal;
        NetSalesExcVAT: Decimal;
        CostAmt: Decimal;
        DebitExcVat: Decimal;
        DebitCostAmt: Decimal;
        Values: array[14, 12] of Decimal;
        Text10600000: Label 'The Time in File %1 is less than %2';
        Text10600001: Label 'Monday,';
        Text10600002: Label 'Tuesday,';
        Text10600003: Label 'Wednesday,';
        Text10600004: Label 'Thursday,';
        Text10600005: Label 'Friday,';
        Text10600006: Label 'Saturday,';
        Text10600007: Label 'Sunday';
        Text10600008: Label 'Period Overview ';
        Text10600010: Label 'Note : All figures are exclusive of VAT';
        Report_Caption: Label 'Sale Time Report';
        Page_Caption: Label 'Page ';
        TextTime: Label 'Time';
        TextItemExpedition: Label 'Item Sales';
        TextExpedition: Label 'No. of Sales';
        TextFrom: Label 'From';
        TextTo: Label 'To';
        TextAvgLines: Label 'Average Lines';
        TextSaleExp: Label 'Avg Basket Value';
        TextReturn: Label 'Return Amt';
        TextNetSales: Label 'Net Sales';
        TextDiscount: Label 'Discount Amt';
        TextDebit: Label 'Debit Sales Amt';
        TextDb: Label 'Margin %';
        TextDg: Label 'Dg';
        TextCancelled: Label 'Cancelled';
        TextOther: Label 'Other';
        TextSalesAmt: Label 'Sales Amt';
        POSSalesline: Record "NPR POS Entry Sales Line";
        NoofSales: Integer;
        Noofdebtsales: Integer;
        TextQty: Label 'Quantity';


    procedure CalcValue()
    var
        MinDato: Date;
        MaxDato: Date;
        FilterArray: array[2] of Date;
    begin
        PosEntry1.CopyFilters("POS Entry");
        if PosEntry1.GetFilter("Entry Date") = '' then
            PosEntry1.SetRange("Entry Date", Today);


        MinDato := PosEntry1.GetRangeMin("Entry Date");
        MaxDato := PosEntry1.GetRangeMax("Entry Date");

        if not DayFilter then begin
            FilterArray[1] := MinDato;
            FilterArray[2] := MaxDato;
            Calculate(FilterArray);
        end else begin
            for MinDato := MinDato to MaxDato do begin
                if Date.Get(Date."Period Type"::Date, MinDato) then
                    if DayArray[Date."Period No."] then begin

                        if MinDato = MaxDato then begin
                            if FilterArray[1] = 0D then begin
                                FilterArray[1] := MinDato;
                                FilterArray[2] := MinDato;
                                Calculate(FilterArray);
                            end else begin
                                FilterArray[2] := MinDato;
                                Calculate(FilterArray);
                            end;
                        end else begin
                            if FilterArray[1] = 0D then begin
                                FilterArray[1] := MinDato;
                                FilterArray[2] := MinDato;
                            end else begin
                                FilterArray[2] := MinDato;
                            end;
                        end;
                    end else begin

                        if FilterArray[1] <> 0D then begin
                            Calculate(FilterArray);
                            FilterArray[1] := 0D;
                            FilterArray[2] := 0D;
                        end;
                    end;
            end;
        end;
    end;


    procedure Calculate(FilterArray: array[2] of Date)
    var
        I: Integer;
    begin
        PosEntry1.CopyFilters("POS Entry");
        PosEntry1.SetFilter("Entry Date", '%1..%2', FilterArray[1], FilterArray[2]);

        for I := 1 to Interval do begin
            NoofSales := 0;
            Noofdebtsales := 0;
            CostAmt := 0;
            Lines := 0;
            DiscountAmt := 0;
            DebitExcVat := 0;
            OtherAmt := 0;
            NetSalesAmt := 0;
            SalesReturnAmt := 0;
            db := 0;
            InterruptedAmt := 0;
            NetSalesExcVAT := 0;
            DebitCostAmt := 0;

            PosEntry1.SetFilter("Ending Time", '>=%1&<%2', TimeArray[I], TimeArray[I + 1]);

            if PosEntry1.FindSet() then begin
                repeat
                    NetSalesAmt += PosEntry1."Amount Excl. Tax";
                    NetSalesExcVAT += PosEntry1."Amount Excl. Tax";

                    POSSalesline.Reset();
                    POSSalesline.SetRange(POSSalesline."POS Entry No.", PosEntry1."Entry No.");
                    POSSalesline.SetRange(Type, POSSalesline.Type::Item);
                    POSSalesline.CalcSums("Unit Cost (LCY)", Quantity, "Line Dsc. Amt. Excl. VAT (LCY)");
                    CostAmt += POSSalesline."Unit Cost (LCY)";
                    Lines += POSSalesline.Quantity;
                    DiscountAmt += POSSalesline."Line Discount Amount Incl. VAT";

                    POSSalesline.Reset();
                    POSSalesline.SetRange(POSSalesline."POS Entry No.", PosEntry1."Entry No.");
                    POSSalesline.SetRange(Type, POSSalesline.Type::"G/L Account");
                    POSSalesline.CalcSums("Unit Cost (LCY)", Quantity, "Line Dsc. Amt. Excl. VAT (LCY)");

                    CostAmt += POSSalesline."Unit Cost (LCY)";
                    Lines += POSSalesline.Quantity;
                until PosEntry1.Next() = 0;
            end;

            if PosEntry1.FindSet() then begin
                repeat
                    POSSalesline.Reset();
                    POSSalesline.SetRange("POS Entry No.", PosEntry1."Entry No.");
                    if POSSalesline.FindSet() then begin
                        repeat
                            if POSSalesline."Amount Excl. VAT (LCY)" < 0 then
                                SalesReturnAmt += POSSalesline."Amount Excl. VAT (LCY)";
                        until POSSalesline.Next() = 0;
                    end;
                until PosEntry1.Next() = 0;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.SetRange("Entry Type", PosEntry2."Entry Type"::"Direct Sale");
            if PosEntry2.FindSet() then begin
                Noofdebtsales := PosEntry2.Count;
                repeat
                    POSSalesline.Reset();
                    POSSalesline.SetRange("POS Entry No.", PosEntry1."Entry No.");
                    if POSSalesline.FindSet() then begin
                        repeat
                            DebitExcVat += POSSalesline."Amount Excl. VAT";
                        until POSSalesline.Next() = 0;
                    end;
                until PosEntry2.Next() = 0;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.SetRange("Entry Type", PosEntry2."Entry Type"::"Credit Sale");
            if PosEntry2.FindSet() then begin
                NoofSales := PosEntry2.Count;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.Setrange("Entry Type", PosEntry2."Entry Type"::Other);
            if PosEntry2.FindSet() then begin
                OtherAmt := PosEntry2.Count;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.Setrange("Entry Type", PosEntry2."Entry Type"::Comment);
            if PosEntry2.FindSet() then begin
                OtherAmt := PosEntry2.Count;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.Setrange("Entry Type", PosEntry2."Entry Type"::Balancing);
            if PosEntry2.FindSet() then begin
                OtherAmt := PosEntry2.Count;
            end;

            PosEntry2.Reset();
            PosEntry2.CopyFilters(PosEntry1);
            PosEntry2.SetRange("Entry Type", PosEntry2."Entry Type"::"Cancelled Sale");
            if PosEntry2.FindSet() then begin
                InterruptedAmt := PosEntry2.Count;
            end;

            db := (NetSalesExcVAT) - (CostAmt + DebitCostAmt);
            ItemAmt := NoofSales + Noofdebtsales;

            Values[I] [1] += ItemAmt;
            Values[I] [2] += Lines;
            Values[I] [3] += NetSalesExcVAT;
            Values[I] [4] += NetSalesAmt;
            Values[I] [5] += SalesReturnAmt;
            Values[I] [6] += NetSalesAmt + ABS(SalesReturnAmt);
            Values[I] [7] += DiscountAmt;
            Values[I] [8] += DebitExcVat;
            Values[I] [9] += db;
            Values[I] [11] += InterruptedAmt;
            Values[I] [12] += OtherAmt;
            Values[14] [1] += ItemAmt;
            Values[14] [3] += NetSalesExcVAT;
            Values[14] [4] += ItemSalesAmt;
            Values[14] [5] += SalesReturnAmt;
            Values[14] [6] += NetSalesAmt;
            Values[14] [7] += DiscountAmt;
            Values[14] [8] += DebitExcVat;
            Values[14] [9] += db;
            Values[14] [11] += InterruptedAmt;
            Values[14] [12] += OtherAmt;
        end;
    end;
}

