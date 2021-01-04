page 6151589 "NPR Event Task Lines"
{
    Caption = 'Event Task Lines';
    DataCaptionFields = "Job No.";
    PageType = List;
    UsageCategory = Administration;
    SaveValues = true;
    SourceTable = "Job Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Job No. field';
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the value of the Job Task No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Job Task Type"; "Job Task Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Task Type field';
                }
                field(Totaling; Totaling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Totaling field';
                }
                field("Job Posting Group"; "Job Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Job Posting Group field';
                }
                field("WIP-Total"; "WIP-Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WIP-Total field';
                }
                field("WIP Method"; "WIP Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WIP Method field';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field("Schedule (Total Cost)"; "Schedule (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Schedule (Total Cost) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Total Cost (LCY)");
                    end;
                }
                field("Schedule (Total Price)"; "Schedule (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Schedule (Total Price) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                    end;
                }
                field("Usage (Total Cost)"; "Usage (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Usage (Total Cost) field';
                }
                field("Usage (Total Price)"; "Usage (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Usage (Total Price) field';
                }
                field("Contract (Total Cost)"; "Contract (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract (Total Cost) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(true, true, false, false, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Total Cost (LCY)");
                    end;
                }
                field("Contract (Total Price)"; "Contract (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract (Total Price) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(true, true, false, false, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                    end;
                }
                field("Contract (Invoiced Cost)"; "Contract (Invoiced Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract (Invoiced Cost) field';
                }
                field("Contract (Invoiced Price)"; "Contract (Invoiced Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract (Invoiced Price) field';
                }
                field("Remaining (Total Cost)"; "Remaining (Total Cost)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining (Total Cost) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Remaining Total Cost (LCY)");
                    end;
                }
                field("Remaining (Total Price)"; "Remaining (Total Price)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining (Total Price) field';

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Remaining Line Amount (LCY)");
                    end;
                }
                field("EAC (Total Cost)"; CalcEACTotalCost)
                {
                    ApplicationArea = All;
                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the value of the EAC (Total Cost) field';
                }
                field("EAC (Total Price)"; CalcEACTotalPrice)
                {
                    ApplicationArea = All;
                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the value of the EAC (Total Price) field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Outstanding Orders"; "Outstanding Orders")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Outstanding Orders field';

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine);
                        PurchLine.SetFilter("Outstanding Amount (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; "Amt. Rcd. Not Invoiced")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amt. Rcd. Not Invoiced field';

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine);
                        PurchLine.SetFilter("Amt. Rcd. Not Invoiced (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Job Task")
            {
                Caption = '&Job Task';
                Image = Task;
                action(EventPlanningLines)
                {
                    Caption = 'Event &Planning Lines';
                    Image = JobLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+P';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Event &Planning Lines action';

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        EventPlanningLines: Page "NPR Event Planning Lines";
                    begin
                        TestField("Job Task Type", "Job Task Type"::Posting);
                        TestField("Job No.");
                        TestField("Job Task No.");
                        JobPlanningLine.FilterGroup(2);
                        JobPlanningLine.SetRange("Job No.", "Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task No.");
                        JobPlanningLine.FilterGroup(0);
                        EventPlanningLines.SetJobTaskNoVisible(false);
                        EventPlanningLines.SetJobNo("Job No.");
                        EventPlanningLines.SetTableView(JobPlanningLine);
                        EventPlanningLines.Run;
                    end;
                }
                action(JobTaskStatistics)
                {
                    Caption = 'Job Task &Statistics';
                    Image = StatisticsDocument;
                    RunObject = Page "Job Task Statistics";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Job Task &Statistics action';
                }
                action("Job &Task Card")
                {
                    Caption = 'Job &Task Card';
                    Image = Task;
                    RunObject = Page "Job Task Card";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Job &Task Card action';
                }
                separator("-")
                {
                    Caption = '-';
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    action("Dimensions-&Single")
                    {
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Job Task Dimensions";
                        RunPageLink = "Job No." = FIELD("Job No."),
                                      "Job Task No." = FIELD("Job Task No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-&Single action';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-&Multiple action';

                        trigger OnAction()
                        var
                            JobTask: Record "Job Task";
                            JobTaskDimensionsMultiple: Page "Job Task Dimensions Multiple";
                        begin
                            CurrPage.SetSelectionFilter(JobTask);
                            JobTaskDimensionsMultiple.SetMultiJobTask(JobTask);
                            JobTaskDimensionsMultiple.RunModal;
                        end;
                    }
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("Sales &Documents")
                {
                    Caption = 'Sales &Documents';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales &Documents action';

                    trigger OnAction()
                    var
                        EventInvoices: Page "NPR Event Invoices";
                    begin
                        EventInvoices.SetPrJobTask(Rec);
                        EventInvoices.RunModal;
                    end;
                }
            }
            group("W&IP")
            {
                Caption = 'W&IP';
                Image = WIP;
                action("&WIP Entries")
                {
                    Caption = '&WIP Entries';
                    Image = WIPEntries;
                    RunObject = Page "Job WIP Entries";
                    RunPageLink = "Job No." = FIELD("Job No.");
                    RunPageView = SORTING("Job No.", "Job Posting Group", "WIP Posting Date");
                    ApplicationArea = All;
                    ToolTip = 'Executes the &WIP Entries action';
                }
                action("WIP &G/L Entries")
                {
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Job WIP G/L Entries";
                    RunPageLink = "Job No." = FIELD("Job No.");
                    RunPageView = SORTING("Job No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the WIP &G/L Entries action';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Job Ledger E&ntries")
                {
                    Caption = 'Job Ledger E&ntries';
                    Image = JobLedger;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    RunPageView = SORTING("Job No.", "Job Task No.");
                    ShortCutKey = 'Ctrl+F7';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Job Ledger E&ntries action';
                }
            }
        }
        area(processing)
        {
            group("New Documents")
            {
                Caption = 'New Documents';
                Image = Invoice;
                action("Create &Sales Invoice")
                {
                    Caption = 'Create &Sales Invoice';
                    Ellipsis = true;
                    Image = Invoice;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create &Sales Invoice action';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked;

                        JobTask.SetRange("Job No.", Job."No.");
                        if "Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Job Create Sales Invoice", true, false, JobTask);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Split &Planning Lines")
                {
                    Caption = 'Split &Planning Lines';
                    Ellipsis = true;
                    Image = Splitlines;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Split &Planning Lines action';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked;

                        TestField("Job Task No.");
                        JobTask.SetRange("Job No.", Job."No.");
                        JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Job Split Planning Line", true, false, JobTask);
                    end;
                }
                action("Change &Dates")
                {
                    Caption = 'Change &Dates';
                    Ellipsis = true;
                    Image = ChangeDate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Change &Dates action';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked;

                        JobTask.SetRange("Job No.", Job."No.");
                        if "Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Change Job Dates", true, false, JobTask);
                    end;
                }
                action("<Action7>")
                {
                    Caption = 'I&ndent Job Tasks';
                    Image = Indent;
                    RunObject = Codeunit "Job Task-Indent";
                    ApplicationArea = All;
                    ToolTip = 'Executes the I&ndent Job Tasks action';
                }
                group("&Copy")
                {
                    Caption = '&Copy';
                    Image = Copy;
                    action("Copy Job Planning Lines &from...")
                    {
                        Caption = 'Copy Job Planning Lines &from...';
                        Ellipsis = true;
                        Image = CopyToTask;
                        Promoted = true;
                        PromotedCategory = Process;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Copy Job Planning Lines &from... action';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            TestField("Job Task Type", "Job Task Type"::Posting);
                            CopyJobPlanningLines.SetToJobTask(Rec);
                            CopyJobPlanningLines.RunModal;
                        end;
                    }
                    action("Copy Job Planning Lines &to...")
                    {
                        Caption = 'Copy Job Planning Lines &to...';
                        Ellipsis = true;
                        Image = CopyFromTask;
                        Promoted = true;
                        PromotedCategory = Process;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Copy Job Planning Lines &to... action';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            TestField("Job Task Type", "Job Task Type"::Posting);
                            CopyJobPlanningLines.SetFromJobTask(Rec);
                            CopyJobPlanningLines.RunModal;
                        end;
                    }
                }
                group("<Action13>")
                {
                    Caption = 'W&IP';
                    Image = WIP;
                    action("<Action48>")
                    {
                        Caption = '&Calculate WIP';
                        Ellipsis = true;
                        Image = CalculateWIP;
                        ApplicationArea = All;
                        ToolTip = 'Executes the &Calculate WIP action';

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            TestField("Job No.");
                            Job.Get("Job No.");
                            Job.SetRange("No.", Job."No.");
                            REPORT.RunModal(REPORT::"Job Calculate WIP", true, false, Job);
                        end;
                    }
                    action("<Action49>")
                    {
                        Caption = '&Post WIP to G/L';
                        Ellipsis = true;
                        Image = PostOrder;
                        ShortCutKey = 'F9';
                        ApplicationArea = All;
                        ToolTip = 'Executes the &Post WIP to G/L action';

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            TestField("Job No.");
                            Job.Get("Job No.");
                            Job.SetRange("No.", Job."No.");
                            REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Job);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Indentation;
        StyleIsStrong := "Job Task Type" <> "Job Task Type"::Posting;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearTempDim;
    end;

    var
        [InDataSet]
        DescriptionIndent: Integer;
        [InDataSet]
        StyleIsStrong: Boolean;

    local procedure SetPurchLineFilters(var PurchLine: Record "Purchase Line")
    begin
        PurchLine.SetCurrentKey("Document Type", "Job No.", "Job Task No.");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Job No.", "Job No.");
        if "Job Task Type" in ["Job Task Type"::Total, "Job Task Type"::"End-Total"] then
            PurchLine.SetFilter("Job Task No.", Totaling)
        else
            PurchLine.SetRange("Job Task No.", "Job Task No.");
    end;

    local procedure SetDrillDownFilter(SetContractLineFilter: Boolean; ContractLine: Boolean; SetScheduleLineFilter: Boolean; ScheduleLine: Boolean; var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
        if Rec.Totaling <> '' then
            JobPlanningLine.SetFilter("Job Task No.", Rec.Totaling);
        if SetContractLineFilter then
            JobPlanningLine.SetRange("Contract Line", ContractLine);
        if SetScheduleLineFilter then
            JobPlanningLine.SetRange("Schedule Line", ScheduleLine);
        if Rec.GetFilter("Planning Date Filter") <> '' then
            JobPlanningLine.SetFilter("Planning Date", Rec.GetFilter("Planning Date Filter"));
    end;
}

