codeunit 6060165 "NPR Event Plan.Line Group. Mgt"
{
    trigger OnRun()
    begin
    end;

    var
        NoDaysSetErr: Label 'You need to set at least one day of the week.';
        RecreateConfirm: Label 'This line will be deleted and recreated. Any related grouping lines will be deleted and recreated per new setup. Do you want to continue?';
        Desc2AsPeriod: Label 'From %1 to %2, total: %3 lines';

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterDeleteEvent', '', true, true)]
    local procedure JobPlanningLineOnAfterDelete(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
        JobPlanningLine.SetRange("NPR Group Source Line No.", Rec."Line No.");
        JobPlanningLine.DeleteAll(true);
    end;

    procedure DistributeAccrossPeriod(var Rec: Record "Job Planning Line")
    var
        NewRec: Record "Job Planning Line";
        JobPlanningLineTemp: Record "Job Planning Line" temporary;
        JobPlanningLineBackupTemp: Record "Job Planning Line" temporary;
        EventPlanLineBuffer: Record "NPR Event Plan. Line Buffer" temporary;
        Date: Record Date;
        EventPeriodDistrDlg: Page "NPR Event Period Distr. Dialog";
        EventPlanLineBufferList: Page "NPR Event Plan. Line Buffer";
        DaysOfWeek: array[7] of Boolean;
        LineNo: Integer;
    begin
        CheckPreconditions(Rec);
        if not Confirm(RecreateConfirm) then
            exit;
        EventPeriodDistrDlg.SetParameters(Rec);
        if EventPeriodDistrDlg.RunModal <> ACTION::OK then
            exit;
        EventPeriodDistrDlg.GetParameters(JobPlanningLineTemp, DaysOfWeek);
        CheckParameters(JobPlanningLineTemp, DaysOfWeek);

        BackupCurrentDistribution(Rec, JobPlanningLineBackupTemp);
        NewRec := Rec;
        Rec.Delete(true);
        Commit; //lines need to be deleted here as InsertBuffer has availability check which must not take current lines -
                //if this process will require changing, will revert back to deleting after last OK is pressed and COMMIT will not be needed
                //but this means that avaialbility check will take current lines into consideration as well
                //this means BackupCurrentDistribution and RestoreOldDistribution will not be needed

        Date.SetRange("Period Type", Date."Period Type"::Date);
        Date.SetRange("Period Start", JobPlanningLineTemp."Planning Date", JobPlanningLineTemp."Planned Delivery Date");
        Date.SetFilter("Period No.", PrepareDaysFilter(DaysOfWeek));
        if Date.FindSet then
            repeat
                LineNo += 10000;
                JobPlanningLineTemp."Planning Date" := Date."Period Start";
                InsertBuffer(JobPlanningLineTemp, LineNo, EventPlanLineBuffer);
            until Date.Next = 0;

        EventPlanLineBuffer.FilterGroup := 2;
        EventPlanLineBuffer.SetRange("Job No.", Rec."Job No.");
        EventPlanLineBuffer.SetRange("Job Task No.", Rec."Job Task No.");
        EventPlanLineBuffer.SetRange("Job Planning Line No.", Rec."Line No.");
        EventPlanLineBuffer.FilterGroup := 0;
        if PAGE.RunModal(PAGE::"NPR Event Plan. Line Buffer", EventPlanLineBuffer) = ACTION::LookupOK then begin
            EventPlanLineBuffer.SetRange("Action Type", EventPlanLineBuffer."Action Type"::Create);
            CreateJobPlanningLineFromBuffer(NewRec, EventPlanLineBuffer);
        end else
            RestoreOldDistribution(JobPlanningLineBackupTemp);
    end;

    local procedure CheckParameters(var JobPlanningLine: Record "Job Planning Line"; DaysOfWeek: array[7] of Boolean)
    var
        i: Integer;
    begin
        //JobPlanningLine is just to remind me to check it if its needed later
        for i := 1 to ArrayLen(DaysOfWeek) do
            if DaysOfWeek[i] then
                exit;
        Error(NoDaysSetErr);
    end;

    local procedure PrepareDaysFilter(DaysOfWeek: array[7] of Boolean) "Filter": Text
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(DaysOfWeek) do
            if DaysOfWeek[i] then
                if Filter = '' then
                    Filter := Format(i)
                else
                    Filter := Filter + '|' + Format(i);
        exit(Filter);
    end;

    local procedure InsertBuffer(var JobPlanningLine: Record "Job Planning Line"; LineNo: Integer; var EventPlanLineBuffer: Record "NPR Event Plan. Line Buffer")
    begin
        EventPlanLineBuffer.Init;
        EventPlanLineBuffer."Job No." := JobPlanningLine."Job No.";
        EventPlanLineBuffer."Job Task No." := JobPlanningLine."Job Task No.";
        EventPlanLineBuffer."Job Planning Line No." := JobPlanningLine."Line No.";
        EventPlanLineBuffer."Line No." := LineNo;
        EventPlanLineBuffer."Planning Date" := JobPlanningLine."Planning Date";
        EventPlanLineBuffer."Starting Time" := JobPlanningLine."NPR Starting Time";
        EventPlanLineBuffer."Ending Time" := JobPlanningLine."NPR Ending Time";
        EventPlanLineBuffer.Quantity := JobPlanningLine.Quantity;
        EventPlanLineBuffer."Unit of Measure Code" := JobPlanningLine."Unit of Measure Code";
        EventPlanLineBuffer.Type := JobPlanningLine.Type.AsInteger();
        EventPlanLineBuffer."No." := JobPlanningLine."No.";
        EventPlanLineBuffer.Insert;
        CheckCapAndTimeAvailability(JobPlanningLine, EventPlanLineBuffer);
        EventPlanLineBuffer.Modify;
    end;

    local procedure CheckCapAndTimeAvailability(var JobPlanningLine: Record "Job Planning Line"; var EventPlanLineBuffer: Record "NPR Event Plan. Line Buffer")
    var
        JobsSetup: Record "Jobs Setup";
        xJobPlanningLineTemp: Record "Job Planning Line" temporary;
        EventMgt: Codeunit "NPR Event Management";
        ReturnMsg: Text;
        OverCapacitateSetup: Integer;
    begin
        JobsSetup.Get();

        EventPlanLineBuffer.TestField("Planning Date");
        EventPlanLineBuffer.TestField("Starting Time");
        EventPlanLineBuffer.TestField("Ending Time");

        EventPlanLineBuffer."Action Type" := EventPlanLineBuffer."Action Type"::Create;
        EventMgt.SetBufferMode();
        if EventPlanLineBuffer.Quantity = 0 then
            ReturnMsg := EventMgt.CheckResTimeFrameAvailability(JobPlanningLine)
        else begin
            xJobPlanningLineTemp := JobPlanningLine;
            xJobPlanningLineTemp.Quantity := 0;
            ReturnMsg := EventMgt.CheckResAvailability(JobPlanningLine, xJobPlanningLineTemp);
        end;
        if ReturnMsg <> '' then begin
            EventPlanLineBuffer."Status Text" := CopyStr(ReturnMsg, 1, MaxStrLen(EventPlanLineBuffer."Status Text"));
            EventMgt.AllowOverCapacitateResource(JobPlanningLine, OverCapacitateSetup);
            case OverCapacitateSetup of
                JobsSetup."NPR Over Capacitate Resource"::Disallow:
                    begin
                        EventPlanLineBuffer."Status Type" := EventPlanLineBuffer."Status Type"::Error;
                        EventPlanLineBuffer."Action Type" := EventPlanLineBuffer."Action Type"::Skip;
                    end;
                JobsSetup."NPR Over Capacitate Resource"::Warn:
                    begin
                        EventPlanLineBuffer."Status Type" := EventPlanLineBuffer."Status Type"::Warning;
                        EventPlanLineBuffer."Action Type" := EventPlanLineBuffer."Action Type"::" ";
                    end;
            end;
        end;
        EventPlanLineBuffer."Status Checked" := true;
    end;

    procedure CheckCapAndTimeAvailabilityOnDemand(var EventPlanLineBuffer: Record "NPR Event Plan. Line Buffer"; WithModify: Boolean)
    var
        JobPlanningLineTemp: Record "Job Planning Line" temporary;
    begin
        JobPlanningLineTemp."Job No." := EventPlanLineBuffer."Job No.";
        JobPlanningLineTemp."Job Task No." := EventPlanLineBuffer."Job Task No.";
        JobPlanningLineTemp.Type := "Job Planning Line Type".FromInteger(EventPlanLineBuffer.Type);
        JobPlanningLineTemp."No." := EventPlanLineBuffer."No.";
        JobPlanningLineTemp."Planning Date" := EventPlanLineBuffer."Planning Date";
        JobPlanningLineTemp."NPR Starting Time" := EventPlanLineBuffer."Starting Time";
        JobPlanningLineTemp."NPR Ending Time" := EventPlanLineBuffer."Ending Time";
        JobPlanningLineTemp.Quantity := EventPlanLineBuffer.Quantity;
        JobPlanningLineTemp."Unit of Measure Code" := EventPlanLineBuffer."Unit of Measure Code";
        CheckCapAndTimeAvailability(JobPlanningLineTemp, EventPlanLineBuffer);
        if WithModify then
            EventPlanLineBuffer.Modify;
    end;

    procedure CalcTimeQty(StartTime: Time; EndTime: Time; var Quantity: Decimal)
    begin
        if (StartTime <> 0T) and (EndTime <> 0T) then
            Quantity := (EndTime - StartTime) / 3600000;
    end;

    local procedure CheckPreconditions(Rec: Record "Job Planning Line")
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        Rec.TestField(Type, Rec.Type::Resource);
        Rec.TestField("No.");
        Rec.TestField("Planning Date", 0D);
        Rec.TestField("NPR Starting Time", 0T);
        Rec.TestField("NPR Ending Time", 0T);
        Rec.TestField(Quantity, 0);
        Rec.TestField("Qty. Invoiced", 0);

        if Rec."NPR Group Line" then begin
            JobPlanningLine.SetRange("Job No.", Rec."Job No.");
            JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
            JobPlanningLine.SetRange("NPR Group Source Line No.", Rec."Line No.");
            if JobPlanningLine.FindSet then
                repeat
                    JobPlanningLine.TestField("Qty. Transferred to Invoice", 0);
                    JobPlanningLine.TestField("Qty. Invoiced", 0);
                until JobPlanningLine.Next = 0;
        end;
    end;

    local procedure CreateJobPlanningLineFromBuffer(var Rec: Record "Job Planning Line"; var EventPlanLineBuffer: Record "NPR Event Plan. Line Buffer")
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine2: Record "Job Planning Line";
        Resource: Record Resource;
        ResourceTemp: Record Resource temporary;
        LineNo: Integer;
        MinDate: Date;
        MaxDate: Date;
    begin
        if EventPlanLineBuffer.IsEmpty then
            exit;

        Job.Get(EventPlanLineBuffer."Job No.");
        JobTask.Get(Job."No.", EventPlanLineBuffer."Job Task No.");
        LineNo := 10000;
        JobPlanningLine2.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine2.SetRange("Job Task No.", Rec."Job Task No.");
        if JobPlanningLine2.FindLast then
            LineNo := JobPlanningLine2."Line No." + 10000;

        EventPlanLineBuffer.SetRange(Type, EventPlanLineBuffer.Type::Resource);
        if EventPlanLineBuffer.FindSet then
            repeat
                if not ResourceTemp.Get(EventPlanLineBuffer."No.") then begin
                    ResourceTemp."No." := EventPlanLineBuffer."No.";
                    ResourceTemp.Insert;
                end;
            until EventPlanLineBuffer.Next = 0;
        if ResourceTemp.FindSet then
            repeat
                Resource.Get(Rec."No.");
                Rec."No." := Resource."No.";
                Rec."Line No." := LineNo;
                Rec."NPR Group Line" := true;
                Rec.Insert;
                LineNo += 10000;
                EventPlanLineBuffer.SetRange("No.", ResourceTemp."No.");
                if EventPlanLineBuffer.FindSet then
                    repeat
                        JobPlanningLine2.Init;
                        JobPlanningLine2."Job No." := Rec."Job No.";
                        JobPlanningLine2."Job Task No." := Rec."Job Task No.";
                        JobPlanningLine2."Line No." := LineNo;
                        JobPlanningLine2."NPR Skip Cap./Avail. Check" := EventPlanLineBuffer."Status Checked";
                        JobPlanningLine2."NPR Group Source Line No." := Rec."Line No.";
                        JobPlanningLine2."NPR Group Line" := true;
                        JobPlanningLine2.Insert;
                        JobPlanningLine2.Validate("Line Type", Rec."Line Type");
                        JobPlanningLine2.Validate("Planning Date", EventPlanLineBuffer."Planning Date");
                        JobPlanningLine2.Validate(Type, EventPlanLineBuffer.Type::Resource);
                        JobPlanningLine2.Validate("No.", EventPlanLineBuffer."No.");
                        JobPlanningLine2.Validate("NPR Starting Time", EventPlanLineBuffer."Starting Time");
                        JobPlanningLine2.Validate("NPR Ending Time", EventPlanLineBuffer."Ending Time");
                        JobPlanningLine2.Validate(Quantity, EventPlanLineBuffer.Quantity);
                        JobPlanningLine2."NPR Skip Cap./Avail. Check" := false;
                        JobPlanningLine2.Modify(true);
                        LineNo += 10000;
                        if MinDate = 0D then
                            MinDate := JobPlanningLine2."Planning Date";
                        if JobPlanningLine2."Planning Date" < MinDate then
                            MinDate := JobPlanningLine2."Planning Date";
                        if JobPlanningLine2."Planning Date" > MaxDate then
                            MaxDate := JobPlanningLine2."Planning Date";
                    until EventPlanLineBuffer.Next = 0;
                Rec."Description 2" := StrSubstNo(Desc2AsPeriod, Format(MinDate), Format(MaxDate), Format(EventPlanLineBuffer.Count));
                Rec.Modify;
            until ResourceTemp.Next = 0;
    end;

    local procedure BackupCurrentDistribution(Rec: Record "Job Planning Line"; var RecBackup: Record "Job Planning Line")
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        RecBackup := Rec;
        RecBackup.Insert;
        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
        JobPlanningLine.SetRange("NPR Group Source Line No.", Rec."Line No.");
        if JobPlanningLine.FindSet then
            repeat
                RecBackup := JobPlanningLine;
                RecBackup.Insert;
            until JobPlanningLine.Next = 0;
    end;

    local procedure RestoreOldDistribution(var RecBackup: Record "Job Planning Line")
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if RecBackup.FindSet then
            repeat
                JobPlanningLine := RecBackup;
                JobPlanningLine.Insert;
            until RecBackup.Next = 0;
    end;
}

