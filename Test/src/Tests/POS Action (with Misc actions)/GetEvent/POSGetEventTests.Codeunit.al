codeunit 85087 "NPR POS Get Event Tests"
{
    // [FEATURE] [POS Action: Get Event]
    Subtype = Test;

    var
        POSInitialized, JobsSetupInitialized : Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        JobsSetup: Record "Jobs Setup";
        ParamDialogTypeOption: Option TextField,List;
        ParamGetEventLinesOption: Option Invoiceable,Selection,None;
        ParamAddNewLinesToTaskOption: Option Default,First,Selection;
        LookAheadPeriodDays, RecordCount : Integer;
        Assert: Codeunit Assert;
        ExpectedErrFrom: Label 'Expected error message from: %1', Comment = '%1 = code snippet where error should come from';
        EventTaskNotSelectedErr: Label 'You must select a task to continue.';
        NothingToInvoiceErr: Label 'There''s nothing to invoice on that event.';
        EventPlanningLineNotSelectedErr: Label 'You must select event planning line(s) to continue.';
        NoVariantCodeSelectedErr: Label 'No %1 selected for item %2.';
        ItemRequiresVariantErr: Label 'Variant is required for item %1.';
        SelectEventReturnsBlankMsg: Label 'Method SelectEvent needs to return blank value.';
        SelectEventCountMsg: Label 'Method SelectEvent expects different no. of records to appear in the list.';
        ValuesAreDifferentMsg: Label '%1 is not the same.';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CancelEventListModalPageHandler')]
    procedure SelectEvent_EventIsNotSelectedFromTheList()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        ExpectedEventNo, ActualEventNo : Code[20];
    begin
        // [SCENARIO] No event is selected from the event list (list is closed) and blank event is returned 
        // [GIVEN] A few events in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Expecting no event to be selected
        ExpectedEventNo := '';
        Commit();
        // [WHEN] No event is selected
        ActualEventNo := POSActionGetEventB.SelectEvent(0);
        // [THEN] Received event no. is blank        
        Assert.AreEqual(ExpectedEventNo, ActualEventNo, SelectEventReturnsBlankMsg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GetEventListRecordCountModalPageHandler')]
    procedure SelectEvent_EventListIsShowingOnlyEvents()
    var
        LibraryJob: Codeunit "Library - Job";
        LibraryEvent: Codeunit "NPR Library - Event";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ExpectedEventCount, ActualEventCount : Integer;
    begin
        // [SCENARIO] Jobs that are not events should not be shown on the Event List page 
        // [GIVEN] First need to make sure no jobs exist in the system
        InitializeJobsSetup();
        Job.DeleteAll(false);
        // A few jobs
        LibraryJob.CreateJob(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        LibraryJob.CreateJob(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One event
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Expected record count on the page
        ExpectedEventCount := 1;
        Commit();
        // [WHEN] Event is selected
        POSActionGetEventB.SelectEvent(0);
        ActualEventCount := RecordCount;
        // [THEN] Record counts need to match        
        Assert.AreEqual(ExpectedEventCount, ActualEventCount, SelectEventCountMsg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GetEventListRecordCountModalPageHandler')]
    procedure SelectEvent_EventListIsShowingOnlyEventsInStatusOrder()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ExpectedEventCount, ActualEventCount : Integer;
        EventStatus: Enum "NPR Event Status";
    begin
        // [SCENARIO] Only events in Status = Order should be shown on the Event List page 
        // [GIVEN] First need to make sure no jobs exist in the system
        InitializeJobsSetup();
        Job.DeleteAll(false);
        // Few events in wrong status
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Enum::"NPR Event Status".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo("NPR Event Status"), EventStatus::Order.AsInteger()));
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Enum::"NPR Event Status".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo("NPR Event Status"), EventStatus::Order.AsInteger()));
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Enum::"NPR Event Status".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo("NPR Event Status"), EventStatus::Order.AsInteger()));
        Job.Modify(true);
        // Few events in correct status
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Expected record count on the page
        ExpectedEventCount := 2;
        Commit();
        // [WHEN] Event is selected
        POSActionGetEventB.SelectEvent(0);
        ActualEventCount := RecordCount;
        // [THEN] Record counts need to match        
        Assert.AreEqual(ExpectedEventCount, ActualEventCount, SelectEventCountMsg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GetEventListRecordCountModalPageHandler')]
    procedure SelectEvent_EventListIsShowingOnlyNonBlockedEvents()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ExpectedEventCount, ActualEventCount : Integer;
        JobBlocked: Enum "Job Blocked";
    begin
        // [SCENARIO] Only events with Blocked = " " should be shown on the Event List page 
        // [GIVEN] First need to make sure no jobs exist in the system
        InitializeJobsSetup();
        Job.DeleteAll(false);
        // Few events with random blocked options
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Blocked := Enum::"Job Blocked".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo(Blocked), JobBlocked::" ".AsInteger()));
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Blocked := Enum::"Job Blocked".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo(Blocked), JobBlocked::" ".AsInteger()));
        Job.Modify(true);
        // Event with correct blocked option
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Blocked := Job.Blocked::" ";
        Job.Modify(true);
        // Expected record count on the page
        ExpectedEventCount := 1;
        Commit();
        // [WHEN] Event is selected
        POSActionGetEventB.SelectEvent(0);
        ActualEventCount := RecordCount;
        // [THEN] Record counts need to match        
        Assert.AreEqual(ExpectedEventCount, ActualEventCount, SelectEventCountMsg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GetEventListRecordCountModalPageHandler')]
    procedure SelectEvent_EventListIsShowingOnlyEventsInSetPeriod()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        LibraryUtility: Codeunit "Library - Utility";
        Job: Record Job;
        ExpectedEventCount, ActualEventCount, LookAheadPeriodDays : Integer;
    begin
        // [SCENARIO] Only events that have Starting Date in given period should be shown on the Event List page 
        // First need to make sure no jobs exist in the system
        InitializeJobsSetup();
        Job.DeleteAll(false);
        // Lookahead period days will also be used to create random dates in the past
        LookAheadPeriodDays := 5;
        // Few events in past
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."Starting Date" := LibraryUtility.GenerateRandomDate(CalcDate('<-' + FORMAT(LookAheadPeriodDays) + 'D>', WorkDate()), CalcDate('<-1D>', WorkDate()));
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."Starting Date" := LibraryUtility.GenerateRandomDate(CalcDate('<-' + FORMAT(LookAheadPeriodDays) + 'D>', WorkDate()), CalcDate('<-1D>', WorkDate()));
        Job.Modify(true);
        // Few events in correct date range (two border dates and one in between)
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."Starting Date" := WorkDate();
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."Starting Date" := LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<' + FORMAT(LookAheadPeriodDays) + 'D>', WorkDate()));
        Job.Modify(true);
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."Starting Date" := CalcDate('<' + FORMAT(LookAheadPeriodDays) + 'D>', WorkDate());
        Job.Modify(true);
        // Expected record count on the page
        ExpectedEventCount := 3;
        Commit();
        // [WHEN] Event is selected
        POSActionGetEventB.SelectEvent(LookAheadPeriodDays);
        ActualEventCount := RecordCount;
        // [THEN] Record counts need to match        
        Assert.AreEqual(ExpectedEventCount, ActualEventCount, SelectEventCountMsg);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_JobDoesntExist()
    var
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobNo: Code[20];
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import a job that doesnt exist
        // [GIVEN] A non existant job
        // Expected error message
        JobNo := LibraryUtility.GenerateRandomCode20(Job.FieldNo("No."), Database::Job);
        asserterror Job.Get(JobNo);
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, JobNo, ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Job.Get()'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_JobIsNotEvent()
    var
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import a job that is not an event
        // [GIVEN] A regular job        
        InitializeJobsSetup();
        LibraryJob.CreateJob(Job);
        Commit();
        // Expected error message
        asserterror Job.TestField("NPR Event");
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error messages and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Job.TestField("NPR Event")'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsNotInOrderStatus()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        EventStatusEnum: Enum "NPR Event Status";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event that is not in Order status
        // [GIVEN] An event in random status (not Order)   
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job);
        Job.Validate("NPR Event Status", Enum::"NPR Event Status".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo("NPR Event Status"), EventStatusEnum::Order.AsInteger())));
        Job.Modify(true);
        Commit();
        // Expected error message
        asserterror Job.TestField("NPR Event Status", Job."NPR Event Status"::Order);
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Job.TestField("NPR Event Status", Job."NPR Event Status"::Order)'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsBlocked()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobBlockedEnum: Enum "Job Blocked";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event that is blocked
        // [GIVEN] A blocked event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Validate(Blocked, Enum::"Job Blocked".FromInteger(LibraryEvent.GetRandomOption(Database::Job, Job.FieldNo(Blocked), JobBlockedEnum::" ".AsInteger())));
        Job.Modify(true);
        Commit();
        // Expected error message
        asserterror Job.TestBlocked();
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Job.TestBlocked()'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventDoesntHaveACustomer()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event without a customer
        // [GIVEN] An event in Order status without a customer   
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."NPR Event Customer No." := '';
        Job.Modify(true);
        Commit();
        // Expected error message
        asserterror Job.TestField("NPR Event Customer No.");
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Job.TestField("NPR Event Customer No.")'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasABlockedCustomer()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        Customer: Record Customer;
        CustomerBlockedEnum: Enum "Customer Blocked";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with a blocked customer
        // [GIVEN] An event in Order status with a blocked customer
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        Customer.Get(Job."NPR Event Customer No.");
        Customer.Validate(Blocked, Enum::"Customer Blocked".FromInteger(LibraryEvent.GetRandomOption(Database::Customer, Customer.FieldNo(Blocked), CustomerBlockedEnum::" ".AsInteger())));
        Customer.Modify(true);
        Commit();
        // Expected error message
        asserterror Customer.TestField(Blocked, Customer.Blocked::" ");
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'Customer.TestField(Blocked, Customer.Blocked::" ")'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_JobsSetupDoesntHaveADefaultTask()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with ParamAddNewLinesToTaskOption = Default without default task on Jobs Setup
        // [GIVEN] Jobs Setup without default task
        InitializeJobsSetup();
        JobsSetup.Validate("NPR Def. Job Task No.", '');
        JobsSetup.Modify(true);
        // An event in Order status
        LibraryEvent.CreateEvent(Job);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        Commit();
        // Expected error message
        asserterror JobsSetup.TestField("NPR Def. Job Task No.");
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'JobsSetup.TestField("NPR Def. Job Task No.")'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventDoesntHaveADefaultTask()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with ParamAddNewLinesToTaskOption = Default without default Job Task
        // [GIVEN] An event in Order status
        JobsSetupInitialized := false;
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // No default Job Task
        JobTask.Delete(true);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // Expected error message
        asserterror JobTask.Get(Job."No.", JobsSetup."NPR Def. Job Task No.");
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'JobTask.Get(Job."No.",JobsSetup."NPR Def. Job Task No.")'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventDoesntHaveAnyTask()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with ParamAddNewLinesToTaskOption = First without any Job Task
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // No Job Task
        JobTask.Delete(true);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        // Expected error message
        JobTask.SetRange("Job No.", Job."No.");
        asserterror JobTask.FindFirst();
        ExpectedMessage := GetLastErrorText();
        ClearLastError();
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'JobTask.FindFirst()'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CancelEventTaskLinesModalPageHandler')]
    procedure ImportEvent_NoJobTaskIsSelected()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with ParamAddNewLinesToTaskOption = Selection without any Job Task selected
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Two more Job Tasks are available
        LibraryJob.CreateJobTask(Job, JobTask);
        LibraryJob.CreateJobTask(Job, JobTask);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Selection;
        // Expected error message
        ExpectedMessage := EventTaskNotSelectedErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'EventTaskNotSelectedErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasNoInvoiceableLinesOnDefaultTask()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines on default task
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Job Planning Line for latter Job Task
#if BC17
        LibraryJob.CreateJobPlanningLine(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo("Line Type")),
                                        Enum::"Job Planning Line Type".FromInteger(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo(Type))),
                                        JobTask, JobPlanningLine);
