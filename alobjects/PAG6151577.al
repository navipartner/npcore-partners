page 6151577 "Event Copy"
{
    // NPR5.32/TJ  /20170523 CASE 275974 Object was created as a copy of page 1040
    // NPR5.32/TJ  /20170523 CASE 275963 Set Visible property to FALSE on all controls in "Copy from" tab except SourceJobNo control
    //                                   Added new controls under "Copy to" tab: "Starting Date", "Ending Date"
    //                                   Added code to OnQueryClosePage
    // NPR5.34/TJ  /20170724 CASE 281187 Added code to OnOpenPage
    // NPR5.38/TJ  /20171110 CASE 296166 Added code to OnQueryClosePage
    // NPR5.40/TJ  /20170124 CASE 301375 Keeping original value of Event Status/Status field from SourceJob

    Caption = 'Copy Job';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group("Copy from")
            {
                Caption = 'Copy from';
                field(SourceJobNo; SourceJobNo)
                {
                    ApplicationArea = All;
                    Caption = 'Job No.';
                    TableRelation = Job;

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
                    ApplicationArea = All;
                    Caption = 'Job Task No. from';
                    Visible = false;

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
                    ApplicationArea = All;
                    Caption = 'Job Task No. to';
                    Visible = false;

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
                    ApplicationArea = All;
                    Caption = 'Source';
                    OptionCaption = 'Job Planning Lines,Job Ledger Entries,None';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateSource;
                    end;
                }
                field("Planning Line Type"; PlanningLineType)
                {
                    ApplicationArea = All;
                    Caption = 'Incl. Planning Line Type';
                    Enabled = PlanningLineTypeEnable;
                    OptionCaption = 'Schedule+Contract,Schedule,Contract';
                    Visible = false;
                }
                field("Ledger Entry Line Type"; LedgerEntryType)
                {
                    ApplicationArea = All;
                    Caption = 'Incl. Ledger Entry Line Type';
                    Enabled = LedgerEntryLineTypeEnable;
                    OptionCaption = 'Usage+Sale,Usage,Sale';
                    Visible = false;
                }
                field(FromDate; FromDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    Visible = false;
                }
                field(ToDate; ToDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    Visible = false;
                }
            }
            group("Copy to")
            {
                Caption = 'Copy to';
                field(TargetJobNo; TargetJobNo)
                {
                    ApplicationArea = All;
                    Caption = 'Job No.';
                }
                field(TargetJobDescription; TargetJobDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Job Description';
                }
                field(TargetBillToCustomerNo; TargetBillToCustomerNo)
                {
                    ApplicationArea = All;
                    Caption = 'Bill-To Customer No.';
                    TableRelation = Customer;
                }
                field(NewStartingDate; NewStartingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';

                    trigger OnValidate()
                    begin
                        CheckDate;
                    end;
                }
                field(NewEndingDate; NewEndingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';

                    trigger OnValidate()
                    begin
                        CheckDate;
                    end;
                }
            }
            group(Apply)
            {
                Caption = 'Apply';
                field(CopyJobPrices; CopyJobPrices)
                {
                    ApplicationArea = All;
                    Caption = 'Copy Job Prices';
                }
                field(CopyQuantity; CopyQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Copy Quantity';
                }
                field(CopyDimensions; CopyDimensions)
                {
                    ApplicationArea = All;
                    Caption = 'Copy Dimensions';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        PlanningLineType := PlanningLineType::"Schedule+Contract";
        LedgerEntryType := LedgerEntryType::"Usage+Sale";
        ValidateSource;
        //-NPR5.34 [281187]
        CopyDimensions := true;
        //+NPR5.34 [281187]
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput;
            CopyJob.SetCopyOptions(CopyJobPrices, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
            CopyJob.SetJobTaskRange(FromJobTaskNo, ToJobTaskNo);
            CopyJob.SetJobTaskDateRange(FromDate, ToDate);
            CopyJob.CopyJob(SourceJob, TargetJobNo, TargetJobDescription, TargetBillToCustomerNo);
            //-NPR5.32 [275963]
            TargetJob.Get(TargetJobNo);
            TargetJob."Starting Date" := 0D;
            TargetJob."Ending Date" := 0D;
            if NewStartingDate <> 0D then
                TargetJob.Validate("Starting Date", NewStartingDate);
            if NewEndingDate <> 0D then
                TargetJob.Validate("Ending Date", NewEndingDate);
            //-NPR5.38 [296166]
            TargetJob."Event Status" := TargetJob.Status;
            //+NPR5.38 [296166]
            //-NPR5.40 [301375]
            TargetJob.Validate("Event Status", SourceJob."Event Status");
            //+NPR5.40 [301375]
            TargetJob.Modify;
            //+NPR5.32 [275963]
            ConfirmAnswer := Confirm(Text001);
        end
    end;

    var
        SourceJob: Record Job;
        CopyJob: Codeunit "Copy Job";
        SourceJobNo: Code[20];
        FromJobTaskNo: Code[20];
        ToJobTaskNo: Code[20];
        TargetJobNo: Code[20];
        TargetJobDescription: Text[50];
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

    local procedure ValidateUserInput()
    var
        JobsSetup: Record "Jobs Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if (SourceJobNo = '') or not SourceJob.Get(SourceJob."No.") then
            Error(Text004, SourceJob.TableCaption);

        JobsSetup.Get;
        JobsSetup.TestField("Job Nos.");
        if TargetJobNo = '' then begin
            TargetJobNo := NoSeriesManagement.GetNextNo(JobsSetup."Job Nos.", 0D, true);
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
        NewJob.SetRecFilter;
    end;

    procedure GetConfirmAnswer(): Boolean
    begin
        exit(ConfirmAnswer);
    end;

    local procedure CheckDate()
    begin
        if (NewStartingDate > NewEndingDate) and (NewEndingDate <> 0D) then
            Error(Text011, SourceJob.FieldCaption("Starting Date"), SourceJob.FieldCaption("Ending Date"));
    end;
}

