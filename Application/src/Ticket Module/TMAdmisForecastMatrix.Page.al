page 6151135 "NPR TM Admis. Forecast Matrix"
{
    Extensible = False;
    // TM1.48/TSA /20200625 CASE 409741 Initial Version

    Caption = 'Admission Forecast Matrix';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Ticket Forecast';

    layout
    {
        area(content)
        {
            group(Control6014401)
            {
                ShowCaption = false;
                field(AdmissionCode; PageAdmissionCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Admission Code';
                    TableRelation = "NPR TM Admission";
                    ToolTip = 'Specifies the value of the Admission Code field';

                    trigger OnValidate()
                    begin

                        MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                        MATRIX_UpdateSubpage();
                    end;
                }
                group(Control6014405)
                {
                    ShowCaption = false;
                    field(DisplayOption; PageStatisticsOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Display Option';
                        OptionCaption = 'Sales,Reservations,Utilization Pct.,Capacity Pct.';
                        ToolTip = 'Specifies the value of the Display Option field';

                        trigger OnValidate()
                        begin

                            MATRIX_UpdateSubpage();
                        end;
                    }
                    field(Periodtype; PagePeriodOption)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Periodtype';
#if BC17 or BC18
                        OptionCaption = 'Actual,Day,Week,Month,Quarter,Year';
#endif
                        ToolTip = 'Specifies the value of the Periodtype field';

                        trigger OnValidate()
                        begin

                            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
                            MATRIX_UpdateSubpage();
                        end;
                    }
                }
            }
            part(MATRIX; "NPR TM Admis. Forecast Lines")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Previous Set")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Previous Set';

                trigger OnAction()
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Previous);
                    MATRIX_UpdateSubpage();
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Previous Set';

                trigger OnAction()
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::PreviousColumn);
                    MATRIX_UpdateSubpage();
                end;
            }
            action("Next Column")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Next Set';

                trigger OnAction()
                begin

                    MATRIX_GenerateColumnCaptions(MATRIX_Step::NextColumn);
                    MATRIX_UpdateSubpage();
                end;
            }
            action("Next Set")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Next Set';

                trigger OnAction()
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Next);
                    MATRIX_UpdateSubpage();
                end;
            }

            action(Statistics)
            {
                ToolTip = 'Navigate to Ticket Statistics';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Statistics';
                Image = Statistics;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
            }
        }
    }

    trigger OnOpenPage()
    begin

        if (PageAdmissionCode <> '') then begin
            MATRIX_GenerateColumnCaptions(MATRIX_Step::Initial);
            MATRIX_UpdateSubpage();
        end;
    end;

    var
        PageAdmissionCode: Code[20];
        PageStatisticsOption: Option INITIAL,RESERVATION,UTILIZATION_PCT,CAPACITY_PCT;
#if BC17 or BC18
        PagePeriodOption: Option ACTUAL,DAY,WEEK,MONTH,QUARTER,YEAR;
#else
        PagePeriodOption: Enum "Analysis Period Type";
#endif
        MATRIX_MatrixRecords: array[32] of Record "NPR TM Admis. Schedule Entry";
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_CaptionRange: Text;
        MATRIX_PrimKeyFirstCaptionInCu: Text;
        MATRIX_CurrentNoOfColumns: Integer;
        MATRIX_Step: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";

    procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
        MATRIX_PeriodRecords: array[32] of Record Date;
        i: Integer;
        RecRef: RecordRef;
        TempAdmSchEntry: Record "NPR TM Admis. Schedule Entry" temporary;
    begin

        Clear(MATRIX_CaptionSet);
        Clear(MATRIX_MatrixRecords);
        MATRIX_CurrentNoOfColumns := 12;

        if (MATRIX_SetWanted = MATRIX_SetWanted::Initial) then
            MATRIX_PrimKeyFirstCaptionInCu := '';

#if BC17 or BC18
        if (PagePeriodOption = PagePeriodOption::ACTUAL) then begin
