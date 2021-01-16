report 6014411 "NPR Sale Time Report"
{
    // NPK7/LS/250414 CASE 176190 : Convert report to Nav 2013
    //    The print shows for each of the specified time intervals:
    //    1) The number of goods Expeditions.
    //    2) The average number of lines per. expedition.
    //    3) The amount sold.
    //    4) The returned amount.
    //    5) The cast off.
    //    6) The number of interrupted operations (Interrupted and parked).
    //    7) The number of other expeditions (gift certificates, payments etc..
    //    Requires the following key in the audit roll:
    //    Handling date, Expedition mode, type "Gift certificate Ref", Box Number, End Time, Seller Code, Bontype
    // 
    // NPR4.21/TS/20150917 CASE 222728 Corrected Text Constant
    // NPR4.21/LS/20151124  CASE 221773 Correcting report layout
    // NPR5.31/JLK /20170414  CASE 269893 Added filter on audit roll for sale and debit sale only
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.43/EMGO/20180619  CASE 318293 Make Time Filter editable in Request Page + SaveValues set to Yes
    // NPR5.46/ZESO/20181001  CASE 327839 Fix bug where Cash Register No Filter was not being applied to data.
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines
    // NPR5.55/ZESO/20200601  CASE 403608 Format TidNumber and TidNumberPlus1 in dataset to text.
    // NPR5.55/YAHA/20200807  CASE 412334 Corrections to make field Sales Amount and Net Sales with Excl VAT
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sale Time Report.rdlc';

    Caption = 'Sale Time Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            DataItemTableView = WHERE("Sale Type" = FILTER(Sale | "Debit Sale"));
            MaxIteration = 1;
            RequestFilterFields = "Register No.", "Salesperson Code", "Sale Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code";
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
            column(SalesPerson_Header; "Audit Roll"."Salesperson Code")
            {
            }
            column(DateFilter; Text10600008 + DateFilter)
            {
            }
            column(WeekDay; WeekDay)
            {
            }
            column(Filters_AuditRoll; "Audit Roll".GetFilters)
            {
            }
            column(SalespersonFilters_AuditRoll; "Audit Roll".GetFilter("Salesperson Code"))
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
            column(TextQty; "Audit Roll".FieldCaption(Quantity))
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
                    CurrReport.Break;

                if Values[Number] [1] <> 0 then
                    Values[Number] [2] := Values[Number] [2] / Values[Number] [1];

                if Values[Number] [3] <> 0 then
                    Values[Number] [10] := Round((Values[Number] [9] / Values[Number] [3]) * 100, 0.01);

                //Omsætning pr. ekspedition
                if Values[Number] [1] <> 0 then
                    Values[Number] [3] := Round((Values[Number] [3] / Values[Number] [1]), 0.01)
                else
                    Values[Number] [3] := 0;

                //-NPK7.0
                if Number = 13 then begin
                    Divider_14_3 := Values[14] [3];
                    Divider_14_1 := Values[14] [1];
                end;
                //+NPK7.0
            end;

            trigger OnPreDataItem()
            begin
                Calc;
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
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 1 field';
                        }
                        field(TimeArray_2; TimeArray[2])
                        {
                            Caption = '2';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 2 field';
                        }
                        field(TimeArray_3; TimeArray[3])
                        {
                            Caption = '3';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 3 field';
                        }
                        field(TimeArray_4; TimeArray[4])
                        {
                            Caption = '4';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 4 field';
                        }
                        field(TimeArray_5; TimeArray[5])
                        {
                            Caption = '5';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 5 field';
                        }
                        field(TimeArray_6; TimeArray[6])
                        {
                            Caption = '6';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 6 field';
                        }
                        field(TimeArray_7; TimeArray[7])
                        {
                            Caption = '7';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 7 field';
                        }
                        field(TimeArray_8; TimeArray[8])
                        {
                            Caption = '8';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 8 field';
                        }
                        field(TimeArray_9; TimeArray[9])
                        {
                            Caption = '9';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 9 field';
                        }
                        field(TimeArray_10; TimeArray[10])
                        {
                            Caption = '10';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 10 field';
                        }
                        field(TimeArray_11; TimeArray[11])
                        {
                            Caption = '11';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 11 field';
                        }
                        field(TimeArray_12; TimeArray[12])
                        {
                            Caption = '12';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 12 field';
                        }
                        field(TimeArray_13; TimeArray[13])
                        {
                            Caption = '13';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 13 field';
                        }
                        field(TimeArray_14; TimeArray[14])
                        {
                            Caption = '14';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the 14 field';
                        }
                    }
                    group(Weekdays)
                    {
                        Caption = 'Weekdays';
                        field(DayArray_1; DayArray[1])
                        {
                            Caption = 'Monday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Monday field';
                        }
                        field(DayArray_2; DayArray[2])
                        {
                            Caption = 'Tuesday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Tuesday field';
                        }
                        field(DayArray_3; DayArray[3])
                        {
                            Caption = 'Wednesday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Wednesday field';
                        }
                        field(DayArray_4; DayArray[4])
                        {
                            Caption = 'Thursday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Thursday field';
                        }
                        field(DayArray_5; DayArray[5])
                        {
                            Caption = 'Friday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Friday field';
                        }
                        field(DayArray_6; DayArray[6])
                        {
                            Caption = 'Saturday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Saturday field';
                        }
                        field(DayArray_7; DayArray[7])
                        {
                            Caption = 'Sunday';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Sunday field';
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
            if "Audit Roll"."Sale Date" = 0D then
                "Audit Roll"."Sale Date" := Today;
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
        j := '2';
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
        TimeArray[ArrayLen(TimeArray)] := 235959.99T;

        for i := 1 to ArrayLen(DayArray) do
            DayArray[i] := true;

        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
        //-NPR5.39
        // Object.SETRANGE(ID, 6014411);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        // ObjectDetails := FORMAT(Object.ID)+', '+FORMAT(Object."Version List");
        //+NPR5.39
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

        DateFilter := "Audit Roll".GetFilter("Sale Date");
        if DateFilter = '' then
            DateFilter := Format(Today);
    end;

    var
        CompanyInfo: Record "Company Information";
        AuditRoll1: Record "NPR Audit Roll";
        AuditRoll2: Record "NPR Audit Roll";
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
        j: Text[30];
        DebitAmt: Decimal;
        SalesReturnAmt: Decimal;
        ReturnChangeAmt: Decimal;
        ExchangedItemAmt: Decimal;
        CorrectedAmt: Decimal;
        AuditRollAmt: Decimal;
        Register: Record "NPR Register";
        PaymentTypePOS: Record "NPR Payment Type POS";
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
        Divider_14_3: Decimal;
        Divider_14_1: Decimal;
        Text10600010: Label 'Note : All figures are exclusive of VAT';
        Report_Caption: Label 'Sale Time Report';
        Page_Caption: Label 'Page ';
        TextTime: Label 'Time';
        TextItemExpedition: Label 'Item Sales';
        TextExpedition: Label 'No. of Sales';
        TextFrom: Label 'From';
        TextTo: Label 'To';
        TextAvgLines: Label 'Average Lines';
        TextSaleExp: Label 'Turn/Exp.';
        TextReturn: Label 'Return Amt';
        TextNetSales: Label 'Net Sales';
        TextDiscount: Label 'Discount Amt';
        TextDebit: Label 'Debit Sales Amt';
        TextDb: Label 'Margin %';
        TextDg: Label 'Dg';
        TextCancelled: Label 'Cancelled';
        TextOther: Label 'Other';
        TextSalesAmt: Label 'Sales Amt';

    procedure Calc()
    var
        MinDato: Date;
        MaxDato: Date;
        FilterArray: array[2] of Date;
    begin
        AuditRoll1.CopyFilters("Audit Roll");
        if AuditRoll1.GetFilter("Sale Date") = '' then
            AuditRoll1.SetRange("Sale Date", Today);

        MinDato := AuditRoll1.GetRangeMin("Sale Date");
        MaxDato := AuditRoll1.GetRangeMax("Sale Date");

        if not DayFilter then begin
            FilterArray[1] := MinDato;
            FilterArray[2] := MaxDato;
            Calculate(FilterArray);
        end else begin
            for MinDato := MinDato to MaxDato do begin
                if Date.Get(Date."Period Type"::Date, MinDato) then
                    if DayArray[Date."Period No."] then begin
                        //Dag er ikke fravalgt
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
                        //Dato er fravalgt
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
        AuditRoll1.SetCurrentKey("Sale Date", "Sale Type", Type, "Gift voucher ref.", "Register No.", "Closing Time", "Salesperson Code", "Receipt Type");
        AuditRoll1.CopyFilters("Audit Roll");

        if AuditRoll1.GetFilter("Register No.") = '' then begin
            if Register.FindFirst then;
        end else
            if Register.Get(AuditRoll1.GetFilter("Register No.")) then;

        AuditRoll1.SetFilter("Sale Date", '%1..%2', FilterArray[1], FilterArray[2]);
        AuditRoll1.CopyFilter("Sale Date", PaymentTypePOS."Date Filter");
        AuditRoll1.CopyFilter("Salesperson Code", PaymentTypePOS."Salesperson Filter");
        AuditRoll1.CopyFilter("Shortcut Dimension 1 Code", PaymentTypePOS."Global Dimension Code 1 Filter");
        AuditRoll1.CopyFilter("Shortcut Dimension 2 Code", PaymentTypePOS."Global Dimension Code 2 Filter");

        for I := 1 to Interval do begin
            AuditRoll1.SetFilter("Closing Time", '>=%1&<%2', TimeArray[I], TimeArray[I + 1]);
            PaymentTypePOS.SetFilter("End Time Filter", '>=%1&<%2', TimeArray[I], TimeArray[I + 1]);
            //-NPR5.46 [327839]
            PaymentTypePOS.SetFilter("Register Filter", AuditRoll1.GetFilter("Register No."));
            //+NPR5.46 [327839]
            PaymentTypePOS.CalcFields("Normal Sale in Audit Roll", "Debit Sale in Audit Roll", "Norm. Sales in Audit Excl. VAT", "Cost Amount in Audit Roll",
             "Debit Sales in Audit Excl. VAT", "Debit Cost Amount Audit Roll", "No. of Sales in Audit Roll", "No. of Deb. Sales in Aud. Roll", "No. of Sale Lines in Aud. Roll", "No. of Item Lines in Aud. Deb.");

            //-NPR5.55 [412334]
            //NetSalesAmt := PaymentTypePOS."Normal Sale in Audit Roll";
            NetSalesAmt := PaymentTypePOS."Norm. Sales in Audit Excl. VAT";
            //+NPR5.55 [412334]
            NetSalesExcVAT := PaymentTypePOS."Norm. Sales in Audit Excl. VAT";
            //-NPR5.55 [412334]
            //DebitAmt := PaymentTypePOS."Debit Sale in Audit Roll";
            DebitAmt := PaymentTypePOS."Debit Sales in Audit Excl. VAT";
            //+NPR5.55 [412334]
            CostAmt := PaymentTypePOS."Cost Amount in Audit Roll";
            //-NPR5.55 [412334]
            //DebitCostAmt := PaymentTypePOS."Debit Cost Amount Audit Roll";
            DebitCostAmt := PaymentTypePOS."Debit Sales in Audit Excl. VAT";
            //+NPR5.55 [412334]
            DebitExcVat := PaymentTypePOS."Debit Sales in Audit Excl. VAT";

            db := (NetSalesExcVAT + DebitExcVat) - (CostAmt + DebitCostAmt);

            // Qty ekspeditioner
            ItemAmt := PaymentTypePOS."No. of Sales in Audit Roll" + PaymentTypePOS."No. of Deb. Sales in Aud. Roll";

            //Qty Item Lines
            Lines := PaymentTypePOS."No. of Sale Lines in Aud. Roll" + PaymentTypePOS."No. of Item Lines in Aud. Deb.";

            //Andre ekspeditioner
            AuditRoll2.SetCurrentKey("Register No.", "Sales Ticket No.", Type, "Closing Time", Description, "Sale Date");
            AuditRoll2.CopyFilters("Audit Roll");
            AuditRoll2.SetRange("Sale Date", FilterArray[1], FilterArray[2]);
            AuditRoll2.SetFilter("Closing Time", '>=%1&<%2', TimeArray[I], TimeArray[I + 1]);
            AuditRoll2.SetFilter("Sale Type", '%1|%2|%3|%4', AuditRoll2."Sale Type"::"Out payment", AuditRoll2."Sale Type"::"Gift Voucher",
             AuditRoll2."Sale Type"::"Credit Voucher", AuditRoll2."Sale Type"::Deposit);
            OtherAmt := AuditRoll2.Count;

            AuditRoll2.SetFilter("Sale Type", '%1', AuditRoll2."Sale Type"::Comment);
            AuditRoll2.SetFilter(Type, '%1', AuditRoll2.Type::"Debit Sale");
            OtherAmt += AuditRoll2.Count;

            //Afbrudte ekspeditioner
            AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Comment);
            AuditRoll1.SetRange(Type, AuditRoll1.Type::Cancelled);
            InterruptedAmt := AuditRoll1.Count;

            //ReturnChangeAmt
            AuditRoll1.SetRange(Type, AuditRoll1.Type::Payment);
            AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Payment);
            AuditRoll1.SetRange("Receipt Type", AuditRoll1."Receipt Type"::"Negative receipt");

            AuditRoll1.CalcSums("Amount Including VAT");
            ReturnChangeAmt := Abs(AuditRoll1."Amount Including VAT");

            //ExchangedItemAmt
            AuditRoll1.SetRange("Receipt Type", AuditRoll1."Receipt Type"::"Return items");
            AuditRoll1.SetRange(Type, AuditRoll1.Type::Item);
            AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Sale);
            AuditRoll1.CalcSums(Amount);
            ExchangedItemAmt := Abs(AuditRoll1.Amount);

            //Varesalg i neg bon
            AuditRoll1.SetRange("Receipt Type", AuditRoll1."Receipt Type"::"Sales in negative receipt");
            AuditRoll1.CalcSums(Amount);
            CorrectedAmt := Abs(AuditRoll1.Amount);

            //Tilgodebeviser
            AuditRoll1.SetRange("Receipt Type");
            AuditRoll1.SetRange(Type, AuditRoll1.Type::"G/L");
            AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Deposit);
            AuditRoll1.SetRange("No.", Format(Register."Credit Voucher Account"));
            Clear(AuditRollAmt);
            if AuditRoll1.FindFirst then begin
                repeat
                    AuditRollAmt += Abs(AuditRoll1.Amount);
                until AuditRoll1.Next = 0;
            end;

            SalesReturnAmt := ReturnChangeAmt + ExchangedItemAmt + CorrectedAmt + AuditRollAmt;
            ItemSalesAmt := NetSalesAmt + SalesReturnAmt;

            //Linierabatbel¢b
            AuditRoll1.SetRange("No.");
            AuditRoll1.SetRange(Type, AuditRoll1.Type::Item);
            AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Sale);
            AuditRoll1.CalcSums("Line Discount Amount");
            DiscountAmt := AuditRoll1."Line Discount Amount";

            Values[I] [1] += ItemAmt;
            Values[I] [2] += Lines;
            Values[I] [3] += NetSalesExcVAT + DebitExcVat;
            Values[I] [4] += ItemSalesAmt;
            Values[I] [5] += SalesReturnAmt;
            Values[I] [6] += NetSalesAmt;
            Values[I] [7] += DiscountAmt;
            Values[I] [8] += DebitExcVat;
            Values[I] [9] += db;
            Values[I] [11] += InterruptedAmt;
            Values[I] [12] += OtherAmt;
            Values[14] [1] += ItemAmt;
            Values[14] [3] += NetSalesExcVAT + DebitExcVat;
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

