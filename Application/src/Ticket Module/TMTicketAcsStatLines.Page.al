page 6060117 "NPR TM Ticket Acs. Stat.Lines"
{
    Caption = 'Ticket Access Stat. Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Dimension Code Buffer";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("LINE_Total"; LINE_Total)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Admissions';
                    ToolTip = 'Specifies the value of the Admissions field';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin

        LINE_Total := DisplayCellValue(0, 0, false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        Found := TicketAdmissionStatisticsMgr.FindRec(LineFactOption, Rec, Which, TicketFactLineFilter, PeriodType, PeriodFilter, PeriodInitialized, InternalDateFilter);
        if (Found) then
            MATRIX_OnAfterGetRecord(MATRIX_MaxNoOfMatrixColumn);

        exit(Rec.Visible and Found);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        Step: Integer;
    begin
        repeat
            Step := TicketAdmissionStatisticsMgr.NextRec(LineFactOption, Rec, Steps, TicketFactLineFilter, PeriodType, PeriodFilter);

            if (Step <> 0) then
                MATRIX_OnAfterGetRecord(MATRIX_MaxNoOfMatrixColumn);

        until ((Rec.Visible) or (Step = 0));

        exit(Step);
    end;

    var
        MatrixRecords: array[12] of Record "Dimension Code Buffer";
        MATRIX_ColumnTempRec: Record "Dimension Code Buffer";
        MATRIX_MaxNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[12] of Text;
        MATRIX_CaptionSet: array[32] of Text[80];
        LINE_Total: Text;
        TicketAdmissionStatisticsMgr: Codeunit "NPR TM Ticket Access Stats";
        TicketStatisticsFilter: Record "NPR TM Ticket Access Stats";
        TicketDrillDownFilter: Record "NPR TM Ticket Access Stats";
        TicketFactLineFilter: Record "NPR TM Ticket Access Fact";
        LineFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        ColumnFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        PeriodFilter: Text;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        PeriodInitialized: Boolean;
        InternalDateFilter: Text[30];
        ItemFactFilter: Text;
        TicketTypeFactFilter: Text;
        DateFactFilter: Text;
        HourFactFilter: Text;
        AdmissionCodeFactFilter: Text;
        VariantCodeFactFilter: Text;
        DisplayOption: Option "COUNT",COUNT_TREND,TREND;
        TrendPeriodType: Option PERIOD,YEAR;
        AdmissionDefinition: Option;
        HideLinesWithZeroAdmitted: Boolean;

    local procedure MATRIX_OnDrillDown(MATRIX_ColumnOrdinal: Integer)
    var
        MatrixPeriod: Text;
    begin
        MATRIX_ColumnTempRec := MatrixRecords[MATRIX_ColumnOrdinal];

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatrixPeriod('', Format(MATRIX_ColumnTempRec."Period Start"), PeriodType, 0);

        end else
            if (LineFactOption = LineFactOption::PERIOD) then begin
                MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatrixPeriod('', Format(Rec."Period Start"), PeriodType, 0);

            end;

        TicketAdmissionStatisticsMgr.StatisticsDrillDown(LineFactOption, Rec.Code,
                ColumnFactOption, MATRIX_ColumnTempRec.Code, true,
                TicketDrillDownFilter, MatrixPeriod);
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_NumberOfColumns: Integer)
    var
        CurrentColumnOrdinal: Integer;
    begin

        CurrentColumnOrdinal := 0;
        while (CurrentColumnOrdinal < MATRIX_NumberOfColumns) do begin
            CurrentColumnOrdinal += 1;
            MATRIX_CellData[CurrentColumnOrdinal] := DisplayCellValue(0, CurrentColumnOrdinal, true);

            Rec.Visible := ((Rec.Visible) or (not HideLinesWithZeroAdmitted) or (MATRIX_CellData[CurrentColumnOrdinal] <> ''));
        end;

    end;

    procedure Load(MatrixColumns1: array[32] of Text[80]; var MatrixRecords1: array[12] of Record "Dimension Code Buffer"; CurrentNoOfMatrixColumns: Integer; pLineDimOption: Integer; pColumnDimOption: Integer; pDisplayOption: Option; pPeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period"; pAdmissionDefinition: Option)
    var
        i: Integer;
    begin

        for i := 1 to 12 do begin
            MATRIX_CaptionSet[i] := MatrixColumns1[i];
            MatrixRecords[i] := MatrixRecords1[i];
            MATRIX_CellData[i] := '';
        end;
        MATRIX_MaxNoOfMatrixColumn := CurrentNoOfMatrixColumns;

        LineFactOption := pLineDimOption;
        ColumnFactOption := pColumnDimOption;
        DisplayOption := pDisplayOption;
        PeriodType := pPeriodType;
        AdmissionDefinition := pAdmissionDefinition;

        TicketFactLineFilter.Reset();
        case LineFactOption of
            LineFactOption::ITEM:
                TicketFactLineFilter.SetFilter("Fact Code", ItemFactFilter);
            LineFactOption::TICKET_TYPE:
                TicketFactLineFilter.SetFilter("Fact Code", TicketTypeFactFilter);
            LineFactOption::ADMISSION_CODE:
                TicketFactLineFilter.SetFilter("Fact Code", AdmissionCodeFactFilter);
            LineFactOption::ADMISSION_DATE:
                TicketFactLineFilter.SetFilter("Fact Code", DateFactFilter);
            LineFactOption::ADMISSION_HOUR:
                TicketFactLineFilter.SetFilter("Fact Code", HourFactFilter);
            LineFactOption::VARIANT_CODE:
                TicketFactLineFilter.SetFilter("Fact Code", VariantCodeFactFilter);
        end;
    end;

    procedure SetFilters(pItemFactFilter: Text; pTicketTypeFactFilter: Text; pAdmissionDateFactFilter: Text; pAdmissionHourFactFilter: Text; pAdmissionCodeFactFilter: Text; pVariantCodeFactFilter: Text; pBlockedItemFactFilter: Text; pBlockedTicketTypeFactFilter: Text; pBlockedDateFactFilter: Text; pBlockedHourFactFilter: Text; pBlockedAdmissionFactFilter: Text; pBlockedVariantCodeFactFilter: Text; pHideLinesWithZeroAdmitted: Boolean)
    begin
        Rec.Reset();

        ItemFactFilter := FilterAndFilter(pItemFactFilter, pBlockedItemFactFilter);
        TicketTypeFactFilter := FilterAndFilter(pTicketTypeFactFilter, pBlockedTicketTypeFactFilter);
        DateFactFilter := FilterAndFilter(pAdmissionDateFactFilter, pBlockedDateFactFilter);
        HourFactFilter := FilterAndFilter(pAdmissionHourFactFilter, pBlockedHourFactFilter);
        AdmissionCodeFactFilter := FilterAndFilter(pAdmissionCodeFactFilter, pBlockedAdmissionFactFilter);
        VariantCodeFactFilter := FilterAndFilter(pVariantCodeFactFilter, pBlockedVariantCodeFactFilter);

        TicketStatisticsFilter.Reset();
        TicketStatisticsFilter.SetFilter("Item No. Filter", ItemFactFilter);
        TicketStatisticsFilter.SetFilter("Ticket Type Filter", TicketTypeFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Date Filter", DateFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Hour Filter", HourFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Code Filter", AdmissionCodeFactFilter);
        TicketStatisticsFilter.SetFilter("Variant Code Filter", VariantCodeFactFilter);

        TicketDrillDownFilter.Reset();
        TicketDrillDownFilter.SetFilter("Item No.", ItemFactFilter);
        TicketDrillDownFilter.SetFilter("Ticket Type", TicketTypeFactFilter);
        TicketDrillDownFilter.SetFilter("Admission Date", DateFactFilter);
        TicketDrillDownFilter.SetFilter("Admission Hour", HourFactFilter);
        TicketDrillDownFilter.SetFilter("Admission Code", AdmissionCodeFactFilter);
        TicketDrillDownFilter.SetFilter("Variant Code", VariantCodeFactFilter);

        HideLinesWithZeroAdmitted := pHideLinesWithZeroAdmitted;
    end;

    local procedure FilterAndFilter(pFilter1: Text; pFilter2: Text) newFilter: Text
    var
        FilterLbl: Label '%1&%2', Locked = true;
    begin
        newFilter := pFilter1;
        if (newFilter = '') then
            newFilter := pFilter2
        else
            if (pFilter2 <> '') then
                newFilter := StrSubstNo(FilterLbl, pFilter1, pFilter2);

        exit(newFilter);
    end;

    procedure DisplayCellValue(FormatOption: Option A,B,C,D; ColumnOrdinal: Integer; IncludeColumns: Boolean) CellValue: Text
    var
        MatrixPeriod: Text;
    begin
        MATRIX_ColumnTempRec.Init();
        if (IncludeColumns) then
            MATRIX_ColumnTempRec := MatrixRecords[ColumnOrdinal];

        MatrixPeriod := DateFactFilter;

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatrixPeriod('', Format(MATRIX_ColumnTempRec."Period Start"), PeriodType, 0);
            if (not IncludeColumns) then
                MatrixPeriod := DateFactFilter;

        end else
            if (LineFactOption = LineFactOption::PERIOD) then begin
                MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatrixPeriod('', Format(Rec."Period Start"), PeriodType, 0);

            end;

        CellValue := TicketAdmissionStatisticsMgr.FormatCellValue(LineFactOption, Rec.Code,
                            ColumnFactOption, MATRIX_ColumnTempRec.Code, IncludeColumns,
                            TicketStatisticsFilter, MatrixPeriod, DisplayOption, PeriodType, TrendPeriodType, AdmissionDefinition);
    end;
}

