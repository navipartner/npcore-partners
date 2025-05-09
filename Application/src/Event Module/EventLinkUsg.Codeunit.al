﻿codeunit 6060157 "NPR Event Link Usg."
{
    Access = Internal;
    //New object copied from standard codeunit 1026
    Permissions = TableData "Job Usage Link" = rimd;

    var
        Text001: Label 'The specified %1 does not have %2 enabled.', Comment = 'The specified Job Planning Line does not have Usage Link enabled.';
        ConfirmUsageWithBlankLineTypeQst: Label 'Usage will not be linked to the job planning line because the Line Type field is empty.\\Do you want to continue?';
        UseAutoConfirm: Boolean;
        AutoConfirmAnswer: Boolean;

    procedure ApplyUsage(JobLedgerEntry: Record "Job Ledger Entry"; JobJournalLine: Record "Job Journal Line")
    begin
        if JobJournalLine."Job Planning Line No." = 0 then
            MatchUsageUnspecified(JobLedgerEntry, JobJournalLine."Line Type" = JobJournalLine."Line Type"::" ")
        else
            MatchUsageSpecified(JobLedgerEntry, JobJournalLine);
    end;

    local procedure MatchUsageUnspecified(JobLedgerEntry: Record "Job Ledger Entry"; EmptyLineType: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
        JobUsageLink: Record "Job Usage Link";
        Confirmed: Boolean;
        MatchedQty: Decimal;
        MatchedTotalCost: Decimal;
        MatchedLineAmount: Decimal;
        RemainingQtyToMatch: Decimal;
    begin
        RemainingQtyToMatch := JobLedgerEntry."Quantity (Base)";
        repeat
            if not FindMatchingJobPlanningLine(JobPlanningLine, JobLedgerEntry) then
                if EmptyLineType then begin
                    if UseAutoConfirm then
                        Confirmed := AutoConfirmAnswer
                    else
                        Confirmed := Confirm(ConfirmUsageWithBlankLineTypeQst, false);
                    if not Confirmed then
                        Error('');
                    RemainingQtyToMatch := 0;
                end else
                    CreateJobPlanningLine(JobPlanningLine, JobLedgerEntry, RemainingQtyToMatch);

            if RemainingQtyToMatch <> 0 then begin
                JobUsageLink.Create(JobPlanningLine, JobLedgerEntry);
                if Abs(RemainingQtyToMatch) > Abs(JobPlanningLine."Remaining Qty. (Base)") then
                    MatchedQty := JobPlanningLine."Remaining Qty. (Base)"
                else
                    MatchedQty := RemainingQtyToMatch;
                MatchedTotalCost := (JobLedgerEntry."Total Cost" / JobLedgerEntry."Quantity (Base)") * MatchedQty;
                MatchedLineAmount := (JobLedgerEntry."Line Amount" / JobLedgerEntry."Quantity (Base)") * MatchedQty;
                JobPlanningLine.Use(CalcQtyFromBaseQty(MatchedQty, JobPlanningLine."Qty. per Unit of Measure"),
                  MatchedTotalCost, MatchedLineAmount, JobLedgerEntry."Posting Date", JobLedgerEntry."Currency Factor");
                RemainingQtyToMatch -= MatchedQty;
            end;
        until RemainingQtyToMatch = 0;
    end;

    local procedure MatchUsageSpecified(JobLedgerEntry: Record "Job Ledger Entry"; JobJournalLine: Record "Job Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobUsageLink: Record "Job Usage Link";
        TotalRemainingQtyPrePostBase: Decimal;
        PostedQtyBase: Decimal;
        TotalQtyBase: Decimal;
    begin
        JobPlanningLine.Get(JobLedgerEntry."Job No.", JobLedgerEntry."Job Task No.", JobJournalLine."Job Planning Line No.");
        if not JobPlanningLine."Usage Link" then
            Error(Text001, JobPlanningLine.TableCaption, JobPlanningLine.FieldCaption("Usage Link"));

        PostedQtyBase := JobPlanningLine."Quantity (Base)" - JobPlanningLine."Remaining Qty. (Base)";
        TotalRemainingQtyPrePostBase := JobJournalLine."Quantity (Base)" + JobJournalLine."Remaining Qty. (Base)";
        TotalQtyBase := PostedQtyBase + TotalRemainingQtyPrePostBase;
        JobPlanningLine.SetBypassQtyValidation(true);
        JobPlanningLine.Validate(Quantity, CalcQtyFromBaseQty(TotalQtyBase, JobPlanningLine."Qty. per Unit of Measure"));
        JobPlanningLine.Validate("Serial No.", JobLedgerEntry."Serial No.");
        JobPlanningLine.Validate("Lot No.", JobLedgerEntry."Lot No.");
        JobPlanningLine.Use(CalcQtyFromBaseQty(JobLedgerEntry."Quantity (Base)", JobPlanningLine."Qty. per Unit of Measure"),
          JobLedgerEntry."Total Cost", JobLedgerEntry."Line Amount", JobLedgerEntry."Posting Date", JobLedgerEntry."Currency Factor");
        JobUsageLink.Create(JobPlanningLine, JobLedgerEntry);
    end;

    procedure FindMatchingJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; JobLedgerEntry: Record "Job Ledger Entry"): Boolean
    var
        Resource: Record Resource;
        "Filter": Text;
    begin
        JobPlanningLine.Reset();
        JobPlanningLine.SetCurrentKey("Job No.", "Schedule Line", Type, "No.", "Planning Date");
        JobPlanningLine.SetRange("Job No.", JobLedgerEntry."Job No.");
        JobPlanningLine.SetRange("Job Task No.", JobLedgerEntry."Job Task No.");
        JobPlanningLine.SetRange(Type, JobLedgerEntry.Type);
        JobPlanningLine.SetRange("No.", JobLedgerEntry."No.");
        JobPlanningLine.SetRange("Location Code", JobLedgerEntry."Location Code");
        JobPlanningLine.SetRange("Schedule Line", true);
        JobPlanningLine.SetRange("Usage Link", true);

        if JobLedgerEntry.Type = JobLedgerEntry.Type::Resource then begin
            Filter := Resource.GetUnitOfMeasureFilter(JobLedgerEntry."No.", JobLedgerEntry."Unit of Measure Code");
            JobPlanningLine.SetFilter("Unit of Measure Code", Filter);
        end;

        if (JobLedgerEntry."Line Type" = JobLedgerEntry."Line Type"::Billable) or
           (JobLedgerEntry."Line Type" = JobLedgerEntry."Line Type"::"Both Budget and Billable")
        then
            JobPlanningLine.SetRange("Contract Line", true);

        if JobLedgerEntry.Quantity > 0 then
            JobPlanningLine.SetFilter("Remaining Qty.", '>0')
        else
            JobPlanningLine.SetFilter("Remaining Qty.", '<0');

        case JobLedgerEntry.Type of
            JobLedgerEntry.Type::Item:
                JobPlanningLine.SetRange("Variant Code", JobLedgerEntry."Variant Code");
            JobLedgerEntry.Type::Resource:
                JobPlanningLine.SetRange("Work Type Code", JobLedgerEntry."Work Type Code");
        end;

        // Match most specific Job Planning Line.
        if JobPlanningLine.FindFirst() then
            exit(true);

        JobPlanningLine.SetRange("Variant Code", '');
        JobPlanningLine.SetRange("Work Type Code", '');

        // Match Location Code, while Variant Code and Work Type Code are blank.
        if JobPlanningLine.FindFirst() then
            exit(true);

        JobPlanningLine.SetRange("Location Code", '');

        case JobLedgerEntry.Type of
            JobLedgerEntry.Type::Item:
                JobPlanningLine.SetRange("Variant Code", JobLedgerEntry."Variant Code");
            JobLedgerEntry.Type::Resource:
                JobPlanningLine.SetRange("Work Type Code", JobLedgerEntry."Work Type Code");
        end;

        // Match Variant Code / Work Type Code, while Location Code is blank.
        if JobPlanningLine.FindFirst() then
            exit(true);

        JobPlanningLine.SetRange("Variant Code", '');
        JobPlanningLine.SetRange("Work Type Code", '');

        // Match unspecific Job Planning Line.
        if JobPlanningLine.FindFirst() then
            exit(true);

        exit(false);
    end;

    local procedure CreateJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; JobLedgerEntry: Record "Job Ledger Entry"; RemainingQtyToMatch: Decimal)
    var
        Job: Record Job;
        JobPostLine: Codeunit "Job Post-Line";
    begin
        RemainingQtyToMatch := CalcQtyFromBaseQty(RemainingQtyToMatch, JobLedgerEntry."Qty. per Unit of Measure");

        case JobLedgerEntry."Line Type" of
            JobLedgerEntry."Line Type"::" ":
                JobLedgerEntry."Line Type" := JobLedgerEntry."Line Type"::Budget;
            JobLedgerEntry."Line Type"::Billable:
                JobLedgerEntry."Line Type" := JobLedgerEntry."Line Type"::"Both Budget and Billable";
        end;
        JobPlanningLine.Reset();
        JobPostLine.InsertPlLineFromLedgEntry(JobLedgerEntry);
        // Retrieve the newly created Job PlanningLine.
        JobPlanningLine.SetRange("Job No.", JobLedgerEntry."Job No.");
        JobPlanningLine.SetRange("Job Task No.", JobLedgerEntry."Job Task No.");
        JobPlanningLine.SetRange("Schedule Line", true);
        JobPlanningLine.FindLast();
        JobPlanningLine.Validate("Usage Link", true);
        JobPlanningLine.Validate(Quantity, RemainingQtyToMatch);
        JobPlanningLine.Modify();

        // If type is Both Schedule And Contract and that type isn't allowed,
        // retrieve the Contract line and modify the quantity as well.
        // Do the same if the type is G/L Account (Job Planning Lines will always be split in one Schedule and one Contract line).
        Job.Get(JobLedgerEntry."Job No.");
        if (JobLedgerEntry."Line Type" = JobLedgerEntry."Line Type"::"Both Budget and Billable") and
           ((not Job."Allow Schedule/Contract Lines") or (JobLedgerEntry.Type = JobLedgerEntry.Type::"G/L Account"))
        then begin
            JobPlanningLine.Get(JobLedgerEntry."Job No.", JobLedgerEntry."Job Task No.", JobPlanningLine."Line No." + 10000);
            JobPlanningLine.Validate(Quantity, RemainingQtyToMatch);
            JobPlanningLine.Modify();
            JobPlanningLine.Get(JobLedgerEntry."Job No.", JobLedgerEntry."Job Task No.", JobPlanningLine."Line No." - 10000);
        end;
    end;

    local procedure CalcQtyFromBaseQty(BaseQty: Decimal; QtyPerUnitOfMeasure: Decimal): Decimal
    begin
        if QtyPerUnitOfMeasure <> 0 then
            exit(Round(BaseQty / QtyPerUnitOfMeasure, 0.00001));
        exit(BaseQty);
    end;

    procedure SetAutoConfirm(ConfirmAnswer: Boolean)
    begin
        UseAutoConfirm := true;
        AutoConfirmAnswer := ConfirmAnswer;
    end;
}

