page 6151577 "NPR Event Copy"
{
    Extensible = False;
    Caption = 'Copy Job';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group("Copy from")
            {
                Caption = 'Copy from';
                field(SourceJobNo; SourceJobNo)
                {

                    Caption = 'Job No.';
                    TableRelation = Job;
                    ToolTip = 'Specifies the event number.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if (SourceJobNo <> '') and not SourceJob.Get(SourceJobNo) then
                            Error(Text003, SourceJob.TableCaption, SourceJobNo);
                        TargetJobDescription := SourceJob.Description;
                        TargetBillToCustomerNo := SourceJob."Bill-to Customer No.";

                        FromJobTaskNo := '';
                        ToJobTaskNo := '';
                    end;
                }
                field(FromJobTaskNo; FromJobTaskNo)
                {

                    Caption = 'Job Task No. from';
                    Visible = false;
                    ToolTip = 'Specifies the first event task number to be copied from. Only planning lines with an event task number equal to or higher than the number specified in this field will be included.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        JobTask: Record "Job Task";
                    begin
                        if SourceJob."No." <> '' then begin
                            JobTask.SetRange("Job No.", SourceJob."No.");
                            if PAGE.RunModal(PAGE::"Job Task List", JobTask) = ACTION::LookupOK then
                                FromJobTaskNo := JobTask."Job Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        JobTask: Record "Job Task";
                    begin
                        if (FromJobTaskNo <> '') and not JobTask.Get(SourceJob."No.", FromJobTaskNo) then
                            Error(Text003, JobTask.TableCaption, FromJobTaskNo);
                    end;
                }
                field(ToJobTaskNo; ToJobTaskNo)
                {

                    Caption = 'Job Task No. to';
                    Visible = false;
                    ToolTip = 'Specifies the last event task number to be copied from. Only planning lines with an event task number equal to or lower than the number specified in this field will be included.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        JobTask: Record "Job Task";
                    begin
                        if SourceJobNo <> '' then begin
                            JobTask.SetRange("Job No.", SourceJobNo);
                            if PAGE.RunModal(PAGE::"Job Task List", JobTask) = ACTION::LookupOK then
                                ToJobTaskNo := JobTask."Job Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        JobTask: Record "Job Task";
                    begin
                        if (ToJobTaskNo <> '') and not JobTask.Get(SourceJobNo, ToJobTaskNo) then
                            Error(Text003, JobTask.TableCaption, ToJobTaskNo);
                    end;
                }
                field("From Source"; Source)
                {

                    Caption = 'Source';
                    OptionCaption = 'Job Planning Lines,Job Ledger Entries,None';
                    Visible = false;
                    ToolTip = 'Specifies the basis on which you want the planning lines to be copied. If, for example, you want the planning lines to reflect actual usage and invoicing of items, resources, and general ledger expenses on the event you copy from, then select Job Ledger Entries in this field.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ValidateSource();
                    end;
                }
                field("Planning Line Type"; PlanningLineType)
                {

                    Caption = 'Incl. Planning Line Type';
                    Enabled = PlanningLineTypeEnable;
                    OptionCaption = 'Schedule+Contract,Schedule,Contract';
                    Visible = false;
                    ToolTip = 'Specifies how copy planning lines. Budget+Billable: All planning lines are copied. Budget: Only lines of type Budget or type Both Budget and Billable are copied. Billable: Only lines of type Billable or type Both Budget and Billable are copied.';
                    ApplicationArea = NPRRetail;
                }
                field("Ledger Entry Line Type"; LedgerEntryType)
                {

                    Caption = 'Incl. Ledger Entry Line Type';
                    Enabled = LedgerEntryLineTypeEnable;
                    OptionCaption = 'Usage+Sale,Usage,Sale';
                    Visible = false;
                    ToolTip = 'Specifies how to copy job ledger entries. Usage+Sale: All job ledger entries are copied. Entries of type Usage are copied to new planning lines of type Budget. Entries of type Sale are copied to new planning lines of type Billable. Usage: All job ledger entries of type Usage are copied to new planning lines of type Budget. Sale: All job ledger entries of type Sale are copied to new planning lines of type Billable.';
                    ApplicationArea = NPRRetail;
                }
                field(FromDate; FromDate)
                {

                    Caption = 'Starting Date';
                    Visible = false;
                    ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    ApplicationArea = NPRRetail;
                }
                field(ToDate; ToDate)
                {

                    Caption = 'Ending Date';
                    Visible = false;
                    ToolTip = 'Specifies the date to which the report or batch job processes information.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Copy to")
            {
                Caption = 'Copy to';
                field(TargetJobNo; TargetJobNo)
                {

                    Caption = 'Job No.';
                    Editable = not Recurring;
                    ToolTip = 'Specifies the event number.';
                    ApplicationArea = NPRRetail;
                }
                field(TargetJobDescription; TargetJobDescription)
                {

                    Caption = 'Job Description';
                    ToolTip = 'Specifies a description of the event.';
                    ApplicationArea = NPRRetail;
                }
                field(TargetBillToCustomerNo; TargetBillToCustomerNo)
                {

                    Caption = 'Bill-To Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the number of an alternate customer that the event is billed to instead of the main customer.';
                    ApplicationArea = NPRRetail;
                }
                field(NewStartingDate; NewStartingDate)
                {

                    Caption = 'Starting Date';
                    ToolTip = 'Specifies a date from which the event will start.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckDate();
                    end;
                }
                field(NewEndingDate; NewEndingDate)
                {

                    Caption = 'Ending Date';
                    ToolTip = 'Specifies a date at which the event will end.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckDate();
                    end;
                }
                field(Recurring; Recurring)
                {

                    Caption = 'Recurring';
                    ToolTip = 'Specifies if you want to create a recurring event defined by parameters in Recurring Formula and Recurring Until.';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        TargetJobNo := '';
                    end;
                }
                field(RecurrFormula; RecurrFormula)
                {

                    Caption = 'Recurring Formula';
                    ToolTip = 'Specifies a formula by which event will occur. For example, every seven days (7D), or every month (1M) and so on.';
                    ApplicationArea = NPRRetail;
                }
                field(RecurrUntil; RecurrUntil)
                {

                    Caption = 'Recurring Until';
                    ToolTip = 'Specifies the last date until the event is supposed to recurr.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Apply)
            {
                Caption = 'Apply';
                field(CopyJobPrices; CopyJobPrices)
                {

                    Caption = 'Copy Job Prices';
                    ToolTip = 'Specifies that item prices, resource prices, and G/L prices will be copied from the event that you specified on the Copy From FastTab.';
                    ApplicationArea = NPRRetail;
                }
                field(CopyQuantity; CopyQuantity)
                {

                    Caption = 'Copy Quantity';
                    ToolTip = 'Specifies that the quantities will be copied to the new event.';
                    ApplicationArea = NPRRetail;
                }
                field(CopyDimensions; CopyDimensions)
                {

                    Caption = 'Copy Dimensions';
                    ToolTip = 'Specifies that the dimensions will be copied to the new event.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        PlanningLineType := PlanningLineType::"Schedule+Contract";
        LedgerEntryType := LedgerEntryType::"Usage+Sale";
        ValidateSource();
        CopyDimensions := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then
            CopyEvent();
    end;

    var
        SourceJob: Record Job;
        CopyJob: Codeunit "Copy Job";
        SourceJobNo: Code[20];
        FromJobTaskNo: Code[20];
        ToJobTaskNo: Code[20];
        TargetJobNo: Code[20];
        TargetJobDescription: Text[100];
        TargetBillToCustomerNo: Code[20];
        FromDate: Date;
        ToDate: Date;
        Source: Option "Job Planning Lines","Job Ledger Entries","None";
        PlanningLineType: Option "Schedule+Contract",Schedule,Contract;
        LedgerEntryType: Option "Usage+Sale",Usage,Sale;
        Text001: Label 'The job was successfully copied. Do you want to open it now?';
        Text002: Label 'Job No. %1 will be assigned to the new Job. Do you want to continue?';
        Text003: Label '%1 %2 does not exist.', Comment = 'Job Task 1000 does not exist.';
        CopyJobPrices: Boolean;
        CopyQuantity: Boolean;
        CopyDimensions: Boolean;
        [InDataSet]
        PlanningLineTypeEnable: Boolean;
        [InDataSet]
        LedgerEntryLineTypeEnable: Boolean;
        Text004: Label 'Provide a valid source %1.';
        ConfirmAnswer: Boolean;
        NewStartingDate: Date;
        NewEndingDate: Date;
        Text011: Label '%1 must be equal to or earlier than %2.';
        TargetJob: Record Job;
        Recurring: Boolean;
        RecurrFormula: DateFormula;
        RecurrUntil: Date;
        EventDuration: Integer;
        RecurrErr: Label 'For recurring events you need to specify Starting Date and all recurring fields.';
        RecurrFormulaErr: Label 'You can''t specify negative Recurring Formula.';

    local procedure ValidateUserInput()
    var
        JobsSetup: Record "Jobs Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if (SourceJobNo = '') or not SourceJob.Get(SourceJob."No.") then
            Error(Text004, SourceJob.TableCaption);
        if Recurring then begin
            if (NewStartingDate = 0D) or (RecurrUntil = 0D) or (Format(RecurrFormula) = '') then
                Error(RecurrErr);
            CheckRecurrFormula();
        end;

        JobsSetup.Get();
        JobsSetup.TestField("Job Nos.");
        if TargetJobNo = '' then begin
            TargetJobNo := NoSeriesManagement.GetNextNo(JobsSetup."Job Nos.", 0D, true);
            if not Recurring then
                if not Confirm(Text002, true, TargetJobNo) then begin
                    TargetJobNo := '';
                    Error('');
                end;
        end else
            NoSeriesManagement.TestManual(JobsSetup."Job Nos.");
    end;

    local procedure ValidateSource()
    begin
        case true of
            Source = Source::"Job Planning Lines":
                begin
                    PlanningLineTypeEnable := true;
                    LedgerEntryLineTypeEnable := false;
                end;
            Source = Source::"Job Ledger Entries":
                begin
                    PlanningLineTypeEnable := false;
                    LedgerEntryLineTypeEnable := true;
                end;
            Source = Source::None:
                begin
                    PlanningLineTypeEnable := false;
                    LedgerEntryLineTypeEnable := false;
                end;
        end;
    end;

    procedure SetFromJob(SourceJob2: Record Job)
    begin
        SourceJob := SourceJob2;
        SourceJobNo := SourceJob."No.";
        TargetJobDescription := SourceJob.Description;
        TargetBillToCustomerNo := SourceJob."Bill-to Customer No.";
    end;

    procedure GetTargetJob(var NewJob: Record Job)
    begin
        NewJob.Get(TargetJobNo);
        NewJob.SetRecFilter();
    end;

    procedure GetConfirmAnswer(): Boolean
    begin
        exit(ConfirmAnswer);
    end;

    local procedure CheckDate()
    begin
        if (NewStartingDate > NewEndingDate) and (NewEndingDate <> 0D) then
            Error(Text011, SourceJob.FieldCaption("Starting Date"), SourceJob.FieldCaption("Ending Date"));
        if (NewStartingDate <> 0D) and (NewEndingDate <> 0D) then
            EventDuration := NewEndingDate - NewStartingDate;
    end;

    local procedure CheckRecurrFormula()
    var
        NewStartDate: Date;
    begin
        NewStartDate := CalcDate(RecurrFormula, NewStartingDate);
        if NewStartDate < NewStartingDate then
            Error(RecurrFormulaErr);
    end;

    local procedure CopyEvent()
    begin
        repeat
            ValidateUserInput();
            CopyJob.SetCopyOptions(CopyJobPrices, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
            CopyJob.SetJobTaskRange(FromJobTaskNo, ToJobTaskNo);
            CopyJob.SetJobTaskDateRange(FromDate, ToDate);
#if BC20
            CopyJob.CopyJob(SourceJob, TargetJobNo, TargetJobDescription, '', TargetBillToCustomerNo);
#else
            CopyJob.CopyJob(SourceJob, TargetJobNo, TargetJobDescription, TargetBillToCustomerNo);
#endif
            TargetJob.Get(TargetJobNo);
            TargetJob."Starting Date" := 0D;
            TargetJob."Ending Date" := 0D;
            if NewStartingDate <> 0D then
                TargetJob.Validate("Starting Date", NewStartingDate);
            if NewEndingDate <> 0D then
                TargetJob.Validate("Ending Date", NewEndingDate);
            if Recurring then
                TargetJob.Validate("NPR Event Status", TargetJob."NPR Event Status"::Planning)
            else begin
                TargetJob."NPR Event Status" := TargetJob.Status;
                TargetJob.Validate("NPR Event Status", SourceJob."NPR Event Status");
            end;
            TargetJob.Modify();
            if Recurring then begin
                NewStartingDate := CalcDate(RecurrFormula, NewStartingDate);
                if NewEndingDate <> 0D then
                    NewEndingDate := NewStartingDate + EventDuration;
                TargetJobNo := '';
            end;
        until NewStartingDate > RecurrUntil;
        if not Recurring then
            ConfirmAnswer := Confirm(Text001);
    end;
}

