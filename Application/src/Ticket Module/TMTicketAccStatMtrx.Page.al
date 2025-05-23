﻿page 6060116 "NPR TM Ticket Acc. Stat. Mtrx"
{
    Extensible = False;
    Caption = 'Ticket Access Statistics Matrix';
    PageType = ListPlus;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Ticket Statistics, Admission Statistics';
    PromotedActionCategories = 'New,Process,Report,Update,Navigate';
    layout
    {
        area(content)
        {
            group(General)
            {
                group(MatrixGroup)
                {
                    Caption = 'Matrix';
                    field(fld_LineFactOption; LineFactOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show as Lines';
                        Importance = Promoted;
                        OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Period,Admission Code,Variant Code';
                        ToolTip = 'Specifies the value of the Show as Lines field';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                        end;

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm();
                        end;
                    }
                    field(fld_ColumnFactOption; ColumnFactOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show as Columns';
                        Importance = Promoted;
                        OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Period,Admission Code,Variant Code';
                        ToolTip = 'Specifies the value of the Show as Columns field';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                        end;

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm();
                        end;
                    }
                }
                group(Display)
                {
                    Caption = 'Display';
                    field(fld_FactNameAsColumnHeading; FactNameAsColumnHeading)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Fact Name As Column Heading';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Fact Name As Column Heading field';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm();
                        end;
                    }
                    field(fld_HideAdmission; HideLinesWithZeroAdmissionCount)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Hide Lines having Zero Admitted';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Hide Lines having Zero Admitted field';

                        trigger OnValidate()
                        begin
                            //-#341289 [341289]
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm();
                            //+#341289 [341289]
                        end;
                    }
                }
                group(Metrics)
                {
                    Caption = 'Metrics';
                    field(VerticalTotalText; VerticalTotalText)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Matrix Total';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Matrix Total field';
                    }
                    field(AdmissionDefinition; AdmissionDefinition)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Admission Count Def.';
                        Importance = Additional;
                        OptionCaption = 'Admitted Count,Admitted count with Revoked,Admitted (All)';
                        ToolTip = 'Specifies the value of the Admission Count Def. field';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm();
                        end;
                    }
                    field(fld_DisplayOption; DisplayOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show Value As';
                        Importance = Promoted;
                        OptionCaption = 'Admission Count,Count & Trend,Trend';
                        ToolTip = 'Specifies the value of the Show Value As field';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm();
                        end;
                    }
                    field(fld_PeriodType; PeriodType)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'View by';
                        Importance = Additional;
#if BC17 or BC18
                        OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
#endif
                        ToolTip = 'Specifies the value of the View by field';

                        trigger OnValidate()
                        begin
                            DateFactFilter := '';
                            FindPeriod('');
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm();
                        end;
                    }
                    field(fld_TrendPeriodType; TrendPeriodType)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Trend Period Type';
                        Importance = Additional;
                        OptionCaption = 'Period,Year';
                        ToolTip = 'Specifies the value of the Trend Period Type field';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm();
                        end;
                    }
                }
            }
            part(MATRIX; "NPR TM Ticket Acs. Stat.Lines")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ShowFilter = false;
            }
            group("Matrix Filters")
            {
                Caption = 'Matrix Filters';
                field(ItemFactFilter; ItemFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Item Filter';
                    ToolTip = 'Specifies the value of the Item Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::ITEM, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
                field(TicketTypeFactFilter; TicketTypeFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Type Filter';
                    ToolTip = 'Specifies the value of the Ticket Type Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::TICKET_TYPE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
                field(DateFactFilter; DateFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the value of the Date Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DateValue: Date;
                    begin

                        if (FactLookup(LineFactOption::ADMISSION_DATE, Text)) then begin
                            if (Evaluate(DateValue, Text, 9)) then
                                Text := Format(DateValue);
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    var
                        SystemEventWrapper: Codeunit "NPR System Event Wrapper";
                        TicketStatistics: Record "NPR TM Ticket Access Stats";
                    begin

                        //-TM1.39 [334644]
                        SystemEventWrapper.MakeDateFilter(DateFactFilter);
                        //+TM1.39 [334644]

                        TicketStatistics.SetFilter("Admission Date", DateFactFilter);
                        DateFactFilter := TicketStatistics.GetFilter("Admission Date");
                        InternalDateFilter := DateFactFilter;
                        // DateFilterOnAfterValidate;

                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
                field(HourFactFilter; HourFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Hour Filter';
                    ToolTip = 'Specifies the value of the Hour Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::ADMISSION_HOUR, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
                field(AdmissionCodeFilter; AdmissionCodeFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Admission Code Filter';
                    ToolTip = 'Specifies the value of the Admission Code Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::ADMISSION_CODE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
                field(VariantCodeFilter; VariantCodeFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Variant Code Filter';
                    ToolTip = 'Specifies the value of the Variant Code Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::VARIANT_CODE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm();
                    end;
                }
            }
            group("Blocked Facts")
            {
                Caption = 'Blocked Facts';
                field(BlockedItemFactFilter; BlockedItemFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Item Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked Item Filter field';
                }
                field(BlockedTicketTypeFactFilter; BlockedTicketTypeFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Ticket Type Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked Ticket Type Filter field';
                }
                field(BlockedHourFactFilter; BlockedHourFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Hour Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked Hour Filter field';
                }
                field(BlockedAdmissionFactFilter; BlockedAdmissionFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Admisson Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked Admisson Filter field';
                }
                field(BlockedVariantFactFilter; BlockedVariantFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Variant Code Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked Variant Code Filter field';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Update Statistics")
            {
                ToolTip = 'Update statistics with the latest admission information.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Update Statistics';
                Image = Refresh;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                trigger OnAction()
                begin
                    TicketAccessStatisticsMgr.BuildCompressedStatistics(Today);
                    UpdateMatrixSubForm();
                end;
            }
            group(Periods)
            {
                Caption = 'Periods';
                action("Previous Period")
                {
                    ToolTip = 'Previous Period';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Period';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin

                        FindPeriod('<');
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);

                        CurrPage.Update();
                        UpdateMatrixSubForm();
                    end;
                }
                action("Next Period")
                {
                    ToolTip = 'Next Period';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Period';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin

                        FindPeriod('>');
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);

                        CurrPage.Update();
                        UpdateMatrixSubForm();
                    end;
                }
                action("Previous Set")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Set';
                    Image = PreviousSet;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Previous Set';

                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Previous);
                        UpdateMatrixSubForm();
                    end;
                }
                action("Previous Column")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Column';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Previous Set';

                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::PreviousColumn);
                        UpdateMatrixSubForm();
                    end;
                }
                action("Next Column")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Column';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Next Set';

                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::NextColumn);
                        UpdateMatrixSubForm();
                    end;
                }
                action("Next Set")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Set';
                    Image = NextSet;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Next Set';

                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Next);
                        UpdateMatrixSubForm();
                    end;
                }
            }
            action(Forecast)
            {
                ToolTip = 'Navigate to Admission Forecast.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Forecast';
                Image = Forecast;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Page "NPR TM Admis. Forecast Matrix";
            }
        }
    }

    trigger OnInit()
    begin
        TicketAccessStatisticsMgr.BuildCompressedStatistics(Today);
        LineFactOption := 0;
        ColumnFactOption := 1;
        PeriodType := PeriodType::Day;
        SetAutoFilterOnBlockedFacts();
    end;

    trigger OnOpenPage()
    begin
        FindPeriod('');
        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
        UpdateMatrixSubForm();
        CalcVerticalTotal();
    end;

    var
        MATRIX_MatrixRecords: array[32] of Record "Dimension Code Buffer";
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_CaptionRange: Text;
        MATRIX_PrimKeyFirstCaptionInCu: Text;
        MATRIX_CurrentNoOfColumns: Integer;
        MATRIX_Step: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        TicketAccessStatisticsMgr: Codeunit "NPR TM Ticket Access Stats";
        LineFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        ColumnFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        FactNameAsColumnHeading: Boolean;
        HideLinesWithZeroAdmissionCount: Boolean;
        ItemFactFilter: Text;
        TicketTypeFactFilter: Text;
        DateFactFilter: Text;
        HourFactFilter: Text;
        AdmissionCodeFilter: Text;
        VariantCodeFilter: Text;
        DisplayOption: Option "COUNT",COUNT_TREND,TREND;
        TrendPeriodType: Option PERIOD,YEAR;
