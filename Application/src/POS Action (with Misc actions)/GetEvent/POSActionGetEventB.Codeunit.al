codeunit 6060162 "NPR POS Action: Get Event B"
{
    Access = Internal;

    var
        NothingToInvoiceErr: Label 'There''s nothing to invoice on that event.';
        ItemRequiresVariantConfirm: Label 'Item %1 on event %2 is missing a %3. You need to select it before proceeding. Do you want to continue?';
        NoVariantCodeSelectedErr: Label 'No %1 selected for item %2.';
        EventTaskNotSelectedErr: Label 'You must select a task to continue.';
        EventPlanningLineNotSelectedErr: Label 'You must select event planning line(s) to continue.';

    procedure SelectEvent(LookAheadPeriodDays: Integer): Code[20]
    var
        Job: Record Job;
        EventList: Page "NPR Event List";
        DateFormulaPlaceholderString: Label '<%1D>', Comment = '%1 - number of days';
    begin
        Job.SetRange("NPR Event", true);
        Job.SetRange("NPR Event Status", Job."NPR Event Status"::Order);
        Job.SetRange(Blocked, Job.Blocked::" ");
        if LookAheadPeriodDays > 0 then
            Job.SetRange("Starting Date", WorkDate(), CalcDate(StrSubstNo(DateFormulaPlaceholderString, LookAheadPeriodDays), WorkDate()));
        EventList.SetTableView(Job);
        EventList.LookupMode := true;
        if EventList.RunModal() = Action::LookupOK then begin
            EventList.GetRecord(Job);
            exit(Job."No.");
        end;
        exit('');
    end;

    procedure ImportEvent(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; EventNo: Code[20]; GetEventLinesOption: Option Invoiceable,Selection,None; AddNewLinesToTaskOption: Option Default,First,Selection)
    var
        Job: Record Job;
        Customer: Record Customer;
        JobPlanningLine: Record "Job Planning Line";
        JobTask: Record "Job Task";
        SalePOS: Record "NPR POS Sale";
        TempJobPlanningLine: Record "Job Planning Line" temporary;
    begin

        GetAndTestJob(EventNo, Job);
        GetAndTestCustomer(Job, Customer);
        GetJobTask(Job, AddNewLinesToTaskOption, JobTask);
        GetJobPlanningLines(Job, JobTask, GetEventLinesOption, JobPlanningLine);
        if GetEventLinesOption <> GetEventLinesOption::None then
            TestJobPlanningLinesAndCollectUpdates(JobPlanningLine, TempJobPlanningLine);
        Sale.GetCurrentSale(SalePOS);
        UpdateSalePOSWithEventInfo(Customer, JobTask, SalePOS);
        if GetEventLinesOption <> GetEventLinesOption::None then
            CreateSaleLinePOSFromJobPlanningLine(SalePOS, SaleLine, JobPlanningLine, TempJobPlanningLine, JobTask);
    end;

    local procedure GetAndTestJob(EventNo: Code[20]; var Job: Record Job)
    begin
        Job.Get(EventNo);
        Job.TestField("NPR Event");
        Job.TestField("NPR Event Status", Job."NPR Event Status"::Order);
        Job.TestBlocked();
        Job.TestField("NPR Event Customer No.");
    end;

    local procedure GetAndTestCustomer(Job: Record Job; var Customer: Record Customer)
    begin
        Customer.Get(Job."NPR Event Customer No.");
        Customer.TestField(Blocked, Customer.Blocked::" ");
    end;

    local procedure GetJobTask(Job: Record Job; AddNewLinesToTaskOption: Option Default,First,Selection; var JobTask: Record "Job Task")
    var
        JobsSetup: Record "Jobs Setup";
        EventTaskLines: Page "NPR Event Task Lines";
    begin
        case AddNewLinesToTaskOption of
            AddNewLinesToTaskOption::Default:
                begin
                    JobsSetup.Get();
                    JobsSetup.TestField("NPR Def. Job Task No.");
                    JobTask.Get(Job."No.", JobsSetup."NPR Def. Job Task No.");
                end;
            AddNewLinesToTaskOption::First:
                begin
                    JobTask.SetRange("Job No.", Job."No.");
                    JobTask.FindFirst();
                end;
            AddNewLinesToTaskOption::Selection:
                begin
                    JobTask.SetRange("Job No.", Job."No.");
                    EventTaskLines.SetTableView(JobTask);
                    EventTaskLines.Editable(false);
                    EventTaskLines.LookupMode(true);
                    if EventTaskLines.RunModal() = Action::LookupOK then begin
                        EventTaskLines.GetRecord(JobTask);
                        JobTask.SetRecFilter();
                        JobTask.FindFirst();
                    end else
                        Error(EventTaskNotSelectedErr);
                end;
        end;
    end;

    local procedure GetJobPlanningLines(Job: Record Job; JobTask: Record "Job Task"; GetEventLinesOption: Option Invoiceable,Selection,None; var JobPlanningLine: Record "Job Planning Line")
    var
        EventPlanningLines: Page "NPR Event Planning Lines";
        NothingToInvoice: Boolean;
    begin
        JobPlanningLine.SetRange("Job No.", JobTask."Job No.");
        JobPlanningLine.SetRange("Job Task No.", JobTask."Job Task No.");
        JobPlanningLine.SetFilter("Line Type", '>%1', JobPlanningLine."Line Type"::Budget);
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
        JobPlanningLine.SetFilter("Qty. to Transfer to Invoice", '>0');
        JobPlanningLine.SetFilter("NPR Ticket Status", '<%1', JobPlanningLine."NPR Ticket Status"::Revoked);
        case GetEventLinesOption of
            GetEventLinesOption::Invoiceable:
                if not JobPlanningLine.FindSet() then
                    Error(NothingToInvoiceErr);
            GetEventLinesOption::Selection:
                begin
                    EventPlanningLines.SetTableView(JobPlanningLine);
                    EventPlanningLines.Editable(false);
                    EventPlanningLines.LookupMode(true);
                    if EventPlanningLines.RunModal() = Action::LookupOK then
                        EventPlanningLines.GetSelectionFilter(JobPlanningLine)
                    else
                        Error(EventPlanningLineNotSelectedErr);
                end;
            GetEventLinesOption::None:
                NothingToInvoice := not Job."NPR Allow POS Add. New Lines";
        end;
        if NothingToInvoice or not JobPlanningLine.FindSet() then
            Error(NothingToInvoiceErr);
    end;

    local procedure TestJobPlanningLinesAndCollectUpdates(var JobPlanningLine: Record "Job Planning Line"; var TempJobPlanningLine: Record "Job Planning Line")
    begin
        if JobPlanningLine.FindSet() then
            repeat
                TempJobPlanningLine := JobPlanningLine;
                if JobPlanningLine."Variant Code" = '' then
                    CheckVariantCodeAndCollect(JobPlanningLine, TempJobPlanningLine);
                TempJobPlanningLine.Insert(false);
            until JobPlanningLine.Next() = 0;
    end;

    local procedure CheckVariantCodeAndCollect(var JobPlanningLine: Record "Job Planning Line"; var TempJobPlanningLine: Record "Job Planning Line")
    var
        ItemVariant: Record "Item Variant";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        ItemVariant.SetRange("Item No.", JobPlanningLine."No.");
        if ItemVariant.IsEmpty then
            exit;
        if not Confirm(StrSubstNo(ItemRequiresVariantConfirm, JobPlanningLine."No.", JobPlanningLine."Job No.", JobPlanningLine.FieldCaption("Variant Code"))) then
            Error(NoVariantCodeSelectedErr, JobPlanningLine.FieldCaption("Variant Code"), JobPlanningLine."No.");

        TempJobPlanningLine."Variant Code" := POSSaleLine.FillVariantThroughLookUp(JobPlanningLine."No.", JobPlanningLine."Location Code");
    end;

    local procedure UpdateSalePOSWithEventInfo(Customer: Record Customer; JobTask: Record "Job Task"; var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Validate("Prices Including VAT", Customer."Prices Including VAT");
        SalePOS.Validate("Event No.", JobTask."Job No.");
        SalePOS.Validate("Event Task No.", JobTask."Job Task No.");
        SalePOS.Modify();
    end;

    local procedure CreateSaleLinePOSFromJobPlanningLine(SalePOS: Record "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; var JobPlanningLine: Record "Job Planning Line"; var TempJobPlanningLine: Record "Job Planning Line"; JobTask: Record "Job Task")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        JobPlanningLine.FindSet();
        repeat
            TempJobPlanningLine.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.", JobPlanningLine."Line No.");
            SaleLine.GetCurrentSaleLine(SaleLinePOS);
            InsertSaleLinePOS(TempJobPlanningLine, JobTask, SalePOS, SaleLine, SaleLinePOS);
            InsertJobPlanningLineInvoice(JobPlanningLine, SalePOS, SaleLinePOS);
            JobPlanningLine.UpdateQtyToTransfer();
            JobPlanningLine.Modify();
        until JobPlanningLine.Next() = 0;
    end;

    local procedure InsertSaleLinePOS(var JobPlanningLine: Record "Job Planning Line"; JobTask: Record "Job Task"; SalePOS: Record "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
    begin
        SaleLinePOS."No." := JobPlanningLine."No.";
        SaleLinePOS."Variant Code" := JobPlanningLine."Variant Code";
        SaleLinePOS.Description := JobPlanningLine.Description;
        SaleLinePOS."Description 2" := JobPlanningLine."Description 2";
        SaleLinePOS."Variant Code" := JobPlanningLine."Variant Code";
        SaleLinePOS."Unit of Measure Code" := JobPlanningLine."Unit of Measure Code";
        SaleLinePOS.Quantity := JobPlanningLine."Qty. to Transfer to Invoice";
        SaleLinePOS."Unit Price" := JobPlanningLine."Unit Price";
        SaleLinePOS."Shortcut Dimension 1 Code" := JobTask."Global Dimension 1 Code";
        SaleLinePOS."Shortcut Dimension 2 Code" := JobTask."Global Dimension 2 Code";
        SaleLinePOS."Discount %" := JobPlanningLine."Line Discount %";
        SaleLinePOS."Discount Amount" := JobPlanningLine."Line Discount Amount";
        Item.Get(JobPlanningLine."No.");
        SaleLinePOS."Price Includes VAT" := false;
        SaleLinePOS."VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        SaleLine.SetUseLinePriceVATParams(true);
        SaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure InsertJobPlanningLineInvoice(JobPlanningLine: Record "Job Planning Line"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLineInvoice.Init();
        JobPlanningLineInvoice."NPR POS Unit No." := SaleLinePOS."Register No.";
        JobPlanningLineInvoice."NPR POS Store Code" := SalePOS."POS Store Code";
        JobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type"::Invoice;
        JobPlanningLineInvoice."Document No." := SaleLinePOS."Sales Ticket No.";
        JobPlanningLineInvoice."Line No." := SaleLinePOS."Line No.";
        JobPlanningLineInvoice."Job No." := JobPlanningLine."Job No.";
        JobPlanningLineInvoice."Job Task No." := JobPlanningLine."Job Task No.";
        JobPlanningLineInvoice."Job Planning Line No." := JobPlanningLine."Line No.";
        JobPlanningLineInvoice."Quantity Transferred" := JobPlanningLine."Qty. to Transfer to Invoice";
        JobPlanningLineInvoice."Transferred Date" := SaleLinePOS.Date;
        JobPlanningLineInvoice.Insert();
    end;
}