#else
        if (PagePeriodOption = PagePeriodOption::"Accounting Period") then begin
#endif
            TempAdmSchEntry.Reset();
            if (TempAdmSchEntry.IsTemporary()) then TempAdmSchEntry.DeleteAll();

            // Find all dates this admission has time slots
            AdmSchEntry.SetFilter("Admission Code", '=%1', PageAdmissionCode);
            AdmSchEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmSchEntry.FindSet()) then begin
                repeat
                    TempAdmSchEntry.SetFilter("Admission Start Date", '=%1', AdmSchEntry."Admission Start Date");
                    if (TempAdmSchEntry.IsEmpty()) then begin
                        TempAdmSchEntry.TransferFields(AdmSchEntry, true);
                        TempAdmSchEntry.Insert();
                    end;
                until (AdmSchEntry.Next() = 0);
            end;

            if (TempAdmSchEntry.IsEmpty()) then
                exit;

            TempAdmSchEntry.Reset();
            RecRef.GetTable(TempAdmSchEntry);
            RecRef.SetTable(TempAdmSchEntry);

            TempAdmSchEntry.Reset();
            TempAdmSchEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            TempAdmSchEntry.SetFilter("Admission Start Date", '>=%1', Today);

            if (not TempAdmSchEntry.FindFirst()) then begin
                TempAdmSchEntry.Reset();
                if (TempAdmSchEntry.Find('+')) then
                    i := TempAdmSchEntry.Next(-MATRIX_CurrentNoOfColumns + 1);
            end;

            TempAdmSchEntry.Reset();
            if (MATRIX_PrimKeyFirstCaptionInCu = '') then begin
                MATRIX_PrimKeyFirstCaptionInCu := TempAdmSchEntry.GetPosition();
                RecRef.SetPosition(MATRIX_PrimKeyFirstCaptionInCu);
                MATRIX_SetWanted := MATRIX_SetWanted::Same;
            end;

            MatrixMgt.GenerateMatrixData(
              RecRef, MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, TempAdmSchEntry.FieldNo("Admission Start Date"),
              MATRIX_PrimKeyFirstCaptionInCu, MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns);

            for i := 1 to MATRIX_CurrentNoOfColumns do begin
                MATRIX_MatrixRecords[i]."Admission Code" := PageAdmissionCode;
                Evaluate(MATRIX_MatrixRecords[i]."Admission Start Date", MATRIX_CaptionSet[i]);
            end;

        end else begin

#if BC17 or BC18
            MatrixMgt.GeneratePeriodMatrixData(
              MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, false,
              PagePeriodOption - 1, '', MATRIX_PrimKeyFirstCaptionInCu,
              MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns, MATRIX_PeriodRecords);
#else
            MatrixMgt.GeneratePeriodMatrixData(
              MATRIX_SetWanted, MATRIX_CurrentNoOfColumns, false,
              PagePeriodOption, '', MATRIX_PrimKeyFirstCaptionInCu,
              MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrentNoOfColumns, MATRIX_PeriodRecords);
#endif

            for i := 1 to MATRIX_CurrentNoOfColumns do begin
                MATRIX_MatrixRecords[i]."Admission Code" := PageAdmissionCode;
                MATRIX_MatrixRecords[i]."Admission Start Date" := MATRIX_PeriodRecords[i]."Period Start";
                MATRIX_MatrixRecords[i]."Admission End Date" := MATRIX_PeriodRecords[i]."Period End";
            end;

        end;
    end;

    local procedure MATRIX_UpdateSubpage()
    begin

        CurrPage.MATRIX.PAGE.Load(
          MATRIX_CaptionSet,
          MATRIX_MatrixRecords,
          MATRIX_CurrentNoOfColumns,
          PageStatisticsOption, PagePeriodOption);

        CurrPage.Update(false);
    end;

    procedure SetInitialAdmissionCode(AdmissionCode: Code[20])
    begin

        PageAdmissionCode := AdmissionCode;
    end;
}

