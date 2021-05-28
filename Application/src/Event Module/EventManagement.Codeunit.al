codeunit 6060150 "NPR Event Management"
{
    Permissions = TableData "Job Ledger Entry" = imd,
                  TableData "Job Register" = imd,
                  TableData "Value Entry" = rimd;

    var
        JobsSetup: Record "Jobs Setup";
        GLSetup: Record "General Ledger Setup";
        JobReg: Record "Job Register";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        ContinueMsg: Label 'Do you want to continue?';
        EventEmailMgt: Codeunit "NPR Event Email Management";
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        RelatedJobEntriesExistErr: Label 'You can''t change %1 as there are related %2 or %3 associated with it.';
        EventVersionSpecificMgt: Codeunit "NPR Event Vers. Specific Mgt.";
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        AmountRoundingPrecision: Decimal;
        UnitAmountRoundingPrecision: Decimal;
        AmountRoundingPrecisionFCY: Decimal;
        UnitAmountRoundingPrecisionFCY: Decimal;
        RoundingSet: Boolean;
        NothingToCopyTxt: Label 'There was nothing to copy.';
        NextEntryNo: Integer;
        JobRegisterInitialized: Boolean;
        POSDocPostType: Option " ","POS Entry","Audit Roll";
        POSEntryNo: Integer;
        SalesDocErr: Label 'The %1 %2 does not exist anymore. A printed copy of the document was created before the document was deleted.';
        POSDocProcessingErr: Label 'Document is currently being processed on POS. Please try again later.';
        POSDocErr: Label 'POS document %1 %2 no longer exists.';
        BlockDeleteErr: Label 'You can''t delete event %1 as it is in status %2. Please check %3 for blocked statuses.';
        BufferMode: Boolean;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsert(var Rec: Record Job; RunTrigger: Boolean)
    var
        Job: Record Job;
        ReturnMsg: Text;
    begin
        if not RunTrigger then
            exit;

        if not IsEventJob(Rec) then
            exit;

        if Rec."NPR Source Job No." = '' then
            Rec."NPR Source Job No." := Rec."No.";

        if Rec."NPR Source Job No." <> Rec."No." then begin
            Job.Get(Rec."NPR Source Job No.");
            EventAttrMgt.CopyAttributes('', Rec."NPR Source Job No.", Rec."No.", ReturnMsg);
            CopyTemplates(Rec."NPR Source Job No.", Rec."No.", 0, ReturnMsg);
            CopyExchIntTemplates(Rec."NPR Source Job No.", Rec."No.", ReturnMsg);
            CopyComments(Rec."NPR Source Job No.", Rec."No.", ReturnMsg);
            Rec."NPR Source Job No." := Rec."No.";
        end;
        Rec.Validate("NPR Event Status");
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterModifyEvent', '', false, false)]
    local procedure JobOnAfterModify(var Rec: Record Job; var xRec: Record Job; RunTrigger: Boolean)
    var
        JobTask: Record "Job Task";
    begin
        if not RunTrigger then
            exit;

        if not IsEventJob(Rec) then
            exit;

        if (Rec."NPR Event Status" = xRec."NPR Event Status") and (Rec."NPR Event Status".AsInteger() < Rec."NPR Event Status"::Postponed.AsInteger()) and (Rec."NPR Event Status" <> Rec.Status) then begin
            Rec.Validate("NPR Event Status");
            Rec.Modify();
        end;

        JobsSetup.Get();
        if (xRec."Bill-to Customer No." = '') and (Rec."Bill-to Customer No." <> xRec."Bill-to Customer No.") then
            if JobsSetup."NPR Auto. Create Job Task Line" then begin
                JobsSetup.TestField("NPR Def. Job Task No.");
                if not JobTask.Get(Rec."No.", JobsSetup."NPR Def. Job Task No.") then begin
                    JobTask.Init();
                    JobTask.Validate("Job No.", Rec."No.");
                    JobTask.Validate("Job Task No.", JobsSetup."NPR Def. Job Task No.");
                    JobTask.Description := JobsSetup."NPR Def. Job Task Description";
                    JobTask.Insert(true);
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure JobOnBeforeDelete(var Rec: Record Job; RunTrigger: Boolean)
    begin
        BlockDeleteIfInStatus(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterDeleteEvent', '', false, false)]
    local procedure JobOnAfterDelete(var Rec: Record Job; RunTrigger: Boolean)
    var
        EventWordLayout: Record "NPR Event Word Layout";
        EventAttribute: Record "NPR Event Attribute";
        EventExchIntTempEntry: Record "NPR Event Exch.Int.Temp.Entry";
    begin
        if not RunTrigger then
            exit;

        if not IsEventJob(Rec) then
            exit;

        EventAttribute.SetRange("Job No.", Rec."No.");
        EventAttribute.DeleteAll(true);

        EventWordLayout.SetRange("Source Record ID", Rec.RecordId);
        EventWordLayout.DeleteAll();

        EventExchIntTempEntry.SetRange("Source Record ID", Rec.RecordId);
        EventExchIntTempEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'NPR Event Status', false, false)]
    local procedure JobEventStatusOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        JobPlanningLine: Record "Job Planning Line";
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
        EmailCounter: Integer;
    begin
        JobPlanningLine.SetCurrentKey("Job No.");
        JobPlanningLine.SetRange("Job No.", Rec."No.");

        if Rec."NPR Event Status".AsInteger() < Rec."NPR Event Status"::Postponed.AsInteger() then begin
            if Rec."NPR Event Status" = Rec."NPR Event Status"::Completed then begin
                Rec.Status := Rec.Status::Completed;
                if Rec."Ending Date" = 0D then
                    Rec.Validate("Ending Date", WorkDate());
                JobPlanningLine.ModifyAll(Status, Rec.Status, true);
            end else
                Rec.Validate(Status, Rec."NPR Event Status");
        end else
            Rec.Validate(Status, Rec.Status::Planning);

        if JobPlanningLine.FindSet() then
            repeat
                JobPlanningLine.Validate("NPR Event Status", Rec."NPR Event Status");
                JobPlanningLine.Modify(true);
            until JobPlanningLine.Next() = 0;

        if (CurrFieldNo = Rec.FieldNo("NPR Event Status")) and (Rec."NPR Event Status" <> xRec."NPR Event Status") then begin
            EventExchIntTemplate.SetRange("Auto. Send. Enabled (E-Mail)", true);
            EventExchIntTemplate.SetRange("Auto.Send.Event Status(E-Mail)", Rec."NPR Event Status");
            if EventExchIntTemplate.FindSet() then
                repeat
                    EventEmailMgt.SetAskOnce(EmailCounter);
                    EventEmailMgt.SetEventExcIntTemplate(EventExchIntTemplate);
                    EventEmailMgt.SendEMail(Rec, EventExchIntTemplate."Template For", Rec.FieldNo("NPR Event Status"));
                    EmailCounter += 1;
                until EventExchIntTemplate.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Starting Date', false, false)]
    local procedure JobStartingDateOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        CalculatedDate: Date;
        PreparationPeriodText: Label 'This event requires %1 of %2. Setting %3 to %4 may lead to event not being fully prepared. Earliest %3 should be set to %5. Do you want to continue?';
        SuggestedDate: Date;
        StartingDateChangedQst: Label '%1 has changed. Do you want to update lines?';
        JobPlanningLine: Record "Job Planning Line";
    begin
        if not IsEventJob(Rec) then
            exit;

        if (Format(Rec."NPR Preparation Period") <> '') and (Rec."Starting Date" <> xRec."Starting Date") and (Rec."Starting Date" <> 0D) then begin
            CalculatedDate := CalcDate('<-' + Format(Rec."NPR Preparation Period") + '>', Rec."Starting Date");
            if CalculatedDate < Today then begin
                SuggestedDate := CalcDate(Rec."NPR Preparation Period", Today);
                if Confirm(StrSubstNo(PreparationPeriodText,
                                        Rec.FieldCaption("NPR Preparation Period"),
                                        Format(Rec."NPR Preparation Period"),
                                        Rec.FieldCaption("Starting Date"),
                                        Format(Rec."Starting Date"),
                                        Format(SuggestedDate))) then
                    Rec.Validate("Starting Date", SuggestedDate);
            end;
        end;

        if Rec."Starting Date" <> xRec."Starting Date" then begin
            if CurrFieldNo = Rec.FieldNo("Starting Date") then
                if not Confirm(StrSubstNo(StartingDateChangedQst, Rec.FieldCaption("Starting Date"))) then
                    exit;
            JobPlanningLine.SetRange("Job No.", Rec."No.");
            if JobPlanningLine.FindSet() then
                repeat
                    JobPlanningLine.Validate("Planning Date", Rec."Starting Date");
                    JobPlanningLine.Modify();
                until JobPlanningLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'NPR Starting Time', false, false)]
    local procedure JobStartingTimeOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        CheckTime(Rec."Starting Date", Rec."Ending Date", Rec."NPR Starting Time", Rec."NPR Ending Time");
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'NPR Ending Time', false, false)]
    local procedure JobEndingTimeOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        CheckTime(Rec."Starting Date", Rec."Ending Date", Rec."NPR Starting Time", Rec."NPR Ending Time");
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure JobBilltoCustomerNoOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        Rec."NPR Event Customer No." := Rec."Bill-to Customer No.";
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'NPR Event Customer No.', false, false)]
    local procedure JobEventCustomerNoOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        JobLedgerEntry: Record "Job Ledger Entry";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        TempJob: Record Job temporary;
        RecRef: RecordRef;
        TempRecRef: RecordRef;
        FldRef: FieldRef;
        FldRef2: FieldRef;
        i: Integer;
        ConfirmCustomerChange: Label 'Are you sure you want to change %1?';
    begin
        if (Rec."NPR Event Customer No." = '') or (Rec."NPR Event Customer No." <> xRec."NPR Event Customer No.") then begin
            if (Rec."NPR Event Customer No." <> xRec."NPR Event Customer No.") and (xRec."NPR Event Customer No." <> '') then
                if not Confirm(StrSubstNo(ConfirmCustomerChange, Rec.FieldCaption("NPR Event Customer No."))) then
                    Error('');
            if JobLedgEntryExist(Rec) or RelatedSalesInvoiceCreditMemoExists(Rec) then
                Error(RelatedJobEntriesExistErr, Rec.FieldCaption("NPR Event Customer No."), JobLedgerEntry.TableCaption, JobPlanningLineInvoice.TableCaption);
        end;
        TempJob := Rec;
        TempJob."No." := '';
        TempJob.Insert();
        TempJob.Validate("Bill-to Customer No.", Rec."NPR Event Customer No.");
        TempJob.Modify();
        RecRef.GetTable(Rec);
        TempRecRef.GetTable(TempJob);
        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            FldRef2 := TempRecRef.FieldIndex(i);
            if (FldRef.Number <> Rec.FieldNo("No.")) and (FldRef.Value <> FldRef2.Value) then
                FldRef.Value := FldRef2.Value;
        end;
        RecRef.Modify();
        RecRef.SetTable(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterInsert(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;

        Job.Get(Rec."Job No.");
        if not IsEventJob(Job) then
            exit;

        if (Job."Starting Date" = Job."Ending Date") and (Job."NPR Starting Time" <> 0T) and (Rec.Type = Rec.Type::Resource) then begin
            Rec."NPR Starting Time" := Job."NPR Starting Time";
            Rec.Modify();
        end;

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterDeleteEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterDelete(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        DeleteActivityLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Line Type', false, false)]
    local procedure JobPlanningLineLineTypeOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        CheckResAvailability(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Planning Date', false, false)]
    local procedure JobPlanningLinePlanningDateOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        CheckResAvailability(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure JobPlanningLineTypeOnBeforeValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Job: Record Job;
    begin
        Job.Get(Rec."Job No.");
        if not IsEventJob(Job) then
            exit;

        if Rec.Type <> xRec.Type then begin
            if EventCalendarMgt.CheckForCalendar(Rec, xRec) then
                if not EventCalendarMgt.CheckForCalendarAndRemove(Rec, xRec) then
                    Error('');
            Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::" ";
            Rec."NPR Resource E-Mail" := '';
            Rec."NPR Mail Item Status" := Rec."NPR Mail Item Status"::" ";
            EventTicketMgt.CheckItemIsTicketAndRemove(Rec, xRec, true, true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if (Rec.Type = Rec.Type::Resource) and (CurrFieldNo = Rec.FieldNo("No.")) then
            CalcResTimeQty(CurrFieldNo, Rec);
        FindJobUnitPriceInclVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Starting Time', false, false)]
    local procedure JobPlanningLineStartingTimeOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("NPR Starting Time") then begin
            CheckTime(Rec."Planning Date", Rec."Planning Date", Rec."NPR Starting Time", Rec."NPR Ending Time");
            CalcResTimeQty(CurrFieldNo, Rec);
            CheckResTimeFrameAvailability(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Ending Time', false, false)]
    local procedure JobPlanningLineEndingTimeOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("NPR Ending Time") then begin
            CheckTime(Rec."Planning Date", Rec."Planning Date", Rec."NPR Starting Time", Rec."NPR Ending Time");
            CalcResTimeQty(CurrFieldNo, Rec);
            CheckResTimeFrameAvailability(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure JobPlanningLineQuantityOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if Rec.Type = Rec.Type::Resource then begin
            if CurrFieldNo = Rec.FieldNo(Quantity) then begin
                CalcResTimeQty(CurrFieldNo, Rec);
                CheckResAvailability(Rec, xRec);
            end else begin
                if Rec.Quantity = 0 then begin
                    Rec.Validate("NPR Starting Time", 0T);
                    Rec.Validate("NPR Ending Time", 0T);
                end;
            end;
        end;
        CalcLineAmountInclVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure JobPlanningLineUnitPriceOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        UpdateUnitPriceInclVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Line Discount Amount', false, false)]
    local procedure JobPlanningLineLineDiscountAmountOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        CalcLineAmountInclVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Line Discount %', false, false)]
    local procedure JobPlanningLineLineDiscountPctOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        CalcLineAmountInclVAT(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Event Status', false, false)]
    local procedure JobPlanningLineEventStatusOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        CheckResAvailability(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 1022, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineInvoiceOnAfterInsert(var Rec: Record "Job Planning Line Invoice"; RunTrigger: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        case Rec."Document Type" of
            Rec."Document Type"::Invoice:
                if SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Document No.") then begin
                    SalesHeader."External Document No." := Rec."Job No.";
                    SalesHeader.Modify();
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeModifyEvent', '', true, true)]
    local procedure SalesLineOnBeforeModify(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        PostedDocType: Enum "Job Planning Line Invoice Document Type";
        JobPostLine: Codeunit "Job Post-Line";
    begin
        if not RunTrigger then
            exit;
        JobPlanningLineInvoice.SetRange("Line No.", Rec."Line No.");
        if not JobPlanningLineInvoiceExists(DATABASE::"Sales Header", Rec."Document Type", Rec."Document No.", JobPlanningLineInvoice, PostedDocType) then
            exit;
        if Rec."Job Contract Entry No." <> 0 then
            exit;
        JobPlanningLineInvoice.FindFirst();
        if not JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.") then
            exit;
        Rec."Job Contract Entry No." := JobPlanningLine."Job Contract Entry No.";
        JobPostLine.TestSalesLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure SalesLineOnBeforeDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        DocType: Enum "Job Planning Line Invoice Document Type";
        JobPlanningLine: Record "Job Planning Line";
    begin
        if not RunTrigger then
            exit;

        case Rec."Document Type" of
            Rec."Document Type"::Invoice:
                DocType := JobPlanningLineInvoice."Document Type"::Invoice;
            Rec."Document Type"::"Credit Memo":
                DocType := JobPlanningLineInvoice."Document Type"::"Credit Memo";
        end;
        if DocType = DocType::" " then
            exit;
        JobPlanningLineInvoice.SetRange("Document Type", DocType);
        JobPlanningLineInvoice.SetRange("Document No.", Rec."Document No.");
        JobPlanningLineInvoice.SetRange("Line No.", Rec."Line No.");
        if not JobPlanningLineInvoice.FindFirst() then
            exit;
        if not JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.") then
            exit;
        if (Rec."Job Contract Entry No." = 0) and (JobPlanningLine."Job Contract Entry No." <> 0) then
            Rec."Job Contract Entry No." := JobPlanningLine."Job Contract Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Job Contract Entry No.', true, true)]
    local procedure SalesLineJobContractEntryNoOnAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if CheckJobsSetup(0) then
            exit;
        if Rec."Job Contract Entry No." <> 0 then begin
            Rec."Job Contract Entry No." := 0;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, true)]
    local procedure SalesPostOnBeforePostSale(var SalesHeader: Record "Sales Header")
    begin
        if CheckJobsSetup(0) then
            exit;
        CheckSalesDoc(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure SalesPostOnAfterPostSale(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        PostedDocNo: Code[20];
        PostedDocType: Enum "Job Planning Line Invoice Document Type";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                PostedDocNo := SalesInvHdrNo;
            SalesHeader."Document Type"::"Credit Memo":
                PostedDocNo := SalesCrMemoHdrNo;
            else
                exit;
        end;
        if CheckJobsSetup(0) then
            exit;
        if not JobPlanningLineInvoiceExists(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", JobPlanningLineInvoice, PostedDocType) then
            exit;
        PostEventSalesDoc(JobPlanningLineInvoice, PostedDocType, PostedDocNo, SalesHeader."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure SaleLinePOSOnAfterDelete(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin
        if not RunTrigger then
            exit;
        POSQuoteEntry.SetRange("Register No.", Rec."Register No.");
        POSQuoteEntry.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        if not POSQuoteEntry.IsEmpty then
            exit;
        SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.");
        JobPlanningLineInvoice.SetRange("Document Type", JobPlanningLineInvoice."Document Type"::Invoice);
        JobPlanningLineInvoice.SetRange("Document No.", Rec."Sales Ticket No.");
        JobPlanningLineInvoice.SetRange("Line No.", Rec."Line No.");
        JobPlanningLineInvoice.SetRange("NPR POS Unit No.", Rec."Register No.");
        JobPlanningLineInvoice.SetRange("NPR POS Store Code", SalePOS."POS Store Code");
        if JobPlanningLineInvoice.FindSet() then
            repeat
                JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.");
                JobPlanningLineInvoice.Delete();
                JobPlanningLine.UpdateQtyToTransfer();
                JobPlanningLine.Modify();
            until JobPlanningLineInvoice.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnAfterPostPOSEntryBatch', '', true, true)]
    local procedure POSPostEntriesOnAfterPostPOSEntryBatch(var POSEntry: Record "NPR POS Entry"; PreviewMode: Boolean)
    var
        POSEntry2: Record "NPR POS Entry";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        PostedDocType: Enum "Job Planning Line Invoice Document Type";
        SkipThisEntry: Boolean;
    begin
        if PreviewMode then
            exit;

        POSEntry2.Copy(POSEntry);
        POSEntry2.SetRange("Post Item Entry Status", POSEntry2."Post Item Entry Status"::Posted);
        if POSEntry2.FindSet() then
            repeat
                POSSalesLine.SetRange("POS Entry No.", POSEntry2."Entry No.");
                POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
                SkipThisEntry := POSSalesLine.IsEmpty();
                if not SkipThisEntry then begin
                    JobPlanningLineInvoice.SetRange("NPR POS Unit No.", POSEntry2."POS Unit No.");
                    JobPlanningLineInvoice.SetRange("NPR POS Store Code", POSEntry2."POS Store Code");
                    SkipThisEntry := not JobPlanningLineInvoiceExists(DATABASE::"NPR POS Sale", Enum::"Sales Document Type".FromInteger(0), POSEntry2."Document No.", JobPlanningLineInvoice, PostedDocType);
                end;
                POSEntryNo := POSEntry2."Entry No.";
                POSDocPostType := POSDocPostType::"POS Entry";
                if not SkipThisEntry then
                    PostEventSalesDoc(JobPlanningLineInvoice, PostedDocType, POSEntry2."Document No.", POSEntry2."Posting Date");
            until POSEntry2.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151005, 'OnAfterLoadFromQuote', '', true, true)]
    local procedure POSActionLoadFromQuoteOnAfterLoadFromQuote(POSQuoteEntry: Record "NPR POS Saved Sale Entry"; var SalePOS: Record "NPR POS Sale")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        PostedDocType: Enum "Job Planning Line Invoice Document Type";
        JobPlanningLineInvoice2: Record "Job Planning Line Invoice";
    begin
        JobPlanningLineInvoice.SetRange("NPR POS Unit No.", POSQuoteEntry."Register No.");
        JobPlanningLineInvoice.SetRange("NPR POS Store Code", SalePOS."POS Store Code");
        if not JobPlanningLineInvoiceExists(DATABASE::"NPR POS Sale", Enum::"Sales Document Type".FromInteger(0), POSQuoteEntry."Sales Ticket No.", JobPlanningLineInvoice, PostedDocType) then
            exit;
        if JobPlanningLineInvoice.FindSet() then
            repeat
                JobPlanningLineInvoice2.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.", JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", JobPlanningLineInvoice."Line No.");
                JobPlanningLineInvoice2.Delete(true);
                JobPlanningLineInvoice2."Document No." := SalePOS."Sales Ticket No.";
                JobPlanningLineInvoice2."NPR POS Unit No." := SalePOS."Register No.";
                JobPlanningLineInvoice2."NPR POS Store Code" := SalePOS."POS Store Code";
                JobPlanningLineInvoice2.Insert(true);
            until JobPlanningLineInvoice.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, 463, 'OnAfterActionEvent', 'NPR SetStatusToBlockEventDelete', true, true)]
    local procedure SetStatusesToBlockEventDelete(var Rec: Record "Jobs Setup")
    var
        GenericMultipleCheckList: Page "NPR Gen. Multiple Check List";
        OutS: OutStream;
        OptionFilter: Text;
    begin
        GenericMultipleCheckList.SetOptions(GetJobEventStatusOptions(), GetBlockEventDeleteOptionFilter());
        GenericMultipleCheckList.LookupMode(true);
        if GenericMultipleCheckList.RunModal() = ACTION::LookupOK then begin
            OptionFilter := GenericMultipleCheckList.GetSelectedOption();
            if OptionFilter = '' then
                Clear(Rec."NPR Block Event Deletion")
            else begin
                Rec."NPR Block Event Deletion".CreateOutStream(OutS);
                OutS.Write(OptionFilter);
            end;
            Rec.Modify();
        end;
    end;

    local procedure CheckTime(StartDate: Date; EndDate: Date; StartTime: Time; EndTime: Time)
    var
        Job: Record Job;
        Text001: Label '%1 must be earlier than %2.';
    begin
        if StartDate = EndDate then
            if (StartTime > EndTime) and (StartTime <> 0T) and (EndTime <> 0T) then
                Error(Text001, Job.FieldCaption("NPR Starting Time"), Job.FieldCaption("NPR Ending Time"));
    end;

    local procedure CalcResTimeQty(FromFieldNo: Integer; var Rec: Record "Job Planning Line")
    var
        Job: Record Job;
    begin
        if not JobsSetup.Get() then
            exit;

        Job.Get(Rec."Job No.");
        if not IsEventJob(Job) then
            exit;

        if not (JobsSetup."NPR Qty. Rel. 2 Start/End Time" and (JobsSetup."NPR Time Calc. Unit of Measure" = Rec."Unit of Measure Code")) then
            exit;
        if Rec.Type <> Rec.Type::Resource then
            exit;
        if Rec."Planning Date" = 0D then
            exit;
        case FromFieldNo of
            Rec.FieldNo("NPR Ending Time"), Rec.FieldNo("No."):
                if Rec."NPR Ending Time" <> 0T then begin
                    if (Rec."NPR Starting Time" = 0T) and (Rec.Quantity > 0) then
                        Rec.Validate("NPR Starting Time", Rec."NPR Ending Time" - Rec.Quantity * 3600000);
                    if (Rec."NPR Starting Time" <> 0T) and (Rec.Quantity = 0) then
                        Rec.Validate(Quantity, Round((Rec."NPR Ending Time" - Rec."NPR Starting Time") / 3600000, 1 / 100000, '='));
                end;
            Rec.FieldNo("NPR Starting Time"):
                if Rec."NPR Starting Time" <> 0T then begin
                    if (Rec."NPR Ending Time" = 0T) and (Rec.Quantity > 0) then
                        Rec.Validate("NPR Ending Time", Rec."NPR Starting Time" + Rec.Quantity * 3600000);
                    if (Rec."NPR Ending Time" <> 0T) and (Rec.Quantity = 0) then
                        Rec.Validate(Quantity, Round((Rec."NPR Ending Time" - Rec."NPR Starting Time") / 3600000, 1 / 100000, '='));
                end;
            Rec.FieldNo(Quantity):
                if Rec.Quantity > 0 then begin
                    if (Rec."NPR Starting Time" <> 0T) and (Rec."NPR Ending Time" = 0T) then
                        Rec.Validate("NPR Ending Time", Rec."NPR Starting Time" + Rec.Quantity * 3600000);
                    if (Rec."NPR Starting Time" = 0T) and (Rec."NPR Ending Time" <> 0T) then
                        Rec.Validate("NPR Starting Time", Rec."NPR Ending Time" - Rec.Quantity * 3600000);
                end;
        end;
    end;

    procedure CheckResAvailability(Rec: Record "Job Planning Line"; xRec: Record "Job Planning Line") MsgToDisplay: Text
    var
        AvailCap: Decimal;
        Text002: Label 'Resource %1 is over capacitated on %2.';
        Text003: Label 'There are only %1 %2 available.';
        Text004: Label 'Please check Resource Availabilty for more details.';
        Job: Record Job;
        OverCapacitateResourceSetupValue: Integer;
    begin
        if not JobsSetup.Get() then
            exit;

        if not Job.Get(Rec."Job No.") then
            exit;

        if not IsEventJob(Job) then
            exit;

        if not InProperStatus(Job."NPR Event Status") then
            exit;

        if not Rec."Schedule Line" then
            exit;
        if Rec.Type <> Rec.Type::Resource then
            exit;
        if Rec."No." = '' then
            exit;
        if Rec.Quantity = 0 then
            exit;
        if Rec."Planning Date" = 0D then
            exit;
        if Rec."NPR Skip Cap./Avail. Check" then
            exit;
        if AllowOverCapacitateResource(Rec, OverCapacitateResourceSetupValue) then
            exit;
        if not IsResCapacityAvail(Rec, xRec, AvailCap) then begin
            MsgToDisplay := StrSubstNo(Text002, Rec."No.", Format(Rec."Planning Date"));
            if AvailCap > 0 then
                MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(Text003, Format(AvailCap), Rec."Unit of Measure Code");
            if BufferMode then
                exit(MsgToDisplay);
            if OverCapacitateResourceSetupValue = JobsSetup."NPR Over Capacitate Resource"::Disallow.AsInteger() then
                Error(MsgToDisplay);
            MsgToDisplay := MsgToDisplay + ' ' + Text004 + ' ' + ContinueMsg;
            if not Confirm(MsgToDisplay) then
                Error('');
        end;
        MsgToDisplay := CheckResTimeFrameAvailability(Rec);

    end;

    local procedure IsResCapacityAvail(Rec: Record "Job Planning Line"; xRec: Record "Job Planning Line"; var AvailCap: Decimal): Boolean
    var
        Resource: Record Resource;
        TotalCapacity: Decimal;
    begin
        Resource.Get(Rec."No.");
        Resource.SetFilter("Date Filter", Format(Rec."Planning Date"));
        Resource.CalcFields("Qty. on Order (Job)", "Qty. Quoted (Job)", Capacity, "NPR Qty. Planned (Job)");
        TotalCapacity := Resource."Qty. on Order (Job)" + Resource."Qty. Quoted (Job)" + Resource."NPR Qty. Planned (Job)";
        if xRec.Quantity > 0 then
            TotalCapacity -= xRec.Quantity;
        AvailCap := Resource.Capacity - TotalCapacity;
        exit((Resource.Capacity = 0) or ((Resource.Capacity > 0) and (Rec.Quantity + TotalCapacity <= Resource.Capacity)));

    end;

    procedure CheckResTimeFrameAvailability(Rec: Record "Job Planning Line") MsgToDisplay: Text
    var
        TimeFrameProblemMsg: Label 'Time frame %1 - %2 for resource %3 is allready partially/fully used on other event/line:\%4 If you keep current time frame, resource may have difficulties fulfilling all engagements.';
        OverCapacitateResourceSetupValue: Integer;
    begin
        if Rec.Type <> Rec.Type::Resource then
            exit;
        if Rec."NPR Skip Cap./Avail. Check" then
            exit;
        if AllowOverCapacitateResource(Rec, OverCapacitateResourceSetupValue) then
            exit;
        if not IsResTimeFrameAvail(Rec, MsgToDisplay) then begin
            MsgToDisplay := StrSubstNo(TimeFrameProblemMsg, Format(Rec."NPR Starting Time"), Format(Rec."NPR Ending Time"), Rec."No.", MsgToDisplay);
            if BufferMode then
                exit(MsgToDisplay);
            if OverCapacitateResourceSetupValue = JobsSetup."NPR Over Capacitate Resource"::Disallow.AsInteger() then
                Error(MsgToDisplay);
            MsgToDisplay := MsgToDisplay + '\' + ContinueMsg;
            if not Confirm(MsgToDisplay) then
                Error('');
        end;
    end;

    local procedure IsResTimeFrameAvail(Rec: Record "Job Planning Line"; var MsgToDisplay: Text): Boolean
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if (Rec."NPR Starting Time" = 0T) or (Rec."NPR Ending Time" = 0T) then
            exit(true);
        if Rec.Type <> Rec.Type::Resource then
            exit(true);
        if Rec."No." = '' then
            exit(true);

        JobPlanningLine.SetFilter("NPR Event Status", '<=%1', JobPlanningLine."NPR Event Status"::Order);
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetRange("No.", Rec."No.");
        JobPlanningLine.SetRange("Planning Date", Rec."Planning Date");
        JobPlanningLine.SetRange("Schedule Line", true);

        JobPlanningLine.SetFilter("Job No.", '<>%1', Rec."Job No.");
        ApplyTimeCombinations(JobPlanningLine, Rec);
        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine.SetFilter("Job Task No.", '<>%1', Rec."Job Task No.");
        ApplyTimeCombinations(JobPlanningLine, Rec);
        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
        JobPlanningLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
        ApplyTimeCombinations(JobPlanningLine, Rec);
        JobPlanningLine.SetRange("Job No.");
        JobPlanningLine.SetRange("Job Task No.");
        JobPlanningLine.SetRange("Line No.");
        JobPlanningLine.MarkedOnly(true);
        AddToMessage(JobPlanningLine, MsgToDisplay);
        exit(MsgToDisplay = '');
    end;

    local procedure ApplyTimeCombinations(var JobPlanningLine: Record "Job Planning Line"; Rec: Record "Job Planning Line")
    begin
        JobPlanningLine.SetFilter("NPR Starting Time", '<=%1', Rec."NPR Starting Time");
        JobPlanningLine.SetFilter("NPR Ending Time", '>=%1', Rec."NPR Ending Time");
        MarkPlanningLine(JobPlanningLine);
        JobPlanningLine.SetFilter("NPR Ending Time", '<=%1&>%2', Rec."NPR Ending Time", Rec."NPR Starting Time");
        MarkPlanningLine(JobPlanningLine);

        JobPlanningLine.SetFilter("NPR Starting Time", '>%1', Rec."NPR Starting Time");
        JobPlanningLine.SetFilter("NPR Ending Time", '<%1', Rec."NPR Ending Time");
        MarkPlanningLine(JobPlanningLine);

        JobPlanningLine.SetFilter("NPR Starting Time", '>=%1&<%2', Rec."NPR Starting Time", Rec."NPR Ending Time");
        JobPlanningLine.SetFilter("NPR Ending Time", '>=%1', Rec."NPR Ending Time");
        MarkPlanningLine(JobPlanningLine);
        JobPlanningLine.SetRange("NPR Starting Time");
        JobPlanningLine.SetRange("NPR Ending Time");

    end;

    local procedure MarkPlanningLine(var JobPlanningLine: Record "Job Planning Line")
    begin
        if JobPlanningLine.FindSet() then
            repeat
                JobPlanningLine.Mark(true);
            until JobPlanningLine.Next() = 0;
    end;

    local procedure AddToMessage(var JobPlanningLine: Record "Job Planning Line"; var MsgToDisplay: Text)
    begin
        if JobPlanningLine.FindSet() then
            repeat
                MsgToDisplay += JobPlanningLine."Job No." + ' ' + Format(JobPlanningLine."NPR Starting Time") + ' - ' + Format(JobPlanningLine."NPR Ending Time") + '\';
            until JobPlanningLine.Next() = 0;
    end;

    procedure IsEventJob(Job: Record Job): Boolean
    begin
        exit(Job."NPR Event");
    end;

    local procedure DeleteActivityLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", JobPlanningLine.RecordId);
        ActivityLog.DeleteAll();
    end;

    local procedure InProperStatus(Status: Enum "NPR Event Status"): Boolean
    begin
        exit(Status.AsInteger() < 3);
    end;

    procedure SaveReportAs(Job: Record Job; TemplateType: Option Customer,Team; SaveAs: Option Word,PDF; var TempBlob: Codeunit "Temp Blob")
    var
        CurrentJob: Record Job;
        RecRef: RecordRef;
        DataTypeMgt: Codeunit "Data Type Management";
        OutStr: OutStream;
        ReportID: Integer;
    begin
        CurrentJob.Copy(Job);
        CurrentJob.SetRecFilter();
        case TemplateType of
            TemplateType::Customer:
                ReportID := REPORT::"NPR Event Customer Template";
            TemplateType::Team:
                ReportID := REPORT::"NPR Event Team Template";
        end;
        DataTypeMgt.GetRecordRef(CurrentJob, RecRef);
        TempBlob.CreateOutStream(OutStr);
        case SaveAs of
            SaveAs::Word:
                Report.SaveAs(ReportID, '', ReportFormat::Word, OutStr, RecRef);
            SaveAs::PDF:
                Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);
        end;
    end;

    procedure CopyTemplates(FromEventNo: Code[20]; ToEventNo: Code[20]; CopyWhatHere: Option All,Customer,Team; var ReturnMsg: Text): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
        EventWordLayoutFrom: Record "NPR Event Word Layout";
        EventWordLayoutTo: Record "NPR Event Word Layout";
    begin
        JobFrom.Get(FromEventNo);
        JobTo.Get(ToEventNo);
        EventWordLayoutFrom.SetRange("Source Record ID", JobFrom.RecordId);
        if CopyWhatHere > 0 then
            EventWordLayoutFrom.SetRange(Usage, CopyWhatHere);
        if EventWordLayoutFrom.FindSet() then begin
            repeat
                EventWordLayoutFrom.CalcFields(Layout, "XML Part", "Request Page Parameters");
                EventWordLayoutTo.Init();
                EventWordLayoutTo := EventWordLayoutFrom;
                EventWordLayoutTo."Source Record ID" := JobTo.RecordId;
                EventWordLayoutTo.Insert(true);
            until EventWordLayoutFrom.Next() = 0;
            exit(true);
        end;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    procedure MergeAndSaveWordLayout(EventWordLayout: Record "NPR Event Word Layout"; SaveAs: Option Word,Pdf; FileName: Text)
    var
        Job: Record Job;
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        DataTypeMgt: Codeunit "Data Type Management";
        InStrWordDoc: InStream;
        InStrParameters: InStream;
        OutStrWordDoc, OutStr : OutStream;
        InStrXmlData: InStream;
        FileExtension: Text;
        ExtensionMismatch: Label 'Provided file extension %1 can''t be used on file type %2.';
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        Parameters: Text;
    begin
        EventWordLayout.GetJobFromRecID(Job);
        Job.SetRecFilter();
        ValidateAndUpdateWordLayoutOnRecord(EventWordLayout);
        EventWordLayout.CalcFields(Layout);
        EventWordLayout.Layout.CreateInStream(InStrWordDoc);
        if EventWordLayout."Request Page Parameters".HasValue() then begin
            EventWordLayout.CalcFields("Request Page Parameters");
            EventWordLayout."Request Page Parameters".CreateInStream(InStrParameters);
            InStrParameters.ReadText(Parameters);
        end;
        ValidateWordLayoutCheckOnly(EventWordLayout."Report ID", InStrWordDoc);
        TempBlob.CreateOutStream(OutStrWordDoc);

        Case EventWordLayout.Usage of
            EventWordLayout.Usage::Customer:
                begin
                    DataTypeMgt.GetRecordRef(Job, RecRef);
                    TempBlob.CreateOutStream(OutStr);
                    Report.SaveAs(Report::"NPR Event Customer Template", Parameters, ReportFormat::Xml, OutStr, RecRef);
                end;
            EventWordLayout.Usage::Team:
                begin
                    DataTypeMgt.GetRecordRef(Job, RecRef);
                    TempBlob.CreateOutStream(OutStr);
                    Report.SaveAs(Report::"NPR Event Team Template", Parameters, ReportFormat::Xml, OutStr, RecRef);
                end;
        end;
        TempBlob.CreateInStream(InStrXmlData);
        EventVersionSpecificMgt.WordXMLMergerMergeWordDocument(InStrWordDoc, InStrXmlData, OutStrWordDoc, OutStrWordDoc);

        FileExtension := 'docx';
        if SaveAs = SaveAs::Pdf then begin
            FileExtension := 'pdf';
            ConvertWordToPdf(TempBlob);
        end;

        if FileName = '' then begin
            FileName := EventEWSMgt.CreateFileName(Job, EMailTemplateHeader) + '.' + FileExtension;
        end else begin
            if FileMgt.GetExtension(FileName) <> FileExtension then
                Error(ExtensionMismatch, FileMgt.GetExtension(FileName), Format(SaveAs));
        end;
        FileMgt.BLOBExport(TempBlob, FileName, true);
    end;

    local procedure ValidateWordLayoutCheckOnly(ReportID: Integer; DocumentStream: InStream)
    var
        ValidationErrors: Text;
        ValidationErrorFormat: Text;
        TemplateAfterUpdateValidationErr: Label 'The automatic update could not resolve all the conflicts in the current Word layout. For example, the layout uses fields that are missing in the report design or the report ID is wrong.\The following errors were detected:\%1\You must manually update the layout to match the current report design.';
    begin
        ValidationErrors := EventVersionSpecificMgt.WordXMLMergerValidateWordDocumentTemplate(DocumentStream, REPORT.WordXmlPart(ReportID, true));
        if ValidationErrors <> '' then begin
            ValidationErrorFormat := TemplateAfterUpdateValidationErr;
            Message(ValidationErrorFormat, ValidationErrors);
        end;
    end;

    local procedure ValidateAndUpdateWordLayoutOnRecord(EventWordLayout: Record "NPR Event Word Layout"): Boolean
    var
        DocumentStream: InStream;
        ValidationErrors: Text;
        TemplateValidationUpdateQst: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the layout validation:\%1\Do you want to run an automatic update?';
        TemplateValidationErr: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the document validation:\%1\You must update the layout to match the current report design.';
    begin
        EventWordLayout.CalcFields(Layout);
        EventWordLayout.Layout.CreateInStream(DocumentStream);
        EventVersionSpecificMgt.WordXMLMergerConstructor();
        ValidationErrors := EventVersionSpecificMgt.WordXMLMergerValidateWordDocumentTemplate(DocumentStream, REPORT.WordXmlPart(EventWordLayout."Report ID", true));
        if ValidationErrors <> '' then begin
            if Confirm(TemplateValidationUpdateQst, false, ValidationErrors) then begin
                ValidationErrors := EventWordLayout.TryUpdateLayout(false);
                Commit();
                exit(true);
            end;
            Error(TemplateValidationErr, ValidationErrors);
        end;
        exit(false);

    end;

    procedure ConvertWordToPdf(var TempBlob: Codeunit "Temp Blob")
    var
        TempBlobPdf: Codeunit "Temp Blob";
        InStreamWordDoc: InStream;
        OutStreamPdfDoc: OutStream;
    begin
        TempBlob.CreateInStream(InStreamWordDoc);
        TempBlobPdf.CreateOutStream(OutStreamPdfDoc);
        EventVersionSpecificMgt.PdfWriterConvertToPdf(InStreamWordDoc, OutStreamPdfDoc);
        TempBlob := TempBlobPdf;
    end;

    local procedure GetOverCapacitateResourceSetup(JobPlanningLine: Record "Job Planning Line") SetupValue: Integer
    var
        Resource: Record Resource;
    begin
        Resource.Get(JobPlanningLine."No.");
        SetupValue := Resource."NPR Over Capacitate Resource".AsInteger();
        if SetupValue = 0 then
            SetupValue := JobsSetup."NPR Over Capacitate Resource".AsInteger();
        exit(SetupValue);
    end;

    local procedure CopyExchIntTemplates(FromEventNo: Code[20]; ToEventNo: Code[20]; var ReturnMsg: Text): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
        EventExchIntTempEntryFrom: Record "NPR Event Exch.Int.Temp.Entry";
        EventExchIntTempEntryTo: Record "NPR Event Exch.Int.Temp.Entry";
    begin
        JobFrom.Get(FromEventNo);
        JobTo.Get(ToEventNo);
        EventExchIntTempEntryFrom.SetRange("Source Record ID", JobFrom.RecordId);
        if EventExchIntTempEntryFrom.FindSet() then begin
            repeat
                EventExchIntTempEntryTo.Init();
                EventExchIntTempEntryTo := EventExchIntTempEntryFrom;
                EventExchIntTempEntryTo."Source Record ID" := JobTo.RecordId;
                EventExchIntTempEntryTo.Insert();
            until EventExchIntTempEntryFrom.Next() = 0;
            exit(true);
        end;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    local procedure RelatedSalesInvoiceCreditMemoExists(Rec: Record Job): Boolean
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        JobPlanningLineInvoice.SetRange("Job No.", Rec."No.");
        exit(not JobPlanningLineInvoice.IsEmpty());
    end;

    local procedure JobLedgEntryExist(Rec: Record Job): Boolean
    var
        JobLedgEntry: Record "Job Ledger Entry";
    begin
        Clear(JobLedgEntry);
        JobLedgEntry.SetCurrentKey("Job No.");
        JobLedgEntry.SetRange("Job No.", Rec."No.");
        exit(not JobLedgEntry.IsEmpty());
    end;

    procedure AllowOverCapacitateResource(Rec: Record "Job Planning Line"; var OverCapacitateResourceSetupValue: Integer): Boolean
    begin
        JobsSetup.Get();
        OverCapacitateResourceSetupValue := GetOverCapacitateResourceSetup(Rec);
        exit(OverCapacitateResourceSetupValue in [JobsSetup."NPR Over Capacitate Resource"::" ".AsInteger(), JobsSetup."NPR Over Capacitate Resource"::Allow.AsInteger()]);
    end;

    local procedure FindJobUnitPriceInclVAT(var JobPlanningLine: Record "Job Planning Line")
    var
        Job: Record Job;
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        Item: Record Item;
        Resource: Record Resource;
        VATBusPostGroup: Code[20];
        VATProdPostGroup: Code[20];
    begin
        Job.Get(JobPlanningLine."Job No.");
        if Customer.Get(Job."Bill-to Customer No.") then
            VATBusPostGroup := Customer."VAT Bus. Posting Group";
        case JobPlanningLine.Type of
            JobPlanningLine.Type::Item:
                if Item.Get(JobPlanningLine."No.") then
                    VATProdPostGroup := Item."VAT Prod. Posting Group";
            JobPlanningLine.Type::Resource:
                if Resource.Get(JobPlanningLine."No.") then
                    VATProdPostGroup := Resource."VAT Prod. Posting Group";
        end;
        if not VATPostingSetup.Get(VATBusPostGroup, VATProdPostGroup) then
            Clear(VATPostingSetup);
        if not (VATPostingSetup."VAT Calculation Type" in [VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT", VATPostingSetup."VAT Calculation Type"::"Sales Tax"]) then
            JobPlanningLine."NPR Est. VAT %" := VATPostingSetup."VAT %";
        UpdateUnitPriceInclVAT(JobPlanningLine);
    end;

    local procedure UpdateUnitPriceInclVAT(var JobPlanningLine: Record "Job Planning Line")
    begin
        if not RoundingSet then
            SetRoundingPrecision(JobPlanningLine."Currency Code");
        JobPlanningLine."NPR Est. Unit Price Incl. VAT" := Round(JobPlanningLine."Unit Price" * (1 + JobPlanningLine."NPR Est. VAT %" / 100), UnitAmountRoundingPrecisionFCY);
        JobPlanningLine."NPR Est. U.Price Inc VAT (LCY)" := Round(JobPlanningLine."Unit Price (LCY)" * (1 + JobPlanningLine."NPR Est. VAT %" / 100), UnitAmountRoundingPrecision);
        CalcLineAmountInclVAT(JobPlanningLine);
    end;

    local procedure CalcLineAmountInclVAT(var JobPlanningLine: Record "Job Planning Line")
    begin
        if not RoundingSet then
            SetRoundingPrecision(JobPlanningLine."Currency Code");
        JobPlanningLine."NPR Est. Line Amount Incl. VAT" := Round(JobPlanningLine."Line Amount" * (1 + JobPlanningLine."NPR Est. VAT %" / 100), AmountRoundingPrecisionFCY);
        JobPlanningLine."NPR Est. L.Amt. Inc VAT (LCY)" := Round(JobPlanningLine."Line Amount (LCY)" * (1 + JobPlanningLine."NPR Est. VAT %" / 100), AmountRoundingPrecision);
    end;

    local procedure SetRoundingPrecision(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        Clear(Currency);
        Currency.InitRoundingPrecision();
        AmountRoundingPrecision := Currency."Amount Rounding Precision";
        UnitAmountRoundingPrecision := Currency."Unit-Amount Rounding Precision";
        if CurrencyCode <> '' then begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        AmountRoundingPrecisionFCY := Currency."Amount Rounding Precision";
        UnitAmountRoundingPrecisionFCY := Currency."Unit-Amount Rounding Precision";
        RoundingSet := true;
    end;

    local procedure CopyComments(FromEventNo: Code[20]; ToEventNo: Code[20]; var ReturnMsg: Text): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
        CommentLineFrom: Record "Comment Line";
        CommentLineTo: Record "Comment Line";
    begin
        JobFrom.Get(FromEventNo);
        JobTo.Get(ToEventNo);
        CommentLineFrom.SetRange("Table Name", CommentLineFrom."Table Name"::Job);
        CommentLineFrom.SetRange("No.", FromEventNo);
        if CommentLineFrom.FindSet() then
            repeat
                CommentLineTo := CommentLineFrom;
                CommentLineTo."No." := ToEventNo;
                CommentLineTo.Insert();
            until CommentLineFrom.Next() = 0;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    local procedure CalcLineAmountLCY(JobPlanningLine: Record "Job Planning Line"; Qty: Decimal): Decimal
    var
        TotalPrice: Decimal;
    begin
        TotalPrice := Round(Qty * JobPlanningLine."Unit Price (LCY)", 0.01);
        exit(TotalPrice - Round(TotalPrice * JobPlanningLine."Line Discount %" / 100, 0.01));
    end;

    procedure PostEventSalesDoc(var JobPlanningLineInvoice: Record "Job Planning Line Invoice"; PostedDocType: Enum "Job Planning Line Invoice Document Type"; PostedDocNo: Code[20];
                                                                                                                   PostingDate: Date)
    var
        JobPlanningLineInvoice2: Record "Job Planning Line Invoice";
    begin
        ChangeJobPlanInvoiceFromNonpostedToPosted(JobPlanningLineInvoice, PostedDocType, PostedDocNo, PostingDate, JobPlanningLineInvoice2);
        if not CheckJobsSetup(2) then
            exit;
        InitJobRegister();
        PrepareAndPostJournal(JobPlanningLineInvoice2);
    end;

    procedure CheckJobsSetup(ProcessStep: Option Creation,PostingInventoryOnly,PostingBothInventoryAndJob): Boolean
    begin
        JobsSetup.Get();
        case ProcessStep of
            ProcessStep::Creation:
                exit(JobsSetup."NPR Post Event on S.Inv. Post" = JobsSetup."NPR Post Event on S.Inv. Post"::" ");
            ProcessStep::PostingInventoryOnly:
                exit(JobsSetup."NPR Post Event on S.Inv. Post" = JobsSetup."NPR Post Event on S.Inv. Post"::"Only Inventory");
            ProcessStep::PostingBothInventoryAndJob:
                exit(JobsSetup."NPR Post Event on S.Inv. Post" = JobsSetup."NPR Post Event on S.Inv. Post"::"Both Inventory and Job");
        end;
    end;

    local procedure CheckSalesDoc(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        JobPlanningLine: Record "Job Planning Line";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        PostedDocType: Enum "Job Planning Line Invoice Document Type";
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        JobPlanningLineInvoiceExists(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", JobPlanningLineInvoice, PostedDocType);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>0');
        if SalesLine.FindSet() then
            repeat
                if (SalesLine."Job Contract Entry No." = 0) and (SalesLine."Job No." <> '') and (SalesLine."Job Task No." <> '') then begin
                    JobPlanningLineInvoice.SetRange("Line No.", SalesLine."Line No.");
                    if JobPlanningLineInvoice.FindFirst() then begin
                        JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.");
                        Job.Get(JobPlanningLine."Job No.");
                        Job.TestBlocked();
                        Job.TestField(Status, Job.Status::Open);
                        JobTask.Get(SalesLine."Job No.", SalesLine."Job Task No.");
                        JobTask.TestField("Job Task Type", JobTask."Job Task Type"::Posting);
                        if Job."Invoice Currency Code" = '' then begin
                            Job.TestField("Currency Code", SalesHeader."Currency Code");
                            Job.TestField("Currency Code", JobPlanningLine."Currency Code");
                            SalesHeader.TestField("Currency Code", JobPlanningLine."Currency Code");
                            SalesHeader.TestField("Currency Factor", JobPlanningLine."Currency Factor");
                        end else begin
                            Job.TestField("Currency Code", '');
                            JobPlanningLine.TestField("Currency Code", '');
                        end;
                        SalesHeader.TestField("Bill-to Customer No.", Job."Bill-to Customer No.");
                        JobPlanningLine.CalcFields("Qty. Transferred to Invoice");
                        if JobPlanningLine.Type <> JobPlanningLine.Type::Text then
                            JobPlanningLine.TestField("Qty. Transferred to Invoice");
                        ValidateRelationship(SalesHeader, SalesLine, JobPlanningLine);
                    end;
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure JobPlanningLineInvoiceExists(DocTableID: Integer; DocType: Enum "Sales Document Type"; DocNo: Code[20]; var JobPlanningLineInvoice: Record "Job Planning Line Invoice"; var PostedDocType: Enum "Job Planning Line Invoice Document Type"): Boolean
    var
        SalesHeader: Record "Sales Header";
        JobPlanInvLineDocType: Enum "Job Planning Line Invoice Document Type";
    begin
        PostedDocType := PostedDocType::" ";
        case DocTableID of
            DATABASE::"Sales Header":
                case DocType of
                    SalesHeader."Document Type"::Invoice:
                        begin
                            JobPlanInvLineDocType := JobPlanningLineInvoice."Document Type"::Invoice;
                            PostedDocType := JobPlanningLineInvoice."Document Type"::"Posted Invoice";
                        end;
                    SalesHeader."Document Type"::"Credit Memo":
                        begin
                            JobPlanInvLineDocType := JobPlanningLineInvoice."Document Type"::"Credit Memo";
                            PostedDocType := JobPlanningLineInvoice."Document Type"::"Posted Credit Memo";
                        end;
                end;
            DATABASE::"NPR POS Sale":
                begin
                    JobPlanInvLineDocType := JobPlanningLineInvoice."Document Type"::Invoice;
                    PostedDocType := JobPlanningLineInvoice."Document Type"::"Posted Invoice";
                end;
        end;
        JobPlanningLineInvoice.SetRange("Document Type", JobPlanInvLineDocType);
        JobPlanningLineInvoice.SetRange("Document No.", DocNo);
        exit(not JobPlanningLineInvoice.IsEmpty());
    end;

    local procedure ChangeJobPlanInvoiceFromNonpostedToPosted(var NonPostedJobPlanningLineInvoice: Record "Job Planning Line Invoice"; PostedDocType: Enum "Job Planning Line Invoice Document Type"; PostedDocNo: Code[20];
                                                                                                                                                          PostingDate: Date; var PostedJobPlanningLineInvoice: Record "Job Planning Line Invoice")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        NextEntryNo: Integer;
    begin
        Clear(PostedJobPlanningLineInvoice);
        if NonPostedJobPlanningLineInvoice.FindSet() then
            repeat
                JobPlanningLineInvoice.Get(NonPostedJobPlanningLineInvoice."Job No.", NonPostedJobPlanningLineInvoice."Job Task No.", NonPostedJobPlanningLineInvoice."Job Planning Line No.",
                                            NonPostedJobPlanningLineInvoice."Document Type", NonPostedJobPlanningLineInvoice."Document No.", NonPostedJobPlanningLineInvoice."Line No.");
                JobPlanningLine.Get(NonPostedJobPlanningLineInvoice."Job No.", NonPostedJobPlanningLineInvoice."Job Task No.", NonPostedJobPlanningLineInvoice."Job Planning Line No.");
                JobPlanningLineInvoice.Delete(true);
                JobPlanningLineInvoice."Document Type" := PostedDocType;
                JobPlanningLineInvoice."Document No." := PostedDocNo;
                JobPlanningLineInvoice.Insert(true);
                JobPlanningLineInvoice."Invoiced Date" := PostingDate;
                JobPlanningLineInvoice."Invoiced Amount (LCY)" := CalcLineAmountLCY(JobPlanningLine, JobPlanningLineInvoice."Quantity Transferred");
                JobPlanningLineInvoice."Invoiced Cost Amount (LCY)" := JobPlanningLineInvoice."Quantity Transferred" * JobPlanningLine."Unit Cost (LCY)";
                JobPlanningLineInvoice."Job Ledger Entry No." := NextEntryNo;
                JobPlanningLineInvoice.Modify();
                JobPlanningLine.UpdateQtyToInvoice();
                JobPlanningLine.Modify();
            until NonPostedJobPlanningLineInvoice.Next() = 0;
        PostedJobPlanningLineInvoice.SetRange("Document Type", PostedDocType);
        PostedJobPlanningLineInvoice.SetRange("Document No.", PostedDocNo);
    end;

    local procedure InitJobRegister()
    var
        JobLedgEntry: Record "Job Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
        JobRegNo: Integer;
    begin
        if JobRegisterInitialized then
            exit;
        SourceCodeSetup.Get();
        JobLedgEntry.LockTable();
        if JobLedgEntry.FindLast() then
            NextEntryNo := JobLedgEntry."Entry No.";
        NextEntryNo := NextEntryNo + 1;

        JobReg.LockTable();
        if JobReg.FindLast() then
            JobRegNo := JobReg."No.";
        JobRegNo := JobRegNo + 1;

        JobReg.Init();
        JobReg."No." := JobRegNo;
        JobReg."From Entry No." := NextEntryNo;
        JobReg."To Entry No." := NextEntryNo;
        JobReg."Creation Date" := Today();
        JobReg."Source Code" := SourceCodeSetup.Sales;
        JobReg."Journal Batch Name" := '';
        JobReg."User ID" := UserId;
        JobReg.Insert();
        JobRegisterInitialized := true;
    end;

    local procedure PrepareAndPostJournal(var JobPlanningLineInvoice: Record "Job Planning Line Invoice")
    var
        JobJnlLine: Record "Job Journal Line";
    begin
        if JobPlanningLineInvoice.FindSet() then
            repeat
                PrepareJobJournal(JobPlanningLineInvoice, JobJnlLine."Entry Type"::Usage, JobJnlLine); //Usage
                PostJournal(JobPlanningLineInvoice, JobJnlLine);
                PrepareJobJournal(JobPlanningLineInvoice, JobJnlLine."Entry Type"::Sale, JobJnlLine); //Sale
                PostJournal(JobPlanningLineInvoice, JobJnlLine);
            until JobPlanningLineInvoice.Next() = 0;
    end;

    local procedure PrepareJobJournal(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; EntryType: Enum "Job Journal Line Entry Type"; var JobJnlLine: Record "Job Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobTask: Record "Job Task";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SourceCodeSetup: Record "Source Code Setup";
        Item: Record Item;
        DocumentDate: Date;
        DocumentNo: Code[20];
        PostingGroup: Code[20];
        GenBusPostGroup: Code[20];
        GenProdPostGroup: Code[20];
        Description: Text;
        Description2: Text;
        UnitOfMeasureCode: Code[10];
        QtyPerUoM: Decimal;
        LocationCode: Code[10];
        BinCode: Code[20];
        ReasonCode: Code[10];
        ExternalDocNo: Code[35];
        TransportMethod: Code[10];
        TransactionType: Code[10];
        TransactionSpecification: Code[10];
        EntryExitPoint: Code[10];
        "Area": Code[10];
        Quantity: Decimal;
        CurrencyFactor: Decimal;
        UnitCost: Decimal;
        UnitCostLCY: Decimal;
        LineDiscPerc: Decimal;
        ShortcutDimCode1: Code[20];
        ShortcutDimCode2: Code[20];
        DimSetID: Integer;
#if not BC17
        OrdinalValue: Integer;
#endif
    begin
        JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.");
        SourceCodeSetup.Get();
        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        Clear(JobJnlLine);

        case EntryType of
            EntryType::Sale:
                begin
                    case JobPlanningLineInvoice."Document Type" of
                        JobPlanningLineInvoice."Document Type"::"Posted Invoice":
                            begin
                                case POSDocPostType of
                                    POSDocPostType::" ":
                                        begin
                                            SalesInvHeader.Get(JobPlanningLineInvoice."Document No.");
                                            SalesInvLine.Get(JobPlanningLineInvoice."Document No.", JobPlanningLineInvoice."Line No.");
                                            DocumentDate := SalesInvHeader."Document Date";
                                            DocumentNo := SalesInvLine."Document No.";
                                            PostingGroup := SalesInvLine."Posting Group";
                                            GenBusPostGroup := SalesInvLine."Gen. Bus. Posting Group";
                                            GenProdPostGroup := SalesInvLine."Gen. Prod. Posting Group";
                                            Description := SalesInvLine.Description;
                                            Description2 := SalesInvLine."Description 2";
                                            UnitOfMeasureCode := SalesInvLine."Unit of Measure Code";
                                            QtyPerUoM := SalesInvLine."Qty. per Unit of Measure";
                                            LocationCode := SalesInvLine."Location Code";
                                            BinCode := SalesInvLine."Bin Code";
                                            ReasonCode := SalesInvHeader."Reason Code";
                                            ExternalDocNo := SalesInvHeader."External Document No.";
                                            TransportMethod := SalesInvLine."Transport Method";
                                            TransactionType := SalesInvLine."Transaction Type";
                                            TransactionSpecification := SalesInvLine."Transaction Specification";
                                            EntryExitPoint := SalesInvLine."Exit Point";
                                            Area := SalesInvLine.Area;
                                            Quantity := SalesInvLine.Quantity;
                                            CurrencyFactor := SalesInvHeader."Currency Factor";
                                            UnitCost := SalesInvLine."Unit Cost";
                                            UnitCostLCY := SalesInvLine."Unit Cost (LCY)";
                                            LineDiscPerc := SalesInvLine."Line Discount %";
                                            ShortcutDimCode1 := SalesInvLine."Shortcut Dimension 1 Code";
                                            ShortcutDimCode2 := SalesInvLine."Shortcut Dimension 2 Code";
                                            DimSetID := SalesInvLine."Dimension Set ID";
                                        end;
                                    POSDocPostType::"POS Entry":
                                        begin
                                            POSEntry.Get(POSEntryNo);
                                            POSSalesLine.Get(POSEntry."Entry No.", JobPlanningLineInvoice."Line No.");
                                            DocumentDate := POSEntry."Document Date";
                                            DocumentNo := POSSalesLine."Document No.";
                                            PostingGroup := POSSalesLine."Posting Group";
                                            GenBusPostGroup := POSSalesLine."Gen. Bus. Posting Group";
                                            GenProdPostGroup := POSSalesLine."Gen. Prod. Posting Group";
                                            Description := POSSalesLine.Description;
                                            UnitOfMeasureCode := POSSalesLine."Unit of Measure Code";
                                            QtyPerUoM := POSSalesLine."Qty. per Unit of Measure";
                                            LocationCode := POSSalesLine."Location Code";
                                            BinCode := POSSalesLine."Bin Code";
                                            ReasonCode := POSEntry."Reason Code";
                                            Quantity := POSSalesLine.Quantity;
                                            CurrencyFactor := POSEntry."Currency Factor";
                                            UnitCost := POSSalesLine."Unit Cost";
                                            UnitCostLCY := POSSalesLine."Unit Cost (LCY)";
                                            LineDiscPerc := POSSalesLine."Line Discount %";
                                            ShortcutDimCode1 := POSSalesLine."Shortcut Dimension 1 Code";
                                            ShortcutDimCode2 := POSSalesLine."Shortcut Dimension 2 Code";
                                            DimSetID := POSSalesLine."Dimension Set ID";
                                        end;
                                end;
                            end;
                        JobPlanningLineInvoice."Document Type"::"Posted Credit Memo":
                            begin
                                SalesCrMemoHeader.Get(JobPlanningLineInvoice."Document No.");
                                SalesCrMemoLine.Get(JobPlanningLineInvoice."Document No.", JobPlanningLineInvoice."Line No.");
                                DocumentDate := SalesCrMemoHeader."Document Date";
                                DocumentNo := SalesCrMemoLine."Document No.";
                                PostingGroup := SalesCrMemoLine."Posting Group";
                                GenBusPostGroup := SalesCrMemoLine."Gen. Bus. Posting Group";
                                GenProdPostGroup := SalesCrMemoLine."Gen. Prod. Posting Group";
                                Description := SalesCrMemoLine.Description;
                                Description2 := SalesCrMemoLine."Description 2";
                                UnitOfMeasureCode := SalesCrMemoLine."Unit of Measure Code";
                                QtyPerUoM := SalesCrMemoLine."Qty. per Unit of Measure";
                                LocationCode := SalesCrMemoLine."Location Code";
                                BinCode := SalesCrMemoLine."Bin Code";
                                ReasonCode := SalesCrMemoHeader."Reason Code";
                                ExternalDocNo := SalesCrMemoHeader."External Document No.";
                                TransportMethod := SalesCrMemoLine."Transport Method";
                                TransactionType := SalesCrMemoLine."Transaction Type";
                                TransactionSpecification := SalesCrMemoLine."Transaction Specification";
                                EntryExitPoint := SalesCrMemoLine."Exit Point";
                                Area := SalesCrMemoLine.Area;
                                Quantity := -SalesCrMemoLine.Quantity;
                                CurrencyFactor := SalesCrMemoHeader."Currency Factor";
                                UnitCost := SalesCrMemoLine."Unit Cost";
                                UnitCostLCY := SalesCrMemoLine."Unit Cost (LCY)";
                                LineDiscPerc := SalesCrMemoLine."Line Discount %";
                                ShortcutDimCode1 := SalesCrMemoLine."Shortcut Dimension 1 Code";
                                ShortcutDimCode2 := SalesCrMemoLine."Shortcut Dimension 2 Code";
                                DimSetID := SalesCrMemoLine."Dimension Set ID";
                            end;
                    end;
#if BC17
                    JobJnlLine."Line Type" := JobPlanningLine."Line Type" + 1;
#else
                    OrdinalValue := JobPlanningLine."Line Type".AsInteger();
                    OrdinalValue := OrdinalValue + 1;
                    JobJnlLine."Line Type" := "Job Line Type".FromInteger(OrdinalValue);
#endif
                    JobJnlLine."Source Code" := SourceCodeSetup.Sales;
                end;
            EntryType::Usage:
                begin
                    DocumentDate := JobPlanningLineInvoice."Invoiced Date"; //in standard user is prompted to specify
                    DocumentNo := JobPlanningLine."Job No.";
                    if JobPlanningLine."Document No." <> '' then
                        DocumentNo := JobPlanningLine."Document No.";
                    if JobPlanningLine."Usage Link" then begin
                        JobJnlLine."Job Planning Line No." := JobPlanningLine."Line No.";
#if BC17                        
                        JobJnlLine."Line Type" := JobPlanningLine."Line Type" + 1;
#else
                        OrdinalValue := JobPlanningLine."Line Type".AsInteger();
                        OrdinalValue := OrdinalValue + 1;
                        JobJnlLine."Line Type" := "Job Line Type".FromInteger(OrdinalValue);
#endif
                    end;
                    PostingGroup := JobTask."Job Posting Group";
                    GenBusPostGroup := JobPlanningLine."Gen. Bus. Posting Group";
                    GenProdPostGroup := JobPlanningLine."Gen. Prod. Posting Group";
                    Description := JobPlanningLine.Description;
                    Description2 := JobPlanningLine."Description 2";
                    UnitOfMeasureCode := JobPlanningLine."Unit of Measure Code";
                    QtyPerUoM := JobPlanningLine."Qty. per Unit of Measure";
                    LocationCode := JobPlanningLine."Location Code";
                    BinCode := JobPlanningLine."Bin Code";
                    Quantity := JobPlanningLineInvoice."Quantity Transferred";
                    LineDiscPerc := JobPlanningLine."Line Discount %";
                end;
        end;

        JobJnlLine."Job No." := JobPlanningLine."Job No.";
        JobJnlLine."Job Task No." := JobPlanningLine."Job Task No.";
        JobJnlLine.Type := JobPlanningLine.Type;
        JobJnlLine."No." := JobPlanningLine."No.";
        JobJnlLine."Entry Type" := EntryType;
        JobJnlLine."Serial No." := JobPlanningLine."Serial No.";
        JobJnlLine."Lot No." := JobPlanningLine."Lot No.";
        JobJnlLine."Posting Date" := JobPlanningLineInvoice."Invoiced Date";
        JobJnlLine."Document Date" := DocumentDate;
        JobJnlLine."Document No." := DocumentNo;
        JobJnlLine."Posting Group" := PostingGroup;
        JobJnlLine."Gen. Bus. Posting Group" := GenBusPostGroup;
        JobJnlLine."Gen. Prod. Posting Group" := GenProdPostGroup;
        JobJnlLine.Description := Description;
        JobJnlLine."Description 2" := Description2;
        case EntryType of
            EntryType::Sale:
                begin
                    JobJnlLine."Unit of Measure Code" := UnitOfMeasureCode;
                    JobJnlLine.Validate("Qty. per Unit of Measure", QtyPerUoM);
                end;
            EntryType::Usage:
                JobJnlLine.Validate("Unit of Measure Code", UnitOfMeasureCode);
        end;
        JobJnlLine."Work Type Code" := JobPlanningLine."Work Type Code";
        JobJnlLine."Variant Code" := JobPlanningLine."Variant Code";
        JobJnlLine."Currency Code" := JobPlanningLine."Currency Code";
        JobJnlLine."Currency Factor" := JobPlanningLine."Currency Factor";
        JobJnlLine."Resource Group No." := JobPlanningLine."Resource Group No.";
        JobJnlLine."Customer Price Group" := JobPlanningLine."Customer Price Group";
        JobJnlLine."Location Code" := LocationCode;
        JobJnlLine."Bin Code" := BinCode;
        JobJnlLine."Service Order No." := JobPlanningLine."Service Order No.";
        JobJnlLine."Reason Code" := ReasonCode;
        JobJnlLine."External Document No." := ExternalDocNo;
        JobJnlLine."Transport Method" := TransportMethod;
        JobJnlLine."Transaction Type" := TransactionType;
        JobJnlLine."Transaction Specification" := TransactionSpecification;
        JobJnlLine."Entry/Exit Point" := EntryExitPoint;
        JobJnlLine.Area := Area;
        JobJnlLine."Country/Region Code" := JobPlanningLine."Country/Region Code";
        JobJnlLine.Validate(Quantity, Quantity);
        if EntryType = EntryType::Usage then
            JobJnlLine.Validate("Qty. per Unit of Measure", QtyPerUoM);
        JobJnlLine."Direct Unit Cost (LCY)" := JobPlanningLine."Direct Unit Cost (LCY)";
        case EntryType of
            EntryType::Sale:
                begin
                    if JobJnlLine.Type = JobJnlLine.Type::Item then
                        Item.Get(JobJnlLine."No.");
                    if (JobPlanningLine."Currency Code" = '') and (CurrencyFactor <> 0) then
                        ValidateUnitCostAndPrice(JobJnlLine, Item, UnitCostLCY, JobPlanningLine."Unit Price")
                    else
                        ValidateUnitCostAndPrice(JobJnlLine, Item, UnitCost, JobPlanningLine."Unit Price");
                end;
            EntryType::Usage:
                begin
                    JobJnlLine.Validate("Unit Cost", JobPlanningLine."Unit Cost");
                    JobJnlLine.Validate("Unit Price", JobPlanningLine."Unit Price");
                end;
        end;
        JobJnlLine.Validate("Line Discount %", LineDiscPerc);
        case EntryType of
            EntryType::Sale:
                begin
                    JobJnlLine."Shortcut Dimension 1 Code" := ShortcutDimCode1;
                    JobJnlLine."Shortcut Dimension 2 Code" := ShortcutDimCode2;
                    JobJnlLine."Dimension Set ID" := DimSetID;
                end;
            EntryType::Usage:
                JobJnlLine.UpdateDimensions();
        end;
    end;

    local procedure PostJournal(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; var JobJnlLine: Record "Job Journal Line") JobLedgEntryNo: Integer
    var
        ValueEntry: Record "Value Entry";
        RemainingAmount: Decimal;
        RemainingAmountLCY: Decimal;
        RemainingQtyToTrack: Decimal;
        Currency: Record Currency;
        Job: Record Job;
        JobTask: Record "Job Task";
        CurrExchRate: Record "Currency Exchange Rate";
        ResJnlLine: Record "Res. Journal Line";
        ResLedgEntry: Record "Res. Ledger Entry";
        ResJnlPostLine: Codeunit "Res. Jnl.-Post Line";
        SkipJobLedgerEntry: Boolean;
        ItemLedgEntry: Record "Item Ledger Entry";
        JobLedgEntry2: Record "Job Ledger Entry";
        TempRemainingQty: Decimal;
    begin
        Job.Get(JobJnlLine."Job No.");
        JobJnlLine.TestField("Currency Code", Job."Currency Code"); //this should be tested when creating invoice so this process doesnt fail to late
        JobTask.Get(JobJnlLine."Job No.", JobJnlLine."Job Task No.");
        GLSetup.Get();
        if GLSetup."Additional Reporting Currency" <> '' then begin
            if JobJnlLine."Source Currency Code" <> GLSetup."Additional Reporting Currency" then begin
                Currency.Get(GLSetup."Additional Reporting Currency");
                Currency.TestField("Amount Rounding Precision");
                JobJnlLine."Source Currency Total Cost" :=
                  Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      JobJnlLine."Posting Date",
                      GLSetup."Additional Reporting Currency", JobJnlLine."Total Cost (LCY)",
                      CurrExchRate.ExchangeRate(
                        JobJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
                    Currency."Amount Rounding Precision");
                JobJnlLine."Source Currency Total Price" :=
                  Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      JobJnlLine."Posting Date",
                      GLSetup."Additional Reporting Currency", JobJnlLine."Total Price (LCY)",
                      CurrExchRate.ExchangeRate(
                        JobJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
                    Currency."Amount Rounding Precision");
                JobJnlLine."Source Currency Line Amount" :=
                  Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      JobJnlLine."Posting Date",
                      GLSetup."Additional Reporting Currency", JobJnlLine."Line Amount (LCY)",
                      CurrExchRate.ExchangeRate(
                        JobJnlLine."Posting Date", GLSetup."Additional Reporting Currency")),
                    Currency."Amount Rounding Precision");
            end;
        end else begin
            JobJnlLine."Source Currency Total Cost" := 0;
            JobJnlLine."Source Currency Total Price" := 0;
            JobJnlLine."Source Currency Line Amount" := 0;
        end;

        if JobJnlLine."Entry Type" = JobJnlLine."Entry Type"::Usage then begin
            case JobJnlLine.Type of
                JobJnlLine.Type::Resource:
                    begin
                        InitResJnlLine(JobJnlLine, ResJnlLine);
                        ResLedgEntry.LockTable();
                        ResJnlPostLine.RunWithCheck(ResJnlLine);
                        JobJnlLine."Resource Group No." := ResJnlLine."Resource Group No.";
                        JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
                    end;
                JobJnlLine.Type::Item:
                    if GetJobConsumptionValueEntry(JobPlanningLineInvoice, ValueEntry, JobJnlLine) then begin
                        RemainingAmount := JobJnlLine."Line Amount";
                        RemainingAmountLCY := JobJnlLine."Line Amount (LCY)";
                        RemainingQtyToTrack := JobJnlLine.Quantity;

                        repeat
                            SkipJobLedgerEntry := false;
                            if ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.") then begin
                                JobLedgEntry2.SetRange("Ledger Entry Type", JobLedgEntry2."Ledger Entry Type"::Item);
                                JobLedgEntry2.SetRange("Ledger Entry No.", ItemLedgEntry."Entry No.");
                                // The following code is only to secure that JLEs created at receipt in version 6.0 or earlier,
                                // are not created again at point of invoice (6.0 SP1 and newer).
                                if JobLedgEntry2.FindFirst() and (JobLedgEntry2.Quantity = -ItemLedgEntry.Quantity) then
                                    SkipJobLedgerEntry := true
                                else begin
                                    JobJnlLine."Serial No." := ItemLedgEntry."Serial No.";
                                    JobJnlLine."Lot No." := ItemLedgEntry."Lot No.";
                                end;
                            end;
                            if not SkipJobLedgerEntry then begin
                                TempRemainingQty := JobJnlLine."Remaining Qty.";
                                JobJnlLine.Quantity := -ValueEntry."Invoiced Quantity" / JobJnlLine."Qty. per Unit of Measure";
                                JobJnlLine."Quantity (Base)" := Round(JobJnlLine.Quantity * JobJnlLine."Qty. per Unit of Measure", 0.00001);
                                if JobJnlLine."Currency Code" <> '' then
                                    Currency.Get(JobJnlLine."Currency Code")
                                else
                                    Currency.InitRoundingPrecision();

                                UpdateJobJnlLineTotalAmounts(JobJnlLine, Currency."Amount Rounding Precision");
                                UpdateJobJnlLineAmount(
                                  JobJnlLine, RemainingAmount, RemainingAmountLCY, RemainingQtyToTrack, Currency."Amount Rounding Precision");

                                JobJnlLine.Validate("Remaining Qty.", TempRemainingQty);
                                JobJnlLine."Ledger Entry Type" := JobJnlLine."Ledger Entry Type"::Item;
                                JobJnlLine."Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
                                JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
                                ValueEntry."Job Ledger Entry No." := JobLedgEntryNo;
                                ValueEntry.Modify(true);
                            end;
                        until ValueEntry.Next() = 0;
                    end;
                JobJnlLine.Type::"G/L Account":
                    JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
            end;
        end else
            JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);

        exit(JobLedgEntryNo);
    end;

    local procedure ValidateUnitCostAndPrice(var JobJournalLine: Record "Job Journal Line"; Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        if Item."Costing Method" <> Item."Costing Method"::Standard then
            JobJournalLine.Validate("Unit Cost", UnitCost);
        JobJournalLine.Validate("Unit Price", UnitPrice);
    end;

    local procedure GetJobConsumptionValueEntry(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; var ValueEntry: Record "Value Entry"; JobJournalLine: Record "Job Journal Line"): Boolean
    begin
        ValueEntry.SetRange("Item No.", JobJournalLine."No.");
        ValueEntry.SetRange("Document No.", JobPlanningLineInvoice."Document No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Job Ledger Entry No.", 0);
        exit(ValueEntry.FindSet());
    end;

    local procedure CreateJobLedgEntry(JobJnlLine: Record "Job Journal Line"): Integer
    var
        JobLedgEntry: Record "Job Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        JobPlanningLine: Record "Job Planning Line";
        Job: Record Job;
        JobTransferLine: Codeunit "Job Transfer Line";
        EventLinkUsage: Codeunit "NPR Event Link Usg.";
        JobPostLine: Codeunit "Job Post-Line";
    begin
        SetCurrency(JobJnlLine);

        JobLedgEntry.Init();
        JobTransferLine.FromJnlLineToLedgEntry(JobJnlLine, JobLedgEntry);
        if JobLedgEntry."Entry Type" = JobLedgEntry."Entry Type"::Sale then begin
            JobLedgEntry.Quantity := -JobJnlLine.Quantity;
            JobLedgEntry."Quantity (Base)" := -JobJnlLine."Quantity (Base)";
            JobLedgEntry."Total Cost (LCY)" := -JobJnlLine."Total Cost (LCY)";
            JobLedgEntry."Total Cost" := -JobJnlLine."Total Cost";
            JobLedgEntry."Total Price (LCY)" := -JobJnlLine."Total Price (LCY)";
            JobLedgEntry."Total Price" := -JobJnlLine."Total Price";
            JobLedgEntry."Line Amount (LCY)" := -JobJnlLine."Line Amount (LCY)";
            JobLedgEntry."Line Amount" := -JobJnlLine."Line Amount";
            JobLedgEntry."Line Discount Amount (LCY)" := -JobJnlLine."Line Discount Amount (LCY)";
            JobLedgEntry."Line Discount Amount" := -JobJnlLine."Line Discount Amount";
        end else begin
            JobLedgEntry.Quantity := JobJnlLine.Quantity;
            JobLedgEntry."Quantity (Base)" := JobJnlLine."Quantity (Base)";
            JobLedgEntry."Total Cost (LCY)" := JobJnlLine."Total Cost (LCY)";
            JobLedgEntry."Total Cost" := JobJnlLine."Total Cost";
            JobLedgEntry."Total Price (LCY)" := JobJnlLine."Total Price (LCY)";
            JobLedgEntry."Total Price" := JobJnlLine."Total Price";
            JobLedgEntry."Line Amount (LCY)" := JobJnlLine."Line Amount (LCY)";
            JobLedgEntry."Line Amount" := JobJnlLine."Line Amount";
            JobLedgEntry."Line Discount Amount (LCY)" := JobJnlLine."Line Discount Amount (LCY)";
            JobLedgEntry."Line Discount Amount" := JobJnlLine."Line Discount Amount";
        end;
        JobLedgEntry."Additional-Currency Total Cost" := -JobLedgEntry."Additional-Currency Total Cost";
        JobLedgEntry."Add.-Currency Total Price" := -JobLedgEntry."Add.-Currency Total Price";
        JobLedgEntry."Add.-Currency Line Amount" := -JobLedgEntry."Add.-Currency Line Amount";
        JobLedgEntry."Entry No." := NextEntryNo;
        JobLedgEntry."No. Series" := JobJnlLine."Posting No. Series";
        JobLedgEntry."Original Unit Cost (LCY)" := JobLedgEntry."Unit Cost (LCY)";
        JobLedgEntry."Original Total Cost (LCY)" := JobLedgEntry."Total Cost (LCY)";
        JobLedgEntry."Original Unit Cost" := JobLedgEntry."Unit Cost";
        JobLedgEntry."Original Total Cost" := JobLedgEntry."Total Cost";
        JobLedgEntry."Original Total Cost (ACY)" := JobLedgEntry."Additional-Currency Total Cost";
        JobLedgEntry."Dimension Set ID" := JobJnlLine."Dimension Set ID";

        case JobJnlLine.Type of
            JobJnlLine.Type::Resource:
                begin
                    if JobJnlLine."Entry Type" = JobJnlLine."Entry Type"::Usage then begin
                        if ResLedgEntry.FindLast() then begin
                            JobLedgEntry."Ledger Entry Type" := JobLedgEntry."Ledger Entry Type"::Resource;
                            JobLedgEntry."Ledger Entry No." := ResLedgEntry."Entry No.";
                        end;
                    end;
                end;
            JobJnlLine.Type::Item:
                begin
                    JobLedgEntry."Ledger Entry Type" := JobJnlLine."Ledger Entry Type"::Item;
                    JobLedgEntry."Ledger Entry No." := JobJnlLine."Ledger Entry No.";
                    JobLedgEntry."Serial No." := JobJnlLine."Serial No.";
                    JobLedgEntry."Lot No." := JobJnlLine."Lot No.";
                end;
            JobJnlLine.Type::"G/L Account":
                begin
                    JobLedgEntry."Ledger Entry Type" := JobLedgEntry."Ledger Entry Type"::" ";
                end;
        end;
        if JobLedgEntry."Entry Type" = JobLedgEntry."Entry Type"::Sale then begin
            JobLedgEntry."Serial No." := JobJnlLine."Serial No.";
            JobLedgEntry."Lot No." := JobJnlLine."Lot No.";
        end;

        JobLedgEntry.Insert(true);

        JobReg."To Entry No." := NextEntryNo;
        JobReg.Modify();

        if JobLedgEntry."Entry Type" = JobLedgEntry."Entry Type"::Usage then begin
            // Usage Link should be applied if it is enabled for the job,
            // if a Job Planning Line number is defined or if it is enabled for a Job Planning Line.
            Job.Get(JobLedgEntry."Job No.");
            if Job."Apply Usage Link" or
               (JobJnlLine."Job Planning Line No." <> 0) or
               EventLinkUsage.FindMatchingJobPlanningLine(JobPlanningLine, JobLedgEntry)
            then begin
                EventLinkUsage.SetAutoConfirm(true);
                EventLinkUsage.ApplyUsage(JobLedgEntry, JobJnlLine)
            end
            else
                JobPostLine.InsertPlLineFromLedgEntry(JobLedgEntry)
        end;

        NextEntryNo := NextEntryNo + 1;

        exit(JobLedgEntry."Entry No.");
    end;

    local procedure SetCurrency(JobJnlLine: Record "Job Journal Line")
    var
        Currency: Record Currency;
    begin
        if JobJnlLine."Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision()
        end else begin
            Currency.Get(JobJnlLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
    end;

    local procedure InitResJnlLine(JobJnlLine: Record "Job Journal Line"; var ResJnlLine: Record "Res. Journal Line")
    begin
        ResJnlLine.Init();
        ResJnlLine."Entry Type" := JobJnlLine."Entry Type";
        ResJnlLine."Document No." := JobJnlLine."Document No.";
        ResJnlLine."External Document No." := JobJnlLine."External Document No.";
        ResJnlLine."Posting Date" := JobJnlLine."Posting Date";
        ResJnlLine."Document Date" := JobJnlLine."Document Date";
        ResJnlLine."Resource No." := JobJnlLine."No.";
        ResJnlLine.Description := JobJnlLine.Description;
        ResJnlLine."Work Type Code" := JobJnlLine."Work Type Code";
        ResJnlLine."Job No." := JobJnlLine."Job No.";
        ResJnlLine."Shortcut Dimension 1 Code" := JobJnlLine."Shortcut Dimension 1 Code";
        ResJnlLine."Shortcut Dimension 2 Code" := JobJnlLine."Shortcut Dimension 2 Code";
        ResJnlLine."Dimension Set ID" := JobJnlLine."Dimension Set ID";
        ResJnlLine."Unit of Measure Code" := JobJnlLine."Unit of Measure Code";
        ResJnlLine."Source Code" := JobJnlLine."Source Code";
        ResJnlLine."Gen. Bus. Posting Group" := JobJnlLine."Gen. Bus. Posting Group";
        ResJnlLine."Gen. Prod. Posting Group" := JobJnlLine."Gen. Prod. Posting Group";
        ResJnlLine."Posting No. Series" := JobJnlLine."Posting No. Series";
        ResJnlLine."Reason Code" := JobJnlLine."Reason Code";
        ResJnlLine."Resource Group No." := JobJnlLine."Resource Group No.";
        ResJnlLine."Recurring Method" := JobJnlLine."Recurring Method";
        ResJnlLine."Expiration Date" := JobJnlLine."Expiration Date";
        ResJnlLine."Recurring Frequency" := JobJnlLine."Recurring Frequency";
        ResJnlLine.Quantity := JobJnlLine.Quantity;
        ResJnlLine."Qty. per Unit of Measure" := JobJnlLine."Qty. per Unit of Measure";
        ResJnlLine."Direct Unit Cost" := JobJnlLine."Direct Unit Cost (LCY)";
        ResJnlLine."Unit Cost" := JobJnlLine."Unit Cost (LCY)";
        ResJnlLine."Total Cost" := JobJnlLine."Total Cost (LCY)";
        ResJnlLine."Unit Price" := JobJnlLine."Unit Price (LCY)";
        ResJnlLine."Total Price" := JobJnlLine."Line Amount (LCY)";
        ResJnlLine."Time Sheet No." := JobJnlLine."Time Sheet No.";
        ResJnlLine."Time Sheet Line No." := JobJnlLine."Time Sheet Line No.";
        ResJnlLine."Time Sheet Date" := JobJnlLine."Time Sheet Date";
    end;

    local procedure UpdateJobJnlLineTotalAmounts(var JobJnlLineToUpdate: Record "Job Journal Line"; AmtRoundingPrecision: Decimal)
    begin
        JobJnlLineToUpdate."Total Cost" := Round(JobJnlLineToUpdate."Unit Cost" * JobJnlLineToUpdate.Quantity, AmtRoundingPrecision);
        JobJnlLineToUpdate."Total Cost (LCY)" := Round(JobJnlLineToUpdate."Unit Cost (LCY)" * JobJnlLineToUpdate.Quantity, AmtRoundingPrecision);
        JobJnlLineToUpdate."Total Price" := Round(JobJnlLineToUpdate."Unit Price" * JobJnlLineToUpdate.Quantity, AmtRoundingPrecision);
        JobJnlLineToUpdate."Total Price (LCY)" := Round(JobJnlLineToUpdate."Unit Price (LCY)" * JobJnlLineToUpdate.Quantity, AmtRoundingPrecision);
    end;

    local procedure UpdateJobJnlLineAmount(var JobJnlLineToUpdate: Record "Job Journal Line"; var RemainingAmount: Decimal; var RemainingAmountLCY: Decimal; var RemainingQtyToTrack: Decimal; AmtRoundingPrecision: Decimal)
    begin
        JobJnlLineToUpdate."Line Amount" := Round(RemainingAmount * JobJnlLineToUpdate.Quantity / RemainingQtyToTrack, AmtRoundingPrecision);
        JobJnlLineToUpdate."Line Amount (LCY)" := Round(RemainingAmountLCY * JobJnlLineToUpdate.Quantity / RemainingQtyToTrack, AmtRoundingPrecision);

        RemainingAmount -= JobJnlLineToUpdate."Line Amount";
        RemainingAmountLCY -= JobJnlLineToUpdate."Line Amount (LCY)";
        RemainingQtyToTrack -= JobJnlLineToUpdate.Quantity;
    end;

    local procedure ValidateRelationship(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; JobPlanningLine: Record "Job Planning Line")
    var
        JobTask: Record "Job Task";
        Txt: Text[500];
        Text000: Label 'has been changed (initial a %1: %2= %3, %4= %5)';
    begin
        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        Txt := StrSubstNo(Text000,
            JobTask.TableCaption, JobTask.FieldCaption("Job No."), JobTask."Job No.",
            JobTask.FieldCaption("Job Task No."), JobTask."Job Task No.");

        if JobPlanningLine.Type = JobPlanningLine.Type::Text then
            if SalesLine.Type <> SalesLine.Type::" " then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::Resource then
            if SalesLine.Type <> SalesLine.Type::Resource then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::Item then
            if SalesLine.Type <> SalesLine.Type::Item then
                SalesLine.FieldError(Type, Txt);
        if JobPlanningLine.Type = JobPlanningLine.Type::"G/L Account" then
            if SalesLine.Type <> SalesLine.Type::"G/L Account" then
                SalesLine.FieldError(Type, Txt);

        if SalesLine."No." <> JobPlanningLine."No." then
            SalesLine.FieldError("No.", Txt);
        if SalesLine."Location Code" <> JobPlanningLine."Location Code" then
            SalesLine.FieldError("Location Code", Txt);
        if SalesLine."Work Type Code" <> JobPlanningLine."Work Type Code" then
            SalesLine.FieldError("Work Type Code", Txt);
        if SalesLine."Unit of Measure Code" <> JobPlanningLine."Unit of Measure Code" then
            SalesLine.FieldError("Unit of Measure Code", Txt);
        if SalesLine."Variant Code" <> JobPlanningLine."Variant Code" then
            SalesLine.FieldError("Variant Code", Txt);
        if SalesLine."Gen. Prod. Posting Group" <> JobPlanningLine."Gen. Prod. Posting Group" then
            SalesLine.FieldError("Gen. Prod. Posting Group", Txt);
        if SalesLine."Line Discount %" <> JobPlanningLine."Line Discount %" then
            SalesLine.FieldError("Line Discount %", Txt);
        if JobPlanningLine."Unit Cost (LCY)" <> SalesLine."Unit Cost (LCY)" then
            SalesLine.FieldError("Unit Cost (LCY)", Txt);
        if SalesLine.Type = SalesLine.Type::" " then begin
            if SalesLine."Line Amount" <> 0 then
                SalesLine.FieldError("Line Amount", Txt);
        end;
        if SalesHeader."Prices Including VAT" then begin
            if JobPlanningLine."VAT %" <> SalesLine."VAT %" then
                SalesLine.FieldError("VAT %", Txt);
        end;
    end;

    procedure OpenSalesDocument(JobPlanningLineInvoice: Record "Job Planning Line Invoice")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin
        case JobPlanningLineInvoice."Document Type" of
            JobPlanningLineInvoice."Document Type"::Invoice:
                if JobPlanningLineInvoice."NPR POS Unit No." = '' then begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Invoice", SalesHeader);
                end else begin
                    //sales ticket remains as Document Type = Invoice until posted from Audit Roll/POS Entry
                    if ShowProcessedPOSDocument(JobPlanningLineInvoice) then
                        exit;
                    POSQuoteEntry.SetRange("Register No.", JobPlanningLineInvoice."NPR POS Unit No.");
                    POSQuoteEntry.SetRange("Sales Ticket No.", JobPlanningLineInvoice."Document No.");
                    if not POSQuoteEntry.IsEmpty then
                        PAGE.RunModal(0, POSQuoteEntry)
                    else
                        Error(POSDocProcessingErr);
                end;
            JobPlanningLineInvoice."Document Type"::"Credit Memo":
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Sales Credit Memo", SalesHeader);
                end;
            JobPlanningLineInvoice."Document Type"::"Posted Invoice":
                if JobPlanningLineInvoice."NPR POS Unit No." = '' then begin
                    if not SalesInvHeader.Get(JobPlanningLineInvoice."Document No.") then
                        Error(SalesDocErr, SalesInvHeader.TableCaption, JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end else begin
                    if not ShowProcessedPOSDocument(JobPlanningLineInvoice) then
                        Error(POSDocErr, JobPlanningLineInvoice."NPR POS Unit No.", JobPlanningLineInvoice."Document No.");
                end;
            JobPlanningLineInvoice."Document Type"::"Posted Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(JobPlanningLineInvoice."Document No.") then
                        Error(SalesDocErr, SalesCrMemoHeader.TableCaption, JobPlanningLineInvoice."Document No.");
                    PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;
        end;
    end;

    procedure GetJobPlanningLineInvoices(JobPlanningLine: Record "Job Planning Line")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        ClearAll();
        if JobPlanningLine."Line No." = 0 then
            exit;
        JobPlanningLine.TestField("Job No.");
        JobPlanningLine.TestField("Job Task No.");

        JobPlanningLineInvoice.SetRange("Job No.", JobPlanningLine."Job No.");
        JobPlanningLineInvoice.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        JobPlanningLineInvoice.SetRange("Job Planning Line No.", JobPlanningLine."Line No.");
        if JobPlanningLineInvoice.Count() = 1 then begin
            JobPlanningLineInvoice.FindFirst();
            OpenSalesDocument(JobPlanningLineInvoice);
        end else
            PAGE.RunModal(PAGE::"NPR Event Invoices", JobPlanningLineInvoice);
    end;

    procedure FindInvoices(var TempJobPlanningLineInvoice: Record "Job Planning Line Invoice" temporary; JobNo: Code[20]; JobTaskNo: Code[20]; JobPlanningLineNo: Integer; DetailLevel: Option All,"Per Job","Per Job Task","Per Job Planning Line")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        RecordFound: Boolean;
    begin
        case DetailLevel of
            DetailLevel::All:
                begin
                    if JobPlanningLineInvoice.FindSet() then
                        TempJobPlanningLineInvoice := JobPlanningLineInvoice;
                    exit;
                end;
            DetailLevel::"Per Job":
                JobPlanningLineInvoice.SetRange("Job No.", JobNo);
            DetailLevel::"Per Job Task":
                begin
                    JobPlanningLineInvoice.SetRange("Job No.", JobNo);
                    JobPlanningLineInvoice.SetRange("Job Task No.", JobTaskNo);
                end;
            DetailLevel::"Per Job Planning Line":
                begin
                    JobPlanningLineInvoice.SetRange("Job No.", JobNo);
                    JobPlanningLineInvoice.SetRange("Job Task No.", JobTaskNo);
                    JobPlanningLineInvoice.SetRange("Job Planning Line No.", JobPlanningLineNo);
                end;
        end;

        TempJobPlanningLineInvoice.DeleteAll();
        if JobPlanningLineInvoice.FindSet() then begin
            repeat
                RecordFound := false;
                case DetailLevel of
                    DetailLevel::"Per Job":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, '', 0, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Job Task":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, JobTaskNo, 0, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                    DetailLevel::"Per Job Planning Line":
                        if TempJobPlanningLineInvoice.Get(
                             JobNo, JobTaskNo, JobPlanningLineNo, JobPlanningLineInvoice."Document Type", JobPlanningLineInvoice."Document No.", 0)
                        then
                            RecordFound := true;
                end;

                if RecordFound then begin
                    TempJobPlanningLineInvoice."Quantity Transferred" += JobPlanningLineInvoice."Quantity Transferred";
                    TempJobPlanningLineInvoice."Invoiced Amount (LCY)" += JobPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempJobPlanningLineInvoice."Invoiced Cost Amount (LCY)" += JobPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    TempJobPlanningLineInvoice.Modify();
                end else begin
                    case DetailLevel of
                        DetailLevel::"Per Job":
                            TempJobPlanningLineInvoice."Job No." := JobNo;
                        DetailLevel::"Per Job Task":
                            begin
                                TempJobPlanningLineInvoice."Job No." := JobNo;
                                TempJobPlanningLineInvoice."Job Task No." := JobTaskNo;
                            end;
                        DetailLevel::"Per Job Planning Line":
                            begin
                                TempJobPlanningLineInvoice."Job No." := JobNo;
                                TempJobPlanningLineInvoice."Job Task No." := JobTaskNo;
                                TempJobPlanningLineInvoice."Job Planning Line No." := JobPlanningLineNo;
                            end;
                    end;
                    TempJobPlanningLineInvoice."Document Type" := JobPlanningLineInvoice."Document Type";
                    TempJobPlanningLineInvoice."Document No." := JobPlanningLineInvoice."Document No.";
                    TempJobPlanningLineInvoice."Quantity Transferred" := JobPlanningLineInvoice."Quantity Transferred";
                    TempJobPlanningLineInvoice."Invoiced Amount (LCY)" := JobPlanningLineInvoice."Invoiced Amount (LCY)";
                    TempJobPlanningLineInvoice."Invoiced Cost Amount (LCY)" := JobPlanningLineInvoice."Invoiced Cost Amount (LCY)";
                    TempJobPlanningLineInvoice."NPR POS Unit No." := JobPlanningLineInvoice."NPR POS Unit No.";
                    TempJobPlanningLineInvoice."NPR POS Store Code" := JobPlanningLineInvoice."NPR POS Store Code";
                    TempJobPlanningLineInvoice.Insert();
                end;
            until JobPlanningLineInvoice.Next() = 0;
        end;
    end;

    local procedure ShowProcessedPOSDocument(JobPlanningLineInvoice: Record "Job Planning Line Invoice") HasEntries: Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("POS Unit No.", JobPlanningLineInvoice."NPR POS Unit No.");
        POSEntry.SetRange("POS Store Code", JobPlanningLineInvoice."NPR POS Store Code");
        POSEntry.SetRange("Document No.", JobPlanningLineInvoice."Document No.");
        HasEntries := not POSEntry.IsEmpty();
        if HasEntries then
            PAGE.RunModal(0, POSEntry);
        exit(HasEntries);
    end;

    procedure GetBlockEventDeleteOptionFilter() OptionFilter: Text
    var
        InS: InStream;
    begin
        JobsSetup.Get();
        if JobsSetup."NPR Block Event Deletion".HasValue() then begin
            JobsSetup.CalcFields("NPR Block Event Deletion");
            JobsSetup."NPR Block Event Deletion".CreateInStream(InS);
            InS.Read(OptionFilter);
        end;
        exit(OptionFilter);
    end;

    local procedure GetJobEventStatusOptions() OptionCaption: Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Job: Record Job;
    begin
        RecRef.Open(DATABASE::Job);
        FldRef := RecRef.Field(Job.FieldNo("NPR Event Status"));
        OptionCaption := FldRef.OptionCaption;
        RecRef.Close();
        OptionCaption := RemoveEmptyOptionsFromEventStatusOption(OptionCaption);
        exit(OptionCaption);
    end;

    local procedure RemoveEmptyOptionsFromEventStatusOption(OptionString: Text) CleanedOptionString: Text
    var
        i: Integer;
        TypeHelper: Codeunit "Type Helper";
        OptionValue: Text;
    begin
        for i := 0 to TypeHelper.GetNumberOfOptions(OptionString) do begin
            OptionValue := SelectStr(i + 1, OptionString);
            if OptionValue <> '' then begin
                if CleanedOptionString <> '' then
                    CleanedOptionString += ',';
                CleanedOptionString += OptionValue;
            end;
        end;
        exit(CleanedOptionString);
    end;

    local procedure BlockDeleteIfInStatus(Job: Record Job)
    var
        OptionFilter: Text;
    begin
        Job.SetRecFilter();
        OptionFilter := GetBlockEventDeleteOptionFilter();
        if OptionFilter = '' then
            exit;
        Job.SetFilter("NPR Event Status", OptionFilter);
        if not Job.IsEmpty then
            Error(BlockDeleteErr, Job."No.", Format(Job."NPR Event Status"), JobsSetup.TableCaption);
    end;

    procedure SetBufferMode()
    begin
        BufferMode := true;
    end;
}

