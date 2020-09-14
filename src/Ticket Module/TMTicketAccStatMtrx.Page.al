page 6060116 "NPR TM Ticket Acc. Stat. Mtrx"
{
    // NPR4.14/TSA/20150803 CASE214262 - Initial Version
    // TM1.00/TSA /20151217 CASE 219658-01 NaviPartner Ticket Management
    // TM1.07/TSA /20160125 CASE 232495 Admission Code as a fact in ticket statistics
    // TM1.12/TSA /20160407 CASE 230600 Added DAN Captions
    // TM1.14/TSA /20160520 CASE 240358 Fixed various features witht the RTC version of Access Statistics Matrix
    // TM1.15/TSA /20160603 CASE 242771 Transport TM1.15 - 1 June 2016
    // TM1.15/TSA /20170525 CASE 278049 Fixing issues report by OMA
    // TM1.22/TSA /20170606 CASE 279257 Fixed the Admission Code Column Filter Screen Refresh
    // TM1.22/TSA /20170606 CASE 279257 Prefill Column Filter with blocked facts
    // TM1.23/TSA /20170719 CASE 279257 Fixed minor issues with blocking facts
    // TM1.26/TSA /20171120 CASE 293916 Added the AdmissionDefinition field to defined what should be counted
    // TM1.28/TSA /20180202 CASE 304216 Changed intial period to be Day instead of month
    // TM1.36/TSA /20180727 CASE 323024 Adding dimension variant code
    // TM1.36/TSA /20180727 CASE 323400 Added admitted including revisits
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // TM1.47/TSA /20200421 CASE 401250 Added a "update statistics" action
    // TM1.48/TSA /20200705 CASE 409741 Added Admission Forecast Action

    Caption = 'Ticket Access Statistics Matrix';
    PageType = ListPlus;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(MatrixGroup)
                {
                    Caption = 'Matrix';
                    field("fld_LineFactOption"; LineFactOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show as Lines';
                        Importance = Promoted;
                        OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Period,Admission Code,Variant Code';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NewCode: Text[30];
                        begin
                        end;

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm;
                        end;
                    }
                    field("fld_ColumnFactOption"; ColumnFactOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show as Columns';
                        Importance = Promoted;
                        OptionCaption = 'Item,Ticket Type,Admission Date,Admission Hour,Period,Admission Code,Variant Code';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NewCode: Text[30];
                        begin
                        end;

                        trigger OnValidate()
                        var
                            MATRIX_SetWanted: Option First,Previous,Same,Next;
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm;
                        end;
                    }
                }
                group(Display)
                {
                    Caption = 'Display';
                    field("fld_FactNameAsColumnHeading"; FactNameAsColumnHeading)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Fact Name As Column Heading';
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm;
                        end;
                    }
                    field("fld_HideAdmission"; HideLinesWithZeroAdmissionCount)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Hide Lines having Zero Admitted';
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            //-#341289 [341289]
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm;
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
                    }
                    field(AdmissionDefinition; AdmissionDefinition)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Admission Count Def.';
                        Importance = Additional;
                        OptionCaption = 'Admitted Count,Admitted minus Revoked,Admitted incl. Revisits';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm;
                        end;
                    }
                    field("fld_DisplayOption"; DisplayOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Show Value As';
                        Importance = Promoted;
                        OptionCaption = 'Admission Count,Count & Trend,Trend';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm;
                        end;
                    }
                    field("fld_PeriodType"; PeriodType)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'View by';
                        Importance = Additional;
                        OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';

                        trigger OnValidate()
                        begin
                            DateFactFilter := '';
                            FindPeriod('');
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            UpdateMatrixSubForm;
                        end;
                    }
                    field("fld_TrendPeriodType"; TrendPeriodType)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Trend Period Type';
                        Importance = Additional;
                        OptionCaption = 'Period,Year';

                        trigger OnValidate()
                        begin
                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Same);
                            UpdateMatrixSubForm;
                        end;
                    }
                }
            }
            part(MATRIX; "NPR TM Ticket Acs. Stat.Lines")
            {
                ShowFilter = false;

            }
            group("Matrix Filters")
            {
                Caption = 'Matrix Filters';
                field(ItemFactFilter; ItemFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Item Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin

                        exit(FactLookup(LineFactOption::ITEM, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm;
                    end;
                }
                field(TicketTypeFactFilter; TicketTypeFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Type Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin

                        exit(FactLookup(LineFactOption::TICKET_TYPE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm;
                    end;
                }
                field(DateFactFilter; DateFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Date Filter';

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
                        UpdateMatrixSubForm;
                    end;
                }
                field(HourFactFilter; HourFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Hour Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::ADMISSION_HOUR, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm;
                    end;
                }
                field(AdmissionCodeFilter; AdmissionCodeFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Admission Code Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::ADMISSION_CODE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm;
                    end;
                }
                field(VariantCodeFilter; VariantCodeFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Variant Code Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        exit(FactLookup(LineFactOption::VARIANT_CODE, Text));
                    end;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        UpdateMatrixSubForm;
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
                }
                field(BlockedTicketTypeFactFilter; BlockedTicketTypeFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Ticket Type Filter';
                    Editable = false;
                }
                field(BlockedHourFactFilter; BlockedHourFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Hour Filter';
                    Editable = false;
                }
                field(BlockedAdmissionFactFilter; BlockedAdmissionFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Admisson Filter';
                    Editable = false;
                }
                field(BlockedVariantFactFilter; BlockedVariantFactFilter)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Blocked Variant Code Filter';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Statistics")
            {
                ToolTip = 'Update statistics with the latest admission information.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Update Statistics';
                Image = Refresh;
                Promoted = true;
                PromotedIsBig = true;


                trigger OnAction()
                begin

                    //-TM1.47 [401250]
                    TicketAccessStatisticsMgr.BuildCompressedStatistics(Today);
                    UpdateMatrixSubForm;
                    //+TM1.47 [401250]
                end;
            }
            group(Periods)
            {
                Caption = 'Periods';
                action("Next Period")
                {
                    ToolTip = 'Next Period';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Period';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedCategory = Process;


                    trigger OnAction()
                    begin

                        FindPeriod('>');
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);

                        CurrPage.Update;
                        UpdateMatrixSubForm;
                    end;
                }
                action("Previous Period")
                {
                    ToolTip = 'Previous Period';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Period';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedCategory = Process;


                    trigger OnAction()
                    begin

                        FindPeriod('<');
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);

                        CurrPage.Update;
                        UpdateMatrixSubForm;
                    end;
                }
                action("Previous Set")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Set';
                    Image = PreviousSet;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';


                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Previous);
                        UpdateMatrixSubForm;
                    end;
                }
                action("Previous Column")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Previous Column';
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';


                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::PreviousColumn);
                        UpdateMatrixSubForm;
                    end;
                }
                action("Next Column")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Column';
                    Image = NextRecord;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';


                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::NextColumn);
                        UpdateMatrixSubForm;
                    end;
                }
                action("Next Set")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Next Set';
                    Image = NextSet;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';


                    trigger OnAction()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Next);
                        UpdateMatrixSubForm;
                    end;
                }
            }
        }
        area(navigation)
        {
            action(Forecast)
            {
                ToolTip = 'Navigate to Admission Forecast.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Forecast';
                Ellipsis = true;
                Image = Forecast;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Forecast Matrix";

            }
        }
    }

    trigger OnInit()
    begin

        LineFactOption := 0;
        ColumnFactOption := 1;

        //-TM1.28 [304216]
        //PeriodType := PeriodType::Month;
        PeriodType := PeriodType::Day;
        //+TM1.28 [304216]

        SetAutoFilterOnBlockedFacts();

        CalcVerticalTotal();
    end;

    trigger OnOpenPage()
    begin

        TicketAccessStatisticsMgr.BuildCompressedStatistics(Today);

        FindPeriod('');
        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
        UpdateMatrixSubForm;
    end;

    var
        MATRIX_MatrixRecords: array[32] of Record "Dimension Code Buffer";
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_CaptionRange: Text[250];
        MATRIX_PrimKeyFirstCaptionInCu: Text[80];
        MATRIX_CurrentNoOfColumns: Integer;
        MATRIX_Step: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        TicketAccessStatisticsMgr: Codeunit "NPR TM Ticket Access Stats";
        LineFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        ColumnFactOption: Option ITEM,TICKET_TYPE,ADMISSION_DATE,ADMISSION_HOUR,PERIOD,ADMISSION_CODE,VARIANT_CODE;
        FactNameAsColumnHeading: Boolean;
        HideLinesWithZeroAdmissionCount: Boolean;
        ItemFactFilter: Text[1024];
        TicketTypeFactFilter: Text[1024];
        DateFactFilter: Text[1024];
        HourFactFilter: Text[1024];
        AdmissionCodeFilter: Text[1024];
        VariantCodeFilter: Text[1024];
        DisplayOption: Option "COUNT",COUNT_TREND,TREND;
        TrendPeriodType: Option PERIOD,YEAR;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        TicketStatistics_delete: Record "NPR TM Ticket Access Stats";
        TicketStatisticsFilter: Record "NPR TM Ticket Access Stats";
        InternalDateFilter: Text[30];
        LineFactCode: Code[20];
        ColumnFactCode: Code[20];
        VerticalTotalText: Text[30];
        INVALID_FACTOPTION: Label 'Invalid FactOption';
        BlockedItemFactFilter: Text;
        BlockedAdmissionFactFilter: Text;
        BlockedTicketTypeFactFilter: Text;
        BlockedHourFactFilter: Text;
        BlockedVariantFactFilter: Text;
        AdmissionDefinition: Option ADMITTED_COUNT,ADMITTED_REVOKED_COUNT,ADMITTED_REVIST;

    procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
        MATRIX_PeriodRecords: array[32] of Record Date;
        i: Integer;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TicketFact: Record "NPR TM Ticket Access Fact";
        ColumnFieldNo: Integer;
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
                //-TM1.36 [323024]
                ColumnFactOption::VARIANT_CODE:
                    begin
                        FieldRef.SetFilter('%1', TicketFact."Fact Name"::VARIANT_CODE);
                        if ((VariantCodeFilter <> '') or (BlockedVariantFactFilter <> '')) then begin
                            FieldRef := RecRef.FieldIndex(2);
                            FieldRef.SetFilter(FilterAndFilter(VariantCodeFilter, BlockedVariantFactFilter));
                        end;
                    end;
                //+TM1.36 [323024]

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

    local procedure FindPeriod(SearchText: Code[10])
    var
        Item: Record Item;
        Calendar: Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
        Date1: Date;
        Date2: Date;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
    begin

        if (DateFactFilter <> '') then begin
            Calendar.SetFilter("Period Start", DateFactFilter);

            if (not PeriodFormMgt.FindDate('-', Calendar, PeriodType)) then
                PeriodFormMgt.FindDate('-', Calendar, PeriodType::Day);

            Calendar.SetRange("Period Start");
        end;

        if Calendar."Period Start" = 0D then
            Calendar."Period Start" := Today;  //-+TM1.28 [304216] Calendar."Period Start" := CALCDATE ('<-1D>', WORKDATE);

        PeriodFormMgt.FindDate(SearchText, Calendar, PeriodType);
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
        //-#341289 [341289]
        // CurrPage.MATRIX.PAGE.SetFilters (ItemFactFilter, TicketTypeFactFilter, DateFactFilter, HourFactFilter, AdmissionCodeFilter, VariantCodeFilter,
        //  BlockedItemFactFilter, BlockedTicketTypeFactFilter, '', BlockedHourFactFilter, BlockedAdmissionFactFilter, BlockedVariantFactFilter);

        CurrPage.MATRIX.PAGE.SetFilters(
          ItemFactFilter, TicketTypeFactFilter, DateFactFilter, HourFactFilter, AdmissionCodeFilter, VariantCodeFilter,
          BlockedItemFactFilter, BlockedTicketTypeFactFilter, '', BlockedHourFactFilter, BlockedAdmissionFactFilter, BlockedVariantFactFilter,
          HideLinesWithZeroAdmissionCount);
        //+#341289 [341289]

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
        //-TM1.36 [323024]
        TicketStatisticsFilter.SetFilter("Variant Code Filter", FilterAndFilter(VariantCodeFilter, BlockedVariantFactFilter));
        //+TM1.36 [323024]

        CalcVerticalTotal();
        CurrPage.Update(false);
    end;

    procedure FactLookup(FactOption: Option; var FactFilter: Text[1024]): Boolean
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
                Error(INVALID_FACTOPTION);
        end;
        TicketFact.FilterGroup(0);

        FactList.LookupMode(true);
        FactList.SetTableView(TicketFact);
        FactList.SetSelection(TicketFact);

        if FactList.RunModal = ACTION::LookupOK then begin
            FactFilter := FactList.GetSelectionFilter;
            UpdateMatrixSubForm();
            exit(true);
        end;
    end;

    local procedure CalcVerticalTotal()
    var
        MatrixPeriod: Text[100];
    begin

        MatrixPeriod := DateFactFilter;
        VerticalTotalText := Format(TicketAccessStatisticsMgr.CalcVerticalTotal(LineFactOption, ColumnFactOption, TicketStatisticsFilter, MatrixPeriod, AdmissionDefinition));
    end;

    local procedure SetAutoFilterOnBlockedFacts()
    var
        TicketAccessFact: Record "NPR TM Ticket Access Fact";
    begin

        TicketAccessFact.SetFilter(Block, '=%1', true);
        if (TicketAccessFact.FindSet()) then begin
            repeat
                case TicketAccessFact."Fact Name" of

                    TicketAccessFact."Fact Name"::TICKET_TYPE:
                        if (BlockedTicketTypeFactFilter = '') then
                            BlockedTicketTypeFactFilter := StrSubstNo('<>%1', TicketAccessFact."Fact Code")
                        else
                            BlockedTicketTypeFactFilter := StrSubstNo('%1&<>%2', BlockedTicketTypeFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ADMISSION_CODE:
                        if (BlockedAdmissionFactFilter = '') then
                            BlockedAdmissionFactFilter := StrSubstNo('<>%1', TicketAccessFact."Fact Code")
                        else
                            BlockedAdmissionFactFilter := StrSubstNo('%1&<>%2', BlockedAdmissionFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ITEM:
                        if (BlockedItemFactFilter = '') then
                            BlockedItemFactFilter := StrSubstNo('<>%1', TicketAccessFact."Fact Code")
                        else
                            BlockedItemFactFilter := StrSubstNo('%1&<>%2', BlockedItemFactFilter, TicketAccessFact."Fact Code");

                    TicketAccessFact."Fact Name"::ADMISSION_HOUR:
                        if (BlockedHourFactFilter = '') then
                            BlockedHourFactFilter := StrSubstNo('<>%1', TicketAccessFact."Fact Code")
                        else
                            BlockedHourFactFilter := StrSubstNo('%1&<>%2', BlockedHourFactFilter, TicketAccessFact."Fact Code");

                    //-TM1.36 [323024]
                    TicketAccessFact."Fact Name"::VARIANT_CODE:
                        if (BlockedVariantFactFilter = '') then
                            BlockedVariantFactFilter := StrSubstNo('<>%1', TicketAccessFact."Fact Code")
                        else
                            BlockedVariantFactFilter := StrSubstNo('%1&<>%2', BlockedVariantFactFilter, TicketAccessFact."Fact Code");
                //+TM1.36 [323024]
                end;
            until (TicketAccessFact.Next() = 0);
        end;
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
}