#else
        LibraryJob.CreateJobPlanningLine(Enum::"Job Planning Line Line Type".FromInteger(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo("Line Type"))),
                                        Enum::"Job Planning Line Type".FromInteger(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo(Type))),
                                        JobTask, JobPlanningLine);
#endif
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasNoInvoiceableLinesWithLineTypeAtLeastBillable()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines of at least Billable line type
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Budget        
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget,
                                        Enum::"Job Planning Line Type".FromInteger(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo(Type))),
                                        JobTask, JobPlanningLine);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasNoInvoiceableLinesWithTypeItem()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines of type Item
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with random Type except Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable,
                                        Enum::"Job Planning Line Type".FromInteger(LibraryEvent.GetRandomOption(Database::"Job Planning Line", JobPlanningLine.FieldNo(Type), JobPlanningLine.Type::Item.AsInteger())),
                                        JobTask, JobPlanningLine);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasNoInvoiceableLinesWithTicketStatusRevokedOrConfirmed()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines with Ticket Status Revoked or Confirmed
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable, Type = Item and Ticket Status = Revoked
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Revoked;
        JobPlanningLine.Modify(true);
        // Job Planning Line with Line Type = Billable, Type = Item and Ticket Status = Confirmed
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Confirmed;
        JobPlanningLine.Modify(true);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CancelEventPlanningLinesModalPageHandler')]
    procedure ImportEvent_NoInvoiceableJobPlanningLinesHaveBeenSelected()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with invoiceable lines but none have been selected
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Selection;
        // Expected error message
        ExpectedMessage := EventPlanningLineNotSelectedErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'EventPlanningLineNotSelectedErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasNoInvoiceableLinesAndNewOnesCantBeAddedOnPOS()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines and new ones can't be added on POS
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Budget and Type = Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::None;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventHasInvoiceableLinesAndNewOnesCantBeAddedOnPOS()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with no invoiceable lines and new ones can't be added on POS
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::None;
        // Expected error message
        ExpectedMessage := NothingToInvoiceErr;
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NothingToInvoiceErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('CancelVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventHasInvoiceableLinesWithNoVariantsAndSelectionIsNotConfirmed()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ItemVariant: Record "Item Variant";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with invoiceable lines without Variant Code (on items that require variants) and confirmation for adding 
        //            variants is not accepted
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Item has variants
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := StrSubstNo(NoVariantCodeSelectedErr, JobPlanningLine.FieldCaption("Variant Code"), JobPlanningLine."No.");
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'NoVariantCodeSelectedErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AcceptVariantSelectionConfirmHandler,CancelVariantSelectionModalPageHandler')]
    procedure ImportEvent_EventHasInvoiceableLinesWithNoVariantsAndVariantSelectionIsCanceled()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        ItemVariant: Record "Item Variant";
        ActualMessage, ExpectedMessage : Text;
    begin
        // [SCENARIO] Error message if trying to import an event with invoiceable lines without Variant Code (on items that require variants) and variant selection 
        //            is canceled
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Item has variants
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        Commit();
        // Parameter setup
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        // Expected error message
        ExpectedMessage := StrSubstNo(ItemRequiresVariantErr, JobPlanningLine."No.");
        // [WHEN] User tries to import event
        asserterror POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect error message and compare to expected error
        ActualMessage := GetLastErrorText();
        Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ExpectedErrFrom, 'ItemRequiresVariantErr'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsImportedAndPOSSaleDataIsCorrect()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        POSSaleRec: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        // [SCENARIO] Event is imported and POS Sale data is correct
        // An event in correct status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Customer created will be used later in comparison
        Customer.Get(Job."NPR Event Customer No.");
        // Job Planning Line with Line Type = Billable and Type = Item that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Check POS Sale values are correct
        POSSale.GetCurrentSale(POSSaleRec);
        Assert.AreEqual(Customer."No.", POSSaleRec."Customer No.", StrSubstNo(ValuesAreDifferentMsg, POSSaleRec.FieldCaption("Customer No.")));
        Assert.AreEqual(Customer."Prices Including VAT", POSSaleRec."Prices Including VAT", StrSubstNo(ValuesAreDifferentMsg, POSSaleRec.FieldCaption("Prices Including VAT")));
        Assert.AreEqual(Job."No.", POSSaleRec."Event No.", StrSubstNo(ValuesAreDifferentMsg, POSSaleRec.FieldCaption("Event No.")));
        Assert.AreEqual(JobTask."Job Task No.", POSSaleRec."Event Task No.", StrSubstNo(ValuesAreDifferentMsg, POSSaleRec.FieldCaption("Event Task No.")));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsImportedAndPOSSaleLineDataIsCorrect()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLineRec: Record "NPR POS Sale Line";
        Item: Record Item;
    begin
        // [SCENARIO] Event is imported and POS Sale Line data is correct
        // [GIVEN] An event in correct status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Item which will later be used in comparison
        Item.Get(JobPlanningLine."No.");
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Check POS Sale Line values are correct
        POSSale.GetCurrentSale(POSSaleRec);
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRec);
        CheckPOSSaleLineData(JobTask, JobPlanningLine, POSSaleRec, POSSaleLineRec, Item);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsImportedAndJobPlanningLineInvoiceDataIsCorrect()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLineRec: Record "NPR POS Sale Line";
        JobPlanningLineInvoice: Record "Job Planning Line Invoice";
    begin
        // [SCENARIO] Event is imported and Job Planning Line Invoice data is correct
        // [GIVEN] An event in correct status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        // Delete all JobPlanningLineInvoice so we can only have the one created by this test function
        JobPlanningLineInvoice.DeleteAll();
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Check POS Sale Line values are correct
        POSSale.GetCurrentSale(POSSaleRec);
        POSSaleLine.GetCurrentSaleLine(POSSaleLineRec);
        JobPlanningLineInvoice.FindFirst();
        CheckJobPlanningLineInvoiceData(JobPlanningLine, POSSaleRec, POSSaleLineRec, JobPlanningLineInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventIsImportedAndJobPlanningLineDataIsCorrect()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLineRec: Record "NPR POS Sale Line";
        ExpectedValue: Decimal;
    begin
        // [SCENARIO] Event is imported and Job Planning Line data is correct
        // [GIVEN] An event in correct status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // Job Planning Line with Line Type = Billable and Type = Item that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Expected value after import
        JobPlanningLine.CalcFields("Qty. Transferred to Invoice");
        ExpectedValue := JobPlanningLine.Quantity - JobPlanningLine."Qty. Transferred to Invoice";
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Check Job Planning Line values are correct
        JobPlanningLine.FindFirst();
        JobPlanningLine.CalcFields("Qty. Transferred to Invoice");
        Assert.AreEqual(0, JobPlanningLine."Qty. to Transfer to Invoice", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLine.FieldCaption("Qty. to Transfer to Invoice")));
        Assert.AreEqual(ExpectedValue, JobPlanningLine."Qty. Transferred to Invoice", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLine.FieldCaption("Qty. Transferred to Invoice")));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithInvoiceableLinesAndDefaultTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, DefaultJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Invoiceable, ParamAddNewLinesToTaskOption = Default
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task and with invoiceable qty. that will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, DefaultJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in DefaultJobTask that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := JobPlanningLine."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        ExpectedTotalLineAmount += JobPlanningLine."Line Amount";
        ExpectedLineCount := 2;
        // Last item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLine."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        // One line on default task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, DefaultJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithInvoiceableLinesAndFirstTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, FirstJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Invoiceable, ParamAddNewLinesToTaskOption = First
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task and with invoiceable qty. that will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status and a task that will be selected
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, FirstJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in FirstJobTask that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := JobPlanningLine."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        ExpectedTotalLineAmount += JobPlanningLine."Line Amount";
        ExpectedLineCount := 2;
        // Last item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLine."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        // One line on first task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, FirstJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectThirdEventTaskLineModalPageHandler,SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithInvoiceableLinesAndSelectionTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, SelectedJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Invoiceable, ParamAddNewLinesToTaskOption = Selection
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task and with invoiceable qty. that will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status and a random task
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // One more task which will be selected
        LibraryJob.CreateJobTask(Job, SelectedJobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in SelectedJobTask that will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := JobPlanningLine."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        ExpectedTotalLineAmount += JobPlanningLine."Line Amount";
        ExpectedLineCount := 2;
        // Last item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLine."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLine."No.");
        // One line on selected task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Invoiceable;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Selection;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, SelectedJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFirstEventPlanningLinesModalPageHandler,SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithSelectedInvoiceableLinesAndDefaultTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, DefaultJobTask : Record "Job Task";
        JobPlanningLine, JobPlanningLineWithVariant : Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Selection, ParamAddNewLinesToTaskOption = Default
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task with invoiceable qty. and only one will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status and a random task
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, DefaultJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in DefaultJobTask but only one will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLineWithVariant);
        ExpectedTotalLineAmount := JobPlanningLineWithVariant."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        ExpectedLineCount := 1;
        // First item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLineWithVariant."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        // One line on selected task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Selection;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, DefaultJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectFirstEventPlanningLinesModalPageHandler,SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithSelectedInvoiceableLinesAndFirstTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, FirstJobTask : Record "Job Task";
        JobPlanningLine, JobPlanningLineWithVariant : Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Selection, ParamAddNewLinesToTaskOption = First
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task with invoiceable qty. and only one will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status and a random task
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, FirstJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in FirstJobTask but only one will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLineWithVariant);
        ExpectedTotalLineAmount := JobPlanningLineWithVariant."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        ExpectedLineCount := 1;
        // First item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLineWithVariant."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        // One line on selected task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Selection;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, FirstJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectThirdEventTaskLineModalPageHandler,SelectFirstEventPlanningLinesModalPageHandler,SelectFirstVariantModalPageHandler,AcceptVariantSelectionConfirmHandler')]
    procedure ImportEvent_EventWithSelectedInvoiceableLinesAndSelectedTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, SelectedJobTask : Record "Job Task";
        JobPlanningLine, JobPlanningLineWithVariant : Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemVariant: Record "Item Variant";
        ExpectedLineCount, ActualLineCount, LineWithVariantCode : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
        ExpectedVariantCode, ActualVariantCode : Code[10];
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = Selection, ParamAddNewLinesToTaskOption = Selection
        // Has one line on random task that will not be chosen
        // Has one line on correct task but with no invoiceable qty. that will not be chosen
        // Has two lines on correct task with invoiceable qty. and only one will be chosen
        // One of the two lines has a variant
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status and a random task
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // One more task which will be selected
        LibraryJob.CreateJobTask(Job, SelectedJobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in SelectedJobTask but only one will be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLineWithVariant);
        ExpectedTotalLineAmount := JobPlanningLineWithVariant."Line Amount";
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        ExpectedLineCount := 1;
        // First item has variants and first one will end on POS
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        ExpectedVariantCode := ItemVariant.Code;
        LineWithVariantCode := JobPlanningLineWithVariant."Line No.";
        LibraryInventory.CreateItemVariant(ItemVariant, JobPlanningLineWithVariant."No.");
        // One line on selected task that will not be picked since it doesn't have Qty. to Transfer to Invoice
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        // One Job Planning Line on other Job Task that will not be picked up
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::Selection;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Selection;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        ActualVariantCode := GetActualVariantCode(SaleLinePOS, LineWithVariantCode);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, SelectedJobTask, ExpectedLineCount, ActualLineCount, LineWithVariantCode, ExpectedTotalLineAmount, ActualTotalLineAmount, ExpectedVariantCode, ActualVariantCode);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventWithNoneAndDefaultTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, DefaultJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ExpectedLineCount, ActualLineCount : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = None, ParamAddNewLinesToTaskOption = Default
        // Has two lines on correct task and with invoiceable qty. that will NOT be chosen
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status that allows adding lines on POS
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(JobsSetup."NPR Def. Job Task No.", Job, DefaultJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."NPR Allow POS Add. New Lines" := true;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in DefaultJobTask that will NOT be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, DefaultJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := 0;
        ExpectedLineCount := 0;
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::None;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Default;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, DefaultJobTask, ExpectedLineCount, ActualLineCount, 0, ExpectedTotalLineAmount, ActualTotalLineAmount, '', '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportEvent_EventWithNoneAndFirstTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, FirstJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ExpectedLineCount, ActualLineCount : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = None, ParamAddNewLinesToTaskOption = First
        // Has two lines on correct task and with invoiceable qty. that will NOT be chosen
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status that allows adding lines on POS
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, FirstJobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."NPR Allow POS Add. New Lines" := true;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in DefaultJobTask that will NOT be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, FirstJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := 0;
        ExpectedLineCount := 0;
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::None;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::First;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, FirstJobTask, ExpectedLineCount, ActualLineCount, 0, ExpectedTotalLineAmount, ActualTotalLineAmount, '', '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SelectThirdEventTaskLineModalPageHandler')]
    procedure ImportEvent_EventWithNoneAndSelectedTaskIsImported()
    var
        LibraryEvent: Codeunit "NPR Library - Event";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
        Job: Record Job;
        JobTask, SelectedJobTask : Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ExpectedLineCount, ActualLineCount : Integer;
        ExpectedTotalLineAmount, ActualTotalLineAmount : Decimal;
    begin
        // [SCENARIO] Event is imported into POS with ParamGetEventLinesOption = None, ParamAddNewLinesToTaskOption = Selected
        // Has two lines on correct task and with invoiceable qty. that will NOT be chosen
        // We're testing no. of lines, total amount, job task no. and variant code
        // [GIVEN] An event in Order status that allows adding lines on POS
        InitializeJobsSetup();
        LibraryEvent.CreateEvent(Job, JobTask);
        Job."NPR Event Status" := Job."NPR Event Status"::Order;
        Job."NPR Allow POS Add. New Lines" := true;
        Job.Modify(true);
        // One more Job Task
        LibraryJob.CreateJobTask(Job, JobTask);
        // One more Job Task that will be selected
        LibraryJob.CreateJobTask(Job, SelectedJobTask);
        // Two Job Planning Line with Line Type = Billable and Type = Item in DefaultJobTask that will NOT be moved to POS
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Billable, JobPlanningLine.Type::Item, SelectedJobTask, JobPlanningLine);
        ExpectedTotalLineAmount := 0;
        ExpectedLineCount := 0;
        // Initialized POS
        POSInitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        Commit();
        // Parameter setup
        ParamGetEventLinesOption := ParamGetEventLinesOption::None;
        ParamAddNewLinesToTaskOption := ParamAddNewLinesToTaskOption::Selection;
        // [WHEN] Event is imported
        POSActionGetEventB.ImportEvent(POSSale, POSSaleLine, Job."No.", ParamGetEventLinesOption, ParamAddNewLinesToTaskOption);
        // [THEN] Collect and compare values
        GetSaleLinePOSData(POSSale, POSSaleLine, SalePOS, SaleLinePOS, ActualLineCount, ActualTotalLineAmount);
        CheckCommonEventData(JobPlanningLine, SalePOS, SaleLinePOS, SelectedJobTask, ExpectedLineCount, ActualLineCount, 0, ExpectedTotalLineAmount, ActualTotalLineAmount, '', '');
    end;

    procedure POSInitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if POSInitialized then begin
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not POSInitialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSInitialized := true;
        end;

        Commit();
    end;

    procedure InitializeJobsSetup()
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if JobsSetupInitialized then
            exit;
        if not JobsSetup.Get() then
            JobsSetup.Insert(true);
        JobsSetup.Validate("Job Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        JobsSetup.Validate("NPR Auto. Create Job Task Line", true);
        JobsSetup.Validate("NPR Def. Job Task No.", 'DEFAULT');
        JobsSetup.Modify(true);
        JobsSetupInitialized := true;
        Commit();
    end;

    local procedure GetSaleLinePOSData(var POSSale: Codeunit "NPR POS Sale"; var POSSaleLine: Codeunit "NPR POS Sale Line"; var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; var ActualLineCount: Integer; var ActualTotalLineAmount: Decimal)
    begin
        POSSale.RefreshCurrent();
        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.SetRange("Line No.");
        if SaleLinePOS.FindSet() then
            repeat
                ActualLineCount += 1;
                ActualTotalLineAmount += SaleLinePOS."Line Amount";
            until SaleLinePOS.Next() = 0;
    end;

    local procedure GetActualVariantCode(var SaleLinePOS: Record "NPR POS Sale Line"; LineWithVariantCode: Integer): Code[10]
    begin
        SaleLinePOS.SetRange("Line No.", LineWithVariantCode);
        SaleLinePOS.FindFirst();
        exit(SaleLinePOS."Variant Code");
    end;

    local procedure CheckPOSSaleLineData(JobTask: Record "Job Task"; JobPlanningLine: Record "Job Planning Line"; POSSaleRec: Record "NPR POS Sale"; POSSaleLineRec: Record "NPR POS Sale Line"; Item: Record Item)
    begin
        Assert.AreEqual(POSSaleLineRec."Sale Type"::Sale, POSSaleLineRec."Sale Type", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Sale Type")));
        Assert.AreEqual(JobPlanningLine."No.", POSSaleLineRec."No.", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("No.")));
        Assert.AreEqual(JobPlanningLine."Variant Code", POSSaleLineRec."Variant Code", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Variant Code")));
        Assert.AreEqual(JobPlanningLine.Description, POSSaleLineRec.Description, StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption(Description)));
        Assert.AreEqual(JobPlanningLine."Description 2", POSSaleLineRec."Description 2", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Description 2")));
        Assert.AreEqual(JobPlanningLine."Variant Code", POSSaleLineRec."Variant Code", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Variant Code")));
        Assert.AreEqual(JobPlanningLine."Unit of Measure Code", POSSaleLineRec."Unit of Measure Code", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Unit of Measure Code")));
        Assert.AreEqual(JobPlanningLine."Qty. to Transfer to Invoice", POSSaleLineRec.Quantity, StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption(Quantity)));
        Assert.AreEqual(JobPlanningLine."Unit Price", POSSaleLineRec."Unit Price", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Unit Price")));
        Assert.AreEqual(POSSaleRec."Shortcut Dimension 1 Code", POSSaleLineRec."Shortcut Dimension 1 Code", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Shortcut Dimension 1 Code")));
        Assert.AreEqual(POSSaleRec."Shortcut Dimension 2 Code", POSSaleLineRec."Shortcut Dimension 2 Code", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Shortcut Dimension 2 Code")));
        Assert.AreEqual(JobPlanningLine."Line Discount %", POSSaleLineRec."Discount %", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Discount %")));
        Assert.AreEqual(JobPlanningLine."Line Discount Amount", POSSaleLineRec."Discount Amount", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Discount Amount")));
        Assert.AreEqual(false, POSSaleLineRec."Price Includes VAT", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("Price Includes VAT")));
        Assert.AreEqual(POSSaleRec."VAT Bus. Posting Group", POSSaleLineRec."VAT Bus. Posting Group", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("VAT Bus. Posting Group")));
        Assert.AreEqual(Item."VAT Prod. Posting Group", POSSaleLineRec."VAT Prod. Posting Group", StrSubstNo(ValuesAreDifferentMsg, POSSaleLineRec.FieldCaption("VAT Prod. Posting Group")));
    end;

    local procedure CheckJobPlanningLineInvoiceData(JobPlanningLine: Record "Job Planning Line"; POSSaleRec: Record "NPR POS Sale"; POSSaleLineRec: Record "NPR POS Sale Line"; JobPlanningLineInvoice: Record "Job Planning Line Invoice")
    begin
        Assert.AreEqual(POSSaleLineRec."Register No.", JobPlanningLineInvoice."NPR POS Unit No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("NPR POS Unit No.")));
        Assert.AreEqual(POSSaleRec."POS Store Code", JobPlanningLineInvoice."NPR POS Store Code", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("NPR POS Store Code")));
        Assert.AreEqual(JobPlanningLineInvoice."Document Type"::Invoice, JobPlanningLineInvoice."Document Type", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Document Type")));
        Assert.AreEqual(POSSaleLineRec."Sales Ticket No.", JobPlanningLineInvoice."Document No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Document No.")));
        Assert.AreEqual(POSSaleLineRec."Line No.", JobPlanningLineInvoice."Line No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Line No.")));
        Assert.AreEqual(JobPlanningLine."Job No.", JobPlanningLineInvoice."Job No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Job No.")));
        Assert.AreEqual(JobPlanningLine."Job Task No.", JobPlanningLineInvoice."Job Task No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Job Task No.")));
        Assert.AreEqual(JobPlanningLine."Line No.", JobPlanningLineInvoice."Job Planning Line No.", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Job Planning Line No.")));
        Assert.AreEqual(JobPlanningLine."Qty. to Transfer to Invoice", JobPlanningLineInvoice."Quantity Transferred", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Quantity Transferred")));
        Assert.AreEqual(POSSaleLineRec.Date, JobPlanningLineInvoice."Transferred Date", StrSubstNo(ValuesAreDifferentMsg, JobPlanningLineInvoice.FieldCaption("Transferred Date")));
    end;

    local procedure CheckCommonEventData(JobPlanningLine: Record "Job Planning Line"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; JobTask: Record "Job Task"; ExpectedLineCount: Integer; ActualLineCount: Integer; LineWithVariantCode: Integer; ExpectedTotalLineAmount: Decimal; ActualTotalLineAmount: Decimal; ExpectedVariantCode: Code[10]; ActualVariantCode: Code[10])
    begin
        Assert.AreEqual(JobTask."Job Task No.", SalePOS."Event Task No.", StrSubstNo(ValuesAreDifferentMsg, SalePOS.FieldCaption("Event Task No.")));
        Assert.AreEqual(ExpectedLineCount, ActualLineCount, StrSubstNo(ValuesAreDifferentMsg, 'No. of lines'));
        Assert.AreEqual(ExpectedTotalLineAmount, ActualTotalLineAmount, StrSubstNo(ValuesAreDifferentMsg, JobPlanningLine.FieldCaption("Line Amount")));
        if LineWithVariantCode <> 0 then
            Assert.AreEqual(ExpectedVariantCode, ActualVariantCode, StrSubstNo(ValuesAreDifferentMsg, SaleLinePOS.FieldCaption("Variant Code") + ' on ' + SaleLinePOS.FieldCaption("Line No.") + ' ' + Format(LineWithVariantCode)));
    end;

    [ModalPageHandler]
    procedure CancelEventListModalPageHandler(var EventList: TestPage "NPR Event List")
    begin
        EventList.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure GetEventListRecordCountModalPageHandler(var EventList: TestPage "NPR Event List")
    begin
        RecordCount := 0;
        EventList.First();
        repeat
            RecordCount += 1;
        until not EventList.Next();
        EventList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CancelEventTaskLinesModalPageHandler(var EventTaskLines: TestPage "NPR Event Task Lines")
    begin
        EventTaskLines.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectThirdEventTaskLineModalPageHandler(var EventTaskLines: TestPage "NPR Event Task Lines")
    begin
        EventTaskLines.First();
        EventTaskLines.Next();
        EventTaskLines.Next();
        EventTaskLines.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CancelEventPlanningLinesModalPageHandler(var EventPlanningLines: TestPage "NPR Event Planning Lines")
    begin
        EventPlanningLines.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectSecondEventPlanningLinesModalPageHandler(var EventPlanningLines: TestPage "NPR Event Planning Lines")
    begin
        EventPlanningLines.First();
        EventPlanningLines.Next();
        EventPlanningLines.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectFirstEventPlanningLinesModalPageHandler(var EventPlanningLines: TestPage "NPR Event Planning Lines")
    begin
        EventPlanningLines.First();
        EventPlanningLines.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure CancelVariantSelectionConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    procedure AcceptVariantSelectionConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CancelVariantSelectionModalPageHandler(var ItemVariantsLookup: TestPage "NPR Item Variants Lookup")
    begin
        ItemVariantsLookup.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectFirstVariantModalPageHandler(var ItemVariantsLookup: TestPage "NPR Item Variants Lookup")
    begin
        ItemVariantsLookup.First();
        ItemVariantsLookup.OK().Invoke();
    end;
}