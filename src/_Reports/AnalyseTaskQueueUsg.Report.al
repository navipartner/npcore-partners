report 6059900 "NPR Analyse Task Queue Usg."
{
    // TQ1.25/JDH/20150504 CASE ?????? versioned for release     g
    // TQ1.28/RMT/20150825 CASE 185346 Updated by TR and included in release
    // TQ1.32/TJ /20180319 CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Analyse Task Queue Usage.rdlc';

    Caption = 'Analyse Task Queue Usage';

    dataset
    {
        dataitem("Task Log (Task)"; "NPR Task Log (Task)")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "Starting Time", "Ending Time", "User ID";
            column(StartingTime; TMPDateTimeGroup."Starting Time")
            {
            }
            column(EndingTime; TMPDateTimeGroup."Ending Time")
            {
            }
            column(ObjectNoChangeCoompanies; TMPDateTimeGroup."Object No.")
            {
            }
            column(TaskDuration; FormatDuration(TMPDateTimeGroup."Task Duration"))
            {
            }
            column(Utilization; CalcUtilization(TMPDateTimeGroup))
            {
            }

            trigger OnPreDataItem()
            begin
                BuildGroupTable("Task Log (Task)".GetRangeMin("Starting Time"), "Task Log (Task)".GetRangeMax("Ending Time"));
                CurrReport.Break;
            end;
        }
        dataitem(Company; Company)
        {
            DataItemTableView = SORTING(Name);
            RequestFilterFields = Name;

            trigger OnAfterGetRecord()
            begin
                //-TQ1.32 [307717]
                //LastDateTime := CREATEDATETIME(31129999D,0T);
                LastDateTime := CreateDateTime(DMY2Date(31, 12, 9999), 0T);
                //+TQ1.32 [307717]

                Dia.Update(1, Name);
                TMPDateTimeGroup.Reset;
                if not TMPDateTimeGroup.FindFirst then
                    CurrReport.Break;

                TaskLog.Reset;
                TaskLog.ChangeCompany(Company.Name);
                TaskLog.SetRange("Entry Type", TaskLog."Entry Type"::Task);
                "Task Log (Task)".CopyFilter("User ID", TaskLog."User ID");

                //tasklog must be within the current period meaning if you like a report from 10:00 to 11:00
                //the endtime must be after 10:00 (endtime can be after 11:00, but newer before 10:00)
                //and the starttime must be before 11:00 (Starttime can be before 10, but newer after 11)
                //
                TMPDateTimeGroup.FindFirst;
                TaskLog.SetFilter("Ending Time", '>%1', TMPDateTimeGroup."Starting Time");
                TMPDateTimeGroup.FindLast;
                TaskLog.SetFilter("Starting Time", '<%1', TMPDateTimeGroup."Ending Time");

                if TaskLog.FindSet then
                    repeat
                        Dia.Update(2, TaskLog."Entry No.");
                        TMPDateTimeGroup.SetRange("Starting Time", 0DT, TaskLog."Ending Time");
                        TMPDateTimeGroup.SetRange("Ending Time", TaskLog."Starting Time", LastDateTime);
                        if TMPDateTimeGroup.FindSet then
                            repeat
                                case true of
                                    //start and end time within current group
                                    (TaskLog."Starting Time" > TMPDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" < TMPDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TMPDateTimeGroup."Entry No.", TaskLog."Starting Time", TaskLog."Ending Time", TaskLog);
                                            TMPDateTimeGroup."Task Duration" += TaskLog."Ending Time" - TaskLog."Starting Time";
                                        end;
                                    //start time within current group, endtime after
                                    (TaskLog."Starting Time" > TMPDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" > TMPDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TMPDateTimeGroup."Entry No.", TaskLog."Starting Time", TMPDateTimeGroup."Ending Time", TaskLog);
                                            TMPDateTimeGroup."Task Duration" += TMPDateTimeGroup."Ending Time" - TaskLog."Starting Time";
                                        end;
                                    //start time before current group, end time within current group
                                    (TaskLog."Starting Time" < TMPDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" < TMPDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TMPDateTimeGroup."Entry No.", TMPDateTimeGroup."Starting Time", TaskLog."Ending Time", TaskLog);
                                            TMPDateTimeGroup."Task Duration" += TaskLog."Ending Time" - TMPDateTimeGroup."Starting Time";
                                        end;
                                    //start and end time before and after current group
                                    else begin
                                            InsertTmpTQ(TMPDateTimeGroup."Entry No.", TMPDateTimeGroup."Starting Time", TMPDateTimeGroup."Ending Time", TaskLog);
                                            TMPDateTimeGroup."Task Duration" += TMPDateTimeGroup."Ending Time" - TMPDateTimeGroup."Starting Time";
                                        end;

                                end;
                                TMPDateTimeGroup.Modify;
                            until TMPDateTimeGroup.Next = 0;
                    until TaskLog.Next = 0;

                //no of changecompanies
                TaskLog.SetRange("Entry Type", TaskLog."Entry Type"::ChangeComp);
                TMPDateTimeGroup.Reset;
                TMPDateTimeGroup.FindLast;
                LastDateTime := TMPDateTimeGroup."Ending Time";

                TMPDateTimeGroup.FindFirst;
                TaskLog.SetRange("Starting Time", TMPDateTimeGroup."Starting Time", LastDateTime);
                TaskLog.SetRange("Ending Time");

                if TaskLog.FindSet then
                    repeat
                        TMPDateTimeGroup.SetRange("Starting Time", 0DT, TaskLog."Starting Time");
                        TMPDateTimeGroup.SetRange("Ending Time", TaskLog."Starting Time", LastDateTime);
                        if TMPDateTimeGroup.FindFirst then begin
                            TMPDateTimeGroup."Task Duration" += 3000;//approx time for comp switch
                            TMPDateTimeGroup."Object No." += 1;
                            TMPDateTimeGroup.Modify;
                        end;
                    until TaskLog.Next = 0;


                /*virker men er langsom - pr¢ver at vende den om
                IF TMPDateTimeGroup.FINDSET THEN REPEAT
                  Dia.UPDATE(2, TMPDateTimeGroup."No.");
                  //find entries starting before this period start, and ends after this period ends
                  TaskLog.SETFILTER("Starting Time", '<%1', TMPDateTimeGroup."Starting Date-Time");
                  TaskLog.SETFILTER("Ending Time", '>%1', TMPDateTimeGroup."Ending Date-Time");
                  IF TaskLog.FINDSET THEN REPEAT
                    TMPTaskQueue.Company := Company.Name;
                    TMPTaskQueue."Task Template" := TMPDateTimeGroup."No.";
                    TMPTaskQueue."Task Batch" := TaskLog."Journal Batch Name";
                    TMPTaskQueue."Task Line No." := TaskLog."Entry No.";
                    TMPTaskQueue."Next Run time" := TMPDateTimeGroup."Ending Date-Time";
                  //  TMPTaskQueue.Priority :=
                    TMPTaskQueue."Estimated Duration" := TMPDateTimeGroup."Ending Date-Time" - TMPDateTimeGroup."Starting Date-Time";
                    TMPTaskQueue."Started Time" := TMPDateTimeGroup."Starting Date-Time";
                    TMPTaskQueue."Assigned Time" := TaskLog."Ending Time";
                    TMPTaskQueue."Assigned To User" := TaskLog."User ID";
                    TMPTaskQueue.INSERT;
                  UNTIL TaskLog.NEXT = 0;
                
                  //find entries starting before this period start, and ends in this period ends
                  TaskLog.SETFILTER("Starting Time", '<%1', TMPDateTimeGroup."Starting Date-Time");
                  TaskLog.SETFILTER("Ending Time", '>%1&<=%1', TMPDateTimeGroup."Starting Date-Time", TMPDateTimeGroup."Ending Date-Time");
                  IF TaskLog.FINDSET THEN REPEAT
                    TMPTaskQueue.Company := Company.Name;
                    TMPTaskQueue."Task Template" := TMPDateTimeGroup."No.";
                    TMPTaskQueue."Task Batch" := TaskLog."Journal Batch Name";
                    TMPTaskQueue."Task Line No." := TaskLog."Entry No.";
                    TMPTaskQueue."Next Run time" := TaskLog."Ending Time";
                  //  TMPTaskQueue.Priority :=
                    TMPTaskQueue."Estimated Duration" := TaskLog."Ending Time" - TMPDateTimeGroup."Starting Date-Time";
                    TMPTaskQueue."Started Time" := TMPDateTimeGroup."Starting Date-Time";
                    TMPTaskQueue."Assigned Time" := TaskLog."Ending Time";
                    TMPTaskQueue."Assigned To User" := TaskLog."User ID";
                    TMPTaskQueue.INSERT;
                  UNTIL TaskLog.NEXT = 0;
                
                  //find entries starting in this period,  and ends after this period ends
                  TaskLog.SETFILTER("Starting Time", '>%1&<%2', TMPDateTimeGroup."Starting Date-Time", TMPDateTimeGroup."Ending Date-Time");
                  TaskLog.SETFILTER("Ending Time", '>%1', TMPDateTimeGroup."Ending Date-Time");
                  IF TaskLog.FINDSET THEN REPEAT
                    TMPTaskQueue.Company := Company.Name;
                    TMPTaskQueue."Task Template" := TMPDateTimeGroup."No.";
                    TMPTaskQueue."Task Batch" := TaskLog."Journal Batch Name";
                    TMPTaskQueue."Task Line No." := TaskLog."Entry No.";
                    TMPTaskQueue."Next Run time" := TMPDateTimeGroup."Ending Date-Time";
                  //  TMPTaskQueue.Priority :=
                    TMPTaskQueue."Estimated Duration" := TMPDateTimeGroup."Ending Date-Time" - TaskLog."Starting Time";
                    TMPTaskQueue."Started Time" := TaskLog."Starting Time";
                    TMPTaskQueue."Assigned Time" := TaskLog."Ending Time";
                    TMPTaskQueue."Assigned To User" := TaskLog."User ID";
                    TMPTaskQueue.INSERT;
                  UNTIL TaskLog.NEXT = 0;
                
                  //find entries starting in this period,  and ends in this period
                  TaskLog.SETFILTER("Starting Time", '>%1', TMPDateTimeGroup."Starting Date-Time");
                  TaskLog.SETFILTER("Ending Time", '>%1&<=%2', 0DT, TMPDateTimeGroup."Ending Date-Time");
                  IF TaskLog.FINDSET THEN REPEAT
                    TMPTaskQueue.Company := Company.Name;
                    TMPTaskQueue."Task Template" := TMPDateTimeGroup."No.";
                    TMPTaskQueue."Task Batch" := TaskLog."Journal Batch Name";
                    TMPTaskQueue."Task Line No." := TaskLog."Entry No.";
                    TMPTaskQueue."Next Run time" := TaskLog."Ending Time";
                  //  TMPTaskQueue.Priority :=
                    TMPTaskQueue."Estimated Duration" := TaskLog."Ending Time" - TaskLog."Starting Time";
                    TMPTaskQueue."Started Time" := TaskLog."Starting Time";
                    TMPTaskQueue."Assigned Time" := TaskLog."Ending Time";
                    TMPTaskQueue."Assigned To User" := TaskLog."User ID";
                    TMPTaskQueue.INSERT;
                  UNTIL TaskLog.NEXT = 0;
                UNTIL TMPDateTimeGroup.NEXT = 0;
                */

            end;

            trigger OnPostDataItem()
            begin
                Dia.Close;
            end;

            trigger OnPreDataItem()
            begin
                Dia.Open(Text001 + '\' + Text002);
            end;
        }
        dataitem(Header; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(Number_Header; Header.Number)
            {
            }
            column(StartingTime_Header; TMPDateTimeGroup."Starting Time")
            {
            }
            column(EndingTime_Header; TMPDateTimeGroup."Ending Time")
            {
            }
            column(ObjectNoChangeCoompanies_Header; TMPDateTimeGroup."Object No.")
            {
            }
            column(TaskDuration_Header; FormatDuration(TMPDateTimeGroup."Task Duration"))
            {
            }
            column(Utilization_Header; CalcUtilization(TMPDateTimeGroup))
            {
            }
            column(ShowHeader1; ShowHeader1)
            {
            }
            column(ShowLinesHeader; ShowLinesHeader)
            {
            }
            dataitem(Lines; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(Number_Lines; Lines.Number)
                {
                }
                column(Company_Lines; TMPTaskQueue.Company)
                {
                }
                column(Duration_Lines; FormatDuration(TMPTaskQueue."Estimated Duration"))
                {
                }
                column(AssignedToUser_Lines; TMPTaskQueue."Assigned To User")
                {
                }
                column(StartTime_Lines; Format(TMPTaskQueue."Started Time", 0, 3))
                {
                }
                column(EndTime_Lines; Format(TMPTaskQueue."Assigned Time", 0, 3))
                {
                }
                column(ObjectTime_Lines; TMPTaskQueue."Object Type")
                {
                }
                column(ObjectNo_Lines; TMPTaskQueue."Object No.")
                {
                }
                column(LastExecutionStatus_Lines; TMPTaskQueue."Last Execution Status")
                {
                    OptionCaption = ' ,Started,Error,Succes,Message';
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TMPTaskQueue.FindFirst
                    else
                        TMPTaskQueue.Next;
                end;

                trigger OnPreDataItem()
                begin
                    case true of
                        ShowLines = ShowLines::UtilizationPct:
                            begin
                                if WarningLevel > CalcUtilization(TMPDateTimeGroup) then
                                    CurrReport.Break;
                            end;
                        ShowLines = ShowLines::None:
                            CurrReport.Break;
                    end;
                    TMPTaskQueue.Reset;
                    TMPTaskQueue.SetCurrentKey("Next Run time");
                    TMPTaskQueue.SetRange("Task Template", Format(TMPDateTimeGroup."Entry No."));
                    SetRange(Number, 1, TMPTaskQueue.Count);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TMPDateTimeGroup.FindFirst
                else
                    TMPDateTimeGroup.Next;

                ShowHeader1 := (WarningLevel > CalcUtilization(TMPDateTimeGroup));
                ShowLinesHeader := (WarningLevel <= CalcUtilization(TMPDateTimeGroup));
            end;

            trigger OnPreDataItem()
            begin
                TMPDateTimeGroup.Reset;
                SetRange(Number, 1, TMPDateTimeGroup.Count);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(GroupBy; GroupBy)
                {
                    Caption = 'Group By:';
                }
                field(ShowLines; ShowLines)
                {
                    Caption = 'Show Lines';
                }
                field(WarningLevel; WarningLevel)
                {
                    Caption = 'Show Warning';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        StartingDateTime_Cap = 'Starting Date-Time';
        EndingDateTime_Cap = 'Ending Date-Time';
        NoOfChangecompanies_Cap = 'No. of Changecompanies';
        TimeConsumed_Cap = 'Time Consumed';
        Utilisation_Cap = 'Utilization %';
        Company_Cap = 'Company';
        Duration_Cap = 'Duration';
        UserId_Cap = 'User Id';
        StartTime_Cap = 'Start Time';
        EndTime_Cap = 'End Time';
        ObjectType_Cap = 'Object Type';
        ObjectNo_Cap = 'Object No.';
        Status_Cap = 'Status';
    }

    var
        TMPTaskQueue: Record "NPR Task Queue" temporary;
        TaskLog: Record "NPR Task Log (Task)";
        TMPDateTimeGroup: Record "NPR Task Log (Task)" temporary;
        GroupBy: Option Quarter,Hour,Day;
        Dia: Dialog;
        LastDateTime: DateTime;
        ShowLines: Option "None",UtilizationPct,All;
        WarningLevel: Decimal;
        Text001: Label 'Company #1###################';
        Text002: Label 'Group #2################';
        ShowHeader1: Boolean;
        ShowLinesHeader: Boolean;

    procedure BuildGroupTable(StartDateTime: DateTime; EndDateTime: DateTime)
    var
        PeriodStartTime: DateTime;
        Dur: Duration;
        PeriodEndTime: DateTime;
        Counter: Integer;
    begin
        case GroupBy of
            GroupBy::Quarter:
                Dur := 1000 * 60 * 15;
            GroupBy::Hour:
                Dur := 1000 * 60 * 60;
            GroupBy::Day:
                Dur := 1000 * 60 * 60 * 24;
        end;

        PeriodStartTime := StartDateTime;

        while PeriodStartTime < EndDateTime do begin
            Counter += 1;
            TMPDateTimeGroup."Entry No." := Counter;
            TMPDateTimeGroup."Starting Time" := PeriodStartTime;
            TMPDateTimeGroup."Ending Time" := PeriodStartTime + Dur - 1;
            TMPDateTimeGroup.Insert;
            PeriodStartTime += Dur;
        end;
    end;

    procedure InsertTmpTQ(Group: Integer; StartTime: DateTime; EndTime: DateTime; TaskLog: Record "NPR Task Log (Task)")
    begin
        TMPTaskQueue.Company := Company.Name;
        TMPTaskQueue."Task Template" := Format(Group);
        //TMPTaskQueue."Task Batch" := TaskLog."Journal Batch Name";
        TMPTaskQueue."Task Line No." := TaskLog."Entry No.";
        TMPTaskQueue."Next Run time" := StartTime;
        TMPTaskQueue."Estimated Duration" := EndTime - StartTime;
        TMPTaskQueue."Started Time" := StartTime;
        TMPTaskQueue."Assigned Time" := EndTime;
        TMPTaskQueue."Assigned To User" := TaskLog."User ID";
        TMPTaskQueue."Object Type" := TaskLog."Object Type";
        TMPTaskQueue."Object No." := TaskLog."Object No.";
        TMPTaskQueue."Last Execution Status" := TaskLog.Status;
        TMPTaskQueue.Insert;
    end;

    procedure FormatDuration(DurIn: Duration): Text[30]
    var
        Hours: Integer;
        "Min": Integer;
        Sec: Integer;
        MinTxt: Text[30];
        SecTxt: Text[30];
    begin
        if DurIn = 0 then
            exit('');
        Hours := DurIn div (60 * 60 * 1000);
        DurIn := DurIn mod (60 * 60 * 1000);
        Min := DurIn div (60 * 1000);
        DurIn := DurIn mod (60 * 1000);
        Sec := DurIn div (1000);
        if Min < 9 then
            MinTxt := '0';
        MinTxt += Format(Min);

        if Sec < 9 then
            SecTxt := '0';
        SecTxt += Format(Sec);

        exit(Format(Hours) + ':' + MinTxt + ':' + SecTxt);
    end;

    procedure CalcUtilization(TaskLog: Record "NPR Task Log (Task)"): Decimal
    var
        Int: Integer;
        DivBy: Integer;
    begin
        Int := TaskLog."Task Duration";

        case GroupBy of
            GroupBy::Quarter:
                DivBy := 1000 * 60 * 15;
            GroupBy::Hour:
                DivBy := 1000 * 60 * 60;
            GroupBy::Day:
                DivBy := 1000 * 60 * 60 * 24;
        end;

        exit(Int / DivBy * 100);
    end;
}