#if (BC17 or BC18)
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
#else
        PeriodType: Enum "Analysis Period Type";
#endif
        TicketStatisticsFilter: Record "NPR TM Ticket Access Stats";
        InternalDateFilter: Text;
        VerticalTotalText: Text;
        INVALID_FACT_OPTION: Label 'Invalid FactOption';
        BlockedItemFactFilter: Text;
        BlockedAdmissionFactFilter: Text;
        BlockedTicketTypeFactFilter: Text;
        BlockedHourFactFilter: Text;
        BlockedVariantFactFilter: Text;
        AdmissionDefinition: Option ADMITTED_COUNT,ADMITTED_REVOKED_COUNT,ADMITTED_ALL;

    internal procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
        MATRIX_PeriodRecords: array[32] of Record Date;
        i: Integer;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TicketFact: Record "NPR TM Ticket Access Fact";
        HaveCaptions: Boolean;
        AccessStatistics: Record "NPR TM Ticket Access Stats";
    begin

        Clear(MATRIX_CaptionSet);
        Clear(MATRIX_MatrixRecords);
        MATRIX_CurrentNoOfColumns := 12;

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            MatrixMgt.GeneratePeriodMatrixData(
              MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, FactNameAsColumnHeading,
              PeriodType, DateFactFilter, MATRIX_PrimKeyFirstCaptionInCu,
              MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns, MATRIX_PeriodRecords);
            for i := 1 to MATRIX_CurrentNoOfColumns do begin
                MATRIX_MatrixRecords[i]."Period Start" := MATRIX_PeriodRecords[i]."Period Start";
                MATRIX_MatrixRecords[i]."Period End" := MATRIX_PeriodRecords[i]."Period End";
            end;
        end else begin

            Clear(MATRIX_CaptionSet);
            RecRef.GetTable(TicketFact);
            RecRef.SetTable(TicketFact);

            FieldRef := RecRef.FieldIndex(1);
            HaveCaptions := true;

            case ColumnFactOption of
                ColumnFactOption::ITEM:
                    begin
                        FieldRef.SetFilter('=%1', TicketFact."Fact Name"::ITEM);
                        if ((ItemFactFilter <> '') or (BlockedItemFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(ItemFactFilter, BlockedItemFactFilter));
                        end;
                    end;
                ColumnFactOption::TICKET_TYPE:
                    begin
                        FieldRef.SetFilter('=%1', TicketFact."Fact Name"::TICKET_TYPE);
                        if ((TicketTypeFactFilter <> '') or (BlockedTicketTypeFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(TicketTypeFactFilter, BlockedTicketTypeFactFilter));
                        end;
                    end;
                ColumnFactOption::ADMISSION_DATE:
                    begin
                        FieldRef.SetFilter('%1', TicketFact."Fact Name"::ADMISSION_DATE);
                        if (DateFactFilter <> '') then begin
                            // cast native date to XML date on fact table
                            AccessStatistics.SetFilter("Admission Date", DateFactFilter);
                            if (AccessStatistics.FindFirst()) then;
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter('%1..%2', Format(AccessStatistics.GetRangeMin("Admission Date"), 0, 9), Format(AccessStatistics.GetRangeMax("Admission Date"), 0, 9));
                        end;
                    end;
                ColumnFactOption::ADMISSION_HOUR:
                    begin
                        FieldRef.SetFilter('%1', TicketFact."Fact Name"::ADMISSION_HOUR);
                        if ((HourFactFilter <> '') or (BlockedHourFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(HourFactFilter, BlockedHourFactFilter));
                        end;
                    end;
                ColumnFactOption::ADMISSION_CODE:
                    begin
                        FieldRef.SetFilter('%1', TicketFact."Fact Name"::ADMISSION_CODE);
                        if ((AdmissionCodeFilter <> '') or (BlockedAdmissionFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(AdmissionCodeFilter, BlockedAdmissionFactFilter));
                        end;
                    end;
                ColumnFactOption::VARIANT_CODE:
                    begin
                        FieldRef.SetFilter('%1', TicketFact."Fact Name"::VARIANT_CODE);
                        if ((VariantCodeFilter <> '') or (BlockedVariantFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(VariantCodeFilter, BlockedVariantFactFilter));
                        end;
                    end;
                else
                    HaveCaptions := false;
            end;

            if (HaveCaptions) then begin
                MatrixMgt.GenerateMatrixData(
                  RecRef, MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, 2,
                  MATRIX_PrimKeyFirstCaptionInCu, MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);

                for i := 1 to MATRIX_CurrentNoOfColumns do
                    MATRIX_MatrixRecords[i].Code := MATRIX_CaptionSet[i];

                if (FactNameAsColumnHeading) then
                    MatrixMgt.GenerateMatrixData(
                      RecRef, MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, 10,
                      MATRIX_PrimKeyFirstCaptionInCu, MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);
            end;

        end;
    end;

    local procedure FindPeriod(SearchText: Text[3])
    var
        Calendar: Record Date;
#if (BC17 or BC18)
        PeriodFormMgt: Codeunit PeriodFormManagement;
#else
        PeriodPageMgt: Codeunit PeriodPageManagement;
#endif
        Date1: Date;
        Date2: Date;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
    begin

        if (DateFactFilter <> '') then begin
            Calendar.SetFilter("Period Start", DateFactFilter);

#if (BC17 or BC18)
            if (not PeriodFormMgt.FindDate('-', Calendar, PeriodType)) then
                PeriodFormMgt.FindDate('-', Calendar, PeriodType::Day);
#else
            if (not PeriodPageMgt.FindDate('-', Calendar, PeriodType)) then
                PeriodPageMgt.FindDate('-', Calendar, PeriodType::Day);
#endif

            Calendar.SetRange("Period Start");
        end;

        if Calendar."Period Start" = 0D then
            Calendar."Period Start" := Today();

#if (BC17 or BC18)
        PeriodFormMgt.FindDate(SearchText, Calendar, PeriodType);
#else
        PeriodPageMgt.FindDate(SearchText, Calendar, PeriodType);
#endif
        Date1 := Calendar."Period Start";
        Date2 := Calendar."Period End";

        if (ColumnFactOption = ColumnFactOption::PERIOD) then begin
            Date1 := Calendar."Period Start";
            Calendar.Next(11);
            Date2 := Calendar."Period End";
        end;

        TicketStatistics.SetRange("Admission Date Filter", NormalDate(Date1), NormalDate(Date2));

        if (TicketStatistics.GetRangeMin("Admission Date Filter") = TicketStatistics.GetRangeMax("Admission Date Filter")) then
            TicketStatistics.SetRange("Admission Date Filter", TicketStatistics.GetRangeMin("Admission Date Filter"));

        InternalDateFilter := TicketStatistics.GetFilter("Admission Date Filter");
        DateFactFilter := InternalDateFilter;
    end;

    local procedure UpdateMatrixSubForm()
    begin
        CurrPage.MATRIX.PAGE.SetFilters(
          ItemFactFilter, TicketTypeFactFilter, DateFactFilter, HourFactFilter, AdmissionCodeFilter, VariantCodeFilter,
          BlockedItemFactFilter, BlockedTicketTypeFactFilter, '', BlockedHourFactFilter, BlockedAdmissionFactFilter, BlockedVariantFactFilter,
          HideLinesWithZeroAdmissionCount);

        CurrPage.MATRIX.PAGE.Load(
          MATRIX_CaptionSet,
          MATRIX_MatrixRecords,
          MATRIX_CurrentNoOfColumns,
          LineFactOption, ColumnFactOption, DisplayOption, PeriodType, AdmissionDefinition);

        TicketStatisticsFilter.Reset();
        TicketStatisticsFilter.SetFilter("Item No. Filter", FilterAndFilter(ItemFactFilter, BlockedItemFactFilter));
        TicketStatisticsFilter.SetFilter("Ticket Type Filter", FilterAndFilter(TicketTypeFactFilter, BlockedTicketTypeFactFilter));
        TicketStatisticsFilter.SetFilter("Admission Date Filter", FilterAndFilter(DateFactFilter, ''));
        TicketStatisticsFilter.SetFilter("Admission Hour Filter", FilterAndFilter(HourFactFilter, BlockedHourFactFilter));
        TicketStatisticsFilter.SetFilter("Admission Code Filter", FilterAndFilter(AdmissionCodeFilter, BlockedAdmissionFactFilter));
        TicketStatisticsFilter.SetFilter("Variant Code Filter", FilterAndFilter(VariantCodeFilter, BlockedVariantFactFilter));

        CalcVerticalTotal();
        CurrPage.Update(false);
    end;

    internal procedure FactLookup(FactOption: Option; var FactFilter: Text): Boolean
    var
        FactList: Page "NPR TM Ticket Access Facts";
        TicketFact: Record "NPR TM Ticket Access Fact";
    begin
        TicketFact.FilterGroup(2);
        case FactOption of
            LineFactOption::ITEM:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ITEM);
            LineFactOption::TICKET_TYPE:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::TICKET_TYPE);
            LineFactOption::ADMISSION_DATE:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_DATE);
            LineFactOption::ADMISSION_HOUR:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_HOUR);
            LineFactOption::ADMISSION_CODE:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_CODE);
            //-TM1.36 [323024]
            LineFactOption::VARIANT_CODE:
                TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::VARIANT_CODE);
            //+TM1.36 [323024]

            else
                Error(INVALID_FACT_OPTION);
        end;
        TicketFact.FilterGroup(0);

        FactList.LookupMode(true);
        FactList.SetTableView(TicketFact);
        FactList.SetSelection(TicketFact);

        if FactList.RunModal() = ACTION::LookupOK then begin
            FactFilter := FactList.GetSelectionFilter();
            UpdateMatrixSubForm();
            exit(true);
        end;
    end;

    local procedure CalcVerticalTotal()
    var
        MatrixPeriod: Text;
    begin

        MatrixPeriod := DateFactFilter;
        VerticalTotalText := Format(TicketAccessStatisticsMgr.CalcVerticalTotal(LineFactOption, ColumnFactOption, TicketStatisticsFilter, MatrixPeriod, AdmissionDefinition));
    end;

    local procedure SetAutoFilterOnBlockedFacts()
    var
        TicketAccessFact: Record "NPR TM Ticket Access Fact";
        BlockedTicketTypeFactFilterLbl: Label '<>%1', Locked = true;
        BlockedTicketTypeFactFilter2Lbl: Label '%1&<>%2', Locked = true;
    begin

        TicketAccessFact.SetFilter(Block, '=%1', true);
        if (TicketAccessFact.FindSet()) then begin
            repeat
                case TicketAccessFact."Fact Name" of

                    TicketAccessFact."Fact Name"::TICKET_TYPE:
                        if (BlockedTicketTypeFactFilter = '') then
                            BlockedTicketTypeFactFilter := StrSubstNo(BlockedTicketTypeFactFilterLbl, TicketAccessFact."Fact Code")
                        else
                            BlockedTicketTypeFactFilter := StrSubstNo(BlockedTicketTypeFactFilter2Lbl, BlockedTicketTypeFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ADMISSION_CODE:
                        if (BlockedAdmissionFactFilter = '') then
                            BlockedAdmissionFactFilter := StrSubstNo(BlockedTicketTypeFactFilterLbl, TicketAccessFact."Fact Code")
                        else
                            BlockedAdmissionFactFilter := StrSubstNo(BlockedTicketTypeFactFilter2Lbl, BlockedAdmissionFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ITEM:
                        if (BlockedItemFactFilter = '') then
                            BlockedItemFactFilter := StrSubstNo(BlockedTicketTypeFactFilterLbl, TicketAccessFact."Fact Code")
                        else
                            BlockedItemFactFilter := StrSubstNo(BlockedTicketTypeFactFilter2Lbl, BlockedItemFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ADMISSION_HOUR:
                        if (BlockedHourFactFilter = '') then
                            BlockedHourFactFilter := StrSubstNo(BlockedTicketTypeFactFilterLbl, TicketAccessFact."Fact Code")
                        else
                            BlockedHourFactFilter := StrSubstNo(BlockedTicketTypeFactFilter2Lbl, BlockedHourFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::VARIANT_CODE:
                        if (BlockedVariantFactFilter = '') then
                            BlockedVariantFactFilter := StrSubstNo(BlockedTicketTypeFactFilterLbl, TicketAccessFact."Fact Code")
                        else
                            BlockedVariantFactFilter := StrSubstNo(BlockedTicketTypeFactFilter2Lbl, BlockedVariantFactFilter, TicketAccessFact."Fact Code");
                end;
            until (TicketAccessFact.Next() = 0);
        end;
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
}

