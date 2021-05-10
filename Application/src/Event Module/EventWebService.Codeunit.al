codeunit 6060158 "NPR Event Web Service"
{
    procedure CopyEventFromTemplate(BundledItemNo: Code[20]; TemplateEventNo: Code[20]; BillToCustomerNo: Code[20]; BundledItemQuantity: Decimal; BundledItemPrice: Decimal; StartDateTime: DateTime; EndDateTime: DateTime; AdditionalItems: XMLport "NPR Event Import Opt. Items"; var ReturnMessage: Text): Boolean
    var
        EventSalesSetup: Record "NPR Event Web Sales Setup";
        CopyJob: Codeunit "Copy Job";
        Source: Option "Job Planning Lines","Job Ledger Entries","None";
        PlanningLineType: Option "Schedule+Contract",Schedule,Contract;
        LedgerEntryType: Option "Usage+Sale",Usage,Sale;
        CopyJobPrices: Boolean;
        CopyQuantity: Boolean;
        CopyDimensions: Boolean;
        SourceJob: Record Job;
        TargetJob: Record Job;
        TargetJobNo: Code[20];
        TargetJobDescription: Text[100];
        JobsSetup: Record "Jobs Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        JobPlanningLine: Record "Job Planning Line";
        TempJobPlanningLine: Record "Job Planning Line" temporary;
        JobTask: Record "Job Task";
        ProcessingError: Label 'Navision error: %1';
        NoJobTask: Label '%1 wasn''t created. Check if associated event template %2 has %1 created and that it can copied to new event.';
        NoJobsSetupNos: Label '%1 is not setup on %2.';
        NoEventTemplate: Label 'Template %1 doesn''t exist.';
        LineNo: Integer;
        XmlPortProblem: Label 'There''s a problem with importing additional items.';
        SuccessMsg: Label 'Event %1 successfuly created.';
        NoEventSalesSetup: Label 'A %1 needs to be set with %2=%3 and %4=%5 before event can be created.';
    begin
        EventSalesSetup.SetRange(Type, EventSalesSetup.Type::Item);
        EventSalesSetup.SetRange("No.", BundledItemNo);
        EventSalesSetup.SetRange("Event No.", TemplateEventNo);
        if not EventSalesSetup.FindFirst() then begin
            ReturnMessage := StrSubstNo(ProcessingError, StrSubstNo(NoEventSalesSetup, EventSalesSetup.TableCaption,
                                                                    EventSalesSetup.FieldCaption("No."), BundledItemNo,
                                                                    EventSalesSetup.FieldCaption("Event No."), TemplateEventNo));
            exit(false);
        end;

        CopyJobPrices := true;
        CopyQuantity := false;
        CopyDimensions := true;

        if not SourceJob.Get(TemplateEventNo) then begin
            ReturnMessage := StrSubstNo(ProcessingError, StrSubstNo(NoEventTemplate, TemplateEventNo));
            exit(false);
        end;

        JobsSetup.Get();
        if JobsSetup."Job Nos." = '' then begin
            ReturnMessage := StrSubstNo(ProcessingError, StrSubstNo(NoJobsSetupNos, JobsSetup.FieldCaption("Job Nos."), JobsSetup.TableCaption));
            exit(false);
        end;

        TargetJobNo := NoSeriesManagement.GetNextNo(JobsSetup."Job Nos.", 0D, true);
        TargetJobDescription := SourceJob.Description;
        CopyJob.SetCopyOptions(CopyJobPrices, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
        CopyJob.CopyJob(SourceJob, TargetJobNo, TargetJobDescription, BillToCustomerNo);
        TargetJob.Get(TargetJobNo);
        TargetJob."Starting Date" := 0D;
        TargetJob."Ending Date" := 0D;
        if DT2Date(StartDateTime) <> 0D then
            TargetJob.Validate("Starting Date", DT2Date(StartDateTime));
        if DT2Date(EndDateTime) <> 0D then
            TargetJob.Validate("Ending Date", DT2Date(EndDateTime));
        if DT2Time(StartDateTime) <> 0T then
            TargetJob.Validate("NPR Starting Time", DT2Time(StartDateTime));
        if DT2Time(EndDateTime) <> 0T then
            TargetJob.Validate("NPR Ending Time", DT2Time(EndDateTime));
        TargetJob.Modify();

        JobTask.SetRange("Job No.", TargetJob."No.");
        if not JobTask.FindFirst() then begin
            ReturnMessage := StrSubstNo(ProcessingError, NoJobTask);
            exit(false);
        end;

        if not AdditionalItems.Import() then begin
            ReturnMessage := StrSubstNo(ProcessingError, XmlPortProblem);
            exit(false);
        end;

        LineNo := 10000;
        JobPlanningLine.SetRange("Job No.", TargetJob."No.");
        if JobPlanningLine.FindLast() then
            LineNo := JobPlanningLine."Line No." + 10000;

        JobPlanningLine.Init();
        JobPlanningLine."Job No." := TargetJob."No.";
        JobPlanningLine."Job Task No." := JobTask."Job Task No.";
        JobPlanningLine."Line No." := LineNo;
        JobPlanningLine.Insert(true);
        JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::"Both Budget and Billable");
        JobPlanningLine.Validate(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.Validate("No.", BundledItemNo);
        JobPlanningLine.Validate(Quantity, BundledItemQuantity);
        JobPlanningLine.Validate("Unit Price", BundledItemPrice);
        JobPlanningLine.Modify(true);
        LineNo += 10000;

        AdditionalItems.GetOptionalItems(TempJobPlanningLine);
        if TempJobPlanningLine.FindSet() then
            repeat
                JobPlanningLine.Init();
                JobPlanningLine."Job No." := TargetJob."No.";
                JobPlanningLine."Job Task No." := JobTask."Job Task No.";
                JobPlanningLine."Line No." := LineNo;
                JobPlanningLine.Insert(true);
                JobPlanningLine.Validate("Line Type", JobPlanningLine."Line Type"::"Both Budget and Billable");
                JobPlanningLine.Validate(Type, JobPlanningLine.Type::Item);
                JobPlanningLine.Validate("No.", TempJobPlanningLine."No.");
                if TempJobPlanningLine.Description <> '' then
                    JobPlanningLine.Description := TempJobPlanningLine.Description;
                JobPlanningLine.Validate(Quantity, TempJobPlanningLine.Quantity);
                JobPlanningLine.Validate("Unit Price", TempJobPlanningLine."Unit Price");
                JobPlanningLine.Validate("Line Discount %", TempJobPlanningLine."Line Discount %");
                JobPlanningLine.Modify(true);
                LineNo += 10000;
            until TempJobPlanningLine.Next() = 0;

        ReturnMessage := StrSubstNo(SuccessMsg, TargetJob."No.");
        exit(true);
    end;
}

