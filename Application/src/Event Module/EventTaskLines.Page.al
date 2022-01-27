page 6151589 "NPR Event Task Lines"
{
    Extensible = False;
    Caption = 'Event Task Lines';
    DataCaptionFields = "Job No.";
    PageType = List;
    UsageCategory = Administration;

    SaveValues = true;
    SourceTable = "Job Task";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Job No."; Rec."Job No.")
                {

                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Job No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Task No."; Rec."Job Task No.")
                {

                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the value of the Job Task No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Task Type"; Rec."Job Task Type")
                {

                    ToolTip = 'Specifies the value of the Job Task Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Totaling; Rec.Totaling)
                {

                    ToolTip = 'Specifies the value of the Totaling field';
                    ApplicationArea = NPRRetail;
                }
                field("Job Posting Group"; Rec."Job Posting Group")
                {

                    ToolTip = 'Specifies the value of the Job Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("WIP-Total"; Rec."WIP-Total")
                {

                    ToolTip = 'Specifies the value of the WIP-Total field';
                    ApplicationArea = NPRRetail;
                }
                field("WIP Method"; Rec."WIP Method")
                {

                    ToolTip = 'Specifies the value of the WIP Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; Rec."End Date")
                {

                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {

                    ToolTip = 'Specifies the value of the Schedule (Total Cost) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Total Cost (LCY)");
                    end;
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {

                    ToolTip = 'Specifies the value of the Schedule (Total Price) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                    end;
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {

                    ToolTip = 'Specifies the value of the Usage (Total Cost) field';
                    ApplicationArea = NPRRetail;
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {

                    ToolTip = 'Specifies the value of the Usage (Total Price) field';
                    ApplicationArea = NPRRetail;
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {

                    ToolTip = 'Specifies the value of the Contract (Total Cost) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(true, true, false, false, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Total Cost (LCY)");
                    end;
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {

                    ToolTip = 'Specifies the value of the Contract (Total Price) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(true, true, false, false, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Line Amount (LCY)");
                    end;
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {

                    ToolTip = 'Specifies the value of the Contract (Invoiced Cost) field';
                    ApplicationArea = NPRRetail;
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {

                    ToolTip = 'Specifies the value of the Contract (Invoiced Price) field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {

                    ToolTip = 'Specifies the value of the Remaining (Total Cost) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Remaining Total Cost (LCY)");
                    end;
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {

                    ToolTip = 'Specifies the value of the Remaining (Total Price) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                    begin
                        SetDrillDownFilter(false, false, true, true, JobPlanningLine);
                        PAGE.Run(PAGE::"NPR Event Planning Lines", JobPlanningLine, JobPlanningLine."Remaining Line Amount (LCY)");
                    end;
                }
                field("EAC (Total Cost)"; Rec.CalcEACTotalCost())
                {

                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the value of the EAC (Total Cost) field';
                    ApplicationArea = NPRRetail;
                }
                field("EAC (Total Price)"; Rec.CalcEACTotalPrice())
                {

                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the value of the EAC (Total Price) field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Outstanding Orders"; Rec."Outstanding Orders")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Outstanding Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine);
                        PurchLine.SetFilter("Outstanding Amount (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; Rec."Amt. Rcd. Not Invoiced")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amt. Rcd. Not Invoiced field';
                    ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;

            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+P';

                    ToolTip = 'Executes the Event &Planning Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        EventPlanningLines: Page "NPR Event Planning Lines";
                    begin
                        Rec.TestField("Job Task Type", Rec."Job Task Type"::Posting);
                        Rec.TestField("Job No.");
                        Rec.TestField("Job Task No.");
                        JobPlanningLine.FilterGroup(2);
                        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
                        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
                        JobPlanningLine.FilterGroup(0);
                        EventPlanningLines.SetJobTaskNoVisible(false);
                        EventPlanningLines.SetJobNo(Rec."Job No.");
                        EventPlanningLines.SetTableView(JobPlanningLine);
                        EventPlanningLines.Run();
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

                    ToolTip = 'Executes the Job Task &Statistics action';
                    ApplicationArea = NPRRetail;
                }
                action("Job &Task Card")
                {
                    Caption = 'Job &Task Card';
                    Image = Task;
                    RunObject = Page "Job Task Card";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'Shift+F7';

                    ToolTip = 'Executes the Job &Task Card action';
                    ApplicationArea = NPRRetail;
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

                        ToolTip = 'Executes the Dimensions-&Single action';
                        ApplicationArea = NPRRetail;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        ToolTip = 'Executes the Dimensions-&Multiple action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            JobTask: Record "Job Task";
                            JobTaskDimensionsMultiple: Page "Job Task Dimensions Multiple";
                        begin
                            CurrPage.SetSelectionFilter(JobTask);
                            JobTaskDimensionsMultiple.SetMultiJobTask(JobTask);
                            JobTaskDimensionsMultiple.RunModal();
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
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Executes the Sales &Documents action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EventInvoices: Page "NPR Event Invoices";
                    begin
                        EventInvoices.SetPrJobTask(Rec);
                        EventInvoices.RunModal();
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

                    ToolTip = 'Executes the &WIP Entries action';
                    ApplicationArea = NPRRetail;
                }
                action("WIP &G/L Entries")
                {
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Job WIP G/L Entries";
                    RunPageLink = "Job No." = FIELD("Job No.");
                    RunPageView = SORTING("Job No.");

                    ToolTip = 'Executes the WIP &G/L Entries action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Job Ledger E&ntries action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Create &Sales Invoice action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        Rec.TestField("Job No.");
                        Job.Get(Rec."Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        JobTask.SetRange("Job No.", Job."No.");
                        if Rec."Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", Rec."Job Task No.");

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
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Executes the Split &Planning Lines action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        Rec.TestField("Job No.");
                        Job.Get(Rec."Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        Rec.TestField("Job Task No.");
                        JobTask.SetRange("Job No.", Job."No.");
                        JobTask.SetRange("Job Task No.", Rec."Job Task No.");

                        REPORT.RunModal(REPORT::"Job Split Planning Line", true, false, JobTask);
                    end;
                }
                action("Change &Dates")
                {
                    Caption = 'Change &Dates';
                    Ellipsis = true;
                    Image = ChangeDate;

                    ToolTip = 'Executes the Change &Dates action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        Rec.TestField("Job No.");
                        Job.Get(Rec."Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        JobTask.SetRange("Job No.", Job."No.");
                        if Rec."Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", Rec."Job Task No.");

                        REPORT.RunModal(REPORT::"Change Job Dates", true, false, JobTask);
                    end;
                }
                action("<Action7>")
                {
                    Caption = 'I&ndent Job Tasks';
                    Image = Indent;
                    RunObject = Codeunit "Job Task-Indent";

                    ToolTip = 'Executes the I&ndent Job Tasks action';
                    ApplicationArea = NPRRetail;
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
                        PromotedOnly = true;
                        PromotedCategory = Process;

                        ToolTip = 'Executes the Copy Job Planning Lines &from... action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            Rec.TestField("Job Task Type", Rec."Job Task Type"::Posting);
                            CopyJobPlanningLines.SetToJobTask(Rec);
                            CopyJobPlanningLines.RunModal();
                        end;
                    }
                    action("Copy Job Planning Lines &to...")
                    {
                        Caption = 'Copy Job Planning Lines &to...';
                        Ellipsis = true;
                        Image = CopyFromTask;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Process;

                        ToolTip = 'Executes the Copy Job Planning Lines &to... action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            Rec.TestField("Job Task Type", Rec."Job Task Type"::Posting);
                            CopyJobPlanningLines.SetFromJobTask(Rec);
                            CopyJobPlanningLines.RunModal();
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

                        ToolTip = 'Executes the &Calculate WIP action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            Rec.TestField("Job No.");
                            Job.Get(Rec."Job No.");
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

                        ToolTip = 'Executes the &Post WIP to G/L action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            Rec.TestField("Job No.");
                            Job.Get(Rec."Job No.");
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
        DescriptionIndent := Rec.Indentation;
        StyleIsStrong := Rec."Job Task Type" <> Rec."Job Task Type"::Posting;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ClearTempDim();
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
        PurchLine.SetRange("Job No.", Rec."Job No.");
        if Rec."Job Task Type" in [Rec."Job Task Type"::Total, Rec."Job Task Type"::"End-Total"] then
            PurchLine.SetFilter("Job Task No.", Rec.Totaling)
        else
            PurchLine.SetRange("Job Task No.", Rec."Job Task No.");
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

