codeunit 6059912 "NPR MM Membership Stat. Mgmt."
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        UpdateStatistics(Today() - 1, true);
    end;

    local procedure UpdateStatistics(RefDate: Date; Replace: Boolean)
    var
        MMMembershipEntry: Record "NPR MM Membership Entry";
        MMMembershipStatistics: Record "NPR MM Membership Statistics";
        RefDateLY: Date;
        FirstDateOfMonth: Date;
        LastDateOfMonth: Date;
    begin
        MMMembershipEntry.SetRange(Blocked, false);
        if MMMembershipEntry.IsEmpty() then
            Exit; // membership module not used, so no need to make further counts

        if not MMMembershipStatistics.Get(RefDate) then begin
            MMMembershipStatistics."Reference Date" := RefDate;
            MMMembershipStatistics.Insert(true);
        end else
            if not Replace then
                exit;

        MMMembershipEntry.SetFilter("Valid From Date", '<=%1', RefDate);
        MMMembershipEntry.SetFilter("Valid Until Date", '>=%1', RefDate);

        // no of new members
        MMMembershipEntry.SetRange(Context, MMMembershipEntry.Context::NEW);
        MMMembershipStatistics."First Time Members" := MMMembershipEntry.Count();

        // no of recurring members
        MMMembershipEntry.SetFilter(Context, '%1|%2|%3', MMMembershipEntry.Context::RENEW, MMMembershipEntry.Context::AUTORENEW, MMMembershipEntry.Context::UPGRADE);
        MMMembershipStatistics."Recurring Members" := MMMembershipEntry.Count();

        // no of future members
        MMMembershipEntry.SetRange(Context);
        MMMembershipEntry.SetFilter("Valid From Date", '>%1', RefDate);
        MMMembershipEntry.SetRange("Valid Until Date");
        MMMembershipEntry.SetFilter("Created At", '<=%1', CreateDateTime(RefDate, 235959.999T)); // for historical calculation..
        MMMembershipStatistics."Future Members" := MMMembershipEntry.Count();
        MMMembershipEntry.SetRange("Created At");

        // no of members last year
        RefDateLY := CalcDate('<-1Y>', RefDate);
        MMMembershipEntry.SetFilter("Valid From Date", '<=%1', RefDateLY);
        MMMembershipEntry.SetFilter("Valid Until Date", '>=%1', RefDateLY);
        MMMembershipEntry.SetRange(Context, MMMembershipEntry.Context::NEW);
        MMMembershipStatistics."First Time Members Last Year" := MMMembershipEntry.Count();

        MMMembershipEntry.SetFilter(Context, '%1|%2|%3', MMMembershipEntry.Context::RENEW, MMMembershipEntry.Context::AUTORENEW, MMMembershipEntry.Context::UPGRADE);
        MMMembershipStatistics."Recurring Members Last Year" := MMMembershipEntry.Count();

        //no of members expire current month
        FirstDateOfMonth := CalcDate('<-CM>', RefDate);
        LastDateOfMonth := CalcDate('<CM>', RefDate);
        MMMembershipEntry.Reset();
        MMMembershipEntry.SetRange("Valid Until Date", FirstDateOfMonth, LastDateOfMonth);
        MMMembershipStatistics."No. of Members expire CM" := MMMembershipEntry.Count();

        MMMembershipStatistics.Modify();
    end;

    internal procedure CreateHistoricalData()
    var
        Date: Record Date;
        DateDialog: Page "Date-Time Dialog";
        SelectedDate: Date;
        SelectedDateError: Label 'Please select a date before today.';
        Window: Dialog;
        ProgressLbl: Label 'Processing... #1';
        ProgressLbl2: Label '%1 of %2';
        TotalRecNo: Integer;
        i: Integer;
    begin
        DateDialog.SetDateTime(CreateDateTime(Today() - 1, 000000T));
        if DateDialog.RunModal() = Action::OK then
            SelectedDate := DT2Date(DateDialog.GetDateTime())
        else
            exit;

        if SelectedDate >= Today() then
            Error(SelectedDateError);

        Date.SetRange("Period Type", Date."Period Type"::Date);
        Date.SetRange("Period Start", SelectedDate, Today() - 1);

        if GuiAllowed then begin
            TotalRecNo := Date.Count;
            Window.Open(ProgressLbl);
        end;

        if Date.FindSet() then
            repeat
                if GuiAllowed then begin
                    i += 1;
                    if i mod 10 = 0 then
                        Window.Update(1, StrSubstNo(ProgressLbl2, i, TotalRecNo));
                end;
                UpdateStatistics(Date."Period Start", false);
            until Date.Next() = 0;

        if GuiAllowed then
            Window.Close();
    end;

    internal procedure CreateHistoricalDataSingleDate()
    var
        DateDialog: Page "Date-Time Dialog";
        SelectedDate: Date;
    begin
        DateDialog.SetDateTime(CreateDateTime(Today() - 1, 000000T));
        if DateDialog.RunModal() = Action::OK then
            SelectedDate := DT2Date(DateDialog.GetDateTime())
        else
            exit;

        UpdateStatistics(SelectedDate, true);
    end;

    internal procedure DeleteHistoricalData()
    var
        MMMembershipStatistics: Record "NPR MM Membership Statistics";
        DateDialog: Page "Date-Time Dialog";
        SelectedDate: Date;
        ConfirmManagement: Codeunit "Confirm Management";
        SelectedDateError: Label 'Please select a date before today.';
        ConfirmStartDeletion: Label 'This action will ask to select a date and based on the selection all historical data until that date will be permanently deleted. Are you sure you want to continue?';
        ConfirmDeletion: Label 'Are you sure you want to delete all historical data until ''%1''?';
    begin
        if not ConfirmManagement.GetResponse(ConfirmStartDeletion, false) then
            exit;

        DateDialog.SetDateTime(CreateDateTime(Today() - 1, 000000T));
        if DateDialog.RunModal() = Action::OK then
            SelectedDate := DT2Date(DateDialog.GetDateTime())
        else
            exit;

        if SelectedDate >= Today() then
            Error(SelectedDateError);

        if ConfirmManagement.GetResponse(StrSubstNo(ConfirmDeletion, SelectedDate), false) then begin
            MMMembershipStatistics.SetRange("Reference Date", 0D, SelectedDate);
            MMMembershipStatistics.DeleteAll();
        end;
    end;

    internal procedure CreateJobQueueEntry()
    var
        MMMemberCommunity: Record "NPR MM Member Community";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescription: Label 'Membership Statistics - AutoCreated';
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        if MMMemberCommunity.IsEmpty() then begin
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitID()) then
                JobQueueEntry.Cancel();
            exit;
        end;

        NotBeforeDateTime := CurrentDateTime();
        Evaluate(NextRunDateFormula, '<1D>');
        if JobQueueManagement.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CurrCodeunitID(),
            '',
            JobQueueDescription,
            NotBeforeDateTime,
            040000T,
            060000T,
            NextRunDateFormula,
            '',
            JobQueueEntry)
        then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR MM Membership Stat. Mgmt.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Community", 'OnAfterInsertEvent', '', false, false)]
    local procedure EnsureJobQueueEntryExistsOnMemberCommunityInsert(var Rec: Record "NPR MM Member Community")
    var
        JobQueueEntry: Record "Job Queue Entry";
        MMStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitID()) then
            MMStatMgmt.CreateJobQueueEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        CreateJobQueueEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = CurrCodeunitID())
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
}
