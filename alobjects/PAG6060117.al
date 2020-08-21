page 6060117 "TM Ticket Access Stat. Lines"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.07/TSA/20160125  CASE 232495 Admission Code as a fact in ticket statistics
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.14/TSA/20160520  CASE 240358 Fixed various features witht the RTC version of Access Statistics Matrix
    // TM1.15/TSA/20160603  CASE 242771 Transport TM1.15 - 1 June 2016
    // #278050/TSA/20170525  CASE 278049 Fixing issues report by OMA
    // TM1.22/TSA/20170606  CASE 279257 Prefill Column Filter with blocked facts, filter string length changed to text
    // TM1.23/TSA /20170719 CASE 279257 Fixed minor issues with blocking facts
    // TM1.26/TSA /20171120 CASE 293916 Added AdmissionDefinition variable to defined what gets counted
    // TM1.36/TSA /20180727 CASE 323024 Added dimension variant code
    // TM1.39/TSA /20190103 CASE 341289 Hide lines with zero admission

    Caption = 'Ticket Access Stat. Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Dimension Code Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(LINE_Total; LINE_Total)
                {
                    ApplicationArea = All;
                    Caption = 'Admissions';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    StyleExpr = 'Strong';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;

                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    StyleExpr = 'Strong';

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
    var
        MATRIX_CurrentColumnOrdinal: Integer;
    begin

        //-TM1.39 [341289]
        // MATRIX_CurrentColumnOrdinal := 0;
        // WHILE (MATRIX_CurrentColumnOrdinal < MATRIX_CurrentNoOfMatrixColumn) DO BEGIN
        //  MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
        //  MATRIX_OnAfterGetRecord (MATRIX_CurrentColumnOrdinal);
        // END;
        // MATRIX_OnAfterGetRecord (MATRIX_MaxNoOfMatrixColumn);
        //+TM1.39 [341289]

        LINE_Total := DisplayCellValue(0, 0, false);
        //IF (ColumnFactOption = ColumnFactOption::PERIOD) THEN
        //  LINE_Total := '';
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        //-TM1.39 [341289]
        // EXIT (TicketAdmissionStatisticsMgr.FindRec (LineFactOption, Rec, Which, TicketFactLineFilter,
        //                                            PeriodType, PeriodFilter, PeriodInitialized, InternalDateFilter));

        Found := TicketAdmissionStatisticsMgr.FindRec(LineFactOption, Rec, Which, TicketFactLineFilter, PeriodType, PeriodFilter, PeriodInitialized, InternalDateFilter);
        if (Found) then
            MATRIX_OnAfterGetRecord(MATRIX_MaxNoOfMatrixColumn);

        exit(Rec.Visible and Found);
        //+TM1.39 [341289]
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        Step: Integer;
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        //-TM1.39 [341289]
        // EXIT (TicketAdmissionStatisticsMgr.NextRec (LineFactOption, Rec, Steps, TicketFactLineFilter,
        //                                            PeriodType, PeriodFilter));

        repeat
            Step := TicketAdmissionStatisticsMgr.NextRec(LineFactOption, Rec, Steps, TicketFactLineFilter, PeriodType, PeriodFilter);

            if (Step <> 0) then
                MATRIX_OnAfterGetRecord(MATRIX_MaxNoOfMatrixColumn);

        until ((Rec.Visible) or (Step = 0));

        exit(Step);
        //+TM1.39 [341289]
    end;

    var
        MatrixRecords: array[12] of Record "Dimension Code Buffer";
        MATRIX_ColumnTempRec: Record "Dimension Code Buffer";
        MATRIX_MaxNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[12] of Text[80];
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_Step: Option Initial,Previous,Same,Next;
        LINE_Total: Text[80];
        TicketAdmissionStatisticsMgr: Codeunit "TM Ticket Access Statistics";
        TicketStatisticsFilter: Record "TM Ticket Access Statistics";
        TicketDrilldownFilter: Record "TM Ticket Access Statistics";
        TicketFactLineFilter: Record "TM Ticket Access Fact";
        LineFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        ColumnFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        PeriodFilter: Text[1024];
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
        MatrixPeriod: Text[30];
    begin
        MATRIX_ColumnTempRec := MatrixRecords[MATRIX_ColumnOrdinal];

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatricsPeriod('', Format(MATRIX_ColumnTempRec."Period Start"), PeriodType, 0);

        end else
            if (LineFactOption = LineFactOption::PERIOD) then begin
                MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatricsPeriod('', Format(Rec."Period Start"), PeriodType, 0);

            end;

        TicketAdmissionStatisticsMgr.StatisticsDrilldown(LineFactOption, Rec.Code,
                ColumnFactOption, MATRIX_ColumnTempRec.Code, true,
                TicketDrilldownFilter, MatrixPeriod);
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_NumberOfColumns: Integer)
    var
        CurrentColumnOrdinal: Integer;
    begin

        //-TM1.39 [341289]
        //MATRIX_CellData[MATRIX_ColumnOrdinal] := DisplayCellValue (0, MATRIX_ColumnOrdinal, TRUE);

        CurrentColumnOrdinal := 0;
        while (CurrentColumnOrdinal < MATRIX_NumberOfColumns) do begin
            CurrentColumnOrdinal += 1;
            MATRIX_CellData[CurrentColumnOrdinal] := DisplayCellValue(0, CurrentColumnOrdinal, true);

            Rec.Visible := ((Rec.Visible) or (not HideLinesWithZeroAdmitted) or (MATRIX_CellData[CurrentColumnOrdinal] <> ''));
        end;
        //+TM1.39 [341289]
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

        TicketFactLineFilter.Reset;
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
            //-TM1.36 [323024]
            LineFactOption::VARIANT_CODE:
                TicketFactLineFilter.SetFilter("Fact Code", VariantCodeFactFilter);
        //+TM1.36 [323024]
        end;
    end;

    procedure SetFilters(pItemFactFilter: Text; pTicketTypeFactFilter: Text; pAdmissionDateFactFilter: Text; pAdmissionHourFactFilter: Text; pAdmissionCodeFactFilter: Text; pVariantCodeFactFilter: Text; pBlockedItemFactFilter: Text; pBlockedTicketTypeFactFilter: Text; pBlockedDateFactFilter: Text; pBlockedHourFactFilter: Text; pBlockedAdmissionFactFilter: Text; pBlockedVariantCodeFactFilter: Text; pHideLinesWithZeroAdmitted: Boolean)
    begin
        Reset();

        ItemFactFilter := FilterAndFilter(pItemFactFilter, pBlockedItemFactFilter);
        TicketTypeFactFilter := FilterAndFilter(pTicketTypeFactFilter, pBlockedTicketTypeFactFilter);
        DateFactFilter := FilterAndFilter(pAdmissionDateFactFilter, pBlockedDateFactFilter);
        HourFactFilter := FilterAndFilter(pAdmissionHourFactFilter, pBlockedHourFactFilter);
        AdmissionCodeFactFilter := FilterAndFilter(pAdmissionCodeFactFilter, pBlockedAdmissionFactFilter);
        //-TM1.36 [323024]
        VariantCodeFactFilter := FilterAndFilter(pVariantCodeFactFilter, pBlockedVariantCodeFactFilter);
        //+TM1.36 [323024]

        TicketStatisticsFilter.Reset();
        TicketStatisticsFilter.SetFilter("Item No. Filter", ItemFactFilter);
        TicketStatisticsFilter.SetFilter("Ticket Type Filter", TicketTypeFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Date Filter", DateFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Hour Filter", HourFactFilter);
        TicketStatisticsFilter.SetFilter("Admission Code Filter", AdmissionCodeFactFilter);
        //-TM1.36 [323024]
        TicketStatisticsFilter.SetFilter("Variant Code Filter", VariantCodeFactFilter);
        //+TM1.36 [323024]

        TicketDrilldownFilter.Reset();
        TicketDrilldownFilter.SetFilter("Item No.", ItemFactFilter);
        TicketDrilldownFilter.SetFilter("Ticket Type", TicketTypeFactFilter);
        TicketDrilldownFilter.SetFilter("Admission Date", DateFactFilter);
        TicketDrilldownFilter.SetFilter("Admission Hour", HourFactFilter);
        TicketDrilldownFilter.SetFilter("Admission Code", AdmissionCodeFactFilter);
        //-TM1.36 [323024]
        TicketDrilldownFilter.SetFilter("Variant Code", VariantCodeFactFilter);
        //+TM1.36 [323024]

        //-TM1.39 [341289]
        HideLinesWithZeroAdmitted := pHideLinesWithZeroAdmitted;
        //+TM1.39 [341289]
    end;

    local procedure FilterAndFilter(pFilter1: Text; pFilter2: Text) newFilter: Text
    begin

        newFilter := pFilter1;
        if (newFilter = '') then
            newFilter := pFilter2
        else
            if (pFilter2 <> '') then
                newFilter := StrSubstNo('%1&%2', pFilter1, pFilter2);

        exit(newFilter);
    end;

    procedure DisplayCellValue(FormatOption: Option A,B,C,D; ColumnOrdinal: Integer; IncludeColumns: Boolean) CellValue: Text[30]
    var
        MatrixPeriod: Text[30];
    begin
        MATRIX_ColumnTempRec.Init();
        if (IncludeColumns) then
            MATRIX_ColumnTempRec := MatrixRecords[ColumnOrdinal];

        MatrixPeriod := DateFactFilter;

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatricsPeriod('', Format(MATRIX_ColumnTempRec."Period Start"), PeriodType, 0);
            if (not IncludeColumns) then
                MatrixPeriod := DateFactFilter;

        end else
            if (LineFactOption = LineFactOption::PERIOD) then begin
                MatrixPeriod := TicketAdmissionStatisticsMgr.FindMatricsPeriod('', Format(Rec."Period Start"), PeriodType, 0);

            end;

        CellValue := TicketAdmissionStatisticsMgr.FormatCellValue(LineFactOption, Rec.Code,
                            ColumnFactOption, MATRIX_ColumnTempRec.Code, IncludeColumns,
                            TicketStatisticsFilter, MatrixPeriod, DisplayOption, PeriodType, TrendPeriodType, AdmissionDefinition);
    end;
}

