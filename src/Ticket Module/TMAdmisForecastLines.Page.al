page 6151139 "NPR TM Admis. Forecast Lines"
{
    // TM1.48/TSA /20200625 CASE 409741 Initial Version

    Caption = 'Admission Forecast Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR TM Admis. Schedule Lines";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = StartTime;
                field("Code"; LINE_Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                }
                field(Description; LINE_Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(StartTime; LINE_StartTime)
                {
                    ApplicationArea = All;
                    Caption = 'Start Time';
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
    begin

        MATRIX_OnAfterGetRecord(MATRIX_MaxNoOfMatrixColumn);
    end;

    var
        MatrixRecords: array[12] of Record "NPR TM Admis. Schedule Entry";
        MATRIX_ColumnTempRec: Record "NPR TM Admis. Schedule Entry";
        MATRIX_MaxNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[12] of Text[80];
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_Step: Option Initial,Previous,Same,Next;
        LINE_Code: Code[20];
        LINE_Description: Text;
        LINE_StartTime: Text;
        PageStatisticsOption: Option INITIAL,RESERVATION,UTILIZATION_PCT,CAPACITY_PCT;
        PagePeriodOption: Option ACTUAL,DAY,WEEK,MONTH,QUARTER,YEAR;

    local procedure MATRIX_OnDrillDown(ColumnOrdinal: Integer)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleEntryPage: Page "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.FilterGroup(2);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Rec."Admission Code");
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', Rec."Schedule Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (PagePeriodOption = PagePeriodOption::ACTUAL) then begin
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', MatrixRecords[ColumnOrdinal]."Admission Start Date");
        end else begin
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..%2', MatrixRecords[ColumnOrdinal]."Admission Start Date", MatrixRecords[ColumnOrdinal]."Admission End Date");
        end;

        AdmissionScheduleEntry.FilterGroup(0);

        AdmissionScheduleEntryPage.SetTableView(AdmissionScheduleEntry);
        AdmissionScheduleEntryPage.Run();
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_NumberOfColumns: Integer)
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        CurrentColumnOrdinal: Integer;
    begin

        LINE_Code := Rec."Schedule Code";
        if (AdmissionSchedule.Get(Rec."Schedule Code")) then;
        LINE_Description := AdmissionSchedule.Description;
        LINE_StartTime := Format(AdmissionSchedule."Start Time");

        CurrentColumnOrdinal := 0;
        while (CurrentColumnOrdinal < MATRIX_NumberOfColumns) do begin
            CurrentColumnOrdinal += 1;
            MATRIX_CellData[CurrentColumnOrdinal] := DisplayCellValue(CurrentColumnOrdinal);

        end;
    end;

    procedure Load(MatrixColumns1: array[32] of Text[80]; var MatrixRecords1: array[12] of Record "NPR TM Admis. Schedule Entry"; CurrentNoOfMatrixColumns: Integer; pStatisticsOption: Option; pPeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period")
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        i: Integer;
    begin

        MATRIX_MaxNoOfMatrixColumn := CurrentNoOfMatrixColumns;
        for i := 1 to 12 do begin
            MATRIX_CaptionSet[i] := MatrixColumns1[i];
            MatrixRecords[i] := MatrixRecords1[i];
            MATRIX_CellData[i] := '';
        end;

        Rec.Reset();
        if (Rec.IsTemporary()) then begin
            Rec.DeleteAll();

            AdmissionScheduleLines.SetFilter("Admission Code", '=%1', MatrixRecords[1]."Admission Code");
            AdmissionScheduleLines.SetFilter(Blocked, '=%1', false);
            if (AdmissionScheduleLines.FindSet()) then begin
                repeat
                    Rec.TransferFields(AdmissionScheduleLines, true);
                    Rec.Insert();
                until (AdmissionScheduleLines.Next() = 0);

                Rec.FindFirst();

            end;
        end;

        PageStatisticsOption := pStatisticsOption;
        PagePeriodOption := pPeriodType;
    end;

    procedure DisplayCellValue(ColumnOrdinal: Integer) CellValue: Text[30]
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        CellSum: Integer;
        CellCapacity: Integer;
    begin

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Rec."Admission Code");
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', Rec."Schedule Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (PagePeriodOption = PagePeriodOption::ACTUAL) then begin
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', MatrixRecords[ColumnOrdinal]."Admission Start Date");
        end else begin
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..%2', MatrixRecords[ColumnOrdinal]."Admission Start Date", MatrixRecords[ColumnOrdinal]."Admission End Date");
        end;

        CellValue := '-';
        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                AdmissionScheduleEntry.CalcFields("Initial Entry", "Open Reservations");

                case PageStatisticsOption of
                    PageStatisticsOption::INITIAL:
                        CellSum += AdmissionScheduleEntry."Initial Entry";
                    PageStatisticsOption::RESERVATION:
                        CellSum += AdmissionScheduleEntry."Open Reservations";
                    PageStatisticsOption::UTILIZATION_PCT, PageStatisticsOption::CAPACITY_PCT:
                        begin
                            CellSum += AdmissionScheduleEntry."Initial Entry";
                            CellCapacity += AdmissionScheduleEntry."Max Capacity Per Sch. Entry";
                        end;

                end;
            until (AdmissionScheduleEntry.Next() = 0);

            case PageStatisticsOption of
                PageStatisticsOption::UTILIZATION_PCT:
                    begin
                        CellValue := '~';
                        if (CellCapacity <> 0) then CellValue := StrSubstNo('%1%', Round(CellSum / CellCapacity * 100, 0.01));
                    end;
                PageStatisticsOption::CAPACITY_PCT:
                    begin
                        CellValue := '100%';
                        if (CellCapacity <> 0) then CellValue := StrSubstNo('%1%', Round(100 - CellSum / CellCapacity * 100, 0.01));
                    end;

                else
                    CellValue := Format(CellSum);
            end;

        end;
    end;
}

