report 6059900 "NPR Analyse Task Queue Usg."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Analyse Task Queue Usage.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Analyse Task Queue Usage';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Task Log (Task)"; "NPR Task Log (Task)")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "Starting Time", "Ending Time", "User ID";
            column(StartingTime; TempDateTimeGroup."Starting Time")
            {
            }
            column(EndingTime; TempDateTimeGroup."Ending Time")
            {
            }
            column(ObjectNoChangeCoompanies; TempDateTimeGroup."Object No.")
            {
            }
            column(TaskDuration; FormatDuration(TempDateTimeGroup."Task Duration"))
            {
            }
            column(Utilization; CalcUtilization(TempDateTimeGroup))
            {
            }

            trigger OnPreDataItem()
            begin
                BuildGroupTable("Task Log (Task)".GetRangeMin("Starting Time"), "Task Log (Task)".GetRangeMax("Ending Time"));
                CurrReport.Break();
            end;
        }
        dataitem(Company; Company)
        {
            DataItemTableView = SORTING(Name);
            RequestFilterFields = Name;

            trigger OnAfterGetRecord()
            begin
                LastDateTime := CreateDateTime(DMY2Date(31, 12, 9999), 0T);

                Dia.Update(1, Name);
                TempDateTimeGroup.Reset();
                if TempDateTimeGroup.IsEmpty() then
                    CurrReport.Break();

                TaskLog.Reset();
                TaskLog.ChangeCompany(Company.Name);
                TaskLog.SetRange("Entry Type", TaskLog."Entry Type"::Task);
                "Task Log (Task)".CopyFilter("User ID", TaskLog."User ID");

                //tasklog must be within the current period meaning if you like a report from 10:00 to 11:00
                //the endtime must be after 10:00 (endtime can be after 11:00, but newer before 10:00)
                //and the starttime must be before 11:00 (Starttime can be before 10, but newer after 11)
                //
                TempDateTimeGroup.FindFirst();
                TaskLog.SetFilter("Ending Time", '>%1', TempDateTimeGroup."Starting Time");
                TempDateTimeGroup.FindLast();
                TaskLog.SetFilter("Starting Time", '<%1', TempDateTimeGroup."Ending Time");

                if TaskLog.FindSet() then
                    repeat
                        Dia.Update(2, TaskLog."Entry No.");
                        TempDateTimeGroup.SetRange("Starting Time", 0DT, TaskLog."Ending Time");
                        TempDateTimeGroup.SetRange("Ending Time", TaskLog."Starting Time", LastDateTime);
                        if TempDateTimeGroup.FindSet() then
                            repeat
                                case true of
                                    //start and end time within current group
                                    (TaskLog."Starting Time" > TempDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" < TempDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TempDateTimeGroup."Entry No.", TaskLog."Starting Time", TaskLog."Ending Time", TaskLog);
                                            TempDateTimeGroup."Task Duration" += TaskLog."Ending Time" - TaskLog."Starting Time";
                                        end;
                                    //start time within current group, endtime after
                                    (TaskLog."Starting Time" > TempDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" > TempDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TempDateTimeGroup."Entry No.", TaskLog."Starting Time", TempDateTimeGroup."Ending Time", TaskLog);
                                            TempDateTimeGroup."Task Duration" += TempDateTimeGroup."Ending Time" - TaskLog."Starting Time";
                                        end;
                                    //start time before current group, end time within current group
                                    (TaskLog."Starting Time" < TempDateTimeGroup."Starting Time") and
                                    (TaskLog."Ending Time" < TempDateTimeGroup."Ending Time"):
                                        begin
                                            InsertTmpTQ(TempDateTimeGroup."Entry No.", TempDateTimeGroup."Starting Time", TaskLog."Ending Time", TaskLog);
                                            TempDateTimeGroup."Task Duration" += TaskLog."Ending Time" - TempDateTimeGroup."Starting Time";
                                        end;
                                    //start and end time before and after current group
                                    else begin
                                            InsertTmpTQ(TempDateTimeGroup."Entry No.", TempDateTimeGroup."Starting Time", TempDateTimeGroup."Ending Time", TaskLog);
                                            TempDateTimeGroup."Task Duration" += TempDateTimeGroup."Ending Time" - TempDateTimeGroup."Starting Time";
                                        end;

                                end;
                                TempDateTimeGroup.Modify();
                            until TempDateTimeGroup.Next() = 0;
                    until TaskLog.Next() = 0;

                //no of changecompanies
                TaskLog.SetRange("Entry Type", TaskLog."Entry Type"::ChangeComp);
                TempDateTimeGroup.Reset();
                TempDateTimeGroup.FindLast();
                LastDateTime := TempDateTimeGroup."Ending Time";

                TempDateTimeGroup.FindFirst();
                TaskLog.SetRange("Starting Time", TempDateTimeGroup."Starting Time", LastDateTime);
                TaskLog.SetRange("Ending Time");

                if TaskLog.FindSet() then
                    repeat
                        TempDateTimeGroup.SetRange("Starting Time", 0DT, TaskLog."Starting Time");
                        TempDateTimeGroup.SetRange("Ending Time", TaskLog."Starting Time", LastDateTime);
                        if TempDateTimeGroup.FindFirst() then begin
                            TempDateTimeGroup."Task Duration" += 3000;//approx time for comp switch
                            TempDateTimeGroup."Object No." += 1;
                            TempDateTimeGroup.Modify();
                        end;
                    until TaskLog.Next() = 0;
            end;

            trigger OnPostDataItem()
            begin
                Dia.Close();
            end;

            trigger OnPreDataItem()
            begin
                Dia.Open(CompanyLbl + '\' + GroupLbl);
            end;
        }
        dataitem(Header; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(Number_Header; Header.Number)
            {
            }
            column(StartingTime_Header; TempDateTimeGroup."Starting Time")
            {
            }
            column(EndingTime_Header; TempDateTimeGroup."Ending Time")
            {
            }
            column(ObjectNoChangeCoompanies_Header; TempDateTimeGroup."Object No.")
            {
            }
            column(TaskDuration_Header; FormatDuration(TempDateTimeGroup."Task Duration"))
            {
            }
            column(Utilization_Header; CalcUtilization(TempDateTimeGroup))
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
                column(Company_Lines; TempTaskQueue.Company)
                {
                }
                column(Duration_Lines; FormatDuration(TempTaskQueue."Estimated Duration"))
                {
                }
                column(AssignedToUser_Lines; TempTaskQueue."Assigned To User")
                {
                }
                column(StartTime_Lines; Format(TempTaskQueue."Started Time", 0, 3))
                {
                }
                column(EndTime_Lines; Format(TempTaskQueue."Assigned Time", 0, 3))
                {
                }
                column(ObjectTime_Lines; TempTaskQueue."Object Type")
                {
                }
                column(ObjectNo_Lines; TempTaskQueue."Object No.")
                {
                }
                column(LastExecutionStatus_Lines; TempTaskQueue."Last Execution Status")
                {
                    OptionCaption = ' ,Started,Error,Succes,Message';
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempTaskQueue.FindFirst()
                    else
                        TempTaskQueue.Next();
                end;

                trigger OnPreDataItem()
                begin
                    case true of
                        ShowLines = ShowLines::UtilizationPct:
                            begin
                                if WarningLevel > CalcUtilization(TempDateTimeGroup) then
                                    CurrReport.Break();
                            end;
                        ShowLines = ShowLines::None:
                            CurrReport.Break();
                    end;
                    TempTaskQueue.Reset();
                    TempTaskQueue.SetCurrentKey("Next Run time");
                    TempTaskQueue.SetRange("Task Template", Format(TempDateTimeGroup."Entry No."));
                    SetRange(Number, 1, TempTaskQueue.Count());
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempDateTimeGroup.FindFirst()
                else
                    TempDateTimeGroup.Next();

                ShowHeader1 := (WarningLevel > CalcUtilization(TempDateTimeGroup));
                ShowLinesHeader := (WarningLevel <= CalcUtilization(TempDateTimeGroup));
            end;

            trigger OnPreDataItem()
            begin
                TempDateTimeGroup.Reset();
                SetRange(Number, 1, TempDateTimeGroup.Count());
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
                field("Group By"; GroupBy)
                {

                    Caption = 'Group By:';
                    OptionCaption = 'Quarter,Hour,Day';
                    ToolTip = 'Specifies the value of the Group By: field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Lines"; ShowLines)
                {

                    Caption = 'Show Lines';
                    OptionCaption = 'None,UtilizationPct,All';
                    ToolTip = 'Specifies the value of the Show Lines field';
                    ApplicationArea = NPRRetail;
                }
                field("Warning Level"; WarningLevel)
                {

                    Caption = 'Show Warning';
                    ToolTip = 'Specifies the value of the Show Warning field';
                    ApplicationArea = NPRRetail;
                }
            }
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
        TaskLog: Record "NPR Task Log (Task)";
        TempDateTimeGroup: Record "NPR Task Log (Task)" temporary;
        TempTaskQueue: Record "NPR Task Queue" temporary;
        ShowHeader1: Boolean;
        ShowLinesHeader: Boolean;
        LastDateTime: DateTime;
        WarningLevel: Decimal;
        Dia: Dialog;
        CompanyLbl: Label 'Company #1###################';
        GroupLbl: Label 'Group #2################';
        ShowLines: Option "None",UtilizationPct,All;
        GroupBy: Option Quarter,Hour,Day;

    procedure BuildGroupTable(StartDateTime: DateTime; EndDateTime: DateTime)
    var
        PeriodStartTime: DateTime;
        Dur: Duration;
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
            TempDateTimeGroup."Entry No." := Counter;
            TempDateTimeGroup."Starting Time" := PeriodStartTime;
            TempDateTimeGroup."Ending Time" := PeriodStartTime + Dur - 1;
            TempDateTimeGroup.Insert();
            PeriodStartTime += Dur;
        end;
    end;

    procedure InsertTmpTQ(Group: Integer; StartTime: DateTime; EndTime: DateTime; TaskLog: Record "NPR Task Log (Task)")
    begin
        TempTaskQueue.Company := Company.Name;
        TempTaskQueue."Task Template" := Format(Group);
        TempTaskQueue."Task Line No." := TaskLog."Entry No.";
        TempTaskQueue."Next Run time" := StartTime;
        TempTaskQueue."Estimated Duration" := EndTime - StartTime;
        TempTaskQueue."Started Time" := StartTime;
        TempTaskQueue."Assigned Time" := EndTime;
        TempTaskQueue."Assigned To User" := TaskLog."User ID";
        TempTaskQueue."Object Type" := TaskLog."Object Type";
        TempTaskQueue."Object No." := TaskLog."Object No.";
        TempTaskQueue."Last Execution Status" := TaskLog.Status;
        TempTaskQueue.Insert();
    end;

    procedure FormatDuration(DurIn: Duration): Text[30]
    var
        Hours: Integer;
        "Min": Integer;
        Sec: Integer;
        MinTxt: Text;
        SecTxt: Text;
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
        DivBy: Integer;
        Int: Integer;
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

