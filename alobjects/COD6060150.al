codeunit 6060150 "Event Management"
{
    // NPR5.31/TJ  /20170315 CASE 269162 "Planning Date" taken from header "Starting Date" if not empty
    //                                   Changed how the Status field is getting updated
    //                                   Recoded some lines using file name functions
    //                                   Moved CopyAttributes function to "Event Attribute Management" codeunit
    //                                   Moved global TextConstant NothingToCopyTxt to function CopyTemplates
    //                                   Task Line is now created regardless of "Event Status"
    // NPR5.32/TJ  /20170516 CASE 275957 Fixed a problem when copying template didn't copy BLOBs as well
    //                                   CopyTemplate will now properly apply new event description on copied layout
    //                                   Fixed a problem when copying a job that has allready been copied so templates were taken from original job rather then new source job
    // NPR5.32/TJ  /20170519 CASE 275966 Changed how resource availability is checked
    //                                   Removed local variable JobsSetup from all the functions so global variable is used instead
    // NPR5.32/TJ  /20170519 CASE 275950 Updating planning lines if Starting Date is changed
    // NPR5.32/TJ  /20170523 CASE 276753 Updating External Document No. with Job No. when creating sales invoice
    // NPR5.32/TJ  /20170523 CASE 275963 Raising question to update date on planning lines only if coming from Starting Date field on header
    // NPR5.32/TJ  /20170525 CASE 278090 Checking if job exists before checking resource availability
    // NPR5.33/TJ  /20170607 CASE 277972 When job is deleted related new table Event Attribute is also deleted
    // NPR5.33/TJ  /20170626 CASE 275966 Fixed time frame recognition by checking same start/end time
    //                                   Displaying only marked lines so if same time frame falls into multiple rules it doesn't get showed multiple times
    // NPR5.34/TJ  /20170707 CASE 277938 Function CreateFileName changed
    //                                   When job is deleted so are exchange integration templates related to that job
    //                                   When job is copied so are exchange integration templates related to that job
    // NPR5.35/TJ  /20170731 CASE 275959 New subscribers to new field "Event Customer No." and standard field "Bill-to Customer No."
    // NPR5.35/TJ  /20170803 CASE 285826 Recoded usage of .NET assemblies that are specific for current NAV version
    // NPR5.35/TJ  /20170818 CASE 277938 Fixed a bug regarding copying exch. templates when copying event
    // NPR5.35/TJ  /20170821 CASE 287270 Over capacitate setup is now checked for time frame availability as well
    // NPR5.36/TJ  /20170901 CASE 289046 Reseting custom fields when Type is changed
    // NPR5.36/TJ  /20170911 CASE 287267 Not validating Status when Completed as it changes Ending Date
    // NPR5.36/TJ  /20170911 CASE 275966 Fixing issue with Status field not properly updating
    // NPR5.38/TJ  /20171004 CASE 291965 New functionalities to find/update/calculate price/amount with VAT
    // NPR5.38/TJ  /20171128 CASE 296160 Changing customer requires confirmation
    // NPR5.40/TJ  /20180124 CASE 301375 Events in status Planning are now also included when checking for available capacity on resources
    //                                   Time frame availability check was not checking on proper date when event was created as a copy
    // NPR5.40/TJ  /20180306 CASE 307328 Comments are also copied when event is copied
    // NPR5.44/TJ  /20180723 CASE 322879 Function CheckResTimeFrameAvailability changed to global
    // NPR5.48/TJ  /20181119 CASE 287903 Added new process that allows posting inventory directly from sales invoice created from job
    // NPR5.49/TJ  /20181207 CASE 331208 Integration with POS
    // NPR5.49/TJ  /20190226 CASE 346780 Fixed an issue with specifying time on type thats not a resource
    // NPR5.53/TJ  /20200110 CASE 346821 New functions to set statuses on Jobs Setup page
    //                                   New process to block deletion of events in specified status
    // NPR5.53/TJ  /20200206 CASE 385993 Fixed a bug preventing event delete with no setup
    // NPR5.54/TJ  /20200306 CASE 395153 Fixed a bug where forced inventory posting was allowing sales invoice modifications
    // NPR5.55/TJ  /20200330 CASE 397741 Variable MsgToDisplay set as return value in functions CheckResTimeFrameAvailability and CheckResAvailability
    //                                   New feature to check resource availability in bulk
    //                                   Functions AllowOverCapacitateResource and CheckResAvailability are now set as global
    //                                   Resource availability and capacity checks are getting skipped when we're creating lines from buffer
    // NPR5.55/TJ  /20200129 CASE 374887 Automatically sending e-mails

    Permissions = TableData "Job Ledger Entry" = imd,
                  TableData "Job Register" = imd,
                  TableData "Value Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        JobsSetup: Record "Jobs Setup";
        GLSetup: Record "General Ledger Setup";
        JobReg: Record "Job Register";
        EventEWSMgt: Codeunit "Event EWS Management";
        ContinueMsg: Label 'Do you want to continue?';
        EventEmailMgt: Codeunit "Event Email Management";
        EventAttrMgt: Codeunit "Event Attribute Management";
        RelatedJobEntriesExistErr: Label 'You can''t change %1 as there are related %2 or %3 associated with it.';
        EventVersionSpecificMgt: Codeunit "Event Version Specific Mgt.";
        EventCalendarMgt: Codeunit "Event Calendar Management";
        EventTicketMgt: Codeunit "Event Ticket Management";
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
        AuditRollPosting: Record "Audit Roll Posting";
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

        if Rec."Source Job No." = '' then
            Rec."Source Job No." := Rec."No.";

        if Rec."Source Job No." <> Rec."No." then begin
            Job.Get(Rec."Source Job No.");
            //-NPR5.31 [269162]
            //CopyAttributes(Rec."Source Job No.",Rec."No.",ReturnMsg);
            EventAttrMgt.CopyAttributes('', Rec."Source Job No.", Rec."No.", ReturnMsg);
            //+NPR5.31 [269162]
            CopyTemplates(Rec."Source Job No.", Rec."No.", 0, ReturnMsg);
            //-NPR5.34 [277938]
            CopyExchIntTemplates(Rec."Source Job No.", Rec."No.", ReturnMsg);
            //+NPR5.34 [277938]
            //-NPR5.40 [307328]
            CopyComments(Rec."Source Job No.", Rec."No.", ReturnMsg);
            //+NPR5.40 [307328]
            //-NPR5.32 [275957]
            Rec."Source Job No." := Rec."No.";
            //+NPR5.32 [275957]
        end;
        //-NPR5.36 [275966]
        Rec.Validate("Event Status");
        //+NPR5.36 [275966]
        Rec.Modify;
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

        //-NPR5.31 [269162]
        if (Rec."Event Status" = xRec."Event Status") and (Rec."Event Status" < Rec."Event Status"::Postponed) and (Rec."Event Status" <> Rec.Status) then begin
            Rec.Validate("Event Status");
            //-NPR5.36 [275966]
            Rec.Modify;
        end;
        //-NPR5.36 [275966]

        //IF NOT EventEWSMgt.CheckStatus(Rec,FALSE) THEN
        //  EXIT;
        //+NPR5.31 [269162]

        JobsSetup.Get();
        if (xRec."Bill-to Customer No." = '') and (Rec."Bill-to Customer No." <> xRec."Bill-to Customer No.") then
            if JobsSetup."Auto. Create Job Task Line" then begin
                JobsSetup.TestField("Def. Job Task No.");
                if not JobTask.Get(Rec."No.", JobsSetup."Def. Job Task No.") then begin
                    JobTask.Init;
                    JobTask.Validate("Job No.", Rec."No.");
                    JobTask.Validate("Job Task No.", JobsSetup."Def. Job Task No.");
                    JobTask.Description := JobsSetup."Def. Job Task Description";
                    JobTask.Insert(true);
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure JobOnBeforeDelete(var Rec: Record Job; RunTrigger: Boolean)
    begin
        //-NPR5.53 [346821]
        BlockDeleteIfInStatus(Rec);
        //+NPR5.53 [346821]
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterDeleteEvent', '', false, false)]
    local procedure JobOnAfterDelete(var Rec: Record Job; RunTrigger: Boolean)
    var
        EventWordLayout: Record "Event Word Layout";
        EventAttribute: Record "Event Attribute";
        EventExchIntTempEntry: Record "Event Exch. Int. Temp. Entry";
    begin
        if not RunTrigger then
            exit;

        if not IsEventJob(Rec) then
            exit;
        //-NPR5.33 [277972]
        /*
        EventAttributeEntry.SETRANGE("Job No.",Rec."No.");
        EventAttributeEntry.DELETEALL;
        */
        EventAttribute.SetRange("Job No.", Rec."No.");
        EventAttribute.DeleteAll(true);
        //+NPR5.33 [277972]
        EventWordLayout.SetRange("Source Record ID", Rec.RecordId);
        EventWordLayout.DeleteAll;
        //-NPR5.34 [277938]
        EventExchIntTempEntry.SetRange("Source Record ID", Rec.RecordId);
        EventExchIntTempEntry.DeleteAll;
        //+NPR5.34 [277938]

    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Event Status', false, false)]
    local procedure JobEventStatusOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        JobPlanningLine: Record "Job Planning Line";
        EventExchIntTemplate: Record "Event Exch. Int. Template";
        EmailCounter: Integer;
    begin
        //-NPR5.31 [269162]
        /*
        IF xRec."Event Status" <> Rec."Event Status" THEN BEGIN
          IF NOT (Rec."Event Status" IN [Rec."Event Status"::Postponed,Rec."Event Status"::Cancelled]) THEN
        */
        //-NPR5.36 [287267]
        /*
          IF Rec."Event Status" <= Rec."Event Status"::Postponed THEN
        //+NPR5.31 [269162]
            Rec.VALIDATE(Status,Rec."Event Status");
        */
        JobPlanningLine.SetCurrentKey("Job No.");
        JobPlanningLine.SetRange("Job No.", Rec."No.");

        if Rec."Event Status" < Rec."Event Status"::Postponed then begin
            if Rec."Event Status" = Rec."Event Status"::Completed then begin
                Rec.Status := Rec.Status::Completed;
                if Rec."Ending Date" = 0D then
                    Rec.Validate("Ending Date", WorkDate);
                JobPlanningLine.ModifyAll(Status, Rec.Status, true);
            end else
                Rec.Validate(Status, Rec."Event Status");
        end else
            Rec.Validate(Status, Rec.Status::Planning);
        //  JobPlanningLine.SETCURRENTKEY("Job No.");
        //  JobPlanningLine.SETRANGE("Job No.",Rec."No.");
        //+NPR5.36 [287267]
        JobPlanningLine.ModifyAll("Event Status", Rec."Event Status", true);
        //-NPR5.31 [269162]
        //END;
        //NPR5.31 [269162]
        
        //-NPR5.55 [374887]
        if (CurrFieldNo = Rec.FieldNo("Event Status")) and (Rec."Event Status" <> xRec."Event Status") then begin
          EventExchIntTemplate.SetRange("Auto. Send. Enabled (E-Mail)",true);
          EventExchIntTemplate.SetRange("Auto.Send.Event Status(E-Mail)",Rec."Event Status");
          if EventExchIntTemplate.FindSet then
            repeat
              EventEmailMgt.SetAskOnce(EmailCounter);
              EventEmailMgt.SetEventExcIntTemplate(EventExchIntTemplate);
              EventEmailMgt.SendEMail(Rec,EventExchIntTemplate."Template For",Rec.FieldNo("Event Status"));
              EmailCounter += 1;
            until EventExchIntTemplate.Next = 0;
        end;
        //+NPR5.55 [374887]

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

        if (Format(Rec."Preparation Period") <> '') and (Rec."Starting Date" <> xRec."Starting Date") and (Rec."Starting Date" <> 0D) then begin
            CalculatedDate := CalcDate('<-' + Format(Rec."Preparation Period") + '>', Rec."Starting Date");
            if CalculatedDate < Today then begin
                SuggestedDate := CalcDate(Rec."Preparation Period", Today);
                if Confirm(StrSubstNo(PreparationPeriodText,
                                        Rec.FieldCaption("Preparation Period"),
                                        Format(Rec."Preparation Period"),
                                        Rec.FieldCaption("Starting Date"),
                                        Format(Rec."Starting Date"),
                                        Format(SuggestedDate))) then
                    Rec.Validate("Starting Date", SuggestedDate);
            end;
        end;

        //-NPR5.32 [275950]
        if Rec."Starting Date" <> xRec."Starting Date" then begin
            //-NPR5.32 [275963]
            if CurrFieldNo = Rec.FieldNo("Starting Date") then
                //+NPR5.32 [275963]
                if not Confirm(StrSubstNo(StartingDateChangedQst, Rec.FieldCaption("Starting Date"))) then
                    exit;
            JobPlanningLine.SetRange("Job No.", Rec."No.");
            if JobPlanningLine.FindSet then
                repeat
                    JobPlanningLine.Validate("Planning Date", Rec."Starting Date");
                    JobPlanningLine.Modify;
                until JobPlanningLine.Next = 0;
        end;
        //+NPR5.32 [275950]
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Starting Time', false, false)]
    local procedure JobStartingTimeOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        CheckTime(Rec."Starting Date", Rec."Ending Date", Rec."Starting Time", Rec."Ending Time");
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Ending Time', false, false)]
    local procedure JobEndingTimeOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        CheckTime(Rec."Starting Date", Rec."Ending Date", Rec."Starting Time", Rec."Ending Time");
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure JobBilltoCustomerNoOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    begin
        //-NPR5.35 [275959]
        Rec."Event Customer No." := Rec."Bill-to Customer No.";
        //+NPR5.35 [275959]
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Event Customer No.', false, false)]
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
        //-NPR5.35 [275959]
        if (Rec."Event Customer No." = '') or (Rec."Event Customer No." <> xRec."Event Customer No.") then begin
            //-NPR5.38 [296160]
            if (Rec."Event Customer No." <> xRec."Event Customer No.") and (xRec."Event Customer No." <> '') then
                if not Confirm(StrSubstNo(ConfirmCustomerChange, Rec.FieldCaption("Event Customer No."))) then
                    Error('');
            //+NPR5.38 [296160]
            if JobLedgEntryExist(Rec) or RelatedSalesInvoiceCreditMemoExists(Rec) then
                Error(RelatedJobEntriesExistErr, Rec.FieldCaption("Event Customer No."), JobLedgerEntry.TableCaption, JobPlanningLineInvoice.TableCaption);
        end;
        TempJob := Rec;
        TempJob."No." := '';
        TempJob.Insert;
        TempJob.Validate("Bill-to Customer No.", Rec."Event Customer No.");
        TempJob.Modify;
        RecRef.GetTable(Rec);
        TempRecRef.GetTable(TempJob);
        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            FldRef2 := TempRecRef.FieldIndex(i);
            if (FldRef.Number <> Rec.FieldNo("No.")) and (FldRef.Value <> FldRef2.Value) then
                FldRef.Value := FldRef2.Value;
        end;
        RecRef.Modify;
        RecRef.SetTable(Rec);
        //Rec.GET(Rec."No.");
        //+NPR5.35 [275959]
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

        //-NPR5.40 [301375]
        /*
        //-NPR5.31 [269162]
        IF Job."Starting Date" <> 0D THEN BEGIN
          Rec.VALIDATE("Planning Date",Job."Starting Date");
          Rec.MODIFY;
        END;
        //+NPR5.31 [269162]
        */
        //+NPR5.40 [301375]

        if (Job."Starting Date" = Job."Ending Date") and (Job."Starting Time" <> 0T) and (Rec.Type = Rec.Type::Resource) then begin
            Rec."Starting Time" := Job."Starting Time";
            Rec.Modify;
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
        //-NPR5.36 [289046]
        //if Type was Item which had issued ticket, user needs to be warned and if agreed, ticket should be removed
        Job.Get(Rec."Job No.");
        if not IsEventJob(Job) then
            exit;

        if Rec.Type <> xRec.Type then begin
            if EventCalendarMgt.CheckForCalendar(Rec, xRec) then
                if not EventCalendarMgt.CheckForCalendarAndRemove(Rec, xRec) then
                    Error('');
            Rec."Calendar Item Status" := Rec."Calendar Item Status"::" ";
            Rec."Resource E-Mail" := '';
            Rec."Mail Item Status" := Rec."Mail Item Status"::" ";
            EventTicketMgt.CheckItemIsTicketAndRemove(Rec, xRec, true, true);
        end;
        //+NPR5.36 [289046]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Resource: Record Resource;
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        if (Rec.Type = Rec.Type::Resource) and (CurrFieldNo = Rec.FieldNo("No.")) then
            CalcResTimeQty(CurrFieldNo, Rec, xRec);
        //-NPR5.38 [291965]
        FindJobUnitPriceInclVAT(Rec, CurrFieldNo);
        //+NPR5.38 [291965]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Starting Time', false, false)]
    local procedure JobPlanningLineStartingTimeOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Starting Time") then begin
            CheckTime(Rec."Planning Date", Rec."Planning Date", Rec."Starting Time", Rec."Ending Time");
            CalcResTimeQty(CurrFieldNo, Rec, xRec);
            CheckResTimeFrameAvailability(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Ending Time', false, false)]
    local procedure JobPlanningLineEndingTimeOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Ending Time") then begin
            CheckTime(Rec."Planning Date", Rec."Planning Date", Rec."Starting Time", Rec."Ending Time");
            CalcResTimeQty(CurrFieldNo, Rec, xRec);
            CheckResTimeFrameAvailability(Rec);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure JobPlanningLineQuantityOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if Rec.Type = Rec.Type::Resource then begin
            //-NPR5.40 [301375]
            //IF CurrFieldNo = Rec.FIELDNO(Quantity) THEN
            if CurrFieldNo = Rec.FieldNo(Quantity) then begin
                //+NPR5.40 [301375]
                CalcResTimeQty(CurrFieldNo, Rec, xRec);
                CheckResAvailability(Rec, xRec);
                //-NPR5.40 [301375]
            end else begin
                if Rec.Quantity = 0 then begin
                    Rec.Validate("Starting Time", 0T);
                    Rec.Validate("Ending Time", 0T);
                end;
            end;
            //+NPR5.40 [301375]
        end;
        //-NPR5.38 [291965]
        CalcLineAmountInclVAT(Rec);
        //+NPR5.38 [291965]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure JobPlanningLineUnitPriceOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.38 [291965]
        UpdateUnitPriceInclVAT(Rec);
        //+NPR5.38 [291965]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Line Discount Amount', false, false)]
    local procedure JobPlanningLineLineDiscountAmountOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.38 [291965]
        CalcLineAmountInclVAT(Rec);
        //+NPR5.38 [291965]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Line Discount %', false, false)]
    local procedure JobPlanningLineLineDiscountPctOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.38 [291965]
        CalcLineAmountInclVAT(Rec);
        //+NPR5.38 [291965]
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
                    SalesHeader.Modify;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeModifyEvent', '', true, true)]
    local procedure SalesLineOnBeforeModify(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        PostedDocType: Integer;
        JobPostLine: Codeunit "Job Post-Line";
    begin
        //-NPR5.54 [395153]
        if not RunTrigger then
            exit;
        JobPlanningLineInvoice.SetRange("Line No.", Rec."Line No.");
        if not JobPlanningLineInvoiceExists(DATABASE::"Sales Header", Rec."Document Type", Rec."Document No.", JobPlanningLineInvoice, PostedDocType) then
            exit;
        if Rec."Job Contract Entry No." <> 0 then
            exit;
        JobPlanningLineInvoice.FindFirst;
        if not JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.") then
            exit;
        Rec."Job Contract Entry No." := JobPlanningLine."Job Contract Entry No.";
        JobPostLine.TestSalesLine(Rec);
        //+NPR5.54 [395153]
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure SalesLineOnBeforeDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        DocType: Integer;
        JobPlanningLine: Record "Job Planning Line";
    begin
        //-NPR5.48 [287903]
        if not RunTrigger then
            exit;

        case Rec."Document Type" of
            Rec."Document Type"::Invoice:
                DocType := JobPlanningLineInvoice."Document Type"::Invoice;
            Rec."Document Type"::"Credit Memo":
                DocType := JobPlanningLineInvoice."Document Type"::"Credit Memo";
        end;
        if DocType = 0 then
            exit;
        JobPlanningLineInvoice.SetRange("Document Type", DocType);
        JobPlanningLineInvoice.SetRange("Document No.", Rec."Document No.");
        JobPlanningLineInvoice.SetRange("Line No.", Rec."Line No.");
        if not JobPlanningLineInvoice.FindFirst then
            exit;
        if not JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.") then
            exit;
        if (Rec."Job Contract Entry No." = 0) and (JobPlanningLine."Job Contract Entry No." <> 0) then
            Rec."Job Contract Entry No." := JobPlanningLine."Job Contract Entry No.";
        //+NPR5.48 [287903]
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Job Contract Entry No.', true, true)]
    local procedure SalesLineJobContractEntryNoOnAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        //-NPR5.48 [287903]
        if CheckJobsSetup(0) then
            exit;
        if Rec."Job Contract Entry No." <> 0 then begin
            Rec."Job Contract Entry No." := 0;
            Rec.Modify;
        end;
        //+NPR5.48 [287903]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, true)]
    local procedure SalesPostOnBeforePostSale(var SalesHeader: Record "Sales Header")
    begin
        //-NPR5.48 [287903]
        if CheckJobsSetup(0) then
            exit;
        CheckSalesDoc(SalesHeader);
        //+NPR5.48 [287903]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure SalesPostOnAfterPostSale(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        PostedDocNo: Code[20];
        PostedDocType: Integer;
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        //-NPR5.48 [287903]
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
        //+NPR5.48 [287903]
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure SaleLinePOSOnAfterDelete(var Rec: Record "Sale Line POS"; RunTrigger: Boolean)
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "Sale POS";
        POSQuoteEntry: Record "POS Quote Entry";
    begin
        //-NPR5.49 [331208]
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
        JobPlanningLineInvoice.SetRange("POS Unit No.", Rec."Register No.");
        JobPlanningLineInvoice.SetRange("POS Store Code", SalePOS."POS Store Code");
        if JobPlanningLineInvoice.FindSet then
            repeat
                JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.");
                JobPlanningLineInvoice.Delete;
                JobPlanningLine.UpdateQtyToTransfer();
                JobPlanningLine.Modify;
            until JobPlanningLineInvoice.Next = 0;
        //+NPR5.49 [331208]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150615, 'OnAfterPostPOSEntryBatch', '', true, true)]
    local procedure POSPostEntriesOnAfterPostPOSEntryBatch(var POSEntry: Record "POS Entry"; PreviewMode: Boolean)
    var
        POSEntry2: Record "POS Entry";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        POSSalesLine: Record "POS Sales Line";
        PostedDocType: Integer;
        SkipThisEntry: Boolean;
    begin
        //-NPR5.49 [331208]
        if PreviewMode then
            exit;

        POSEntry2.Copy(POSEntry);
        POSEntry2.SetRange("Post Item Entry Status", POSEntry2."Post Item Entry Status"::Posted);
        if POSEntry2.FindSet then
            repeat
                POSSalesLine.SetRange("POS Entry No.", POSEntry2."Entry No.");
                POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
                SkipThisEntry := POSSalesLine.IsEmpty;
                if not SkipThisEntry then begin
                    JobPlanningLineInvoice.SetRange("POS Unit No.", POSEntry2."POS Unit No.");
                    JobPlanningLineInvoice.SetRange("POS Store Code", POSEntry2."POS Store Code");
                    SkipThisEntry := not JobPlanningLineInvoiceExists(DATABASE::"Sale POS", 0, POSEntry2."Document No.", JobPlanningLineInvoice, PostedDocType);
                end;
                POSEntryNo := POSEntry2."Entry No.";
                POSDocPostType := POSDocPostType::"POS Entry";
                if not SkipThisEntry then
                    PostEventSalesDoc(JobPlanningLineInvoice, PostedDocType, POSEntry2."Document No.", POSEntry2."Posting Date");
            until POSEntry2.Next = 0;
        //+NPR5.49 [331208]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014414, 'OnAfterRunPostItemLedger', '', true, true)]
    local procedure PostTempAuditRollOnAfterRunPostItemLedger(var Rec: Record "Audit Roll Posting")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        PostedDocType: Integer;
        SkipThisEntry: Boolean;
    begin
        //-NPR5.49 [331208]
        if Rec.FindSet then
            repeat
                AuditRollPosting := Rec;
                SkipThisEntry := not AuditRollPosting."Item Entry Posted";
                if not SkipThisEntry then begin
                    JobPlanningLineInvoice.SetRange("POS Unit No.", AuditRollPosting."Register No.");
                    SkipThisEntry := not JobPlanningLineInvoiceExists(DATABASE::"Sale POS", 0, AuditRollPosting."Sales Ticket No.", JobPlanningLineInvoice, PostedDocType);
                end;
                POSDocPostType := POSDocPostType::"Audit Roll";
                if not SkipThisEntry then
                    PostEventSalesDoc(JobPlanningLineInvoice, PostedDocType, AuditRollPosting."Posted Doc. No.", AuditRollPosting."Sale Date");
            until Rec.Next = 0;
        //+NPR5.49 [331208]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151005, 'OnAfterLoadFromQuote', '', true, true)]
    local procedure POSActionLoadFromQuoteOnAfterLoadFromQuote(POSQuoteEntry: Record "POS Quote Entry"; var SalePOS: Record "Sale POS")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        PostedDocType: Integer;
        JobPlanningLineInvoice2: Record "Job Planning Line Invoice";
    begin
        //-NPR5.49 [331208]
        with JobPlanningLineInvoice do begin
            SetRange("POS Unit No.", POSQuoteEntry."Register No.");
            SetRange("POS Store Code", SalePOS."POS Store Code");
            if not JobPlanningLineInvoiceExists(DATABASE::"Sale POS", 0, POSQuoteEntry."Sales Ticket No.", JobPlanningLineInvoice, PostedDocType) then
                exit;
            if FindSet then
                repeat
                    JobPlanningLineInvoice2.Get("Job No.", "Job Task No.", "Job Planning Line No.", "Document Type", "Document No.", "Line No.");
                    JobPlanningLineInvoice2.Delete(true);
                    JobPlanningLineInvoice2."Document No." := SalePOS."Sales Ticket No.";
                    JobPlanningLineInvoice2."POS Unit No." := SalePOS."Register No.";
                    JobPlanningLineInvoice2."POS Store Code" := SalePOS."POS Store Code";
                    JobPlanningLineInvoice2.Insert(true);
                until Next = 0;
        end;
        //+NPR5.49 [331208]
    end;

    [EventSubscriber(ObjectType::Page, 463, 'OnAfterActionEvent', 'SetStatusToBlockEventDelete', true, true)]
    local procedure SetStatusesToBlockEventDelete(var Rec: Record "Jobs Setup")
    var
        GenericMultipleCheckList: Page "Generic Multiple Check List";
        OutS: OutStream;
        OptionFilter: Text;
    begin
        //-NPR5.53 [346821]
        GenericMultipleCheckList.SetOptions(GetJobEventStatusOptions(), GetBlockEventDeleteOptionFilter());
        GenericMultipleCheckList.LookupMode(true);
        if GenericMultipleCheckList.RunModal = ACTION::LookupOK then begin
            OptionFilter := GenericMultipleCheckList.GetSelectedOption();
            if OptionFilter = '' then
                Clear(Rec."Block Event Deletion")
            else begin
                Rec."Block Event Deletion".CreateOutStream(OutS);
                OutS.Write(OptionFilter);
            end;
            Rec.Modify;
        end;
        //+NPR5.53 [346821]
    end;

    local procedure CheckTime(StartDate: Date; EndDate: Date; StartTime: Time; EndTime: Time)
    var
        Job: Record Job;
        Text001: Label '%1 must be earlier than %2.';
    begin
        if StartDate = EndDate then
            if (StartTime > EndTime) and (StartTime <> 0T) and (EndTime <> 0T) then
                Error(Text001, Job.FieldCaption("Starting Time"), Job.FieldCaption("Ending Time"));
    end;

    local procedure CalcResTimeQty(FromFieldNo: Integer; var Rec: Record "Job Planning Line"; xRec: Record "Job Planning Line")
    var
        Job: Record Job;
    begin
        if not JobsSetup.Get then
            exit;

        Job.Get(Rec."Job No.");
        if not IsEventJob(Job) then
            exit;

        with Rec do begin
            if not (JobsSetup."Qty. Relates to Start/End Time" and (JobsSetup."Time Calc. Unit of Measure" = "Unit of Measure Code")) then
                exit;
            if Type <> Type::Resource then
                exit;
            if "Planning Date" = 0D then
                exit;
            case FromFieldNo of
                FieldNo("Ending Time"), FieldNo("No."):
                    if "Ending Time" <> 0T then begin
                        if ("Starting Time" = 0T) and (Quantity > 0) then
                            Validate("Starting Time", "Ending Time" - Quantity * 3600000);
                        if ("Starting Time" <> 0T) and (Quantity = 0) then
                            Validate(Quantity, ("Ending Time" - "Starting Time") / 3600000);
                    end;
                FieldNo("Starting Time"):
                    if "Starting Time" <> 0T then begin
                        if ("Ending Time" = 0T) and (Quantity > 0) then
                            Validate("Ending Time", "Starting Time" + Quantity * 3600000);
                        if ("Ending Time" <> 0T) and (Quantity = 0) then
                            Validate(Quantity, ("Ending Time" - "Starting Time") / 3600000);
                    end;
                FieldNo(Quantity):
                    if Quantity > 0 then begin
                        if ("Starting Time" <> 0T) and ("Ending Time" = 0T) then
                            Validate("Ending Time", "Starting Time" + Quantity * 3600000);
                        if ("Starting Time" = 0T) and ("Ending Time" <> 0T) then
                            Validate("Starting Time", "Ending Time" - Quantity * 3600000);
                    end;
            end;
        end;
    end;

    procedure CheckResAvailability(Rec: Record "Job Planning Line";xRec: Record "Job Planning Line") MsgToDisplay: Text
    var
        Resource: Record Resource;
        AvailCap: Decimal;
        TotalCapacity: Decimal;
        Text002: Label 'Resource %1 is over capacitated on %2.';
        Text003: Label 'There are only %1 %2 available.';
        Text004: Label 'Please check Resource Availabilty for more details.';
        Job: Record Job;
        OverCapacitateResourceSetupValue: Integer;
    begin
        if not JobsSetup.Get then
            exit;

        //-NPR5.32 [275966]
        //IF NOT JobsSetup."Resource Availability Warning" THEN
        //  EXIT;
        //+NPR5.32 [275966]

        //-NPR5.32 [278090]
        //Job.GET(Rec."Job No.");
        if not Job.Get(Rec."Job No.") then
            exit;
        //+NPR5.32 [278090]

        if not IsEventJob(Job) then
            exit;

        if not InProperStatus(Job."Event Status") then
            exit;

        with Rec do begin
            if not "Schedule Line" then
                exit;
            if Type <> Type::Resource then
                exit;
            if "No." = '' then
                exit;
            if Quantity = 0 then
                exit;
            if "Planning Date" = 0D then
                exit;
          //-NPR5.55 [397741]
          if "Skip Cap./Avail. Check" then
            exit;
          //+NPR5.55 [397741]
            //-NPR5.35 [287270]
            /*
            //-NPR5.32 [275966]
            OverCapacitateResourceSetupValue := GetOverCapacitateResourceSetup(Rec);
            IF OverCapacitateResourceSetupValue IN [JobsSetup."Over Capacitate Resource"::" ",JobsSetup."Over Capacitate Resource"::Allow] THEN
              EXIT;
            //+NPR5.32 [275966]
            */
            if AllowOverCapacitateResource(Rec, OverCapacitateResourceSetupValue) then
                exit;
            //-NPR5.35 [287270]
            if not IsResCapacityAvail(Rec, xRec, AvailCap) then begin
                MsgToDisplay := StrSubstNo(Text002, "No.", Format("Planning Date"));
                if AvailCap > 0 then
                    MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(Text003, Format(AvailCap), "Unit of Measure Code");
            //-NPR5.55 [397741]
            if BufferMode then
              exit(MsgToDisplay);
            //+NPR5.55 [397741]
                //-NPR5.32 [275966]
                if OverCapacitateResourceSetupValue = JobsSetup."Over Capacitate Resource"::Disallow then
                    Error(MsgToDisplay);
                //-NPR5.32 [275966]
                MsgToDisplay := MsgToDisplay + ' ' + Text004 + ' ' + ContinueMsg;
                if not Confirm(MsgToDisplay) then
                    Error('');
            end;
          //-NPR5.55 [397741]
          //CheckResTimeFrameAvailability(Rec);
          MsgToDisplay := CheckResTimeFrameAvailability(Rec);
          //+NPR5.55 [397741]
        end;

    end;

    local procedure IsResCapacityAvail(Rec: Record "Job Planning Line"; xRec: Record "Job Planning Line"; var AvailCap: Decimal): Boolean
    var
        Resource: Record Resource;
        TotalCapacity: Decimal;
    begin
        with Rec do begin
            Resource.Get("No.");
            Resource.SetFilter("Date Filter", Format("Planning Date"));
            //-NPR5.40 [301375]
            /*
            Resource.CALCFIELDS("Qty. on Order (Job)","Qty. Quoted (Job)",Capacity);
            TotalCapacity := Resource."Qty. on Order (Job)" + Resource."Qty. Quoted (Job)";
            */
            Resource.CalcFields("Qty. on Order (Job)", "Qty. Quoted (Job)", Capacity, "Qty. Planned (Job)");
            TotalCapacity := Resource."Qty. on Order (Job)" + Resource."Qty. Quoted (Job)" + Resource."Qty. Planned (Job)";
            //+NPR5.40 [301375]
            if (xRec.Quantity > 0) and (xRec.Quantity <> Quantity) then
                TotalCapacity -= xRec.Quantity;
            AvailCap := Resource.Capacity - TotalCapacity;
            exit((Resource.Capacity = 0) or ((Resource.Capacity > 0) and (Quantity + TotalCapacity <= Resource.Capacity)));
        end;

    end;

    procedure CheckResTimeFrameAvailability(Rec: Record "Job Planning Line") MsgToDisplay: Text
    var
        TimeFrameProblemMsg: Label 'Time frame %1 - %2 for resource %3 is allready partially/fully used on other event/line:\%4 If you keep current time frame, resource may have difficulties fulfilling all engagements.';
        OverCapacitateResourceSetupValue: Integer;
    begin
        //-NPR5.49 [346780]
        if Rec.Type <> Rec.Type::Resource then
            exit;
        //+NPR5.49 [346780]
        //-NPR5.55 [397741]
        if Rec."Skip Cap./Avail. Check" then
          exit;
        //+NPR5.55 [397741]
        //-NPR5.35 [287270]
        if AllowOverCapacitateResource(Rec, OverCapacitateResourceSetupValue) then
            exit;
        //+NPR5.35 [287270]
        if not IsResTimeFrameAvail(Rec, MsgToDisplay) then begin
            //-NPR5.35 [287270]
            //MsgToDisplay := STRSUBSTNO(TimeFrameProblemMsg,FORMAT(Rec."Starting Time"),FORMAT(Rec."Ending Time"),Rec."No.",MsgToDisplay) + '\' + ContinueMsg;
            MsgToDisplay := StrSubstNo(TimeFrameProblemMsg, Format(Rec."Starting Time"), Format(Rec."Ending Time"), Rec."No.", MsgToDisplay);
          //-NPR5.55 [397741]
          if BufferMode then
            exit(MsgToDisplay);
          //+NPR5.55 [397741]
            if OverCapacitateResourceSetupValue = JobsSetup."Over Capacitate Resource"::Disallow then
                Error(MsgToDisplay);
            MsgToDisplay := MsgToDisplay + '\' + ContinueMsg;
            //+NPR5.35 [287270]
            if not Confirm(MsgToDisplay) then
                Error('');
        end;
    end;

    local procedure IsResTimeFrameAvail(Rec: Record "Job Planning Line"; var MsgToDisplay: Text): Boolean
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if (Rec."Starting Time" = 0T) or (Rec."Ending Time" = 0T) then
            exit(true);
        if Rec.Type <> Rec.Type::Resource then
            exit(true);
        if Rec."No." = '' then
            exit(true);

        with JobPlanningLine do begin
            SetFilter("Event Status", '<=%1', "Event Status"::Order);
            SetRange(Type, Type::Resource);
            SetRange("No.", Rec."No.");
            SetRange("Planning Date", Rec."Planning Date");
            SetRange("Schedule Line", true);

            SetFilter("Job No.", '<>%1', Rec."Job No.");
            //-NPR5.33 [275966]
            //ApplyTimeCombinations(JobPlanningLine,Rec,MsgToDisplay);
            ApplyTimeCombinations(JobPlanningLine, Rec);
            //+NPR5.33 [275966]
            SetRange("Job No.", Rec."Job No.");
            SetFilter("Job Task No.", '<>%1', Rec."Job Task No.");
            //-NPR5.33 [275966]
            //ApplyTimeCombinations(JobPlanningLine,Rec,MsgToDisplay);
            ApplyTimeCombinations(JobPlanningLine, Rec);
            //+NPR5.33 [275966]
            SetRange("Job Task No.", Rec."Job Task No.");
            SetFilter("Line No.", '<>%1', Rec."Line No.");
            //-NPR5.33 [275966]
            //ApplyTimeCombinations(JobPlanningLine,Rec,MsgToDisplay);
            ApplyTimeCombinations(JobPlanningLine, Rec);
            SetRange("Job No.");
            SetRange("Job Task No.");
            SetRange("Line No.");
            MarkedOnly(true);
            AddToMessage(JobPlanningLine, MsgToDisplay);
            //+NPR5.33 [275966]
        end;
        exit(MsgToDisplay = '');
    end;

    local procedure ApplyTimeCombinations(var JobPlanningLine: Record "Job Planning Line"; Rec: Record "Job Planning Line")
    begin
        with JobPlanningLine do begin
            //-NPR5.33 [275966]
            /*
              SETFILTER("Starting Time",'<%1',Rec."Starting Time");
              SETFILTER("Ending Time",'>%1',Rec."Ending Time");
              AddToMessage(JobPlanningLine,MsgToDisplay);
              SETFILTER("Ending Time",'<%1&>%2',Rec."Ending Time",Rec."Starting Time");
              AddToMessage(JobPlanningLine,MsgToDisplay);

              SETFILTER("Starting Time",'>%1',Rec."Starting Time");
              SETFILTER("Ending Time",'<%1',Rec."Ending Time");
              AddToMessage(JobPlanningLine,MsgToDisplay);

              SETFILTER("Starting Time",'>%1&<%2',Rec."Starting Time",Rec."Ending Time");
              SETFILTER("Ending Time",'>%1',Rec."Ending Time");
              AddToMessage(JobPlanningLine,MsgToDisplay);
            */
            SetFilter("Starting Time", '<=%1', Rec."Starting Time");
            SetFilter("Ending Time", '>=%1', Rec."Ending Time");
            MarkPlanningLine(JobPlanningLine);
            SetFilter("Ending Time", '<=%1&>%2', Rec."Ending Time", Rec."Starting Time");
            MarkPlanningLine(JobPlanningLine);

            SetFilter("Starting Time", '>%1', Rec."Starting Time");
            SetFilter("Ending Time", '<%1', Rec."Ending Time");
            MarkPlanningLine(JobPlanningLine);

            SetFilter("Starting Time", '>=%1&<%2', Rec."Starting Time", Rec."Ending Time");
            SetFilter("Ending Time", '>=%1', Rec."Ending Time");
            MarkPlanningLine(JobPlanningLine);
            SetRange("Starting Time");
            SetRange("Ending Time");
            //+NPR5.33 [276966]
        end;

    end;

    local procedure MarkPlanningLine(var JobPlanningLine: Record "Job Planning Line")
    begin
        if JobPlanningLine.FindSet then
            repeat
                JobPlanningLine.Mark(true);
            until JobPlanningLine.Next = 0;
    end;

    local procedure AddToMessage(var JobPlanningLine: Record "Job Planning Line"; var MsgToDisplay: Text)
    begin
        if JobPlanningLine.FindSet then
            repeat
                MsgToDisplay += JobPlanningLine."Job No." + ' ' + Format(JobPlanningLine."Starting Time") + ' - ' + Format(JobPlanningLine."Ending Time") + '\';
            until JobPlanningLine.Next = 0;
    end;

    procedure IsEventJob(Job: Record Job): Boolean
    begin
        exit(Job."Event");
    end;

    local procedure DeleteActivityLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", JobPlanningLine.RecordId);
        ActivityLog.DeleteAll;
    end;

    local procedure InProperStatus(Status: Option): Boolean
    begin
        exit(Status < 3);
    end;

    procedure EditTemplate(EventWordLayout: Record "Event Word Layout")
    var
        TempBlob: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        [RunOnClient]
        WordApplication: DotNet npNetApplicationClass;
        [RunOnClient]
        WordDocument: DotNet npNetDocument;
        [RunOnClient]
        WdWindowState: DotNet npNetWdWindowState;
        FileName: Text;
        NewFileName: Text;
        NewFileName2: Text;
        ErrorMessage: Text;
        LoadModifiedDoc: Boolean;
        WordCaption: Text;
        LoadDocQst: Label 'The template document has been edited in Word.\\Do you want to import the changes?';
        WordNotFoundErr: Label 'You cannot edit the template because Microsoft Word is not available on your computer. To edit the template, you must install a supported version of Word.';
        WaitMsg: Label 'Please wait while the template opens in Word.\After the template opens in Word, make changes to it,\and then close the Word document to continue.';
        Window: Dialog;
        Job: Record Job;
    begin
        if not CanLoadType(WordApplication) then
            Error(WordNotFoundErr);

        EventWordLayout.GetJobFromRecID(Job);
        WordCaption := Job."No." + ' ' + Format(EventWordLayout.Usage) + ' ' + EventWordLayout.TableCaption;
        Clear(TempBlob);
        TempBlob.FromRecord(EventWordLayout, EventWordLayout.FieldNo(Layout));
        Window.Open(WaitMsg);
        FileName := FileMgt.BLOBExport(TempBlob, FileName, false);

        //-NPR5.35 [285826]
        //WordApplication := WordHelper.GetApplication(ErrorMessage);
        EventVersionSpecificMgt.WordHelperGetApplication(WordApplication, ErrorMessage);
        //+NPR5.35 [285826]
        if IsNull(WordApplication) then
            Error(WordNotFoundErr);

        //-NPR5.35 [285826]
        /*
        WordHandler := WordHandler.WordHandler;
        WordDocument := WordHelper.CallOpen(WordApplication,FileName,FALSE,FALSE);
        */
        EventVersionSpecificMgt.WordHandlerConstructor();
        EventVersionSpecificMgt.WordHelperCallOpen(WordApplication, FileName, false, false, WordDocument);
        //+NPR5.35 [285826]
        WordDocument.ActiveWindow.Caption := WordCaption;
        WordDocument.Application.Visible := true;
        WordDocument.ActiveWindow.WindowState := WdWindowState.wdWindowStateNormal;

        WordApplication.WindowState := WdWindowState.wdWindowStateMinimize;
        WordApplication.Visible := true;
        WordApplication.Activate;
        WordApplication.WindowState := WdWindowState.wdWindowStateNormal;

        WordDocument.Saved := true;
        WordDocument.Application.Activate;

        //-NPR5.35 [285826]
        //NewFileName := WordHandler.WaitForDocument(WordDocument);
        NewFileName := EventVersionSpecificMgt.WordHandlerWaitForDocument(WordDocument);
        //+NPR5.35 [285826]
        Window.Close;

        Clear(WordApplication);

        LoadModifiedDoc := Confirm(LoadDocQst);

        if LoadModifiedDoc then begin
            FileMgt.BLOBImport(TempBlob, NewFileName);
            EventWordLayout.ImportLayoutBlob(TempBlob, '');
        end;

        FileMgt.DeleteClientFile(FileName);
        if FileName <> NewFileName then
            FileMgt.DeleteClientFile(NewFileName);

    end;

    procedure SaveReportAs(Job: Record Job; TemplateType: Option Customer,Team; SaveAs: Option Word,PDF; FileName: Text)
    var
        CurrentJob: Record Job;
        ReportID: Integer;
    begin
        CurrentJob.Copy(Job);
        CurrentJob.SetRecFilter;
        case TemplateType of
            TemplateType::Customer:
                ReportID := REPORT::"Event Customer Template";
            TemplateType::Team:
                ReportID := REPORT::"Event Team Template";
        end;
        case SaveAs of
            SaveAs::Word:
                REPORT.SaveAsWord(ReportID, FileName, CurrentJob);
            SaveAs::PDF:
                REPORT.SaveAsPdf(ReportID, FileName, CurrentJob);
        end;
    end;

    procedure CopyTemplates(FromEventNo: Code[20]; ToEventNo: Code[20]; CopyWhatHere: Option All,Customer,Team; var ReturnMsg: Text): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
        NoUsageSetErr: Label 'You need to specify Usage before you can copy a template.';
        EventWordLayoutFrom: Record "Event Word Layout";
        EventWordLayoutTo: Record "Event Word Layout";
    begin
        JobFrom.Get(FromEventNo);
        JobTo.Get(ToEventNo);
        EventWordLayoutFrom.SetRange("Source Record ID", JobFrom.RecordId);
        if CopyWhatHere > 0 then
            EventWordLayoutFrom.SetRange(Usage, CopyWhatHere);
        if EventWordLayoutFrom.FindSet then begin
            repeat
                //-NPR5.32 [275957]
                EventWordLayoutFrom.CalcFields(Layout, "XML Part");
                //+NPR5.32 [275957]
                EventWordLayoutTo.Init;
                EventWordLayoutTo := EventWordLayoutFrom;
                EventWordLayoutTo."Source Record ID" := JobTo.RecordId;
                //-NPR5.32 [275957]
                //EventWordLayoutTo.INSERT;
                EventWordLayoutTo.Insert(true);
            //+NPR5.32 [275957]
            until EventWordLayoutFrom.Next = 0;
            exit(true);
        end;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    procedure MergeAndSaveWordLayout(EventWordLayout: Record "Event Word Layout"; SaveAs: Option Word,Pdf; FileName: Text)
    var
        Job: Record Job;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStrWordDoc: InStream;
        OutStrWordDoc: OutStream;
        DoConvertToPdf: Boolean;
        InStrXmlData: InStream;
        FileNameXml: Text;
        TempFile: File;
        FileExtension: Text;
        ExtensionMismatch: Label 'Provided file extension %1 can''t be used on file type %2.';
        EMailTemplateHeader: Record "E-mail Template Header";
    begin
        EventWordLayout.GetJobFromRecID(Job);
        Job.SetRecFilter;
        ValidateAndUpdateWordLayoutOnRecord(EventWordLayout);
        EventWordLayout.CalcFields(Layout);
        EventWordLayout.Layout.CreateInStream(InStrWordDoc);
        ValidateWordLayoutCheckOnly(EventWordLayout."Report ID", InStrWordDoc);
        TempBlob.CreateOutStream(OutStrWordDoc);

        FileNameXml := FileMgt.ServerTempFileName('xml');
        REPORT.SaveAsXml(EventWordLayout."Report ID", FileNameXml, Job);
        TempFile.Open(FileNameXml);
        TempFile.CreateInStream(InStrXmlData);
        //-NPR5.35 [285826]
        //OutStrWordDoc := NAVWordXMLMerger.MergeWordDocument(InStrWordDoc,InStrXmlData,OutStrWordDoc);
        EventVersionSpecificMgt.WordXMLMergerMergeWordDocument(InStrWordDoc, InStrXmlData, OutStrWordDoc, OutStrWordDoc);
        //+NPR5.35 [285826]
        TempFile.Close;

        FileExtension := 'docx';
        if SaveAs = SaveAs::Pdf then begin
            FileExtension := 'pdf';
            DoConvertToPdf := true;
            ConvertWordToPdf(TempBlob);
        end;

        if FileName = '' then begin
            //-NPR5.31 [269162]
            //FileName := EventEmailMgt.CreateFileName(Job) + '.' + FileExtension;
            //-NPR5.34 [277938]
            //FileName := EventEWSMgt.CreateFileName(Job,0) + '.' + FileExtension;
            FileName := EventEWSMgt.CreateFileName(Job, EMailTemplateHeader) + '.' + FileExtension;
            //+NPR5.34 [277938]
            //+NPR5.31 [269162]
            FileMgt.BLOBExport(TempBlob, FileName, true)
        end else begin
            if FileMgt.GetExtension(FileName) <> FileExtension then
                Error(ExtensionMismatch, FileMgt.GetExtension(FileName), Format(SaveAs));
            FileMgt.BLOBExportToServerFile(TempBlob, FileName);
        end;
    end;

    local procedure ValidateWordLayoutCheckOnly(ReportID: Integer; DocumentStream: InStream)
    var
        ValidationErrors: Text;
        ValidationErrorFormat: Text;
        TemplateAfterUpdateValidationErr: Label 'The automatic update could not resolve all the conflicts in the current Word layout. For example, the layout uses fields that are missing in the report design or the report ID is wrong.\The following errors were detected:\%1\You must manually update the layout to match the current report design.';
    begin
        //-NPR5.35 [285826]
        //ValidationErrors := NAVWordXMLMerger.ValidateWordDocumentTemplate(DocumentStream,REPORT.WORDXMLPART(ReportID,TRUE));
        ValidationErrors := EventVersionSpecificMgt.WordXMLMergerValidateWordDocumentTemplate(DocumentStream, REPORT.WordXmlPart(ReportID, true));
        //+NPR5.35 [285826]
        if ValidationErrors <> '' then begin
            ValidationErrorFormat := TemplateAfterUpdateValidationErr;
            Message(ValidationErrorFormat, ValidationErrors);
        end;
    end;

    local procedure ValidateAndUpdateWordLayoutOnRecord(EventWordLayout: Record "Event Word Layout"): Boolean
    var
        DocumentStream: InStream;
        ValidationErrors: Text;
        TemplateValidationUpdateQst: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the layout validation:\%1\Do you want to run an automatic update?';
        TemplateValidationErr: Label 'The Word layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the document validation:\%1\You must update the layout to match the current report design.';
    begin
        EventWordLayout.CalcFields(Layout);
        EventWordLayout.Layout.CreateInStream(DocumentStream);
        //-NPR5.35 [285826]
        /*
        NAVWordXMLMerger := NAVWordXMLMerger.WordReportManager;
        ValidationErrors :=
          NAVWordXMLMerger.ValidateWordDocumentTemplate(DocumentStream,REPORT.WORDXMLPART(EventWordLayout."Report ID",TRUE));
        */
        EventVersionSpecificMgt.WordXMLMergerConstructor();
        ValidationErrors := EventVersionSpecificMgt.WordXMLMergerValidateWordDocumentTemplate(DocumentStream, REPORT.WordXmlPart(EventWordLayout."Report ID", true));
        //+NPR5.35 [285826]
        if ValidationErrors <> '' then begin
            if Confirm(TemplateValidationUpdateQst, false, ValidationErrors) then begin
                ValidationErrors := EventWordLayout.TryUpdateLayout(false);
                Commit;
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
        //-NPR5.35 [285826]
        //PdfWriter.ConvertToPdf(InStreamWordDoc,OutStreamPdfDoc);
        EventVersionSpecificMgt.PdfWriterConvertToPdf(InStreamWordDoc, OutStreamPdfDoc);
        //+NPR5.35 [285826]
        TempBlob := TempBlobPdf;
    end;

    local procedure GetOverCapacitateResourceSetup(JobPlanningLine: Record "Job Planning Line") SetupValue: Integer
    var
        Resource: Record Resource;
    begin
        Resource.Get(JobPlanningLine."No.");
        SetupValue := Resource."Over Capacitate Resource";
        if SetupValue = 0 then
            SetupValue := JobsSetup."Over Capacitate Resource";
        exit(SetupValue);
    end;

    local procedure CopyExchIntTemplates(FromEventNo: Code[20]; ToEventNo: Code[20]; var ReturnMsg: Text): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
        EventExchIntTempEntryFrom: Record "Event Exch. Int. Temp. Entry";
        EventExchIntTempEntryTo: Record "Event Exch. Int. Temp. Entry";
    begin
        JobFrom.Get(FromEventNo);
        JobTo.Get(ToEventNo);
        EventExchIntTempEntryFrom.SetRange("Source Record ID", JobFrom.RecordId);
        if EventExchIntTempEntryFrom.FindSet then begin
            repeat
                EventExchIntTempEntryTo.Init;
                EventExchIntTempEntryTo := EventExchIntTempEntryFrom;
                EventExchIntTempEntryTo."Source Record ID" := JobTo.RecordId;
                EventExchIntTempEntryTo.Insert;
            //-NPR5.35 [277938]
            //UNTIL EventExchIntTempEntryTo.NEXT = 0;
            until EventExchIntTempEntryFrom.Next = 0;
            //+NPR5.35 [277938]
            exit(true);
        end;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    local procedure RelatedSalesInvoiceCreditMemoExists(Rec: Record Job): Boolean
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        //-NPR5.35 [275959]
        JobPlanningLineInvoice.SetRange("Job No.", Rec."No.");
        exit(not JobPlanningLineInvoice.IsEmpty);
        //+NPR5.35 [275959]
    end;

    local procedure JobLedgEntryExist(Rec: Record Job): Boolean
    var
        JobLedgEntry: Record "Job Ledger Entry";
    begin
        //-NPR5.35 [275959]
        Clear(JobLedgEntry);
        JobLedgEntry.SetCurrentKey("Job No.");
        JobLedgEntry.SetRange("Job No.", Rec."No.");
        exit(not JobLedgEntry.IsEmpty);
        //+NPR5.35 [275959]
    end;

    procedure AllowOverCapacitateResource(Rec: Record "Job Planning Line";var OverCapacitateResourceSetupValue: Integer): Boolean
    begin
        JobsSetup.Get();
        OverCapacitateResourceSetupValue := GetOverCapacitateResourceSetup(Rec);
        exit(OverCapacitateResourceSetupValue in [JobsSetup."Over Capacitate Resource"::" ", JobsSetup."Over Capacitate Resource"::Allow]);
    end;

    local procedure FindJobUnitPriceInclVAT(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer)
    var
        Job: Record Job;
        VATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        Item: Record Item;
        Resource: Record Resource;
        VATBusPostGroup: Code[10];
        VATProdPostGroup: Code[10];
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
            JobPlanningLine."Est. VAT %" := VATPostingSetup."VAT %";
        UpdateUnitPriceInclVAT(JobPlanningLine);
    end;

    local procedure UpdateUnitPriceInclVAT(var JobPlanningLine: Record "Job Planning Line")
    begin
        if not RoundingSet then
            SetRoundingPrecision(JobPlanningLine."Currency Code");
        JobPlanningLine."Est. Unit Price Incl. VAT" := Round(JobPlanningLine."Unit Price" * (1 + JobPlanningLine."Est. VAT %" / 100), UnitAmountRoundingPrecisionFCY);
        JobPlanningLine."Est. Unit Price Incl VAT (LCY)" := Round(JobPlanningLine."Unit Price (LCY)" * (1 + JobPlanningLine."Est. VAT %" / 100), UnitAmountRoundingPrecision);
        CalcLineAmountInclVAT(JobPlanningLine);
    end;

    local procedure CalcLineAmountInclVAT(var JobPlanningLine: Record "Job Planning Line")
    begin
        if not RoundingSet then
            SetRoundingPrecision(JobPlanningLine."Currency Code");
        JobPlanningLine."Est. Line Amount Incl. VAT" := Round(JobPlanningLine."Line Amount" * (1 + JobPlanningLine."Est. VAT %" / 100), AmountRoundingPrecisionFCY);
        JobPlanningLine."Est. Line Amt. Incl. VAT (LCY)" := Round(JobPlanningLine."Line Amount (LCY)" * (1 + JobPlanningLine."Est. VAT %" / 100), AmountRoundingPrecision);
    end;

    local procedure SetRoundingPrecision(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        Clear(Currency);
        Currency.InitRoundingPrecision;
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
        if CommentLineFrom.FindSet then
            repeat
                CommentLineTo := CommentLineFrom;
                CommentLineTo."No." := ToEventNo;
                CommentLineTo.Insert;
            until CommentLineFrom.Next = 0;
        ReturnMsg := NothingToCopyTxt;
        exit(false);
    end;

    local procedure CalcLineAmountLCY(JobPlanningLine: Record "Job Planning Line"; Qty: Decimal): Decimal
    var
        TotalPrice: Decimal;
    begin
        //-NPR5.48 [287903]
        TotalPrice := Round(Qty * JobPlanningLine."Unit Price (LCY)", 0.01);
        exit(TotalPrice - Round(TotalPrice * JobPlanningLine."Line Discount %" / 100, 0.01));
        //+NPR5.48 [287903]
    end;

    procedure PostEventSalesDoc(var JobPlanningLineInvoice: Record "Job Planning Line Invoice"; PostedDocType: Integer; PostedDocNo: Code[20]; PostingDate: Date)
    var
        JobPlanningLineInvoice2: Record "Job Planning Line Invoice";
    begin
        //-NPR5.48 [287903]
        ChangeJobPlanInvoiceFromNonpostedToPosted(JobPlanningLineInvoice, PostedDocType, PostedDocNo, PostingDate, JobPlanningLineInvoice2);
        if not CheckJobsSetup(2) then
            exit;
        InitJobRegister();
        PrepareAndPostJournal(JobPlanningLineInvoice2, PostedDocNo);
        //+NPR5.48 [287903]
    end;

    procedure CheckJobsSetup(ProcessStep: Option Creation,PostingInventoryOnly,PostingBothInventoryAndJob): Boolean
    begin
        //-NPR5.48 [287903]
        JobsSetup.Get();
        case ProcessStep of
            ProcessStep::Creation:
                exit(JobsSetup."Post Event on Sales Inv. Post" = JobsSetup."Post Event on Sales Inv. Post"::" ");
            ProcessStep::PostingInventoryOnly:
                exit(JobsSetup."Post Event on Sales Inv. Post" = JobsSetup."Post Event on Sales Inv. Post"::"Only Inventory");
            ProcessStep::PostingBothInventoryAndJob:
                exit(JobsSetup."Post Event on Sales Inv. Post" = JobsSetup."Post Event on Sales Inv. Post"::"Both Inventory and Job");
        end;
        //+NPR5.48 [287903]
    end;

    local procedure CheckSalesDoc(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        JobPlanningLine: Record "Job Planning Line";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        PostedDocType: Integer;
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        //-NPR5.48 [287903]
        JobPlanningLineInvoiceExists(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", JobPlanningLineInvoice, PostedDocType);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>0');
        if SalesLine.FindSet then
            repeat
                if (SalesLine."Job Contract Entry No." = 0) and (SalesLine."Job No." <> '') and (SalesLine."Job Task No." <> '') then begin
                    JobPlanningLineInvoice.SetRange("Line No.", SalesLine."Line No.");
                    if JobPlanningLineInvoice.FindFirst then begin
                        JobPlanningLine.Get(JobPlanningLineInvoice."Job No.", JobPlanningLineInvoice."Job Task No.", JobPlanningLineInvoice."Job Planning Line No.");
                        Job.Get(JobPlanningLine."Job No.");
                        Job.TestBlocked;
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
            until SalesLine.Next = 0;
        //+NPR5.48 [287903]
    end;

    local procedure JobPlanningLineInvoiceExists(DocTableID: Integer; DocType: Integer; DocNo: Code[20]; var JobPlanningLineInvoice: Record "Job Planning Line Invoice"; var PostedDocType: Integer): Boolean
    var
        SalesHeader: Record "Sales Header";
        JobPlanInvLineDocType: Integer;
    begin
        //-NPR5.48 [287903]
        PostedDocType := 0;
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
            DATABASE::"Sale POS":
                begin
                    JobPlanInvLineDocType := JobPlanningLineInvoice."Document Type"::Invoice;
                    PostedDocType := JobPlanningLineInvoice."Document Type"::"Posted Invoice";
                end;
        end;
        JobPlanningLineInvoice.SetRange("Document Type", JobPlanInvLineDocType);
        JobPlanningLineInvoice.SetRange("Document No.", DocNo);
        exit(not JobPlanningLineInvoice.IsEmpty);
        //+NPR5.48 [287903]
    end;

    local procedure ChangeJobPlanInvoiceFromNonpostedToPosted(var NonPostedJobPlanningLineInvoice: Record "Job Planning Line Invoice"; PostedDocType: Integer; PostedDocNo: Code[20]; PostingDate: Date; var PostedJobPlanningLineInvoice: Record "Job Planning Line Invoice")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        JobPlanningLine: Record "Job Planning Line";
        JobLedgEntry: Record "Job Ledger Entry";
        NextEntryNo: Integer;
    begin
        //-NPR5.48 [287903]
        Clear(PostedJobPlanningLineInvoice);
        if NonPostedJobPlanningLineInvoice.FindSet then
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
                JobPlanningLineInvoice.Modify;
                JobPlanningLine.UpdateQtyToInvoice;
                JobPlanningLine.Modify;
            until NonPostedJobPlanningLineInvoice.Next = 0;
        PostedJobPlanningLineInvoice.SetRange("Document Type", PostedDocType);
        PostedJobPlanningLineInvoice.SetRange("Document No.", PostedDocNo);
        //+NPR5.48 [287903]
    end;

    local procedure InitJobRegister()
    var
        JobLedgEntry: Record "Job Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
        JobRegNo: Integer;
    begin
        //-NPR5.48 [287903]
        if JobRegisterInitialized then
            exit;
        SourceCodeSetup.Get();
        JobLedgEntry.LockTable;
        if JobLedgEntry.FindLast then
            NextEntryNo := JobLedgEntry."Entry No.";
        NextEntryNo := NextEntryNo + 1;

        JobReg.LockTable;
        if JobReg.FindLast then
            JobRegNo := JobReg."No.";
        JobRegNo := JobRegNo + 1;

        JobReg.Init;
        JobReg."No." := JobRegNo;
        JobReg."From Entry No." := NextEntryNo;
        JobReg."To Entry No." := NextEntryNo;
        JobReg."Creation Date" := Today;
        JobReg."Source Code" := SourceCodeSetup.Sales;
        JobReg."Journal Batch Name" := '';
        JobReg."User ID" := UserId;
        JobReg.Insert;
        JobRegisterInitialized := true;
        //+NPR5.48 [287903]
    end;

    local procedure PrepareAndPostJournal(var JobPlanningLineInvoice: Record "Job Planning Line Invoice"; PostedDocNo: Code[20])
    var
        JobJnlLine: Record "Job Journal Line";
    begin
        //-NPR5.48 [287903]
        if JobPlanningLineInvoice.FindSet then
            repeat
                PrepareJobJournal(JobPlanningLineInvoice, 0, JobJnlLine); //Usage
                PostJournal(JobPlanningLineInvoice, JobJnlLine);
                PrepareJobJournal(JobPlanningLineInvoice, 1, JobJnlLine); //Sale
                PostJournal(JobPlanningLineInvoice, JobJnlLine);
            until JobPlanningLineInvoice.Next = 0;
        //+NPR5.48 [287903]
    end;

    local procedure PrepareJobJournal(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; EntryType: Option Usage,Sale; var JobJnlLine: Record "Job Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobTask: Record "Job Task";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        POSEntry: Record "POS Entry";
        POSSalesLine: Record "POS Sales Line";
        SourceCodeSetup: Record "Source Code Setup";
        Item: Record Item;
        DocumentDate: Date;
        DocumentNo: Code[20];
        PostingGroup: Code[10];
        GenBusPostGroup: Code[10];
        GenProdPostGroup: Code[10];
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
        CurrencyCode: Code[10];
        UnitCost: Decimal;
        UnitCostLCY: Decimal;
        LineDiscPerc: Decimal;
        ShortcutDimCode1: Code[20];
        ShortcutDimCode2: Code[20];
        DimSetID: Integer;
    begin
        //-NPR5.48 [287903]
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
                                //-NPR5.49 [331208]
                                case POSDocPostType of
                                    POSDocPostType::" ":
                                        begin
                                            //+NPR5.49 [331208]
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
                                            CurrencyCode := SalesInvHeader."Currency Code";
                                            UnitCost := SalesInvLine."Unit Cost";
                                            UnitCostLCY := SalesInvLine."Unit Cost (LCY)";
                                            LineDiscPerc := SalesInvLine."Line Discount %";
                                            ShortcutDimCode1 := SalesInvLine."Shortcut Dimension 1 Code";
                                            ShortcutDimCode2 := SalesInvLine."Shortcut Dimension 2 Code";
                                            DimSetID := SalesInvLine."Dimension Set ID";
                                            //-NPR5.49 [331208]
                                        end;
                                    POSDocPostType::"Audit Roll":
                                        begin
                                            DocumentDate := AuditRollPosting."Sale Date";
                                            DocumentNo := AuditRollPosting."Posted Doc. No.";
                                            PostingGroup := AuditRollPosting."Posting Group";
                                            GenBusPostGroup := AuditRollPosting."Gen. Bus. Posting Group";
                                            GenProdPostGroup := AuditRollPosting."Gen. Prod. Posting Group";
                                            Description := AuditRollPosting.Description;
                                            UnitOfMeasureCode := AuditRollPosting.Unit;
                                            QtyPerUoM := 1; //may need change if we introduce this to Audit Roll
                                            LocationCode := AuditRollPosting.Lokationskode;
                                            BinCode := AuditRollPosting."Bin Code";
                                            ReasonCode := AuditRollPosting."Reason Code";
                                            Quantity := AuditRollPosting.Quantity;
                                            CurrencyCode := AuditRollPosting."Currency Code";
                                            UnitCost := AuditRollPosting."Unit Cost";
                                            UnitCostLCY := AuditRollPosting."Unit Cost (LCY)";
                                            LineDiscPerc := AuditRollPosting."Line Discount %";
                                            ShortcutDimCode1 := AuditRollPosting."Shortcut Dimension 1 Code";
                                            ShortcutDimCode2 := AuditRollPosting."Shortcut Dimension 2 Code";
                                            DimSetID := AuditRollPosting."Dimension Set ID";
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
                                            CurrencyCode := POSEntry."Currency Code";
                                            UnitCost := POSSalesLine."Unit Cost";
                                            UnitCostLCY := POSSalesLine."Unit Cost (LCY)";
                                            LineDiscPerc := POSSalesLine."Line Discount %";
                                            ShortcutDimCode1 := POSSalesLine."Shortcut Dimension 1 Code";
                                            ShortcutDimCode2 := POSSalesLine."Shortcut Dimension 2 Code";
                                            DimSetID := POSSalesLine."Dimension Set ID";
                                        end;
                                end;
                                //+NPR5.49 [331208]
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
                                CurrencyCode := SalesCrMemoHeader."Currency Code";
                                UnitCost := SalesCrMemoLine."Unit Cost";
                                UnitCostLCY := SalesCrMemoLine."Unit Cost (LCY)";
                                LineDiscPerc := SalesCrMemoLine."Line Discount %";
                                ShortcutDimCode1 := SalesCrMemoLine."Shortcut Dimension 1 Code";
                                ShortcutDimCode2 := SalesCrMemoLine."Shortcut Dimension 2 Code";
                                DimSetID := SalesCrMemoLine."Dimension Set ID";
                            end;
                    end;
                    JobJnlLine."Line Type" := JobPlanningLine."Line Type" + 1;
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
                        JobJnlLine."Line Type" := JobPlanningLine."Line Type" + 1;
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
                JobJnlLine.UpdateDimensions;
        end;
        //+NPR5.48 [287903]
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
        //-NPR5.48 [287903]
        with JobJnlLine do begin
            Job.Get("Job No.");
            TestField("Currency Code", Job."Currency Code"); //this should be tested when creating invoice so this process doesnt fail to late
            JobTask.Get("Job No.", "Job Task No.");
            GLSetup.Get;
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
                case Type of
                    Type::Resource:
                        begin
                            InitResJnlLine(JobJnlLine, ResJnlLine);
                            ResLedgEntry.LockTable;
                            ResJnlPostLine.RunWithCheck(ResJnlLine);
                            JobJnlLine."Resource Group No." := ResJnlLine."Resource Group No.";
                            JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
                        end;
                    Type::Item:
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
                                    if JobLedgEntry2.FindFirst and (JobLedgEntry2.Quantity = -ItemLedgEntry.Quantity) then
                                        SkipJobLedgerEntry := true
                                    else begin
                                        JobJnlLine."Serial No." := ItemLedgEntry."Serial No.";
                                        JobJnlLine."Lot No." := ItemLedgEntry."Lot No.";
                                    end;
                                end;
                                if not SkipJobLedgerEntry then begin
                                    TempRemainingQty := JobJnlLine."Remaining Qty.";
                                    JobJnlLine.Quantity := -ValueEntry."Invoiced Quantity" / "Qty. per Unit of Measure";
                                    JobJnlLine."Quantity (Base)" := Round(JobJnlLine.Quantity * "Qty. per Unit of Measure", 0.00001);
                                    if "Currency Code" <> '' then
                                        Currency.Get("Currency Code")
                                    else
                                        Currency.InitRoundingPrecision;

                                    UpdateJobJnlLineTotalAmounts(JobJnlLine, Currency."Amount Rounding Precision");
                                    UpdateJobJnlLineAmount(
                                      JobJnlLine, RemainingAmount, RemainingAmountLCY, RemainingQtyToTrack, Currency."Amount Rounding Precision");

                                    JobJnlLine.Validate("Remaining Qty.", TempRemainingQty);
                                    JobJnlLine."Ledger Entry Type" := "Ledger Entry Type"::Item;
                                    JobJnlLine."Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
                                    JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
                                    ValueEntry."Job Ledger Entry No." := JobLedgEntryNo;
                                    ValueEntry.Modify(true);
                                end;
                            until ValueEntry.Next = 0;
                        end;
                    Type::"G/L Account":
                        JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
                end;
            end else
                JobLedgEntryNo := CreateJobLedgEntry(JobJnlLine);
        end;

        exit(JobLedgEntryNo);
        //+NPR5.48 [287903]
    end;

    local procedure ValidateUnitCostAndPrice(var JobJournalLine: Record "Job Journal Line"; Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        //-NPR5.48 [287903]
        if Item."Costing Method" <> Item."Costing Method"::Standard then
            JobJournalLine.Validate("Unit Cost", UnitCost);
        JobJournalLine.Validate("Unit Price", UnitPrice);
        //+NPR5.48 [287903]
    end;

    local procedure GetJobConsumptionValueEntry(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; var ValueEntry: Record "Value Entry"; JobJournalLine: Record "Job Journal Line"): Boolean
    begin
        //-NPR5.48 [287903]
        with JobJournalLine do begin
            //ValueEntry.SETCURRENTKEY("Job No.","Job Task No.","Document No.");
            ValueEntry.SetRange("Item No.", "No.");
            //ValueEntry.SETRANGE("Job No.","Job No.");
            //ValueEntry.SETRANGE("Job Task No.","Job Task No.");
            //ValueEntry.SETRANGE("Document No.","Document No.");
            ValueEntry.SetRange("Document No.", JobPlanningLineInvoice."Document No.");
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
            ValueEntry.SetRange("Job Ledger Entry No.", 0);
        end;
        exit(ValueEntry.FindSet);
        //+NPR5.48 [287903]
    end;

    local procedure CreateJobLedgEntry(JobJnlLine: Record "Job Journal Line"): Integer
    var
        JobLedgEntry: Record "Job Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        JobPlanningLine: Record "Job Planning Line";
        Job: Record Job;
        JobTransferLine: Codeunit "Job Transfer Line";
        EventLinkUsage: Codeunit "Event Link Usage";
        JobPostLine: Codeunit "Job Post-Line";
    begin
        //-NPR5.48 [287903]
        SetCurrency(JobJnlLine);

        JobLedgEntry.Init;
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

        with JobJnlLine do
            case Type of
                Type::Resource:
                    begin
                        if "Entry Type" = "Entry Type"::Usage then begin
                            if ResLedgEntry.FindLast then begin
                                JobLedgEntry."Ledger Entry Type" := JobLedgEntry."Ledger Entry Type"::Resource;
                                JobLedgEntry."Ledger Entry No." := ResLedgEntry."Entry No.";
                            end;
                        end;
                    end;
                Type::Item:
                    begin
                        JobLedgEntry."Ledger Entry Type" := "Ledger Entry Type"::Item;
                        JobLedgEntry."Ledger Entry No." := "Ledger Entry No.";
                        JobLedgEntry."Serial No." := "Serial No.";
                        JobLedgEntry."Lot No." := "Lot No.";
                    end;
                Type::"G/L Account":
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
        JobReg.Modify;

        if JobLedgEntry."Entry Type" = JobLedgEntry."Entry Type"::Usage then begin
            // Usage Link should be applied if it is enabled for the job,
            // if a Job Planning Line number is defined or if it is enabled for a Job Planning Line.
            Job.Get(JobLedgEntry."Job No.");
            if Job."Apply Usage Link" or
               (JobJnlLine."Job Planning Line No." <> 0) or
               //-NPR5.49 [331208]
               /*
                  JobLinkUsage.FindMatchingJobPlanningLine(JobPlanningLine,JobLedgEntry)
               THEN
                 JobLinkUsage.ApplyUsage(JobLedgEntry,JobJnlLine)
               */
               EventLinkUsage.FindMatchingJobPlanningLine(JobPlanningLine, JobLedgEntry)
            then begin
                EventLinkUsage.SetAutoConfirm(true);
                EventLinkUsage.ApplyUsage(JobLedgEntry, JobJnlLine)
            end
            //+NPR5.49 [331208]
            else
                JobPostLine.InsertPlLineFromLedgEntry(JobLedgEntry)
        end;

        NextEntryNo := NextEntryNo + 1;

        exit(JobLedgEntry."Entry No.");
        //+NPR5.48 [287903]

    end;

    local procedure SetCurrency(JobJnlLine: Record "Job Journal Line")
    var
        Currency: Record Currency;
    begin
        //-NPR5.48 [287903]
        if JobJnlLine."Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision
        end else begin
            Currency.Get(JobJnlLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        //+NPR5.48 [287903]
    end;

    local procedure InitResJnlLine(JobJnlLine: Record "Job Journal Line"; var ResJnlLine: Record "Res. Journal Line")
    begin
        //-NPR5.48 [287903]
        with ResJnlLine do begin
            Init;
            "Entry Type" := JobJnlLine."Entry Type";
            "Document No." := JobJnlLine."Document No.";
            "External Document No." := JobJnlLine."External Document No.";
            "Posting Date" := JobJnlLine."Posting Date";
            "Document Date" := JobJnlLine."Document Date";
            "Resource No." := JobJnlLine."No.";
            Description := JobJnlLine.Description;
            "Work Type Code" := JobJnlLine."Work Type Code";
            "Job No." := JobJnlLine."Job No.";
            "Shortcut Dimension 1 Code" := JobJnlLine."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := JobJnlLine."Shortcut Dimension 2 Code";
            "Dimension Set ID" := JobJnlLine."Dimension Set ID";
            "Unit of Measure Code" := JobJnlLine."Unit of Measure Code";
            "Source Code" := JobJnlLine."Source Code";
            "Gen. Bus. Posting Group" := JobJnlLine."Gen. Bus. Posting Group";
            "Gen. Prod. Posting Group" := JobJnlLine."Gen. Prod. Posting Group";
            "Posting No. Series" := JobJnlLine."Posting No. Series";
            "Reason Code" := JobJnlLine."Reason Code";
            "Resource Group No." := JobJnlLine."Resource Group No.";
            "Recurring Method" := JobJnlLine."Recurring Method";
            "Expiration Date" := JobJnlLine."Expiration Date";
            "Recurring Frequency" := JobJnlLine."Recurring Frequency";
            Quantity := JobJnlLine.Quantity;
            "Qty. per Unit of Measure" := JobJnlLine."Qty. per Unit of Measure";
            "Direct Unit Cost" := JobJnlLine."Direct Unit Cost (LCY)";
            "Unit Cost" := JobJnlLine."Unit Cost (LCY)";
            "Total Cost" := JobJnlLine."Total Cost (LCY)";
            "Unit Price" := JobJnlLine."Unit Price (LCY)";
            "Total Price" := JobJnlLine."Line Amount (LCY)";
            "Time Sheet No." := JobJnlLine."Time Sheet No.";
            "Time Sheet Line No." := JobJnlLine."Time Sheet Line No.";
            "Time Sheet Date" := JobJnlLine."Time Sheet Date";
        end;
        //+NPR5.48 [287903]
    end;

    local procedure UpdateJobJnlLineTotalAmounts(var JobJnlLineToUpdate: Record "Job Journal Line"; AmtRoundingPrecision: Decimal)
    begin
        //-NPR5.48 [287903]
        with JobJnlLineToUpdate do begin
            "Total Cost" := Round("Unit Cost" * Quantity, AmtRoundingPrecision);
            "Total Cost (LCY)" := Round("Unit Cost (LCY)" * Quantity, AmtRoundingPrecision);
            "Total Price" := Round("Unit Price" * Quantity, AmtRoundingPrecision);
            "Total Price (LCY)" := Round("Unit Price (LCY)" * Quantity, AmtRoundingPrecision);
        end;
        //+NPR5.48 [287903]
    end;

    local procedure UpdateJobJnlLineAmount(var JobJnlLineToUpdate: Record "Job Journal Line"; var RemainingAmount: Decimal; var RemainingAmountLCY: Decimal; var RemainingQtyToTrack: Decimal; AmtRoundingPrecision: Decimal)
    begin
        //-NPR5.48 [287903]
        with JobJnlLineToUpdate do begin
            "Line Amount" := Round(RemainingAmount * Quantity / RemainingQtyToTrack, AmtRoundingPrecision);
            "Line Amount (LCY)" := Round(RemainingAmountLCY * Quantity / RemainingQtyToTrack, AmtRoundingPrecision);

            RemainingAmount -= "Line Amount";
            RemainingAmountLCY -= "Line Amount (LCY)";
            RemainingQtyToTrack -= Quantity;
        end;
        //+NPR5.48 [287903]
    end;

    local procedure ValidateRelationship(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; JobPlanningLine: Record "Job Planning Line")
    var
        JobTask: Record "Job Task";
        Txt: Text[500];
        Text000: Label 'has been changed (initial a %1: %2= %3, %4= %5)';
    begin
        //-NPR5.48 [287903]
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
        //+NPR5.48 [287903]
    end;

    procedure OpenSalesDocument(JobPlanningLineInvoice: Record "Job Planning Line Invoice")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        POSQuoteEntry: Record "POS Quote Entry";
    begin
        //-NPR5.49 [331208]
        with JobPlanningLineInvoice do
            case "Document Type" of
                "Document Type"::Invoice:
                    if JobPlanningLineInvoice."POS Unit No." = '' then begin
                        SalesHeader.Get(SalesHeader."Document Type"::Invoice, "Document No.");
                        PAGE.RunModal(PAGE::"Sales Invoice", SalesHeader);
                    end else begin
                        //sales ticket remains as Document Type = Invoice until posted from Audit Roll/POS Entry
                        if ShowProcessedPOSDocument(JobPlanningLineInvoice, false) then
                            exit;
                        POSQuoteEntry.SetRange("Register No.", JobPlanningLineInvoice."POS Unit No.");
                        POSQuoteEntry.SetRange("Sales Ticket No.", JobPlanningLineInvoice."Document No.");
                        if not POSQuoteEntry.IsEmpty then
                            PAGE.RunModal(0, POSQuoteEntry)
                        else
                            Error(POSDocProcessingErr);
                    end;
                "Document Type"::"Credit Memo":
                    begin
                        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", "Document No.");
                        PAGE.RunModal(PAGE::"Sales Credit Memo", SalesHeader);
                    end;
                "Document Type"::"Posted Invoice":
                    if JobPlanningLineInvoice."POS Unit No." = '' then begin
                        if not SalesInvHeader.Get("Document No.") then
                            Error(SalesDocErr, SalesInvHeader.TableCaption, "Document No.");
                        PAGE.RunModal(PAGE::"Posted Sales Invoice", SalesInvHeader);
                    end else begin
                        if not ShowProcessedPOSDocument(JobPlanningLineInvoice, true) then
                            Error(POSDocErr, JobPlanningLineInvoice."POS Unit No.", JobPlanningLineInvoice."Document No.");
                    end;
                "Document Type"::"Posted Credit Memo":
                    begin
                        if not SalesCrMemoHeader.Get("Document No.") then
                            Error(SalesDocErr, SalesCrMemoHeader.TableCaption, "Document No.");
                        PAGE.RunModal(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                    end;
            end;
        //+NPR5.49 [331208]
    end;

    procedure GetJobPlanningLineInvoices(JobPlanningLine: Record "Job Planning Line")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        //-NPR5.49 [331208]
        ClearAll;
        with JobPlanningLine do begin
            if "Line No." = 0 then
                exit;
            TestField("Job No.");
            TestField("Job Task No.");

            JobPlanningLineInvoice.SetRange("Job No.", "Job No.");
            JobPlanningLineInvoice.SetRange("Job Task No.", "Job Task No.");
            JobPlanningLineInvoice.SetRange("Job Planning Line No.", "Line No.");
            if JobPlanningLineInvoice.Count = 1 then begin
                JobPlanningLineInvoice.FindFirst;
                OpenSalesDocument(JobPlanningLineInvoice);
            end else
                PAGE.RunModal(PAGE::"Event Invoices", JobPlanningLineInvoice);
        end;
        //+NPR5.49 [331208]
    end;

    procedure FindInvoices(var TempJobPlanningLineInvoice: Record "Job Planning Line Invoice" temporary; JobNo: Code[20]; JobTaskNo: Code[20]; JobPlanningLineNo: Integer; DetailLevel: Option All,"Per Job","Per Job Task","Per Job Planning Line")
    var
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
        RecordFound: Boolean;
    begin
        //-NPR5.49 [331208]
        case DetailLevel of
            DetailLevel::All:
                begin
                    if JobPlanningLineInvoice.FindSet then
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

        TempJobPlanningLineInvoice.DeleteAll;
        if JobPlanningLineInvoice.FindSet then begin
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
                    TempJobPlanningLineInvoice.Modify;
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
                    TempJobPlanningLineInvoice."POS Unit No." := JobPlanningLineInvoice."POS Unit No.";
                    TempJobPlanningLineInvoice."POS Store Code" := JobPlanningLineInvoice."POS Store Code";
                    TempJobPlanningLineInvoice.Insert;
                end;
            until JobPlanningLineInvoice.Next = 0;
        end;
        //+NPR5.49 [331208]
    end;

    local procedure ShowProcessedPOSDocument(JobPlanningLineInvoice: Record "Job Planning Line Invoice"; Posted: Boolean) HasEntries: Boolean
    var
        POSEntry: Record "POS Entry";
        AuditRoll: Record "Audit Roll";
        NPRetailSetup: Record "NP Retail Setup";
        AdvancedPostingActive: Boolean;
    begin
        //-NPR5.49 [331208]
        AdvancedPostingActive := NPRetailSetup.Get and NPRetailSetup."Advanced Posting Activated";
        if AdvancedPostingActive then begin
            POSEntry.SetRange("POS Unit No.", JobPlanningLineInvoice."POS Unit No.");
            POSEntry.SetRange("POS Store Code", JobPlanningLineInvoice."POS Store Code");
            POSEntry.SetRange("Document No.", JobPlanningLineInvoice."Document No.");
            HasEntries := not POSEntry.IsEmpty;
            if HasEntries then
                PAGE.RunModal(0, POSEntry);
        end else begin
            AuditRoll.SetRange("Register No.", JobPlanningLineInvoice."POS Unit No.");
            if Posted then
                AuditRoll.SetRange("Posted Doc. No.", JobPlanningLineInvoice."Document No.")
            else
                AuditRoll.SetRange("Sales Ticket No.", JobPlanningLineInvoice."Document No.");
            HasEntries := not AuditRoll.IsEmpty;
            if HasEntries then
                PAGE.RunModal(0, AuditRoll);
        end;
        exit(HasEntries);
        //+NPR5.49 [331208]
    end;

    procedure GetBlockEventDeleteOptionFilter() OptionFilter: Text
    var
        InS: InStream;
    begin
        //-NPR5.53 [346821]
        JobsSetup.Get();
        if JobsSetup."Block Event Deletion".HasValue then begin
            JobsSetup.CalcFields("Block Event Deletion");
            JobsSetup."Block Event Deletion".CreateInStream(InS);
            InS.Read(OptionFilter);
        end;
        exit(OptionFilter);
        //+NPR5.53 [346821]
    end;

    local procedure GetJobEventStatusOptions() OptionCaption: Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Job: Record Job;
    begin
        //-NPR5.53 [346821]
        RecRef.Open(DATABASE::Job);
        FldRef := RecRef.Field(Job.FieldNo("Event Status"));
        OptionCaption := FldRef.OptionCaption;
        RecRef.Close;
        OptionCaption := RemoveEmptyOptionsFromEventStatusOption(OptionCaption);
        exit(OptionCaption);
        //+NPR5.53 [346821]
    end;

    local procedure RemoveEmptyOptionsFromEventStatusOption(OptionString: Text) CleanedOptionString: Text
    var
        i: Integer;
        TypeHelper: Codeunit "Type Helper";
        OptionValue: Text;
    begin
        //-NPR5.53 [346821]
        for i := 0 to TypeHelper.GetNumberOfOptions(OptionString) do begin
            OptionValue := SelectStr(i + 1, OptionString);
            if OptionValue <> '' then begin
                if CleanedOptionString <> '' then
                    CleanedOptionString += ',';
                CleanedOptionString += OptionValue;
            end;
        end;
        exit(CleanedOptionString);
        //+NPR5.53 [346821]
    end;

    local procedure BlockDeleteIfInStatus(Job: Record Job)
    var
        OptionFilter: Text;
    begin
        //-NPR5.53 [346821]
        Job.SetRecFilter;
        //-NPR5.53 [385993]
        //Job.SETFILTER("Event Status",GetBlockEventDeleteOptionFilter());
        OptionFilter := GetBlockEventDeleteOptionFilter();
        if OptionFilter = '' then
            exit;
        Job.SetFilter("Event Status", OptionFilter);
        //+NPR5.53 [385993]
        if not Job.IsEmpty then
            Error(BlockDeleteErr, Job."No.", Format(Job."Event Status"), JobsSetup.TableCaption);
        //+NPR5.53 [346821]
    end;

    procedure SetBufferMode()
    begin
        //-NPR5.55 [397741]
        BufferMode := true;
        //+NPR5.55 [397741]
    end;
}

